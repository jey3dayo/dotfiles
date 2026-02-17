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
# Derive repository root from script location (works regardless of clone path)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_ROOT="$REPO_ROOT"
GITLEAKS_IGNORE="$CONFIG_ROOT/.gitleaksignore"
GITLEAKS_CONFIG="$CONFIG_ROOT/.gitleaks.toml"

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

write_gitleaksignore_header() {
  {
    printf '%s\n' '# Gitleaks Ignore File'
    printf '%s\n' '# Fingerprint-only format: one fingerprint per line.'
    printf '%s\n' '# Generate/update with: sh ./scripts/setup-gitleaks.sh --create-baseline'
    printf '%s\n' '# Path-based exclusions must be defined in .gitleaks.toml [allowlist].paths.'
  } >"$GITLEAKS_IGNORE"
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

run_gitleaks_detect() {
  if [ -f "$GITLEAKS_CONFIG" ]; then
    gitleaks detect --no-git --config "$GITLEAKS_CONFIG" "$@"
  else
    gitleaks detect --no-git "$@"
  fi
}

create_baseline() {
  print_info "Creating fingerprint baseline file..."

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

  cd "$CONFIG_ROOT" || exit 1

  baseline_tmp=$(mktemp "${TMPDIR:-/tmp}/gitleaks-baseline.XXXXXX")
  baseline_log=$(mktemp "${TMPDIR:-/tmp}/gitleaks-baseline-log.XXXXXX")

  if run_gitleaks_detect \
    --report-format json \
    --report-path "$baseline_tmp" >"$baseline_log" 2>&1; then
    scan_status=0
  else
    scan_status=$?
  fi

  if [ "$scan_status" -eq 0 ]; then
    write_gitleaksignore_header
    print_success "No secrets found - baseline not needed"
    rm -f "$baseline_tmp" "$baseline_log"
    return 0
  fi

  if [ ! -s "$baseline_tmp" ]; then
    print_error "Failed to create baseline report"
    sed -n '1,20p' "$baseline_log" >&2
    rm -f "$baseline_tmp" "$baseline_log"
    return 1
  fi

  sed -n 's/.*"Fingerprint"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$baseline_tmp" \
    | awk 'NF { if (!seen[$0]++) print $0 }' >"$GITLEAKS_IGNORE"
  rm -f "$baseline_tmp" "$baseline_log"

  if [ -s "$GITLEAKS_IGNORE" ]; then
    print_success "Baseline created: $GITLEAKS_IGNORE"
  else
    print_warning "Baseline file not created - manual review recommended"
  fi
}

run_initial_scan() {
  print_info "Running initial gitleaks scan..."
  cd "$CONFIG_ROOT" || exit 1

  scan_log=$(mktemp "${TMPDIR:-/tmp}/gitleaks-scan-log.XXXXXX")
  if run_gitleaks_detect --verbose >"$scan_log" 2>&1; then
    scan_status=0
  else
    scan_status=$?
  fi

  tail -20 "$scan_log"
  rm -f "$scan_log"

  if [ "$scan_status" -eq 0 ]; then
    print_success "No secrets detected"
  else
    print_warning "Potential secrets detected"
    print_info "Review findings above and update $GITLEAKS_IGNORE if needed"
    print_info "Run: sh ./scripts/setup-gitleaks.sh --create-baseline"
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
        printf "  --create-baseline  Create .gitleaksignore fingerprint baseline\n"
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
