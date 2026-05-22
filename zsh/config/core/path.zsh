# PATH utility functions
# Interactive PATH setup is centralized in config/core/interactive-path.zsh.
# These functions are for debugging and optimization

# PATH optimization utility function
path-check() {
  emulate -L zsh
  local -a path_entries=("${path[@]}")
  local -a unique_entries=("${(u)path_entries[@]}")
  local -A seen
  local -a duplicates missing
  local dir

  print -r -- "🔍 PATH Analysis"
  print -r -- "━━━━━━━━━━━━━━━━━━━"
  print -r -- "Total entries: ${#path_entries}"
  print -r -- "Unique entries: ${#unique_entries}"

  for dir in "${path_entries[@]}"; do
    (( seen[$dir]++ ))
    if (( seen[$dir] == 2 )); then
      duplicates+=("$dir")
    fi
  done

  if (( ${#duplicates[@]} )); then
    print -r -- "⚠️  Duplicates found:"
    printf '%s\n' "${duplicates[@]}"
  else
    print -r -- "✅ No duplicates"
  fi

  # Check for potentially missing directories (skip mise paths as they're dynamic)
  for dir in "${path_entries[@]}"; do
    [[ $dir == *".mise"* ]] && continue
    [[ -z "$dir" ]] && dir="."
    [[ -d "$dir" ]] || missing+=("$dir")
  done

  if (( ${#missing[@]} )); then
    print -r -- "❌ Missing directories:"
    printf '  %s\n' "${missing[@]}"
  else
    print -r -- "✅ All paths exist"
  fi
}

# Quick system check function
zsh-quick-check() {
  emulate -L zsh
  local -a path_entries=("${path[@]}")
  local -a function_names=("${(k)functions[@]}")
  local -a alias_names=("${(k)aliases[@]}")
  local -A seen
  local -a duplicates
  local dir tool

  for dir in "${path_entries[@]}"; do
    (( seen[$dir]++ ))
    if (( seen[$dir] == 2 )); then
      duplicates+=("$dir")
    fi
  done

  print -r -- "🚀 Zsh Quick System Check"
  print -r -- "━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Performance indicators
  print -r -- "📊 Performance:"
  print -r -- "  Functions loaded: ${#function_names[@]}"
  print -r -- "  Aliases defined: ${#alias_names[@]}"

  # PATH status
  print -r -- ""
  print -r -- "🛤️  PATH Status:"
  print -r -- "  Total entries: ${#path_entries}"
  print -r -- "  Duplicates: ${#duplicates[@]}"

  # Tool availability
  print -r -- ""
  print -r -- "🔧 Key Tools:"
  local tools=(git fzf mise sheldon starship)
  for tool in "${tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
      print -r -- "  ✅ $tool"
    else
      print -r -- "  ❌ $tool (not found)"
    fi
  done

  # Memory usage (approximate)
  local pid=$$
  local mem=$(ps -o rss= -p "$pid" 2>/dev/null | tr -d ' ')
  if [[ -n "$mem" ]]; then
    print -r -- ""
    print -r -- "💾 Memory: ${mem}KB"
  else
    print -r -- ""
    print -r -- "💾 Memory: N/A"
  fi
}
