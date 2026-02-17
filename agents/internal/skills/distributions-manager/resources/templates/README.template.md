# [Bundle Name]

[Brief description of bundle purpose and target workflow/team]

---

## Contents

### Skills ([count])

- **[skill-name]**: [Brief description of what this skill does]
- **[skill-name]**: [Brief description]
- ...

### Commands ([count])

- **[command-name]**: [Brief description of what this command does]
- **[command-group:subcommand]**: [Brief description]
- ...

### Configuration

- **config/shared-rules.md**: [Description of shared rules]
- **config/bundle-config.json**: [Description of bundle metadata]
- **config/templates/**: [Description of included templates]

---

## Installation

This bundle is included in `bundles/[bundle-name]/`.

### Deploy with Nix Home Manager

```bash
home-manager switch --flake ~/.config --impure
```

### Verify Installation

```bash
# Check skills
ls -la ~/.claude/skills/ | grep -E 'skill1|skill2'

# Check commands
mise run skills:list 2>/dev/null | jq '.skills[] | select(.source == "local")'
```

---

## Usage

[Provide usage examples or workflow descriptions]

### Example 1: [Workflow Name]

```bash
# Step 1: ...
# Step 2: ...
```

### Example 2: [Workflow Name]

```bash
# Step 1: ...
# Step 2: ...
```

---

## Configuration

[Optional: Describe any configuration options or customization]

### Customizing Skills

[How to override or customize included skills]

### Adding Local Overrides

```bash
# Create local override in skills-internal/
cp -r bundles/[bundle-name]/skills/[skill] skills-internal/
# Modify skills-internal/[skill]/SKILL.md
```

---

## Maintenance

### Adding Skills

```bash
cd bundles/[bundle-name]/skills
ln -s ../../../skills-internal/[new-skill] ./
home-manager switch --flake ~/.config --impure
```

### Removing Skills

```bash
cd bundles/[bundle-name]/skills
rm [skill-name]
home-manager switch --flake ~/.config --impure
```

### Updating Bundle

```bash
# Pull latest changes
git pull origin main

# Redeploy
home-manager switch --flake ~/.config --impure
```

---

## Version History

- **[version]** ([date]): [Changes description]
- **1.0.0** (2025-02-11): Initial release

---

## Maintainers

- [Name] <[email]>
- [Team Name] <[team-email]>

---

## Related Documentation

- [Link to skill documentation]
- [Link to command documentation]
- [Link to workflow guides]

---

## License

[License information, if applicable]
