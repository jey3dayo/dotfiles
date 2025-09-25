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
# path_helper puts system paths first, but we want our paths to have priority
# Re-add critical paths that should come before system paths
path=(
  $HOME/.claude/local(N-/)
  $HOME/bin(N-/)
  $HOME/.local/bin(N-/)
  /opt/homebrew/bin(N-/)
  /opt/homebrew/sbin(N-/)
  $path
)

# Activate mise if available
if [[ -x /opt/homebrew/bin/mise ]]; then
  # Activate mise immediately for tool availability
  eval "$(/opt/homebrew/bin/mise activate zsh)"
  # Force initial hook execution
  if (( $+functions[_mise_hook] )); then
    _mise_hook
  fi
fi

# vim: set syntax=zsh:
