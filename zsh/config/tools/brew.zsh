command -v brew &>/dev/null || return

typeset -gr BREW_ENV_DEFER_SECONDS=3

# Custom brew environment setup that preserves mise tool priority
# Note: brew unlink node was executed to avoid conflicts with mise-managed node
_setup_brew_env() {
  local brew_output="$($BREW_PATH/brew shellenv)"
  # Apply all brew environment variables except PATH modifications
  # PATH is already configured in config/core/path.zsh
  eval "$(echo "$brew_output" | grep -v '^export PATH=')"
}

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

  # Defer expensive operations but preserve mise priority
  zsh-defer -t $BREW_ENV_DEFER_SECONDS _setup_brew_env
else
  # Fallback for immediate loading
  _setup_brew_env
fi

if [ -f $BREW_PATH/etc/brew-wrap ]; then
  source $BREW_PATH/etc/brew-wrap
fi
