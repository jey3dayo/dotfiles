# FZF configuration only - loaded early for immediate availability

if command -v fzf > /dev/null 2>&1; then
  # Workaround for zsh 5.9+: upstream fzf scripts restore shell options via
  # `eval $__fzf_*_options`, and the serialized options include `zle on/off`.
  # Setting `zle` via `setopt` is invalid, so patch those eval lines in cache.
  _source_patched_fzf_script() {
    local src="$1"
    local cache_name="$2"
    local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/fzf"
    local patched="$cache_dir/$cache_name"

    [[ -r "$src" ]] || return 0
    if [[ ! -r "$patched" || "$src" -nt "$patched" ]]; then
      mkdir -p "$cache_dir"
      awk '
        /^[[:space:]]*eval \$__fzf_completion_options$/ {
          print "  local __fzf_restore_opts=\"${__fzf_completion_options// zle on/}\""
          print "  __fzf_restore_opts=\"${__fzf_restore_opts// zle off/}\""
          print "  eval \"$__fzf_restore_opts\""
          print "  unset __fzf_restore_opts"
          next
        }
        /^[[:space:]]*eval \$__fzf_key_bindings_options$/ {
          print "  local __fzf_restore_opts=\"${__fzf_key_bindings_options// zle on/}\""
          print "  __fzf_restore_opts=\"${__fzf_restore_opts// zle off/}\""
          print "  eval \"$__fzf_restore_opts\""
          print "  unset __fzf_restore_opts"
          next
        }
        { print }
      ' "$src" >| "$patched"
    fi
    source "$patched"
  }

  local fzf_shell_dir="${XDG_DATA_HOME:-$HOME/.local/share}/sheldon/repos/github.com/junegunn/fzf/shell"
  _source_patched_fzf_script "$fzf_shell_dir/completion.zsh" "completion.zsh"
  _source_patched_fzf_script "$fzf_shell_dir/key-bindings.zsh" "key-bindings.zsh"
  unfunction _source_patched_fzf_script 2> /dev/null

  export FZF_DEFAULT_OPTS="--height ${ZSH_FZF_DEFAULT_HEIGHT} --reverse"

  export FZF_CTRL_R_OPTS="
    --preview 'echo {}' --preview-window up:${ZSH_FZF_CTRL_R_PREVIEW_LINES}:hidden:wrap
    --bind 'ctrl-/:toggle-preview'
    --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
    --color header:italic
    --header 'Press CTRL-Y to copy command into clipboard'"

  export FZF_CTRL_T_OPTS="
    --preview 'bat -n --color=always {}'
    --bind 'ctrl-/:change-preview-window(down|hidden|)'"

  # Process kill widget
  fzf-kill-widget() {
    local -r root_uid=0
    # Run the kill command in the shell for proper interactive behavior
    if [[ "${UID}" != "$root_uid" ]]; then
      BUFFER="ps -f -u \${UID} | sed 1d | fzf --prompt 'Kill> ' --height ${ZSH_FZF_KILL_HEIGHT} --reverse | awk '{print \$2}' | xargs kill -${ZSH_FZF_KILL_SIGNAL}"
    else
      BUFFER="ps -ef | sed 1d | fzf --prompt 'Kill> ' --height ${ZSH_FZF_KILL_HEIGHT} --reverse | awk '{print \$2}' | xargs kill -${ZSH_FZF_KILL_SIGNAL}"
    fi
    zle accept-line
  }
  zle -N fzf-kill-widget
  for keymap in emacs viins vicmd; do
    bindkey -M "$keymap" '^gx' fzf-kill-widget
    bindkey -M "$keymap" '^g^x' fzf-kill-widget
  done
fi
