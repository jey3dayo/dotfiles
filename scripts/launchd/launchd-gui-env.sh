#!/bin/sh
# GUI アプリ向け環境変数を launchctl setenv で注入する LaunchAgent 本体。
# 旧 home.nix launchd.agents.codex-gui-env から移管（mise bootstrap 管理）。
set -eu

PATH="$HOME/.mise/shims:$HOME/bin:$HOME/.local/bin:$HOME/.config/scripts:$HOME/.cargo/bin:$HOME/go/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH

"$HOME/.config/scripts/setup-env.sh"

# npm userconfig を GUI 起動アプリへも伝播（~/.npmrc shim 廃止のため）
launchctl setenv NPM_CONFIG_USERCONFIG "$HOME/.config/npm/npmrc"
