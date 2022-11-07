# alias
alias vim="nvim"
alias vi="nvim"
alias less="less -giMRSW -z-4 -x4"
alias where="command -v"
alias df="df -h"
alias du="du -h"
alias l='exa -la'
alias ll='exa -la'
alias hg="hg --encoding=utf-8"
alias gst="git status -sb"
alias tailf="tail -f"
alias ag="ag --hidden"

# gnu
alias sed="gsed"
alias grep="ggrep"

# custom
alias npm-clean='npm run ncu && rm -rf node_modules && yarn && npm prune'
alias pip-upgrade='pip3 list --format json --outdated | jq .[].name | xargs pip install -U'
alias yarn-upgrade='yarn global upgrade'
alias brew-upgrade='brew update && brew upgrade && brew cleanup'
alias software-upgrade='softwareupdate --all --install --force'
alias pkg-upgrade='yarn-upgrade ; pip-upgrade ; brew-upgrade ; software-upgrade ; npm -g i npm-check-updates'

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

# diff
if command -v colordiff>/dev/null; then
  alias diff="colordiff"
fi

# peco
if command -v peco>/dev/null; then
  alias s='ssh $(grep -iE "^host[[:space:]]+[^*]" ~/.ssh/config|grep -v \*|peco|awk "{print \$2}")'
fi
