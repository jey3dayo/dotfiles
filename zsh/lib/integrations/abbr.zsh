export SHELDON_CONFIG_DIR="${ZDOTDIR:-$HOME/.config/zsh}/sheldon"
export SHELDON_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/sheldon"

_zsh_load_abbr() {
  emulate -L zsh
  [[ -n "${ZSH_ABBR_LOADED:-}" ]] && return 0
  ZSH_ABBR_LOADED=1

  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/sheldon/zsh-minimal.zsh"
  [[ -r "$cache" ]] && () { source "$1" } "$cache"
}

if [[ -n "${ZSH_LOAD_PLUGINS:-}" ]]; then
  _zsh_load_abbr
elif [[ -o interactive ]]; then
  autoload -Uz add-zsh-hook

  _zsh_load_abbr_once() {
    add-zsh-hook -d precmd _zsh_load_abbr_once 2>/dev/null
    _zsh_load_abbr
  }

  add-zsh-hook precmd _zsh_load_abbr_once
fi

# vim: set syntax=zsh:
