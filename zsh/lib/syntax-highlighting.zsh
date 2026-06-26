dotfiles_load_syntax_highlighting() {
  emulate -L zsh
  [[ -n "${DOTFILES_SYNTAX_HIGHLIGHTING_LOADED:-}" ]] && return 0

  local highlighter="${XDG_DATA_HOME:-$HOME/.local/share}/sheldon/repos/github.com/zdharma-continuum/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
  [[ -r "$highlighter" ]] || return 0

  DOTFILES_SYNTAX_HIGHLIGHTING_LOADED=1
  source "$highlighter"
}

if [[ -n "${ZSH_LOAD_SYNTAX_HIGHLIGHTING:-}" ]]; then
  dotfiles_load_syntax_highlighting
elif [[ -o interactive ]]; then
  autoload -Uz add-zle-hook-widget

  dotfiles_load_syntax_highlighting_once() {
    add-zle-hook-widget -d zle-line-init dotfiles_load_syntax_highlighting_once 2>/dev/null
    dotfiles_load_syntax_highlighting
  }

  add-zle-hook-widget zle-line-init dotfiles_load_syntax_highlighting_once
fi

# vim: set syntax=zsh:
