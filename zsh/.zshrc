: "${XDG_STATE_HOME:=${HOME}/.local/state}"

source_zsh_lib() {
  local file="${ZDOTDIR:-$HOME/.config/zsh}/lib/$1"
  [[ -r "$file" ]] && source "$file"
}

# Core shell state
source_zsh_lib path.zsh
(( $+functions[_zsh_setup_path] )) && _zsh_setup_path
source_zsh_lib options.zsh
source_zsh_lib history.zsh

# Completion setup
source_zsh_lib completion.zsh
source_zsh_lib ni.zsh
source_zsh_lib gh-completion.zsh

# Key bindings and widgets
source_zsh_lib fzf.zsh
source_zsh_lib fzf-tab.zsh
source_zsh_lib git-widgets.zsh

# Interactive input integrations
source_zsh_lib abbr.zsh
source_zsh_lib atuin.zsh
source_zsh_lib zoxide.zsh
source_zsh_lib autosuggestions.zsh

# Platform-specific setup
source_zsh_lib wsl.zsh

# Prompt and final ZLE decorators
source_zsh_lib prompt.zsh
source_zsh_lib syntax-highlighting.zsh

unfunction source_zsh_lib _zsh_setup_path 2>/dev/null

# vim: set syntax=zsh:
