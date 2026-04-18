---
name: apm-usage
description: Use when working with APM (Agent Package Manager) manifests, `~/.apm` global workspace flows, or migrating legacy bundled skills into `apm-workspace`.
---

# APM Usage

Derived from the upstream idea at:
<https://github.com/mizchi/chezmoi-dotfiles/blob/main/dot_claude/skills/apm-usage/>

## Overview

APM (Agent Package Manager) manages agent skills and related dependencies with a manifest such as `apm.yml`.

In this repository, the target architecture is now **APM global management via `~/.apm`**.  
`apm-workspace` is the intended source-of-truth repo, `~/.apm` is its local checkout, and `~/.apm/apm.yml` is the manifest used by daily install/update flows.

## Use This Skill When

- Editing or reviewing `apm.yml`
- Installing or updating agent skills with `apm`
- Migrating a legacy bundled skill from `agents/src/skills/` into `~/.apm`
- Explaining `apm install -g`, `apm deps update -g`, or Codex compile handling

## This Repository's Rule Of Thumb

Prefer `~/.apm` for day-to-day install / update / list / check when:

- The skill is part of day-to-day agent distribution in this environment
- The dependency should be managed by `apm install -g`
- The skill should live in `apm-workspace` and be deployable across machines

Treat `agents/src/skills/<name>/` as legacy only when:

- You are seeding a migration into `~/.apm/packages/<name>/`
- You need rollback while the APM path is still stabilizing
- CI is still validating the legacy Nix bundle

Do not assume `apm install -g` will deploy `~/.apm/.apm/skills` directly.

## Core Commands

```bash
# Install the APM CLI managed by mise
mise install

# Bootstrap ~/.apm checkout, manifest, and packages/
mise run skills:bootstrap

# Install everything declared in ~/.apm/apm.yml
mise run skills:install

# Update global dependencies in ~/.apm
mise run skills:update

# List installed global dependencies
mise run skills:list

# Validate workspace primitives
mise run apm:validate

# Check deployed target state
mise run skills:check

# One-time migration from legacy bundled skill
mise run skills:migrate -- apm-usage
```

## Important Global Constraint

According to the APM CLI reference, `apm install -g` uses user scope (`~/.apm/`) but **skips local `.apm/` content deployment at user scope**.

That means this is **not** the stable pattern for repo-owned global skills:

```text
~/.apm/.apm/skills/my-skill
```

Instead, use installable local packages under `~/.apm/packages/` and add them with global install:

```bash
cd ~/.apm
apm install -g ./packages/my-skill
```

This lets `~/.apm/apm.yml` stay the manifest source of truth while still deploying a repo-owned local package into `~/.claude/skills`, `~/.cursor/skills`, `~/.opencode/skills`, and Codex compile output.

`mise run skills:bootstrap` is expected to prepare an empty `apm-workspace` checkout all the way to:

- `~/.apm/` as the git checkout
- `~/.apm/apm.yml` as the manifest
- `~/.apm/packages/README.md` as the marker for repo-owned local packages

If `apm` itself is not installed yet, bootstrap should still prepare those files, and later commands should clearly tell you to run `mise install` before `skills:migrate` / `skills:install`.

## Migration Workflow

1. Bootstrap the workspace with `mise run skills:bootstrap`
2. Start with `mise run skills:migrate -- apm-usage`
3. This copies `agents/src/skills/apm-usage/` into `~/.apm/packages/apm-usage/` and runs `apm install -g ./packages/apm-usage`
4. From that point on, edit `~/.apm/packages/<skill-id>/`
5. Deploy with `mise run skills:install`
6. Validate with `mise run apm:validate`
7. If needed, fall back with `mise run skills:legacy:install`

## Legacy / Rollback Notes

- `skills:validate`, `skills:validate:internal`, `skills:check:sync`, and `skills:report` are legacy validation / reporting tasks kept for CI and compatibility in Phase 1
- `skills:add` is also still legacy and edits repo-local source definitions rather than `~/.apm`
- `skills:legacy:*` tasks are the explicit escape hatch if the APM path breaks
- `agents/src/skills/` should no longer be described as the long-term source of truth for agent distribution in this repo
- In this repo, install the APM CLI through `mise` rather than the official installer unless you are doing manual recovery
