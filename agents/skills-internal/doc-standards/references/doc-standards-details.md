# Doc Standards 詳細リファレンス

## Project Configuration

### Minimal config.yaml

Projects should create `.claude/doc-standards/config.yaml` with at minimum:

```yaml
project:
  name: "my-project"
  language: "en" # or "ja", "es", etc.

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
  reference_file: "references/tag-taxonomy.md" # or "../skills/doc-standards/references/tag-taxonomy.md"

size:
  recommended: 500
  warning: 1000
  hard_limit: 2000
```

### Complete Schema

See `references/config-schema.md` for complete configuration options.

---

## Usage Instructions

### For Project Maintainers: Setup

#### Step 1: Create Project Config

```bash
mkdir -p .claude/doc-standards/references
touch .claude/doc-standards/config.yaml
```

#### Step 2: Define Configuration

Create minimal config (see above) or comprehensive config (see `references/config-schema.md`).

#### Step 3: Create Tag Taxonomy

Define project tags in `.claude/doc-standards/references/tag-taxonomy.md`:

```markdown
# Tag Taxonomy

## Category Tags (Tier 1)

- category/guide - Step-by-step procedures
- category/reference - API docs, schemas
- category/operations - Runbooks, troubleshooting
  ...

## Audience Tags (Tier 2)

- audience/developer - Development team
- audience/operations - Operations team
  ...

## Environment Tags (Tier 3)

- environment/staging - Staging-specific
- environment/production - Production-only
  ...
```

#### Step 4: (Optional) Add Examples

Create project-specific examples:

- `references/size-guidelines-examples.md`
- `references/quality-checklist-examples.md`

#### Step 5: Verify Discovery

The skill will automatically discover and load your configuration.

### For Users: Documentation Workflow

**Creating New Documentation**:

1. Skill detects document creation intent
2. Loads project config and tag taxonomy
3. Applies metadata template (project language)
4. Guides tag selection from project taxonomy
5. Validates size against project thresholds
6. Performs quality check using project standards

**User Experience**:

- Responses in project-configured language
- Tag suggestions from project taxonomy
- Size warnings based on project thresholds
- Quality checks using project examples

---

## Fallback Behavior

If no project config found (`.claude/doc-standards/config.yaml` doesn't exist):

1. **Use minimal defaults**:
   - Metadata template: H1 + date + audience + tags
   - Tag system: 3-tier (category/audience/environment)
   - Size thresholds: 500/1000/2000 lines
   - Response language: English

2. **Prompt user to create config**:

   ```
   No project configuration found at .claude/doc-standards/config.yaml.

   For better documentation standards enforcement, create project config:

   1. mkdir -p .claude/doc-standards/references
   2. Create config.yaml (see ~/.claude/skills/doc-standards/references/config-schema.md)
   3. Define tag-taxonomy.md with project tags

   Using minimal defaults for now.
   ```

3. **Require manual tag taxonomy**:
   - User must define tags manually without taxonomy file
   - Skill validates format but doesn't suggest specific values

---

## Output Format

### Standard Document Template

When creating new documentation, provide this template (adapt to project language):

````markdown
# 📍 Doc Standards - New Document

**Document Type**: [Guide | Reference | Operations]
**Recommended Tags**:

- `category/[category-type]`
- `audience/[audience-type]`
- `environment/[environment-type]` (if applicable)

**Size Estimate**: [Current line count] lines

---

## Generated Metadata Template

```markdown
# [Icon] [Document Title]

**Last Updated**: YYYY-MM-DD
**Audience**: [Target audience]
**Tags**: `category/value`, `audience/value`, `environment/value`

## Overview

[Brief purpose statement]

## Main Content

[Content sections]

## Related Documents

[Related docs links]
```
````

---

## Next Steps

1. **Review and adjust tags** - Verify suggested tags match document purpose
2. **Add to project navigation** - Create link in docs/README.md or similar
3. **Update document mapping** - Register in mapping table (if project uses one)
4. **Commit changes** - Use project commit conventions
5. **Schedule review** - Set future review date per project policy

````

### Tag Recommendation Format

When suggesting tags, provide rationale (adapt to project language):

```markdown
## Recommended Tags

**Category Tags**:
- `category/guide` - Document provides step-by-step procedures

**Audience Tags**:
- `audience/developer` - Primary audience is development team

**Environment Tags**:
- `environment/development` - Applies to local development environment

**Rationale**: [Explain why these tags were selected based on content analysis]

**Similar Documents** (if project has document mapping):
- [filename.md] uses similar tag combination
````

---

## Best Practices

### Document Scope

**Do**:

- Focus on single topic per document
- Keep under recommended size (default: 500 lines)
- Split by topic when exceeding warning threshold (default: 1000 lines)
- Use clear, descriptive titles
- Include concrete examples

**Don't**:

- Mix multiple unrelated topics
- Create oversized documents (>2000 lines)
- Use vague titles
- Include only theory without examples
- Forget to update metadata dates

### Tag Application

**Do**:

- Use canonical format (`category/`, `audience/`, `environment/`)
- Combine multiple tags appropriately
- Reference project tag taxonomy
- Select tags that match document purpose
- Include required tiers per project config

**Don't**:

- Use non-canonical format (tags without prefixes)
- Over-tag (respect project max_recommended)
- Use only generic tags
- Create new tag categories without project discussion
- Skip required tag tiers

### Quality Maintenance

**Do**:

- Update last_updated field on every edit
- Check links periodically
- Review content freshness per project policy
- Keep code examples up-to-date
- Validate metadata completeness

**Don't**:

- Leave stale dates
- Ignore broken links
- Keep outdated information
- Use deprecated commands in examples
- Skip metadata validation

---

## References

### Generic Framework References

Load these progressively as needed:

1. **`references/metadata-template-framework.md`**
   - Standard metadata structure
   - Required field patterns
   - Document type templates
   - **Load when**: Creating headers, validating format

2. **`references/tag-system-framework.md`**
   - 3-tier tag architecture
   - Canonical format rules
   - Tag validation logic
   - **Load when**: Understanding tag system, validating tags

3. **`references/size-guidelines-framework.md`**
   - Size thresholds (customizable per project)
   - Decision tree for splits
   - 4 split strategies
   - **Load when**: Document approaching threshold, split decisions

4. **`references/quality-checklist-framework.md`**
   - Metadata quality checks
   - Content quality checks
   - Link validation framework
   - **Load when**: Final validation, periodic reviews

5. **`references/config-schema.md`**
   - Complete config.yaml schema
   - Field descriptions
   - Configuration examples
   - **Load when**: Setting up new project, updating config

### Project-Specific References

If project has configuration, also load (when needed):

- Project `tag-taxonomy.md` - Specific tag values
- Project `document-mapping.md` - Document registry (optional)
- Project `size-guidelines-examples.md` - Split examples (optional)
- Project `quality-checklist-examples.md` - Validation examples (optional)

### Progressive Disclosure

**Principle**: Load only what is needed for the current task.

- **Creating new doc**: Load metadata-template + tag-system + project tags
- **Checking size**: Load size-guidelines only
- **Adding to registry**: Load document-mapping only (if project has it)
- **Final review**: Load quality-checklist only

**Avoid**: Loading all references at once (wastes context window).

---

## Response Language

Response language is determined by project configuration:

1. **Check project config** (`.claude/doc-standards/config.yaml`):

   ```yaml
   response:
     language: "ja" # or "en", "es", etc.
   ```

2. **Use configured language**:
   - Japanese (`ja`): "メタデータテンプレートを適用します"
   - English (`en`): "Applying metadata template"
   - Spanish (`es`): "Aplicando plantilla de metadatos"

3. **Default to English** if no config found

---

## Integration Points

This skill works with:

- **Project rules** (`.claude/rules/documentation-rules.md` or similar)
- **Documentation hub** (`docs/README.md` or project-specific location)
- **Document mapping** (project-defined registry)

**Workflow**:

1. User requests documentation creation
2. This skill triggers automatically
3. Load project config and discover settings
4. Apply metadata template in project language
5. Guide tag selection from project taxonomy
6. Validate using project thresholds and standards
7. Suggest navigation/mapping updates per project conventions

---

## Setup Instructions for New Projects

See `README.md` in this directory for complete setup instructions.

**Quick Start**:

1. Create `.claude/doc-standards/config.yaml`
2. Define tag taxonomy in `references/tag-taxonomy.md`
3. (Optional) Add project examples
4. Skill will auto-discover configuration

For complete setup guide and examples, see:

- `~/.claude/skills/doc-standards/README.md`
- `~/.claude/skills/doc-standards/references/config-schema.md`
