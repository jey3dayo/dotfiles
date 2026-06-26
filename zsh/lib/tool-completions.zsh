_dotfiles_add_fpath() {
  local dir="$1"
  [[ -n "$dir" && -d "$dir" ]] || return 0
  fpath=("$dir" "${fpath[@]}")
}

_dotfiles_add_fpath "${XDG_DATA_HOME:-$HOME/.local/share}/sheldon/repos/github.com/eza-community/eza/completions/zsh"
_dotfiles_add_fpath "$HOME/.bun"

unfunction _dotfiles_add_fpath 2>/dev/null

# vim: set syntax=zsh:
