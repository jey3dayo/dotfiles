# sheldon plugin manager bootstrap
# plugins (including zsh-defer) must load before config loader

cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}
config_dir=${XDG_CONFIG_HOME:-$HOME/.config}

export SHELDON_CONFIG_DIR="$ZDOTDIR/sheldon"
sheldon_cache="$cache_dir/sheldon/sheldon.zsh"
sheldon_toml="$SHELDON_CONFIG_DIR/plugins.toml"

_refresh_sheldon_cache() {
  local cache="$1"
  local tmp="${cache}.$$"

  mkdir -p "${cache:h}" || return 0
  sheldon source >| "$tmp" 2> /dev/null && mv -f "$tmp" "$cache"
  rm -f "$tmp" 2> /dev/null || true
}

if command -v sheldon > /dev/null 2>&1; then
  if [[ -r "$sheldon_cache" ]]; then
    source "$sheldon_cache"
    if [[ "$sheldon_toml" -nt "$sheldon_cache" ]]; then
      _refresh_sheldon_cache "$sheldon_cache" &!
    fi
  else
    _refresh_sheldon_cache "$sheldon_cache" &!
  fi
fi

unfunction _refresh_sheldon_cache 2> /dev/null || true
unset cache_dir config_dir sheldon_cache sheldon_toml
