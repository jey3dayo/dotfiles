# shellcheck shell=bash
# bash entrypoint (tracked)
# - Keep environment setup stable (XDG + mise)
# - Provide a sane interactive default (prompt + colors)

if [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.sh" ]; then
  . "${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.sh"
  _shell_bootstrap_env
  unset -f _shell_bootstrap_env _shell_bootstrap_xdg_env _shell_bootstrap_mise_env \
    _shell_bootstrap_tool_env _shell_source_hm_session_vars _shell_detect_mise_environment \
    _shell_is_raspberry_pi _shell_path_prepend_existing
else
  : "${XDG_CONFIG_HOME:=$HOME/.config}"
  : "${XDG_CACHE_HOME:=$HOME/.cache}"
  : "${XDG_DATA_HOME:=$HOME/.local/share}"
  : "${XDG_STATE_HOME:=$HOME/.local/state}"
  export XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME

  : "${MISE_DATA_DIR:=$HOME/.mise}"
  : "${MISE_CACHE_DIR:=$MISE_DATA_DIR/cache}"
  : "${MISE_CONFIG_FILE:=$XDG_CONFIG_HOME/mise/config.default.toml}"
  export MISE_DATA_DIR MISE_CACHE_DIR MISE_CONFIG_FILE

  : "${GHQ_ROOT:=$HOME/src}"
  : "${RIPGREP_CONFIG_PATH:=$XDG_CONFIG_HOME/.ripgreprc}"
  : "${BUN_INSTALL:=$HOME/.bun}"
  : "${PNPM_HOME:=$HOME/.local/share/pnpm}"
  : "${NI_CONFIG_FILE:=$HOME/.config/nirc}"
  export GHQ_ROOT RIPGREP_CONFIG_PATH BUN_INSTALL PNPM_HOME NI_CONFIG_FILE
fi

# PATH (keep it simple; don't try to replicate zsh's path logic)
_path_prepend_once() {
  [ -n "$1" ] || return 0
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1:$PATH" ;;
  esac
}

_path_prepend_once "$HOME/bin"
_path_prepend_once "$HOME/.local/bin"
_path_prepend_once "$XDG_CONFIG_HOME/bin"
_path_prepend_once "$XDG_CONFIG_HOME/scripts"
[ -d "$HOME/.claude/local" ] && _path_prepend_once "$HOME/.claude/local"
export PATH
unset -f _path_prepend_once

# Activate mise if available
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi

_mise_promote_paths() {
  local mise_data_dir="${MISE_DATA_DIR:-$HOME/.mise}"
  local old_ifs="$IFS"
  local dir
  local mise_paths=""
  local other_paths=""

  IFS=:
  for dir in $PATH; do
    case "$dir" in
      "$mise_data_dir"/installs/* | "$mise_data_dir"/shims)
        case ":$mise_paths:" in
          *":$dir:"*) ;;
          *) mise_paths="${mise_paths:+$mise_paths:}$dir" ;;
        esac
        ;;
      *)
        case ":$other_paths:" in
          *":$dir:"*) ;;
          *) other_paths="${other_paths:+$other_paths:}$dir" ;;
        esac
        ;;
    esac
  done
  IFS="$old_ifs"

  PATH="${mise_paths}${mise_paths:+${other_paths:+:}}${other_paths}"
  export PATH
}
_mise_promote_paths
unset -f _mise_promote_paths

# ------------------------------------------------------------------------------
# Interactive-only settings
# ------------------------------------------------------------------------------
case $- in
  *i*) ;;
  *) return ;;
esac

# Enable color prompt for common terminals
case "${TERM:-}" in
  xterm-color | *-256color) color_prompt=yes ;;
esac

if [ "${color_prompt:-}" = yes ]; then
  PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
  PS1='\u@\h:\w\$ '
fi
unset color_prompt

# Enable color support of ls/grep if available
if command -v dircolors >/dev/null 2>&1; then
  if [ -r "$HOME/.dircolors" ]; then
    eval "$(dircolors -b "$HOME/.dircolors")"
  else
    eval "$(dircolors -b)"
  fi
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# Common aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# AI CLIs
alias cl='claude --dangerously-skip-permissions'
alias co='codex --yolo'
alias cz='ANTHROPIC_BASE_URL=https://api.z.ai/api/anthropic ANTHROPIC_AUTH_TOKEN="$ZAI_API_KEY" claude --dangerously-skip-permissions'

# Starship prompt (if available)
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi
