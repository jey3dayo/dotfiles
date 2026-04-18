#!/bin/sh
set -eu

COMMAND="${1:-help}"
if [ "$#" -gt 0 ]; then
  shift
fi

REPO_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
WORKSPACE_DIR="${APM_WORKSPACE_DIR:-$HOME/.apm}"
WORKSPACE_REPO="${APM_WORKSPACE_REPO:-https://github.com/jey3dayo/apm-workspace.git}"
LEGACY_SKILLS_DIR="$REPO_ROOT/agents/src/skills"
PACKAGES_DIR="$WORKSPACE_DIR/packages"
CODEX_OUTPUT="${APM_CODEX_OUTPUT:-$HOME/.codex/AGENTS.md}"
MISE_TEMPLATE="$REPO_ROOT/templates/apm-workspace/mise.toml"
MISE_DESTINATION="$WORKSPACE_DIR/mise.toml"
MANAGED_MISE_MARKER="# Managed by ~/.config bootstrap"

have_command() {
  command -v "$1" >/dev/null 2>&1
}

log() {
  printf '%s\n' "$*"
}

warn() {
  printf 'warning: %s\n' "$*" >&2
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

require_apm() {
  if ! have_command apm; then
    fail "apm not found. Run 'cd $WORKSPACE_DIR && mise install' (or install it in another shell) before retrying."
  fi
}

validate_skill_id() {
  skill_id="$1"

  case "$skill_id" in
    ""|.|..|*/*|*\\*)
      fail "Invalid skill id: $skill_id"
      ;;
  esac

  case "$skill_id" in
    [A-Za-z0-9]*)
      ;;
    *)
      fail "Invalid skill id: $skill_id"
      ;;
  esac

  case "$skill_id" in
    *[!A-Za-z0-9._-]*)
      fail "Invalid skill id: $skill_id"
      ;;
  esac
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

  mkdir -p "$PACKAGES_DIR"
}

ensure_gitignore_entry() {
  entry="$1"
  gitignore_path="$WORKSPACE_DIR/.gitignore"
  touch "$gitignore_path"

  if ! grep -qxF "$entry" "$gitignore_path"; then
    printf '\n%s\n' "$entry" >>"$gitignore_path"
  fi
}

ensure_packages_readme() {
  packages_readme_path="$PACKAGES_DIR/README.md"

  if [ -f "$packages_readme_path" ]; then
    return 0
  fi

  cat >"$packages_readme_path" <<'EOF'
# Local APM packages

Store repo-owned local packages under `packages/<skill-id>/`.

Typical flow:

```bash
cd ~/.apm
mise install
mise run migrate -- apm-usage
mise run apply
```
EOF
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
  ensure_gitignore_entry '.apm/'
  ensure_gitignore_entry 'apm_modules/'
  ensure_packages_readme

  if [ ! -f "$WORKSPACE_DIR/apm.yml" ]; then
    log "Writing bootstrap apm.yml in $WORKSPACE_DIR"
    write_workspace_manifest_template
  fi
}

manifest_has_local_packages() {
  manifest_path="$WORKSPACE_DIR/apm.yml"

  if [ ! -f "$manifest_path" ]; then
    return 1
  fi

  grep -qE '^[[:space:]]*-[[:space:]]+\./packages/' "$manifest_path"
}

refresh_workspace_checkout() {
  ensure_workspace_repo

  if [ -n "$(git -C "$WORKSPACE_DIR" status --porcelain 2>/dev/null || true)" ]; then
    warn "$WORKSPACE_DIR has local changes; skipping git pull."
    return 0
  fi

  current_branch=$(git -C "$WORKSPACE_DIR" branch --show-current 2>/dev/null || true)
  remote_name=$(git -C "$WORKSPACE_DIR" config --get "branch.$current_branch.remote" 2>/dev/null || true)
  merge_ref=$(git -C "$WORKSPACE_DIR" config --get "branch.$current_branch.merge" 2>/dev/null || true)
  merge_branch=${merge_ref#refs/heads/}
  upstream="$remote_name/$merge_branch"

  if [ -z "$current_branch" ] || [ -z "$remote_name" ] || [ -z "$merge_ref" ]; then
    return 0
  fi

  if ! git -C "$WORKSPACE_DIR" show-ref --verify --quiet "refs/remotes/$upstream"; then
    return 0
  fi

  log "Updating $WORKSPACE_DIR from $upstream"
  git -C "$WORKSPACE_DIR" pull --ff-only
}

ensure_workspace_mise_file() {
  if [ ! -f "$MISE_TEMPLATE" ]; then
    fail "Missing mise template: $MISE_TEMPLATE"
  fi

  if [ ! -f "$MISE_DESTINATION" ]; then
    cp "$MISE_TEMPLATE" "$MISE_DESTINATION"
    log "Installed workspace mise.toml: $MISE_DESTINATION"
    return 0
  fi

  if grep -qF "$MANAGED_MISE_MARKER" "$MISE_DESTINATION"; then
    cp "$MISE_TEMPLATE" "$MISE_DESTINATION"
    log "Refreshed managed workspace mise.toml: $MISE_DESTINATION"
    return 0
  fi

  if [ "${APM_BOOTSTRAP_FORCE_MISE:-0}" = "1" ]; then
    cp "$MISE_TEMPLATE" "$MISE_DESTINATION"
    log "Replaced workspace mise.toml due to APM_BOOTSTRAP_FORCE_MISE=1"
    return 0
  fi

  warn "$MISE_DESTINATION already exists and is not managed by this repo; leaving it unchanged."
}

compile_codex() {
  require_apm
  mkdir -p "$(dirname "$CODEX_OUTPUT")"
  (
    cd "$WORKSPACE_DIR"
    apm compile --target codex --output "$CODEX_OUTPUT"
  )
}

copy_skill() {
  skill_id="$1"
  validate_skill_id "$skill_id"
  source_dir="$LEGACY_SKILLS_DIR/$skill_id"
  destination_dir="$PACKAGES_DIR/$skill_id"

  if [ ! -d "$source_dir" ]; then
    fail "Legacy skill not found: $source_dir"
  fi

  if [ -e "$destination_dir" ]; then
    if [ "${APM_MIGRATE_FORCE:-0}" != "1" ]; then
      fail "$destination_dir already exists. Set APM_MIGRATE_FORCE=1 to replace it."
    fi

    rm -rf "$destination_dir"
  fi

  cp -R "$source_dir" "$destination_dir"
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
  log "  mise run migrate -- apm-usage"
  log "  mise run apply"
}

cmd_inject_mise() {
  ensure_workspace_repo
  ensure_workspace_mise_file
}

cmd_apply() {
  require_apm
  ensure_workspace_repo
  ensure_workspace_scaffold

  if manifest_has_local_packages; then
    fail "apm 0.8.11 cannot deploy ./packages/* dependencies at user scope yet. Packages are seeded in ~/.apm/apm.yml, but rollout should stay on the legacy path until a later phase."
  fi

  (
    cd "$WORKSPACE_DIR"
    apm install -g
  )
  compile_codex
}

cmd_update() {
  require_apm
  ensure_workspace_repo
  refresh_workspace_checkout
  ensure_workspace_scaffold

  if manifest_has_local_packages; then
    fail "apm 0.8.11 cannot deploy ./packages/* dependencies at user scope yet. Update stopped before user-scope install; keep using the legacy deploy path for now."
  fi

  (
    cd "$WORKSPACE_DIR"
    apm deps update -g
    apm install -g
  )
  compile_codex
}

cmd_list() {
  require_apm
  apm deps list -g
}

cmd_validate() {
  require_apm
  ensure_workspace_repo
  ensure_workspace_scaffold
  (
    cd "$WORKSPACE_DIR"
    apm compile --validate
  )
}

cmd_doctor() {
  require_apm
  ensure_workspace_repo
  ensure_workspace_scaffold
  (
    cd "$WORKSPACE_DIR"
    printf 'apm: %s\n' "$(apm --version)"
    printf 'workspace: %s\n' "$WORKSPACE_DIR"
    printf 'manifest: %s\n' "$(test -f apm.yml && printf present || printf missing)"
    printf 'packages: %s\n' "$(test -d packages && printf present || printf missing)"
    printf 'branch: %s\n' "$(git branch --show-current 2>/dev/null || printf detached)"
    printf 'remote:\n'
    git remote -v || true
    printf 'targets:\n'
    for path in "$HOME/.claude/skills" "$HOME/.cursor/skills" "$HOME/.opencode/skills" "$HOME/.codex/AGENTS.md"; do
      if [ -e "$path" ]; then
        printf '  present  %s\n' "$path"
      else
        printf '  missing  %s\n' "$path"
      fi
    done
    apm deps list -g
  )
}

cmd_migrate() {
  if [ "$#" -eq 0 ]; then
    fail "usage: scripts/apm-workspace.sh migrate <skill-id> [skill-id ...]"
  fi

  require_apm
  ensure_workspace_repo
  ensure_workspace_scaffold
  ensure_workspace_mise_file

  for skill_id in "$@"; do
    copy_skill "$skill_id"
    (
      cd "$WORKSPACE_DIR"
      apm install "./packages/$skill_id"
    )
    log "Migrated legacy skill into ~/.apm/packages/$skill_id and recorded ./packages/$skill_id in apm.yml"
  done
}

cmd_smoke() {
  require_command bash
  require_command pwsh
  bash -n "$REPO_ROOT/scripts/apm-workspace.sh"
  pwsh -NoProfile -ExecutionPolicy Bypass -File "$REPO_ROOT/scripts/apm-workspace.ps1" help >/dev/null
  if [ ! -f "$MISE_TEMPLATE" ]; then
    fail "Missing workspace mise template: $MISE_TEMPLATE"
  fi
  grep -qF "$MANAGED_MISE_MARKER" "$MISE_TEMPLATE"
}

cmd_help() {
  cat <<EOF
Usage: scripts/apm-workspace.sh <command> [args...]

Commands:
  bootstrap          Ensure ~/.apm checkout + apm.yml + packages/ + mise.toml are ready
  inject-mise        Copy or refresh the managed ~/.apm/mise.toml template
  apply              Deploy user-scope-compatible dependencies and compile Codex output
  update             Pull clean checkout, update deps, then apply
  list               Show APM global dependencies
  validate           Validate the ~/.apm workspace
  doctor             Print workspace and target state
  migrate <skills>   Copy legacy skills into ~/.apm/packages/<id> and register them
  smoke              Validate script syntax and workspace template wiring

Environment overrides:
  APM_WORKSPACE_DIR
  APM_WORKSPACE_REPO
  APM_WORKSPACE_NAME
  APM_CODEX_OUTPUT
  APM_BOOTSTRAP_FORCE_MISE=1
  APM_MIGRATE_FORCE=1
EOF
}

case "$COMMAND" in
  bootstrap) cmd_bootstrap "$@" ;;
  inject-mise) cmd_inject_mise ;;
  apply) cmd_apply ;;
  update) cmd_update ;;
  list) cmd_list ;;
  validate) cmd_validate ;;
  doctor) cmd_doctor ;;
  migrate) cmd_migrate "$@" ;;
  smoke) cmd_smoke ;;
  help|-h|--help) cmd_help ;;
  *)
    fail "unknown command: $COMMAND"
    ;;
esac
