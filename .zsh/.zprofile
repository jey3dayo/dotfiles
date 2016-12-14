export LANG='ja_JP.UTF-8'
export LC_ALL='ja_JP.UTF-8'

export BROWSER='open'
export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'

export LISTMAX=0
export GREP_OPTIONS='--color=auto'

typeset -gU cdpath fpath mailpath path

path=(
  /usr/local/{bin,sbin}(N-/)
  $HOME/{bin,sbin}(N-/)
  $HOME/local/bin(N-/)
  $path
)

# alias
alias vi="vim"
alias less="less -giMRSW -z-4 -x4"
alias where="command -v"
alias df="df -h"
alias du="du -h"
alias ll='ls -lAFhp'
alias ls='ls -pF'
alias hg="hg --encoding=utf-8"
alias gst="git status -sb"
alias tailf="tail -f"

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
alias pip-upgrade='pip list --format json | jq .[].name | xargs pip install -U'
alias brew-upgrade='brew update && brew upgrade && brew prune && brew file cask_upgrade -C'

case ${OSTYPE} in
  darwin*)
  alias flushdns='dscacheutil -flushcache;sudo killall -HUP mDNSResponder'

  # fix ggrep
  unset GREP_OPTIONS

  # z command
  if [[ -s ~/tmp/.z ]] then
  export _Z_DATA=~/tmp/.z
  . `brew --prefix`/etc/profile.d/z.sh
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

# vim: set syntax=zsh:
