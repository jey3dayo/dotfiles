_zsh_load_fzf() {
  emulate -L zsh
  [[ -n "${ZSH_FZF_LOADED:-}" ]] && return 0
  command -v fzf >/dev/null 2>&1 || return 0

  local fzf_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/fzf/fzf.zsh"
  [[ -r "$fzf_cache" ]] || return 0

  ZSH_FZF_LOADED=1
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-"--height 50% --reverse"}"
  export FZF_CTRL_T_COMMAND="${FZF_CTRL_T_COMMAND:-"fd --type f --hidden --follow --exclude .git --exclude node_modules --exclude .worktrees --exclude .claude/worktrees --exclude tmp --exclude dist --exclude build"}"
  export FZF_CTRL_T_OPTS="${FZF_CTRL_T_OPTS:-"--preview 'bat -n --color=always {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"}"
  () { source "$1" >/dev/null } "$fzf_cache"

  if (( $+widgets[fzf-cd-widget] )); then
    local keymap
    for keymap in emacs viins vicmd; do
      bindkey -M "$keymap" '^gc' fzf-cd-widget
      bindkey -M "$keymap" '^g^c' fzf-cd-widget
    done
  fi

  if command -v ghq >/dev/null 2>&1; then
    _zsh_fzf_ghq_widget_impl() {
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

    zle -N _zsh_fzf_ghq_widget
    bindkey '^]' _zsh_fzf_ghq_widget
  fi

  _zsh_fzf_kill_widget_impl() {
    if [[ "${UID}" == 0 ]]; then
      BUFFER="ps -ef | sed 1d | fzf --prompt 'Kill> ' --height 40% --reverse | awk '{print \$2}' | xargs kill -9"
    else
      BUFFER="ps -f -u \${UID} | sed 1d | fzf --prompt 'Kill> ' --height 40% --reverse | awk '{print \$2}' | xargs kill -9"
    fi
    zle accept-line
  }

  zle -N _zsh_fzf_kill_widget
  local keymap
  for keymap in emacs viins vicmd; do
    bindkey -M "$keymap" '^gx' _zsh_fzf_kill_widget
    bindkey -M "$keymap" '^g^x' _zsh_fzf_kill_widget
  done
}

_zsh_fzf_file_widget() {
  _zsh_load_fzf >/dev/null
  if (( $+widgets[fzf-file-widget] )); then
    zle fzf-file-widget
  else
    zle reset-prompt
  fi
}

_zsh_fzf_cd_widget() {
  _zsh_load_fzf >/dev/null
  if (( $+widgets[fzf-cd-widget] )); then
    zle fzf-cd-widget
  else
    zle reset-prompt
  fi
}

_zsh_fzf_ghq_widget() {
  _zsh_load_fzf >/dev/null
  if (( $+functions[_zsh_fzf_ghq_widget_impl] )); then
    _zsh_fzf_ghq_widget_impl
  else
    zle reset-prompt
  fi
}

_zsh_fzf_kill_widget() {
  _zsh_load_fzf >/dev/null
  if (( $+functions[_zsh_fzf_kill_widget_impl] )); then
    _zsh_fzf_kill_widget_impl
  else
    zle reset-prompt
  fi
}

if [[ -n "${ZSH_LOAD_FZF:-}" ]]; then
  _zsh_load_fzf >/dev/null
elif [[ -o interactive ]]; then
  zle -N _zsh_fzf_file_widget
  zle -N _zsh_fzf_cd_widget
  zle -N _zsh_fzf_ghq_widget
  zle -N _zsh_fzf_kill_widget
  bindkey '^T' _zsh_fzf_file_widget
  bindkey '\ec' _zsh_fzf_cd_widget
  bindkey '^]' _zsh_fzf_ghq_widget

  keymap=
  for keymap in emacs viins vicmd; do
    bindkey -M "$keymap" '^gc' _zsh_fzf_cd_widget
    bindkey -M "$keymap" '^g^c' _zsh_fzf_cd_widget
    bindkey -M "$keymap" '^gx' _zsh_fzf_kill_widget
    bindkey -M "$keymap" '^g^x' _zsh_fzf_kill_widget
  done
  unset keymap
fi

# vim: set syntax=zsh:
