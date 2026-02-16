#!/bin/sh
set -eu

# ==============================================================================
# Skills Distribution Check Script
# ==============================================================================
# Verifies skills distribution from Home Manager:
# - Counts skills in ~/.claude/skills/
# - Compares with expected minimum (≥42 internal skills)
# - Checks symlink integrity
# - Displays Home Manager generation information
#
# Usage: sh ./scripts/skills-check.sh
# ==============================================================================

# Colors
if [ -t 1 ]; then
  BLUE='\033[0;34m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  RED='\033[0;31m'
  BOLD='\033[1m'
  NC='\033[0m' # No Color
else
  BLUE=''
  GREEN=''
  YELLOW=''
  RED=''
  BOLD=''
  NC=''
fi

SKILLS_DIR="$HOME/.claude/skills"
EXPECTED_MIN_SKILLS=42 # skills-internal/ の最小数

# ==============================================================================
# Header
# ==============================================================================

printf "\n"
printf "%b\n" "${BOLD}${BLUE}========================================${NC}"
printf "%b\n" "${BOLD}${BLUE}  Skills Distribution Check${NC}"
printf "%b\n" "${BOLD}${BLUE}========================================${NC}"
printf "\n"

# ==============================================================================
# Check Skills Directory
# ==============================================================================

if [ ! -d "$SKILLS_DIR" ]; then
  printf "%b\n" "${RED}✗ Skills directory not found: $SKILLS_DIR${NC}"
  printf "\n"
  printf "%b\n" "${BOLD}Action Required:${NC}"
  printf "  Run: %bhome-manager switch --flake ~/.config --impure%b\n" "$YELLOW" "$NC"
  printf "\n"
  exit 1
fi

# ==============================================================================
# Count Skills
# ==============================================================================

# Exclude .system, include both directories and symlinks
SKILLS_COUNT=$(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 ! -name ".system" 2>/dev/null | wc -l | tr -d ' ')

printf "%b\n" "${BOLD}Skills Count:${NC}"
printf "  Total: %d skills\n" "$SKILLS_COUNT"
printf "  Expected: ≥ %d skills (internal)\n" "$EXPECTED_MIN_SKILLS"

STATUS_FAILED=0
if [ "$SKILLS_COUNT" -lt "$EXPECTED_MIN_SKILLS" ]; then
  printf "  %bStatus: ✗ Insufficient skills (%d < %d)%b\n" "$RED$BOLD" "$SKILLS_COUNT" "$EXPECTED_MIN_SKILLS" "$NC"
  STATUS_FAILED=1
else
  printf "  %bStatus: ✓ Sufficient skills (%d ≥ %d)%b\n" "$GREEN$BOLD" "$SKILLS_COUNT" "$EXPECTED_MIN_SKILLS" "$NC"
fi
printf "\n"

# ==============================================================================
# Home Manager Generation Info
# ==============================================================================

printf "%b\n" "${BOLD}Home Manager Generation:${NC}"
LATEST_GEN=$(home-manager generations 2>/dev/null | sed -n '1p')

if [ -n "$LATEST_GEN" ]; then
  GEN_ID=$(printf "%s\n" "$LATEST_GEN" | sed -n 's/.* id \([0-9][0-9]*\) -> .*/\1/p')
  GEN_DATE=$(printf "%s\n" "$LATEST_GEN" | awk '{print $1, $2}')
  GEN_PATH=$(printf "%s\n" "$LATEST_GEN" | sed 's/^.* -> //; s/ (current)$//')
  printf "  ID: %s\n" "$GEN_ID"
  printf "  Date: %s\n" "$GEN_DATE"
  printf "  Path: %s\n" "$GEN_PATH"

  # Check if generation includes agent-skills
  if [ -d "$GEN_PATH/home-files/.claude/skills" ]; then
    GEN_SKILLS_COUNT=$(find "$GEN_PATH/home-files/.claude/skills" -mindepth 1 -maxdepth 1 ! -name ".system" 2>/dev/null | wc -l | tr -d ' ')
    printf "  Skills in generation: %d\n" "$GEN_SKILLS_COUNT"
    if [ "$GEN_SKILLS_COUNT" -eq "$SKILLS_COUNT" ]; then
      printf "  %bGeneration match: ✓ Consistent%b\n" "$GREEN" "$NC"
    else
      printf "  %bGeneration match: ✗ Inconsistent (%d vs %d)%b\n" "$YELLOW" "$GEN_SKILLS_COUNT" "$SKILLS_COUNT" "$NC"
    fi
  else
    printf "  %bGeneration: ✗ No skills found in generation%b\n" "$RED" "$NC"
  fi
else
  printf "  %bGeneration: ✗ Not available%b\n" "$RED" "$NC"
fi
printf "\n"

# ==============================================================================
# Symlink Integrity Check
# ==============================================================================

printf "%b\n" "${BOLD}Symlink Integrity:${NC}"
BROKEN_LINKS=0
VALID_LINKS=0

for skill_dir in "$SKILLS_DIR"/*; do
  [ -e "$skill_dir" ] || [ -L "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")

  # Skip .system
  [ "$skill_name" = ".system" ] && continue

  if [ -L "$skill_dir" ]; then
    target=$(readlink "$skill_dir")
    link_dir=$(dirname "$skill_dir")
    case "$target" in
      /*) resolved_target="$target" ;;
      *) resolved_target="$link_dir/$target" ;;
    esac

    if [ -d "$resolved_target" ]; then
      VALID_LINKS=$((VALID_LINKS + 1))
    else
      BROKEN_LINKS=$((BROKEN_LINKS + 1))
      printf "  %b✗ Broken: %s → %s%b\n" "$RED" "$skill_name" "$resolved_target" "$NC"
    fi
  else
    printf "  %b⚠ Not a symlink: %s%b\n" "$YELLOW" "$skill_name" "$NC"
  fi
done

printf "  Valid symlinks: %d\n" "$VALID_LINKS"
printf "  Broken symlinks: %d\n" "$BROKEN_LINKS"

if [ "$BROKEN_LINKS" -gt 0 ]; then
  printf "  %bStatus: ✗ Broken symlinks found%b\n" "$RED$BOLD" "$NC"
  STATUS_FAILED=1
else
  printf "  %bStatus: ✓ All symlinks valid%b\n" "$GREEN$BOLD" "$NC"
fi
printf "\n"

# ==============================================================================
# Summary
# ==============================================================================

printf "%b\n" "${BOLD}Summary:${NC}"
if [ "$STATUS_FAILED" -eq 1 ]; then
  printf "  %b✗ Skills distribution check FAILED%b\n" "$RED$BOLD" "$NC"
  printf "\n"
  printf "%b\n" "${BOLD}Troubleshooting:${NC}"
  printf "  1. Check if Home Manager was applied correctly:\n"
  printf "     %bhome-manager switch --flake ~/.config --impure%b\n" "$YELLOW" "$NC"
  printf "\n"
  printf "  2. Verify skills configuration:\n"
  printf "     %bmise run skills:list%b\n" "$YELLOW" "$NC"
  printf "\n"
  printf "  3. Check for conflicts with other Home Manager configurations:\n"
  printf "     %bhome-manager generations | head -3%b\n" "$YELLOW" "$NC"
  printf "\n"
  printf "  4. See troubleshooting guide:\n"
  printf "     %bcat ~/.config/.claude/rules/troubleshooting.md%b\n" "$YELLOW" "$NC"
  printf "\n"
  exit 1
else
  printf "  %b✓ Skills distribution check PASSED%b\n" "$GREEN$BOLD" "$NC"
  printf "\n"
fi
