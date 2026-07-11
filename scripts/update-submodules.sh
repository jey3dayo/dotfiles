#!/usr/bin/env bash

set -euo pipefail

if [[ ! -f .gitmodules ]]; then
  echo "No submodules configured, skipping"
  exit 0
fi

clear_stale_index_lock() {
  local repo_label="$1"
  local lock_path
  lock_path=$(git rev-parse --git-path index.lock)

  if [[ ! -f "$lock_path" ]]; then
    return 0
  fi

  if command -v lsof >/dev/null 2>&1; then
    if lsof "$lock_path" >/dev/null 2>&1; then
      echo "Active git index.lock detected for $repo_label: $lock_path" >&2
      return 1
    fi
  elif command -v fuser >/dev/null 2>&1; then
    if fuser "$lock_path" >/dev/null 2>&1; then
      echo "Active git index.lock detected for $repo_label: $lock_path" >&2
      return 1
    fi
  else
    echo "Cannot verify whether git index.lock is stale for $repo_label: neither lsof nor fuser is available" >&2
    return 1
  fi

  echo "Removing stale git index.lock for $repo_label: $lock_path"
  rm -f "$lock_path"
}

clear_stale_index_lock "."
git submodule sync --recursive
# shellcheck disable=SC2016 # $displaypath and $lock_path expand in each submodule.
git submodule foreach --recursive '
lock_path=$(git rev-parse --git-path index.lock)
if [ -f "$lock_path" ]; then
  if command -v lsof >/dev/null 2>&1; then
    if lsof "$lock_path" >/dev/null 2>&1; then
      echo "Active git index.lock detected for $displaypath: $lock_path" >&2
      exit 1
    fi
  elif command -v fuser >/dev/null 2>&1; then
    if fuser "$lock_path" >/dev/null 2>&1; then
      echo "Active git index.lock detected for $displaypath: $lock_path" >&2
      exit 1
    fi
  else
    echo "Cannot verify whether git index.lock is stale for $displaypath: neither lsof nor fuser is available" >&2
    exit 1
  fi

  echo "Removing stale git index.lock for $displaypath: $lock_path"
  rm -f "$lock_path"
fi

git reset --hard HEAD && git clean -fd
'

# Update only top-level submodules to the latest remote tip, then align nested
# submodules to the commits pinned by each parent submodule.
GIT_HTTP_VERSION=HTTP/1.1 git -c http.version=HTTP/1.1 submodule update --remote
git submodule update --init --recursive
