#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
dist_root="${repo_root}/agents/distributions/default"
skills_dir="${dist_root}/skills"

errors=0

fail() {
  printf 'ERROR: %s\n' "$1"
  errors=$((errors + 1))
}

if [ ! -d "${skills_dir}" ]; then
  fail "Missing skills directory: ${skills_dir}"
fi

if [ -d "${skills_dir}" ]; then
  while IFS= read -r -d '' link; do
    rel="${link#"${repo_root}"/}"
    fail "Symlink is not allowed in default skills: ${rel}"
  done < <(find "${skills_dir}" -type l -print0)

  skill_count=0
  for skill_path in "${skills_dir}"/*; do
    [ -d "${skill_path}" ] || continue
    skill_count=$((skill_count + 1))
    if [ ! -f "${skill_path}/SKILL.md" ] && [ ! -f "${skill_path}/skills/SKILL.md" ]; then
      rel="${skill_path#"${repo_root}"/}"
      fail "Missing SKILL.md: ${rel}/SKILL.md (or ${rel}/skills/SKILL.md)"
    fi
  done

  if [ "${skill_count}" -eq 0 ]; then
    fail "No skills found under ${skills_dir}"
  fi
fi

if [ "${errors}" -gt 0 ]; then
  printf 'Distribution validation failed with %d error(s).\n' "${errors}"
  exit 1
fi

printf 'Distribution validation passed.\n'
