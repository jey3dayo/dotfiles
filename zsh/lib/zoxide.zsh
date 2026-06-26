dotfiles_load_zoxide() {
  emulate -L zsh
  [[ -n "${DOTFILES_ZOXIDE_LOADED:-}" ]] && return 0
  command -v zoxide >/dev/null 2>&1 || return 0

  DOTFILES_ZOXIDE_LOADED=1
  export _ZO_RESOLVE_SYMLINKS=1
  eval "$(zoxide init zsh)"
  alias j=z
}

if [[ -n "${ZSH_LOAD_ZOXIDE:-}" ]]; then
  dotfiles_load_zoxide
elif [[ -o interactive ]]; then
  autoload -Uz add-zle-hook-widget

  dotfiles_load_zoxide_once() {
    add-zle-hook-widget -d zle-line-init dotfiles_load_zoxide_once 2>/dev/null
    dotfiles_load_zoxide
  }

  add-zle-hook-widget zle-line-init dotfiles_load_zoxide_once
fi

# vim: set syntax=zsh:
