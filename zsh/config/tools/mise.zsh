# ========================================
# mise Activation Helper
# ========================================
# USAGE: Called by .zprofile (login) and .zshrc (non-login)
# TIMING: Requires MISE_* env vars from .zshenv
# ========================================

# Activate mise for PATH management (idempotent)
_mise_activate() {
  # Skip if already activated
  typeset -f mise > /dev/null && return 0

  # Find mise executable
  local mise_path=""
  if [[ -x /opt/homebrew/bin/mise ]]; then
    mise_path="/opt/homebrew/bin/mise"
  elif command -v mise &> /dev/null; then
    mise_path="$(command -v mise)"
  else
    return 1 # mise not found
  fi

  # Activate
  eval "$($mise_path activate zsh)"
  _mise_wrap_github_token
}

_mise_wrap_github_token() {
  (( $+functions[mise] )) || return 0
  (( $+functions[_mise_original] )) && return 0

  functions[_mise_original]=$functions[mise]

  mise() {
    case "$1" in
      update | upgrade)
        local command token
        command="$1"
        token="$(gh auth token)" || return
        shift
        MISE_GITHUB_TOKEN="$token" _mise_original "$command" "$@"
        ;;
      *)
        _mise_original "$@"
        ;;
    esac
  }
}

# ========================================
# mise Completion and Utilities
# ========================================

# Activate mise for non-login shells (login shells already activated in .zprofile)
# This is executed when config/tools/mise.zsh is sourced by config/loader.zsh in .zshrc
if [[ -o interactive && ! -o login ]]; then
  _mise_activate
fi

# Early return if mise is not available
command -v mise > /dev/null 2>&1 || return

# Shortcut for local CI
alias refresh="mise ci"

# Run `mise update`/`mise upgrade` with a GitHub token only for that invocation.
_mise_wrap_github_token

# Prefer the bundled completion file when available.
# Generating completions through `mise complete -s zsh` can block WSL login
# because it shells out to `mise x -- usage ...` on startup.
local bundled_mise_completion="${ZDOTDIR:-$HOME/.config/zsh}/completions/_mise"
if (( $+functions[_mise_hook] )) && [[ ! -r "$bundled_mise_completion" ]]; then
  if command -v usage > /dev/null 2>&1; then
    if (( $+functions[zsh-defer] )); then
      zsh-defer -t $MISE_COMPLETION_DEFER_SECONDS eval '$(mise complete -s zsh)'
    else
      eval "$(mise complete -s zsh)"
    fi
  fi
fi

# Utility functions for mise management
mise-status() {
  echo "🔧 mise Status Report"
  echo "━━━━━━━━━━━━━━━━━━━━"
  echo "Data directory: $MISE_DATA_DIR"
  echo "Cache directory: $MISE_CACHE_DIR"
  echo "Shims directory: $MISE_DATA_DIR/shims"
  echo ""
  echo "Active tools:"
  mise list --current 2> /dev/null || echo "No tools configured"
  echo ""
  echo "PATH status:"
  if [[ "$PATH" == *"$MISE_DATA_DIR/shims"* ]]; then
    echo "✅ mise shims in PATH"
  else
    echo "❌ mise shims not found in PATH"
  fi
}
