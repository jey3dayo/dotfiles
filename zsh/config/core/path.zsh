# Re-prioritize mise shims (may have been reordered by plugins)
# User paths ($HOME/bin, etc.) are already set in .zshenv
path=(
  $HOME/.mise/shims(N-)
  $path
)

# Add Homebrew to end of PATH (for brew command availability and starship)
# Placed after mise shims to ensure mise-managed tools take priority
if [[ "$(arch)" == arm64 ]]; then
  path+=(/opt/homebrew/bin(N-))
  path+=(/opt/homebrew/sbin(N-))
else
  path+=(/usr/local/bin(N-))
  path+=(/usr/local/sbin(N-))
fi

# PATH optimization utility function
path-check() {
  echo "🔍 PATH Analysis"
  echo "━━━━━━━━━━━━━━━━━━━"
  echo "Total entries: $(echo $PATH | tr ':' '\n' | wc -l | tr -d ' ')"
  echo "Unique entries: $(echo $PATH | tr ':' '\n' | sort -u | wc -l | tr -d ' ')"

  local duplicates=$(echo $PATH | tr ':' '\n' | sort | uniq -d)
  if [[ -n "$duplicates" ]]; then
    echo "⚠️  Duplicates found:"
    echo "$duplicates"
  else
    echo "✅ No duplicates"
  fi

  # Check for potentially missing directories (skip mise paths as they're dynamic)
  local missing=0
  for dir in $(echo $PATH | tr ':' '\n' | grep -v '\.mise'); do
    if [[ ! -d "$dir" ]]; then
      [[ $missing -eq 0 ]] && echo "❌ Missing directories:"
      echo "  $dir"
      ((missing++))
    fi
  done
  [[ $missing -eq 0 ]] && echo "✅ All paths exist"
}

# Quick system check function
zsh-quick-check() {
  echo "🚀 Zsh Quick System Check"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Performance indicators
  echo "📊 Performance:"
  echo "  Functions loaded: $(typeset -f | grep '^[a-zA-Z]' | wc -l | tr -d ' ')"
  echo "  Aliases defined: $(alias | wc -l | tr -d ' ')"

  # PATH status
  echo "\n🛤️  PATH Status:"
  echo "  Total entries: $(echo $PATH | tr ':' '\n' | wc -l | tr -d ' ')"
  echo "  Duplicates: $(echo $PATH | tr ':' '\n' | sort | uniq -d | wc -l | tr -d ' ')"

  # Tool availability
  echo "\n🔧 Key Tools:"
  local tools=(git fzf mise sheldon starship)
  for tool in $tools; do
    if command -v $tool >/dev/null 2>&1; then
      echo "  ✅ $tool"
    else
      echo "  ❌ $tool (not found)"
    fi
  done

  # Memory usage (approximate)
  local pid=$$
  local mem=$(ps -o rss= -p $pid 2>/dev/null | tr -d ' ')
  [[ -n "$mem" ]] && echo "\n💾 Memory: ${mem}KB" || echo "\n💾 Memory: N/A"
}
