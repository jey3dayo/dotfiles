: "${XDG_STATE_HOME:=${HOME}/.local/state}"

_dotfiles_source_zsh_lib() {
  local file="${ZDOTDIR:-$HOME/.config/zsh}/lib/$1"
  [[ -r "$file" ]] && source "$file"
}

_dotfiles_source_zsh_lib path.zsh
(( $+functions[dotfiles_zsh_setup_path] )) && dotfiles_zsh_setup_path

_dotfiles_source_zsh_lib options.zsh
_dotfiles_source_zsh_lib history.zsh
_dotfiles_source_zsh_lib tool-completions.zsh
_dotfiles_source_zsh_lib completion.zsh
_dotfiles_source_zsh_lib ni.zsh
_dotfiles_source_zsh_lib gh.zsh
_dotfiles_source_zsh_lib history-search.zsh
_dotfiles_source_zsh_lib fzf.zsh
_dotfiles_source_zsh_lib fzf-tab.zsh
_dotfiles_source_zsh_lib git-widgets.zsh
_dotfiles_source_zsh_lib autosuggestions.zsh
_dotfiles_source_zsh_lib atuin.zsh
_dotfiles_source_zsh_lib zoxide.zsh
_dotfiles_source_zsh_lib wsl.zsh
_dotfiles_source_zsh_lib plugins.zsh
_dotfiles_source_zsh_lib prompt.zsh
_dotfiles_source_zsh_lib syntax-highlighting.zsh

unfunction _dotfiles_source_zsh_lib dotfiles_zsh_setup_path 2>/dev/null

# vim: set syntax=zsh:
