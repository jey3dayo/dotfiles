dotfiles_load_gh_completion() {
  emulate -L zsh
  [[ -n "${DOTFILES_GH_COMPLETION_LOADED:-}" ]] && return 0

  local gh_completion="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions/_gh"
  [[ -r "$gh_completion" ]] || return 0

  DOTFILES_GH_COMPLETION_LOADED=1
  source "$gh_completion"
}

if [[ -n "${ZSH_LOAD_GH:-}" ]]; then
  dotfiles_load_gh_completion
elif [[ -o interactive ]]; then
  autoload -Uz add-zle-hook-widget

  dotfiles_load_gh_completion_once() {
    add-zle-hook-widget -d zle-line-init dotfiles_load_gh_completion_once 2>/dev/null
    dotfiles_load_gh_completion
  }

  add-zle-hook-widget zle-line-init dotfiles_load_gh_completion_once
fi

# vim: set syntax=zsh:
