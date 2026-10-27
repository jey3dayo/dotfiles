#!/bin/sh
# git-wt の wt.hook。新しい worktree で mise と依存を入れる（失敗しても作成は止めない）

# trust は worktree 間で共有され、trusted_config_paths でもカバーされる
if [ -f mise.toml ] || [ -f .mise.toml ]; then
  mise install
fi

# lockfile が無いと ni が対話で止まる
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
