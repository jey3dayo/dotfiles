#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/../../.." && pwd)"
cd "${repo_root}"

# Ensure required dependency exists.
if ! command -v fd >/dev/null 2>&1; then
  echo "❌ fd not found. Please install fd (https://github.com/sharkdp/fd)"
  exit 1
fi

# Node test runner compatible test files.
mapfile -t node_test_files < <(
  fd --type f --glob "*.test.ts" --exclude "replace-bold-headings.test.ts" agents/scripts scripts | sort -u
)

if ((${#node_test_files[@]} > 0)); then
  echo "Running Node test runner suites (${#node_test_files[@]} files)..."
  tsx --test "${node_test_files[@]}"
else
  echo "No Node test runner suites found."
fi

# Keep backward compatibility for script-style tests.
legacy_tests=(
  "scripts/replace-bold-headings.test.ts"
  "agents/scripts/replace-bold-headings.test.ts"
)

for legacy_test in "${legacy_tests[@]}"; do
  if [[ -f "${legacy_test}" ]]; then
    echo "Running legacy TS test: ${legacy_test}"
    tsx "${legacy_test}"
  fi
done
