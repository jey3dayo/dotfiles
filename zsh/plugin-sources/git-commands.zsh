function git_diff() {
  if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = 'true' ]; then
    echo git diff
    git diff
  fi
  zle reset-prompt
}
zle -N git_diff git_diff
bindkey '^gg' git_diff
