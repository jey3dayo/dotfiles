if  [[ "$(arch)" == arm64 ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  path=(/opt/homebrew/bin(N-/) $path)
  [[ -x /usr/local/bin/brew ]] && alias brew="arch -arch arm64e /opt/homebrew/bin/brew"

  export ASDF_DATA_DIR=~/.asdf
  . /opt/homebrew/opt/asdf/libexec/asdf.sh
  . ~/.asdf/plugins/java/set-java-home.zsh

  # source "${XDG_CONFIG_HOME:-$HOME/.config}/asdf-direnv/zshrc"
  export ASDF_DIRENV_BIN="/Users/t00114/.asdf/installs/direnv/2.32.1/bin/direnv"
  eval "$($ASDF_DIRENV_BIN hook zsh)"
else
  eval "$(/usr/local/bin/brew shellenv)"
  path=(/usr/local/bin/(N-/) $path)
  [[ -x /usr/local/bin/brew ]] && alias brew="arch -arch x86_64 /usr/local/bin/brew"

  export ASDF_DATA_DIR=~/.asdf_x86
  . /usr/local/opt/asdf/libexec/asdf.sh
  . ~/.asdf_x86/plugins/java/set-java-home.zsh

  # source "${XDG_CONFIG_HOME:-$HOME/.config}/asdf-direnv/zshrc"
  export ASDF_DIRENV_BIN="/Users/t00114/.asdf_x86/installs/direnv/2.32.1/bin/direnv"
  eval "$($ASDF_DIRENV_BIN hook zsh)"
fi
