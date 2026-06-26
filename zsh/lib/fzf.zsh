dotfiles_load_fzf() {
  emulate -L zsh
  [[ -n "${DOTFILES_FZF_LOADED:-}" ]] && return 0
  command -v fzf >/dev/null 2>&1 || return 0

  local fzf_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/fzf/fzf.zsh"
  [[ -r "$fzf_cache" ]] || return 0

  DOTFILES_FZF_LOADED=1
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-"--height 50% --reverse"}"
  export FZF_CTRL_T_COMMAND="${FZF_CTRL_T_COMMAND:-"fd --type f --hidden --follow --exclude .git --exclude node_modules --exclude .worktrees --exclude .claude/worktrees --exclude tmp --exclude dist --exclude build"}"
  export FZF_CTRL_T_OPTS="${FZF_CTRL_T_OPTS:-"--preview 'bat -n --color=always {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"}"
  source "$fzf_cache"

  if (( $+widgets[fzf-cd-widget] )); then
    local keymap
    for keymap in emacs viins vicmd; do
      bindkey -M "$keymap" '^gc' fzf-cd-widget
      bindkey -M "$keymap" '^g^c' fzf-cd-widget
    done
  fi

  if command -v ghq >/dev/null 2>&1; then
    dotfiles_fzf_ghq_widget() {
      local repo
      repo="$(
        ghq list -p |
          fzf --prompt='GHQ> ' --height=40% --reverse \
            --preview 'bat --color=always --style=header,grid --line-range :80 {}/README.* 2>/dev/null || eza -la --color=always {}'
      )"
      [[ -n "$repo" ]] || return 0
      BUFFER="cd ${(q)repo}"
      zle accept-line
    }

    zle -N dotfiles_fzf_ghq_widget
    bindkey '^]' dotfiles_fzf_ghq_widget
  fi

  dotfiles_fzf_kill_widget() {
    if [[ "${UID}" == 0 ]]; then
      BUFFER="ps -ef | sed 1d | fzf --prompt 'Kill> ' --height 40% --reverse | awk '{print \$2}' | xargs kill -9"
    else
      BUFFER="ps -f -u \${UID} | sed 1d | fzf --prompt 'Kill> ' --height 40% --reverse | awk '{print \$2}' | xargs kill -9"
    fi
    zle accept-line
  }

  zle -N dotfiles_fzf_kill_widget
  local keymap
  for keymap in emacs viins vicmd; do
    bindkey -M "$keymap" '^gx' dotfiles_fzf_kill_widget
    bindkey -M "$keymap" '^g^x' dotfiles_fzf_kill_widget
  done
}

if [[ -n "${ZSH_LOAD_FZF:-}" ]]; then
  dotfiles_load_fzf
elif [[ -o interactive ]]; then
  autoload -Uz add-zle-hook-widget

  dotfiles_load_fzf_once() {
    add-zle-hook-widget -d zle-line-init dotfiles_load_fzf_once 2>/dev/null
    dotfiles_load_fzf
  }

  add-zle-hook-widget zle-line-init dotfiles_load_fzf_once
fi

# vim: set syntax=zsh:
