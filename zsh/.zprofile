export LANG='ja_JP.UTF-8'
export LC_ALL='ja_JP.UTF-8'

export BROWSER='open'
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'

export LISTMAX=0

typeset -U path cdpath fpath manpath

# Activate mise (env vars configured in .zshenv)
# See: config/tools/mise.zsh (_mise_activate helper)
if [[ -f "${ZDOTDIR}/config/tools/mise.zsh" ]]; then
  source "${ZDOTDIR}/config/tools/mise.zsh"
  _mise_activate
fi

# Load cargo environment for login shells.
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Complete PATH setup (executed after macOS path_helper)
# macOS /etc/zprofile runs path_helper which reorders PATH
# This ensures our desired priority: user paths > system > Homebrew
# Note: mise shims are managed automatically by 'mise activate' above
path=(
  # User binaries
  $HOME/{bin,sbin}(N-)
  $HOME/.local/{bin,sbin}(N-)
  $XDG_CONFIG_HOME/scripts(N-)
  $HOME/.claude/{bin,local}(N-)

  # Language-specific tools
  $HOME/.deno/bin(N-)
  $HOME/.cargo/bin(N-)
  /usr/local/opt/openjdk/bin(N-)
  /usr/local/opt/coreutils/libexec/gnubin(N-)
  $BUN_INSTALL/bin(N-)
  $HOME/go/bin(N-)
  $PNPM_HOME(N-)
  $HOME/.local/npm-global/bin(N-)

  # Android SDK
  $ANDROID_SDK_ROOT/emulator(N-)
  $ANDROID_SDK_ROOT/tools(N-)
  $ANDROID_SDK_ROOT/tools/bin(N-)
  $ANDROID_SDK_ROOT/platform-tools(N-)

  # Homebrew (before system for latest tools)
  /opt/homebrew/bin(N-)
  /opt/homebrew/sbin(N-)
  /usr/local/bin(N-)
  /usr/local/sbin(N-)

  # System paths (lowest priority, fallback)
  $path
)

# vim: set syntax=zsh:
