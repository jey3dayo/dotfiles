if ! command -v gh >/dev/null 2>&1; then
  return
fi

# Use zsh-defer if available, otherwise run immediately if compdef exists
if (( $+functions[zsh-defer] )); then
  zsh-defer eval "$(gh completion -s zsh)"
elif (( $+functions[compdef] )); then
  eval "$(gh completion -s zsh)"
else
  # Queue for later execution after compinit
  typeset -g -a _post_compinit_hooks
  _post_compinit_hooks+=("eval \"\$(gh completion -s zsh)\"")
fi
