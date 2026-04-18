---
name: apm-usage
description: Use when working with APM manifests, `~/.apm` global skill management, or migrating enabled external skills into `apm-workspace`.
---

# APM Usage

## Overview

In this repository, APM is used primarily for **global skill management**.

- `~/.apm/apm.yml` is the global manifest
- `~/.apm/apm_modules/` stores downloaded dependency sources
- `apm install -g` is the normal deployment path

Do not treat `packages/` or workspace-root `.apm/` as the source of truth for global skills.

## Use This Skill When

- Editing or reviewing `~/.apm/apm.yml`
- Installing or updating global skills with `apm install -g`
- Registering enabled external skills from `nix/agent-skills-sources.nix`
- Explaining the difference between upstream refs, `apm_modules/`, and deployed targets
- Checking whether a skill should stay legacy-only instead of entering the global manifest

## Rule Of Thumb

Prefer `~/.apm` when:

- The skill should be globally available across machines
- You want the manifest to preserve the upstream repository reference
- The skill already comes from `nix/agent-skills-sources.nix`

Treat `agents/src/skills/<name>/` as legacy-only when:

- It exists for rollback
- It is a seed helper for older bundled distribution
- It should not be written into the global `apm.yml`

For external skills, the source of truth is the upstream ref in `~/.apm/apm.yml`.  
For installed sources, the on-disk cache is `~/.apm/apm_modules/`.

## Internal Bundled Skills

Internal bundled skills are on a separate migration track.

- current source:
  - `~/.config/agents/src/skills/<id>/`
- current role:
  - rollback
  - migration seed
  - contract/pilot source for future internal packaging
- not allowed:
  - treating `./packages/*` as the long-term global route
  - reintroducing internal bundled skills into `~/.apm/apm.yml` as local-path dependencies

Current first-batch pilot candidates:

- `apm-usage`
- `atomic-commit`
- `greptileai`

These first-batch skills are now bundled and registered, but the legacy sources still remain in the rollback/seed lane.

Use `mise run migrate-internal[:profile]` when you need to stage an internal profile into:

```text
~/.apm/.internal-seed/
```

This staging area is only for pilot/reference use and does not change `~/.apm/apm.yml`.

Use `mise run bundle-internal[:profile]` when you need a valid APM package artifact at:

```text
~/.apm/.internal-seed/internal-<profile>/
```

That artifact is useful for validation and future publication work, but as of APM 0.8.11 you still cannot do `apm install -g <local-path>` from user scope.

## Core Commands

```bash
# Bootstrap once from ~/.config
cd ~/.config
mise run apm:bootstrap

# Day-to-day global flow from ~/.apm
cd ~/.apm
mise install
mise run migrate-external
mise run apply
mise run validate
mise run doctor
```

## Important Global Model

APM global skill management in this setup is centered on:

```text
~/.apm/
  apm.yml
  apm.lock.yaml
  apm_modules/
  mise.toml
```

- `apm.yml` tracks dependencies by upstream ref
- `apm_modules/` holds downloaded sources
- `apm install -g` deploys the current global dependency set to user targets

If you see `./packages/...` in `apm.yml`, that is legacy migration residue and should be removed from the global model.

## External Migration Workflow

1. Bootstrap with `cd ~/.config && mise run apm:bootstrap`
2. Move to `~/.apm` and run `mise install`
3. Run `mise run migrate-external`
4. Run `mise run apply`
5. Validate with `mise run validate` and `mise run doctor`

`migrate-external` does this:

- reads `nix/agent-skills-sources.nix`
- derives canonical upstream refs for enabled skills
- skips IDs owned by bundled internal legacy skills such as `dev-browser`
- updates `~/.apm/apm.yml` through `apm install -g <upstream-ref>`
- lets APM place downloaded sources in `~/.apm/apm_modules/`

## Legacy Notes

- `migrate` is only a legacy recovery/seed helper and is not part of the normal global flow
- `migrate-internal[:profile]` is the explicit pilot helper for internal bundled skills and seeds `~/.apm/.internal-seed/`
- `bundle-internal[:profile]` builds a valid internal APM artifact under `~/.apm/.internal-seed/internal-<profile>/`
- `stage-internal[:profile]` syncs that generated bundle into `~/.apm/internal-bundles/internal-<profile>/` and prints the future `owner/repo/path#branch` upstream ref
- `register-internal[:profile]` only runs once that staged path is committed and pushed, then installs it by upstream ref
- `smoke-internal[:profile]` project-scope installs that generated bundle into a temp workspace and checks `.agents/skills/<id>/SKILL.md`
- `migrate` is now just a compatibility alias for `migrate-internal`
- `agents:legacy:*` remains the rollback path if the APM route breaks
- `agents/src/skills/` should not be described as the long-term global source of truth
- internal bundled skill migration should update the contract/docs first, then introduce a bundle/package mechanism, and only then change installation flow
- install the APM CLI through `mise` in this repository unless you are doing manual recovery
