# Design: Rename `agents/internal/` to `agents/src/`

## Summary

Rename `agents/internal/` to `agents/src/` now that `agents/external/` has been removed, eliminating the internal/external contrast that originally motivated the name.

## Background

`agents/internal/` was named as the counterpart to `agents/external/` (vendored copies of third-party skills). With `agents/external/` removed (external skills now managed exclusively via Nix flake inputs), the `internal` qualifier no longer carries meaning. `src/` is the conventional name for the source content of a distribution.

## Decision

Rename `agents/internal/` → `agents/src/`. Keep `agents/` as the top-level directory unchanged.

## Resulting Structure

```
agents/
├── src/           # Distribution source (skills, commands, rules, agent defs)
│   ├── agents/
│   ├── commands/
│   ├── rules/
│   └── skills/
├── nix/           # Nix infrastructure (lib.nix, module.nix)
├── scripts/       # Maintenance tooling
└── README.md
```

## Change Scope

### Directory

- `agents/internal/` → `agents/src/`

### Nix Code

- `agents/nix/lib.nix` — update path references to `agents/internal`
- `agents/nix/module.nix` — update path references
- `flake.nix` — update `discoverCatalog` call if path is hardcoded

### Scripts & Config

- `agents/scripts/validate-internal.sh` → `validate-src.sh`
- `agents/scripts/validate-internal.test.ts` → `validate-src.test.ts`
- `mise/config.toml` — update `agents/internal` in `MD_EXCLUDES`, `TASK_EXCLUDES`, etc.
- Ignore files (`.fdignore`, `.prettierignore`, etc.) — update any `agents/internal` patterns

### Rules

- `.claude/rules/home-manager.md`
- `.claude/rules/agent-skills-source-of-truth.md`
- `.claude/rules/commands-deprecation.md`

### Steering

- `.kiro/steering/tech.md`
- `.kiro/steering/product.md`

### Documentation

- `agents/README.md`
- `docs/tools/home-manager.md`
- `docs/tools/nix.md`
- `docs/tools/mise.md`
- `docs/tools/mise-tasks.md`
- `docs/superpowers/specs/2026-03-27-unify-external-skills-management-design.md`
- `docs/superpowers/plans/2026-03-27-clean-up-unused-external-skills.md`
- `scripts/replace-bold-headings.ts:293` — comment example only

### CI / Build

- `.github/workflows/validate.yml`
- `.pre-commit-config.yaml`
- `home.nix`

### Skills (self-referential docs inside agents/src/)

These files move with the directory rename but contain path strings that also need updating:

- `agents/src/skills/distributions-manager/SKILL.md`
- `agents/src/skills/distributions-manager/references/architecture.md`
- `agents/src/skills/distributions-manager/references/priority-mechanism.md`
- `agents/src/skills/distributions-manager/references/symlink-patterns.md`
- `agents/src/skills/nix-dotfiles/SKILL.md`
- `agents/src/skills/nix-dotfiles/README.md`
- `agents/src/skills/nix-dotfiles/references/commands.md`
- `agents/src/skills/nix-dotfiles/references/troubleshooting.md`
- `agents/src/skills/docs-index/indexes/agents-index.md`

## Non-Goals

- Restructuring the contents of `agents/src/` (skills, commands, rules, agents subdirs unchanged)
- Renaming `agents/` itself
- Changing how Nix distributes skills to `~/.claude/`
- Renaming the `source == "distribution"` identifier in Nix code (internal concept, not a path)
