#!/usr/bin/env sh

NIX_DAEMON_PROFILE="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"

configure_nix_github_token() {
  if [ "${NIX_GITHUB_TOKEN:-1}" = "0" ]; then
    return 0
  fi

  case "${NIX_CONFIG:-}" in
    *access-tokens*) return 0 ;;
  esac

  if ! command -v gh >/dev/null 2>&1; then
    return 0
  fi

  github_token="$(gh auth token 2>/dev/null || true)"
  if [ -z "$github_token" ]; then
    return 0
  fi

  if [ -n "${NIX_CONFIG:-}" ]; then
    NIX_CONFIG="${NIX_CONFIG}
access-tokens = github.com=${github_token}"
  else
    NIX_CONFIG="access-tokens = github.com=${github_token}"
  fi
  export NIX_CONFIG
}

ensure_nix_or_fail() {
  error_message="${1:-nix not found.}"

  if ! command -v nix >/dev/null 2>&1; then
    if [ -f "$NIX_DAEMON_PROFILE" ]; then
      # shellcheck source=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      . "$NIX_DAEMON_PROFILE"
    fi
  fi

  if ! command -v nix >/dev/null 2>&1; then
    printf '%s\n' "❌ $error_message" >&2
    return 127
  fi

  return 0
}

run_hm() {
  configure_nix_github_token

  if command -v home-manager >/dev/null 2>&1; then
    home-manager "$@"
    return $?
  fi

  ensure_nix_or_fail "nix not found. Cannot run home-manager fallback." || return $?
  nix run home-manager -- "$@"
}
