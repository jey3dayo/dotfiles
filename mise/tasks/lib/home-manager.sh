#!/usr/bin/env sh

NIX_DAEMON_PROFILE="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"

ensure_nix_or_fail() {
  error_message="${1:-nix not found.}"

  if ! command -v nix >/dev/null 2>&1; then
    if [ -f "$NIX_DAEMON_PROFILE" ]; then
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
  if command -v home-manager >/dev/null 2>&1; then
    home-manager "$@"
    return $?
  fi

  ensure_nix_or_fail "nix not found. Cannot run home-manager fallback." || return $?
  nix run home-manager -- "$@"
}
