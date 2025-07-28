# FZF integration - aliases, functions, and widgets

if ! command -v fzf >/dev/null 2>&1; then
  return
fi

# GHQ integration
if command -v ghq >/dev/null 2>&1; then
  alias ghq-repos="ghq list -p | fzf --prompt 'GHQ> ' --height 40% --reverse"
  alias ghq-repo='cd $(ghq-repos)'

  # GHQ repository selection widget
  cd-fzf-ghqlist-widget() {
    local REPO
    REPO=$(ghq list -p | xargs ls -dt1 | sed -e 's;'${GHQ_ROOT}/';;g' | $(__fzfcmd) --prompt 'GHQ> ' --preview "bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*")
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
  local config_files=(
    ~/.ssh/config
    ~/.ssh/ssh_config.d/*
    ${XDG_CONFIG_HOME:-$HOME/.config}/ssh/ssh_config
    ${XDG_CONFIG_HOME:-$HOME/.config}/ssh/ssh_config.d/*
    ${XDG_CONFIG_HOME:-$HOME/.config}/ssh/config.d/*
  )

  for config in $config_files; do
    [[ -f $config ]] && grep -iE "^host[[:space:]]+[^*]" "$config" 2>/dev/null
  done | grep -v \* | awk '{print $2}' | sort -u
}

if [[ -f ~/.ssh/config ]] || [[ -d ~/.ssh/ssh_config.d ]] || [[ -f ${XDG_CONFIG_HOME:-$HOME/.config}/ssh/ssh_config ]]; then
  alias s='ssh $(_ssh_hosts | fzf --prompt "SSH> " --height 40% --reverse)'
fi

# Process kill widget
fzf-kill-widget() {
  local pid
  if [[ "${UID}" != "0" ]]; then
    pid=$(ps -f -u ${UID} | sed 1d | $(__fzfcmd) | awk '{print $2}')
  else
    pid=$(ps -ef | sed 1d | $(__fzfcmd) | awk '{print $2}')
  fi

  if [[ "x$pid" != "x" ]]; then
    echo $pid | xargs kill "-${1:-9}"
  fi
  zle reset-prompt
}
zle -N fzf-kill-widget
bindkey '^g^K' fzf-kill-widget
