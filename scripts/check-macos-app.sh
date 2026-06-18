#!/usr/bin/env bash
set -eo pipefail

XATTR="${XATTR:-/usr/bin/xattr}"
CODESIGN="${CODESIGN:-/usr/bin/codesign}"
SPCTL="${SPCTL:-/usr/sbin/spctl}"
SUDO="${SUDO:-sudo}"
LSREGISTER="${LSREGISTER:-/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister}"

KNOWN_APP_PATHS=(
  "${HOME}/.codex/computer-use/Codex Computer Use.app"
  "/Applications/Codex.app/Contents/Resources/plugins/openai-bundled/plugins/computer-use/Codex Computer Use.app"
)
CODEX_COMPUTER_USE_CACHE_ROOT="${HOME}/.codex/plugins/cache/openai-bundled/computer-use"

usage() {
  printf '%s\n' \
    "Usage:" \
    "  scripts/check-macos-app.sh --fix" \
    "  scripts/check-macos-app.sh [--fix] /path/to/App.app" \
    "  scripts/check-macos-app.sh [--fix] --codex-computer-use" \
    "  scripts/check-macos-app.sh --list" \
    "" \
    "Options:" \
    "  --fix                 Fix known app targets, or the given app path." \
    "  --codex-computer-use  Check known Codex Computer Use app locations." \
    "  --list                Print known app location aliases." \
    "  -h, --help            Show this help."
}

add_target_if_present() {
  local app_path="${1/#\~/${HOME}}"
  local existing_path

  [[ -d "${app_path}" ]] || return 1

  if [[ "${#targets[@]}" -gt 0 ]]; then
    for existing_path in "${targets[@]}"; do
      [[ "${existing_path}" == "${app_path}" ]] && return 0
    done
  fi

  targets+=("${app_path}")
}

add_known_apps() {
  local app_path
  local cache_dir

  for app_path in "${KNOWN_APP_PATHS[@]}"; do
    add_target_if_present "${app_path}" || true
  done

  for cache_dir in "${CODEX_COMPUTER_USE_CACHE_ROOT}"/*; do
    app_path="${cache_dir}/Codex Computer Use.app"
    add_target_if_present "${app_path}" || true
  done
}

list_known_targets() {
  targets=()
  add_known_apps

  printf '%s\n' "Known aliases:"
  printf '%s\n' "  --codex-computer-use"
  for app_path in "${targets[@]}"; do
    printf '    %s\n' "${app_path}"
  done
}

fix=false
known_mode=false
targets=()
required_targets=()

quarantine_status() {
  local app_path="$1"
  local xattr_output

  if ! xattr_output=$("${XATTR}" -lr "${app_path}" 2>&1); then
    echo "quarantine: warning: xattr read failed: ${xattr_output}" >&2
    return 2
  fi

  if printf '%s\n' "${xattr_output}" | /usr/bin/grep -q "com.apple.quarantine"; then
    return 0
  fi

  return 1
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --fix)
      fix=true
      ;;
    --auto-fix)
      echo "ERROR: --auto-fix was removed. Use --fix." >&2
      usage >&2
      exit 64
      ;;
    --codex-computer-use)
      known_mode=true
      ;;
    --list)
      list_known_targets
      exit 0
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    -*)
      echo "ERROR: unknown option: $1" >&2
      usage >&2
      exit 64
      ;;
    *)
      required_targets+=("$1")
      ;;
  esac
  shift
done

if [[ "${fix}" == true && "${#required_targets[@]}" -eq 0 ]]; then
  known_mode=true
fi

if [[ "${known_mode}" == true ]]; then
  add_known_apps
fi

missing=()
for app_path in "${required_targets[@]}"; do
  expanded_path="${app_path/#\~/${HOME}}"
  if ! add_target_if_present "${expanded_path}"; then
    missing+=("${expanded_path}")
  fi
done

if [[ "${known_mode}" == false && "${#required_targets[@]}" -eq 0 ]]; then
  usage >&2
  exit 64
fi

if [[ "${#missing[@]}" -gt 0 ]]; then
  echo "Missing targets:"
  printf ' - %s\n' "${missing[@]}"
  echo
  echo "ERROR: required targets are missing:" >&2
  printf ' - %s\n' "${missing[@]}" >&2
  exit 1
fi

if [[ "${#targets[@]}" -eq 0 ]]; then
  echo "ERROR: no target apps found." >&2
  exit 1
fi

echo "Targets:"
printf ' - %s\n' "${targets[@]}"

if [[ "${fix}" == true ]]; then
  echo
  echo "Fixing quarantine and LaunchServices when possible."
fi

for app_path in "${targets[@]}"; do
  echo
  echo "Target: ${app_path}"

  quarantine_result=0
  quarantine_status "${app_path}" || quarantine_result=$?
  if [[ "${quarantine_result}" -eq 0 ]]; then
    echo "quarantine: present"
    if [[ "${fix}" == true ]]; then
      if ! "${SUDO}" "${XATTR}" -dr com.apple.quarantine "${app_path}"; then
        echo "quarantine: failed to remove"
        check_failed=true
      fi

      quarantine_after_result=0
      quarantine_status "${app_path}" || quarantine_after_result=$?
      if [[ "${quarantine_after_result}" -eq 0 ]]; then
        echo "quarantine: still present after removal"
        check_failed=true
      elif [[ "${quarantine_after_result}" -eq 1 ]]; then
        echo "quarantine: removed"
      else
        check_failed=true
      fi
    fi
  elif [[ "${quarantine_result}" -eq 1 ]]; then
    echo "quarantine: not present"
  else
    check_failed=true
  fi

  echo "codesign:"
  if ! "${CODESIGN}" --verify --deep --strict --verbose=2 "${app_path}" 2>&1; then
    check_failed=true
  fi
  echo "spctl:"
  if ! "${SPCTL}" --assess --type execute --verbose=4 "${app_path}" 2>&1; then
    echo "spctl: warning: assessment failed; codesign result is authoritative for this script." >&2
  fi

  if [[ "${fix}" == true && -x "${LSREGISTER}" ]]; then
    if "${LSREGISTER}" -f "${app_path}" >/dev/null 2>&1; then
      echo "launchservices: registered"
    else
      echo "launchservices: failed to register"
      check_failed=true
    fi
  fi
done

if [[ "${check_failed:-false}" == true ]]; then
  echo
  echo "ERROR: one or more checks failed." >&2
  exit 1
fi
