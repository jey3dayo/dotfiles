#!/usr/bin/env bash

set -e

family=${1:?Expected lint family}

case "$family" in
  biome)
    file_list=${BIOME_FILES:-}
    lint_command=(biome lint)
    ;;
  yaml)
    file_list=${YAML_FILES:-}
    lint_command=(yamllint -f parsable)
    discovery_args=(-e yml -e yaml)
    ;;
  python)
    file_list=${PY_FILES:-}
    lint_command=(uvx ruff check)
    discovery_args=(-e py)
    ;;
  dockerfile)
    file_list=${DOCKERFILE_FILES:-}
    lint_command=(hadolint --no-color)
    ;;
  lua)
    if ! command -v luacheck >/dev/null 2>&1; then
      echo "❌ luacheck not found. Run: mise run ci:install"
      exit 1
    fi
    file_list=${LUA_FILES:-}
    lint_command=(luacheck -q)
    discovery_args=(--hidden -e lua)
    ;;
  *)
    printf 'Unknown lint family: %s\n' "$family" >&2
    exit 2
    ;;
esac

if [ -n "$file_list" ]; then
  # Preserve the existing space-separated shell expansion behavior.
  # shellcheck disable=SC2206
  file_args=($file_list)
  "${lint_command[@]}" "${file_args[@]}"
elif [ "$family" = biome ]; then
  "${lint_command[@]}" .
elif [ "$family" = dockerfile ]; then
  fd -t f -e dockerfile -X "${lint_command[@]}"
  fd -t f --glob 'Dockerfile*' -X "${lint_command[@]}"
else
  # Preserve TASK_EXCLUDES word splitting and pathname expansion.
  # shellcheck disable=SC2206
  exclude_args=(${TASK_EXCLUDES})
  fd "${discovery_args[@]}" "${exclude_args[@]}" -X "${lint_command[@]}"
fi
