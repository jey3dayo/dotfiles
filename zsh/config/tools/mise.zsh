command -v mise >/dev/null 2>&1 || return

# Shortcut for local CI
alias refresh="mise ci"
# Activation is handled in .zprofile (login shell)。ここでは補完・ユーティリティのみ。
# 非ログインシェルで未活性の場合はスキップして早期リターン。
(( $+functions[_mise_hook] )) || return

# Defer only the completion for startup performance
if command -v usage >/dev/null 2>&1; then
  if (( $+functions[zsh-defer] )); then
    zsh-defer -t $MISE_COMPLETION_DEFER_SECONDS eval "$(mise complete -s zsh)"
  else
    eval "$(mise complete -s zsh)"
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
  mise list --current 2>/dev/null || echo "No tools configured"
  echo ""
  echo "PATH status:"
  if [[ "$PATH" == *"$MISE_DATA_DIR/shims"* ]]; then
    echo "✅ mise shims in PATH"
  else
    echo "❌ mise shims not found in PATH"
  fi
}
