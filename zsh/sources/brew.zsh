if (( $+commands[sw_vers] )) && (( $+commands[arch] )); then
  [[ -x /usr/local/bin/brew ]] && alias brew="arch -arch x86_64 /usr/local/bin/brew"
  alias x64='exec arch -x86_64 /bin/zsh'
  alias a64='exec arch -arm64e /bin/zsh'
  switch-arch() {
    if  [[ "$(uname -m)" == arm64 ]]; then
      arch=x86_64
    elif [[ "$(uname -m)" == x86_64 ]]; then
      arch=arm64e
    fi
    exec arch -arch $arch /bin/zsh
  }
fi

if [ "$(uname -m)" = "arm64" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  path=(/opt/homebrew/bin(N-/) $path)
  . /opt/homebrew/opt/asdf/libexec/asdf.sh
else
  eval "$(/usr/local/bin/brew shellenv)"
  export ASDF_DATA_DIR=~/.asdf_x86
  . /usr/local/opt/asdf/libexec/asdf.sh
fi
