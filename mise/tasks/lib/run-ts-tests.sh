#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/../../.." && pwd)"
cd "${repo_root}"

QUIET=${QUIET:-0}

# Node test runner compatible test files.
node_test_files=()
while IFS= read -r file; do
  node_test_files+=("${file}")
done < <(fd --type f --glob "*.test.ts" agents/scripts scripts | sort -u)

if ((${#node_test_files[@]} > 0)); then
  echo "Running bun test suites (${#node_test_files[@]} files)..."
  if [[ "$QUIET" == "1" ]]; then
    if output=$(bun test "${node_test_files[@]}" 2>&1); then
      echo "✅ bun tests passed (${#node_test_files[@]} files)"
    else
      echo "$output"
      exit 1
    fi
  else
    bun test "${node_test_files[@]}"
  fi
else
  echo "No Node test runner suites found."
fi
