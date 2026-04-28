if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.sh" ]]; then
  source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.sh"
elif [[ -n "${ZDOTDIR:-}" && -r "${ZDOTDIR:h}/shell/env.sh" ]]; then
  source "${ZDOTDIR:h}/shell/env.sh"
fi

_mise_bootstrap_env() {
  _dotfiles_bootstrap_mise_env
}
