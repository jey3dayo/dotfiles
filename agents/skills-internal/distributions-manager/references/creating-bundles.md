# Creating Custom Distribution Bundles

## Overview

This guide walks through creating a custom distribution bundle from scratch. Use this when you want to group related skills, commands, and configurations for specific workflows or teams.

---

## Prerequisites

- Familiarity with Nix Home Manager
- Understanding of symlink-based architecture (see `symlink-patterns.md`)
- Access to `agents/` directory

---

## Step-by-Step Guide

### Step 1: Create Bundle Structure

```bash
cd /home/j138/.config/agents/distributions

# Create bundle directory
mkdir -p my-bundle/{skills,commands,config}

# Verify structure
tree my-bundle
# my-bundle/
# ├── skills/
# ├── commands/
# └── config/
```

### Naming conventions

- Lowercase with hyphens: `my-bundle`, `frontend-tools`, `backend-utils`
- Descriptive: Reflect the bundle's purpose

---

### Step 2: Add Skills

```bash
cd my-bundle/skills

# Symlink from skills-internal/
ln -s ../../../skills-internal/my-skill ./

# Symlink from skills/ (external)
ln -s ../../../skills/external-skill ./

# Verify
ls -la
# lrwxrwxrwx my-skill -> ../../../skills-internal/my-skill
# lrwxrwxrwx external-skill -> ../../../skills/external-skill
```

### Tips

- Use relative paths: `../../../skills-internal/` (not absolute)
- Verify targets exist: `ls -la ../../../skills-internal/my-skill`
- Group by theme: All React-related skills together

---

### Step 3: Add Commands

```bash
cd ../commands

# Symlink single command
ln -s ../../../commands-internal/my-command ./

# Symlink command directory (with subcommands)
ln -s ../../../commands-internal/kiro ./

# Verify
ls -la
# lrwxrwxrwx my-command -> ../../../commands-internal/my-command
# lrwxrwxrwx kiro -> ../../../commands-internal/kiro
```

### Subdirectory support

```bash
# Example: kiro command directory
tree ../../../commands-internal/kiro
# kiro/
# ├── spec-init/
# │   └── command.ts
# ├── spec-tasks/
# │   └── command.ts
# └── spec-impl/
#     └── command.ts

# Result: 3 commands (kiro:spec-init, kiro:spec-tasks, kiro:spec-impl)
```

---

### Step 4: Add Configuration (Optional)

```bash
cd ../config

# Add shared rules
cat > shared-rules.md <<EOF
# Shared Development Rules

- Follow project coding standards
- Run tests before committing
- Update documentation
EOF

# Add bundle-specific config
cat > bundle-config.json <<EOF
{
  "bundle": "my-bundle",
  "version": "1.0.0",
  "maintainers": ["team@example.com"]
}
EOF
```

### Config types

- **Rules**: Markdown files for Claude Code instructions
- **Templates**: Reusable templates for skills/commands
- **Metadata**: JSON/YAML configuration files

---

### Step 5: Create README

```bash
cd ..

# Use template (see resources/templates/README.template.md)
cat > README.md <<EOF
# My Bundle

Custom distribution for [workflow/team name].

## Contents

### Skills (${count})

- **my-skill**: Brief description
- **external-skill**: Brief description

### Commands (${count})

- **my-command**: Brief description
- **kiro:spec-init**: Brief description

## Installation

Included in \`distributions/my-bundle/\`. Deploy with:

\`\`\`bash
home-manager switch --flake ~/.config --impure
\`\`\`

## Maintainers

- Team Name <team@example.com>
EOF
```

---

### Step 6: Update Nix Configuration

### Option A: Replace default bundle

```nix
# home/j138/.agents/flake.nix (or ~/.config/flake.nix)
distributionsPath = ~/agents/distributions/my-bundle;
```

### Option B: Keep both (manual merge)

```bash
# Copy my-bundle contents to default/
cp -r my-bundle/skills/* default/skills/
cp -r my-bundle/commands/* default/commands/
```

### Option C: Multi-bundle support (future)

Currently not supported. Single distribution path only.

---

### Step 7: Deploy and Verify

```bash
# Dry-run (check for errors)
home-manager build --flake ~/.config --impure --dry-run

# Deploy
home-manager switch --flake ~/.config --impure

# Verify skills
ls -la ~/.claude/skills/ | grep -E 'my-skill|external-skill'

# Verify commands
mise run skills:list 2>/dev/null | jq '.skills[] | select(.source == "local")'
```

### Common issues

- **Symlink broken**: Check relative path depth (`../../../`)
- **Skill not deployed**: Verify `SKILL.md` exists in target
- **Priority conflict**: Local source overwrites distribution (expected behavior)

---

## Validation Checklist

See `resources/checklist.md` for comprehensive QA checklist. Quick checks:

```bash
# 1. Structure validation
tree -L 2 my-bundle/

# 2. Symlink validation
find my-bundle/ -type l -exec test ! -e {} \; -print
# (Should print nothing if all symlinks are valid)

# 3. SKILL.md validation
find my-bundle/skills/ -type l -exec sh -c '
  target=$(readlink -f "$1")
  test -f "$target/SKILL.md" || echo "Missing SKILL.md: $1"
' _ {} \;

# 4. command.ts validation
find my-bundle/commands/ -type l -exec sh -c '
  target=$(readlink -f "$1")
  find "$target" -name "command.ts" -print -quit | grep -q . || echo "Missing command.ts: $1"
' _ {} \;
```

---

## Examples

### Frontend Bundle

```bash
distributions/frontend-bundle/
├── skills/
│   ├── react -> ../../../skills-internal/react
│   ├── ui-ux-pro-max -> ../../../skills-internal/ui-ux-pro-max
│   └── tsr -> ../../../skills-internal/tsr
├── commands/
│   ├── polish -> ../../../commands-internal/polish
│   └── review -> ../../../commands-internal/review
└── README.md
```

### Backend Bundle

```bash
distributions/backend-bundle/
├── skills/
│   ├── golang -> ../../../skills-internal/golang
│   └── mise -> ../../../skills-internal/mise
├── commands/
│   ├── kiro -> ../../../commands-internal/kiro
│   └── clean -> ../../../commands-internal/clean
└── README.md
```

---

## Maintenance

### Adding Skills to Existing Bundle

```bash
cd distributions/my-bundle/skills
ln -s ../../../skills-internal/new-skill ./
home-manager switch --flake ~/.config --impure
```

### Removing Skills

```bash
cd distributions/my-bundle/skills
rm my-skill  # Remove symlink (does not delete source)
home-manager switch --flake ~/.config --impure
```

### Updating Bundle Metadata

```bash
# Update README.md with new skill counts
# Update config/bundle-config.json version
# Commit changes if tracked in Git
```

---

## Best Practices

1. **Document purpose**: Clear README explaining bundle's use case
2. **Semantic versioning**: Use version numbers for bundles
3. **Test before deploy**: Always run dry-run first
4. **Group logically**: Skills/commands should have thematic coherence
5. **Avoid duplication**: Use distributions for grouping, not copying
6. **Maintain atomicity**: Each skill/command should work independently

---

## Related References

- **architecture.md**: Nix implementation details
- **symlink-patterns.md**: Symlink design patterns
- **priority-mechanism.md**: Conflict resolution
- **resources/checklist.md**: Comprehensive QA checklist
- **resources/templates/**: Bundle templates
