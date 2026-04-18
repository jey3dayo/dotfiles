# Creating Custom Distribution Bundles

## Overview

This guide walks through creating a custom distribution root for `distributionsPath`.

The current runtime supports bundled:

- skills
- rules
- agents
- optional config files

Top-level bundled commands are not part of the active Home Manager deployment path. If you need commands, prefer external `commandsPath` sources.

---

## Step 1: Create Bundle Structure

```bash
cd ~/.config/agents/bundles
mkdir -p my-bundle/{skills,rules,agents,config}
tree my-bundle
```

Recommended naming:

- lowercase with hyphens
- short but descriptive

---

## Step 2: Add Skills

You can either symlink to existing bundled source directories or create bundle-specific skill directories directly.

### Reuse a skill from `agents/src/`

```bash
cd my-bundle/skills
ln -s ../../../src/skills/react ./
ln -s ../../../src/skills/polish ./
```

### Create a bundle-specific skill directory

```bash
mkdir my-custom-skill
$EDITOR my-custom-skill/SKILL.md
```

Validation:

```bash
test -f react/SKILL.md
test -f my-custom-skill/SKILL.md
```

---

## Step 3: Add Rules

Rules are markdown files.

```bash
cd ../rules
ln -s ../../../src/rules/claude-md-design.md ./
mkdir -p tools
$EDITOR tools/my-team-rule.md
```

Subdirectories are preserved in deployed IDs, for example:

- `rules/tools/my-team-rule.md` -> `tools/my-team-rule`

---

## Step 4: Add Agents

Agents are markdown files or subdirectories containing markdown files.

```bash
cd ../agents
ln -s ../../../src/agents/code-reviewer.md ./
ln -s ../../../src/agents/kiro ./
```

Validation:

```bash
test -f code-reviewer.md
test -d kiro
```

---

## Step 5: Add Optional Config

```bash
cd ../config
$EDITOR shared-rules.md
$EDITOR bundle-config.json
```

Use this directory for bundle metadata, shared instructions, and templates.

---

## Step 6: Point `distributionsPath` At The Bundle

Example Home Manager configuration:

```nix
programs.agent-skills = {
  enable = true;
  distributionsPath = ./agents/bundles/my-bundle;
  sources = import ./nix/sources.nix { inherit inputs agentSkills; };
};
```

---

## Step 7: Validate

```bash
home-manager build --flake ~/.config --impure --dry-run
mise run agents:legacy:install
mise run agents:legacy:list 2>/dev/null | jq '.skills[] | {id, source}'
```

Expected behavior:

- bundle skills appear with `source = "distribution"`
- bundled rules and agents are linked into target directories
- bundled skills override external skills with the same ID

---

## Notes

- Prefer relative symlinks over absolute paths
- Prefer `agents/src/` as the base when reusing bundled assets
- Do not point bundle entries at generated directories such as `~/.claude/skills/`
- Do not rely on bundled `commands/` for current Home Manager deployment
