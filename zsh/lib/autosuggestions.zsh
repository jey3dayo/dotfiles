dotfiles_load_autosuggestions() {
  emulate -L zsh
  [[ -n "${DOTFILES_AUTOSUGGESTIONS_LOADED:-}" ]] && return 0

  local autosuggestions="${XDG_DATA_HOME:-$HOME/.local/share}/sheldon/repos/github.com/zsh-users/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [[ -r "$autosuggestions" ]] || return 0

  DOTFILES_AUTOSUGGESTIONS_LOADED=1
  source "$autosuggestions"
}

if [[ -n "${ZSH_LOAD_AUTOSUGGESTIONS:-}" ]]; then
  dotfiles_load_autosuggestions
elif [[ -o interactive ]]; then
  autoload -Uz add-zle-hook-widget

  dotfiles_load_autosuggestions_once() {
    add-zle-hook-widget -d zle-line-init dotfiles_load_autosuggestions_once 2>/dev/null
    dotfiles_load_autosuggestions
  }

  add-zle-hook-widget zle-line-init dotfiles_load_autosuggestions_once
fi

# vim: set syntax=zsh:
