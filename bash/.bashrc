# bash entrypoint (tracked)
# - Keep environment setup stable (XDG + mise)
# - Provide a sane interactive default (prompt + colors)

# XDG base directories
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
export XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME

# mise data/cache directories (must be set before mise activation)
: "${MISE_DATA_DIR:=$HOME/.mise}"
: "${MISE_CACHE_DIR:=$MISE_DATA_DIR/cache}"
export MISE_DATA_DIR MISE_CACHE_DIR

# mise config file is set by Home Manager (hm-session-vars.sh)
# Environment detection: CI > Raspberry Pi > Default (WSL2/macOS/Linux)
if [ -z "${DOTFILES_HM_SESSION_VARS_LOADED:-}" ]; then
  if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
    # shellcheck disable=SC1090,SC1091
    . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    export DOTFILES_HM_SESSION_VARS_LOADED=1
  elif [ -f "$HOME/.config/home-manager/home-manager.sh" ]; then
    # shellcheck disable=SC1090,SC1091
    . "$HOME/.config/home-manager/home-manager.sh"
    export DOTFILES_HM_SESSION_VARS_LOADED=1
  fi
fi

# Basic env vars used across tools
export GHQ_ROOT=~/src
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/.ripgreprc"
export PNPM_HOME="$HOME/.local/share/pnpm"
export NI_CONFIG_FILE="$HOME/.config/nirc"

# PATH (keep it simple; don't try to replicate zsh's path logic)
case ":$PATH:" in
  *":$HOME/bin:"*) ;;
  *) PATH="$HOME/bin:$PATH" ;;
 esac
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
 esac
case ":$PATH:" in
  *":$XDG_CONFIG_HOME/scripts:"*) ;;
  *) PATH="$XDG_CONFIG_HOME/scripts:$PATH" ;;
 esac
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) PATH="$PNPM_HOME:$PATH" ;;
 esac
case ":$PATH:" in
  *":$HOME/.claude/local:"*) ;;
  *) [ -d "$HOME/.claude/local" ] && PATH="$HOME/.claude/local:$PATH" ;;
 esac
export PATH

# Activate mise if available
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi

# ------------------------------------------------------------------------------
# Interactive-only settings
# ------------------------------------------------------------------------------
case $- in
  *i*) ;;
  *) return ;;
 esac

# Enable color prompt for common terminals
case "${TERM:-}" in
  xterm-color|*-256color) color_prompt=yes ;;
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

# Starship prompt (if available)
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi
