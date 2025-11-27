# sheldon plugin manager bootstrap
# plugins (including zsh-defer) must load before config loader

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

  # Custom completions directory (after sheldon loads)
  fpath=(~/.config/zsh/completions $fpath)

  # Rebuild completion cache to include custom completions
  zcompdump="${ZSH_COMPDUMP:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump}"

  # Force rebuild if any custom completion is newer than cache
  needs_rebuild=0
  for comp_file in ~/.config/zsh/completions/*(N); do
    if [[ ! -f "$zcompdump" || "$comp_file" -nt "$zcompdump" ]]; then
      needs_rebuild=1
      break
    fi
  done

  autoload -Uz compinit
  if (( needs_rebuild )); then
    compinit -d "$zcompdump"
  else
    compinit -C -d "$zcompdump"
  fi
  unset needs_rebuild
  unset zcompdump

  # Re-prioritize mise shims after sheldon plugins may have modified PATH
  path=($HOME/.mise/shims(N-) ${path:#$HOME/.mise/shims})
fi

unset cache_dir sheldon_cache sheldon_toml
