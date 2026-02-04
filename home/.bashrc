# Minimal bash setup to avoid errors when using bash.
# Keep bash config lightweight; zsh remains the primary shell.

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

# mise config file selection based on environment
if [ -f "${XDG_CONFIG_HOME}/scripts/setup-mise-env.sh" ]; then
  # shellcheck disable=SC1090
  . "${XDG_CONFIG_HOME}/scripts/setup-mise-env.sh"
fi

# Basic env vars used across tools
export GHQ_ROOT=~/src
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/.ripgreprc"
export PNPM_HOME="$HOME/.local/share/pnpm"
export NI_CONFIG_FILE="$HOME/.config/nirc"
export CODEX_CONFIG="$HOME/.config/codex/config.yaml"

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
export PATH

# Activate mise if available
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi
