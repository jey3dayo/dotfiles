_zsh_load_gh_completion() {
  emulate -L zsh
  [[ -n "${ZSH_GH_COMPLETION_LOADED:-}" ]] && return 0

  local gh_completion="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions/_gh"
  [[ -r "$gh_completion" ]] || return 0

  ZSH_GH_COMPLETION_LOADED=1
  () { source "$1" } "$gh_completion"
}

if [[ -n "${ZSH_LOAD_GH:-}" ]]; then
  _zsh_load_gh_completion
elif [[ -o interactive ]]; then
  autoload -Uz add-zsh-hook

  _zsh_load_gh_completion_once() {
    add-zsh-hook -d precmd _zsh_load_gh_completion_once 2>/dev/null
    _zsh_load_gh_completion
  }

  add-zsh-hook precmd _zsh_load_gh_completion_once
fi

# vim: set syntax=zsh:
