# LC_ALL is intentionally unset: it overrides every LC_* and breaks tools
# that assume C-locale sort/grep behavior.
export LANG='ja_JP.UTF-8'
export BROWSER='open'
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'
export LISTMAX=0

typeset -gaU path
typeset -U cdpath fpath manpath

[[ -r "${ZDOTDIR:-$HOME/.config/zsh}/lib/path.zsh" ]] && source "${ZDOTDIR:-$HOME/.config/zsh}/lib/path.zsh"
(( $+functions[_zsh_setup_path] )) && _zsh_setup_path
unfunction _zsh_setup_path 2>/dev/null

# vim: set syntax=zsh:
