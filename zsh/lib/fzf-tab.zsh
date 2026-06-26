dotfiles_load_fzf_tab() {
  emulate -L zsh
  [[ -n "${DOTFILES_FZF_TAB_LOADED:-}" ]] && return 0
  command -v fzf >/dev/null 2>&1 || return 0

  local fzf_tab="${XDG_DATA_HOME:-$HOME/.local/share}/sheldon/repos/github.com/Aloxaf/fzf-tab/fzf-tab.plugin.zsh"
  [[ -r "$fzf_tab" ]] || return 0

  DOTFILES_FZF_TAB_LOADED=1
  zstyle ':completion:*' menu no
  zstyle ':fzf-tab:*' switch-group '<' '>'
  source "$fzf_tab"
}

if [[ -n "${ZSH_LOAD_FZF_TAB:-}" ]]; then
  dotfiles_load_fzf_tab
elif [[ -o interactive ]]; then
  autoload -Uz add-zle-hook-widget

  dotfiles_load_fzf_tab_once() {
    add-zle-hook-widget -d zle-line-init dotfiles_load_fzf_tab_once 2>/dev/null
    dotfiles_load_fzf_tab
  }

  add-zle-hook-widget zle-line-init dotfiles_load_fzf_tab_once
fi

# vim: set syntax=zsh:
