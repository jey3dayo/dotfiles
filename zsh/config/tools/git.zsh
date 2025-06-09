# Git configuration and custom functions

# Helper function to check if in git repository
_is_git_repo() {
  [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = 'true' ]
}

# Git diff widget function
git_diff() {
  if _is_git_repo; then
    echo git diff
    git diff
  fi
  zle reset-prompt
}
zle -N git_diff git_diff
bindkey '^gg' git_diff
bindkey '^g^g' git_diff

# Git status widget function
git_status() {
  if _is_git_repo; then
    echo git status
    git status -sb
  fi
  zle reset-prompt
}
zle -N git_status git_status
bindkey '^gs' git_status
bindkey '^g^s' git_status

# Git add widget function
git_add_interactive() {
  if _is_git_repo; then
    echo git add -p
    git add -p
  fi
  zle reset-prompt
}
zle -N git_add_interactive git_add_interactive
bindkey '^ga' git_add_interactive
bindkey '^g^a' git_add_interactive

# Git branch selection widget (using fzf if available)
git_branch_select() {
  if _is_git_repo && command -v fzf >/dev/null 2>&1; then
    local branch
    branch=$(git branch -a | grep -v HEAD | sed 's/^[* ] //' | sed 's/remotes\///' | sort -u | fzf --prompt="Select branch: ")
    if [[ -n "$branch" ]]; then
      LBUFFER="${LBUFFER}${branch}"
    fi
  fi
  zle reset-prompt
}
zle -N git_branch_select git_branch_select
bindkey '^gb' git_branch_select
bindkey '^g^b' git_branch_select
