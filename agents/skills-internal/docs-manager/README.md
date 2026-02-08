# Docs Manager Plugin

Comprehensive documentation validation and management system for Claude Code projects.

## Overview

Docs Manager provides systematic documentation quality assurance through configurable validation rules, metadata standards, tag systems, and size management. All paths and project-specific rules are externalized via configuration files, making this a truly generic and reusable solution.

## Features

- **Configurable Paths**: Set documentation root directory via configuration
- **Metadata Validation**: Verify required metadata fields and formats
- **Tag System Compliance**: Validate tags against project-specific vocabulary
- **Size Management**: Monitor document size and suggest splits
- **Link Validation**: Check internal and external links
- **Project-Specific Rules**: Apply custom validation rules
- **Multiple Project Types**: Built-in support for generic, dotfiles, pr-labeler, terraform-infra projects
- **Extensible**: Easy to add custom project types

## Quick Start

### 1. Installation

Install as a Claude Code plugin (installation method depends on your marketplace setup).

### 2. Create Configuration

Copy the configuration template to your project root:

```bash
cp templates/docs-manager-config.template.json .docs-manager-config.json
```

Or start with an example:

```bash
# For generic projects
cp examples/generic-config.json .docs-manager-config.json

# For dotfiles projects
cp examples/dotfiles-config.json .docs-manager-config.json

# For custom projects
cp examples/custom-project-config.json .docs-manager-config.json
```

### 3. Customize Configuration

Edit `.docs-manager-config.json` to match your project:

```json
{
  "docs_root": "./docs",
  "project_type": "generic",
  "required_tags": ["category/", "audience/"],
  "tag_separator": ", ",
  "size_limits": {
    "ideal": 300,
    "acceptable": 500,
    "warning": 1000,
    "maximum": 2000
  }
}
```

### 4. Use in Claude Code

Activate the docs-manager skill when working with documentation:

```
User: "Review all documentation"
Claude: [Loads docs-manager skill]
        [Loads .docs-manager-config.json]
        [Validates all documents in configured docs_root]
        [Generates quality report]
```

## Configuration

### Basic Configuration

Minimum required configuration:

```json
{
  "docs_root": "./docs",
  "project_type": "generic"
}
```

### Complete Configuration

See `templates/docs-manager-config.template.json` for full schema with all available options.

### Configuration Options

#### Core Settings

- `docs_root`: Documentation directory path (default: `./docs`)
- `project_type`: Project type identifier (`generic`, `dotfiles`, `pr-labeler`, `terraform-infra`, `custom`)
- `required_tags`: Array of required tag prefixes (e.g., `["category/", "audience/"]`)
- `optional_tags`: Array of optional tag prefixes
- `tag_separator`: Tag separator in metadata (`,` or ` `)

#### Size Limits

```json
{
  "size_limits": {
    "ideal": 300,
    "acceptable": 500,
    "warning": 1000,
    "maximum": 2000
  }
}
```

#### Metadata Format

```json
{
  "metadata_format": {
    "date_field": "最終更新",
    "date_format": "YYYY-MM-DD",
    "audience_field": "対象",
    "tags_field": "タグ"
  }
}
```

#### Tag Vocabulary

```json
{
  "tag_vocabulary": {
    "category/": ["documentation", "guide", "api"],
    "audience/": ["developer", "user", "contributor"]
  }
}
```

#### Custom Rules

```json
{
  "custom_rules": {
    "detection_patterns": [
      {
        "pattern": "docs/tools/*.md",
        "description": "Tool-specific documentation"
      }
    ],
    "required_files": ["README.md"],
    "update_frequency": {
      "README.md": "quarterly"
    }
  }
}
```

#### Link Validation

```json
{
  "link_validation": {
    "enabled": true,
    "config_file": ".markdown-link-check.json"
  }
}
```

#### Tool Integration

```json
{
  "tools": {
    "linter": "npm run lint:docs",
    "formatter": "prettier --write",
    "link_checker": "markdown-link-check"
  }
}
```

## Usage Examples

### Review Documentation

```
User: "Review all documentation in this project"

Claude will:
1. Load .docs-manager-config.json
2. Scan configured docs_root directory
3. Validate metadata for each document
4. Check tag compliance
5. Verify document sizes
6. Validate links (if enabled)
7. Generate quality report
```

### Create New Documentation

```
User: "Help me create a new API reference document"

Claude will:
1. Load project configuration
2. Suggest appropriate tags from vocabulary
3. Provide metadata template
4. Recommend document structure
5. Validate before saving
```

### Check Link Integrity

```
User: "Check for broken links in documentation"

Claude will:
1. Load link validation configuration
2. Extract all links from documents
3. Validate internal references
4. Test external URLs (if configured)
5. Report broken links
6. Suggest fixes
```

## Directory Structure

```
docs-manager/
├── README.md                          # This file
├── SKILL.md                           # Skill definition for Claude Code
├── templates/                         # Configuration templates
│   └── docs-manager-config.template.json
├── examples/                          # Example configurations
│   ├── generic-config.json
│   ├── dotfiles-config.json
│   └── custom-project-config.json
└── references/                        # Reference documentation
    ├── metadata-standards.md          # Metadata format guidelines
    ├── size-management.md             # Document size best practices
    ├── tag-systems.md                 # Tag system definitions
    └── config-templates.md            # Configuration templates (legacy)
```

## Reference Documentation

- **[Metadata Standards](references/metadata-standards.md)**: Comprehensive guide to metadata formats, validation rules, and best practices
- **[Size Management](references/size-management.md)**: Document size guidelines, splitting strategies, and structure organization
- **[Tag Systems](references/tag-systems.md)**: Tag system definitions and project-specific requirements
- **[Configuration Templates](references/config-templates.md)**: Detailed configuration examples and templates

## Project Types

### Generic

Default project type with minimal assumptions:

- Required tags: `category/`, `audience/`
- Standard size limits
- Basic metadata validation
- Suitable for most projects

### Dotfiles

Specialized for dotfiles projects:

- Additional required tags: `tool/`, `layer/`, `environment/`
- Performance impact documentation
- Update frequency tracking for core tools
- Tool-specific validation rules

### PR Labeler

GitHub Action projects:

- Required tags: `category/`, `audience/`
- Optional environment tags
- cc-sdd integration
- Status tracking (created/planned/auto-updated)

### Terraform Infrastructure

Infrastructure as Code projects:

- Required tags: `category/`, `audience/`, `environment/`
- Multi-account support
- mise task integration
- Directory structure validation

### Custom

Fully customizable project type:

- Define your own requirements
- Custom tag vocabulary
- Project-specific rules
- Flexible validation

## Extending

### Adding New Project Type

1. Create example configuration in `examples/`
2. Define tag vocabulary
3. Specify custom rules
4. Document usage in README
5. Update SKILL.md if needed

### Custom Validation Rules

Add custom validation via configuration:

```json
{
  "custom_rules": {
    "detection_patterns": [
      {
        "pattern": "your-pattern",
        "description": "What this detects"
      }
    ],
    "required_files": ["YOUR_FILE.md"],
    "update_frequency": {
      "YOUR_FILE.md": "monthly"
    },
    "performance_impact_required": ["performance-doc.md"],
    "detail_level_required": "⭐⭐⭐⭐"
  }
}
```

## Integration

### With Claude Code Skills

The docs-manager skill automatically integrates with:

- **docs-index**: Documentation discovery and navigation
- **markdown-docs**: Content quality evaluation
- **code-review**: Documentation review in code review workflow

### With External Tools

Configure external tools for enhanced validation:

```json
{
  "tools": {
    "linter": "markdownlint docs/**/*.md",
    "formatter": "prettier --write docs/**/*.md",
    "link_checker": "markdown-link-check docs/**/*.md"
  }
}
```

### With CI/CD

Integrate validation in CI pipeline:

```yaml
# .github/workflows/docs.yml
name: Documentation Quality

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Validate Documentation
        run: |
          # Use configured tools
          npm run lint:docs
          npm run check:links
```

## Troubleshooting

### Configuration Not Found

**Problem**: `.docs-manager-config.json` not found

**Solution**: Uses default generic configuration. Create configuration file in project root if customization needed.

### Invalid Configuration

**Problem**: Configuration file has errors

**Solution**: Validate against schema in `templates/docs-manager-config.template.json`. Check JSON syntax and required fields.

### Tag Validation Errors

**Problem**: Tags not recognized

**Solution**: Check `tag_vocabulary` in configuration. Add missing tags or update vocabulary.

### Link Validation Failures

**Problem**: Many false positives in link checking

**Solution**: Configure `.markdown-link-check.json` with appropriate ignore patterns and replacement rules.

## Best Practices

1. **Start Simple**: Begin with generic configuration, add customization as needed
2. **Version Control**: Commit `.docs-manager-config.json` to repository
3. **Document Changes**: Update configuration documentation when adding custom rules
4. **Regular Reviews**: Periodically review and update configuration
5. **Team Alignment**: Ensure team understands tag vocabulary and metadata requirements
6. **Automation**: Integrate validation in CI/CD pipeline
7. **Incremental Adoption**: Apply rules gradually to existing documentation

## FAQ

### Q: Do I need a configuration file?

A: No, docs-manager works without configuration using generic defaults. Configuration is optional but recommended for customization.

### Q: Can I use multiple project types?

A: No, one project type per configuration. Use `custom` type for mixed requirements.

### Q: How do I migrate existing documentation?

A: Start with configuration matching current structure, then gradually enhance. See [Metadata Standards](references/metadata-standards.md#migration-guide).

### Q: What if my project doesn't fit any built-in type?

A: Use `custom` project type and define your own rules.

### Q: Can I override specific rules?

A: Yes, all rules are configurable. See template for complete options.

## Contributing

To contribute improvements:

1. Test changes with multiple project types
2. Update documentation and examples
3. Maintain backward compatibility
4. Follow existing configuration patterns

## License

[Specify license]

## Support

For issues or questions:

- Check reference documentation in `references/`
- Review example configurations in `examples/`
- Consult SKILL.md for Claude Code integration details
