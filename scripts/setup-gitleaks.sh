#!/bin/sh
set -eu

# ==============================================================================
# Gitleaks Setup Script - Security Scanning Configuration
# ==============================================================================
# This script configures gitleaks for pre-commit hooks:
# - Validates gitleaks installation
# - Creates baseline ignore file for false positives
# - Runs initial security scan
# - Reinstalls pre-commit hooks
#
# Usage: sh ./scripts/setup-gitleaks.sh [--create-baseline]
# ==============================================================================

# Constants
CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}"
GITLEAKS_IGNORE="$CONFIG_ROOT/.gitleaksignore"

# Color codes (if terminal supports it)
if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  BOLD='\033[1m'
  NC='\033[0m' # No Color
else
  RED=''
  GREEN=''
  YELLOW=''
  BLUE=''
  BOLD=''
  NC=''
fi

# ==============================================================================
# Helper Functions
# ==============================================================================

print_header() {
  printf "\n"
  printf "%b\n" "${BOLD}${BLUE}========================================${NC}"
  printf "%b\n" "${BOLD}${BLUE}  Gitleaks Setup${NC}"
  printf "%b\n" "${BOLD}${BLUE}========================================${NC}"
  printf "\n"
}

print_info() {
  printf "%b\n" "${BLUE}ℹ${NC}  $1"
}

print_success() {
  printf "%b\n" "${GREEN}✓${NC}  $1"
}

print_warning() {
  printf "%b\n" "${YELLOW}⚠${NC}  $1"
}

print_error() {
  printf "%b\n" "${RED}✗${NC}  $1" >&2
}

# ==============================================================================
# Validation Functions
# ==============================================================================

check_gitleaks() {
  if ! command -v gitleaks >/dev/null 2>&1; then
    print_error "gitleaks is not installed"
    print_info "Install with: brew install gitleaks"
    exit 1
  fi
  print_success "gitleaks is installed ($(gitleaks version))"
}

check_precommit() {
  if ! command -v pre-commit >/dev/null 2>&1; then
    print_error "pre-commit is not installed"
    print_info "Install with: brew install pre-commit"
    exit 1
  fi
  print_success "pre-commit is installed ($(pre-commit --version))"
}

# ==============================================================================
# Setup Functions
# ==============================================================================

create_baseline() {
  print_info "Creating baseline ignore file..."

  if [ -f "$GITLEAKS_IGNORE" ]; then
    print_warning "Baseline file already exists: $GITLEAKS_IGNORE"
    printf "Overwrite? (y/N): "
    read -r response
    case "$response" in
      [yY][eE][sS] | [yY])
        rm "$GITLEAKS_IGNORE"
        ;;
      *)
        print_info "Skipping baseline creation"
        return 0
        ;;
    esac
  fi

  # Run gitleaks to detect all current findings and create baseline
  cd "$CONFIG_ROOT" || exit 1

  if gitleaks detect --no-git --report-path /dev/null 2>/dev/null; then
    print_success "No secrets found - baseline not needed"
  else
    print_info "Found potential secrets - creating baseline..."
    # Create baseline from current findings
    gitleaks detect --no-git --baseline-path "$GITLEAKS_IGNORE" --report-format json --report-path /dev/null 2>/dev/null || true
    if [ -f "$GITLEAKS_IGNORE" ]; then
      print_success "Baseline created: $GITLEAKS_IGNORE"
    else
      print_warning "Baseline file not created - manual review recommended"
    fi
  fi
}

run_initial_scan() {
  print_info "Running initial gitleaks scan..."
  cd "$CONFIG_ROOT" || exit 1

  if gitleaks detect --no-git --verbose 2>&1 | tail -20; then
    print_success "No secrets detected"
  else
    print_warning "Potential secrets detected"
    print_info "Review findings above and update $GITLEAKS_IGNORE if needed"
    print_info "Run: gitleaks detect --no-git --baseline-path $GITLEAKS_IGNORE"
  fi
}

reinstall_hooks() {
  print_info "Reinstalling pre-commit hooks..."
  cd "$CONFIG_ROOT" || exit 1

  if pre-commit install; then
    print_success "Pre-commit hooks reinstalled"
  else
    print_error "Failed to reinstall pre-commit hooks"
    exit 1
  fi

  # Update hooks to latest versions
  print_info "Updating pre-commit hook versions..."
  if pre-commit autoupdate; then
    print_success "Hook versions updated"
  else
    print_warning "Failed to update hook versions"
  fi
}

test_hook() {
  print_info "Testing gitleaks hook..."
  cd "$CONFIG_ROOT" || exit 1

  if pre-commit run gitleaks --all-files; then
    print_success "Gitleaks hook test passed"
  else
    print_warning "Gitleaks hook detected issues"
    print_info "Review findings and update baseline if needed"
  fi
}

# ==============================================================================
# Main
# ==============================================================================

main() {
  print_header

  # Parse arguments
  CREATE_BASELINE=false
  for arg in "$@"; do
    case "$arg" in
      --create-baseline)
        CREATE_BASELINE=true
        ;;
      --help | -h)
        printf "Usage: %s [--create-baseline]\n" "$0"
        printf "\n"
        printf "Options:\n"
        printf "  --create-baseline  Create .gitleaksignore baseline file\n"
        printf "  --help, -h         Show this help message\n"
        exit 0
        ;;
      *)
        print_error "Unknown option: $arg"
        exit 1
        ;;
    esac
  done

  # Validation
  check_gitleaks
  check_precommit

  # Setup
  if [ "$CREATE_BASELINE" = true ]; then
    create_baseline
  fi

  run_initial_scan
  reinstall_hooks
  test_hook

  # Summary
  printf "\n"
  printf "%b\n" "${BOLD}${GREEN}========================================${NC}"
  printf "%b\n" "${BOLD}${GREEN}  Gitleaks Setup Complete${NC}"
  printf "%b\n" "${BOLD}${GREEN}========================================${NC}"
  printf "\n"
  print_info "Gitleaks will now scan for secrets on every commit"
  print_info "To bypass (not recommended): git commit --no-verify"
  print_info "To update baseline: sh ./scripts/setup-gitleaks.sh --create-baseline"
  printf "\n"
}

main "$@"
