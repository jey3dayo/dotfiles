dotfiles_load_atuin() {
  emulate -L zsh
  [[ -n "${DOTFILES_ATUIN_LOADED:-}" ]] && return 0
  command -v atuin >/dev/null 2>&1 || return 0

  DOTFILES_ATUIN_LOADED=1
  eval "$(atuin init zsh --disable-up-arrow)"
}

if [[ -n "${ZSH_LOAD_ATUIN:-}" ]]; then
  dotfiles_load_atuin
elif [[ -o interactive ]]; then
  autoload -Uz add-zle-hook-widget

  dotfiles_load_atuin_once() {
    add-zle-hook-widget -d zle-line-init dotfiles_load_atuin_once 2>/dev/null
    dotfiles_load_atuin
  }

  add-zle-hook-widget zle-line-init dotfiles_load_atuin_once
fi

# vim: set syntax=zsh:
