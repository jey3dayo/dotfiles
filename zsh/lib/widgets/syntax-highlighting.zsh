_zsh_load_syntax_highlighting() {
  emulate -L zsh
  [[ -n "${ZSH_SYNTAX_HIGHLIGHTING_LOADED:-}" ]] && return 0

  local highlighter="${XDG_DATA_HOME:-$HOME/.local/share}/sheldon/repos/github.com/zdharma-continuum/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
  [[ -r "$highlighter" ]] || return 0

  ZSH_SYNTAX_HIGHLIGHTING_LOADED=1
  () { source "$1" } "$highlighter"
}

if [[ -n "${ZSH_LOAD_SYNTAX_HIGHLIGHTING:-}" ]]; then
  _zsh_load_syntax_highlighting
elif [[ -o interactive ]]; then
  autoload -Uz add-zsh-hook

  _zsh_load_syntax_highlighting_once() {
    add-zsh-hook -d precmd _zsh_load_syntax_highlighting_once 2>/dev/null
    _zsh_load_syntax_highlighting
  }

  add-zsh-hook precmd _zsh_load_syntax_highlighting_once
fi

# vim: set syntax=zsh:
