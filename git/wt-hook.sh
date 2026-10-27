#!/bin/sh
# git-wt の wt.hook から呼ばれる。新しい worktree で mise と依存のセットアップを済ませる。
# 失敗しても worktree の作成は止めない（最後に exit 0）。

# worktree はパスが変わるので、mise の trust を毎回やり直す
if [ -f mise.toml ] || [ -f .mise.toml ]; then
  mise trust --yes && mise install
fi

# lockfile が無いと ni が対話プロンプトで止まるので、あるときだけ入れる
has_lockfile=
for f in pnpm-lock.yaml yarn.lock package-lock.json bun.lock bun.lockb; do
  [ -f "$f" ] && has_lockfile=1
done
if [ -n "$has_lockfile" ]; then
  if mise exec -- sh -c 'command -v ni' >/dev/null 2>&1; then
    mise exec -- ni --frozen
  elif [ -f pnpm-lock.yaml ]; then
    mise exec -- pnpm install --frozen-lockfile
  fi
fi

exit 0
