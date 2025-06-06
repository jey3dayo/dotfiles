export MISE_DATA_DIR=$HOME/.mise
export MISE_CACHE_DIR=$MISE_DATA_DIR/cache

# Ultra-deferred mise loading - only activate when needed
if (( $+functions[zsh-defer] )); then
  # Defer mise activation and hook-env with high timeout to reduce startup impact
  zsh-defer -t 3 eval "$(mise activate zsh)"
  zsh-defer -t 5 eval "$(mise hook-env -s zsh)"
  # Defer completion loading even more
  zsh-defer -t 10 eval "$(mise complete -s zsh)"
else
  eval "$(mise activate zsh)"
  eval "$(mise hook-env -s zsh)"
fi

### Do not edit. This was autogenerated by 'mise direnv' ###
use_mise() {
  direnv_load mise direnv exec
}
