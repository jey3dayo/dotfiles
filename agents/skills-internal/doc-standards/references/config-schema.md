# doc-standards Configuration Schema

Complete configuration reference for project-specific doc-standards setup.

---

## Overview

This document defines the complete schema for `.claude/doc-standards/config.yaml`, which projects use to customize the doc-standards skill framework.

---

## Complete Schema

```yaml
# Project identification and language
project:
  name: string                     # Project name (e.g., "ASTA", "my-project")
  language: "en" | "ja" | "es" | string  # Response language (ISO 639-1 code)

# Metadata field configuration
metadata:
  required_fields:                 # List of required metadata fields
    - field_name                   # e.g., "last_updated", "audience", "tags"
    ...

  formats:                         # Format specifications
    date: string                   # Date format (e.g., "YYYY-MM-DD", "MM/DD/YYYY")
    tags: string                   # Tag format (e.g., "backtick-wrapped, comma-separated")

  freshness:
    warning_days: number           # Days before doc is flagged as stale (e.g., 180)

# Tag system configuration
tags:
  tier_system:                     # List of tag tier prefixes
    - tier_prefix/                 # e.g., "category/", "audience/", "environment/"
    ...

  min_required:                    # Required tier prefixes (must have at least one tag from each)
    - tier_prefix/                 # e.g., "category/", "audience/"
    ...

  max_recommended: number          # Maximum recommended tag count (e.g., 5)

  reference_file: string           # Path to tag taxonomy file
                                   # e.g., "references/tag-taxonomy.md"
                                   # or "../skills/doc-standards/references/tag-taxonomy.md"

# Size management configuration
size:
  recommended: number              # Recommended line count (e.g., 500)
  warning: number                  # Warning threshold (e.g., 1000)
  hard_limit: number               # Must-split threshold (e.g., 2000)

  examples_file: string            # Path to project examples (optional)
                                   # e.g., "references/size-guidelines-examples.md"

# Quality validation configuration
quality:
  checklist_file: string           # Path to project examples (optional)
                                   # e.g., "references/quality-checklist-examples.md"

  mapping:
    enabled: boolean               # Use document mapping registry
    file: string                   # Path to mapping file (e.g., "references/document-mapping.md")

  links:
    validate: boolean              # Validate link integrity
    update_readme: boolean         # Auto-update navigation hub
    readme_path: string            # Path to hub (e.g., "docs/README.md")

  freshness:                       # Review frequency by doc type (in days)
    operations_docs: number        # e.g., 90
    reference_docs: number         # e.g., 180
    architecture_docs: number      # e.g., 365

# Integration with project systems
integration:
  rules_file: string               # Path to project documentation rules (optional)
                                   # e.g., ".claude/rules/documentation-rules.md"
  docs_hub: string                 # Path to docs navigation hub (optional)
                                   # e.g., "docs/README.md"

# Response formatting
response:
  language: "en" | "ja" | "es" | string  # Output language (ISO 639-1 code)
  format: "conversational" | "formal" | "technical"  # Response style
```

---

## Field Descriptions

### project

**project.name**: Project identifier used in prompts and messages

- Type: `string`
- Example: `"ASTA"`, `"MyProject"`, `"Acme Inc."`
- Required: Yes

**project.language**: Primary project language (affects field labels, response language)

- Type: `string` (ISO 639-1 language code)
- Example: `"en"` (English), `"ja"` (Japanese), `"es"` (Spanish)
- Default: `"en"`
- Required: No

---

### metadata

**metadata.required_fields**: List of required metadata fields in documentation

- Type: `array` of `string`
- Example: `["emoji_icon", "last_updated", "audience", "tags"]`
- Common values:
  - `emoji_icon` - Emoji in H1 title
  - `last_updated` - Last update date
  - `audience` - Target audience
  - `tags` - Tag list
  - Custom fields as needed
- Required: Yes

**metadata.formats.date**: Date format specification

- Type: `string`
- Example: `"YYYY-MM-DD"`, `"MM/DD/YYYY"`, `"DD.MM.YYYY"`
- Default: `"YYYY-MM-DD"`
- Required: No

**metadata.formats.tags**: Tag formatting specification

- Type: `string`
- Example: `"backtick-wrapped, comma-separated"`, `"square-bracket-wrapped, space-separated"`
- Default: `"backtick-wrapped, comma-separated"`
- Required: No

**metadata.freshness.warning_days**: Days before doc is flagged as stale

- Type: `number`
- Example: `180` (6 months), `90` (3 months)
- Default: `180`
- Required: No

---

### tags

**tags.tier_system**: List of tag tier prefixes defining the tag system

- Type: `array` of `string`
- Example: `["category/", "audience/", "environment/"]`
- Standard: `["category/", "audience/", "environment/"]`
- Can add custom tiers: `["category/", "audience/", "environment/", "priority/"]`
- Required: Yes

**tags.min_required**: Required tag tiers (must have at least one tag from each)

- Type: `array` of `string`
- Example: `["category/", "audience/"]`
- Common: Require category and audience, make environment optional
- Required: Yes

**tags.max_recommended**: Maximum recommended tag count

- Type: `number`
- Example: `5`, `3`, `7`
- Default: `5`
- Purpose: Prevent over-tagging
- Required: No

**tags.reference_file**: Path to tag taxonomy file

- Type: `string`
- Example:
  - `"references/tag-taxonomy.md"` (in `.claude/doc-standards/`)
  - `"../skills/doc-standards/references/tag-taxonomy.md"` (in `.claude/skills/doc-standards/`)
- Required: Yes
- **Note**: File must exist and define project's specific tag values

---

### size

**size.recommended**: Ideal target line count

- Type: `number`
- Example: `500`, `400`, `600`
- Purpose: Sweet spot for readability
- Required: Yes

**size.warning**: Warning threshold - consider splitting

- Type: `number`
- Example: `1000`, `800`, `1200`
- Purpose: Flag docs approaching size limits
- Required: Yes

**size.hard_limit**: Must-split threshold

- Type: `number`
- Example: `2000`, `1600`, `2400`
- Purpose: Hard limit requiring immediate split
- Required: Yes

**size.examples_file**: Path to project split examples (optional)

- Type: `string`
- Example: `"references/size-guidelines-examples.md"`
- Purpose: Provide project-specific split examples
- Required: No

---

### quality

**quality.checklist_file**: Path to project quality examples (optional)

- Type: `string`
- Example: `"references/quality-checklist-examples.md"`
- Purpose: Provide project-specific validation examples
- Required: No

**quality.mapping.enabled**: Enable document mapping registry

- Type: `boolean`
- Example: `true`, `false`
- Purpose: Maintain centralized document registry
- Default: `false`
- Required: No

**quality.mapping.file**: Path to document mapping file

- Type: `string`
- Example: `"references/document-mapping.md"`
- Required: Only if `mapping.enabled: true`

**quality.links.validate**: Enable link validation

- Type: `boolean`
- Example: `true`, `false`
- Purpose: Check for broken links
- Default: `true`
- Required: No

**quality.links.update_readme**: Auto-update navigation hub

- Type: `boolean`
- Example: `true`, `false`
- Purpose: Automatically update docs hub when adding new docs
- Default: `false`
- Required: No

**quality.links.readme_path**: Path to navigation hub

- Type: `string`
- Example: `"docs/README.md"`, `"README.md"`
- Required: Only if `links.update_readme: true`

**quality.freshness**: Review frequency by document type (in days)

- Type: `object` with numeric values
- Example:

  ```yaml
  freshness:
    operations_docs: 90
    reference_docs: 180
    architecture_docs: 365
  ```

- Purpose: Define review schedules per doc type
- Required: No

---

### integration

**integration.rules_file**: Path to project documentation rules

- Type: `string`
- Example: `".claude/rules/documentation-rules.md"`
- Purpose: Link to high-level project rules
- Required: No

**integration.docs_hub**: Path to docs navigation hub

- Type: `string`
- Example: `"docs/README.md"`, `"documentation/INDEX.md"`
- Purpose: Central navigation for all documentation
- Required: No

---

### response

**response.language**: Output language for skill responses

- Type: `string` (ISO 639-1 language code)
- Example: `"ja"` (Japanese), `"en"` (English), `"es"` (Spanish)
- Purpose: Localize skill responses to project language
- Default: `"en"`
- Required: No

**response.format**: Response style/formality

- Type: `"conversational"` | `"formal"` | `"technical"`
- Example: `"conversational"` (friendly), `"formal"` (professional), `"technical"` (concise)
- Purpose: Match project communication style
- Default: `"conversational"`
- Required: No

---

## Minimal Configuration Example

Absolute minimum configuration for getting started:

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

**Note**: You must also create `references/tag-taxonomy.md` defining your project's tag values.

---

## ASTA Configuration Example

Complete example from ASTA project:

```yaml
project:
  name: "ASTA"
  language: "ja"

metadata:
  required_fields:
    - emoji_icon
    - last_updated
    - audience
    - tags

  formats:
    date: "YYYY-MM-DD"
    tags: "backtick-wrapped, comma-separated"

  freshness:
    warning_days: 180

tags:
  tier_system:
    - category/
    - audience/
    - environment/

  min_required:
    - category/
    - audience/

  max_recommended: 5

  reference_file: "../skills/doc-standards/references/tag-taxonomy.md"

size:
  recommended: 500
  warning: 1000
  hard_limit: 2000

  examples_file: "../skills/doc-standards/references/size-guidelines-examples.md"

quality:
  checklist_file: "../skills/doc-standards/references/quality-checklist-examples.md"

  mapping:
    enabled: true
    file: "../skills/doc-standards/references/document-mapping.md"

  links:
    validate: true
    update_readme: true
    readme_path: "docs/README.md"

  freshness:
    operations_docs: 90
    reference_docs: 180
    architecture_docs: 365

integration:
  rules_file: ".claude/rules/documentation-rules.md"
  docs_hub: "docs/README.md"

response:
  language: "ja"
  format: "conversational"
```

---

## Medium Configuration Example

Typical configuration for most projects:

```yaml
project:
  name: "MyProject"
  language: "en"

metadata:
  required_fields:
    - last_updated
    - audience
    - tags

  formats:
    date: "YYYY-MM-DD"

tags:
  tier_system:
    - category/
    - audience/
    - environment/

  min_required:
    - category/
    - audience/

  max_recommended: 5

  reference_file: "references/tag-taxonomy.md"

size:
  recommended: 500
  warning: 1000
  hard_limit: 2000

quality:
  links:
    validate: true
    update_readme: true
    readme_path: "docs/README.md"

response:
  language: "en"
  format: "conversational"
```

---

## Validation Rules

### Required Fields

- `project.name` - Must be defined
- `metadata.required_fields` - Must have at least one field
- `tags.tier_system` - Must define at least `category/` and `audience/`
- `tags.min_required` - Must match tiers in `tier_system`
- `tags.reference_file` - Must point to existing file
- `size.recommended`, `size.warning`, `size.hard_limit` - All three required

### Constraints

- `size.recommended < size.warning < size.hard_limit`
- `tags.max_recommended >= len(tags.min_required)`
- `metadata.formats.date` must be valid date pattern
- Language codes should be ISO 639-1

### File Paths

- All paths are relative to `.claude/doc-standards/` directory
- Use `../skills/` to reference project skill directory
- Use `../../` to reference project root

---

## Setup Instructions

### Step 1: Create Directory

```bash
mkdir -p .claude/doc-standards/references
```

### Step 2: Create config.yaml

Choose configuration level (minimal/medium/complete) and create file:

```bash
touch .claude/doc-standards/config.yaml
# Edit file with your configuration
```

### Step 3: Create Tag Taxonomy

**Required**: Create `references/tag-taxonomy.md` with your project's tag values:

```bash
touch .claude/doc-standards/references/tag-taxonomy.md
```

Example content:

```markdown
# Tag Taxonomy

## Category Tags (Tier 1)

- category/guide - Step-by-step procedures
- category/reference - API docs, schemas
  ...

## Audience Tags (Tier 2)

- audience/developer - Development team
- audience/operations - Operations team
  ...

## Environment Tags (Tier 3)

- environment/development - Local development
- environment/staging - Staging environment
- environment/production - Production environment
  ...
```

### Step 4: (Optional) Add Examples

Create optional example files:

```bash
touch .claude/doc-standards/references/size-guidelines-examples.md
touch .claude/doc-standards/references/quality-checklist-examples.md
```

### Step 5: Verify Discovery

The skill will automatically discover your configuration.

Test by creating a new document or asking the skill about documentation standards.

---

## Troubleshooting

### Config Not Found

**Symptom**: Skill uses default English responses, can't find project tags

**Solution**:

- Verify config file exists at `.claude/doc-standards/config.yaml`
- Check file permissions (must be readable)
- Verify YAML syntax (use YAML validator)

### Tag Taxonomy Not Loaded

**Symptom**: Skill can't suggest project tags

**Solution**:

- Verify `tags.reference_file` path is correct
- Check that taxonomy file exists and is readable
- Ensure file contains valid markdown with tag definitions

### Invalid Configuration

**Symptom**: Skill errors when loading config

**Solution**:

- Validate YAML syntax
- Check all required fields are present
- Verify constraint rules (e.g., size thresholds in order)
- Check file paths are correct

---

## Migration from Project Skill to Global + Config

If migrating from a project-specific skill to global skill + config:

1. Extract project-specific values from old SKILL.md
2. Create `.claude/doc-standards/config.yaml` with those values
3. Move tag taxonomy to config location
4. Update path references
5. Test configuration discovery
6. Archive old skill file (or convert to lightweight override)

See migration documentation for details.
