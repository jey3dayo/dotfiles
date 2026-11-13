# In a linked Git worktree, pass the resolved gitdir via --add-dir so the
# workspace-write sandbox can create index.lock. Does not wrap or override
# `codex`. For non-interactive `codex exec` runs, use `codexw exec ... < /dev/null`
# to avoid stdin waits.
codexw() {
  emulate -L zsh
  local git_dir common_dir
  if git_dir="$(git rev-parse --path-format=absolute --git-dir 2>/dev/null)" \
    && common_dir="$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" \
    && [[ -n "$git_dir" && "$git_dir" != "$common_dir" ]]; then
    codex --add-dir "$git_dir" "$@"
  else
    codex "$@"
  fi
}

# vim: set syntax=zsh:
