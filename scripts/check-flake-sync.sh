#!/bin/sh
set -eu

# ==============================================================================
# Flake Inputs / Agent-Skills-Sources Sync Check
# ==============================================================================
# Verifies that flake.nix inputs and nix/agent-skills-sources.nix are in sync.
#
# Checks:
#   1. Every source in agent-skills-sources.nix exists in flake.nix inputs
#   2. Every agent-skills input in flake.nix exists in agent-skills-sources.nix
#   3. URLs match between the two files
#
# Exit codes:
#   0 - All checks passed
#   1 - Sync issues found
#
# Usage: sh ./scripts/check-flake-sync.sh
# ==============================================================================

# Resolve project root (directory containing flake.nix)
SCRIPT_DIR=$(dirname "$0")
PROJECT_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)

FLAKE_NIX="$PROJECT_ROOT/flake.nix"
SOURCES_NIX="$PROJECT_ROOT/nix/agent-skills-sources.nix"

# Colors (disabled when not connected to a terminal)
if [ -t 1 ]; then
  GREEN='\033[0;32m'
  RED='\033[0;31m'
  BOLD='\033[1m'
  NC='\033[0m'
else
  GREEN=''
  RED=''
  BOLD=''
  NC=''
fi

# Temp files for extracted data
FLAKE_DATA=$(mktemp)
SOURCES_DATA=$(mktemp)
trap 'rm -f "$FLAKE_DATA" "$SOURCES_DATA"' EXIT

# ==============================================================================
# Extract from flake.nix: name=url pairs between marker comments
# ==============================================================================
extract_flake_inputs() {
  # Extract the block between marker comments, then parse name + url pairs.
  # Attribute lines match "name = {" (opening a block), not "key = value;".
  awk '
    /^[[:space:]]*# Agent-skills external sources/  { in_block = 1; next }
    /^[[:space:]]*# END Agent-skills external sources/ { in_block = 0; next }
    in_block && /= \{[[:space:]]*$/ {
      n = $0
      gsub(/^[[:space:]]+/, "", n)
      gsub(/[[:space:]]*=.*/, "", n)
      name = n
    }
    in_block && /url[[:space:]]*=/ {
      split($0, parts, "\"")
      url = parts[2]
      if (name != "" && url != "") {
        print name "=" url
        name = ""
        url = ""
      }
    }
  ' "$FLAKE_NIX" | sort
}

# ==============================================================================
# Extract from agent-skills-sources.nix: name=url pairs
# ==============================================================================
extract_sources() {
  # Parse top-level attribute names and their url values
  awk '
    # Top-level attribute: lines like "  openai-skills = {"
    # Must be at indent level 2 (2 spaces), not deeper
    /^  [a-zA-Z][a-zA-Z0-9_-]* = \{/ {
      gsub(/^[[:space:]]+/, "")
      gsub(/[[:space:]]*=.*/, "")
      name = $0
    }
    # URL line inside an attribute block
    /url[[:space:]]*=/ && name != "" {
      split($0, parts, "\"")
      url = parts[2]
      if (url != "") {
        print name "=" url
        name = ""
      }
    }
  ' "$SOURCES_NIX" | sort
}

# ==============================================================================
# Main
# ==============================================================================

printf "%b\n" "${BOLD}Checking flake.nix <-> agent-skills-sources.nix sync...${NC}"
printf "\n"

extract_flake_inputs > "$FLAKE_DATA"
extract_sources > "$SOURCES_DATA"

flake_count=$(wc -l < "$FLAKE_DATA" | tr -d ' ')
sources_count=$(wc -l < "$SOURCES_DATA" | tr -d ' ')

printf "  flake.nix inputs:             %d sources\n" "$flake_count"
printf "  agent-skills-sources.nix:     %d sources\n" "$sources_count"
printf "\n"

errors=0

# --- Check 1: sources.nix entries missing from flake.nix ---
while IFS='=' read -r name url; do
  if ! grep -q "^${name}=" "$FLAKE_DATA"; then
    printf "%b\n" "${RED}  Missing in flake.nix: ${BOLD}${name}${NC}${RED} (url: ${url})${NC}"
    errors=$((errors + 1))
  fi
done < "$SOURCES_DATA"

# --- Check 2: flake.nix entries missing from sources.nix ---
while IFS='=' read -r name url; do
  if ! grep -q "^${name}=" "$SOURCES_DATA"; then
    printf "%b\n" "${RED}  Missing in agent-skills-sources.nix: ${BOLD}${name}${NC}${RED} (url: ${url})${NC}"
    errors=$((errors + 1))
  fi
done < "$FLAKE_DATA"

# --- Check 3: URL mismatches ---
while IFS='=' read -r name flake_url; do
  sources_line=$(grep "^${name}=" "$SOURCES_DATA" 2>/dev/null || true)
  if [ -n "$sources_line" ]; then
    sources_url="${sources_line#*=}"
    if [ "$flake_url" != "$sources_url" ]; then
      printf "%b\n" "${RED}  URL mismatch for ${BOLD}${name}${NC}${RED}:${NC}"
      printf "%b\n" "${RED}    flake.nix:                ${flake_url}${NC}"
      printf "%b\n" "${RED}    agent-skills-sources.nix: ${sources_url}${NC}"
      errors=$((errors + 1))
    fi
  fi
done < "$FLAKE_DATA"

# --- Result ---
printf "\n"
if [ "$errors" -gt 0 ]; then
  printf "%b\n" "${RED}${BOLD}FAILED: ${errors} sync issue(s) found${NC}"
  printf "\n"
  printf "  To fix, ensure both files define the same sources with identical URLs.\n"
  printf "  SSoT is nix/agent-skills-sources.nix; sync changes to flake.nix inputs.\n"
  printf "\n"
  exit 1
else
  printf "%b\n" "${GREEN}${BOLD}PASSED: flake.nix and agent-skills-sources.nix are in sync${NC}"
  printf "\n"
fi
