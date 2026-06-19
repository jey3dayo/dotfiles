# sheldon plugin manager bootstrap
# plugins (including zsh-defer) must load before config loader

_refresh_sheldon_cache() {
  local cache="$1"
  local tmp="${cache}.$$"

  mkdir -p "${cache:h}" || return 0
  sheldon source >| "$tmp" 2> /dev/null && mv -f "$tmp" "$cache"
  rm -f "$tmp" 2> /dev/null || true
}

_load_sheldon_plugins() {
  local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}"
  local sheldon_cache="$cache_dir/sheldon/sheldon.zsh"
  local sheldon_toml="$SHELDON_CONFIG_DIR/plugins.toml"

  command -v sheldon > /dev/null 2>&1 || return 0

  if [[ -r "$sheldon_cache" ]]; then
    source "$sheldon_cache"
    if [[ "$sheldon_toml" -nt "$sheldon_cache" ]]; then
      _refresh_sheldon_cache "$sheldon_cache" &!
    fi
  else
    _refresh_sheldon_cache "$sheldon_cache"
    [[ -r "$sheldon_cache" ]] && source "$sheldon_cache"
  fi
}

export SHELDON_CONFIG_DIR="$ZDOTDIR/sheldon"
_load_sheldon_plugins

unfunction _refresh_sheldon_cache _load_sheldon_plugins 2> /dev/null || true
