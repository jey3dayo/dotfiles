#!/usr/bin/env sh
# mise/lib/nixfmt.sh
# nixfmt wrapper with fallback to nix shell.
#
# Usage (source this file, then call run_nixfmt):
#   . "./mise/lib/nixfmt.sh"
#   run_nixfmt [flags] [files...]

run_nixfmt() {
  if command -v nixfmt >/dev/null 2>&1; then
    nixfmt "$@"
  elif command -v nix >/dev/null 2>&1; then
    nix run .#formatter -- "$@"
  else
    echo "❌ nixfmt not found. Install it locally or make nix available for fallback."
    exit 1
  fi
}
