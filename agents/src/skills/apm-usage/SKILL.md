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

In `.config`, keep APM responsibility minimal:

- bootstrap `~/.apm`
- inject managed `~/.apm/mise.toml`
- seed migration from legacy `agents/src/skills/`
- keep rollback-oriented legacy `agents:*` tasks

Daily APM operation should happen from `~/.apm`, not from `.config`.

## Core Commands

```bash
# From ~/.config: bootstrap only
cd ~/.config
mise run apm:bootstrap

# From ~/.apm: daily operation
cd ~/.apm
mise install
mise run migrate -- apm-usage
mise run apply
mise run validate
mise run doctor
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

This lets `~/.apm/apm.yml` stay the manifest source of truth while keeping repo-owned local packages under `~/.apm/packages/`.

`mise run apm:bootstrap` from `.config` is expected to prepare an empty `apm-workspace` checkout all the way to:

- `~/.apm/` as the git checkout
- `~/.apm/apm.yml` as the manifest
- `~/.apm/packages/README.md` as the marker for repo-owned local packages
- `~/.apm/mise.toml` as the injected task entrypoint

If `apm` itself is not installed yet, bootstrap should still prepare those files.  
After that, move into `~/.apm` and run `mise install`.

## Migration Workflow

1. Bootstrap the workspace with `cd ~/.config && mise run apm:bootstrap`
2. Move to `~/.apm` and run `mise install`
3. Start with `mise run migrate -- apm-usage`
4. This copies `agents/src/skills/apm-usage/` into `~/.apm/packages/apm-usage/` and runs workspace-scope `apm install ./packages/apm-usage`
5. From that point on, edit `~/.apm/packages/<skill-id>/`
6. Treat `~/.apm/apm.yml` + `~/.apm/packages/` as the source of truth
7. Keep the legacy deploy / rollback path available while APM user-scope local package support is still missing
8. Validate with `mise run validate`

## Legacy / Rollback Notes

- `agents:validate`, `agents:validate:internal`, `agents:check:sync`, and `agents:report` are legacy validation / reporting tasks kept for CI and compatibility in Phase 1
- `agents:add` is also still legacy and edits repo-local source definitions rather than `~/.apm`
- `agents:legacy:*` tasks are the explicit escape hatch if the APM path breaks
- `agents/src/skills/` should no longer be described as the long-term source of truth for agent distribution in this repo
- In this repo, install the APM CLI through `mise` rather than the official installer unless you are doing manual recovery
