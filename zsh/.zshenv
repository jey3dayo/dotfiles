# XDG base directories
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
export XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME

: "${ZDOTDIR:=${XDG_CONFIG_HOME}/zsh}"
: "${GIT_CONFIG_GLOBAL:=$XDG_CONFIG_HOME/git/config}"
export ZDOTDIR GIT_CONFIG_GLOBAL

# mise data/cache directories (must be set before .zprofile activation)
: "${MISE_DATA_DIR:=$HOME/.mise}"
: "${MISE_CACHE_DIR:=$MISE_DATA_DIR/cache}"
export MISE_DATA_DIR MISE_CACHE_DIR

# mise config file selection based on environment (must be before mise activate)
if [[ -f "${XDG_CONFIG_HOME}/scripts/setup-mise-env.sh" ]]; then
  source "${XDG_CONFIG_HOME}/scripts/setup-mise-env.sh"
fi

# History file should be set before shell init so history loads
# even if .zshrc is skipped. Keep it under XDG state by default.
: "${HISTFILE:=${XDG_STATE_HOME}/zsh/history}"
export HISTFILE

# History size must be set in .zshenv (not .zshrc) because tools like Claude Code
# use 'zsh -c' which skips .zshrc, resulting in Zsh's defaults (HISTSIZE=30, SAVEHIST=0).
# .zshenv is always sourced, ensuring proper history configuration in all contexts.
HISTSIZE=100000
SAVEHIST=100000
export HISTSIZE SAVEHIST

# Temporary Files
if [[ ! -d "$TMPDIR" ]]; then
  export TMPDIR="/tmp/$LOGNAME"
  mkdir -p "$TMPDIR"
  chmod 700 "$TMPDIR"
fi

TMPPREFIX="${TMPDIR%/}/zsh"

export GHQ_ROOT=~/src
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/.ripgreprc"
export STUDIO_JDK=${JAVA_HOME%/*/*}
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export JAVA_OPTS="-Djava.net.useSystemProxies=true"
export CATALINA_HOME=/opt/homebrew/Cellar/tomcat/10.1.19/libexec/
export ANT_OPTS=-Dbuild.sysclasspath=ignore
export BUN_INSTALL="$HOME/.bun"
export HOMEBREW_BUNDLE_FILE_GLOBAL="$XDG_CONFIG_HOME/Brewfile"
export PNPM_HOME="$HOME/.local/share/pnpm"
export NI_CONFIG_FILE="$HOME/.config/nirc"

# PATH configuration is in .zprofile (executed after macOS path_helper)
# mise shims are managed automatically by 'mise activate' in .zprofile

fpath=(
  ~/.awsume/zsh-autocomplete/
  ~/.local/share/zsh-autocomplete/
  "${fpath[@]}")

# vim: set syntax=zsh:
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
