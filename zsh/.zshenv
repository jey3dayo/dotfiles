# XDG base directories
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
export XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME

: "${ZDOTDIR:=${XDG_CONFIG_HOME}/zsh}"
: "${GIT_CONFIG_GLOBAL:=$XDG_CONFIG_HOME/git/config}"
export ZDOTDIR GIT_CONFIG_GLOBAL

# Temporary Files
if [[ ! -d "$TMPDIR" ]]; then
  export TMPDIR="/tmp/$LOGNAME"
  mkdir -p -m 700 "$TMPDIR"
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
export CODEX_CONFIG="$HOME/.config/codex/config.yaml"

# Minimal PATH setup for non-login shells
# Full PATH configuration is in .zprofile (executed after macOS path_helper)
# Only critical paths that must be available in all zsh contexts
path=(
  $HOME/.mise/shims(N-)
  $path
)

fpath=(
  ~/.awsume/zsh-autocomplete/
  ~/.local/share/zsh-autocomplete/
  $fpath)

# vim: set syntax=zsh:
