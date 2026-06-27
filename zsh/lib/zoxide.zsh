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
  _zsh_zoxide_cd() {
    _zsh_load_zoxide
    if (( $+functions[__zoxide_z] )); then
      __zoxide_z "$@"
    else
      builtin cd "$@"
    fi
  }

  z() {
    _zsh_zoxide_cd "$@"
  }

  j() {
    _zsh_zoxide_cd "$@"
  }
fi

# vim: set syntax=zsh:
