#!/bin/sh
set -eu

# ==============================================================================
# Bootstrap Script - Homebrew Installation for Dotfiles
# ==============================================================================
# This script prepares a fresh macOS system for dotfiles installation by:
# - Installing Homebrew if not present
# - Detecting system architecture (Apple Silicon vs Intel)
# - Validating prerequisites (macOS, git, zsh, curl)
# - Setting up brew command in current session
#
# Usage: sh ./bootstrap.sh
# ==============================================================================

# Constants
HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

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
  printf "%b\n" "${BOLD}${BLUE}  Dotfiles Bootstrap${NC}"
  printf "%b\n" "${BOLD}${BLUE}========================================${NC}"
  printf "\n"
  printf "This script will install Homebrew if not present.\n"
  printf "%b\n" "It will ${BOLD}NOT${NC} modify any existing configurations."
  printf "\n"
}

print_status() {
  printf "%b %s\n" "${BLUE}[INFO]${NC}" "$1"
}

print_success() {
  printf "%b %s\n" "${GREEN}[✓]${NC}" "$1"
}

print_error() {
  printf "%b %s\n" "${RED}[ERROR]${NC}" "$1" >&2
}

print_warning() {
  printf "%b %s\n" "${YELLOW}[WARN]${NC}" "$1"
}

# ==============================================================================
# Prerequisite Checks
# ==============================================================================

check_prerequisites() {
  print_status "Checking prerequisites..."

  # Check macOS
  if [ "$(uname -s)" != "Darwin" ]; then
    print_error "This script is designed for macOS only."
    print_error "Detected OS: $(uname -s)"
    exit 1
  fi
  print_success "macOS detected"

  # Check git
  if ! command -v git > /dev/null 2>&1; then
    print_error "git is not installed."
    print_error "Please install Xcode Command Line Tools first:"
    print_error "  xcode-select --install"
    exit 1
  fi
  print_success "git found: $(command -v git)"

  # Check zsh
  if ! command -v zsh > /dev/null 2>&1; then
    print_error "zsh is not installed."
    print_error "Please install zsh via Homebrew or system package manager."
    exit 1
  fi
  print_success "zsh found: $(command -v zsh)"

  # Check curl
  if ! command -v curl > /dev/null 2>&1; then
    print_error "curl is not installed."
    print_error "curl is required to download Homebrew installer."
    exit 1
  fi
  print_success "curl found: $(command -v curl)"

  printf "\n"
}

# ==============================================================================
# Architecture Detection
# ==============================================================================

detect_architecture() {
  print_status "Detecting system architecture..."

  ARCH=$(uname -m)
  case "$ARCH" in
    arm64 | aarch64)
      HOMEBREW_PREFIX="/opt/homebrew"
      print_success "Apple Silicon detected (${ARCH})"
      ;;
    x86_64)
      HOMEBREW_PREFIX="/usr/local"
      print_success "Intel Mac detected (${ARCH})"
      ;;
    *)
      print_error "Unsupported architecture: ${ARCH}"
      print_error "This script supports only arm64 (Apple Silicon) and x86_64 (Intel)."
      exit 1
      ;;
  esac

  print_status "Homebrew prefix: ${HOMEBREW_PREFIX}"
  printf "\n"

  export HOMEBREW_PREFIX
}

# ==============================================================================
# Homebrew Installation Check
# ==============================================================================

check_homebrew_installed() {
  # Check if brew command is available
  if command -v brew > /dev/null 2>&1; then
    return 0
  fi

  # Check if brew binary exists at expected location
  if [ -x "${HOMEBREW_PREFIX}/bin/brew" ]; then
    # brew exists but not in PATH, add it to current session
    print_warning "Homebrew found at ${HOMEBREW_PREFIX}/bin/brew, adding to PATH..."
    eval "$("${HOMEBREW_PREFIX}/bin/brew" shellenv)"
    return 0
  fi

  # Homebrew not found
  return 1
}

# ==============================================================================
# Homebrew Installation
# ==============================================================================

install_homebrew() {
  print_status "Homebrew not found. Installing Homebrew..."
  printf "\n"

  # Confirm installation
  printf "%b" "${YELLOW}Do you want to install Homebrew now? (y/N):${NC} "
  read -r response
  case "$response" in
    [yY][eE][sS] | [yY]) ;;
    *)
      print_error "Homebrew installation cancelled."
      print_error "Please install Homebrew manually:"
      print_error "  /bin/bash -c \"\$(curl -fsSL ${HOMEBREW_INSTALL_URL})\""
      exit 1
      ;;
  esac

  printf "\n"
  print_status "Running Homebrew installation script..."
  print_status "This may take several minutes and will prompt for your password."
  printf "\n"

  # Run Homebrew installer
  if /bin/bash -c "$(curl -fsSL "${HOMEBREW_INSTALL_URL}")"; then
    print_success "Homebrew installed successfully"
  else
    print_error "Homebrew installation failed"
    print_error "Please check the error messages above and try again."
    print_error "Or install Homebrew manually from: https://brew.sh"
    exit 1
  fi

  printf "\n"

  # Add brew to current session PATH
  if [ -x "${HOMEBREW_PREFIX}/bin/brew" ]; then
    print_status "Adding Homebrew to current session PATH..."
    eval "$("${HOMEBREW_PREFIX}/bin/brew" shellenv)"
    export PATH="${HOMEBREW_PREFIX}/bin:${PATH}"
  else
    print_error "Homebrew binary not found at ${HOMEBREW_PREFIX}/bin/brew"
    print_error "Installation may have failed. Please check and retry."
    exit 1
  fi

  # Verify installation
  if ! command -v brew > /dev/null 2>&1; then
    print_error "brew command not available after installation"
    print_error "Please restart your terminal and try again."
    exit 1
  fi

  print_success "Homebrew is now available in current session"
  print_status "Version: $(brew --version | head -n 1)"
  printf "\n"
}

# ==============================================================================
# Next Steps Display
# ==============================================================================

show_next_steps() {
  printf "%b\n" "${BOLD}${GREEN}========================================${NC}"
  printf "%b\n" "${BOLD}${GREEN}  Bootstrap Complete!${NC}"
  printf "%b\n" "${BOLD}${GREEN}========================================${NC}"
  printf "\n"

  printf "%b\n" "${BOLD}Next Steps:${NC}"
  printf "\n"

  printf "%b\n" "${BOLD}${BLUE}1.${NC} ${BOLD}Configure Git identity${NC} (required):"
  printf "%b\n" "   ${YELLOW}cat > ~/.gitconfig_local << EOF"
  printf "   [user]\n"
  printf "       name = Your Name\n"
  printf "       email = your.email@example.com\n"
  printf "%b\n" "   EOF${NC}"
  printf "\n"

  printf "%b\n" "${BOLD}${BLUE}2.${NC} ${BOLD}Install Nix and Home Manager${NC}:"
  printf "%b\n" "   ${YELLOW}# Install Nix (if not already installed)"
  printf "%b\n" "   sh <(curl -L https://nixos.org/nix/install) --daemon${NC}"
  printf "%b\n" "   ${YELLOW}# Apply dotfiles via Home Manager"
  printf "%b\n" "   home-manager switch --flake . --impure${NC}"
  printf "\n"

  printf "%b\n" "${BOLD}${BLUE}3.${NC} ${BOLD}Install Homebrew packages${NC}:"
  printf "%b\n" "   ${YELLOW}brew bundle${NC}"
  printf "\n"

  printf "%b\n" "${BOLD}${BLUE}4.${NC} ${BOLD}Restart shell${NC}:"
  printf "%b\n" "   ${YELLOW}exec zsh${NC}"
  printf "\n"

  printf "%b\n" "${BOLD}${BLUE}5.${NC} ${BOLD}Verify installation${NC}:"
  printf "%b\n" "   ${YELLOW}zsh-help${NC}"
  printf "%b\n" "   ${YELLOW}zsh-help tools${NC}"
  printf "\n"

  printf "%b\n" "${BOLD}📚 Detailed Documentation:${NC}"
  printf "   %s/docs/setup.md\n" "$(pwd)"
  printf "\n"
}

# ==============================================================================
# Main Execution
# ==============================================================================

main() {
  print_header

  # Phase 1: Prerequisites
  check_prerequisites

  # Phase 2: Architecture detection
  detect_architecture

  # Phase 3: Homebrew installation
  print_status "Checking Homebrew installation..."
  if check_homebrew_installed; then
    print_success "Homebrew is already installed"
    print_status "Version: $(brew --version | head -n 1)"
    printf "\n"
  else
    install_homebrew
  fi

  # Phase 4: Next steps
  show_next_steps

  exit 0
}

# Entry point
main "$@"
