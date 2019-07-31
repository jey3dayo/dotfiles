export LANG='ja_JP.UTF-8'
export LC_ALL='ja_JP.UTF-8'

export BROWSER='open'
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'

export LISTMAX=0
export GREP_OPTIONS='--color=auto'

typeset -gU cdpath fpath mailpath path

path=(
  /usr/local/opt/coreutils/libexec/gnubin(N-/)
  $HOME/{bin,sbin}(N-/)
  $HOME/.local/{bin,sbin}(N-/)
  /usr/local/{bin,sbin}(N-/)
  $path
)

# alias
alias vim="nvim"
alias vi="nvim"
alias less="less -giMRSW -z-4 -x4"
alias where="command -v"
alias df="df -h"
alias du="du -h"
alias l='ls -lAFhp'
alias ll='ls -lAFhp'
alias ls='ls -pF'
alias hg="hg --encoding=utf-8"
alias gst="git status -sb"
alias tailf="tail -f"

# gnu
alias sed="gsed"
alias grep="ggrep"

if command -v colordiff>/dev/null; then
  alias diff="colordiff"
fi

# direnv
if command -v direnv>/dev/null; then
  eval "$(direnv hook zsh)"
fi

# peco
if command -v peco>/dev/null; then
  alias s='ssh $(grep -iE "^host[[:space:]]+[^*]" ~/.ssh/config|grep -v \*|peco|awk "{print \$2}")'
fi

alias npm-clean='npm run ncu && rm -rf node_modules && yarn && npm prune'
alias pip-upgrade='pip list --format json --outdated | jq .[].name | xargs pip install -U'
alias yarn-upgrade='yarn global upgrade'
alias brew-upgrade='brew update && brew upgrade && brew cleanup'
alias pkg-upgrade='yarn-upgrade ; pip-upgrade ; brew-upgrade'

alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"

case ${OSTYPE} in
  darwin*)
  alias flushdns='dscacheutil -flushcache;sudo killall -HUP mDNSResponder'

  # fix ggrep
  unset GREP_OPTIONS

  # z command
  if [[ -s ~/tmp/.z ]] then
  export _Z_DATA=~/tmp/.z
  . /usr/local/etc/profile.d/z.sh
  alias j='z'
  fi
  ;;
esac

# Temporary Files
if [[ ! -d "$TMPDIR" ]]; then
  export TMPDIR="/tmp/$LOGNAME"
  mkdir -p -m 700 "$TMPDIR"
fi

TMPPREFIX="${TMPDIR%/}/zsh"

# ruby
eval "$(rbenv init - --no-rehash)"

if [ -d $HOME/.pyenv ] ; then
  export PYENV_ROOT="$HOME/.pyenv"
  eval "$(pyenv init -)"
fi

if [ -d "$HOME/.nodebrew" ] ; then
  export NODEBREW_ROOT=$HOME/.nodebrew
  export NODE_HOME="$NODEBREW_ROOT/current/bin"
  path=($NODE_HOME(N-/) $path)
fi

export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
export STUDIO_JDK=${JAVA_HOME%/*/*}
export ANDROID_HOME=$HOME/Library/Android/sdk
path=($path $ANDROID_HOME/platform-tools(N-/))

# vim: set syntax=zsh:
