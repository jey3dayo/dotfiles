return

if [[ -r "${ZDOTDIR:-$HOME}/.zinit.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zinit.zsh"
else
  autoload -Uz compinit
  compinit
fi
