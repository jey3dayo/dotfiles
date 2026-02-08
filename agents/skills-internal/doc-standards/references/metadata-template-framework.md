# Metadata Template Framework

Generic metadata structure applicable to any documentation system.

---

## Overview

**Purpose**: Define standardized metadata header format for documentation.

**When to use**:

- Creating new documentation
- Updating existing documentation headers
- Validating metadata completeness
- Checking format compliance

---

## Standard Metadata Format

All documentation should include metadata in this format (field labels configurable per project):

```markdown
# [Icon] [Document Title]

**Last Updated**: YYYY-MM-DD
**Audience**: [Target audience]
**Tags**: `category/value`, `audience/value`, `environment/value`

## Overview

[Brief description of document purpose]
```

**Configurability**:

- Field labels can be customized per project (e.g., "最終更新" vs "Last Updated")
- Date format configurable (default: YYYY-MM-DD)
- Tag format configurable (default: backtick-wrapped, comma-separated)

---

## Required Fields Pattern

### Field 1: Icon Header

**Format**: `# [Emoji] [Title]`

**Purpose**: Visual identification and document type indication

**Common Icon Categories**:

- **General**: 📄 📝 📋
- **Deployment/Operations**: 🚀 🔧 ⚙️
- **Infrastructure**: 🏗️ 🌐 ☁️
- **Security**: 🔐 🔒 🛡️
- **Monitoring**: 📊 📈 📉
- **Testing/Quality**: 🧪 ✅ 🔍
- **Reference**: 📚 📖 📘
- **Tutorial/Guide**: 🎓 🚩 🗺️

**Validation**: Must start with `#` followed by single emoji and title

---

### Field 2: Last Updated

**Format**: `**Last Updated**: YYYY-MM-DD` (or project-configured label)

**Purpose**: Track document freshness and maintenance status

**Rules**:

- Must use ISO 8601 date format (YYYY-MM-DD) by default
- Should be updated on every significant edit
- Used for review scheduling
- Can trigger stale warnings (e.g., 6+ months old)

**Validation**: Date must be valid and in correct format

**Configuration Options**:

```yaml
metadata:
  formats:
    date: "YYYY-MM-DD" # or "MM/DD/YYYY", "DD.MM.YYYY", etc.
  freshness:
    warning_days: 180 # Flag docs older than N days
```

---

### Field 3: Target Audience

**Format**: `**Audience**: [Audience description]` (or project-configured label)

**Purpose**: Identify intended readers for the document

**Generic Audience Types** (customize per project):

- Developer
- Operations
- DevOps/SRE
- Security
- Architect
- Manager
- End User

**Rules**:

- Should match at least one audience tag in Tags field
- Multiple audiences allowed (comma-separated)
- Should align with document content and complexity

**Validation**: Audience should correspond to `audience/*` tags

---

### Field 4: Tags

**Format**: `**Tags**:`category/value`,`audience/value`,`environment/value`` (or project-configured label)

**Purpose**: Enable document discovery and categorization

**Tag Structure** (3-tier system - see `tag-system-framework.md`):

- **Category tags** (`category/`): Primary topic classification
- **Audience tags** (`audience/`): Target reader identification
- **Environment tags** (`environment/`): Deployment scope (optional)

**Rules**:

- Must use canonical format with prefixes
- At least one `category/` tag required (or per project config)
- At least one `audience/` tag required (or per project config)
- `environment/` tags optional (use only for env-specific docs)
- Maximum tags configurable (default: 5 tags recommended)
- Tags must be comma-separated with backticks (or project-configured format)

**Validation**:

- All tags must use canonical format (`prefix/value`)
- Tags must exist in project tag taxonomy
- Required tag tiers must be present

---

## Document Type Templates

### Type 1: Guide/Tutorial

**Purpose**: Step-by-step procedures, how-to guides, tutorials

**Example**:

```markdown
# 🎓 [Feature] Implementation Guide

**Last Updated**: YYYY-MM-DD
**Audience**: Developer
**Tags**: `category/guide`, `audience/developer`

## Overview

This guide explains how to implement [feature]...
```

**Characteristics**:

- Icon: 🎓 (tutorial) or 📘 (guide)
- Audience: Usually single role
- Tags: Include `category/guide` or topic-specific category
- Content: Step-by-step procedures with examples

---

### Type 2: Reference Documentation

**Purpose**: API references, command references, data schemas

**Example**:

```markdown
# 📚 [System] Reference

**Last Updated**: YYYY-MM-DD
**Audience**: Developer, Operations
**Tags**: `category/reference`, `audience/developer`, `audience/operations`

## Overview

Complete reference of [system/API/commands]...
```

**Characteristics**:

- Icon: 📚 (reference) or 📖 (documentation)
- Audience: Multiple audiences common
- Tags: Topic-specific category
- Content: Comprehensive reference information

---

### Type 3: Operations/Runbook

**Purpose**: Operational procedures, runbooks, troubleshooting

**Example**:

```markdown
# 🔧 [System] Operations Guide

**Last Updated**: YYYY-MM-DD
**Audience**: Operations, SRE
**Tags**: `category/operations`, `audience/operations`, `audience/sre`, `environment/production`

## Overview

Procedures for operating [system]...
```

**Characteristics**:

- Icon: 🔧 (operations) or 🚀 (deployment)
- Audience: Multiple roles common
- Tags: Multiple categories possible (`category/operations`, `category/[topic]`)
- Environment: Specific environments often specified
- Content: Procedures, commands, troubleshooting steps

---

## Validation Checklist

Use this checklist when creating or updating documentation:

**Format Validation**:

- [ ] Icon present in H1 title
- [ ] Last Updated field present with correct date format
- [ ] Audience field present
- [ ] Tags field present with proper formatting
- [ ] All tags use canonical format (`prefix/value`)

**Content Validation**:

- [ ] At least one `category/` tag (or project-required tiers)
- [ ] At least one `audience/` tag (or project-required tiers)
- [ ] Audience field matches audience tags
- [ ] Environment tags used only for env-specific docs
- [ ] Tag count within project limits

**Consistency Validation**:

- [ ] Document content matches selected tags
- [ ] Tags consistent with similar documents
- [ ] Icon appropriate for document type
- [ ] Date is current (updated on every edit)

**Structure Validation**:

- [ ] Overview section present
- [ ] Brief description explains document purpose
- [ ] Document structure follows project conventions

---

## Common Mistakes

**Avoid**:

- ❌ Using tags without prefixes: `AWS`, `developer`, `staging`
- ❌ Missing required fields
- ❌ Invalid date format
- ❌ Over-tagging (exceeding project limits)
- ❌ Generic-only tags without specific categories
- ❌ Mismatched audience: Audience field doesn't match audience tags

**Correct Example**:

```markdown
# ✅ Good Example

# 📄 System Architecture Guide

**Last Updated**: 2025-12-22
**Audience**: Developer, Architect
**Tags**: `category/guide`, `category/architecture`, `audience/developer`, `audience/architect`
```

**Incorrect Example**:

```markdown
# ❌ Bad Example (no icon, invalid date, wrong tag format)

# System Architecture Guide

**Last Updated**: 12/22/2025
**Audience**: Developer
**Tags**: guide, architecture, developer
```

---

## Configuration Integration

Projects configure metadata format in `.claude/doc-standards/config.yaml`:

```yaml
metadata:
  required_fields:
    - emoji_icon # In H1 title
    - last_updated # Or project-specific label
    - audience # Or project-specific label
    - tags # Or project-specific label

  formats:
    date: "YYYY-MM-DD"
    tags: "backtick-wrapped, comma-separated"

  freshness:
    warning_days: 180 # Days before stale warning
```

---

## Integration with Other Frameworks

- **Tag selection**: Use `tag-system-framework.md` for tag structure and validation
- **Size management**: Use `size-guidelines-framework.md` when document exceeds thresholds
- **Quality checks**: Use `quality-checklist-framework.md` for final validation

---

## Project-Specific Customization

Projects can customize:

1. **Field Labels**: Use native language labels (e.g., "最終更新" for Japanese)
2. **Date Formats**: Use regional date formats
3. **Icon Conventions**: Define project-specific icon meanings
4. **Tag Formatting**: Adjust separator and wrapper characters
5. **Required Fields**: Add or remove fields per project needs

See project's `.claude/doc-standards/config.yaml` for active configuration.
