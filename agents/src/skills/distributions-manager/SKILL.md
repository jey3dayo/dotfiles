---
name: distributions-manager
version: 1.0.0
description: |
  Explains the current distribution management system for bundled skills,
  agents, rules, and related Nix deployment behavior. Use when planning
  to create custom bundles or understand the bundling architecture.
triggers:
  - distributions
  - bundle
  - distribution management
  - custom bundle
  - skill distribution
  - command distribution
keywords:
  - distributions
  - bundle
  - symlink
  - nix integration
  - priority mechanism
  - custom distribution
related_skills:
  - skill-creator
  - command-creator
  - rules-creator
  - knowledge-creator
---

# Distributions Manager

This skill describes the **legacy Nix / Home Manager distribution path**.
For the newer `~/.apm` global workflow, use `apm-usage` instead.

## What Is A Distribution?

Distributions are bundled assets scanned from `distributionsPath`, typically `agents/src/`.

Current bundled asset types:

- Skills: directories under `agents/src/skills/`
- Rules: markdown files under `agents/src/rules/`
- Agents: markdown files under `agents/src/agents/`
- Config: optional files under `config/`

Current command behavior:

- Top-level commands are deployed from external `commandsPath` sources
- Bundled `agents/src/commands/` is not part of the active Home Manager deployment path

### Current implementation

- Source of truth: `agents/src/`
- Skill priority: `Distribution > External`
- `skills.enable = null`: all discovered bundled and external skills
- Shared selection logic in `agents/nix/lib.nix`
- Bundled agents override external agents with the same ID

---

## When To Use This Knowledge

Use this skill when:

- Adding bundled skills, agents, or rules to `agents/src/`
- Creating a custom distribution root for `distributionsPath`
- Debugging Nix deployment issues related to bundled assets
- Understanding selection and priority behavior
- Updating docs or templates for the current distribution model

---

## Detailed References

### Architecture & Implementation

- `references/architecture.md`: current Nix implementation and deployment flow
- `references/priority-mechanism.md`: skill priority, selection behavior, and conflict handling

### Practical Guides

- `references/creating-bundles.md`: creating custom bundle roots for the current runtime
- `references/symlink-patterns.md`: current symlink patterns and anti-patterns

### Resources

- `resources/templates/bundle-structure.txt`: starter bundle layout
- `resources/templates/README.template.md`: bundle README template
- `resources/examples/default-bundle.md`: analysis of the current `agents/src/` distribution
- `resources/checklist.md`: QA checklist for bundle creation and maintenance

---

## Quick Start

### View Current Distribution

```bash
tree agents/src/
```

### Create A Custom Bundle

See `references/creating-bundles.md` for the full workflow.

```bash
mkdir -p agents/bundles/my-bundle/{skills,rules,agents,config}
cd agents/bundles/my-bundle/skills
ln -s ../../../src/skills/my-skill ./
home-manager switch --flake ~/.config --impure
```

### Verify Deployment

```bash
mise run agents:legacy:list 2>/dev/null | jq '.skills[] | {id, source}'
ls -la ~/.claude/skills/
```

---

## Related Skills

- `skill-creator`: bundled skill creation
- `command-creator`: command authoring guidance
- `rules-creator`: bundled rule creation
- `knowledge-creator`: routing related knowledge questions

---

## Token Budget

| Component            | Tokens       | Loading Strategy                          |
| -------------------- | ------------ | ----------------------------------------- |
| SKILL.md (this file) | ~300         | Always loaded                             |
| references/          | ~1,500-2,000 | Loaded on-demand (progressive disclosure) |
| resources/           | ~700-950     | Loaded when hands-on work is needed       |
| Total                | ~2,500-3,250 | Efficient progressive disclosure          |
