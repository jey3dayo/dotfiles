---
name: doc-standards
description: |
  [What] >-
  [When] Use when: doc-standards を使う時
  [Keywords] doc standards
  Generic documentation standards framework. Validates metadata templates,
  tag tier systems, size management guidelines, and quality checks.
  Automatically discovers project-specific configuration in .claude/doc-standards/.
  Adapts response language based on project configuration (default: English).
  Triggers when users mention "document", "documentation", "metadata", "tags",
  work with docs/ directory, create .md files, or need documentation standards guidance.
---

# Documentation Standards Framework

## Overview

Enforce documentation standards through automated metadata validation, tag system guidance, size management, and quality checks. **Project-agnostic framework** that adapts to project-specific configuration.

**Core Capabilities**:

- Metadata template application and validation
- Tag tier system guidance (category/audience/environment)
- Document size management with split strategies
- Quality checklist validation

**Configuration Discovery**:

1. Load generic framework from `~/.claude/skills/doc-standards/`
2. Check for project config at `.claude/doc-standards/config.yaml`
3. If found: Load project-specific tags, examples, language preference
4. If not found: Use minimal defaults and prompt user to create config

---

## Configuration Discovery

### Step 1: Load Global Framework

The skill loads generic framework components from:

```
~/.claude/skills/doc-standards/references/
  metadata-template-framework.md
  tag-system-framework.md
  size-guidelines-framework.md
  quality-checklist-framework.md
  config-schema.md
```

### Step 2: Detect Project Config

Check for project configuration:

```
.claude/doc-standards/config.yaml
```

**If found**: Load project settings (language, tag taxonomy, size thresholds, etc.)
**If not found**: Use minimal defaults and provide setup guidance

### Step 3: Load Project References

If project config exists, load project-specific references:

```
.claude/doc-standards/references/
  tag-taxonomy.md          (REQUIRED - defines project tags)
  document-mapping.md      (OPTIONAL - document registry)
  size-guidelines-examples.md  (OPTIONAL - project split examples)
  quality-checklist-examples.md (OPTIONAL - project validation examples)
```

Or, if project uses skill-level references (legacy pattern):

```
.claude/skills/doc-standards/references/
  tag-taxonomy.md
  document-mapping.md
  size-guidelines-examples.md
  quality-checklist-examples.md
```

The skill will check both locations and use whichever is found.

---

## Core Capabilities

### 1. Metadata Template Application

Apply standardized metadata format to documentation.

**What it does**:

- Generate metadata header with required fields
- Ensure correct date format (project-configured or YYYY-MM-DD default)
- Suggest appropriate tags based on content
- Validate field completeness

**When to use**:

- Creating new .md files
- Adding metadata to existing documentation
- Updating outdated metadata format

**How it works**:

1. Load `references/metadata-template-framework.md` for structure
2. Load project config for field names and formats
3. Generate metadata header with pre-filled values
4. Guide user through tag selection
5. Validate completeness and format

### 2. Tag System Guidance

Guide appropriate tag selection from project's tag taxonomy.

**What it does**:

- Support 3-tier tag systems: `category/`, `audience/`, `environment/`
- Validate canonical format (prefix/value)
- Check tag combinations
- Load project-specific tag values

**When to use**:

- Selecting tags for new documentation
- Updating tags for existing docs
- Understanding project tag system

**How it works**:

1. Load `references/tag-system-framework.md` for tier architecture
2. Load project's `tag-taxonomy.md` for specific values
3. Analyze document content and purpose
4. Recommend tags based on:
   - Document topic → category tags
   - Target readers → audience tags
   - Deployment scope → environment tags
5. Validate against canonical format

### 3. Size Management

Monitor document size and suggest splits when necessary.

**What it does**:

- Track line counts during creation
- Warn when approaching size thresholds
- Suggest split strategies for large docs
- Provide decision tree for split decisions

**When to use**:

- Document exceeds recommended size (default: 500 lines)
- Document contains multiple distinct topics
- Mixing beginner and advanced content
- Targeting multiple audiences

**How it works**:

1. Monitor current line count
2. Apply size thresholds from project config (or defaults: 500/1000/2000)
3. Load `references/size-guidelines-framework.md` for decision tree
4. Suggest split strategy:
   - **Topic-based split**: Unrelated content
   - **Role-based split**: Multiple audiences
   - **Level-based split**: Beginner/advanced mix
   - **Phase-based split**: Lifecycle phases (setup/operations/troubleshooting)
5. Load project examples if available

### 4. Quality Validation

Validate documentation against quality standards.

**What it does**:

- Metadata quality checks
- Content quality checks
- Link validation
- Navigation checks

**When to use**:

- Final validation before committing
- Reviewing existing documentation
- Conducting periodic reviews
- Checking link validity

**How it works**:

1. Load `references/quality-checklist-framework.md` for framework
2. Load project examples if available
3. Validate metadata completeness
4. Check content structure
5. Verify link functionality
6. Provide improvement suggestions

---

## 詳細リファレンス

- タグ体系/出力フォーマット/ベストプラクティスは `references/doc-standards-details.md` を参照

## 次のステップ

1. 設定ファイルを確認
2. 対象ドキュメントでメタデータ検証
3. 不足項目を補完

## 関連リソース

- `references/doc-standards-details.md`
