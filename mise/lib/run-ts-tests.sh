#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/../.." && pwd)"
cd "${repo_root}"

QUIET=${QUIET:-0}

# bun:test compatible test files.
search_roots=()
if [[ -d "agents/scripts" ]]; then
  search_roots+=("agents/scripts")
fi
if [[ -d "scripts" ]]; then
  search_roots+=("scripts")
fi

test_files=()
if ((${#search_roots[@]} > 0)); then
  while IFS= read -r file; do
    test_files+=("${file}")
  done < <(fd --type f --glob "*.test.ts" "${search_roots[@]}" | sort -u)
fi

if ((${#test_files[@]} > 0)); then
  echo "Running bun test suites (${#test_files[@]} files)..."
  if [[ "$QUIET" == "1" ]]; then
    if output=$(bun test "${test_files[@]}" 2>&1); then
      echo "✅ bun tests passed (${#test_files[@]} files)"
    else
      echo "$output"
      exit 1
    fi
  else
    bun test "${test_files[@]}"
  fi
else
  echo "No bun test suites found."
fi
