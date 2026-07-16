#!/usr/bin/env bash
# mise bootstrap の最終ステップ（[tasks.bootstrap]）から呼ばれる冪等セットアップ。
# 旧 home.nix の activation script（headroom venv 構築）から移管。
set -euo pipefail

# --------------------------------------
# Headroom proxy 用 venv（version marker で冪等化、macOS のみ）
# --------------------------------------
if [ "$(uname -s)" = "Darwin" ]; then
  headroom_version="0.26.0"
  headroom_service_revision="${headroom_version}-service-deps-1"
  headroom_package="headroom-ai[mcp,proxy]==${headroom_version}"
  headroom_pinned_deps=(
    "anyio==4.14.0"
    "click==8.4.1"
    "hpack==4.1.0"
    "litellm==1.89.3"
    "openai==2.43.0"
    "opentelemetry-api==1.42.1"
  )
  headroom_service_dir="$HOME/.local/share/headroom-launchd"
  headroom_venv="$headroom_service_dir/venv"
  headroom_bin="$headroom_venv/bin/headroom"

  if ! command -v uv >/dev/null 2>&1; then
    echo "Error: uv not found on PATH. Run with tools loaded, e.g.:" >&2
    echo "  MISE_CONFIG_FILE=\"\$HOME/.config/mise/config.default.toml\" mise install && mise run bootstrap" >&2
    exit 1
  fi

  mkdir -p "$HOME/.headroom/logs" "$headroom_service_dir"

  marker="$headroom_venv/.headroom-version"
  current_version=""
  if [ -f "$marker" ]; then
    current_version="$(cat "$marker")"
  fi

  if [ ! -x "$headroom_bin" ] || [ "$current_version" != "$headroom_service_revision" ]; then
    echo "Setting up headroom venv ($headroom_service_revision)..."
    if [ ! -x "$headroom_venv/bin/python" ]; then
      uv venv --seed "$headroom_venv"
    fi
    uv pip install --python "$headroom_venv/bin/python" "$headroom_package" "${headroom_pinned_deps[@]}"
    printf '%s\n' "$headroom_service_revision" >"$marker"
  else
    echo "headroom venv is up to date ($headroom_service_revision)"
  fi
fi
