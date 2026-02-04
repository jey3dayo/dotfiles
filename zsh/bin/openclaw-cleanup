#!/usr/bin/env bash
set -euo pipefail

logdir="${XDG_CACHE_HOME:-$HOME/.cache}/openclaw"
mkdir -p "$logdir"
log="$logdir/cleanup.log"

{
  echo "=== openclaw-cleanup $(date -Is) ==="
  echo "host=$(hostname) user=$USER"
  echo "--- df (before) ---"
  df -h /

  echo "--- mise prune ---"
  if command -v mise >/dev/null 2>&1; then
    mise prune -y || true
  else
    echo "mise: not found"
  fi

  echo "--- pnpm store prune ---"
  if command -v pnpm >/dev/null 2>&1; then
    pnpm store prune || true
  else
    echo "pnpm: not found"
  fi

  echo "--- npm cache clean ---"
  if command -v npm >/dev/null 2>&1; then
    npm cache clean --force || true
  else
    echo "npm: not found"
  fi

  echo "--- df (after) ---"
  df -h /
  echo
} >>"$log" 2>&1
