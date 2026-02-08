---
description: Initialize a new specification with detailed project description
allowed-tools: Bash, Read, Write, Glob
argument-hint: <project-description>
---

# Spec Initialization

## Background Information

- **Mission**: Initialize the first phase of spec-driven development by creating directory structure and metadata for a new specification
- **Success Criteria**:
  - Generate appropriate feature name from project description
  - Create unique spec structure without conflicts
  - Provide clear path to next phase (requirements generation)
  - Support configurable directory structure via `.kiro-config.json`

## Instructions

## Step 1: Load Configuration

1. Use **Read** to load `.kiro-config.json` from current working directory
   - If not found, use built-in default configuration
   - Parse JSON and validate structure

2. Resolve all paths relative to current working directory:

   ```
   KIRO_ROOT = ${CWD}/${config.paths.root}
   KIRO_SPECS = ${KIRO_ROOT}/${config.paths.specs}
   KIRO_SETTINGS = ${KIRO_ROOT}/${config.paths.settings}
   KIRO_TEMPLATES = ${KIRO_SETTINGS}/${config.paths.templates}

   TEMPLATE_INIT_JSON = ${KIRO_TEMPLATES}/${config.templates.specs.init}
   TEMPLATE_REQ_INIT_MD = ${KIRO_TEMPLATES}/${config.templates.specs.requirementsInit}
   ```

3. Validate required directories exist:
   - If `KIRO_ROOT` missing, report error: "Kiro root directory not found at ${KIRO_ROOT}. Run setup first."
   - If `KIRO_TEMPLATES` missing, report error with specific path

## Step 2: Generate Feature Name and Check Uniqueness

1. Generate feature name from project description ($ARGUMENTS):
   - Convert to kebab-case
   - Keep 2-4 words maximum
   - Make descriptive and unique

2. Use **Glob** to check existing spec directories:
   - Pattern: `${KIRO_SPECS}/*/`
   - If feature name exists, append numeric suffix: `feature-name-2`, `feature-name-3`, etc.

## Step 3: Create Directory Structure

1. Use **Bash** to create spec directory:

   ```bash
   mkdir -p "${KIRO_SPECS}/${FEATURE_NAME}"
   ```

## Step 4: Initialize Files Using Templates

1. Use **Read** to fetch templates:
   - `${TEMPLATE_INIT_JSON}` → spec.json template
   - `${TEMPLATE_REQ_INIT_MD}` → requirements.md template

2. Replace placeholders in templates:
   - `{{FEATURE_NAME}}` → generated feature name
   - `{{TIMESTAMP}}` → current ISO 8601 timestamp
   - `{{PROJECT_DESCRIPTION}}` → $ARGUMENTS
   - `{{LANGUAGE}}` → config.workflow.defaultLanguage

3. Use **Write** to create files:
   - `${KIRO_SPECS}/${FEATURE_NAME}/spec.json`
   - `${KIRO_SPECS}/${FEATURE_NAME}/requirements.md`

## Important Constraints

- DO NOT generate requirements/design/tasks at this stage
- Follow stage-by-stage development principles
- Maintain strict phase separation
- Only initialization is performed in this phase
- Use configured paths, not hardcoded `.kiro/`

## Tool Guidance

- Use **Read** to load configuration and templates
- Use **Glob** to check existing spec directories for name uniqueness
- Use **Bash** to create directories
- Use **Write** to create spec.json and requirements.md after placeholder replacement
- Perform validation before any file write operation

## Output Description

Provide output in the language specified in config (default: `ja`) with the following structure:

1. **Configuration Used**: Brief mention if using custom or default config
2. **Generated Feature Name**: `feature-name` format with 1-2 sentence rationale
3. **Project Summary**: Brief summary (1 sentence)
4. **Created Files**: Bullet list with full paths (use resolved paths, not variables)
5. **Next Step**: Command block showing `/kiro:spec-requirements <feature-name>`
6. **Notes**: Explain why only initialization was performed (2-3 sentences on phase separation)

**Format Requirements**:

- Use Markdown headings (##, ###)
- Wrap commands in code blocks
- Keep total output concise (under 300 words)
- Use clear, professional language per config language setting

## Safety & Fallback

- **Missing Config**: If `.kiro-config.json` not found, use default configuration and notify user
- **Invalid Config**: If config is malformed, fall back to defaults and report validation errors
- **Ambiguous Feature Name**: If feature name generation is unclear, propose 2-3 options and ask user to select
- **Template Missing**: If template files don't exist at configured paths, report error with specific missing file path and suggest running setup
- **Directory Conflict**: If feature name already exists, append numeric suffix (e.g., `feature-name-2`) and notify user of automatic conflict resolution
- **Write Failure**: Report error with specific path and suggest checking permissions or disk space

## Configuration Example

When using custom configuration, mention it in output:

```markdown
## Configuration

Using custom configuration from `.kiro-config.json`:

- Specs directory: `docs/features/`
- Templates: `docs/config/templates/`
```

Or if using defaults:

```markdown
## Configuration

Using default configuration (`.kiro/` structure).
To customize, create `.kiro-config.json` in project root.
```
