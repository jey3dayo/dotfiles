---
name: apm-usage
description: Use when editing the `~/.apm` global APM workspace, deciding whether a change belongs in `~/.apm/catalog/` or workspace-owned files, or rolling out managed catalog updates.
---

# APM Usage

## Overview

In this repository, APM is used primarily for **global skill management**.

- `~/.apm/apm.yml` is the global manifest
- `~/.apm/apm_modules/` stores downloaded dependency sources
- `~/.apm/catalog/` is the repo-tracked package for managed skills
- `apm install -g` is the normal deployment path

There is no `~/.apm/skills/` directory in the current global model.
Do not treat `packages/`, `~/.apm/skills/`, or workspace-root `.apm/` as the source of truth for global skills.

## Use This Skill When

- Editing or reviewing `~/.apm/apm.yml`
- Installing or updating global skills with `apm install -g`
- Refreshing the tracked managed-skill catalog in `~/.apm/catalog/`
- Explaining the difference between upstream refs, `apm_modules/`, and deployed targets
- Checking whether a skill should stay source-only instead of entering the global manifest

## Quick Routing

Start by routing the request into one of these lanes:

- managed catalog content:
  - edit `~/.apm/catalog/.apm/skills/**`, `AGENTS.md`, `agents/**`, `commands/**`, or `rules/**`
  - then run `mise run stage-catalog`
- workspace-owned files:
  - edit `~/.apm/README.md`, `llms.md`, `apm.yml`, `apm.lock.yaml`, or `docs/**` directly
  - do not restage the catalog unless managed content changed too
- external dependency selection:
  - edit `~/.config/nix/agent-skills-sources.nix` when the source selection itself changes
  - then reconcile `~/.apm/apm.yml` through `mise run migrate-external` or normal APM install/update flows

## Rule Of Thumb

Prefer `~/.apm` when:

- The skill should be globally available across machines
- You want the manifest to preserve the upstream repository reference
- The skill already comes from `nix/agent-skills-sources.nix`

When a user says "fix what is in `~/.apm`", first decide which layer actually owns the change:

- edit `~/.apm/catalog/**` for managed catalog content
- edit `~/.apm/README.md`, `llms.md`, `apm.yml`, or `apm.lock.yaml` for workspace-owned files that live only in the `~/.apm` repo
- treat `~/.config/agents/src/**` as a transitional mirror, not the starting point

Treat `~/.apm/catalog/` as the **authoring source of truth** for managed skills and shared guidance.
Treat `~/.config/agents/src/**` as the **transitional mirror** refreshed by `mise run stage-catalog`.

For external skills, the source of truth is the upstream ref in `~/.apm/apm.yml`.  
For installed sources, the on-disk cache is `~/.apm/apm_modules/`.

For managed skills, the tracked package is:

```text
~/.apm/catalog/.apm/skills/<id>/SKILL.md
```

That tracked package is then referenced from `~/.apm/apm.yml` as:

```text
jey3dayo/apm-workspace/catalog#main
```

The same tracked catalog also carries:

```text
~/.apm/catalog/AGENTS.md
~/.apm/catalog/agents/**
~/.apm/catalog/commands/**
~/.apm/catalog/rules/**
```

## Managed Skill Model

Managed skills and shared guidance now follow a direct-authoring model:

- source of truth:
  - `~/.apm/catalog/.apm/skills/<id>/`
  - `~/.apm/catalog/AGENTS.md`
  - `~/.apm/catalog/agents/**`
  - `~/.apm/catalog/commands/**`
  - `~/.apm/catalog/rules/**`
- transitional mirror:
  - `~/.config/agents/src/skills/<id>/`
  - `~/.config/agents/src/AGENTS.md`
  - `~/.config/agents/src/agents/**`
  - `~/.config/agents/src/commands/**`
  - `~/.config/agents/src/rules/**`

`stage-catalog` normalizes the tracked package and refreshes the mirror so older entry points keep working during the transition.

Runtime targets are a third layer, not an editing surface:

- deployed user targets:
  - `~/.claude/`
  - `~/.codex/`
  - other detected runtime targets
- refresh path:
  - `stage-catalog` updates the tracked package in `~/.apm/catalog/`
  - `register-catalog`, `apply`, or `update` installs that tracked package and syncs runtime guidance files, including `commands/`

In short:

- authoring change: `~/.apm/catalog/**`
- mirror refresh: `~/.config/agents/src/**` via `stage-catalog`
- runtime change: produced by install/sync, not hand-edited

## Fast Paths

Use these short flows for the common request shapes:

1. Managed skill or guidance changed
   - edit `~/.apm/catalog/**`
   - run `mise run stage-catalog`
   - review the normalized `catalog/**` diff and refreshed mirror
   - commit/push `~/.apm`
   - run `mise run register-catalog`
   - run `mise run doctor`

2. Only `~/.apm` docs or manifest files changed
   - edit the workspace-owned files directly
   - commit/push `~/.apm`
   - run `mise run register-catalog` only if `catalog/` changed too

3. External skill mapping changed
   - update `nix/agent-skills-sources.nix`
   - run `mise run migrate-external`
   - run `mise run apply`
   - run `mise run doctor`

Not allowed:

- treating `~/.apm/skills/` as the global source of truth
- reintroducing many local-path skill entries into `~/.apm/apm.yml`
- describing `apm_modules/` as the place where managed skills should be edited

## Core Commands

```bash
# Bootstrap once from ~/.config
cd ~/.config
mise run apm:bootstrap

# Day-to-day global flow from ~/.apm
cd ~/.apm
mise install
mise run format
mise run ci:check
mise run migrate-external
mise run apply
mise run doctor
```

## Managed Catalog Workflow

Use the workspace script when you need to normalize the tracked catalog package and refresh the mirror.

```bash
# Refresh the tracked catalog artifact
cd ~/.apm
powershell -NoProfile -ExecutionPolicy Bypass -File %USERPROFILE%\.config\scripts\apm-workspace.ps1 stage-catalog

# Or on POSIX shells
sh "$HOME/.config/scripts/apm-workspace.sh" stage-catalog
```

That flow:

- rebuilds `~/.apm/.catalog-build/catalog/` as a temporary package artifact
- copies the normalized result back into `~/.apm/catalog/`
- refreshes `~/.config/agents/src/skills/`, `AGENTS.md`, `agents/`, `commands/`, and `rules/` as a transitional mirror
- lets `~/.apm/apm.yml` keep a single upstream ref: `jey3dayo/apm-workspace/catalog#main`

For a full managed-content rollout, the normal sequence is:

1. edit `~/.apm/catalog/`
2. run `mise run stage-catalog` from `~/.apm`
3. review the normalized `catalog/` diff and the refreshed mirror
4. commit and push `~/.apm`
5. run `mise run register-catalog`
6. run `mise run doctor`

## Important Global Model

APM global skill management in this setup is centered on:

```text
~/.apm/
  apm.yml
  apm.lock.yaml
  apm_modules/
  catalog/
  mise.toml
```

- `apm.yml` tracks dependencies by upstream ref
- `apm_modules/` holds downloaded sources
- `catalog/` holds the tracked managed-skill package
- `catalog/AGENTS.md`, `catalog/agents/`, `catalog/commands/`, and `catalog/rules/` hold tracked shared guidance assets
- `apm install -g` deploys the current global dependency set to user targets

If you see `./packages/...` in `apm.yml`, that is legacy migration residue and should be removed from the global model.

## External Migration Workflow

1. Bootstrap with `cd ~/.config && mise run apm:bootstrap`
2. Move to `~/.apm` and run `mise install`
3. Run `mise run migrate-external`
4. Run `mise run apply`
5. Validate with `mise run doctor`

`migrate-external` does this:

- reads `nix/agent-skills-sources.nix`
- derives canonical upstream refs for enabled skills
- skips IDs already owned by the managed catalog
- updates `~/.apm/apm.yml` through `apm install -g <upstream-ref>`
- lets APM place downloaded sources in `~/.apm/apm_modules/`
- auto-runs `pin-external` at the end, rewriting those external refs to `#resolved_commit` based on `apm.lock.yaml`

When a skill is moved into the managed catalog:

- remove the overlapping selection from `nix/agent-skills-sources.nix`
- run `mise run doctor` and confirm `external selection overlap: count=0`
- run `apm prune` once if old package ownership is still hanging around from a previous install state

When managed catalog content changes:

- run `mise run stage-catalog`
- review, commit, and push the updated `catalog/`
- run `mise run register-catalog`
- run `mise run doctor` and confirm target `config/agents/commands/rules` are present

When the change is only for workspace-owned docs such as `~/.apm/README.md` or `llms.md`:

- edit those files directly in `~/.apm`
- do not run `stage-catalog` unless managed catalog content also changed
- push `~/.apm`, then use `register-catalog` only if the tracked package changed

## Legacy Notes

- `validate-catalog` now validates the tracked `catalog/` package itself plus the refreshed `~/.config/agents/src/**` mirror
- `validate-catalog` is available both as `mise run validate-catalog` and as a workspace script command
- `format` formats Markdown / TOML / YAML inside `~/.apm`
- `ci:check` runs format checks plus validation and smoke checks
- `ci` formats, validates, applies, and verifies the local workspace rollout
- `catalog:tidy` restages the tracked catalog, validates it, and prints workspace health
- public maintenance commands should use `bundle-catalog`, `stage-catalog`, `register-catalog`, and `smoke-catalog`
- `doctor` shows both catalog coverage and managed-vs-external selection overlap, plus target `config/agents/commands/rules/skills` presence
- `apply` / `update` validate the tracked catalog before global install
- `apply` / `update` sync tracked `AGENTS.md`, `agents/`, `commands/`, and `rules/` into user runtime targets after install
- `apply` / `update` should fail fast if `./packages/*` entries still remain in the global manifest
- install helpers also fail when APM prints diagnostics such as `packages failed` or `error(s)` even if exit code is 0
- install the APM CLI through `mise` in this repository unless you are doing manual recovery
