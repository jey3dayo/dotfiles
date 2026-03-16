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
done < <(fd --type f --glob "*.test.ts" --exclude "replace-bold-headings.test.ts" agents/scripts scripts | sort -u)

if ((${#node_test_files[@]} > 0)); then
  echo "Running Node test runner suites (${#node_test_files[@]} files)..."
  if [[ "$QUIET" == "1" ]]; then
    if output=$(tsx --test "${node_test_files[@]}" 2>&1); then
      echo "✅ Node tests passed (${#node_test_files[@]} files)"
    else
      echo "$output"
      exit 1
    fi
  else
    tsx --test "${node_test_files[@]}"
  fi
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
    if [[ "$QUIET" == "1" ]]; then
      if output=$(tsx "${legacy_test}" 2>&1); then
        echo "✅ Legacy test passed: ${legacy_test}"
      else
        echo "$output"
        exit 1
      fi
    else
      tsx "${legacy_test}"
    fi
  fi
done
