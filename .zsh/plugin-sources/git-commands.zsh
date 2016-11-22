function _git_status() {
  if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = 'true' ]; then
    echo git status -sb
    git status -sb
  fi
  zle reset-prompt
}
zle -N git_status _git_status
bindkey '^G' git_status
