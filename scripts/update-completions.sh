#!/usr/bin/env bash

# 生成可能な zsh 補完を再生成する。
# ツール本体を mise 経由で更新すると補完スクリプトの実装が変わることがあり、
# リポジトリに固定したコピーは黙って壊れる（例: 出力形式が変わり候補が出なくなる）。
# _ghq / _git-gtr / _ssh_hosts は生成元がないため対象外。

set -euo pipefail

dest_dir="zsh/completions"

# 生成に失敗したときに既存の補完を空ファイルで潰さないよう、成功した場合のみ差し替える
regenerate() {
  local name="$1"
  shift

  if ! command -v "$1" >/dev/null 2>&1; then
    echo "⏭️  ${name}: $1 not installed, skipping"
    return 0
  fi

  local tmp
  tmp="$(mktemp)"
  if "$@" >"$tmp" 2>/dev/null && [ -s "$tmp" ]; then
    mv "$tmp" "${dest_dir}/${name}"
    echo "✓ ${name}"
  else
    rm -f "$tmp"
    echo "⚠️  ${name}: generation failed, keeping existing file" >&2
  fi
}

regenerate _mise mise completion zsh
regenerate _sheldon sheldon completions --shell zsh
regenerate _task task --completion zsh

echo ""
echo "✅ Completions regenerated. Run 'exec zsh' to reload."
