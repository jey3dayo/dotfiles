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

eval "$($BREW_PATH/brew shellenv)"

if [ -f $BREW_PATH/etc/brew-wrap ]; then
  source $BREW_PATH/etc/brew-wrap
fi
