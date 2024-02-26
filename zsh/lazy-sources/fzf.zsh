export FZF_DEFAULT_OPTS="--height 50% --reverse"

export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

export FZF_CTRL_T_OPTS="
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

alias ghq-repos="ghq list -p | fzf --prompt 'GHQ> ' --height 40% --reverse"
alias ghq-repo='cd $(ghq-repos)'


function cd-fzf-ghqlist-widget() {
  local REPO
  REPO=$(ghq list -p | xargs ls -dt1 | sed -e 's;'${GHQ_ROOT}/';;g' | $(__fzfcmd) --prompt 'GHQ> ' --preview "bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*")
  if [ -n "${REPO}" ]; then
    BUFFER="cd ${GHQ_ROOT}/${REPO}"
  fi
  zle accept-line
}
zle -N cd-fzf-ghqlist-widget
bindkey '^]' cd-fzf-ghqlist-widget

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
zle     -N     fzf-kill-widget
bindkey '^g^K' fzf-kill-widget

alias s='ssh $(grep -iE "^host[[:space:]]+[^*]" ~/.ssh/config|grep -v \*|fzf|awk "{print \$2}")'
