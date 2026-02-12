# sheldon plugin manager bootstrap
# plugins (including zsh-defer) must load before config loader

cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}
config_dir=${XDG_CONFIG_HOME:-$HOME/.config}

export SHELDON_CONFIG_DIR="$ZDOTDIR/sheldon"
sheldon_cache="$cache_dir/sheldon/sheldon.zsh"
sheldon_toml="$SHELDON_CONFIG_DIR/plugins.toml"

# キャッシュがない、またはキャッシュが古い場合にキャッシュを作成
if command -v sheldon > /dev/null 2>&1; then
  if [[ ! -r "$sheldon_cache" || "$sheldon_toml" -nt "$sheldon_cache" ]]; then
    mkdir -p "$cache_dir/sheldon"
    sheldon source > $sheldon_cache
  fi
  source "$sheldon_cache"
fi

unset cache_dir sheldon_cache sheldon_toml
