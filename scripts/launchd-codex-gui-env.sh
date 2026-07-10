#!/bin/sh
# GUI アプリ向け環境変数を launchctl setenv で注入する LaunchAgent 本体。
# 旧 home.nix launchd.agents.codex-gui-env から移管（mise bootstrap 管理）。
set -eu

PATH="$HOME/.mise/shims:$HOME/bin:$HOME/.local/bin:$HOME/.config/scripts:$HOME/.cargo/bin:$HOME/go/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH

"$HOME/.config/scripts/setup-env.sh"

env_local="$HOME/.config/.env.local"
if [ ! -f "$env_local" ]; then
  echo "Missing env file: $env_local" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
. "$env_local"
set +a

# npm userconfig を GUI 起動アプリへも伝播（~/.npmrc shim 廃止のため）
launchctl setenv NPM_CONFIG_USERCONFIG "$HOME/.config/npm/npmrc"

# secret は .env.local 全体ではなく、GUI アプリが参照する key だけを allowlist する
if [ -n "${JINA_API_KEY:-}" ]; then
  launchctl setenv JINA_API_KEY "$JINA_API_KEY"
  echo "Set GUI environment variable: JINA_API_KEY"
else
  echo "Skipped empty GUI environment variable: JINA_API_KEY"
fi
