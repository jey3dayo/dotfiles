export MISE_DATA_DIR=$HOME/.mise
export MISE_CACHE_DIR=$MISE_DATA_DIR/cache

if ! command -v mise >/dev/null 2>&1; then
  return
fi

# Immediate mise loading for env vars
eval "$(mise activate zsh)"
eval "$(mise hook-env -s zsh)"

# Defer completion loading to save startup time
if (( $+functions[zsh-defer] )); then
  zsh-defer -t 2 eval "$(mise complete -s zsh)"
else
  eval "$(mise complete -s zsh)"
fi

### Do not edit. This was autogenerated by 'mise direnv' ###
use_mise() {
  direnv_load mise direnv exec
}
