# FZF configuration and custom functions

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

# GHQ integration
alias ghq-repos="ghq list -p | fzf --prompt 'GHQ> ' --height 40% --reverse"
alias ghq-repo='cd $(ghq-repos)'

# SSH host selection
alias s='ssh $(grep -iE "^host[[:space:]]+[^*]" ~/.ssh/config|grep -v \*|fzf|awk "{print \$2}")'