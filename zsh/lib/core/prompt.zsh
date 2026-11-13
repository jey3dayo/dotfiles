starship_init="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/starship/init.zsh"

if [[ -z "${ZSH_DISABLE_STARSHIP:-}" && -r "$starship_init" ]]; then
  () { source "$1" } "$starship_init"
else
  PROMPT='%n@%m:%~%# '
fi

unset starship_init

# vim: set syntax=zsh:
