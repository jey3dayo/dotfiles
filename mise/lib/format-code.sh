#!/usr/bin/env bash

set -e

family=${1:?Expected formatter family}
mode=${2:?Expected write or check mode}

case "$mode" in
  write | check) ;;
  *)
    printf 'Unknown format mode: %s\n' "$mode" >&2
    exit 2
    ;;
esac

case "$family" in
  biome) file_list=${BIOME_FILES:-} ;;
  prettier) file_list=${PRETTIER_FILES:-} ;;
  yaml) file_list=${YAML_FILES:-} ;;
  lua) file_list=${LUA_FILES:-} ;;
  toml) file_list=${TOML_FILES:-} ;;
  python) file_list=${PY_FILES:-} ;;
  *)
    printf 'Unknown formatter family: %s\n' "$family" >&2
    exit 2
    ;;
esac

run_formatter() {
  case "$family:$mode" in
    biome:write)
      biome format --write "$@"
      biome lint --write "$@"
      ;;
    biome:check) biome check --formatter-enabled=true --linter-enabled=true "$@" ;;
    prettier:write) prettier --write --ignore-unknown --log-level error "$@" >/dev/null ;;
    prettier:check) prettier --check --ignore-unknown --log-level error "$@" ;;
    yaml:write) prettier --write --log-level error "$@" >/dev/null ;;
    yaml:check) prettier --check --log-level error "$@" ;;
    lua:write) stylua "$@" ;;
    lua:check) stylua --check "$@" ;;
    toml:write) RUST_LOG=taplo=warn taplo format "$@" ;;
    toml:check) RUST_LOG=taplo=warn taplo format --check "$@" ;;
    python:write) uvx ruff format "$@" ;;
    python:check) uvx ruff format --check "$@" ;;
  esac
}

run_discovery() {
  # Preserve the existing word splitting and pathname expansion of TASK_EXCLUDES.
  # shellcheck disable=SC2206
  local -a excludes=(${TASK_EXCLUDES:-})

  case "$family:$mode" in
    yaml:write) fd -e yml -e yaml "${excludes[@]}" -X prettier --write --log-level error >/dev/null ;;
    yaml:check) fd -e yml -e yaml "${excludes[@]}" -X prettier --check --log-level error ;;
    lua:write) fd --hidden -e lua "${excludes[@]}" -X stylua ;;
    lua:check) fd --hidden -e lua "${excludes[@]}" -X stylua --check ;;
    toml:write) fd -e toml "${excludes[@]}" --exclude nvim/stylua.toml -X env RUST_LOG=taplo=warn taplo format ;;
    toml:check) fd -e toml "${excludes[@]}" --exclude nvim/stylua.toml -X env RUST_LOG=taplo=warn taplo format --check ;;
    python:write) fd -e py "${excludes[@]}" -X uvx ruff format ;;
    python:check) fd -e py "${excludes[@]}" -X uvx ruff format --check ;;
  esac
}

if [ -n "$file_list" ]; then
  # Preserve the existing space splitting and pathname expansion of *_FILES.
  # shellcheck disable=SC2206
  file_args=($file_list)
  run_formatter "${file_args[@]}"
elif [ "$family" = biome ] || [ "$family" = prettier ]; then
  run_formatter .
else
  run_discovery
fi
