#!/bin/sh
set -eu

# ==============================================================================
# Environment Detection Script
# ==============================================================================
# Detects current environment type (CI/Pi/Default) following nix/env-detect.nix
# logic. Displays system information, environment variables, and mise config paths.
#
# Usage: sh ./scripts/env-detect.sh
# ==============================================================================

# Colors
if [ -t 1 ]; then
  BLUE='\033[0;34m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BOLD='\033[1m'
  NC='\033[0m' # No Color
else
  BLUE=''
  GREEN=''
  YELLOW=''
  BOLD=''
  NC=''
fi

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# ==============================================================================
# Header
# ==============================================================================

printf "\n"
printf "%b\n" "${BOLD}${BLUE}========================================${NC}"
printf "%b\n" "${BOLD}${BLUE}  Environment Detection${NC}"
printf "%b\n" "${BOLD}${BLUE}========================================${NC}"
printf "\n"

# ==============================================================================
# Environment Variables Check
# ==============================================================================

printf "%b\n" "${BOLD}Environment Variables:${NC}"
printf "  CI: %s\n" "${CI:-not set}"
printf "  GITHUB_ACTIONS: %s\n" "${GITHUB_ACTIONS:-not set}"
printf "  MISE_CONFIG_FILE: %s\n" "${MISE_CONFIG_FILE:-not set}"
printf "\n"

# ==============================================================================
# System Information
# ==============================================================================

printf "%b\n" "${BOLD}System Information:${NC}"
printf "  Architecture: %s\n" "$(uname -m)"
printf "  OS: %s\n" "$(uname -s)"

if [ -f /proc/cpuinfo ]; then
  CPUINFO_MODEL=$(grep -m 1 "Model" /proc/cpuinfo 2>/dev/null || echo "N/A")
  CPUINFO_HARDWARE=$(grep -m 1 "Hardware" /proc/cpuinfo 2>/dev/null || echo "N/A")
  printf "  CPU Model: %s\n" "$CPUINFO_MODEL"
  printf "  Hardware: %s\n" "$CPUINFO_HARDWARE"
else
  printf "  /proc/cpuinfo: not available (non-Linux)\n"
fi
printf "\n"

# ==============================================================================
# Environment Type Detection
# ==============================================================================
# Follows zsh/config/tools/mise-env.zsh logic: CI > Pi > Default

is_raspberry_pi() {
  # 1. Check architecture (ARM only)
  ARCH=$(uname -m)
  case "$ARCH" in
    aarch64 | armv7l | armv6l)
      # Continue to device detection
      ;;
    *)
      return 1
      ;;
  esac

  # 2. Check /sys/firmware/devicetree/base/model (preferred method)
  # Note: This file may contain NUL bytes, so we strip them before matching
  if [ -r /sys/firmware/devicetree/base/model ]; then
    MODEL=$(tr -d '\000' </sys/firmware/devicetree/base/model 2>/dev/null)
    case "$MODEL" in
      *"Raspberry Pi"*)
        return 0
        ;;
    esac
  fi

  # 3. Fallback: Check /proc/cpuinfo
  if [ -r /proc/cpuinfo ]; then
    CPUINFO=$(cat /proc/cpuinfo)
    case "$CPUINFO" in
      *"Raspberry Pi"* | *"BCM27"* | *"BCM283"*)
        return 0
        ;;
    esac
  fi

  return 1
}

ENV_TYPE="default"
ENV_COLOR=$GREEN

# Priority: CI > Pi > Default
if [ -n "${CI:-}" ] || [ -n "${GITHUB_ACTIONS:-}" ]; then
  ENV_TYPE="ci"
  ENV_COLOR=$YELLOW
elif is_raspberry_pi; then
  ENV_TYPE="pi"
  ENV_COLOR=$BLUE
fi

# ==============================================================================
# Detection Result
# ==============================================================================

printf "%b\n" "${BOLD}Detected Environment:${NC}"
printf "  %b%s%b\n" "${ENV_COLOR}${BOLD}" "$ENV_TYPE" "${NC}"
printf "\n"

# ==============================================================================
# Mise Configuration
# ==============================================================================

EXPECTED_CONFIG="$CONFIG_HOME/mise/config.$ENV_TYPE.toml"
printf "%b\n" "${BOLD}Mise Configuration:${NC}"
printf "  Expected: %s\n" "$EXPECTED_CONFIG"

if [ -f "$EXPECTED_CONFIG" ]; then
  printf "  %bStatus: ✓ File exists%b\n" "$GREEN" "$NC"
else
  printf "  %bStatus: ✗ File not found%b\n" "$YELLOW" "$NC"
fi
printf "\n"

# ==============================================================================
# Detection Explanation
# ==============================================================================

printf "%b\n" "${BOLD}Detection Logic (Priority: CI > Pi > Default):${NC}"

if [ -n "${CI:-}" ] || [ -n "${GITHUB_ACTIONS:-}" ]; then
  printf "  1. CI: ✓ Matched\n"
else
  printf "  1. CI: ✗ Not matched\n"
fi

if [ "$ENV_TYPE" = "pi" ]; then
  printf "  2. Raspberry Pi: ✓ Matched (ARM + Raspberry Pi markers)\n"
else
  printf "  2. Raspberry Pi: ✗ Not matched\n"
fi

if [ "$ENV_TYPE" = "default" ]; then
  printf "  3. Default: ✓ Fallback (WSL2/macOS/Linux)\n"
else
  printf "  3. Default: ○ Not used\n"
fi
printf "\n"
