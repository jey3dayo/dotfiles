_zsh_load_atuin() {
  emulate -L zsh
  [[ -n "${ZSH_ATUIN_LOADED:-}" ]] && return 0
  command -v atuin >/dev/null 2>&1 || return 0

  ZSH_ATUIN_LOADED=1
  eval "$(atuin init zsh --disable-up-arrow)"
}

if [[ -n "${ZSH_LOAD_ATUIN:-}" ]]; then
  _zsh_load_atuin
elif [[ -o interactive ]]; then
  _zsh_atuin_search_widget() {
    _zsh_load_atuin
    if (( $+widgets[atuin-search] )); then
      zle atuin-search
    else
      zle reset-prompt
    fi
  }

  zle -N _zsh_atuin_search_widget
  for keymap in emacs viins vicmd; do
    bindkey -M "$keymap" '^R' _zsh_atuin_search_widget
  done
  unset keymap
fi

# vim: set syntax=zsh:
