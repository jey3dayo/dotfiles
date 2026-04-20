#!/usr/bin/env bash
set -euo pipefail

COMMAND="${1:-help}"
if [ "$#" -gt 0 ]; then
  shift
fi

REPO_ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
WORKSPACE_DIR="${APM_WORKSPACE_DIR:-$HOME/.apm}"
WORKSPACE_REPO="${APM_WORKSPACE_REPO:-https://github.com/jey3dayo/apm-workspace.git}"
EXTERNAL_SOURCES_FILE="$REPO_ROOT/nix/agent-skills-sources.nix"
CODEX_OUTPUT="${APM_CODEX_OUTPUT:-$HOME/.codex/AGENTS.md}"
MISE_TEMPLATE="$REPO_ROOT/templates/apm-workspace/mise.toml"
MISE_DESTINATION="$WORKSPACE_DIR/mise.toml"
CATALOG_BUILD_ROOT="$WORKSPACE_DIR/.catalog-build"
CATALOG_DIR_NAME="catalog"
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

error() {
  printf 'error: %s\n' "$*" >&2
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
    "" | . | .. | */* | *\\*)
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

validate_skill_path_segments() {
  original_value="$1"
  shift

  if [ "$#" -eq 0 ]; then
    fail "Invalid skill path: $original_value"
  fi

  for segment in "$@"; do
    case "$segment" in
      "" | . | .. | */* | *\\*)
        fail "Invalid skill path: $original_value"
        ;;
      [A-Za-z0-9]*)
        ;;
      *)
        fail "Invalid skill path: $original_value"
        ;;
    esac

    case "$segment" in
      *[!A-Za-z0-9._-]*)
        fail "Invalid skill path: $original_value"
        ;;
    esac
  done
}

skill_id_to_manifest_path() {
  skill_id="$1"
  old_ifs=$IFS
  IFS=':'
  # shellcheck disable=SC2086
  set -- $skill_id
  IFS=$old_ifs
  validate_skill_path_segments "$skill_id" "$@"
  printf '%s' "$1"
  shift
  for segment in "$@"; do
    printf '/%s' "$segment"
  done
  printf '\n'
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
}

catalog_build_dir() {
  printf '%s/%s\n' "$CATALOG_BUILD_ROOT" "$CATALOG_DIR_NAME"
}

catalog_build_skills_root() {
  printf '%s/.apm/skills\n' "$(catalog_build_dir)"
}

catalog_build_agents_root() {
  printf '%s/agents\n' "$(catalog_build_dir)"
}

catalog_build_commands_root() {
  printf '%s/commands\n' "$(catalog_build_dir)"
}

catalog_build_rules_root() {
  printf '%s/rules\n' "$(catalog_build_dir)"
}

catalog_build_instructions_path() {
  printf '%s/AGENTS.md\n' "$(catalog_build_dir)"
}

tracked_catalog_dir() {
  printf '%s/%s\n' "$WORKSPACE_DIR" "$CATALOG_DIR_NAME"
}

tracked_catalog_skills_root() {
  printf '%s/.apm/skills\n' "$(tracked_catalog_dir)"
}

tracked_catalog_agents_root() {
  printf '%s/agents\n' "$(tracked_catalog_dir)"
}

tracked_catalog_commands_root() {
  printf '%s/commands\n' "$(tracked_catalog_dir)"
}

tracked_catalog_rules_root() {
  printf '%s/rules\n' "$(tracked_catalog_dir)"
}

tracked_catalog_instructions_path() {
  printf '%s/AGENTS.md\n' "$(tracked_catalog_dir)"
}

tracked_catalog_relative_path() {
  printf '%s\n' "$CATALOG_DIR_NAME"
}

skill_ids_from_root() {
  skills_root="$1"
  [ -d "$skills_root" ] || return 0

  (
    cd "$skills_root"
    find . -type f -name SKILL.md | sed 's#^\./##' | sed 's#/SKILL\.md$##' | sed 's#/#:#g' | sort -u
  )
}

write_catalog_manifest_template() {
  destination_dir="$1"
  cat >"$destination_dir/apm.yml" <<EOF
name: $CATALOG_DIR_NAME
version: 1.0.0
description: Managed catalog package for global APM rollout
dependencies:
  apm: []
  mcp: []
scripts: {}
EOF
}

write_catalog_readme() {
  destination_dir="$1"
  cat >"$destination_dir/README.md" <<EOF
# $CATALOG_DIR_NAME

This directory contains the managed catalog for the global APM workspace.

- Edit skills in \`~/.apm/catalog/.apm/skills/<id>/\`
- Edit shared guidance in \`~/.apm/catalog/AGENTS.md\`, \`agents/**\`, \`commands/**\`, and \`rules/**\`
- \`skills\` live under \`.apm/skills/**\` because they are installable APM package content
- \`commands/**\` stays top-level because it is runtime-synced shared guidance, not nested skill package content
- Edit this directory directly, then run \`mise run stage-catalog\` before commit/push
- Install ref: \`jey3dayo/apm-workspace/catalog#main\`
EOF
}

reset_catalog_build_dir() {
  destination_dir=$(catalog_build_dir)
  rm -rf "$destination_dir"
  mkdir -p "$destination_dir"
  mkdir -p "$(catalog_build_skills_root)"
}

reset_tracked_catalog_dir() {
  destination_dir=$(tracked_catalog_dir)
  rm -rf "$destination_dir"
  mkdir -p "$destination_dir"
}

workspace_remote_to_repo_reference() {
  remote_url="$1"

  case "$remote_url" in
    https://github.com/*)
      repo_ref=${remote_url#https://github.com/}
      repo_ref=${repo_ref%.git}
      repo_ref=${repo_ref%/}
      printf '%s\n' "$repo_ref"
      ;;
    git@github.com:*)
      repo_ref=${remote_url#git@github.com:}
      repo_ref=${repo_ref%.git}
      printf '%s\n' "$repo_ref"
      ;;
    *)
      fail "Unsupported workspace remote URL for catalog reference: $remote_url"
      ;;
  esac
}

workspace_remote_url() {
  remote_name="${1:-origin}"
  ensure_workspace_repo

  if remote_url=$(git -C "$WORKSPACE_DIR" remote get-url "$remote_name" 2>/dev/null); then
    printf '%s\n' "$remote_url"
    return 0
  fi

  if [ "$remote_name" = "origin" ]; then
    printf '%s\n' "$WORKSPACE_REPO"
    return 0
  fi

  fail "Could not resolve remote URL for '$remote_name'"
}

workspace_repo_reference() {
  remote_name="${1:-origin}"
  workspace_remote_to_repo_reference "$(workspace_remote_url "$remote_name")"
}

workspace_tracking_info() {
  current_branch=$(git -C "$WORKSPACE_DIR" branch --show-current 2>/dev/null || true)
  [ -n "$current_branch" ] || fail "Cannot register catalog from a detached HEAD. Check out a tracking branch first."

  remote_name=$(git -C "$WORKSPACE_DIR" config --get "branch.$current_branch.remote" 2>/dev/null || true)
  merge_ref=$(git -C "$WORKSPACE_DIR" config --get "branch.$current_branch.merge" 2>/dev/null || true)
  [ -n "$remote_name" ] && [ -n "$merge_ref" ] || fail "Branch '$current_branch' has no upstream tracking branch. Push it first."

  merge_branch=${merge_ref#refs/heads/}
  printf '%s\036%s\n' "$remote_name" "$merge_branch"
}

tracked_catalog_reference() {
  tracking_info=$(workspace_tracking_info)
  remote_name=${tracking_info%%"$(printf '\036')"*}
  branch_name=${tracking_info#*"$(printf '\036')"}
  printf '%s/%s#%s\n' "$(workspace_repo_reference "$remote_name")" "$(tracked_catalog_relative_path)" "$branch_name"
}

assert_tracked_catalog_published() {
  tracked_relative_path=$(tracked_catalog_relative_path)
  tracked_dir=$(tracked_catalog_dir)

  [ -d "$tracked_dir" ] || fail "Tracked catalog missing: $tracked_dir. Run 'mise run stage-catalog' first."

  dirty=$(git -C "$WORKSPACE_DIR" status --porcelain -- "$tracked_relative_path" 2>/dev/null || true)
  [ -z "$dirty" ] || fail "Tracked catalog has uncommitted changes. Commit and push $tracked_relative_path before registering it."

  tracking_info=$(workspace_tracking_info)
  remote_name=${tracking_info%%"$(printf '\036')"*}
  branch_name=${tracking_info#*"$(printf '\036')"}
  upstream="$remote_name/$branch_name"
  unpushed=$(git -C "$WORKSPACE_DIR" rev-list "$upstream..HEAD" -- "$tracked_relative_path" 2>/dev/null || true)
  [ -z "$unpushed" ] || fail "Tracked catalog has commits not on $upstream. Push the branch before registering it."
}

managed_skill_content_dir() {
  skill_id="$1"
  validate_skill_id "$skill_id"
  source_dir="$(tracked_catalog_skills_root)"
  old_ifs=$IFS
  IFS=':'
  # shellcheck disable=SC2086
  set -- $skill_id
  IFS=$old_ifs
  validate_skill_path_segments "$skill_id" "$@"
  for segment in "$@"; do
    source_dir="$source_dir/$segment"
  done

  [ -f "$source_dir/SKILL.md" ] || fail "Managed catalog skill missing SKILL.md: $source_dir"
  printf '%s\n' "$source_dir"
}

copy_managed_skill_into_catalog() {
  skill_id="$1"
  skills_root="$2"
  validate_skill_id "$skill_id"
  source_dir=$(managed_skill_content_dir "$skill_id")

  destination_dir="$skills_root"
  old_ifs=$IFS
  IFS=':'
  # shellcheck disable=SC2086
  set -- $skill_id
  IFS=$old_ifs
  validate_skill_path_segments "$skill_id" "$@"
  for segment in "$@"; do
    destination_dir="$destination_dir/$segment"
  done

  mkdir -p "$destination_dir"
  cp -R "$source_dir"/. "$destination_dir"
}

copy_managed_instructions_into_catalog() {
  destination_path="$1"
  source_path=$(tracked_catalog_instructions_path)
  [ -f "$source_path" ] || fail "Managed catalog instructions missing: $source_path"
  destination_dir=$(dirname "$destination_path")
  mkdir -p "$destination_dir"
  cp "$source_path" "$destination_path"
}

copy_managed_agent_assets_into_catalog() {
  destination_dir="$1"
  source_dir=$(tracked_catalog_agents_root)
  [ -d "$source_dir" ] || fail "Managed catalog agents missing: $source_dir"
  mkdir -p "$destination_dir"
  cp -R "$source_dir"/. "$destination_dir"
}

copy_managed_command_assets_into_catalog() {
  destination_dir="$1"
  source_dir=$(tracked_catalog_commands_root)
  [ -d "$source_dir" ] || fail "Managed catalog commands missing: $source_dir"
  mkdir -p "$destination_dir"
  cp -R "$source_dir"/. "$destination_dir"
}

copy_managed_rule_assets_into_catalog() {
  destination_dir="$1"
  source_dir=$(tracked_catalog_rules_root)
  [ -d "$source_dir" ] || fail "Managed catalog rules missing: $source_dir"
  mkdir -p "$destination_dir"
  cp -R "$source_dir"/. "$destination_dir"
}

legacy_skill_content_dir() {
  skill_id="$1"
  validate_skill_id "$skill_id"
  skill_root="$LEGACY_SKILLS_DIR/$skill_id"

  if [ ! -d "$skill_root" ]; then
    fail "Legacy skill not found: $skill_root"
  fi

  if [ -f "$skill_root/SKILL.md" ]; then
    printf '%s\n' "$skill_root"
    return 0
  fi

  if [ -f "$skill_root/skills/SKILL.md" ]; then
    printf '%s\n' "$skill_root/skills"
    return 0
  fi

  fail "Legacy skill content dir missing SKILL.md: $skill_root"
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

internal_deploy_target_roots() {
  printf '%s\n' \
    "$HOME/.claude/skills" \
    "$HOME/.cursor/skills" \
    "$HOME/.opencode/skills" \
    "$HOME/.copilot/skills"
}

internal_target_skill_path() {
  target_root="$1"
  skill_id="$2"
  validate_skill_id "$skill_id"
  path="$target_root"
  old_ifs=$IFS
  IFS=':'
  # shellcheck disable=SC2086
  set -- $skill_id
  IFS=$old_ifs
  validate_skill_path_segments "$skill_id" "$@"
  for segment in "$@"; do
    path="$path/$segment"
  done
  printf '%s\n' "$path"
}

remove_internal_target_links() {
  skill_ids="$1"

  internal_deploy_target_roots | while IFS= read -r target_root; do
    [ -d "$target_root" ] || continue

    printf '%s\n' "$skill_ids" | while IFS= read -r skill_id; do
      [ -n "$skill_id" ] || continue
      target_path=$(internal_target_skill_path "$target_root" "$skill_id")
      [ -e "$target_path" ] || continue

      if [ -L "$target_path" ]; then
        rm -f "$target_path"
        log "Removed existing symlink skill target before APM install: $target_path"
      fi
    done
  done
}

internal_skill_exists() {
  skill_id="$1"
  relative_path=$(skill_id_to_manifest_path "$skill_id")
  [ -d "$(tracked_catalog_skills_root)/$relative_path" ]
}

parse_external_sources() {
  if [ ! -f "$EXTERNAL_SOURCES_FILE" ]; then
    return 0
  fi

  awk '
    function flush_source(    has_catalogs, has_selection, line, n, parts, i, value, base_dir, id_prefix) {
      if (current_name == "") {
        return
      }

      has_catalogs = 0
      has_selection = 0
      url = ""
      base_dir = "."
      id_prefix = ""
      catalogs = ""
      selected = ""
      mode = ""

      n = split(block, parts, "\n")
      for (i = 1; i <= n; i++) {
        line = parts[i]
        sub(/[[:space:]]*#.*/, "", line)

        if (mode == "catalogs") {
          if (line ~ /^[[:space:]]*};/) {
            mode = ""
            continue
          }
          if (match(line, /^[[:space:]]*([A-Za-z0-9._-]+)[[:space:]]*=[[:space:]]*"([^"]+)"[[:space:]]*;/, m)) {
            if (catalogs != "") {
              catalogs = catalogs "\034"
            }
            catalogs = catalogs m[1] "\035" m[2]
            has_catalogs = 1
          }
          continue
        }

        if (mode == "selection") {
          if (line ~ /\];/) {
            mode = ""
          }
          while (match(line, /"([^"]+)"/, m)) {
            if (selected != "") {
              selected = selected "\034"
            }
            selected = selected m[1]
            has_selection = 1
            line = substr(line, RSTART + RLENGTH)
          }
          continue
        }

        if (match(line, /^[[:space:]]*url[[:space:]]*=[[:space:]]*"([^"]+)"[[:space:]]*;/, m)) {
          url = m[1]
          continue
        }
        if (match(line, /^[[:space:]]*baseDir[[:space:]]*=[[:space:]]*"([^"]+)"[[:space:]]*;/, m)) {
          base_dir = m[1]
          continue
        }
        if (match(line, /^[[:space:]]*idPrefix[[:space:]]*=[[:space:]]*"([^"]+)"[[:space:]]*;/, m)) {
          id_prefix = m[1]
          continue
        }
        if (line ~ /^[[:space:]]*catalogs[[:space:]]*=[[:space:]]*{/) {
          mode = "catalogs"
          continue
        }
        if (line ~ /selection\.enable[[:space:]]*=[[:space:]]*\[/) {
          mode = "selection"
          while (match(line, /"([^"]+)"/, m)) {
            if (selected != "") {
              selected = selected "\034"
            }
            selected = selected m[1]
            has_selection = 1
            line = substr(line, RSTART + RLENGTH)
          }
          if (line ~ /\];/) {
            mode = ""
          }
          continue
        }
      }

      if (url != "" && has_catalogs && has_selection) {
        printf "%s\036%s\036%s\036%s\036%s\036%s\n", current_name, url, base_dir, id_prefix, catalogs, selected
      }

      current_name = ""
      block = ""
    }

    {
      sanitized = $0
      sub(/[[:space:]]*#.*/, "", sanitized)

      if (depth == 1 && current_name == "" && match(sanitized, /^[[:space:]]*([A-Za-z0-9._-]+)[[:space:]]*=[[:space:]]*{[[:space:]]*$/, m)) {
        current_name = m[1]
        block = $0 "\n"
      } else if (current_name != "") {
        block = block $0 "\n"
      }

      opens = gsub(/\{/, "{", sanitized)
      closes = gsub(/\}/, "}", sanitized)
      depth += opens - closes

      if (current_name != "" && depth == 1) {
        flush_source()
      }
    }
  ' "$EXTERNAL_SOURCES_FILE"
}

external_source_checkout_path() {
  source_name="$1"
  source_url="$2"

  require_command git

  if [ "${source_url#path:}" != "$source_url" ]; then
    relative_path=${source_url#path:}
    (cd "$REPO_ROOT" && cd "$relative_path" && pwd)
    return 0
  fi

  clone_url=
  ref=
  case "$source_url" in
    github:*)
      repo_spec=${source_url#github:}
      owner=${repo_spec%%/*}
      repo_ref=${repo_spec#*/}
      repo=${repo_ref%%/*}
      if [ "$repo_ref" != "$repo" ]; then
        ref=${repo_ref#*/}
      fi
      clone_url="https://github.com/$owner/$repo.git"
      ;;
    git+*)
      clone_url=${source_url#git+}
      case "$clone_url" in
        *[\?\&]ref=*)
          ref=$(printf '%s' "$clone_url" | sed -n 's/^.*[?&]ref=\([^&#]*\).*$/\1/p')
          clone_url=$(printf '%s' "$clone_url" | sed 's/[?&]ref=[^&#]*//')
          ;;
      esac
      ;;
    *)
      clone_url=$source_url
      ;;
  esac

  [ -n "$clone_url" ] || fail "Unsupported source URL: $source_url"

  checkout_root="${TMPDIR:-/tmp}/apm-workspace-external"
  checkout_path="$checkout_root/$source_name"
  mkdir -p "$checkout_root"
  rm -rf "$checkout_path"

  if [ -n "$ref" ]; then
    git clone --depth 1 --branch "$ref" "$clone_url" "$checkout_path" >/dev/null
  else
    git clone --depth 1 "$clone_url" "$checkout_path" >/dev/null
  fi

  printf '%s\n' "$checkout_path"
}

resolve_external_skill_source_dir() {
  checkout_path="$1"
  source_name="$2"
  base_dir="$3"
  id_prefix="$4"
  catalogs_value="$5"
  skill_id="$6"

  source_relative_id="$skill_id"
  if [ -n "$id_prefix" ]; then
    case "$skill_id" in
      "$id_prefix"*)
        source_relative_id=${skill_id#"$id_prefix"}
        ;;
      *)
        fail "Skill '$skill_id' does not match idPrefix '$id_prefix' for source '$source_name'"
        ;;
    esac
  fi

  relative_skill_path=$(skill_id_to_manifest_path "$source_relative_id")
  base_path="$checkout_path"
  if [ "$base_dir" != "." ] && [ -n "$base_dir" ]; then
    base_path="$checkout_path/$base_dir"
  fi

  old_ifs=$IFS
  IFS=$(printf '\034')
  # shellcheck disable=SC2086
  set -- $catalogs_value
  IFS=$old_ifs
  for catalog_entry in "$@"; do
    catalog_path=${catalog_entry#*"$(printf '\035')"}
    catalog_root="$base_path"
    if [ "$catalog_path" != "." ] && [ -n "$catalog_path" ]; then
      catalog_root="$catalog_root/$catalog_path"
    fi
    if [ -f "$catalog_root/SKILL.md" ]; then
      printf '%s\n' "$catalog_root"
      return 0
    fi
    candidate="$catalog_root"
    candidate="$candidate/$relative_skill_path"
    if [ -f "$candidate/SKILL.md" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  while IFS= read -r skill_file; do
    candidate_dir=$(dirname "$skill_file")
    relative_dir=${candidate_dir#"$checkout_path"/}
    case "$relative_dir" in
      "$relative_skill_path" | */"$relative_skill_path")
        printf '%s\n' "$candidate_dir"
        return 0
        ;;
    esac
  done <<EOF
$(find "$checkout_path" -type f -name SKILL.md 2>/dev/null)
EOF

  fail "Could not find external skill '$skill_id' in source '$source_name'"
}

relative_file_list() {
  root_dir="$1"
  if [ ! -d "$root_dir" ]; then
    return 0
  fi

  (
    cd "$root_dir"
    find . -type f | sed 's#^\./##' | sort
  )
}

external_source_repo_reference() {
  source_url="$1"

  case "$source_url" in
    github:*)
      source_path=${source_url#github:}
      owner=${source_path%%/*}
      repo_and_ref=${source_path#*/}
      repo=${repo_and_ref%%/*}
      ref=""
      if [ "$repo_and_ref" != "$repo" ]; then
        ref=${repo_and_ref#"$repo/"}
      fi
      printf '%s\036%s\n' "$owner/$repo" "$ref"
      ;;
    *)
      fail "Cannot derive canonical upstream reference from source URL: $source_url"
      ;;
  esac
}

external_skill_reference() {
  source_url="$1"
  checkout_path="$2"
  source_name="$3"
  base_dir="$4"
  id_prefix="$5"
  catalogs_value="$6"
  skill_id="$7"

  source_dir=$(resolve_external_skill_source_dir "$checkout_path" "$source_name" "$base_dir" "$id_prefix" "$catalogs_value" "$skill_id")
  repo_info=$(external_source_repo_reference "$source_url")
  repo=${repo_info%%"$(printf '\036')"*}
  ref=${repo_info#*"$(printf '\036')"}
  relative_path=${source_dir#"$checkout_path"}
  relative_path=${relative_path#/}

  if [ -n "$relative_path" ] && [ "$relative_path" != "." ]; then
    reference="$repo/$relative_path"
  else
    reference="$repo"
  fi

  if [ -n "$ref" ]; then
    reference="$reference#$ref"
  fi

  printf '%s\n' "$reference"
}

migrate_package() {
  package_relative_path="$1"
  (
    cd "$WORKSPACE_DIR"
    apm install "./packages/$package_relative_path"
  )
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
  log "  mise run migrate-external"
  log "  mise run apply"
}

cmd_inject_mise() {
  ensure_workspace_repo
  ensure_workspace_mise_file
}

apm_install_has_diagnostics_failure() {
  output_file="$1"
  grep -Eq '\[[xX]\][[:space:]]+[1-9][0-9]* packages failed:' "$output_file" \
    || grep -Eq 'Installed .* with [1-9][0-9]* error\(s\)\.' "$output_file"
}

run_workspace_install_command() {
  output_file=$(mktemp)
  pushd "$WORKSPACE_DIR" >/dev/null || fail "Workspace not found: $WORKSPACE_DIR"
  if apm install "$@" >"$output_file" 2>&1; then
    status=0
  else
    status=$?
  fi
  popd >/dev/null || true

  cat "$output_file"
  if [ "$status" -ne 0 ]; then
    rm -f "$output_file"
    fail "apm install failed: $*"
  fi
  if apm_install_has_diagnostics_failure "$output_file"; then
    rm -f "$output_file"
    fail "apm install reported integration diagnostics: $*"
  fi

  rm -f "$output_file"
}

cmd_apply() {
  require_apm
  ensure_workspace_repo
  ensure_workspace_scaffold
  cmd_validate_catalog

  if manifest_has_local_packages; then
    fail "apm 0.8.11 cannot deploy ./packages/* dependencies at user scope yet. Remove local package refs from ~/.apm/apm.yml and keep the global manifest on upstream refs such as jey3dayo/apm-workspace/catalog#main."
  fi

  remove_internal_target_links "$(managed_skill_ids)"
  run_workspace_install_command -g
  normalize_workspace_gitignore
  compile_codex
  sync_managed_catalog_runtime_assets
}

cmd_update() {
  require_apm
  ensure_workspace_repo
  refresh_workspace_checkout
  ensure_workspace_scaffold
  cmd_validate_catalog

  if manifest_has_local_packages; then
    fail "apm 0.8.11 cannot deploy ./packages/* dependencies at user scope yet. Update stopped before user-scope install; remove local package refs from ~/.apm/apm.yml first."
  fi

  remove_internal_target_links "$(managed_skill_ids)"
  (
    cd "$WORKSPACE_DIR"
    apm deps update -g
  )
  run_workspace_install_command -g
  normalize_workspace_gitignore
  compile_codex
  sync_managed_catalog_runtime_assets
}

cmd_list() {
  require_apm
  apm deps list -g
}

lock_pinned_reference_map() {
  lock_path="$WORKSPACE_DIR/apm.lock.yaml"
  [ -f "$lock_path" ] || fail "Lock file not found: $lock_path"

  awk '
    /^- repo_url: / {
      if (repo_url != "" && resolved_commit != "") {
        canonical = repo_url
        if (virtual_path != "") {
          canonical = canonical "/" virtual_path
        }
        printf "%s\t%s#%s\n", canonical, canonical, resolved_commit
      }
      repo_url = substr($0, index($0, ": ") + 2)
      resolved_commit = ""
      virtual_path = ""
      next
    }
    /^[[:space:]]+resolved_commit: / {
      resolved_commit = substr($0, index($0, ": ") + 2)
      next
    }
    /^[[:space:]]+virtual_path: / {
      virtual_path = substr($0, index($0, ": ") + 2)
      next
    }
    END {
      if (repo_url != "" && resolved_commit != "") {
        canonical = repo_url
        if (virtual_path != "") {
          canonical = canonical "/" virtual_path
        }
        printf "%s\t%s#%s\n", canonical, canonical, resolved_commit
      }
    }
  ' "$lock_path"
}

unpinned_external_references() {
  manifest_path="$WORKSPACE_DIR/apm.yml"
  [ -f "$manifest_path" ] || return 0

  awk '
    /^[[:space:]]*-[[:space:]]+/ {
      ref = $2
      if (ref ~ /^jey3dayo\/apm-workspace\/catalog(#|$)/) {
        next
      }
      if (ref ~ /^\.\//) {
        next
      }
      if (ref !~ /#/) {
        print ref
      }
    }
  ' "$manifest_path"
}

manifest_reference_keys() {
  manifest_path="$WORKSPACE_DIR/apm.yml"
  [ -f "$manifest_path" ] || return 0

  awk '
    /^[[:space:]]*-[[:space:]]+/ {
      ref = $2
      print ref
      sub(/#.*/, "", ref)
      print ref
    }
  ' "$manifest_path"
}

cmd_pin_external() {
  ensure_workspace_repo
  ensure_workspace_scaffold

  manifest_path="$WORKSPACE_DIR/apm.yml"
  [ -f "$manifest_path" ] || fail "Manifest not found: $manifest_path"

  map_file=$(mktemp)
  awk 'BEGIN { FS = "\t" } { print $1 "\t" $2 }' <<EOF >"$map_file"
$(lock_pinned_reference_map)
EOF

  updated_file=$(mktemp)
  awk -v map_file="$map_file" '
    BEGIN {
      FS = "\t"
      while ((getline < map_file) > 0) {
        pinned[$1] = $2
      }
      close(map_file)
      updated = 0
    }
    {
      if (match($0, /^([[:space:]]*-[[:space:]]+)([^[:space:]]+)[[:space:]]*$/, m)) {
        ref = m[2]
        if (index(ref, "#") == 0 && (ref in pinned)) {
          print m[1] pinned[ref]
          updated++
          next
        }
      }
      print
    }
    END {
      printf "%d\n", updated > "/dev/stderr"
    }
  ' "$manifest_path" >"$updated_file" 2>"$updated_file.count"

  updated_count=$(tr -d '\r\n' <"$updated_file.count")
  if [ "${updated_count:-0}" -eq 0 ]; then
    rm -f "$map_file" "$updated_file" "$updated_file.count"
    log "No external dependencies needed pinning."
    return 0
  fi

  cat "$updated_file" >"$manifest_path"
  rm -f "$map_file" "$updated_file" "$updated_file.count"
  log "Pinned $updated_count external dependency references in apm.yml"
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

managed_skill_ids() {
  skill_ids_from_root "$(tracked_catalog_skills_root)"
}

managed_agent_relative_paths() {
  tracked_catalog_agent_relative_paths
}

tracked_catalog_agent_relative_paths() {
  relative_file_list "$(tracked_catalog_agents_root)"
}

managed_command_relative_paths() {
  tracked_catalog_command_relative_paths
}

tracked_catalog_command_relative_paths() {
  relative_file_list "$(tracked_catalog_commands_root)"
}

managed_rule_relative_paths() {
  tracked_catalog_rule_relative_paths
}

tracked_catalog_rule_relative_paths() {
  relative_file_list "$(tracked_catalog_rules_root)"
}

file_content_equal() {
  expected_path="$1"
  actual_path="$2"

  [ -f "$expected_path" ] || return 1
  [ -f "$actual_path" ] || return 1

  expected_hash=$(sha256sum "$expected_path" | awk '{print $1}')
  actual_hash=$(sha256sum "$actual_path" | awk '{print $1}')
  [ "$expected_hash" = "$actual_hash" ]
}

tracked_catalog_skill_ids() {
  skill_ids_from_root "$(tracked_catalog_skills_root)"
}

manifest_has_catalog_reference() {
  manifest_path="$WORKSPACE_DIR/apm.yml"
  [ -f "$manifest_path" ] || return 1
  repo_reference=$(workspace_remote_to_repo_reference "$WORKSPACE_REPO")
  grep -q "${repo_reference}/${CATALOG_DIR_NAME}#" "$manifest_path"
}

print_catalog_summary() {
  source_skill_count=$(managed_skill_ids | awk 'NF { count++ } END { print count + 0 }')
  source_agent_count=$(managed_agent_relative_paths | awk 'NF { count++ } END { print count + 0 }')
  source_command_count=$(managed_command_relative_paths | awk 'NF { count++ } END { print count + 0 }')
  source_rule_count=$(managed_rule_relative_paths | awk 'NF { count++ } END { print count + 0 }')
  tracked_manifest=no
  [ -f "$(tracked_catalog_dir)/apm.yml" ] && tracked_manifest=yes
  global_ref=no
  manifest_has_catalog_reference && global_ref=yes
  instructions=missing
  [ -f "$(tracked_catalog_instructions_path)" ] && instructions=present
  status=drift
  if [ "$tracked_manifest" = yes ] && [ "$global_ref" = yes ] && [ "$instructions" = present ]; then
    status=ok
  fi

  printf 'catalog: skills=%s agents=%s commands=%s rules=%s instructions=%s tracked-manifest=%s global-ref=%s status=%s\n' \
    "$source_skill_count" \
    "$source_agent_count" \
    "$source_command_count" \
    "$source_rule_count" \
    "$instructions" "$tracked_manifest" "$global_ref" "$status"
}

managed_external_overlap_lines() {
  managed_tmp=$(mktemp)
  overlaps_tmp=$(mktemp)
  printf '%s\n' "$(managed_skill_ids)" | awk 'NF' | sort -u >"$managed_tmp"

  parse_external_sources | while IFS=$(printf '\036') read -r source_name _source_url _base_dir _id_prefix _catalogs_value selected_value; do
    [ -n "$source_name" ] || continue
    old_ifs=$IFS
    IFS=$(printf '\034')
    read -r -a selected_skills <<<"$selected_value"
    IFS=$old_ifs
    for skill_id in "${selected_skills[@]}"; do
      [ -n "$skill_id" ] || continue
      if grep -Fxq "$skill_id" "$managed_tmp"; then
        printf '%s\t%s\n' "$source_name" "$skill_id"
      fi
    done
  done | sort -u >"$overlaps_tmp"

  cat "$overlaps_tmp"
  rm -f "$managed_tmp" "$overlaps_tmp"
}

print_managed_external_overlap_summary() {
  overlap_lines=$(managed_external_overlap_lines)
  overlap_count=$(printf '%s\n' "$overlap_lines" | awk 'NF { count++ } END { print count + 0 }')
  printf 'external selection overlap: count=%s\n' "$overlap_count"
  if [ "$overlap_count" -gt 0 ]; then
    printf '%s\n' "$overlap_lines" | while IFS=$(printf '\t') read -r source_name skill_id; do
      [ -n "$source_name" ] || continue
      warn "  $source_name: $skill_id"
    done
  fi
}

managed_catalog_runtime_targets() {
  cat <<'EOF'
claude|.claude|CLAUDE.md
codex|.codex|AGENTS.md
cursor|.cursor|AGENTS.md
opencode|.opencode|CLAUDE.md
openclaw|.openclaw|CLAUDE.md
EOF
}

copy_managed_catalog_file() {
  source_path="$1"
  destination_path="$2"
  mkdir -p "$(dirname "$destination_path")"
  cp "$source_path" "$destination_path"
}

sync_managed_catalog_runtime_assets() {
  tracked_dir=$(tracked_catalog_dir)
  [ -d "$tracked_dir" ] || fail "Tracked catalog missing: $tracked_dir. Run 'mise run stage-catalog' first."

  instructions_source=$(tracked_catalog_instructions_path)
  agents_source=$(tracked_catalog_agents_root)
  commands_source=$(tracked_catalog_commands_root)
  rules_source=$(tracked_catalog_rules_root)

  managed_catalog_runtime_targets | while IFS='|' read -r _target_name target_dir config_name; do
    target_root="$HOME/$target_dir"
    mkdir -p "$target_root"

    if [ -f "$instructions_source" ]; then
      copy_managed_catalog_file "$instructions_source" "$target_root/$config_name"
    fi

    if [ -d "$agents_source" ]; then
      mkdir -p "$target_root/agents"
      cp -R "$agents_source"/. "$target_root/agents"
    fi

    if [ -d "$commands_source" ]; then
      mkdir -p "$target_root/commands"
      cp -R "$commands_source"/. "$target_root/commands"
    fi

    if [ -d "$rules_source" ]; then
      mkdir -p "$target_root/rules"
      cp -R "$rules_source"/. "$target_root/rules"
    fi
  done
}

cmd_validate_catalog() {
  ensure_workspace_repo
  ensure_workspace_scaffold

  has_failure=0
  source_skill_ids=$(managed_skill_ids)
  source_agent_paths=$(managed_agent_relative_paths)
  source_command_paths=$(managed_command_relative_paths)
  source_rule_paths=$(managed_rule_relative_paths)
  tracked_manifest="$(tracked_catalog_dir)/apm.yml"
  tracked_readme="$(tracked_catalog_dir)/README.md"
  tracked_instructions="$(tracked_catalog_instructions_path)"

  expected_dir=$(mktemp -d "${TMPDIR:-/tmp}/apm-catalog-expected.XXXXXX")
  write_catalog_manifest_template "$expected_dir"
  write_catalog_readme "$expected_dir"

  if [ ! -f "$tracked_manifest" ]; then
    error "Tracked catalog manifest is missing: $tracked_manifest"
    has_failure=1
  elif ! cmp -s "$tracked_manifest" "$expected_dir/apm.yml"; then
    error "Tracked catalog manifest is not normalized"
    has_failure=1
  fi

  if [ ! -f "$tracked_readme" ]; then
    error "Tracked catalog README is missing: $tracked_readme"
    has_failure=1
  elif ! cmp -s "$tracked_readme" "$expected_dir/README.md"; then
    error "Tracked catalog README is not normalized"
    has_failure=1
  fi

  rm -rf "$expected_dir"

  if ! manifest_has_catalog_reference; then
    error "Global apm.yml is missing the managed catalog ref"
    has_failure=1
  fi

  if [ ! -f "$tracked_instructions" ]; then
    error "Tracked catalog is missing instructions: $tracked_instructions"
    has_failure=1
  fi

  for required_root in "$(tracked_catalog_skills_root):skills" "$(tracked_catalog_agents_root):agents" "$(tracked_catalog_commands_root):commands" "$(tracked_catalog_rules_root):rules"; do
    root_path=${required_root%%:*}
    root_label=${required_root#*:}
    if [ ! -d "$root_path" ]; then
      error "Tracked catalog is missing $root_label: $root_path"
      has_failure=1
    fi
  done

  if [ -z "$(printf '%s\n' "$source_skill_ids" | awk 'NF { print; exit }')" ]; then
    error "Tracked catalog has no managed skills"
    has_failure=1
  fi

  [ "$has_failure" -eq 0 ] || fail "Catalog validation failed"
  source_skill_count=$(printf '%s\n' "$source_skill_ids" | awk 'NF { count++ } END { print count + 0 }')
  source_agent_count=$(printf '%s\n' "$source_agent_paths" | awk 'NF { count++ } END { print count + 0 }')
  source_command_count=$(printf '%s\n' "$source_command_paths" | awk 'NF { count++ } END { print count + 0 }')
  source_rule_count=$(printf '%s\n' "$source_rule_paths" | awk 'NF { count++ } END { print count + 0 }')
  log "Catalog validation passed ($source_skill_count skills, $source_agent_count agents, $source_command_count commands, $source_rule_count rules)"
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
    printf 'branch: %s\n' "$(git branch --show-current 2>/dev/null || printf detached)"
    printf 'remote:\n'
    git remote -v || true
    printf 'targets:\n'
    managed_catalog_runtime_targets | while IFS='|' read -r target_name target_dir config_name; do
      target_root="$HOME/$target_dir"
      if [ -e "$target_root/$config_name" ]; then config_state=present; else config_state=missing; fi
      if [ -e "$target_root/agents" ]; then agents_state=present; else agents_state=missing; fi
      if [ -e "$target_root/commands" ]; then commands_state=present; else commands_state=missing; fi
      if [ -e "$target_root/rules" ]; then rules_state=present; else rules_state=missing; fi
      if [ -e "$target_root/skills" ]; then skills_state=present; else skills_state=missing; fi
      printf '  %s: config=%s agents=%s commands=%s rules=%s skills=%s\n' "$target_name" "$config_state" "$agents_state" "$commands_state" "$rules_state" "$skills_state"
    done
    printf 'external pins: unpinned=%s\n' "$(unpinned_external_references | awk 'NF { count++ } END { print count + 0 }')"
    print_managed_external_overlap_summary
    print_catalog_summary
    apm deps list -g
  )
}

cmd_seed_catalog_build() {
  skill_ids=$(managed_skill_ids)
  ensure_workspace_repo
  ensure_workspace_scaffold
  ensure_workspace_mise_file

  reset_catalog_build_dir
  write_catalog_manifest_template "$(catalog_build_dir)"
  write_catalog_readme "$(catalog_build_dir)"
  copy_managed_instructions_into_catalog "$(catalog_build_instructions_path)"
  copy_managed_agent_assets_into_catalog "$(catalog_build_agents_root)"
  copy_managed_command_assets_into_catalog "$(catalog_build_commands_root)"
  copy_managed_rule_assets_into_catalog "$(catalog_build_rules_root)"

  printf '%s\n' "$skill_ids" | while IFS= read -r skill_id; do
    [ -n "$skill_id" ] || continue
    copy_managed_skill_into_catalog "$skill_id" "$(catalog_build_skills_root)"
  done

  log "Seeded catalog build at ~/.apm/.catalog-build/$CATALOG_DIR_NAME from: $(printf '%s' "$skill_ids" | tr '\n' ',' | sed 's/,$//; s/,/, /g')"
}

cmd_bundle_catalog() {
  cmd_seed_catalog_build "$@"
  log "Built catalog package at ~/.apm/.catalog-build/$CATALOG_DIR_NAME"
}

cmd_stage_catalog() {
  cmd_bundle_catalog "$@"

  tracked_dir=$(tracked_catalog_dir)
  reset_tracked_catalog_dir
  cp -R "$(catalog_build_dir)"/. "$tracked_dir"

  reference=$(tracked_catalog_reference)
  log "Updated ~/.apm/catalog at $tracked_dir"
  log "Candidate upstream ref: $reference"
  log "Push the updated apm-workspace repo before using 'apm install -g $reference'."
}

cmd_register_catalog() {
  require_apm
  skill_ids=$(managed_skill_ids)
  ensure_workspace_repo
  ensure_workspace_scaffold
  ensure_workspace_mise_file
  assert_tracked_catalog_published
  cmd_validate_catalog

  remove_internal_target_links "$skill_ids"

  reference=$(tracked_catalog_reference)
  run_workspace_install_command -g "$reference"
  normalize_workspace_gitignore
  sync_managed_catalog_runtime_assets
  log "Registered catalog from upstream ref: $reference"
}

assert_catalog_release_ready() {
  local dirty tracking_info remote_name branch_name upstream unpushed

  ensure_workspace_repo

  dirty=$(git -C "$WORKSPACE_DIR" status --porcelain 2>/dev/null) || fail "Failed to inspect git status for $WORKSPACE_DIR"
  if [[ -n "${dirty//$'\n'/}" ]]; then
    fail "Working tree is dirty after stage-catalog. Commit or stash changes, push the branch, then rerun catalog:release."
  fi

  tracking_info=$(workspace_tracking_info)
  remote_name=${tracking_info%%"$(printf '\036')"*}
  branch_name=${tracking_info#*"$(printf '\036')"}
  upstream="$remote_name/$branch_name"

  unpushed=$(git -C "$WORKSPACE_DIR" rev-list "$upstream..HEAD" 2>/dev/null) || fail "Failed to compare HEAD against $upstream"
  if [[ -n "${unpushed//$'\n'/}" ]]; then
    fail "Branch has commits not on $upstream. Push before running catalog:release."
  fi
}

cmd_release_catalog() {
  require_apm
  ensure_workspace_repo
  ensure_workspace_scaffold
  ensure_workspace_mise_file

  cmd_stage_catalog "$@"
  assert_catalog_release_ready
  cmd_register_catalog "$@"
}

cmd_smoke_catalog() {
  require_apm
  skill_ids=$(managed_skill_ids)

  cmd_bundle_catalog "$@"

  temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/apm-catalog-smoke.XXXXXX")
  (
    cd "$temp_dir"
    apm install "$(catalog_build_dir)" --target codex
  ) || fail "apm install failed for catalog smoke test. Temp workspace: $temp_dir"

  printf '%s\n' "$skill_ids" | while IFS= read -r skill_id; do
    [ -n "$skill_id" ] || continue
    relative_path=$(skill_id_to_manifest_path "$skill_id")
    if [ ! -f "$temp_dir/.agents/skills/$relative_path/SKILL.md" ]; then
      fail "Smoke test failed: expected installed skill file missing: $temp_dir/.agents/skills/$relative_path/SKILL.md"
    fi

    expected_files=$(relative_file_list "$(catalog_build_skills_root)/$relative_path")
    actual_files=$(relative_file_list "$temp_dir/.agents/skills/$relative_path")
    if [ "$expected_files" != "$actual_files" ]; then
      fail "Smoke test failed: installed skill tree for $skill_id differed from catalog."
    fi
  done

  rm -rf "$temp_dir"
  log "Smoke verified catalog via temp project install: $(printf '%s' "$skill_ids" | tr '\n' ',' | sed 's/,$//; s/,/, /g')"
}

cmd_migrate_external() {
  require_apm
  ensure_workspace_repo
  ensure_workspace_scaffold
  ensure_workspace_mise_file

  requested_sources=("$@")
  requested_source_count=${#requested_sources[@]}
  found_sources=0
  matched_sources=0
  sources_cache=$(mktemp "${TMPDIR:-/tmp}/apm-external-sources.XXXXXX")
  references=()
  registration_messages=()
  declare -A seen_references=()
  declare -A manifest_references=()
  parse_external_sources >"$sources_cache"

  while IFS= read -r manifest_reference; do
    [ -n "$manifest_reference" ] || continue
    manifest_references["$manifest_reference"]=1
  done <<EOF
$(manifest_reference_keys)
EOF

  while IFS=$(printf '\036') read -r source_name source_url base_dir id_prefix catalogs_value selected_value; do
    [ -n "$source_name" ] || continue
    found_sources=1

    if [ "$requested_source_count" -gt 0 ]; then
      include_source=0
      for requested_source in "${requested_sources[@]}"; do
        if [ "$requested_source" = "$source_name" ]; then
          include_source=1
          break
        fi
      done
      [ "$include_source" -eq 1 ] || continue
    fi

    matched_sources=1
    checkout_path=$(external_source_checkout_path "$source_name" "$source_url")

    old_ifs=$IFS
    IFS=$(printf '\034')
    read -r -a selected_skills <<<"$selected_value"
    IFS=$old_ifs
    for skill_id in "${selected_skills[@]}"; do
      if internal_skill_exists "$skill_id"; then
        log "Skipping $skill_id from $source_name: managed catalog already owns this id"
        continue
      fi

      reference=$(external_skill_reference "$source_url" "$checkout_path" "$source_name" "$base_dir" "$id_prefix" "$catalogs_value" "$skill_id")
      base_reference=${reference%%#*}
      if [ -n "${manifest_references[$reference]+x}" ] || [ -n "${manifest_references[$base_reference]+x}" ]; then
        log "Skipping $skill_id from $source_name: already registered as $base_reference"
        continue
      fi

      if [ -z "${seen_references[$reference]+x}" ]; then
        references+=("$reference")
        seen_references["$reference"]=1
        manifest_references["$reference"]=1
        manifest_references["$base_reference"]=1
      fi
      registration_messages+=("Registered external skill $skill_id from $source_name as $reference")
    done
  done <"$sources_cache"

  rm -f "$sources_cache"

  [ "$found_sources" -eq 1 ] || fail "No external skill sources found in $EXTERNAL_SOURCES_FILE"

  if [ "$requested_source_count" -gt 0 ] && [ "$matched_sources" -ne 1 ]; then
    fail "None of the requested external sources were found in $EXTERNAL_SOURCES_FILE"
  fi

  if [ "${#references[@]}" -gt 0 ]; then
    run_workspace_install_command -g "${references[@]}"
    for message in "${registration_messages[@]}"; do
      log "$message"
    done
  else
    log "No external skills selected for registration."
  fi

  cmd_pin_external
}

cmd_help() {
  cat <<EOF
Usage: scripts/apm-workspace.sh <command> [args...]

Commands:
  bootstrap          Ensure ~/.apm checkout + apm.yml + mise.toml are ready
  inject-mise        Copy or refresh the managed ~/.apm/mise.toml template
  apply              Deploy user-scope-compatible dependencies and compile Codex output
  update             Pull clean checkout, update deps, then apply
  list               Show APM global dependencies
  pin-external       Pin external manifest refs to lockfile commits
  validate           Validate the ~/.apm workspace
  validate-catalog   Fail when ~/.apm/catalog is not normalized or missing required assets
  doctor             Print workspace and target state
  bundle-catalog     Build ~/.apm/.catalog-build/catalog as the catalog package artifact
  stage-catalog      Rewrite ~/.apm/catalog into its normalized publishable layout and print its upstream ref
  register-catalog   Install the catalog ref after commit/push
  release-catalog    Stage, require a clean pushed branch, then install the catalog ref
  smoke-catalog      Smoke-test the generated catalog package via temp project install
  migrate-external   Register selected external skills by upstream reference

Environment overrides:
  APM_WORKSPACE_DIR
  APM_WORKSPACE_REPO
  APM_WORKSPACE_NAME
  APM_CODEX_OUTPUT
  APM_BOOTSTRAP_FORCE_MISE=1
EOF
}

case "$COMMAND" in
  bootstrap) cmd_bootstrap "$@" ;;
  inject-mise) cmd_inject_mise ;;
  apply) cmd_apply ;;
  update) cmd_update ;;
  list) cmd_list ;;
  pin-external) cmd_pin_external ;;
  validate) cmd_validate ;;
  validate-catalog) cmd_validate_catalog ;;
  doctor) cmd_doctor ;;
  bundle-catalog) cmd_bundle_catalog "$@" ;;
  stage-catalog) cmd_stage_catalog "$@" ;;
  register-catalog) cmd_register_catalog "$@" ;;
  release-catalog) cmd_release_catalog "$@" ;;
  smoke-catalog) cmd_smoke_catalog "$@" ;;
  migrate-external) cmd_migrate_external "$@" ;;
  help | -h | --help) cmd_help ;;
  *)
    fail "unknown command: $COMMAND"
    ;;
esac
