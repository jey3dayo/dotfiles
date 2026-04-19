#!/usr/bin/env bash

set -euo pipefail

task_name=${1:?task name is required}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/.." && pwd)"
snapshot_root="$(mktemp -d /tmp/codex-mise-wsl-repo-XXXXXXXX)"

cleanup() {
  rm -rf "$snapshot_root"
}

trap cleanup EXIT

should_normalize_text_file() {
  local file_path=$1
  local file_name extension
  file_name=$(basename -- "$file_path")
  extension=${file_name##*.}

  case "$file_name" in
    AGENTS.md | CLAUDE.md | README.md | .mise.toml | .markdownlint-cli2.jsonc | .markdown-link-check.json | .luacheckrc | .editorconfig | .gitignore | .gitattributes | .fdignore | .ignore | .prettierignore | .shellcheckrc | Brewfile)
      return 0
      ;;
  esac

  case ".$extension" in
    .md | .nix | .toml | .json | .jsonc | .yaml | .yml | .sh | .zsh | .bash | .txt | .ts | .tsx | .js | .jsx | .lua | .py | .rc | .conf)
      return 0
      ;;
  esac

  return 1
}

normalize_line_endings() {
  local file_path=$1
  sed -i 's/\r$//' "$file_path"
}

git clone --quiet "$repo_root" "$snapshot_root"

if [ -f "$snapshot_root/.mise.toml" ]; then
  sed -i 's|\.config/mise/tasks/|mise/tasks/|g' "$snapshot_root/.mise.toml"
fi

mapfile -t changed_files < <(
  {
    git -C "$repo_root" diff --name-only HEAD
    git -C "$repo_root" ls-files --others --exclude-standard
  } | awk 'NF' | sort -u
)

mapfile -t deleted_files < <(
  git -C "$repo_root" diff --name-only --diff-filter=D HEAD | awk 'NF' | sort -u
)

for relative_path in "${changed_files[@]}"; do
  source_path="$repo_root/$relative_path"
  [ -f "$source_path" ] || continue

  destination_path="$snapshot_root/$relative_path"
  mkdir -p "$(dirname -- "$destination_path")"
  cp "$source_path" "$destination_path"

  if should_normalize_text_file "$destination_path"; then
    normalize_line_endings "$destination_path"
  fi
done

for relative_path in "${deleted_files[@]}"; do
  destination_path="$snapshot_root/$relative_path"
  [ -e "$destination_path" ] && rm -rf "$destination_path"
done

case "$task_name" in
  check)
    task_commands=(
      "mise run check:format"
      "mise run check:lint"
    )
    ;;
  ci:quick)
    task_commands=(
      "mise run check:format"
      "mise run check:lint:quick"
    )
    ;;
  ci)
    task_commands=(
      "mise run check"
      "mise run test:lua"
      "mise run test:ts"
      "mise run ci:gitleaks"
    )
    ;;
  *)
    printf 'Unsupported task: %s\n' "$task_name" >&2
    exit 1
    ;;
esac

(
  cd "$snapshot_root"
  export MISE_WSL_SNAPSHOT=1
  mise trust "$snapshot_root/.mise.toml" >/dev/null
  for command in "${task_commands[@]}"; do
    eval "$command"
  done
)
