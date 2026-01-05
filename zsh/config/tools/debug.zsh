# Debug and profiling tools (development only)

if [[ -n "$ZSH_DEBUG" ]]; then
  typeset -gr ZSH_DEBUG_BENCHMARK_RUNS=5
  typeset -gr ZSH_DEBUG_PROFILE_TOP_COUNT=20

  zmodload zsh/zprof

  # Benchmark shell startup time
  zsh-benchmark() {
    echo "🔍 Benchmarking zsh startup time..."
    echo ""
    for (( i = 1; i <= ZSH_DEBUG_BENCHMARK_RUNS; i++ )); do
      echo "Run $i:"
      time (zsh -i -c exit)
      echo ""
    done
  }

  # Show zsh profiling information
  zsh-profile() {
    echo "📊 Zsh Profile Information (top ${ZSH_DEBUG_PROFILE_TOP_COUNT}):"
    echo ""
    zprof | head -${ZSH_DEBUG_PROFILE_TOP_COUNT}
  }

  # Clear zsh profiling data
  zsh-profile-clear() {
    zprof -c
    echo "🗑️  Zsh profiling data cleared"
  }

  # Show startup debug information
  zsh-debug-info() {
    echo "🐛 Zsh Debug Information:"
    echo ""
    echo "ZSH Version: $ZSH_VERSION"
    echo "Shell Options:"
    setopt | grep -E "(EXTENDED_GLOB|AUTO_CD|HIST_|COMPLETE_)"
    echo ""
    echo "Loaded Modules:"
    zmodload | sort
    echo ""
    echo "Function Count: $(typeset -f | grep -c '^[a-zA-Z_-].*() {')"
    echo "Alias Count: $(alias | wc -l)"
    if command -v abbr >/dev/null 2>&1; then
      echo "Abbreviation Count: $(abbr -S | wc -l)"
    fi
  }

  # Monitor file loading times
  zsh-load-monitor() {
    echo "📁 File Loading Monitor:"
    echo ""
    echo "Use with: ZSH_DEBUG=1 exec zsh"
    echo "Then check zprof output for slow loading files"
  }

  echo "🐛 Debug mode enabled. Available commands:"
  echo "  zsh-benchmark    - Measure startup time"
  echo "  zsh-profile      - Show profiling data"
  echo "  zsh-profile-clear - Clear profiling data"
  echo "  zsh-debug-info   - Show debug information"
  echo "  zsh-load-monitor - Monitor file loading"
fi
