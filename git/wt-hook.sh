#!/bin/sh
# git-wt の wt.hook。新しい worktree で mise と依存を入れる（失敗しても作成は止めない）

# mise install / exec は読んだ config を暗黙に trust するので、未信頼の config があれば何もしない
# （trust は worktree 間で共有され、trusted_config_paths でもカバーされる）
# 判定できないときも止める（fail-closed）
if ! trust_status=$(mise trust --show); then
  echo "wt-hook: mise trust --show に失敗したのでセットアップをスキップ" >&2
  exit 0
fi
if printf '%s\n' "$trust_status" | grep -q ': untrusted$'; then
  exit 0
fi

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
