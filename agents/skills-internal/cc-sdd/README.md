# cc-sdd: Claude Code Spec-Driven Development

A standardized, configurable plugin for Kiro-style spec-driven development in Claude Code.

## Overview

cc-sdd (Claude Code Spec-Driven Development) provides a structured, phase-based approach to software development with:

- **Configurable directory structure** via `.kiro-config.json`
- **3-phase workflow**: Steering → Specification → Implementation
- **Progressive disclosure** for efficient context loading
- **Multi-project support** with per-project customization

## Quick Start

### For New Projects

1. **Copy default configuration**

   ```bash
   cp .kiro-config.default.json .kiro-config.json
   ```

2. **Copy default directory structure**

   ```bash
   cp -r .kiro-default .kiro
   ```

3. **Initialize your first spec**

   ```bash
   /kiro:spec-init "Your feature description"
   ```

### For Existing cc-sdd Projects

If you already have a `.kiro/` directory:

```bash
# Create config matching your current structure
cp .kiro-config.default.json .kiro-config.json

# Your existing specs will work immediately
/kiro:spec-status
```

See [MIGRATION.md](MIGRATION.md) for detailed migration scenarios.

## Configuration

### Default Structure

```json
{
  "version": "1.0.0",
  "paths": {
    "root": ".kiro",
    "steering": "steering",
    "specs": "specs",
    "settings": "settings"
  }
}
```

### Custom Structure Example

```json
{
  "version": "1.0.0",
  "paths": {
    "root": "docs/specifications",
    "steering": "guidelines",
    "specs": "features"
  }
}
```

See `.kiro-config.schema.json` for full configuration options.

## Directory Structure

```
.kiro/                     # Root directory (configurable)
├── steering/              # Project-wide guidance
│   ├── product.md         # Product context
│   ├── tech.md            # Technology stack
│   └── structure.md       # Project structure
├── specs/                 # Individual feature specs
│   └── [feature-name]/
│       ├── spec.json      # Metadata
│       ├── requirements.md # EARS-format requirements
│       ├── design.md      # Technical design
│       └── tasks.md       # Implementation tasks
└── settings/              # Templates and rules
    ├── templates/
    └── rules/
```

## Workflow

### Phase 0: Steering (Optional)

Establish project-wide guidance:

```bash
/kiro:steering              # Core steering files
/kiro:steering-custom       # Custom domain-specific guidance
```

### Phase 1: Specification

Create spec with 3-stage approval:

```bash
/kiro:spec-init "Feature description"
/kiro:spec-requirements [feature]  # Generate requirements
/kiro:spec-design [feature] -y     # Create design (auto-approve)
/kiro:spec-tasks [feature] -y      # Generate tasks
```

### Phase 2: Implementation & Tracking

```bash
/kiro:spec-impl [feature]          # Implement tasks
/kiro:spec-status [feature]        # Check progress
```

### Validation Tools

```bash
/kiro:validate-gap [feature]       # Analyze implementation gap
/kiro:validate-design [feature]    # Review design quality
/kiro:validate-impl [feature]      # Validate implementation
```

## Key Features

### Configurable Paths

All directory paths are configurable via `.kiro-config.json`, allowing:

- Project-specific structures
- Team conventions
- Integration with existing documentation systems

### Progressive Disclosure

Skill uses Progressive Disclosure pattern:

- Core skill is lightweight (~8KB)
- Detailed references loaded on-demand
- Reduces context usage by 5x

### Backward Compatibility

- Default config matches legacy `.kiro/` structure
- Existing projects work without changes
- Zero-downtime migration path

### Multi-Project Support

Different projects can use different structures:

```bash
# Project A: Traditional
.kiro/steering/ + .kiro/specs/

# Project B: Documentation-centric
docs/architecture/ + docs/features/

# Project C: Monorepo
engineering/specs/guidelines/ + engineering/specs/projects/
```

## Commands Reference

### Steering Management

- `/kiro:steering` - Manage core steering files
- `/kiro:steering-custom` - Create custom steering

### Spec Management

- `/kiro:spec-init [description]` - Initialize new spec
- `/kiro:spec-requirements [feature]` - Generate requirements
- `/kiro:spec-design [feature] [-y]` - Create design
- `/kiro:spec-tasks [feature] [-y]` - Generate tasks
- `/kiro:spec-impl [feature] [tasks]` - Implement
- `/kiro:spec-status [feature]` - Check progress

### Validation

- `/kiro:validate-gap [feature]` - Gap analysis
- `/kiro:validate-design [feature]` - Design review
- `/kiro:validate-impl [feature]` - Implementation validation

### Utilities

- `/kiro:spec-quick [description]` - Fast-track workflow

## Documentation

- **[SKILL.md](SKILL.md)** - Complete plugin documentation
- **[MIGRATION.md](MIGRATION.md)** - Migration guide from legacy cc-sdd
- **[shared/config-loader.md](shared/config-loader.md)** - Configuration system details
- **[references/](references/)** - Detailed reference documentation
  - `workflow.md` - Complete workflow details
  - `steering-system.md` - Steering system guide
  - `specification-system.md` - Specification system guide
  - `commands-reference.md` - All commands reference
  - `development-rules.md` - Development rules
  - `ears-format.md` - EARS requirements format

## Development Rules

1. **3-Stage Approval**: Requirements → Design → Tasks → Implementation
2. **Phase Separation**: No phase skipping allowed
3. **Human Review**: Explicit approval required at each phase
4. **Task Tracking**: Update task status during implementation
5. **Configuration Respect**: Follow project-specific settings

## Configuration Schema

Full schema available in `.kiro-config.schema.json`.

Key configuration sections:

- **paths**: Directory structure
- **workflow**: Language, auto-approval, phase settings
- **templates**: Template file paths
- **rules**: Rule file paths
- **validation**: Validation requirements

## Migration

Migrating from legacy cc-sdd? See [MIGRATION.md](MIGRATION.md) for:

- New project setup
- Existing project migration (keep structure)
- Existing project migration (reorganize)
- Multi-project scenarios
- Troubleshooting

## Best Practices

### For New Projects

1. Use default structure unless you have specific requirements
2. Commit `.kiro-config.json` to version control
3. Document any customizations in project README

### For Teams

1. Establish conventions across projects
2. Share config templates for different project types
3. Document rationale for custom structures

### For Large Projects

1. Use steering extensively for consistency
2. Break features into smaller specs
3. Track progress regularly with `/kiro:spec-status`

## Troubleshooting

### Commands Can't Find Files

Check configuration and paths:

```bash
cat .kiro-config.json
ls -la .kiro/specs/
```

### Templates Not Found

Ensure settings directory has templates:

```bash
ls -la .kiro/settings/templates/
```

If missing, copy from plugin:

```bash
cp -r [plugin-path]/.kiro-default/settings .kiro/
```

### Invalid Configuration

Validate JSON syntax:

```bash
jq . .kiro-config.json
```

Restore from default if needed:

```bash
cp .kiro-config.default.json .kiro-config.json
```

See [MIGRATION.md](MIGRATION.md#common-issues) for more troubleshooting.

## Version

Current version: 1.0.0

## License

See plugin marketplace license.

## Support

For issues, questions, or contributions:

1. Check [MIGRATION.md](MIGRATION.md) for common issues
2. Review [SKILL.md](SKILL.md) for complete documentation
3. Consult [shared/config-loader.md](shared/config-loader.md) for configuration details
