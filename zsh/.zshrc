# jey3dayo .zshrc
: "${XDG_STATE_HOME:=${HOME}/.local/state}"

# Load shared constants before init (used by completion, etc.)
if [[ -r "${ZDOTDIR:-$HOME}/config/core/constants.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/config/core/constants.zsh"
fi
# Source initialization files first (order-dependent)
for f in "${ZDOTDIR:-$HOME}"/init/*.zsh(N); do
  [[ -r "$f" ]] && source "${f}"
done

# Main configuration loader (before styles to match original glob order)
[[ -r "${ZDOTDIR:-$HOME}/config/loader.zsh" ]] && source "${ZDOTDIR:-$HOME}/config/loader.zsh"

# Completion styles (after loader so styles.zsh overrides fzf-tab defaults)
[[ -r "${ZDOTDIR:-$HOME}/sources/styles.zsh" ]] && source "${ZDOTDIR:-$HOME}/sources/styles.zsh"

# Some deferred or system startup paths can be prepended after mise activation.
(( $+functions[_mise_promote_paths] )) && _mise_promote_paths

# vim: set syntax=zsh:
