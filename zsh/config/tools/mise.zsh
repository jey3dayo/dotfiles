export MISE_DATA_DIR=$HOME/.mise
export MISE_CACHE_DIR=$MISE_DATA_DIR/cache

if ! command -v mise >/dev/null 2>&1; then
  return
fi

# Use deferred completion for optimal startup performance
# mise is activated via shims in .zprofile for zero per-prompt overhead
if (( $+functions[zsh-defer] )); then
  zsh-defer -t 8 eval "$(mise complete -s zsh)"
else
  eval "$(mise complete -s zsh)"
fi

# Utility functions for mise management
mise-status() {
  echo "🔧 mise Status Report"
  echo "━━━━━━━━━━━━━━━━━━━━"
  echo "Data directory: $MISE_DATA_DIR"
  echo "Cache directory: $MISE_CACHE_DIR"
  echo "Shims directory: $HOME/.local/share/mise/shims"
  echo ""
  echo "Active tools:"
  mise list --current 2>/dev/null || echo "No tools configured"
  echo ""
  echo "PATH status:"
  if [[ "$PATH" == *".local/share/mise/shims"* ]]; then
    echo "✅ mise shims in PATH"
  else
    echo "❌ mise shims not found in PATH"
  fi
}
