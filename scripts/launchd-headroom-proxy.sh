#!/bin/sh
# Headroom proxy を専用 venv から常駐起動する LaunchAgent 本体。
# 旧 home.nix launchd.agents.headroom-proxy から移管（mise bootstrap 管理）。
# venv の構築・更新は scripts/bootstrap-task.sh が担当する。
set -eu

headroom_service_dir="$HOME/.local/share/headroom-launchd"
headroom_venv="$headroom_service_dir/venv"
headroom_bin="$headroom_venv/bin/headroom"

mkdir -p "$HOME/.headroom/logs"

if [ ! -x "$headroom_bin" ]; then
  echo "Headroom service binary is missing: $headroom_bin" >&2
  echo "Run: mise run bootstrap" >&2
  exit 78
fi

PATH="$headroom_venv/bin:$HOME/bin:$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH

exec "$headroom_bin" proxy \
  --host 127.0.0.1 \
  --port 8787 \
  --mode cache \
  --no-learn \
  --no-memory-tools \
  --no-telemetry \
  --log-file "$HOME/.headroom/logs/proxy.jsonl"
