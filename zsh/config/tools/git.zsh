# Git configuration and custom functions

# Git diff widget function
git_diff() {
  if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = 'true' ]; then
    echo git diff
    git diff
  fi
  zle reset-prompt
}
zle -N git_diff git_diff
bindkey '^gg' git_diff
bindkey '^g^g' git_diff