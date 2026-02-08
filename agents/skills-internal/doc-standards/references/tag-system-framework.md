# Tag System Framework

Generic 3-tier tag system architecture for documentation classification.

---

## Overview

This framework defines a flexible 3-tier tag system that projects can customize with their own tag values.

**3-Tier System**:

```
`category/value`, `audience/value`, `environment/value`
```

**Format Rules**:

- Always use prefix (`category/`, `audience/`, `environment/`)
- Lowercase values after prefix
- Comma-separated in metadata (or project-configured separator)
- Multiple tags per tier allowed
- Wrapped in backticks (or project-configured wrapper)

---

## Tier Architecture

### Tier 1: Category Tags (prefix: `category/`)

**Purpose**: Primary topic classification

**Required**: YES (minimum 1 tag, or per project config)

**Examples** (projects define their own values):

- `category/guide` - Step-by-step procedures
- `category/reference` - API docs, schemas
- `category/operations` - Runbooks, troubleshooting
- `category/infrastructure` - Infrastructure management
- `category/deployment` - Deployment procedures
- `category/testing` - Testing strategies
- `category/security` - Security procedures
- `category/monitoring` - Monitoring setup

**Usage**:

- Select based on document's primary topic
- Multiple categories allowed for cross-cutting docs
- Projects typically define 10-20 category values

---

### Tier 2: Audience Tags (prefix: `audience/`)

**Purpose**: Target reader identification

**Required**: YES (minimum 1 tag, or per project config)

**Generic Audience Types** (projects customize):

- `audience/developer` - Development team
- `audience/operations` - Operations team
- `audience/devops` - DevOps/SRE team
- `audience/sre` - Site Reliability Engineering
- `audience/security` - Security team
- `audience/architect` - Solution architects
- `audience/manager` - Technical managers
- `audience/all` - All technical staff

**Usage**:

- Select based on intended readers
- Multiple audiences allowed
- Projects typically define 4-8 audience values

---

### Tier 3: Environment Tags (prefix: `environment/`)

**Purpose**: Deployment scope specification

**Required**: NO (use only for environment-specific docs)

**Common Environment Types**:

- `environment/development` - Local development
- `environment/staging` - Staging environment
- `environment/production` - Production environment
- `environment/testing` - Test environments
- `environment/sandbox` - Sandbox/experimental

**Usage**:

- Omit for docs applicable to all environments
- Use only for environment-specific procedures
- Projects typically define 3-5 environment values

---

## Canonical Format Rules

### Rule 1: Prefix Requirement

All tags MUST use tier prefix:

```markdown
✅ Correct: `category/guide`, `audience/developer`, `environment/staging`
❌ Wrong: `guide`, `developer`, `staging`
```

**Validation Pattern**: `^[a-z]+\/[a-z-]+$`

---

### Rule 2: Lowercase Values

Values after prefix MUST be lowercase:

```markdown
✅ Correct: `category/api-reference`, `audience/operations`
❌ Wrong: `category/API-Reference`, `audience/Operations`
```

---

### Rule 3: Separator and Wrapper

Tags MUST be formatted per project config (default: comma-separated, backtick-wrapped):

```markdown
✅ Correct: `category/guide`, `audience/developer`
❌ Wrong: category/guide, audience/developer (missing backticks)
❌ Wrong: `category/guide` `audience/developer` (missing separator)
```

**Configuration**:

```yaml
metadata:
  formats:
    tags: "backtick-wrapped, comma-separated" # Default
    # Or: "square-bracket-wrapped, space-separated"
```

---

## Tag Validation Logic

### Validation Steps

```
1. Check prefix format
   → All tags must match: ^[a-z]+\/[a-z-]+$

2. Check required tiers
   → Must have at least one category/ tag
   → Must have at least one audience/ tag
   → (Or per project config)

3. Validate against project taxonomy
   → Load project's tag-taxonomy.md
   → Verify all tags exist in taxonomy
   → Warn for unknown tags

4. Check max count
   → Verify tag count ≤ project's max_recommended
   → (Default: 5 tags)
```

### Python-style Validation

```python
def validate_tags(tags, project_taxonomy, project_config):
    """Validate tags against project taxonomy and rules."""

    # 1. Check prefix format
    for tag in tags:
        if not matches_pattern(tag, r'^[a-z]+\/[a-z-]+$'):
            raise InvalidTagFormat(tag, "Must use 'prefix/lowercase-value' format")

    # 2. Check required tiers
    required_tiers = project_config.tags.min_required  # e.g., ['category/', 'audience/']
    for tier in required_tiers:
        if not has_prefix(tags, tier):
            raise MissingRequiredTier(tier)

    # 3. Validate against project taxonomy
    valid_tags = load_project_taxonomy()  # From tag-taxonomy.md
    for tag in tags:
        if tag not in valid_tags:
            warn(f"Unknown tag: {tag}. Check tag-taxonomy.md")

    # 4. Check max count
    max_tags = project_config.tags.max_recommended  # e.g., 5
    if len(tags) > max_tags:
        warn(f"Too many tags: {len(tags)}. Recommended max: {max_tags}")

    return True
```

---

## Tag Selection Guidelines

### Selecting Category Tags

1. **Identify primary topic**:
   - What is the document primarily about?
   - What is the main category?

2. **Consider cross-cutting concerns**:
   - Does the doc cover multiple topics?
   - Use multiple category tags if applicable

3. **Reference project taxonomy**:
   - Load project's `tag-taxonomy.md`
   - Select from available category values

4. **Avoid over-categorization**:
   - Limit to 2-3 category tags maximum
   - Focus on most relevant categories

---

### Selecting Audience Tags

1. **Identify target readers**:
   - Who will read this document?
   - What roles/teams are involved?

2. **Consider skill level**:
   - Developer-focused content → `audience/developer`
   - Operations procedures → `audience/operations`
   - Cross-team → Multiple audience tags

3. **Match audience field**:
   - Audience tags should match "Audience" metadata field
   - Ensure consistency

---

### Selecting Environment Tags

1. **Check environment specificity**:
   - Is doc environment-specific? → Add environment tag
   - Applies to all environments? → Omit environment tags

2. **Use specific environments**:
   - Production-only → `environment/production`
   - Staging procedures → `environment/staging`
   - Local development → `environment/development`

3. **Multiple environments**:
   - If doc applies to multiple specific environments, include all
   - Example: `environment/staging`, `environment/production`

---

## Tag Combination Patterns

### Pattern 1: Single Topic, Single Audience

**Use case**: Focused guide for one role

```markdown
**Tags**: `category/testing`, `audience/developer`
```

---

### Pattern 2: Single Topic, Multiple Audiences

**Use case**: Procedures involving multiple teams

```markdown
**Tags**: `category/deployment`, `audience/developer`, `audience/operations`
```

---

### Pattern 3: Multiple Topics, Single Audience

**Use case**: Comprehensive guide covering related topics

```markdown
**Tags**: `category/infrastructure`, `category/security`, `audience/devops`
```

---

### Pattern 4: Environment-Specific Operations

**Use case**: Environment-specific procedures

```markdown
**Tags**: `category/operations`, `audience/operations`, `environment/production`
```

---

### Pattern 5: Cross-Cutting Documentation

**Use case**: Meta-documentation, standards, policies

```markdown
**Tags**: `category/documentation`, `category/standards`, `audience/all`
```

---

## Project Configuration

### Tag Tier System Configuration

Projects configure tag system in `.claude/doc-standards/config.yaml`:

```yaml
tags:
  tier_system:
    - category/ # Tier 1: Topic classification
    - audience/ # Tier 2: Reader identification
    - environment/ # Tier 3: Deployment scope (optional)

  min_required:
    - category/ # Must have at least one category tag
    - audience/ # Must have at least one audience tag

  max_recommended: 5 # Warn if exceeding this count

  reference_file: "references/tag-taxonomy.md" # Path to project taxonomy
```

---

## Project Tag Taxonomy

Projects define specific tag values in `.claude/doc-standards/references/tag-taxonomy.md` (or `.claude/skills/doc-standards/references/tag-taxonomy.md`):

```markdown
# Tag Taxonomy

## Category Tags (Tier 1)

- category/guide - Step-by-step procedures
- category/reference - API docs, schemas
- category/operations - Runbooks, troubleshooting
- category/deployment - Deployment procedures
- category/infrastructure - Infrastructure management
- category/testing - Testing strategies
- category/security - Security procedures
- category/monitoring - Monitoring setup
  ...

## Audience Tags (Tier 2)

- audience/developer - Development team
- audience/operations - Operations team
- audience/devops - DevOps/SRE team
- audience/security - Security team
  ...

## Environment Tags (Tier 3)

- environment/development - Local development
- environment/staging - Staging environment
- environment/production - Production environment
  ...
```

---

## Integration with Other Frameworks

- **Metadata template**: Use `metadata-template-framework.md` for tag field format
- **Size management**: Tags help identify split strategies (e.g., split by audience)
- **Quality checks**: Validate tag format and taxonomy compliance

---

## Best Practices

### Do

- ✅ Use canonical format with prefixes
- ✅ Reference project taxonomy when selecting
- ✅ Match audience tags with audience field
- ✅ Use environment tags only when environment-specific
- ✅ Combine tags meaningfully (2-5 tags total)

### Don't

- ❌ Use tags without prefixes
- ❌ Mix old and new formats
- ❌ Over-tag (>5 tags typically excessive)
- ❌ Use generic-only tags without specific categories
- ❌ Create new tag values without updating taxonomy

---

## Common Mistakes

### Mistake 1: Missing Prefixes

```markdown
❌ Wrong: `guide`, `developer`, `staging`
✅ Correct: `category/guide`, `audience/developer`, `environment/staging`
```

### Mistake 2: Uppercase Values

```markdown
❌ Wrong: `category/API-Reference`, `audience/Developer`
✅ Correct: `category/api-reference`, `audience/developer`
```

### Mistake 3: Over-Tagging

```markdown
❌ Wrong: 8 tags covering every possible aspect
✅ Correct: 3-5 most relevant tags
```

### Mistake 4: Generic-Only Tags

```markdown
❌ Wrong: Only `category/documentation`
✅ Correct: `category/documentation`, `category/infrastructure`, `audience/devops`
```

### Mistake 5: Environment Tags for Generic Docs

```markdown
❌ Wrong: `environment/development` for doc applicable everywhere
✅ Correct: Omit environment tags for generic documentation
```

---

## Extending the System

### Adding New Tiers

Projects can add custom tiers beyond the standard 3:

```yaml
tags:
  tier_system:
    - category/
    - audience/
    - environment/
    - priority/ # Custom tier: priority/high, priority/low
    - status/ # Custom tier: status/draft, status/reviewed
```

### Custom Tier Examples

- `priority/high`, `priority/medium`, `priority/low` - Document importance
- `status/draft`, `status/reviewed`, `status/approved` - Review status
- `difficulty/beginner`, `difficulty/advanced` - Skill level
- `type/guide`, `type/reference`, `type/runbook` - Document type

**Note**: Standard 3-tier system covers most needs; add custom tiers only when necessary.
