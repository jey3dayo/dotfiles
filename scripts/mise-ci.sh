#!/usr/bin/env bash

set -euo pipefail

task=${1:?task is required}

is_wsl_checkout() {
  [[ "${MISE_WSL_SNAPSHOT:-0}" != "1" && "${PWD#/mnt/}" != "$PWD" ]]
}

case "$task" in
  gitleaks)
    if [[ "${SKIP_GITLEAKS:-0}" == "1" ]]; then
      echo "Skip ci:gitleaks (SKIP_GITLEAKS=1)"
      exit 0
    fi
    command -v gitleaks >/dev/null 2>&1 || {
      echo "Error: gitleaks not found. Install gitleaks or run with SKIP_GITLEAKS=1" >&2
      exit 1
    }
    gitleaks git -v
    ;;
  verify-deploy)
    mise dotfiles apply --yes --force
    mise dotfiles status --missing
    echo "✅ mise dotfiles はすべて適用済みです"
    ;;
  install)
    luarocks install --local luacheck
    luarocks install --local busted
    ;;
  quick)
    if is_wsl_checkout; then
      exec bash ./scripts/windows/mise-wsl-task.sh ci:quick
    fi
    mise run check:format
    mise run check:lint:quick
    ;;
  full)
    if is_wsl_checkout; then
      exec bash ./scripts/windows/mise-wsl-task.sh ci
    fi
    mise run check
    mise run test:ts
    mise run test:lua
    mise run ci:gitleaks
    ;;
  *)
    echo "Unsupported CI task: $task" >&2
    exit 2
    ;;
esac
