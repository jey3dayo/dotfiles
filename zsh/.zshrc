: "${XDG_STATE_HOME:=${HOME}/.local/state}"

source_zsh_lib() {
  local file="${ZDOTDIR:-$HOME/.config/zsh}/lib/$1"
  [[ -r "$file" ]] && source "$file"
}

# Core shell state
# path.zsh also runs in .zprofile; re-running here covers non-login shells
# that skip .zprofile. _zsh_setup_path is idempotent.
source_zsh_lib core/path.zsh
(( $+functions[_zsh_setup_path] )) && _zsh_setup_path
source_zsh_lib core/options.zsh
source_zsh_lib core/history.zsh

# Completion setup
source_zsh_lib completion/completion.zsh
source_zsh_lib completion/ni.zsh
source_zsh_lib completion/gh-completion.zsh
source_zsh_lib integrations/aicommits.zsh

# Agent integrations
source_zsh_lib integrations/agmsg.zsh
source_zsh_lib integrations/codex.zsh
source_zsh_lib integrations/secrets.zsh

# Key bindings and widgets
source_zsh_lib widgets/fzf.zsh
source_zsh_lib widgets/fzf-tab.zsh
source_zsh_lib widgets/git-widgets.zsh

# Interactive input integrations
source_zsh_lib integrations/abbr.zsh
source_zsh_lib integrations/atuin.zsh
source_zsh_lib integrations/zoxide.zsh
source_zsh_lib widgets/autosuggestions.zsh

# Platform-specific setup
source_zsh_lib platform/wsl.zsh

# Prompt and final ZLE decorators
source_zsh_lib core/prompt.zsh
source_zsh_lib widgets/syntax-highlighting.zsh

unfunction source_zsh_lib _zsh_setup_path 2>/dev/null

# vim: set syntax=zsh:
