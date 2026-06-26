_zsh_load_zoxide() {
  emulate -L zsh
  [[ -n "${ZSH_ZOXIDE_LOADED:-}" ]] && return 0
  command -v zoxide >/dev/null 2>&1 || return 0

  ZSH_ZOXIDE_LOADED=1
  export _ZO_RESOLVE_SYMLINKS=1
  eval "$(zoxide init zsh)"
  alias j=z
}

if [[ -n "${ZSH_LOAD_ZOXIDE:-}" ]]; then
  _zsh_load_zoxide
elif [[ -o interactive ]]; then
  autoload -Uz add-zsh-hook

  _zsh_load_zoxide_once() {
    add-zsh-hook -d precmd _zsh_load_zoxide_once 2>/dev/null
    _zsh_load_zoxide
  }

  add-zsh-hook precmd _zsh_load_zoxide_once
fi

# vim: set syntax=zsh:
