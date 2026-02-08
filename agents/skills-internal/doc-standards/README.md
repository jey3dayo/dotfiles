# Documentation Standards Framework

Generic, project-agnostic documentation standards skill for Claude Code.

---

## Overview

This skill provides a flexible framework for enforcing documentation standards across projects. It discovers project-specific configuration and adapts its behavior accordingly.

**Key Features**:

- **Metadata template application** - Standardized headers with validation
- **Tag system guidance** - 3-tier tag taxonomy support
- **Size management** - Automatic threshold monitoring and split suggestions
- **Quality validation** - Comprehensive quality checks

**Configuration Discovery**:

The skill automatically discovers project configuration at `.claude/doc-standards/config.yaml` and loads project-specific tag taxonomies, examples, and preferences.

---

## Quick Start

### For New Projects

**Step 1**: Create configuration directory

```bash
mkdir -p .claude/doc-standards/references
```

**Step 2**: Create minimal `config.yaml`

```bash
cat > .claude/doc-standards/config.yaml << 'EOF'
project:
  name: "my-project"
  language: "en"

metadata:
  required_fields:
    - last_updated
    - audience
    - tags

tags:
  tier_system:
    - category/
    - audience/
  min_required:
    - category/
    - audience/
  reference_file: "references/tag-taxonomy.md"

size:
  recommended: 500
  warning: 1000
  hard_limit: 2000
EOF
```

**Step 3**: Define your project's tags

```bash
cat > .claude/doc-standards/references/tag-taxonomy.md << 'EOF'
# Tag Taxonomy

## Category Tags (Tier 1)
- category/guide - Step-by-step procedures
- category/reference - API docs, schemas
- category/operations - Runbooks, troubleshooting

## Audience Tags (Tier 2)
- audience/developer - Development team
- audience/operations - Operations team

## Environment Tags (Tier 3)
- environment/development - Local development
- environment/staging - Staging environment
- environment/production - Production environment
EOF
```

**Step 4**: Start using the skill

Create documentation and the skill will automatically apply your standards:

```markdown
# 📄 My New Document

**Last Updated**: 2025-12-22
**Audience**: Developer
**Tags**: `category/guide`, `audience/developer`

## Overview

...
```

---

## File Structure

### Global Skill (this directory)

```
~/.claude/skills/doc-standards/
├── SKILL.md                                 # Generic skill framework
├── README.md                                # This file
└── references/
    ├── metadata-template-framework.md       # Generic metadata structure
    ├── tag-system-framework.md              # Generic tag tier system
    ├── size-guidelines-framework.md         # Generic size management
    ├── quality-checklist-framework.md       # Generic quality checks
    └── config-schema.md                     # Configuration reference
```

### Project Configuration

```
.claude/doc-standards/                       # Project config directory
├── config.yaml                              # Project settings (REQUIRED)
└── references/
    ├── tag-taxonomy.md                      # Project tags (REQUIRED)
    ├── document-mapping.md                  # Document registry (OPTIONAL)
    ├── size-guidelines-examples.md          # Project split examples (OPTIONAL)
    └── quality-checklist-examples.md        # Project validation examples (OPTIONAL)
```

**Alternative**: Projects can also use `.claude/skills/doc-standards/references/` for taxonomy (legacy pattern).

---

## Configuration

### Minimal Configuration

Minimum required to get started:

```yaml
project:
  name: "my-project"
  language: "en"

metadata:
  required_fields:
    - last_updated
    - audience
    - tags

tags:
  tier_system:
    - category/
    - audience/
  min_required:
    - category/
    - audience/
  reference_file: "references/tag-taxonomy.md"

size:
  recommended: 500
  warning: 1000
  hard_limit: 2000
```

### Complete Schema

See `references/config-schema.md` for complete configuration options including:

- Metadata format customization
- Quality validation settings
- Integration points
- Response language/format

---

## Usage

### Automatic Triggers

The skill activates when users:

- Mention "document", "documentation", "metadata", "tags"
- Work with `.md` files in `docs/` directory
- Request documentation standards guidance
- Create or update documentation

### Workflow

1. **User creates documentation**
2. **Skill loads project config** (`.claude/doc-standards/config.yaml`)
3. **Applies project standards**:
   - Metadata template in project language
   - Tag suggestions from project taxonomy
   - Size validation against project thresholds
   - Quality checks using project standards
4. **Responds in project language**

### Examples

**Creating new doc** (English project):

```
User: "Create a new deployment guide"
Skill: "I'll help you create a deployment guide with proper metadata.
       Based on your project tags, I recommend:
       - Tags: `category/deployment`, `category/operations`, `audience/operations`
       - Audience: Operations
       Let me apply the template..."
```

**Creating new doc** (Japanese project):

```
User: "新しいデプロイメントガイドを作成"
Skill: "デプロイメントガイドを作成します。メタデータを適用します。
       プロジェクトのタグから推奨:
       - タグ: `category/deployment`, `category/operations`, `audience/operations`
       - 対象: 運用担当者
       テンプレートを適用します..."
```

---

## Customization

### Adding Custom Tag Tiers

Beyond the standard 3-tier system, add custom tiers:

```yaml
tags:
  tier_system:
    - category/
    - audience/
    - environment/
    - priority/ # Custom: priority/high, priority/low
    - difficulty/ # Custom: difficulty/beginner, difficulty/advanced
```

### Adjusting Size Thresholds

Customize based on your team's preferences:

```yaml
size:
  recommended: 400 # Tighter than default 500
  warning: 800 # Tighter than default 1000
  hard_limit: 1600 # Tighter than default 2000
```

### Localizing Field Labels

Use your project's language:

```yaml
metadata:
  required_fields:
    - "最終更新" # Last Updated (Japanese)
    - "対象" # Audience (Japanese)
    - "タグ" # Tags (Japanese)
```

### Response Language

Set project response language:

```yaml
response:
  language: "ja" # Japanese
  format: "conversational"
```

---

## Integration

### With Project Rules

Link to high-level project rules:

```yaml
integration:
  rules_file: ".claude/rules/documentation-rules.md"
  docs_hub: "docs/README.md"
```

### With Document Mapping

Enable document registry:

```yaml
quality:
  mapping:
    enabled: true
    file: "references/document-mapping.md"
```

### With CI/CD

Automate quality checks:

```yaml
# .github/workflows/docs.yml
- name: Validate Documentation
  run: |
    # Check metadata
    ./scripts/check-doc-metadata.sh
    # Validate links
    npm run check-links
    # Size validation
    find docs -name "*.md" -exec wc -l {} \; | \
      awk '$1 > 1000 {print "⚠️ " $2; fail=1} END {exit fail}'
```

---

## Examples

### Example 1: Software Project

```yaml
project:
  name: "MyApp"
  language: "en"

tags:
  tier_system: [category/, audience/, environment/]
  reference_file: "references/tag-taxonomy.md"

size:
  recommended: 500
  warning: 1000
  hard_limit: 2000
```

### Example 2: Enterprise Project (Japanese)

```yaml
project:
  name: "ASTA"
  language: "ja"

metadata:
  formats:
    date: "YYYY-MM-DD"
  freshness:
    warning_days: 180

quality:
  mapping:
    enabled: true
  links:
    validate: true

response:
  language: "ja"
  format: "conversational"
```

### Example 3: Open Source Project

```yaml
project:
  name: "OpenProject"
  language: "en"

tags:
  max_recommended: 3 # Simpler tagging

size:
  recommended: 600 # Slightly larger docs OK
  warning: 1200
  hard_limit: 2400

quality:
  links:
    validate: true
    update_readme: true
    readme_path: "README.md"
```

---

## Troubleshooting

### Issue: Skill not finding config

**Symptom**: Skill uses English defaults, can't find project tags

**Solution**:

```bash
# Verify config exists
ls -la .claude/doc-standards/config.yaml

# Check YAML syntax
cat .claude/doc-standards/config.yaml

# Verify permissions
chmod 644 .claude/doc-standards/config.yaml
```

### Issue: Tags not loading

**Symptom**: Skill can't suggest project tags

**Solution**:

```bash
# Check path in config
grep reference_file .claude/doc-standards/config.yaml

# Verify taxonomy file exists
ls -la .claude/doc-standards/references/tag-taxonomy.md

# Check file content
cat .claude/doc-standards/references/tag-taxonomy.md
```

### Issue: Wrong language responses

**Symptom**: Skill responds in English but project uses Japanese

**Solution**:

```yaml
# Add to config.yaml
response:
  language: "ja"
```

---

## Migration

### From Project-Specific Skill

If you have an existing project-specific doc-standards skill:

1. **Extract configuration values** from old SKILL.md
2. **Create** `.claude/doc-standards/config.yaml` with those values
3. **Move** tag taxonomy to config location
4. **Update** path references in config
5. **Test** configuration discovery
6. **Optional**: Keep lightweight project skill as override

See `references/config-schema.md` for "Migration" section.

---

## Support

### Documentation

- **SKILL.md**: Complete skill capabilities and usage
- **references/config-schema.md**: Full configuration reference
- **references/**: Framework documentation for each component

### Getting Help

- Check configuration against `references/config-schema.md`
- Verify file paths are correct (relative to `.claude/doc-standards/`)
- Validate YAML syntax
- Review troubleshooting section above

---

## Contributing

This is a generic framework designed to work across projects. To improve it:

1. Keep generic logic in global skill
2. Keep project-specific content in project config
3. Maintain backward compatibility
4. Document configuration options clearly

---

## License

Part of Claude Code ecosystem. See project license for details.
