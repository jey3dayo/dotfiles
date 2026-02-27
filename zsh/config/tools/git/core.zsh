# Git core helper functions
# Dependencies: none (this file is loaded first)

# Helper function to check if in git repository
_is_git_repo() {
  [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = 'true' ]
}

# git-wt shell integration (enable automatic directory switching)
if command -v git-wt >/dev/null 2>&1; then
  eval "$(git wt --init zsh)"
fi

# Shared helpers for git widgets
_git_widget() {
  local action="$1"
  shift

  if ! _is_git_repo; then
    zle reset-prompt
    return 1
  fi

  "$action" "$@"
  local exit_status=$?
  zle reset-prompt
  return $exit_status
}

_register_git_widget() {
  local widget="$1"
  shift
  local -a keymaps=(emacs viins vicmd)
  local keymap key

  zle -N "$widget" "$widget"
  for key in "$@"; do
    for keymap in "${keymaps[@]}"; do
      bindkey -M "$keymap" "$key" "$widget"
    done
  done
}

# Ensure Ctrl-G is always a safe prefix key in all keymaps.
# Without this, vi keymaps may keep `list-expand`, which can trigger
# git completion internals outside completion context.
_set_ctrl_g_prefix() {
  local -a keymaps=(emacs viins vicmd)
  local keymap
  for keymap in "${keymaps[@]}"; do
    bindkey -M "$keymap" '^g' send-break
  done
}

_set_ctrl_g_prefix

# git-wt list helper (skip header if present)
_git_wt_list() {
  command git wt | awk 'NR==1 && $1=="PATH" && $2=="BRANCH" {next} {print}'
}

_git_wt_require() {
  command -v git-wt >/dev/null 2>&1 || {
    echo "git-wt not installed. Install with: mise install"
    return 1
  }
}

# Local branch list helper (excluding current branch if possible)
_git_branch_list() {
  local current_branch
  current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)

  if [[ -n "$current_branch" ]]; then
    git for-each-ref refs/heads --format='%(refname:short)' | grep -Fxv "$current_branch"
  else
    git for-each-ref refs/heads --format='%(refname:short)'
  fi
}

# Branch selector (prefers fzf-git)
_git_select_branch() {
  if command -v _fzf_git_branches >/dev/null 2>&1; then
    _fzf_git_branches | head -n "${ZSH_GIT_FZF_FALLBACK_LIMIT}"
  else
    git branch --format='%(refname:short)' | fzf --prompt="Switch to branch: " --height="${ZSH_GIT_FZF_HEIGHT}" --reverse --preview="git log --oneline --graph --color=always {}"
  fi
}

# vim: set syntax=zsh:
