# Symlink Design Patterns

## Overview

Distributions use symlinks to reference skills and commands without duplication. This document describes the design patterns, best practices, and Nix processing details.

---

## Core Principles

### 1. Relative Paths

**Always use relative paths**, never absolute:

```bash
# ✅ Correct (relative)
ln -s ../../../skills-internal/my-skill ./

# ❌ Incorrect (absolute)
ln -s /home/j138/.config/agents/skills-internal/my-skill ./
```

**Rationale**:

- Portable across environments
- Nix-friendly (works in `/nix/store/`)
- No hardcoded user paths

---

### 2. Path Depth Calculation

From `distributions/default/skills/` to target:

```
distributions/default/skills/my-skill → ../../../skills-internal/my-skill
      ↓           ↓       ↓
      1           2       3 (../ levels)
```

**Template**:

```bash
# From: distributions/<bundle>/skills/
# To:   skills-internal/<skill>/
ln -s ../../../skills-internal/<skill> ./

# From: distributions/<bundle>/commands/
# To:   commands-internal/<command>/
ln -s ../../../commands-internal/<command> ./
```

---

### 3. Target Validation

Always verify symlink target exists:

```bash
# Create symlink
ln -s ../../../skills-internal/my-skill ./

# Verify target
ls -la my-skill
# lrwxrwxrwx my-skill -> ../../../skills-internal/my-skill

# Check target exists (resolve symlink)
test -e my-skill && echo "Valid" || echo "Broken"
```

**Automation**:

```bash
# Find all broken symlinks
find distributions/ -type l -exec test ! -e {} \; -print
```

---

## Patterns

### Pattern 1: Direct Skill Link

**Use case**: Single skill from `skills-internal/`

```bash
cd distributions/my-bundle/skills
ln -s ../../../skills-internal/react ./
```

**Nix processing**:

```nix
# Nix sees:
{ react = { id = "react"; path = /path/to/skills-internal/react; source = "distribution"; }; }
```

**Validation**:

```bash
test -f ../../../skills-internal/react/SKILL.md
```

---

### Pattern 2: External Skill Link

**Use case**: Skill from `skills/` (external sources)

```bash
cd distributions/my-bundle/skills
ln -s ../../../skills/external-skill ./
```

**Priority note**: If same skill exists in `skills-internal/`, local version takes precedence (Local > External > Distribution).

---

### Pattern 3: Command Directory Link

**Use case**: Command with subcommands (e.g., `kiro/`)

```bash
cd distributions/my-bundle/commands
ln -s ../../../commands-internal/kiro ./
```

**Structure**:

```
commands-internal/kiro/
├── spec-init/
│   └── command.ts
├── spec-tasks/
│   └── command.ts
└── spec-impl/
    └── command.ts
```

**Result**: 3 commands (`kiro:spec-init`, `kiro:spec-tasks`, `kiro:spec-impl`)

**Nix processing**:

```nix
# Nix recursively scans kiro/
{
  "kiro:spec-init" = { id = "kiro:spec-init"; path = /path/to/kiro/spec-init; };
  "kiro:spec-tasks" = { id = "kiro:spec-tasks"; path = /path/to/kiro/spec-tasks; };
  "kiro:spec-impl" = { id = "kiro:spec-impl"; path = /path/to/kiro/spec-impl; };
}
```

---

### Pattern 4: Nested Skill Links (Future)

**Use case**: Organize skills in subdirectories

```bash
cd distributions/my-bundle/skills
mkdir -p frontend
cd frontend
ln -s ../../../../skills-internal/react ./
ln -s ../../../../skills-internal/ui-ux-pro-max ./
```

**Note**: Path depth increases by 1 (`../` → `../../../../`)

**Validation**:

```bash
# Check from nested location
cd distributions/my-bundle/skills/frontend
test -f ../../../../skills-internal/react/SKILL.md
```

---

## Anti-Patterns

### ❌ Anti-Pattern 1: Absolute Paths

```bash
# Don't do this
ln -s /home/j138/.config/agents/skills-internal/my-skill ./
```

**Problem**: Breaks in Nix environments, not portable.

---

### ❌ Anti-Pattern 2: Copying Files

```bash
# Don't do this
cp -r ../../../skills-internal/my-skill ./
```

**Problem**: Duplication, no updates, maintenance burden.

---

### ❌ Anti-Pattern 3: Circular References

```bash
# Don't do this
# skills-internal/my-skill/ → distributions/default/skills/my-skill
# distributions/default/skills/my-skill → skills-internal/my-skill/
```

**Problem**: Evaluation loop (prevented by static scanning in Nix).

---

### ❌ Anti-Pattern 4: Linking to Distributions

```bash
# Don't do this
ln -s ../../../distributions/other-bundle/skills/my-skill ./
```

**Problem**: Creates dependency between distributions, defeats purpose.

---

## Nix Processing Details

### Symlink Resolution

Nix dereferences symlinks at filesystem level:

```nix
# distributions/default/skills/my-skill → ../../../skills-internal/my-skill
# Nix sees:
path = /nix/store/.../skills-internal/my-skill
# or (in development):
path = /home/j138/.config/agents/skills-internal/my-skill
```

**Key insight**: Nix only sees **resolved paths**, not the symlink itself.

---

### Directory vs File Symlinks

```nix
# Process symlink to directory
if type == "symlink" && pathExists (entryPath + "/SKILL.md") then
  { ${name} = { id = name; path = entryPath; source = "distribution"; }; }

# Process symlink to directory (no SKILL.md, recurse)
else if type == "symlink" then
  scanSource "distribution" entryPath
```

**Behavior**:

- **Skill directory symlink**: Treat as single skill (if `SKILL.md` exists)
- **Non-skill directory symlink**: Recurse into subdirectories

---

### Type Detection

```nix
# readDir returns:
{ "my-skill" = "symlink"; "other-skill" = "directory"; }

# Both are processed similarly:
type == "directory" || type == "symlink"
```

**Equivalence**: Directories and symlinks are processed identically (both can contain `SKILL.md`).

---

## Validation Scripts

### Check Symlink Validity

```bash
# Find broken symlinks
find distributions/ -type l -exec test ! -e {} \; -print

# Check SKILL.md presence
find distributions/*/skills/ -type l -exec sh -c '
  target=$(readlink -f "$1")
  test -f "$target/SKILL.md" || echo "Missing SKILL.md: $1"
' _ {} \;
```

### Check Path Depth

```bash
# Verify relative paths use correct depth
find distributions/ -type l -exec sh -c '
  link=$(readlink "$1")
  echo "$1 -> $link" | grep -E "^\.\./\.\./\.\." || echo "Incorrect depth: $1"
' _ {} \;
```

---

## Best Practices

1. **Use relative paths**: Always `../../../` depth
2. **Validate targets**: Check `SKILL.md` / `command.ts` exists
3. **Test resolution**: Use `readlink -f` to verify target
4. **Avoid nesting**: Keep distributions flat (one level deep)
5. **Document structure**: Update README with symlink sources
6. **Automate validation**: Run validation scripts before deployment

---

## Debugging

### Symlink Issues

```bash
# Check symlink target
ls -la distributions/default/skills/my-skill

# Resolve symlink fully
readlink -f distributions/default/skills/my-skill

# Test target exists
test -e distributions/default/skills/my-skill && echo "OK" || echo "Broken"
```

### Nix Evaluation Issues

```bash
# Check Nix sees the symlink
nix-store --query --references $(nix-build --no-out-link ~/.config -A home.activationPackage)

# Trace evaluation
nix eval --show-trace --json --impure --expr '
  let lib = import ~/agents/nix/lib.nix { inherit (import <nixpkgs> {}) lib; };
  in lib.discoverCatalog { distributionsPath = ~/agents/distributions/default; }
'
```

---

## Related References

- **architecture.md**: Nix implementation (`scanDistribution`)
- **creating-bundles.md**: Step-by-step bundle creation
- **priority-mechanism.md**: How symlinks interact with priority
- **resources/checklist.md**: Validation checklist
