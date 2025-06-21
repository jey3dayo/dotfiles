cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}
config_dir=${XDG_CONFIG_HOME:-$HOME/.config}

export SHELDON_CONFIG_DIR="$ZDOTDIR/sheldon"
sheldon_cache="$SHELDON_CONFIG_DIR/sheldon.zsh"
sheldon_toml="$SHELDON_CONFIG_DIR/plugins.toml"

# キャッシュがない、またはキャッシュが古い場合にキャッシュを作成
if [[ ! -r "$sheldon_cache" || "$sheldon_toml" -nt "$sheldon_cache" ]]; then
  mkdir -p $cache_dir
  sheldon source >$sheldon_cache
fi
source "$sheldon_cache"

unset cache_dir sheldon_cache sheldon_toml
