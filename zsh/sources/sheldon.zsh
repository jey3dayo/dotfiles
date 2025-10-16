cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}
config_dir=${XDG_CONFIG_HOME:-$HOME/.config}

export SHELDON_CONFIG_DIR="$ZDOTDIR/sheldon"
sheldon_cache="$SHELDON_CONFIG_DIR/sheldon.zsh"
sheldon_toml="$SHELDON_CONFIG_DIR/plugins.toml"

# キャッシュがない、またはキャッシュが古い場合にキャッシュを作成
if command -v sheldon >/dev/null 2>&1; then
  if [[ ! -r "$sheldon_cache" || "$sheldon_toml" -nt "$sheldon_cache" ]]; then
    mkdir -p $cache_dir
    sheldon source >$sheldon_cache
  fi
  source "$sheldon_cache"

  # Re-prioritize mise shims after sheldon plugins may have modified PATH
  path=($HOME/.mise/shims(N-/) ${path:#$HOME/.mise/shims})
fi

unset cache_dir sheldon_cache sheldon_toml
