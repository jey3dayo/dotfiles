# Symlink Design Patterns

## Overview

Custom distribution roots can use symlinks to reuse bundled source files without duplication.

The safe current targets are:

- `agents/src/skills/...`
- `agents/src/rules/...`
- `agents/src/agents/...`

Do not point symlinks at removed legacy layers.

---

## Core Principles

### Use Relative Paths

```bash
# Good
ln -s ../../../src/skills/react ./

# Bad
ln -s /home/j138/.config/agents/src/skills/react ./
```

Why:

- works across machines
- works after Nix path materialization
- avoids user-specific paths

---

## Supported Patterns

### Pattern 1: Skill Reuse

```bash
cd bundles/my-bundle/skills
ln -s ../../../src/skills/react ./
```

Nix treats this as a bundled distribution skill.

### Pattern 2: Rule Reuse

```bash
cd bundles/my-bundle/rules
ln -s ../../../src/rules/claude-md-design.md ./
```

### Pattern 3: Agent Reuse

```bash
cd bundles/my-bundle/agents
ln -s ../../../src/agents/code-reviewer.md ./
ln -s ../../../src/agents/kiro ./
```

Subdirectory layout is preserved for grouped agents such as `kiro/`.

---

## Validation

### Check Targets Exist

```bash
test -e react
test -e code-reviewer.md
test -e kiro
```

### Verify Skill Targets

```bash
find bundles/my-bundle/skills -type l -exec sh -c '
  target=$(readlink -f "$1")
  test -f "$target/SKILL.md" || echo "Missing SKILL.md: $1"
' _ {} \;
```

### Detect Broken Symlinks

```bash
find bundles/my-bundle -type l -exec test ! -e {} \; -print
```

---

## Anti-Patterns

### Absolute Paths

```bash
ln -s /home/j138/.config/agents/src/skills/react ./
```

### Generated Deployment Paths

```bash
ln -s ~/.claude/skills/react ./
```

This creates self-referential behavior against generated output instead of source input.

### Removed Historical Layers

```bash
ln -s ../../../legacy-skills/react ./
ln -s ../../../legacy-commands/kiro ./
ln -s ../../../legacy-distribution/skills/react ./
```

These paths are stale.

### Bundled Commands

```bash
ln -s ../../../src/commands/something ./
```

The current Home Manager module does not deploy bundled `commands/`, so this pattern is not useful for the active runtime.

---

## Filesystem Resolution

Nix resolves symlinks at the filesystem layer. For skills, the important check is still:

```nix
pathExists (entryPath + "/SKILL.md")
```

So a valid symlinked skill target behaves the same as a direct directory from the scanner's perspective.
