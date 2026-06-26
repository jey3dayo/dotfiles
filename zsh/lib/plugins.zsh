export SHELDON_CONFIG_DIR="${ZDOTDIR:-$HOME/.config/zsh}/sheldon"
export SHELDON_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/sheldon"

_dotfiles_sheldon_cache="${XDG_CACHE_HOME:-$HOME/.cache}/sheldon/zsh-minimal.zsh"

dotfiles_load_sheldon_plugins() {
  emulate -L zsh
  [[ -n "${DOTFILES_ZSH_PLUGINS_LOADED:-}" ]] && return 0
  DOTFILES_ZSH_PLUGINS_LOADED=1

  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/sheldon/zsh-minimal.zsh"
  [[ -r "$cache" ]] && source "$cache"
}

if [[ -n "${ZSH_LOAD_PLUGINS:-}" ]]; then
  dotfiles_load_sheldon_plugins
elif [[ -o interactive ]]; then
  autoload -Uz add-zle-hook-widget

  dotfiles_zle_line_init() {
    add-zle-hook-widget -d zle-line-init dotfiles_zle_line_init 2>/dev/null
    dotfiles_load_sheldon_plugins
  }

  add-zle-hook-widget zle-line-init dotfiles_zle_line_init
fi

unset _dotfiles_sheldon_cache

# vim: set syntax=zsh:
