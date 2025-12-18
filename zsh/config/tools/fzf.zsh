# FZF configuration only - loaded early for immediate availability

if command -v fzf >/dev/null 2>&1; then
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

  # Process kill widget
  fzf-kill-widget() {
    # Run the kill command in the shell for proper interactive behavior
    if [[ "${UID}" != "0" ]]; then
      BUFFER="ps -f -u \${UID} | sed 1d | fzf --prompt 'Kill> ' --height 40% --reverse | awk '{print \$2}' | xargs kill -9"
    else
      BUFFER="ps -ef | sed 1d | fzf --prompt 'Kill> ' --height 40% --reverse | awk '{print \$2}' | xargs kill -9"
    fi
    zle accept-line
  }
  zle -N fzf-kill-widget
  bindkey '^gx' fzf-kill-widget
  bindkey '^g^x' fzf-kill-widget
fi
