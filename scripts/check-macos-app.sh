#!/usr/bin/env bash
set -euo pipefail

XATTR="${XATTR:-/usr/bin/xattr}"
CODESIGN="${CODESIGN:-/usr/bin/codesign}"
SPCTL="${SPCTL:-/usr/sbin/spctl}"
SUDO="${SUDO:-sudo}"
LSREGISTER="${LSREGISTER:-/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister}"

usage() {
  printf '%s\n' \
    "Usage:" \
    "  scripts/check-macos-app.sh --auto-fix" \
    "  scripts/check-macos-app.sh [--auto-fix] /path/to/App.app" \
    "  scripts/check-macos-app.sh [--auto-fix] --codex-computer-use" \
    "  scripts/check-macos-app.sh --list" \
    "" \
    "Options:" \
    "  --auto-fix            Auto-fix known app targets, or the given app path." \
    "  --fix                 Alias for --auto-fix." \
    "  --codex-computer-use  Check known Codex Computer Use app locations." \
    "  --list                Print known app location aliases." \
    "  -h, --help            Show this help."
}

known_codex_computer_use_paths() {
  local app_path
  printf '%s\n' "${HOME}/.codex/computer-use/Codex Computer Use.app"

  for app_path in "${HOME}"/.codex/plugins/cache/openai-bundled/computer-use/*/"Codex Computer Use.app"; do
    [[ -d "${app_path}" ]] && printf '%s\n' "${app_path}"
  done

  printf '%s\n' "/Applications/Codex.app/Contents/Resources/plugins/openai-bundled/plugins/computer-use/Codex Computer Use.app"
}

list_known_targets() {
  printf '%s\n' "Known aliases:"
  printf '%s\n' "  --codex-computer-use"
  known_codex_computer_use_paths | while IFS= read -r app_path; do
    printf '    %s\n' "${app_path}"
  done
}

auto_fix=false
targets=()
optional_targets=()

add_target() {
  targets+=("$1")
  optional_targets+=("${2:-false}")
}

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
    --auto-fix | --fix)
      auto_fix=true
      ;;
    --codex-computer-use)
      while IFS= read -r app_path; do
        add_target "${app_path}" true
      done < <(known_codex_computer_use_paths)
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
      add_target "$1" false
      ;;
  esac
  shift
done

if [[ "${#targets[@]}" -eq 0 ]]; then
  if [[ "${auto_fix}" == true ]]; then
    while IFS= read -r app_path; do
      add_target "${app_path}" true
    done < <(known_codex_computer_use_paths)
  else
    usage >&2
    exit 64
  fi
fi

found=()
missing=()
required_missing=()
seen_targets=""
for index in "${!targets[@]}"; do
  app_path="${targets[${index}]}"
  optional="${optional_targets[${index}]}"
  expanded_path="${app_path/#\~/${HOME}}"
  case "
${seen_targets}
" in
    *"
${expanded_path}
"*)
      continue
      ;;
  esac
  seen_targets="${seen_targets}
${expanded_path}"

  if [[ -d "${expanded_path}" ]]; then
    found+=("${expanded_path}")
  else
    missing+=("${expanded_path}")
    if [[ "${optional}" != true ]]; then
      required_missing+=("${expanded_path}")
    fi
  fi
done

if [[ "${#missing[@]}" -gt 0 ]]; then
  echo "Missing targets:"
  printf ' - %s\n' "${missing[@]}"
  echo
fi

if [[ "${#required_missing[@]}" -gt 0 ]]; then
  echo "ERROR: required targets are missing:" >&2
  printf ' - %s\n' "${required_missing[@]}" >&2
  exit 1
fi

if [[ "${#found[@]}" -eq 0 ]]; then
  echo "ERROR: no target apps found." >&2
  exit 1
fi

echo "Targets:"
printf ' - %s\n' "${found[@]}"

if [[ "${auto_fix}" == true ]]; then
  echo
  echo "Auto-fixing quarantine and LaunchServices when possible."
fi

for app_path in "${found[@]}"; do
  echo
  echo "Target: ${app_path}"

  quarantine_result=0
  quarantine_status "${app_path}" || quarantine_result=$?
  if [[ "${quarantine_result}" -eq 0 ]]; then
    echo "quarantine: present"
    if [[ "${auto_fix}" == true ]]; then
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

  if [[ "${auto_fix}" == true && -x "${LSREGISTER}" ]]; then
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
