# XDG base directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"

if [[ "$SHLVL" -eq 1 && -s "${ZDOTDIR}/.zshenv.local" ]]; then
  source "${ZDOTDIR}/.zshenv.local"
fi

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
export GOPATH=$HOME
export BUN_INSTALL="$HOME/.bun"
export HOMEBREW_BUNDLE_FILE_GLOBAL="$XDG_CONFIG_HOME/Brewfile"
# export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
# export SSH_AUTH_SOCK=~/.1password/agent.sock

path=(
  # railsビルド用
  # /opt/homebrew/opt/mysql@5.7/bin(N-/)
  $HOME/.local/{bin,sbin}(N-/)
  /usr/local/{bin,sbin}(N-/)
  $HOME/.deno/bin(N-/)
  $HOME/.cargo/bin(N-/)
  /usr/local/opt/openjdk/bin:(N-/)
  /usr/local/opt/coreutils/libexec/gnubin(N-/)
  $GOPATH/bin(N-/)
  $BUN_INSTALL/bin(N-/)
  $ANDROID_SDK_ROOT/emulator(N-/)
  $ANDROID_SDK_ROOT/tools(N-/)
  $ANDROID_SDK_ROOT/tools/bin(N-/)
  $ANDROID_SDK_ROOT/platform-tools(N-/)
  $path
)

alias awsume="source \$(pyenv which awsume)"
fpath=(
  ~/.awsume/zsh-autocomplete/
  ~/.local/share/zsh-autocomplete/
  $fpath)

# vim: set syntax=zsh:
