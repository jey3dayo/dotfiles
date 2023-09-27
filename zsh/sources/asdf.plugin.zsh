# https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/asdf/asdf.plugin.zsh

# Find where asdf should be installed
[[ "$(arch)" == "arm64" ]] && ASDF_DIR="${ASDF_DIR:-$HOME/.asdf}" || ASDF_DIR="${ASDF_DIR:-$HOME/.asdf_x86}"
ASDF_COMPLETIONS="$ASDF_DIR/completions"

# If not found, check for archlinux/AUR package (/opt/asdf-vm/)
if [[ ! -f "$ASDF_DIR/asdf.sh" || ! -f "$ASDF_COMPLETIONS/asdf.bash" ]] && [[ -f "/opt/asdf-vm/asdf.sh" ]]; then
  ASDF_DIR="/opt/asdf-vm"
  ASDF_COMPLETIONS="$ASDF_DIR"
fi

# If not found, check for Homebrew package
if [[ ! -f "$ASDF_DIR/asdf.sh" || ! -f "$ASDF_COMPLETIONS/asdf.bash" ]] && (( $+commands[brew] )); then
  brew_prefix="$(brew --prefix asdf)"
  ASDF_DIR="${brew_prefix}/libexec"
  ASDF_COMPLETIONS="${brew_prefix}/etc/bash_completion.d"
  unset brew_prefix
fi

# Load command
if [[ -f "$ASDF_DIR/asdf.sh" ]]; then
  . "$ASDF_DIR/asdf.sh"

  # Load completions
  # if [[ -f "$ASDF_COMPLETIONS/asdf.bash" ]]; then
  #   . "$ASDF_COMPLETIONS/asdf.bash"
  # fi


  export ASDF_DIRENV_BIN="$ASDF_DIR/installs/direnv/2.32.3/bin/direnv"
  if [[ -f "$ASDF_DIRENV_BIN" ]]; then
    eval "$($ASDF_DIRENV_BIN hook zsh)"
    # . $ASDF_DIR/plugins/java/set-java-home.zsh
  fi
fi
