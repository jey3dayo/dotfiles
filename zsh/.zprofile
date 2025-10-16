export LANG='ja_JP.UTF-8'
export LC_ALL='ja_JP.UTF-8'

export BROWSER='open'
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'

export LISTMAX=0
export GREP_OPTIONS='--color=auto'

typeset -U path cdpath fpath manpath

# Fix PATH after macOS path_helper reorders it
# path_helper puts system paths first, but we want mise-managed tools to have priority
# Re-prioritize mise shims after system path_helper
# Note: User paths ($HOME/bin, etc.) are already set in .zshenv
# Note: Homebrew paths are added by config/core/path.zsh
path=(
  $HOME/.mise/shims(N-)
  $HOME/.claude/local(N-)
  $path
)

# vim: set syntax=zsh:
