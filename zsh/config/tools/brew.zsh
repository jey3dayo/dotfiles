command -v brew &>/dev/null || return

if [[ "$(arch)" == arm64 ]]; then
  BREW_PATH=/opt/homebrew/bin
  ARCH=arm64e
  [[ -x $BREW_PATH/brew ]] && alias brew="arch -arch arm64e /opt/homebrew/bin/brew"
else
  BREW_PATH=/usr/local/bin
  ARCH=x86_64
fi

[[ -x $BREW_PATH/brew ]] && alias brew="arch -arch $ARCH $BREW_PATH/brew"

# Ultra-deferred brew initialization for maximum startup speed
if (( $+functions[zsh-defer] )); then
  # Set minimal env vars immediately, defer full shellenv
  export HOMEBREW_PREFIX="$([[ "$(arch)" == arm64 ]] && echo /opt/homebrew || echo /usr/local)"
  export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
  export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX"
  
  # Defer expensive operations
  zsh-defer -t 5 eval "$($BREW_PATH/brew shellenv)"
else
  # Fallback for immediate loading
  eval "$($BREW_PATH/brew shellenv)"
fi

if [ -f $BREW_PATH/etc/brew-wrap ]; then
  source $BREW_PATH/etc/brew-wrap
fi
