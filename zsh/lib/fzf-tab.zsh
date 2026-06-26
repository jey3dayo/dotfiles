_zsh_load_fzf_tab() {
  emulate -L zsh
  [[ -n "${ZSH_FZF_TAB_LOADED:-}" ]] && return 0
  command -v fzf >/dev/null 2>&1 || return 0

  local fzf_tab="${XDG_DATA_HOME:-$HOME/.local/share}/sheldon/repos/github.com/Aloxaf/fzf-tab/fzf-tab.plugin.zsh"
  [[ -r "$fzf_tab" ]] || return 0

  ZSH_FZF_TAB_LOADED=1
  zstyle ':completion:*' menu no
  zstyle ':fzf-tab:*' switch-group '<' '>'
  () { source "$1" } "$fzf_tab"
}

if [[ -n "${ZSH_LOAD_FZF_TAB:-}" ]]; then
  _zsh_load_fzf_tab
elif [[ -o interactive ]]; then
  autoload -Uz add-zsh-hook

  _zsh_load_fzf_tab_once() {
    add-zsh-hook -d precmd _zsh_load_fzf_tab_once 2>/dev/null
    _zsh_load_fzf_tab
  }

  add-zsh-hook precmd _zsh_load_fzf_tab_once
fi

# vim: set syntax=zsh:
