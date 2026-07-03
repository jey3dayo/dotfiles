aicommits() {
  emulate -L zsh
  local wrapper="${XDG_CONFIG_HOME:-$HOME/.config}/scripts/aicommits-with-env"

  # aicommits 3.4.0 does not pass environment config through reliably.
  if [[ ! -x "$wrapper" ]]; then
    command aicommits "$@"
    return $?
  fi

  "$wrapper" "$@"
}

aic() {
  emulate -L zsh
  aicommits "$@"
}

# vim: set syntax=zsh:
