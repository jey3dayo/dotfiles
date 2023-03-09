export LANG='ja_JP.UTF-8'
export LC_ALL='ja_JP.UTF-8'

export BROWSER='open'
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'

export LISTMAX=0
export GREP_OPTIONS='--color=auto'

# load sources
for f ("${ZDOTDIR:-$HOME}"/sources/*.zsh) source "${f}"

typeset -U path cdpath fpath manpath

# vim: set syntax=zsh:
