# Distribution Bundle QA Checklist

## Pre-Creation

### Planning

- [ ] Bundle purpose clearly defined
- [ ] Target workflow/team identified
- [ ] Skill/command list compiled
- [ ] Naming convention decided (lowercase-with-hyphens)
- [ ] Existing bundles reviewed for overlap

### Prerequisites

- [ ] Nix Home Manager installed and configured
- [ ] Access to `agents/` directory
- [ ] Understanding of symlink-based architecture
- [ ] Familiarity with priority mechanism (Local > External > Distribution)

---

## Structure

### Directory Creation

- [ ] Bundle directory created: `distributions/<bundle-name>/`
- [ ] Subdirectories created:
  - [ ] `skills/`
  - [ ] `commands/`
  - [ ] `config/` (optional)
- [ ] README.md created at bundle root

### Naming Validation

- [ ] Bundle name uses lowercase-with-hyphens
- [ ] No spaces or special characters in bundle name
- [ ] Bundle name is descriptive and clear

---

## Symlinks

### Skills Symlinks

- [ ] All skill symlinks use relative paths (`../../../skills-internal/`)
- [ ] No absolute paths used
- [ ] Symlink targets exist (verified with `test -e`)
- [ ] All skill targets contain `SKILL.md`
- [ ] Path depth is correct (3 levels: `../../../`)

### Validation command

```bash
find distributions/<bundle-name>/skills/ -type l -exec sh -c '
  target=$(readlink -f "$1")
  test -f "$target/SKILL.md" || echo "Missing SKILL.md: $1"
' _ {} \;
```

### Commands Symlinks

- [ ] All command symlinks use relative paths (`../../../commands-internal/`)
- [ ] No absolute paths used
- [ ] Symlink targets exist (verified with `test -e`)
- [ ] All command targets contain `command.ts` (directly or in subdirectories)
- [ ] Path depth is correct (3 levels: `../../../`)

### Validation command

```bash
find distributions/<bundle-name>/commands/ -type l -exec sh -c '
  target=$(readlink -f "$1")
  find "$target" -name "command.ts" -print -quit | grep -q . || echo "Missing command.ts: $1"
' _ {} \;
```

### Broken Symlinks Check

- [ ] No broken symlinks detected

### Validation command

```bash
find distributions/<bundle-name>/ -type l -exec test ! -e {} \; -print
# Should output nothing
```

---

## Configuration

### Optional Config Files

- [ ] `config/shared-rules.md` created (if needed)
- [ ] `config/bundle-config.json` created (if needed)
- [ ] `config/templates/` directory created (if needed)
- [ ] All config files validated (syntax check)

### Metadata Validation

- [ ] Bundle version specified (semantic versioning: `1.0.0`)
- [ ] Maintainers listed
- [ ] Description provided
- [ ] License specified (if applicable)

---

## Documentation

### README.md

- [ ] Title and description provided
- [ ] Contents section lists all skills and commands
- [ ] Installation instructions included
- [ ] Usage examples provided
- [ ] Maintenance instructions documented
- [ ] Version history started
- [ ] Maintainers listed
- [ ] Related documentation linked

### Inline Documentation

- [ ] Complex symlink patterns explained
- [ ] Custom configuration documented
- [ ] Known issues or limitations noted

---

## Testing

### Pre-Deployment

- [ ] Dry-run executed successfully:

```bash
home-manager build --flake ~/.config --impure --dry-run
```

- [ ] No Nix evaluation errors
- [ ] No symlink resolution errors

### Deployment

- [ ] Bundle deployed successfully:

```bash
home-manager switch --flake ~/.config --impure
```

- [ ] No deployment errors
- [ ] Skills symlinks created in `~/.claude/skills/`
- [ ] Commands available in catalog

### Verification

```bash
ls -la ~/.claude/skills/ | grep -f <(ls -1 distributions/<bundle-name>/skills/)
```

### Runtime

- [ ] Skills trigger correctly:

```bash
mise run skills:list 2>/dev/null | jq '.skills[] | select(.source == "distribution")'
```

- [ ] Commands execute without errors
- [ ] Priority mechanism works as expected (Local > External > Distribution)

---

## Priority Validation

### Source Attribution

- [ ] Skills show correct source tag (`distribution`)
- [ ] Local overrides take precedence (if applicable)
- [ ] External overrides take precedence over distribution (if applicable)

### Check source attribution

```bash
mise run skills:list 2>/dev/null | jq '.skills[] | {id, source}'
```

### Conflict Resolution

- [ ] Local skills override distribution (verified)
- [ ] External skills override distribution (verified)
- [ ] No unexpected priority conflicts

---

## Performance

### Token Efficiency

- [ ] SKILL.md files use progressive disclosure
- [ ] Large references split into separate files
- [ ] Only essential information in entry points
- [ ] Token budget estimated and documented

### Load Time

- [ ] Bundle deployment completes in reasonable time (<30s)
- [ ] No excessive symlink resolution delays
- [ ] Nix evaluation time acceptable

---

## Maintenance

### Version Control

- [ ] Bundle tracked in Git (if applicable)
- [ ] `.gitignore` configured to exclude generated files
- [ ] Commit messages follow conventions
- [ ] Version tags created for releases

### Documentation Sync

- [ ] README.md reflects current contents
- [ ] Skill/command counts accurate
- [ ] Version history updated
- [ ] Related documentation links valid

### Cleanup

- [ ] No unused symlinks
- [ ] No deprecated skills/commands included
- [ ] Config files up-to-date
- [ ] Temporary files removed

---

## Security

### Path Validation

- [ ] No symlinks pointing outside repository
- [ ] No absolute paths to sensitive directories
- [ ] No hardcoded credentials in config files

### Access Control

- [ ] Bundle permissions appropriate (readable by user)
- [ ] No world-writable files
- [ ] Config files protected appropriately

---

## Checklist Summary

### Critical Items (Must-Have)

- ✓ Relative symlinks only
- ✓ All symlink targets exist
- ✓ SKILL.md present in all skill targets
- ✓ command.ts present in all command targets
- ✓ README.md created
- ✓ Dry-run successful
- ✓ Deployment successful

### Recommended Items (Should-Have)

- ✓ Bundle metadata documented
- ✓ Usage examples provided
- ✓ Priority mechanism tested
- ✓ Token budget estimated
- ✓ Version control configured

### Optional Items (Nice-to-Have)

- ○ Custom configuration files
- ○ Templates directory
- ○ Performance benchmarks
- ○ Automated validation scripts

---

## Automation Scripts

### Full Validation Script

```bash
#!/usr/bin/env bash
# validate-bundle.sh

BUNDLE_NAME="${1:-default}"
BUNDLE_PATH="distributions/$BUNDLE_NAME"

echo "Validating bundle: $BUNDLE_NAME"

# Structure check
test -d "$BUNDLE_PATH" || { echo "❌ Bundle not found"; exit 1; }
test -d "$BUNDLE_PATH/skills" || { echo "❌ skills/ missing"; exit 1; }
test -d "$BUNDLE_PATH/commands" || { echo "❌ commands/ missing"; exit 1; }
test -f "$BUNDLE_PATH/README.md" || { echo "⚠️  README.md missing"; }

# Broken symlinks check
broken=$(find "$BUNDLE_PATH" -type l -exec test ! -e {} \; -print)
if [ -n "$broken" ]; then
  echo "❌ Broken symlinks found:"
  echo "$broken"
  exit 1
fi

# SKILL.md check
find "$BUNDLE_PATH/skills/" -type l -exec sh -c '
  target=$(readlink -f "$1")
  test -f "$target/SKILL.md" || echo "❌ Missing SKILL.md: $1"
' _ {} \;

# command.ts check
find "$BUNDLE_PATH/commands/" -type l -exec sh -c '
  target=$(readlink -f "$1")
  find "$target" -name "command.ts" -print -quit | grep -q . || echo "❌ Missing command.ts: $1"
' _ {} \;

echo "✅ Validation complete"
```

### Usage

```bash
bash resources/scripts/validate-bundle.sh my-bundle
```

---

## Related References

- **creating-bundles.md**: Step-by-step creation guide
- **symlink-patterns.md**: Symlink design patterns
- **priority-mechanism.md**: Priority validation
- **templates/bundle-structure.txt**: Structure template
