#!/usr/bin/env bash

set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
  # shellcheck disable=SC2016 # The installer command is instructional text.
  echo 'Homebrew not installed. Install: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  exit 1
fi

brew bundle install --no-upgrade

# 社内 tap は社外環境でアクセスできないため、Homebrew の自動更新から除外する。
tap_dir=/opt/homebrew/Library/Taps/perman/homebrew-tap
if [[ -d "$tap_dir" ]]; then
  git -C "$tap_dir" config homebrew.autoupdate false
  echo "perman/tap: disabled auto-update"
fi
