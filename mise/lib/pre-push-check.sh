#!/bin/sh
set -eu

run_ts=0
run_lua=0

zero_oid="0000000000000000000000000000000000000000"

pushed_files_from_stdin() {
  found=0

  while IFS=' ' read -r local_ref local_oid _remote_ref remote_oid; do
    [ -n "${local_ref:-}" ] || continue
    [ -n "${local_oid:-}" ] || continue
    [ "$local_oid" != "$zero_oid" ] || continue
    found=1

    if [ "${remote_oid:-}" != "$zero_oid" ] && git cat-file -e "$remote_oid^{commit}" 2>/dev/null; then
      git diff --name-only "$remote_oid..$local_oid"
    else
      git rev-list "$local_oid" --not --remotes | while IFS= read -r commit; do
        git diff-tree --no-commit-id --name-only -r "$commit"
      done
    fi
  done

  [ "$found" = "1" ]
}

fallback_pushed_files() {
  upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || true)"

  if [ -n "$upstream" ]; then
    base="$(git merge-base HEAD "$upstream" 2>/dev/null || true)"
  else
    base=""
  fi

  if [ -n "$base" ]; then
    git diff --name-only "$base"..HEAD
  else
    git rev-list HEAD --not --remotes | while IFS= read -r commit; do
      git diff-tree --no-commit-id --name-only -r "$commit"
    done
  fi
}

changed_files() {
  stdin_file="$(mktemp)"
  trap 'rm -f "$stdin_file"' EXIT

  while IFS= read -r line; do
    printf '%s\n' "$line"
  done >"$stdin_file"

  if ! pushed_files_from_stdin <"$stdin_file"; then
    fallback_pushed_files
  fi

  git diff --name-only --cached
  git diff --name-only
}

mark_tests_for_file() {
  case "$1" in
    bin/* | scripts/* | zsh/* | mise/lib/* | mise/tasks/* | .mise.toml)
      run_ts=1
      ;;
  esac

  case "$1" in
    *.lua | spec/* | nvim/spec/* | nvim/lua/*)
      run_lua=1
      ;;
  esac
}

echo "Running pre-push quick CI checks..."
mise run ci:quick

files="$(changed_files | sed '/^$/d' | sort -u)"

if [ -z "$files" ]; then
  echo "No changed files detected for additional pre-push tests."
  exit 0
fi

printf '%s\n' "$files" | while IFS= read -r file; do
  mark_tests_for_file "$file"
  printf '%s %s\n' "$run_ts" "$run_lua"
done | {
  while IFS=' ' read -r ts lua; do
    [ "$ts" = "1" ] && run_ts=1
    [ "$lua" = "1" ] && run_lua=1
  done

  if [ "$run_ts" = "1" ]; then
    echo "Running TypeScript tests for script/zsh/mise changes..."
    mise run test:ts
  fi

  if [ "$run_lua" = "1" ]; then
    echo "Running Lua tests for Lua/Neovim changes..."
    mise run test:lua
  fi
}
