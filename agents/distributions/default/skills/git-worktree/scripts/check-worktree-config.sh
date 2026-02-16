#!/bin/bash

# Git Worktree Configuration Diagnostic Tool
# Version: 1.0.0

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Symbols
CHECK="✓"
CROSS="✗"
INFO="ℹ"
WARN="⚠"

echo -e "${BLUE}=== Git Worktree Configuration Diagnostic ===${NC}\n"

# Check if in git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo -e "${RED}${CROSS} Not in a git repository${NC}"
  exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
echo -e "${GREEN}${CHECK} Repository: $REPO_ROOT${NC}\n"

# Function to check config value
check_config() {
  local key=$1
  local expected=$2
  local scope=$3

  local value
  if [ "$scope" = "local" ]; then
    value=$(git config --local "$key" 2>/dev/null || echo "")
  elif [ "$scope" = "global" ]; then
    value=$(git config --global "$key" 2>/dev/null || echo "")
  else
    value=$(git config "$key" 2>/dev/null || echo "")
  fi

  if [ -n "$value" ]; then
    if [ -n "$expected" ] && [ "$value" != "$expected" ]; then
      echo -e "${YELLOW}${WARN} $key = $value (expected: $expected)${NC}"
    else
      echo -e "${GREEN}${CHECK} $key = $value${NC}"
    fi

    # Show origin
    local origin
    origin=$(git config --show-origin "$key" 2>/dev/null | awk '{print $1}')
    echo -e "  ${INFO} Origin: $origin"
  else
    if [ -n "$expected" ]; then
      echo -e "${YELLOW}${WARN} $key not set (expected: $expected)${NC}"
    else
      echo -e "${INFO} $key not set${NC}"
    fi
  fi
}

echo -e "${BLUE}--- Git-wt Configuration (wt.*) ---${NC}\n"

# Check wt.basedir
check_config "wt.basedir" ".worktrees" ""

# Check wt.nameTemplate
check_config "wt.nameTemplate" "" ""

# Check wt.copyFiles
check_config "wt.copyFiles" "" ""

# Check wt.autoSetupRemote
check_config "wt.autoSetupRemote" "" ""

# Check wt.hooks.enabled
check_config "wt.hooks.enabled" "" ""

echo ""
echo -e "${BLUE}--- Git Worktree Configuration (worktree.*) ---${NC}\n"

# Check worktree.guessRemote
check_config "worktree.guessRemote" "" ""

echo ""
echo -e "${BLUE}--- git-wt Installation ---${NC}\n"

# Check if git-wt is installed
if command -v git-wt &>/dev/null; then
  GIT_WT_VERSION=$(git-wt --version 2>&1 | head -n1)
  echo -e "${GREEN}${CHECK} git-wt installed: $GIT_WT_VERSION${NC}"

  # Check PATH
  GIT_WT_PATH=$(which git-wt)
  echo -e "  ${INFO} Location: $GIT_WT_PATH"
else
  echo -e "${RED}${CROSS} git-wt not found in PATH${NC}"
  echo -e "  ${INFO} Install with: mise install go:github.com/k1LoW/git-wt@latest"
fi

echo ""
echo -e "${BLUE}--- Directory Structure ---${NC}\n"

# Check basedir
BASEDIR=$(git config wt.basedir 2>/dev/null || echo ".worktrees")

if [ -d "$REPO_ROOT/$BASEDIR" ]; then
  echo -e "${GREEN}${CHECK} Base directory exists: $BASEDIR/${NC}"

  # Count worktrees
  WORKTREE_COUNT=$(find "$REPO_ROOT/$BASEDIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
  echo -e "  ${INFO} Worktrees: $WORKTREE_COUNT"
else
  echo -e "${YELLOW}${WARN} Base directory does not exist: $BASEDIR/${NC}"
  echo -e "  ${INFO} Will be created when first worktree is added"
fi

# Check ignore files
echo ""
echo -e "${BLUE}--- Ignore Files ---${NC}\n"

check_ignore_file() {
  local file=$1
  local pattern=$2

  if [ -f "$REPO_ROOT/$file" ]; then
    if grep -q "^$pattern" "$REPO_ROOT/$file" 2>/dev/null; then
      echo -e "${GREEN}${CHECK} $file contains '$pattern'${NC}"
    else
      echo -e "${YELLOW}${WARN} $file missing '$pattern'${NC}"
      echo -e "  ${INFO} Add: echo '$pattern' >> $file"
    fi
  else
    echo -e "${INFO} $file not found${NC}"
  fi
}

check_ignore_file ".gitignore" "$BASEDIR/"
check_ignore_file ".fdignore" "$BASEDIR/"
check_ignore_file ".prettierignore" "$BASEDIR/"

# Check mise config (if exists)
if [ -f "$REPO_ROOT/mise.toml" ] || [ -f "$REPO_ROOT/.mise.toml" ]; then
  MISE_CONFIG=$([ -f "$REPO_ROOT/mise.toml" ] && echo "mise.toml" || echo ".mise.toml")

  if grep -q "$BASEDIR" "$REPO_ROOT/$MISE_CONFIG" 2>/dev/null; then
    echo -e "${GREEN}${CHECK} $MISE_CONFIG excludes '$BASEDIR'${NC}"
  else
    echo -e "${YELLOW}${WARN} $MISE_CONFIG may not exclude '$BASEDIR'${NC}"
    echo -e "  ${INFO} Consider adding exclusion if needed"
  fi
fi

echo ""
echo -e "${BLUE}--- Active Worktrees ---${NC}\n"

# List active worktrees
if git worktree list >/dev/null 2>&1; then
  WORKTREES=$(git worktree list 2>/dev/null)
  WORKTREE_COUNT=$(echo "$WORKTREES" | wc -l)

  if [ "$WORKTREE_COUNT" -gt 1 ]; then
    echo -e "${GREEN}${CHECK} Active worktrees: $((WORKTREE_COUNT - 1))${NC}"
    echo ""
    echo "$WORKTREES" | tail -n +2 | while read -r line; do
      echo -e "  • $line"
    done
  else
    echo -e "${INFO} No additional worktrees (only main repository)${NC}"
  fi
else
  echo -e "${RED}${CROSS} Failed to list worktrees${NC}"
fi

echo ""
echo -e "${BLUE}--- Hook Configuration ---${NC}\n"

# Check hooks
check_hook() {
  local hook=$1
  local path="$REPO_ROOT/.git/hooks/$hook"

  if [ -f "$path" ]; then
    if [ -x "$path" ]; then
      echo -e "${GREEN}${CHECK} $hook exists and is executable${NC}"
    else
      echo -e "${YELLOW}${WARN} $hook exists but not executable${NC}"
      echo -e "  ${INFO} Fix: chmod +x $path"
    fi

    # Show first few lines
    echo -e "  ${INFO} First line: $(head -n 2 "$path" | tail -n 1)"
  else
    echo -e "${INFO} $hook not configured${NC}"
  fi
}

check_hook "post-worktree-add"
check_hook "post-worktree-remove"

echo ""
echo -e "${BLUE}--- Zsh Integration ---${NC}\n"

# Check Zsh functions (if using Zsh)
if [ -n "$ZSH_VERSION" ]; then
  if type gwt &>/dev/null; then
    echo -e "${GREEN}${CHECK} Zsh function 'gwt' loaded${NC}"
  else
    echo -e "${YELLOW}${WARN} Zsh function 'gwt' not found${NC}"
    echo -e "  ${INFO} Check: ~/.config/zsh/config/tools/git.zsh"
  fi

  if type gwts &>/dev/null; then
    echo -e "${GREEN}${CHECK} Zsh function 'gwts' (switch) loaded${NC}"
  else
    echo -e "${YELLOW}${WARN} Zsh function 'gwts' not found${NC}"
  fi

  if type gwtc &>/dev/null; then
    echo -e "${GREEN}${CHECK} Zsh function 'gwtc' (create) loaded${NC}"
  else
    echo -e "${INFO} Zsh function 'gwtc' not found${NC}"
  fi
else
  echo -e "${INFO} Not running in Zsh (integration checks skipped)${NC}"
fi

echo ""
echo -e "${BLUE}--- Recommendations ---${NC}\n"

RECOMMENDATIONS=()

# Check basedir consistency
BASEDIR_CONFIG=$(git config wt.basedir 2>/dev/null || echo "")
if [ -z "$BASEDIR_CONFIG" ]; then
  RECOMMENDATIONS+=("Set wt.basedir: git config --local wt.basedir \".worktrees\"")
fi

# Check if .worktree (singular) is used instead of .worktrees (plural)
if [ "$BASEDIR" = ".worktree" ]; then
  RECOMMENDATIONS+=("Consider using '.worktrees' (plural) for consistency with this repository's conventions")
fi

# Check autoSetupRemote
AUTO_SETUP=$(git config wt.autoSetupRemote 2>/dev/null || echo "")
if [ -z "$AUTO_SETUP" ]; then
  RECOMMENDATIONS+=("Enable auto-setup remote: git config --local wt.autoSetupRemote true")
fi

# Check if git-wt is not installed
if ! command -v git-wt &>/dev/null; then
  RECOMMENDATIONS+=("Install git-wt: mise install go:github.com/k1LoW/git-wt@latest")
fi

# Check hooks
if [ ! -x "$REPO_ROOT/.git/hooks/post-worktree-add" ] && [ -f "$REPO_ROOT/.git/hooks/post-worktree-add" ]; then
  RECOMMENDATIONS+=("Make hook executable: chmod +x .git/hooks/post-worktree-add")
fi

if [ ! -x "$REPO_ROOT/.git/hooks/post-worktree-remove" ] && [ -f "$REPO_ROOT/.git/hooks/post-worktree-remove" ]; then
  RECOMMENDATIONS+=("Make hook executable: chmod +x .git/hooks/post-worktree-remove")
fi

if [ ${#RECOMMENDATIONS[@]} -eq 0 ]; then
  echo -e "${GREEN}${CHECK} Configuration looks good!${NC}"
else
  echo -e "${YELLOW}${WARN} Consider the following improvements:${NC}\n"
  for i in "${!RECOMMENDATIONS[@]}"; do
    echo -e "  $((i + 1)). ${RECOMMENDATIONS[$i]}"
  done
fi

echo ""
echo -e "${BLUE}=== Diagnostic Complete ===${NC}"
