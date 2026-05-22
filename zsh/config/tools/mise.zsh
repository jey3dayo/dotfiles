# ========================================
# mise Activation Helper
# ========================================
# USAGE: Loaded from .zshrc for interactive login and non-login shells.
# TIMING: Requires MISE_* env vars from .zshenv
# ========================================

_mise_prepare_path() {
  [[ -r "${ZDOTDIR:-$HOME/.config/zsh}/config/core/interactive-path.zsh" ]] || return
  source "${ZDOTDIR:-$HOME/.config/zsh}/config/core/interactive-path.zsh"
  (( $+functions[_dotfiles_setup_interactive_path] )) && _dotfiles_setup_interactive_path
  unfunction _dotfiles_setup_interactive_path 2> /dev/null
}

_mise_find_binary() {
  if [[ -x /opt/homebrew/bin/mise ]]; then
    print -r -- /opt/homebrew/bin/mise
  elif command -v mise > /dev/null 2>&1; then
    command -v mise
  else
    return 1
  fi
}

_mise_activate() {
  # Skip if already activated
  if typeset -f mise > /dev/null; then
    _mise_promote_paths
    return 0
  fi

  local mise_path
  mise_path="$(_mise_find_binary)" || return

  eval "$($mise_path activate zsh)"
  _mise_promote_paths
  _mise_wrap_github_token
}

_mise_promote_paths() {
  local mise_data_dir="${MISE_DATA_DIR:-$HOME/.mise}"
  local -a mise_paths other_paths
  local dir

  for dir in "${path[@]}"; do
    case "$dir" in
      "$mise_data_dir"/installs/* | "$mise_data_dir"/shims) mise_paths+=("$dir") ;;
      *) other_paths+=("$dir") ;;
    esac
  done

  path=("${mise_paths[@]}" "${other_paths[@]}")
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

# Interactive shells source this file through the tool loader. Prepare PATH here
# before activating mise so non-login shells get the same baseline as login
# shells, and login shells normalize any later PATH changes before activation.
if [[ -o interactive ]]; then
  _mise_prepare_path
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
