export LANG='ja_JP.UTF-8'
export LC_ALL='ja_JP.UTF-8'

export BROWSER='open'
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'

export LISTMAX=0

typeset -gaU path
typeset -U cdpath fpath manpath

# Load cargo environment for login shells.
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Keep standalone Bun available for login shells that do not read .zshrc.
if [[ -f "${ZDOTDIR}/config/tools/bun.zsh" ]]; then
  source "${ZDOTDIR}/config/tools/bun.zsh"
fi

# vim: set syntax=zsh:
