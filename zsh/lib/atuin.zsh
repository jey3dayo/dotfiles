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
  autoload -Uz add-zsh-hook

  _zsh_load_atuin_once() {
    add-zsh-hook -d precmd _zsh_load_atuin_once 2>/dev/null
    _zsh_load_atuin
  }

  add-zsh-hook precmd _zsh_load_atuin_once
fi

# vim: set syntax=zsh:
