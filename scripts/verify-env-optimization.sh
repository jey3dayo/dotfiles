#!/usr/bin/env bash
# Verification script for shell/env.sh fork reduction optimization
# Usage: ./scripts/verify-env-optimization.sh

set -euo pipefail

echo "=== Shell Environment Optimization Verification ==="
echo

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test function to count process launches during env.sh sourcing
count_forks() {
  local shell_cmd="$1"
  local env_file="$2"
  local test_name="$3"

  echo -e "${BLUE}Testing: ${test_name}${NC}"

  # Create a wrapper script that sources env.sh and calls the bootstrap
  local wrapper=$(mktemp)
  cat >"$wrapper" <<'EOF'
source "$1"
_shell_bootstrap_env
EOF

  # Use strace (Linux) or dtruss (macOS) to count execve calls
  local fork_count=0
  if command -v strace >/dev/null 2>&1; then
    # Linux: count execve syscalls
    fork_count=$(strace -c -e execve "$shell_cmd" "$wrapper" "$env_file" 2>&1 |
      awk '/execve/ {print $4}' || echo "0")
  elif command -v dtruss >/dev/null 2>&1; then
    # macOS: count execve calls (requires sudo)
    echo "  Note: dtruss requires sudo on macOS"
    fork_count=$(sudo dtruss -c "$shell_cmd" "$wrapper" "$env_file" 2>&1 |
      awk '/execve/ {print $1}' || echo "0")
  else
    echo "  Warning: Neither strace nor dtruss available. Using ps-based estimation."
    # Fallback: run with ps monitoring (less accurate)
    "$shell_cmd" "$wrapper" "$env_file" >/dev/null 2>&1
    fork_count="N/A"
  fi

  rm -f "$wrapper"
  echo "  Fork count: $fork_count"
  echo
}

# Test 1: Verify shell built-in variables work correctly
echo -e "${BLUE}Test 1: Verify architecture detection${NC}"
echo "Testing bash MACHTYPE extraction..."
bash -c 'echo "  MACHTYPE=$MACHTYPE"; arch="${MACHTYPE%%-*}"; echo "  Extracted: $arch"'

if command -v zsh >/dev/null 2>&1; then
  echo "Testing zsh CPUTYPE..."
  zsh -c 'echo "  CPUTYPE=$CPUTYPE"'
fi

echo

# Test 2: Verify OSTYPE detection for macOS
echo -e "${BLUE}Test 2: Verify OS detection${NC}"
bash -c 'case "${OSTYPE:-}" in darwin*) echo "  ✓ macOS detected via OSTYPE=$OSTYPE" ;; *) echo "  ✓ Not macOS: OSTYPE=$OSTYPE" ;; esac'
echo

# Test 3: Compare exported variables before and after
echo -e "${BLUE}Test 3: Compare environment variables${NC}"
echo "Sourcing env.sh and exporting variables..."

bash -c '
  source shell/env.sh
  _shell_bootstrap_env
  
  echo "Key variables set:"
  echo "  XDG_CONFIG_HOME=$XDG_CONFIG_HOME"
  echo "  MISE_CONFIG_FILE=$MISE_CONFIG_FILE"
  echo "  MISE_ENV=$MISE_ENV"
  echo "  MISE_DATA_DIR=$MISE_DATA_DIR"
'

if command -v zsh >/dev/null 2>&1; then
  echo
  echo "Testing with zsh..."
  zsh -c '
    source shell/env.sh
    _shell_bootstrap_env
    
    echo "Key variables set:"
    echo "  XDG_CONFIG_HOME=$XDG_CONFIG_HOME"
    echo "  MISE_CONFIG_FILE=$MISE_CONFIG_FILE"
    echo "  MISE_ENV=$MISE_ENV"
    echo "  MISE_DATA_DIR=$MISE_DATA_DIR"
  '
fi

echo

# Test 4: Verify _shell_detect_mise_environment function behavior
echo -e "${BLUE}Test 4: Verify mise environment detection${NC}"
bash -c '
  source shell/env.sh
  
  # Test normal case
  _shell_detect_mise_environment
  echo "  Default: __mise_environment=$__mise_environment"
  unset __mise_environment
  
  # Test CI case
  CI=1 _shell_detect_mise_environment
  echo "  CI mode: __mise_environment=$__mise_environment"
  unset __mise_environment
'

echo

# Test 5: Actual fork count comparison (if git allows)
if git rev-parse HEAD~1 >/dev/null 2>&1; then
  echo -e "${BLUE}Test 5: Fork count comparison (before vs after)${NC}"
  echo "Comparing fork counts between old and new versions..."

  # Save current version
  cp shell/env.sh /tmp/env-new.sh

  # Get old version
  git show HEAD~1:shell/env.sh >/tmp/env-old.sh 2>/dev/null || {
    echo "  Note: Could not retrieve previous version for comparison"
  }

  if [ -f /tmp/env-old.sh ]; then
    echo
    echo "Before optimization:"
    count_forks bash /tmp/env-old.sh "bash (old)"

    echo "After optimization:"
    count_forks bash /tmp/env-new.sh "bash (new)"

    rm -f /tmp/env-old.sh /tmp/env-new.sh
  fi
fi

# Test 6: Timing test (rough measure)
echo -e "${BLUE}Test 6: Startup timing (5 iterations each)${NC}"

time_test() {
  local shell_cmd="$1"
  local iterations=5

  echo "Timing $shell_cmd startup ($iterations iterations)..."
  local total=0
  for i in $(seq 1 "$iterations"); do
    local start=$(date +%s%N 2>/dev/null || echo "0")
    "$shell_cmd" -c 'source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.sh"; _shell_bootstrap_env' >/dev/null 2>&1
    local end=$(date +%s%N 2>/dev/null || echo "0")
    if [ "$start" != "0" ] && [ "$end" != "0" ]; then
      local duration=$(((end - start) / 1000000))
      total=$((total + duration))
      echo "  Run $i: ${duration}ms"
    fi
  done
  if [ "$total" -gt 0 ]; then
    echo "  Average: $((total / iterations))ms"
  fi
  echo
}

time_test bash
if command -v zsh >/dev/null 2>&1; then
  time_test zsh
fi

echo -e "${GREEN}=== Verification Complete ===${NC}"
echo
echo "Expected improvements:"
echo "  • 3 fewer forks on macOS (2x uname, 1x command substitution)"
echo "  • 2 fewer forks on Linux non-Pi (1x uname for Darwin check, 1x command substitution)"
echo "  • Raspberry Pi detection still works (has fallback uname)"
echo
echo "To test on the actual Mac:"
echo "  1. Run: time zsh -i -c exit"
echo "  2. Compare with ZSH_LOAD_PLUGINS=1: time ZSH_LOAD_PLUGINS=1 zsh -i -c exit"
echo "  3. Check env diff: bash -c 'source shell/env.sh; _shell_bootstrap_env; env | sort' > /tmp/env-test"
