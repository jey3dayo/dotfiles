# jey3dayo .zshrc
: "${XDG_STATE_HOME:=${HOME}/.local/state}"

# Load shared constants before init (used by completion, etc.)
if [[ -r "${ZDOTDIR:-$HOME}/config/core/constants.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/config/core/constants.zsh"
fi

_prepare_zsh_interactive_path() {
  local file="${ZDOTDIR:-$HOME}/config/core/interactive-path.zsh"
  [[ -r "$file" ]] || return

  source "$file"
  (($+functions[_dotfiles_setup_interactive_path])) && _dotfiles_setup_interactive_path
}

_source_zsh_init() {
  local file="${ZDOTDIR:-$HOME}/init/$1"
  [[ -r "$file" ]] && source "$file"
}

# Source order-sensitive initialization files explicitly.
_prepare_zsh_interactive_path
_source_zsh_init options.zsh
_source_zsh_init zz-completion.zsh
_source_zsh_init sheldon.zsh
_source_zsh_init history.zsh

# Load any local init extension not listed above.
for f in "${ZDOTDIR:-$HOME}"/init/*.zsh(N); do
  case "${f:t}" in
    options.zsh | zz-completion.zsh | sheldon.zsh | history.zsh) continue ;;
  esac
  [[ -r "$f" ]] && source "$f"
done
unfunction _prepare_zsh_interactive_path _source_zsh_init _dotfiles_setup_interactive_path 2>/dev/null

# Main configuration loader (before styles to match original glob order)
[[ -r "${ZDOTDIR:-$HOME}/config/loader.zsh" ]] && source "${ZDOTDIR:-$HOME}/config/loader.zsh"

# Completion styles (after loader so styles.zsh overrides fzf-tab defaults)
[[ -r "${ZDOTDIR:-$HOME}/sources/styles.zsh" ]] && source "${ZDOTDIR:-$HOME}/sources/styles.zsh"

# Some deferred or system startup paths can be prepended after mise activation.
(($+functions[_mise_promote_paths])) && _mise_promote_paths

# vim: set syntax=zsh:
