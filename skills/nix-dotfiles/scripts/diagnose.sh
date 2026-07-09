#!/usr/bin/env bash
# Nix Dotfiles Diagnostic Script
# Checks Home Manager integration: generation, symlinks, worktree

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check 1: Generation Verification
check_generation() {
  echo -n "Checking Home Manager generation... "

  # Get latest generation
  local latest_gen
  if ! latest_gen=$(home-manager generations 2>/dev/null | head -1); then
    echo -e "${RED}[✗]${NC} Generation check: home-manager not found or no generations"
    return 1
  fi

  if [ -z "$latest_gen" ]; then
    echo -e "${RED}[✗]${NC} Generation check: No generations found"
    return 1
  fi

  # Extract generation path
  local gen_path
  gen_path=$(echo "$latest_gen" | awk '{print $NF}')

  # Check if .claude exists in generation
  if find "$gen_path/home-files/" -path "*claude*" -print -quit 2>/dev/null | grep -q .; then
    echo -e "${GREEN}[✓]${NC} Generation check: .claude found in latest generation"

    # Check generation age (warning if older than 24h)
    local gen_time
    gen_time=$(echo "$latest_gen" | awk '{print $1, $2}')
    local gen_epoch
    gen_epoch=$(date -d "$gen_time" +%s 2>/dev/null || echo 0)
    local now_epoch
    now_epoch=$(date +%s)
    local age_hours=$(((now_epoch - gen_epoch) / 3600))

    if [ "$age_hours" -gt 24 ]; then
      echo -e "  ${YELLOW}⚠${NC}  Warning: Generation is $age_hours hours old"
    fi

    return 0
  else
    echo -e "${RED}[✗]${NC} Generation check: .claude not found in generation"
    echo "    Generation path: $gen_path"
    return 1
  fi
}

# Check 2: Symlink Verification
check_symlinks() {
  echo -n "Checking symlinks... "

  local all_passed=true

  # Check ~/.config/result
  if [ -L "$HOME/.config/result" ]; then
    local result_target
    result_target=$(readlink "$HOME/.config/result")
    echo -e "${GREEN}[✓]${NC} Symlink check: ~/.config/result -> $result_target"
  else
    echo -e "${RED}[✗]${NC} Symlink check: ~/.config/result is not a symlink"
    all_passed=false
  fi

  if $all_passed; then
    return 0
  else
    return 1
  fi
}

# Check 3: Worktree Detection
check_worktree() {
  echo -n "Checking worktree detection... "

  # Check environment variable
  if [ -n "${DOTFILES_WORKTREE:-}" ]; then
    if [ -d "$DOTFILES_WORKTREE" ]; then
      echo -e "${GREEN}[✓]${NC} Worktree check: DOTFILES_WORKTREE=$DOTFILES_WORKTREE"
      return 0
    else
      echo -e "${RED}[✗]${NC} Worktree check: DOTFILES_WORKTREE set but directory not found"
      return 1
    fi
  fi

  # Check default candidates
  local candidates=(
    "$HOME/.config"
    "$HOME/src/github.com/$USER/dotfiles"
    "$HOME/src/dotfiles"
    "$HOME/dotfiles"
  )

  local found=false
  for candidate in "${candidates[@]}"; do
    if [ -d "$candidate" ] \
      && [ -f "$candidate/flake.nix" ] \
      && [ -f "$candidate/home.nix" ] \
      && [ -f "$candidate/nix/dotfiles-module.nix" ]; then
      echo -e "${GREEN}[✓]${NC} Worktree check: Found at $candidate"
      found=true
      break
    fi
  done

  if ! $found; then
    echo -e "${YELLOW}[⚠]${NC} Worktree check: No valid worktree found in default candidates"
    echo "    Set DOTFILES_WORKTREE environment variable if using custom path"
    return 1
  fi

  return 0
}

# Main execution
main() {
  echo "=== Nix Dotfiles Diagnostic ==="
  echo ""

  local all_passed=true

  if ! check_generation; then
    all_passed=false
  fi
  echo ""

  if ! check_symlinks; then
    all_passed=false
  fi
  echo ""

  if ! check_worktree; then
    all_passed=false
  fi
  echo ""

  echo "=== Summary ==="
  if $all_passed; then
    echo -e "${GREEN}All checks passed ✓${NC}"
    exit 0
  else
    echo -e "${RED}Some checks failed. See details above.${NC}"
    echo ""
    echo "Quick fixes:"
    echo "  - Generation issue: home-manager switch --flake ~/.config --impure"
    echo "  - Worktree: Set DOTFILES_WORKTREE=/path/to/dotfiles"
    exit 1
  fi
}

main
