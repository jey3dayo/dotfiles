#!/usr/bin/env bash
set -euo pipefail

COMMAND="${1:-help}"
if [ "$#" -gt 0 ]; then
  shift
fi

WORKSPACE_DIR="${APM_WORKSPACE_DIR:-$HOME/.apm}"
WORKSPACE_REPO="${APM_WORKSPACE_REPO:-https://github.com/jey3dayo/apm-workspace.git}"

have_command() {
  command -v "$1" >/dev/null 2>&1
}

log() {
  printf '%s\n' "$*"
}

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

require_command() {
  if ! have_command "$1"; then
    fail "$1 not found. Install it first."
  fi
}

workspace_project_name() {
  if [ -n "${APM_WORKSPACE_NAME:-}" ]; then
    printf '%s\n' "$APM_WORKSPACE_NAME"
    return 0
  fi

  basename "${WORKSPACE_REPO%.git}"
}

workspace_author_name() {
  git config user.name 2>/dev/null || printf '%s\n' "${USER:-${USERNAME:-unknown}}"
}

ensure_workspace_repo() {
  require_command git

  if [ ! -e "$WORKSPACE_DIR" ]; then
    log "Cloning $WORKSPACE_REPO into $WORKSPACE_DIR"
    git clone "$WORKSPACE_REPO" "$WORKSPACE_DIR"
  elif [ -d "$WORKSPACE_DIR" ] && [ ! -d "$WORKSPACE_DIR/.git" ]; then
    if [ -n "$(ls -A "$WORKSPACE_DIR" 2>/dev/null)" ]; then
      fail "$WORKSPACE_DIR exists but is not an empty directory or git checkout."
    fi

    log "Cloning $WORKSPACE_REPO into existing empty directory $WORKSPACE_DIR"
    (
      cd "$WORKSPACE_DIR"
      git clone "$WORKSPACE_REPO" .
    )
  elif [ ! -d "$WORKSPACE_DIR" ]; then
    fail "$WORKSPACE_DIR exists but is not a directory."
  fi

  if [ ! -d "$WORKSPACE_DIR/.git" ]; then
    fail "$WORKSPACE_DIR exists but is not a git checkout."
  fi
}

refresh_workspace_checkout() {
  current_branch=$(git -C "$WORKSPACE_DIR" branch --show-current 2>/dev/null || true)
  if [ -z "$current_branch" ]; then
    return 0
  fi

  remote_name=$(git -C "$WORKSPACE_DIR" config --get "branch.$current_branch.remote" 2>/dev/null || true)
  merge_ref=$(git -C "$WORKSPACE_DIR" config --get "branch.$current_branch.merge" 2>/dev/null || true)
  if [ -z "$remote_name" ] || [ -z "$merge_ref" ]; then
    return 0
  fi

  merge_branch=${merge_ref#refs/heads/}
  upstream="$remote_name/$merge_branch"
  if ! git -C "$WORKSPACE_DIR" show-ref --verify --quiet "refs/remotes/$upstream"; then
    return 0
  fi

  log "Updating $WORKSPACE_DIR from $upstream"
  git -C "$WORKSPACE_DIR" pull --ff-only
}

ensure_gitignore_entry() {
  entry="$1"
  gitignore_path="$WORKSPACE_DIR/.gitignore"
  touch "$gitignore_path"

  if ! grep -qxF "$entry" "$gitignore_path"; then
    printf '\n%s\n' "$entry" >>"$gitignore_path"
  fi
}

normalize_workspace_gitignore() {
  gitignore_path="$WORKSPACE_DIR/.gitignore"
  [ -f "$gitignore_path" ] || return 0

  tmp_file=$(mktemp "${TMPDIR:-/tmp}/apm-gitignore.XXXXXX")
  awk '
    BEGIN {
      entries[1] = "/.apm/"
      entries[2] = "/apm_modules/"
      entries[3] = "/.catalog-build/"
    }
    function append(line) {
      lines[++line_count] = line
    }
    {
      if ($0 == "# APM dependencies" || $0 == "apm_modules/") {
        next
      }
      for (i = 1; i <= 3; i++) {
        if ($0 == entries[i]) {
          seen[entries[i]] = 1
          next
        }
      }
      append($0)
    }
    END {
      for (i = 1; i <= 3; i++) {
        if (!seen[entries[i]]) {
          if (line_count > 0 && lines[line_count] != "") {
            append("")
          }
          append(entries[i])
        }
      }
      while (line_count > 0 && lines[line_count] == "") {
        line_count--
      }
      for (i = 1; i <= line_count; i++) {
        print lines[i]
      }
    }
  ' "$gitignore_path" >"$tmp_file"
  mv "$tmp_file" "$gitignore_path"
}

write_workspace_manifest_template() {
  manifest_path="$WORKSPACE_DIR/apm.yml"
  project_name=$(workspace_project_name)
  author_name=$(workspace_author_name)

  cat >"$manifest_path" <<EOF
name: $project_name
version: 1.0.0
description: APM project for $project_name
author: $author_name
dependencies:
  apm: []
  mcp: []
scripts: {}
EOF
}

ensure_workspace_scaffold() {
  ensure_workspace_repo
  ensure_gitignore_entry '/.apm/'
  ensure_gitignore_entry '/apm_modules/'
  ensure_gitignore_entry '/.catalog-build/'

  if [ ! -f "$WORKSPACE_DIR/apm.yml" ]; then
    log "Writing bootstrap apm.yml in $WORKSPACE_DIR"
    write_workspace_manifest_template
  fi

  normalize_workspace_gitignore
}

ensure_workspace_mise_file() {
  if [ ! -f "$WORKSPACE_DIR/mise.toml" ]; then
    fail "Missing workspace mise.toml: $WORKSPACE_DIR/mise.toml"
  fi
}

cmd_bootstrap() {
  ensure_workspace_repo
  refresh_workspace_checkout
  ensure_workspace_scaffold
  ensure_workspace_mise_file
  log "APM workspace ready: $WORKSPACE_DIR"
  log ""
  log "Next:"
  log "  cd $WORKSPACE_DIR"
  log "  mise install"
}

cmd_help() {
  cat <<EOF
Usage: scripts/apm-workspace.sh <command> [args...]

Commands:
  bootstrap          Ensure ~/.apm checkout + apm.yml + mise.toml are ready

Environment overrides:
  APM_WORKSPACE_DIR
  APM_WORKSPACE_REPO
  APM_WORKSPACE_NAME
EOF
}

case "$COMMAND" in
  bootstrap) cmd_bootstrap ;;
  help | -h | --help) cmd_help ;;
  *)
    fail "unsupported command in ~/.config: $COMMAND (use ~/.apm tasks for daily operation)"
    ;;
esac
