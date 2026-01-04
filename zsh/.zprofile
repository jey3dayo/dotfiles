export LANG='ja_JP.UTF-8'
export LC_ALL='ja_JP.UTF-8'

export BROWSER='open'
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'

export LISTMAX=0
export GREP_OPTIONS='--color=auto'

typeset -U path cdpath fpath manpath

# Activate mise if available
# Check Homebrew location first (before PATH is fully populated)
if [[ -x /opt/homebrew/bin/mise ]]; then
  eval "$(/opt/homebrew/bin/mise activate zsh)"
elif command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

# Complete PATH setup (executed after macOS path_helper)
# macOS /etc/zprofile runs path_helper which reorders PATH
# This ensures our desired priority: user paths > system > Homebrew
# Note: mise shims are managed automatically by 'mise activate' above
path=(
  # User binaries
  $HOME/{bin,sbin}(N-)
  $HOME/.local/{bin,sbin}(N-)
  $HOME/.claude/bin(N-)

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
