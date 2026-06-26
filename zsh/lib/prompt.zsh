if [[ -z "${ZSH_DISABLE_STARSHIP:-}" ]] && command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
else
  PROMPT='%n@%m:%~%# '
fi

# vim: set syntax=zsh:
