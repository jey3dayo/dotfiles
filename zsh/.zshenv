export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"

if [[ "$SHLVL" -eq 1 && -s "${ZDOTDIR}/.zshenv.local" ]]; then
  source "${ZDOTDIR}/.zshenv.local"
fi

alias npm-upgrade='npm -g i npm-check-updates'
alias pip-upgrade='pip3 list --format json --outdated | jq .[].name | xargs pip install -U'
alias yarn-upgrade='yarn global upgrade'
alias brew-upgrade='brew update && brew upgrade && brew cleanup'
alias software-upgrade='softwareupdate --all --install --force'
alias pkg-upgrade="npm-upgrade && pip-upgrade && yarn-upgrade && brew-upgrade && spoftware-upgrade"
export GHQ_ROOT=~/src

# vim: set syntax=zsh:
