# FZF integration - aliases, functions, and widgets

if ! command -v fzf >/dev/null 2>&1; then
  return
fi

_fzf_cmd() {
  if [[ -n "${TMUX_PANE:-}" ]] && [[ "${FZF_TMUX:-1}" != 0 ]]; then
    fzf-tmux -d"${FZF_TMUX_HEIGHT:-$ZSH_FZF_TMUX_HEIGHT_DEFAULT}" "$@"
  else
    fzf "$@"
  fi
}

# GHQ integration
if command -v ghq >/dev/null 2>&1; then
  alias ghq-repos="ghq list -p | fzf --prompt 'GHQ> ' --height ${ZSH_FZF_PICKER_HEIGHT} --reverse"
  alias ghq-repo='cd $(ghq-repos)'

  # GHQ repository selection widget
  cd-fzf-ghqlist-widget() {
    local REPO
    REPO=$(ghq list -p | xargs ls -dt1 | sed -e "s;${GHQ_ROOT}/;;g" | _fzf_cmd --prompt 'GHQ> ' --preview "bat --color=always --style=header,grid --line-range :${ZSH_FZF_PREVIEW_LINE_RANGE} $(ghq root)/{}/README.*")
    if [ -n "${REPO}" ]; then
      BUFFER="cd ${GHQ_ROOT}/${REPO}"
    fi
    zle accept-line
  }
  zle -N cd-fzf-ghqlist-widget
  bindkey '^]' cd-fzf-ghqlist-widget
fi

# SSH host selection
_ssh_hosts() {
  for config in \
    ~/.ssh/config \
    ~/.ssh/ssh_config.d/* \
    "${XDG_CONFIG_HOME:-$HOME/.config}"/ssh/ssh_config \
    "${XDG_CONFIG_HOME:-$HOME/.config}"/ssh/ssh_config.d/* \
    "${XDG_CONFIG_HOME:-$HOME/.config}"/ssh/config.d/*; do
    [[ -f "$config" ]] && grep -iE "^host[[:space:]]+[^*]" "$config" 2>/dev/null
  done | grep -F -v "*" | awk '{print $2}' | sort -u
}

if [[ -f ~/.ssh/config ]] || [[ -d ~/.ssh/ssh_config.d ]] || [[ -f ${XDG_CONFIG_HOME:-$HOME/.config}/ssh/ssh_config ]]; then
  alias s='ssh $(_ssh_hosts | fzf --prompt "SSH> " --height ${ZSH_FZF_PICKER_HEIGHT} --reverse)'
fi
