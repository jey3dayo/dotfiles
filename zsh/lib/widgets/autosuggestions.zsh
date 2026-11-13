_zsh_load_autosuggestions() {
  emulate -L zsh
  [[ -n "${ZSH_AUTOSUGGESTIONS_LOADED:-}" ]] && return 0

  local autosuggestions="${XDG_DATA_HOME:-$HOME/.local/share}/sheldon/repos/github.com/zsh-users/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [[ -r "$autosuggestions" ]] || return 0

  ZSH_AUTOSUGGESTIONS_LOADED=1
  () { source "$1" } "$autosuggestions"
}

if [[ -n "${ZSH_LOAD_AUTOSUGGESTIONS:-}" ]]; then
  _zsh_load_autosuggestions
elif [[ -o interactive ]]; then
  autoload -Uz add-zsh-hook

  _zsh_load_autosuggestions_once() {
    add-zsh-hook -d precmd _zsh_load_autosuggestions_once 2>/dev/null
    _zsh_load_autosuggestions
  }

  add-zsh-hook precmd _zsh_load_autosuggestions_once
fi

# vim: set syntax=zsh:
