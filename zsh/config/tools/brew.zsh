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

# Defer brew shellenv for faster startup
# Modified to preserve mise PATH priority
if (( $+functions[zsh-defer] )); then
  zsh-defer eval "$(
    eval \"\$($BREW_PATH/brew shellenv)\"
    # Remove mise-managed tools from Homebrew PATH
    PATH=\$(echo \$PATH | tr ':' '\n' | grep -v '/opt/homebrew/bin' | tr '\n' ':' | sed 's/:$//')
    PATH=\"\$PATH:/opt/homebrew/bin\"
    export PATH
  )"
else
  eval "$($BREW_PATH/brew shellenv)"
  # Remove mise-managed tools from Homebrew PATH
  PATH=$(echo $PATH | tr ':' '\n' | grep -v '/opt/homebrew/bin' | tr '\n' ':' | sed 's/:$//')
  PATH="$PATH:/opt/homebrew/bin"
  export PATH
fi

if [ -f $BREW_PATH/etc/brew-wrap ]; then
  source $BREW_PATH/etc/brew-wrap
fi
