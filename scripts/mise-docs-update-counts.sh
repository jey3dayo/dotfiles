#!/usr/bin/env bash

set -euo pipefail

brew_count=$(grep -c '^brew ' Brewfile || true)
cask_count=$(grep -c '^cask ' Brewfile || true)
mise_count=$(grep -c '^[[:alnum:]_][[:alnum:]_]*[[:space:]]*=' mise/config.default.toml || true)

echo "=== Current Tool Counts ==="
echo "Homebrew: $brew_count formulae + $cask_count casks"
echo "mise: $mise_count tools"
echo
echo "Update the following line in .claude/rules/tools/tool-install-policy.md:"
echo "**Current state**: $brew_count formulae + $cask_count casks (as of $(date +%Y-%m-%d))"
