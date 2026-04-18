#!/bin/sh
set -eu

COMMAND="${1:-help}"
if [ "$#" -gt 0 ]; then
  shift
fi

REPO_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
WORKSPACE_DIR="${APM_WORKSPACE_DIR:-$HOME/.apm}"
WORKSPACE_REPO="${APM_WORKSPACE_REPO:-https://github.com/jey3dayo/apm-workspace.git}"
INTERNAL_PROFILE="${APM_INTERNAL_PROFILE:-first-batch}"
LEGACY_SKILLS_DIR="$REPO_ROOT/agents/src/skills"
INTERNAL_PILOT_INVENTORY_FILE="$REPO_ROOT/agents/src/internal-apm-$INTERNAL_PROFILE.txt"
EXTERNAL_SOURCES_FILE="$REPO_ROOT/nix/agent-skills-sources.nix"
CODEX_OUTPUT="${APM_CODEX_OUTPUT:-$HOME/.codex/AGENTS.md}"
MISE_TEMPLATE="$REPO_ROOT/templates/apm-workspace/mise.toml"
MISE_DESTINATION="$WORKSPACE_DIR/mise.toml"
INTERNAL_SEED_DIR="$WORKSPACE_DIR/.internal-seed"
INTERNAL_BUNDLE_NAME="internal-$INTERNAL_PROFILE"
TRACKED_INTERNAL_BUNDLES_DIR_NAME="internal-bundles"
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

case "$INTERNAL_PROFILE" in
  [A-Za-z0-9][A-Za-z0-9._-]*) ;;
  *)
    fail "Invalid internal profile: $INTERNAL_PROFILE"
    ;;
esac

set_internal_profile_context() {
  profile_name="$1"
  case "$profile_name" in
    [A-Za-z0-9][A-Za-z0-9._-]*) ;;
    *)
      fail "Invalid internal profile: $profile_name"
      ;;
  esac

  INTERNAL_PROFILE="$profile_name"
  INTERNAL_PILOT_INVENTORY_FILE="$REPO_ROOT/agents/src/internal-apm-$INTERNAL_PROFILE.txt"
  INTERNAL_BUNDLE_NAME="internal-$INTERNAL_PROFILE"
}

resolve_internal_command_args() {
  if [ "$#" -ge 2 ] && [ "$1" = "--profile" ]; then
    set_internal_profile_context "$2"
    shift 2
  fi

  printf '%s\n' "$@"
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

validate_skill_path_segments() {
  original_value="$1"
  shift

  if [ "$#" -eq 0 ]; then
    fail "Invalid skill path: $original_value"
  fi

  for segment in "$@"; do
    case "$segment" in
      ""|.|..|*/*|*\\*)
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
      entries[3] = "/.internal-seed/"
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
  ensure_gitignore_entry '/.internal-seed/'

  if [ ! -f "$WORKSPACE_DIR/apm.yml" ]; then
    log "Writing bootstrap apm.yml in $WORKSPACE_DIR"
    write_workspace_manifest_template
  fi
}

internal_bundle_dir() {
  printf '%s/%s\n' "$INTERNAL_SEED_DIR" "$INTERNAL_BUNDLE_NAME"
}

internal_bundle_skills_root() {
  printf '%s/.apm/skills\n' "$(internal_bundle_dir)"
}

tracked_internal_bundles_dir() {
  printf '%s/%s\n' "$WORKSPACE_DIR" "$TRACKED_INTERNAL_BUNDLES_DIR_NAME"
}

tracked_internal_bundle_dir() {
  printf '%s/%s\n' "$(tracked_internal_bundles_dir)" "$INTERNAL_BUNDLE_NAME"
}

tracked_internal_bundle_relative_path() {
  printf '%s/%s\n' "$TRACKED_INTERNAL_BUNDLES_DIR_NAME" "$INTERNAL_BUNDLE_NAME"
}

write_internal_bundle_manifest_template() {
  bundle_dir=$(internal_bundle_dir)
  cat >"$bundle_dir/apm.yml" <<EOF
name: $INTERNAL_BUNDLE_NAME
version: 1.0.0
description: Generated internal bundled skills pilot for global APM migration
dependencies:
  apm: []
  mcp: []
scripts: {}
EOF
}

write_internal_bundle_readme() {
  bundle_dir=$(internal_bundle_dir)
  cat >"$bundle_dir/README.md" <<EOF
# $INTERNAL_BUNDLE_NAME Bundle

This bundle is generated from ~/.config internal bundled skills for the global APM migration pilot.

- Source inventory: \`~/.config/agents/src/internal-apm-$INTERNAL_PROFILE.txt\`
- Source skills: \`~/.config/agents/src/skills/<id>/\`
- Purpose: provide a valid APM package artifact for future publish/install work
- Current limitation: \`apm install -g <local-path>\` is rejected by APM 0.8.11 at user scope, so this bundle is for validation and publication prep only
EOF
}

reset_internal_bundle_dir() {
  bundle_dir=$(internal_bundle_dir)
  rm -rf "$bundle_dir"
  mkdir -p "$(internal_bundle_skills_root)"
}

reset_tracked_internal_bundle_dir() {
  tracked_dir=$(tracked_internal_bundle_dir)
  rm -rf "$tracked_dir"
  mkdir -p "$tracked_dir"
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
      fail "Unsupported workspace remote URL for internal bundle reference: $remote_url"
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
  [ -n "$current_branch" ] || fail "Cannot register internal bundle from a detached HEAD. Check out a tracking branch first."

  remote_name=$(git -C "$WORKSPACE_DIR" config --get "branch.$current_branch.remote" 2>/dev/null || true)
  merge_ref=$(git -C "$WORKSPACE_DIR" config --get "branch.$current_branch.merge" 2>/dev/null || true)
  [ -n "$remote_name" ] && [ -n "$merge_ref" ] || fail "Branch '$current_branch' has no upstream tracking branch. Push it first."

  merge_branch=${merge_ref#refs/heads/}
  printf '%s\036%s\n' "$remote_name" "$merge_branch"
}

tracked_internal_bundle_reference() {
  tracking_info=$(workspace_tracking_info)
  remote_name=${tracking_info%%$(printf '\036')*}
  branch_name=${tracking_info#*$(printf '\036')}
  printf '%s/%s#%s\n' "$(workspace_repo_reference "$remote_name")" "$(tracked_internal_bundle_relative_path)" "$branch_name"
}

assert_tracked_internal_bundle_published() {
  tracked_relative_path=$(tracked_internal_bundle_relative_path)
  tracked_dir=$(tracked_internal_bundle_dir)

  [ -d "$tracked_dir" ] || fail "Tracked internal bundle missing: $tracked_dir. Run 'mise run stage-internal' first."

  dirty=$(git -C "$WORKSPACE_DIR" status --porcelain -- "$tracked_relative_path" 2>/dev/null || true)
  [ -z "$dirty" ] || fail "Tracked internal bundle has uncommitted changes. Commit and push $tracked_relative_path before registering it."

  tracking_info=$(workspace_tracking_info)
  remote_name=${tracking_info%%$(printf '\036')*}
  branch_name=${tracking_info#*$(printf '\036')}
  upstream="$remote_name/$branch_name"
  unpushed=$(git -C "$WORKSPACE_DIR" rev-list "$upstream..HEAD" -- "$tracked_relative_path" 2>/dev/null || true)
  [ -z "$unpushed" ] || fail "Tracked internal bundle has commits not on $upstream. Push the branch before registering it."
}

copy_internal_skill_into_bundle() {
  skill_id="$1"
  validate_skill_id "$skill_id"
  source_dir=$(legacy_skill_content_dir "$skill_id")

  if [ ! -d "$source_dir" ]; then
    fail "Legacy skill not found: $source_dir"
  fi

  destination_dir=$(internal_bundle_skills_root)
  old_ifs=$IFS
  IFS=':'
  set -- $skill_id
  IFS=$old_ifs
  validate_skill_path_segments "$skill_id" "$@"
  for segment in "$@"; do
    destination_dir="$destination_dir/$segment"
  done

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

copy_skill() {
  skill_id="$1"
  validate_skill_id "$skill_id"
  source_dir=$(legacy_skill_content_dir "$skill_id")
  package_relative_path=$(skill_id_to_manifest_path "$skill_id")
  destination_dir="$INTERNAL_SEED_DIR/$package_relative_path"

  if [ ! -d "$source_dir" ]; then
    fail "Legacy skill not found: $source_dir"
  fi

  if [ -e "$destination_dir" ]; then
    if [ "${APM_MIGRATE_FORCE:-0}" != "1" ]; then
      printf 'skipped\n'
      return 0
    fi

    rm -rf "$destination_dir"
  fi

  mkdir -p "$destination_dir"
  cp -R "$source_dir"/. "$destination_dir"
  printf 'seeded\n'
}

get_internal_pilot_skill_ids() {
  if [ ! -f "$INTERNAL_PILOT_INVENTORY_FILE" ]; then
    fail "Internal pilot inventory not found: $INTERNAL_PILOT_INVENTORY_FILE"
  fi

  awk '
    /^[[:space:]]*#/ { next }
    /^[[:space:]]*$/ { next }
    { print $1 }
  ' "$INTERNAL_PILOT_INVENTORY_FILE"
}

resolve_internal_skill_ids() {
  if [ "$#" -gt 0 ]; then
    for skill_id in "$@"; do
      validate_skill_id "$skill_id"
      printf '%s\n' "$skill_id"
    done
    return 0
  fi

  get_internal_pilot_skill_ids
}

get_internal_pilot_skill_ids_from_inventory() {
  inventory_file="$1"
  [ -f "$inventory_file" ] || fail "Internal pilot inventory not found: $inventory_file"

  awk '
    /^[[:space:]]*#/ { next }
    /^[[:space:]]*$/ { next }
    { print $1 }
  ' "$inventory_file"
}

get_all_internal_pilot_skill_ids() {
  inventory_dir="$REPO_ROOT/agents/src"
  [ -d "$inventory_dir" ] || return 0

  for inventory_file in "$inventory_dir"/internal-apm-*.txt; do
    [ -f "$inventory_file" ] || continue
    get_internal_pilot_skill_ids_from_inventory "$inventory_file"
  done | awk '!seen[$0]++'
}

internal_inventory_profiles() {
  inventory_dir="$REPO_ROOT/agents/src"
  [ -d "$inventory_dir" ] || return 0

  for inventory_file in "$inventory_dir"/internal-apm-*.txt; do
    [ -f "$inventory_file" ] || continue
    profile=$(basename "$inventory_file" .txt)
    profile=${profile#internal-apm-}
    printf '%s\t%s\n' "$profile" "$inventory_file"
  done | sort
}

legacy_internal_skill_ids() {
  [ -d "$LEGACY_SKILLS_DIR" ] || return 0

  for skill_dir in "$LEGACY_SKILLS_DIR"/*; do
    [ -d "$skill_dir" ] || continue
    basename "$skill_dir"
  done | sort
}

manifest_has_internal_bundle_reference() {
  profile="$1"
  manifest_path="$WORKSPACE_DIR/apm.yml"
  [ -f "$manifest_path" ] || return 1
  grep -q "jey3dayo/apm-workspace/internal-bundles/internal-$profile#main" "$manifest_path"
}

print_internal_inventory_coverage_summary() {
  listed_skill_ids=$(get_all_internal_pilot_skill_ids)
  legacy_skill_ids=$(legacy_internal_skill_ids)

  listed_count=$(printf '%s\n' "$listed_skill_ids" | awk 'NF { count++ } END { print count + 0 }')
  source_count=$(printf '%s\n' "$legacy_skill_ids" | awk 'NF { count++ } END { print count + 0 }')
  if [ "$listed_count" -eq 0 ] && [ "$source_count" -eq 0 ]; then
    return 0
  fi

  unassigned_skill_ids=$(comm -23 <(printf '%s\n' "$legacy_skill_ids" | awk 'NF' | sort) <(printf '%s\n' "$listed_skill_ids" | awk 'NF' | sort))
  orphaned_skill_ids=$(comm -13 <(printf '%s\n' "$legacy_skill_ids" | awk 'NF' | sort) <(printf '%s\n' "$listed_skill_ids" | awk 'NF' | sort))
  if [ -z "$unassigned_skill_ids" ] && [ -z "$orphaned_skill_ids" ]; then
    coverage_state=ok
  else
    coverage_state=drift
  fi

  printf 'internal inventory: listed=%s source=%s status=%s\n' "$listed_count" "$source_count" "$coverage_state"
  if [ -n "$unassigned_skill_ids" ]; then
    printf '  unassigned: %s\n' "$(printf '%s' "$unassigned_skill_ids" | paste -sd ', ' -)"
  fi
  if [ -n "$orphaned_skill_ids" ]; then
    printf '  missing-source: %s\n' "$(printf '%s' "$orphaned_skill_ids" | paste -sd ', ' -)"
  fi
}

print_internal_profile_summary() {
  profiles=$(internal_inventory_profiles)
  [ -n "$profiles" ] || return 0

  printf 'internal profiles:\n'
  printf '%s\n' "$profiles" | while IFS="$(printf '\t')" read -r profile inventory_file; do
    [ -n "$profile" ] || continue
    skill_count=$(get_internal_pilot_skill_ids_from_inventory "$inventory_file" | awk 'END { print NR + 0 }')
    tracked_manifest="$WORKSPACE_DIR/internal-bundles/internal-$profile/apm.yml"
    if [ -f "$tracked_manifest" ]; then
      tracked_state=yes
    else
      tracked_state=no
    fi
    if manifest_has_internal_bundle_reference "$profile"; then
      manifest_state=yes
    else
      manifest_state=no
    fi
    printf '  %-12s skills=%-3s tracked=%-3s manifest=%-3s\n' "$profile" "$skill_count" "$tracked_state" "$manifest_state"
  done
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
  [ -d "$LEGACY_SKILLS_DIR/$relative_path" ]
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
  set -- $catalogs_value
  IFS=$old_ifs
  for catalog_entry in "$@"; do
    catalog_path=${catalog_entry#*$(printf '\035')}
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
      "$relative_skill_path"|*/"$relative_skill_path")
        printf '%s\n' "$candidate_dir"
        return 0
        ;;
    esac
  done <<EOF
$(find "$checkout_path" -type f -name SKILL.md 2>/dev/null)
EOF

  fail "Could not find external skill '$skill_id' in source '$source_name'"
}

copy_external_skill() {
  source_dir="$1"
  skill_id="$2"
  package_relative_path=$(skill_id_to_manifest_path "$skill_id")
  destination_dir="$PACKAGES_DIR/$package_relative_path"
  destination_parent=$(dirname "$destination_dir")

  if [ -e "$destination_dir" ]; then
    if [ "${APM_MIGRATE_FORCE:-0}" != "1" ]; then
      fail "$destination_dir already exists. Set APM_MIGRATE_FORCE=1 to replace it."
    fi
    rm -rf "$destination_dir"
  fi

  mkdir -p "$destination_parent"
  cp -R "$source_dir" "$destination_dir"
  printf '%s\n' "$package_relative_path"
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
  repo=${repo_info%%$(printf '\036')*}
  ref=${repo_info#*$(printf '\036')}
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
  grep -Eq '\[[xX]\][[:space:]]+[1-9][0-9]* packages failed:' "$output_file" ||
    grep -Eq 'Installed .* with [1-9][0-9]* error\(s\)\.' "$output_file"
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
  cmd_validate_internal

  if manifest_has_local_packages; then
    fail "apm 0.8.11 cannot deploy ./packages/* dependencies at user scope yet. Packages are seeded in ~/.apm/apm.yml, but rollout should stay on the legacy path until a later phase."
  fi

  remove_internal_target_links "$(get_all_internal_pilot_skill_ids)"
  run_workspace_install_command -g
  normalize_workspace_gitignore
  compile_codex
}

cmd_update() {
  require_apm
  ensure_workspace_repo
  refresh_workspace_checkout
  ensure_workspace_scaffold
  cmd_validate_internal

  if manifest_has_local_packages; then
    fail "apm 0.8.11 cannot deploy ./packages/* dependencies at user scope yet. Update stopped before user-scope install; keep using the legacy deploy path for now."
  fi

  remove_internal_target_links "$(get_all_internal_pilot_skill_ids)"
  (
    cd "$WORKSPACE_DIR"
    apm deps update -g
  )
  run_workspace_install_command -g
  normalize_workspace_gitignore
  compile_codex
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
      if (ref ~ /^jey3dayo\/apm-workspace\/internal-bundles\//) {
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

tracked_internal_bundle_skill_ids() {
  profile="$1"
  skills_root="$WORKSPACE_DIR/internal-bundles/internal-$profile/.apm/skills"
  [ -d "$skills_root" ] || return 0

  find "$skills_root" -type f -name SKILL.md | while IFS= read -r skill_file; do
    skill_dir=$(dirname "$skill_file")
    relative_path=${skill_dir#"$skills_root"/}
    [ -n "$relative_path" ] || continue
    printf '%s\n' "${relative_path//\//:}"
  done | sort -u
}

cmd_validate_internal() {
  ensure_workspace_repo
  ensure_workspace_scaffold

  has_failure=0
  listed_skill_ids=$(get_all_internal_pilot_skill_ids)
  legacy_skill_ids=$(legacy_internal_skill_ids)
  legacy_tmp=$(mktemp)
  listed_tmp=$(mktemp)
  unassigned_tmp=$(mktemp)
  orphaned_tmp=$(mktemp)
  printf '%s\n' "$legacy_skill_ids" | awk 'NF' | sort >"$legacy_tmp"
  printf '%s\n' "$listed_skill_ids" | awk 'NF' | sort >"$listed_tmp"
  comm -23 "$legacy_tmp" "$listed_tmp" >"$unassigned_tmp"
  comm -13 "$legacy_tmp" "$listed_tmp" >"$orphaned_tmp"
  unassigned_skill_ids=$(cat "$unassigned_tmp")
  orphaned_skill_ids=$(cat "$orphaned_tmp")

  if [ -n "$unassigned_skill_ids" ]; then
    error "Unassigned legacy skills: $(printf '%s\n' "$unassigned_skill_ids" | awk 'BEGIN{ORS=""} NF{if(seen++) printf ", "; printf "%s", $0}')"
    has_failure=1
  fi
  if [ -n "$orphaned_skill_ids" ]; then
    error "Inventory entries without source directories: $(printf '%s\n' "$orphaned_skill_ids" | awk 'BEGIN{ORS=""} NF{if(seen++) printf ", "; printf "%s", $0}')"
    has_failure=1
  fi

  while IFS="$(printf '\t')" read -r profile inventory_file; do
    [ -n "$profile" ] || continue
    tracked_manifest="$WORKSPACE_DIR/internal-bundles/internal-$profile/apm.yml"
    if [ ! -f "$tracked_manifest" ]; then
      error "Tracked internal bundle manifest is missing for profile '$profile': $tracked_manifest"
      has_failure=1
      continue
    fi

    if ! manifest_has_internal_bundle_reference "$profile"; then
      error "Global apm.yml is missing the internal bundle ref for profile '$profile'"
      has_failure=1
    fi

    expected_skill_ids=$(get_internal_pilot_skill_ids_from_inventory "$inventory_file")
    tracked_skill_ids=$(tracked_internal_bundle_skill_ids "$profile")
    expected_tmp=$(mktemp)
    tracked_tmp=$(mktemp)
    missing_tmp=$(mktemp)
    extra_tmp=$(mktemp)
    printf '%s\n' "$expected_skill_ids" | awk 'NF' | sort >"$expected_tmp"
    printf '%s\n' "$tracked_skill_ids" | awk 'NF' | sort >"$tracked_tmp"
    comm -23 "$expected_tmp" "$tracked_tmp" >"$missing_tmp"
    comm -13 "$expected_tmp" "$tracked_tmp" >"$extra_tmp"
    missing_tracked_skill_ids=$(cat "$missing_tmp")
    extra_tracked_skill_ids=$(cat "$extra_tmp")

    if [ -n "$missing_tracked_skill_ids" ]; then
      error "Tracked bundle for profile '$profile' is missing skills: $(printf '%s\n' "$missing_tracked_skill_ids" | awk 'BEGIN{ORS=""} NF{if(seen++) printf ", "; printf "%s", $0}')"
      has_failure=1
    fi
    if [ -n "$extra_tracked_skill_ids" ]; then
      error "Tracked bundle for profile '$profile' has unexpected skills: $(printf '%s\n' "$extra_tracked_skill_ids" | awk 'BEGIN{ORS=""} NF{if(seen++) printf ", "; printf "%s", $0}')"
      has_failure=1
    fi

    rm -f "$expected_tmp" "$tracked_tmp" "$missing_tmp" "$extra_tmp"
  done <<EOF
$(internal_inventory_profiles)
EOF

  rm -f "$legacy_tmp" "$listed_tmp" "$unassigned_tmp" "$orphaned_tmp"

  [ "$has_failure" -eq 0 ] || fail "Internal APM validation failed"

  listed_count=$(printf '%s\n' "$listed_skill_ids" | awk 'NF { count++ } END { print count + 0 }')
  profile_count=$(internal_inventory_profiles | awk 'NF { count++ } END { print count + 0 }')
  log "Internal APM validation passed ($listed_count skills across $profile_count profiles)"
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
    for path in "$HOME/.claude/skills" "$HOME/.cursor/skills" "$HOME/.opencode/skills" "$HOME/.codex/AGENTS.md"; do
      if [ -e "$path" ]; then
        printf '  present  %s\n' "$path"
      else
        printf '  missing  %s\n' "$path"
      fi
    done
    printf 'external pins: unpinned=%s\n' "$(unpinned_external_references | awk 'NF { count++ } END { print count + 0 }')"
    print_internal_inventory_coverage_summary
    print_internal_profile_summary
    apm deps list -g
  )
}

cmd_migrate() {
  warn "migrate is now a compatibility alias. Prefer 'migrate-internal' for internal pilot work."
  cmd_migrate_internal "$@"
}

cmd_migrate_internal() {
  skill_ids=$(resolve_internal_command_args "$@" | resolve_internal_skill_ids)
  [ -n "$skill_ids" ] || fail "Internal pilot inventory is empty: $INTERNAL_PILOT_INVENTORY_FILE"

  ensure_workspace_repo
  ensure_workspace_scaffold
  ensure_workspace_mise_file

  if [ "$#" -eq 0 ]; then
    log "Using internal pilot inventory ($INTERNAL_PROFILE): $(printf '%s' "$skill_ids" | tr '\n' ',' | sed 's/,$//; s/,/, /g')"
  fi

  printf '%s\n' "$skill_ids" | while IFS= read -r skill_id; do
    [ -n "$skill_id" ] || continue
    status=$(copy_skill "$skill_id")
    if [ "$status" = "seeded" ]; then
      log "Seeded internal skill $skill_id into ~/.apm/.internal-seed/$skill_id for pilot/reference only. Global apm.yml was left unchanged."
    else
      log "Skipped internal skill $skill_id because ~/.apm/.internal-seed/$skill_id already exists. Set APM_MIGRATE_FORCE=1 to replace it."
    fi
  done
}

cmd_bundle_internal() {
  skill_ids=$(resolve_internal_command_args "$@" | resolve_internal_skill_ids)
  [ -n "$skill_ids" ] || fail "Internal pilot inventory is empty: $INTERNAL_PILOT_INVENTORY_FILE"

  ensure_workspace_repo
  ensure_workspace_scaffold
  ensure_workspace_mise_file

  reset_internal_bundle_dir
  write_internal_bundle_manifest_template
  write_internal_bundle_readme

  printf '%s\n' "$skill_ids" | while IFS= read -r skill_id; do
    [ -n "$skill_id" ] || continue
    copy_internal_skill_into_bundle "$skill_id"
  done

  log "Built internal bundle at ~/.apm/.internal-seed/$INTERNAL_BUNDLE_NAME from: $(printf '%s' "$skill_ids" | tr '\n' ',' | sed 's/,$//; s/,/, /g')"
}

cmd_stage_internal() {
  skill_ids=$(resolve_internal_command_args "$@" | resolve_internal_skill_ids)
  [ -n "$skill_ids" ] || fail "Internal pilot inventory is empty: $INTERNAL_PILOT_INVENTORY_FILE"

  cmd_bundle_internal "$@"

  tracked_dir=$(tracked_internal_bundle_dir)
  reset_tracked_internal_bundle_dir
  cp -R "$(internal_bundle_dir)"/. "$tracked_dir"

  reference=$(tracked_internal_bundle_reference)
  log "Staged repo-tracked internal bundle at $tracked_dir"
  log "Candidate upstream ref: $reference"
  log "Push the updated apm-workspace repo before using 'apm install -g $reference'."
}

cmd_register_internal() {
  require_apm
  skill_ids=$(get_all_internal_pilot_skill_ids)
  [ -n "$skill_ids" ] || fail "Internal pilot inventory is empty: $INTERNAL_PILOT_INVENTORY_FILE"
  ensure_workspace_repo
  ensure_workspace_scaffold
  ensure_workspace_mise_file
  assert_tracked_internal_bundle_published
  cmd_validate_internal

  remove_internal_target_links "$skill_ids"

  reference=$(tracked_internal_bundle_reference)
  run_workspace_install_command -g "$reference"
  normalize_workspace_gitignore
  log "Registered internal bundle from upstream ref: $reference"
}

cmd_smoke_internal() {
  require_apm
  skill_ids=$(resolve_internal_command_args "$@" | resolve_internal_skill_ids)
  [ -n "$skill_ids" ] || fail "Internal pilot inventory is empty: $INTERNAL_PILOT_INVENTORY_FILE"

  cmd_bundle_internal "$@"

  temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/apm-internal-bundle-smoke.XXXXXX")
  (
    cd "$temp_dir"
    apm install "$(internal_bundle_dir)" --target codex
  ) || fail "apm install failed for internal bundle smoke test. Temp workspace: $temp_dir"

  printf '%s\n' "$skill_ids" | while IFS= read -r skill_id; do
    [ -n "$skill_id" ] || continue
    relative_path=$(skill_id_to_manifest_path "$skill_id")
    if [ ! -f "$temp_dir/.agents/skills/$relative_path/SKILL.md" ]; then
      fail "Smoke test failed: expected installed skill file missing: $temp_dir/.agents/skills/$relative_path/SKILL.md"
    fi

    expected_files=$(relative_file_list "$(internal_bundle_skills_root)/$relative_path")
    actual_files=$(relative_file_list "$temp_dir/.agents/skills/$relative_path")
    if [ "$expected_files" != "$actual_files" ]; then
      fail "Smoke test failed: installed skill tree for $skill_id differed from bundle."
    fi
  done

  rm -rf "$temp_dir"
  log "Smoke verified internal bundle via temp project install: $(printf '%s' "$skill_ids" | tr '\n' ',' | sed 's/,$//; s/,/, /g')"
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
        log "Skipping $skill_id from $source_name: internal bundled skill already owns this id"
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
  bootstrap          Ensure ~/.apm checkout + apm.yml + mise.toml are ready
  inject-mise        Copy or refresh the managed ~/.apm/mise.toml template
  apply              Deploy user-scope-compatible dependencies and compile Codex output
  update             Pull clean checkout, update deps, then apply
  list               Show APM global dependencies
  pin-external       Pin external manifest refs to lockfile commits
  validate           Validate the ~/.apm workspace
  validate-internal  Fail on internal inventory / bundle / manifest drift
  doctor             Print workspace and target state
  migrate            Compatibility alias for migrate-internal
  migrate-internal   Seed internal pilot skills into ~/.apm/.internal-seed/ without changing global apm.yml
  bundle-internal    Build ~/.apm/.internal-seed/internal-<profile> as a valid internal APM bundle artifact
  stage-internal     Copy the generated bundle into ~/.apm/internal-bundles/ and print its upstream ref
  register-internal  Install the staged internal bundle by upstream ref after commit/push
  smoke-internal     Smoke-test the generated internal bundle via temp project install
  migrate-external   Register selected external skills by upstream reference
  smoke              Validate script syntax and workspace template wiring

Environment overrides:
  APM_WORKSPACE_DIR
  APM_WORKSPACE_REPO
  APM_WORKSPACE_NAME
  APM_CODEX_OUTPUT
  APM_INTERNAL_PROFILE=first-batch
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
  pin-external) cmd_pin_external ;;
  validate) cmd_validate ;;
  validate-internal) cmd_validate_internal ;;
  doctor) cmd_doctor ;;
  migrate) cmd_migrate "$@" ;;
  migrate-internal) cmd_migrate_internal "$@" ;;
  bundle-internal) cmd_bundle_internal "$@" ;;
  stage-internal) cmd_stage_internal "$@" ;;
  register-internal) cmd_register_internal "$@" ;;
  smoke-internal) cmd_smoke_internal "$@" ;;
  migrate-external) cmd_migrate_external "$@" ;;
  smoke) cmd_smoke ;;
  help|-h|--help) cmd_help ;;
  *)
    fail "unknown command: $COMMAND"
    ;;
esac
