---
name: distributions-manager
version: 1.0.0
description: |
  Explains the distribution management system for bundling skills,
  commands, and configurations. Use when planning to create custom
  distributions or understand the bundling architecture.
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

## What is Distributions?

Distributions are pre-configured bundles that combine:

- Skills: Symlinks to `skills/` and `skills-internal/`
- Commands: Symlinks to `commands-internal/` (supports subdirectories)
- Rules: Symlinks to `~/.claude/rules/` (markdown files)
- Agents: Symlinks to `~/.claude/agents/` (markdown files, supports subdirectories)
- Config: Shared configuration files

### Key benefits

- No duplication: Symlink-based architecture
- Bundle management: Group related tools together
- Flexible deployment: Optional layer that coexists with existing workflows

### Current implementation

- 100+ symlinks in `internal/` (42 skills + 42 commands + 1 rule + 15 agents)
- Priority: Local > External > Distribution
- Cyclic reference prevention (static paths, scanned before sources)
- Supports subdirectories (e.g., `agents/kiro/`, `commands/shared/`)

---

## When to Use This Knowledge

Use this skill when:

- **Adding new skills/commands** and need to understand where they fit
- **Creating custom distributions** for specific workflows
- **Debugging Nix deployment issues** related to distributions
- **Understanding priority mechanism** (Local > External > Distribution)
- **Planning bundle architectures** for team-specific toolsets

---

## Detailed References

### Architecture & Implementation

- references/architecture.md: Nix implementation details, `scanDistribution()` function, integration with `discoverCatalog()`
- references/priority-mechanism.md: Priority order, conflict resolution, cyclic reference prevention

### Practical Guides

- references/creating-bundles.md: Step-by-step guide for custom bundle creation
- references/symlink-patterns.md: Design patterns for symlink-based architecture

### Resources

- resources/templates/bundle-structure.txt: Directory structure template
- resources/templates/README.template.md: Bundle README template
- resources/examples/default-bundle.md: Analysis of `internal/`
- resources/checklist.md: QA checklist for bundle creation

---

## Quick Start

### View Current Distributions

```bash
# Inspect default bundle
tree agents/internal/

# Optional: list custom bundles (if using distributions directory)
ls -la agents/bundles/
```

### Create a Custom Bundle

See **references/creating-bundles.md** for detailed steps.

```bash
# Create bundle structure
mkdir -p agents/bundles/my-bundle/{skills,commands,config}

# Add skills
cd agents/bundles/my-bundle/skills
ln -s ../../../internal/skills/my-skill ./

# Deploy
home-manager switch --flake ~/.config --impure
```

### Verify Deployment

```bash
# Check deployed skills
ls -la ~/.claude/skills/ | grep my-skill

# Check skill catalog
mise run skills:list 2>/dev/null | jq '.skills[] | select(.source == "local")'
```

---

## Related Skills

- skill-creator: Creating new skills to add to distributions
- command-creator: Creating new commands to add to distributions
- rules-creator: Creating shared rules for bundle configurations
- knowledge-creator: Routing distribution-related questions

---

## Token Budget

| Component            | Tokens       | Loading Strategy                          |
| -------------------- | ------------ | ----------------------------------------- |
| SKILL.md (this file) | ~300         | Always loaded                             |
| references/          | ~1,500-2,000 | Loaded on-demand (progressive disclosure) |
| resources/           | ~700-950     | Loaded when hands-on work is needed       |
| **Total**            | ~2,500-3,250 | Efficient progressive disclosure          |
