# Starship prompt initialization with deferred loading
if ! command -v starship >/dev/null 2>&1; then
  return
fi

if (( $+functions[zsh-defer] )); then
  zsh-defer eval "$(starship init zsh)"
else
  eval "$(starship init zsh)"
fi
