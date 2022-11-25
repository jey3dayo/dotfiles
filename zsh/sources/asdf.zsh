export ASDF_DATA_DIR=~/.asdf_x86

if [ "$(uname -m)" = "arm64" ]; then
  . /opt/homebrew/opt/asdf/libexec/asdf.sh
  . ~/.asdf_x86/plugins/java/set-java-home.zsh
else
  export ASDF_DATA_DIR=~/.asdf_x86
  . /usr/local/opt/asdf/libexec/asdf.sh
  . ~/.asdf_x86/plugins/java/set-java-home.zsh
fi

source "${XDG_CONFIG_HOME:-$HOME/.config}/asdf-direnv/zshrc"

