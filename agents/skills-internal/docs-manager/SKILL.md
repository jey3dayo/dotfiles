---
name: docs-manager
description: |
  [What] Validate and manage documentation. Check metadata (date, audience, tags), verify tag system compliance, enforce size guidelines, validate links, and apply project-specific rules via configuration
  [When] Use when: reviewing documentation quality, creating new docs, working with documentation directories, or .md files (README.md, CONTRIBUTING.md, CHANGELOG.md)
  [Keywords] docs manager, validate, manage, documentation, docs, directories
---

# Docs Manager - Documentation Quality & Management

## Overview

Provide comprehensive documentation validation and management for projects with documentation directories. Validate structure, metadata, tag systems, and enforce project-specific rules while integrating with existing quality tools.

All paths and project-specific rules are configurable via `.docs-manager-config.json` file placed in the project root.

## Core Capabilities

### 1. Configuration System

**Configuration File**: `.docs-manager-config.json` in project root

**Configuration Loading**:

1. Check for `.docs-manager-config.json` in project root
2. If not found, use default generic configuration
3. Load project type from configuration
4. Apply project-specific rules from configuration

**Default Behavior**:

- Documentation root: `./docs`
- Project type: `generic`
- Required tags: `category/`, `audience/`
- Tag separator: `,` (comma-space)

**Configuration Options**:

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

See `templates/docs-manager-config.template.json` for complete schema and `examples/` for sample configurations.

### 2. Metadata Validation

Verify required metadata presence and format.

**Required Fields** (configurable via `metadata_format`):

- Date field (default: `**最終更新**: YYYY-MM-DD`)
- Audience field (default: `**対象**: [Target Audience]`)
- Tags field (default: `**タグ**: [tags]`)

**Validation Process**:

1. Parse metadata block from document header
2. Check all required fields present
3. Validate date format (configurable, default: YYYY-MM-DD)
4. Flag documents not updated in 6+ months
5. Verify audience specification clarity

**Configurable Options**:

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

### 3. Tag System Compliance

Validate tags against project-specific requirements.

**Tag Validation**:

1. Load required/optional tags from configuration
2. Check tag separator format (comma vs. space)
3. Verify all required tag prefixes present
4. Validate tag values against vocabulary (if configured)
5. Flag unknown or misspelled tags

**Configurable Tag Vocabulary**:

```json
{
  "tag_vocabulary": {
    "category/": ["documentation", "guide", "api"],
    "audience/": ["developer", "user"]
  }
}
```

**Reference**: Load tag vocabulary from configuration or provide defaults for detected project type.

### 4. Document Size Management

Monitor and enforce size guidelines.

**Size Thresholds** (configurable via `size_limits`):

- ✅ Ideal: ≤ configured ideal size (default: 300 lines)
- ⚠️ Acceptable: ≤ configured acceptable size (default: 500 lines)
- ⚠️ Large: ≤ configured warning size (default: 1000 lines)
- 🚫 Too Large: > configured maximum size (default: 2000 lines)

**Size Check**:

1. Count total lines in document
2. Classify by configured size category
3. Calculate section sizes
4. Suggest split points for large docs
5. Recommend separation strategy

### 5. Link Validation

Verify internal and external links work correctly.

**Link Types**:

- Internal file references: `[text](./other-doc.md)`
- Section anchors: `[text](#section-heading)`
- External URLs: `[text](https://example.com)`
- Image paths: `![alt](./images/pic.png)`

**Validation**:

1. Extract all markdown links
2. Check internal file references exist (relative to `docs_root`)
3. Verify section anchors valid
4. Test external URLs (with rate limiting)
5. Validate image paths
6. Report broken references

**Tool Integration** (configurable via `link_validation`):

```bash
# Use configured link checker tool
markdown-link-check docs/**/*.md --config .markdown-link-check.json
```

Configuration:

```json
{
  "link_validation": {
    "enabled": true,
    "config_file": ".markdown-link-check.json"
  }
}
```

### 6. Project-Specific Rules

Apply rules based on configuration.

**Detection Patterns**:

Use `custom_rules.detection_patterns` to identify project characteristics:

```json
{
  "custom_rules": {
    "detection_patterns": [
      {
        "pattern": "docs/tools/{zsh,nvim,wezterm}.md",
        "description": "Core tool documentation files"
      }
    ]
  }
}
```

**Update Frequency Tracking**:

```json
{
  "custom_rules": {
    "update_frequency": {
      "docs/tools/zsh.md": "monthly",
      "README.md": "quarterly"
    }
  }
}
```

**Required Files**:

```json
{
  "custom_rules": {
    "required_files": ["README.md", "CONTRIBUTING.md"]
  }
}
```

**Performance Impact Documentation**:

```json
{
  "custom_rules": {
    "performance_impact_required": ["docs/performance.md"]
  }
}
```

### 7. Documentation Structure

Verify consistent structure across documentation.

**Standard Sections**:

1. Metadata Block (title, date, audience, tags)
2. Overview/概要 (purpose and scope)
3. Main Content (core documentation)
4. Related Links/関連リンク (cross-references)
5. Update History/更新履歴 (change log)

**Icon Standards**:

Use consistent emoji icons:

- 📚 Documentation/Guidelines
- 🎯 Project Overview
- 🚀 Quick Start/Setup
- 📝 Specification/Design
- 🛠 Development/Implementation
- 🧪 Testing
- 📦 Release/Deployment
- 🔧 Configuration
- 🐛 Troubleshooting

## Workflow

### Review Existing Documentation

To review documentation:

1. Load configuration from `.docs-manager-config.json` or use defaults
2. Scan configured `docs_root` directory structure
3. For each markdown file:
   - Validate metadata presence and format
   - Check tag system compliance
   - Measure document size against configured limits
   - Verify internal structure
4. Run link validation if enabled
5. Apply project-specific rules from configuration
6. Generate comprehensive report
7. Provide prioritized improvement list

**Example**:

```
User: "Review all documentation"

1. Load .docs-manager-config.json → found dotfiles config
2. Scan ./docs → found 11 files
3. Validate each document against configured rules
4. Report:
   - 10/11 docs have complete metadata
   - 2 docs missing required layer/ tags
   - 1 doc exceeds configured warning size (consider split)
   - 3 broken internal links found
5. Provide prioritized fixes
```

### Create New Documentation

To help create new documentation:

1. Load project configuration
2. Identify document purpose and audience
3. Suggest appropriate tags from configured vocabulary
4. Recommend document structure
5. Provide metadata template based on configuration
6. Guide content organization
7. Validate against configured guidelines before finalizing

**Example**:

```
User: "Help me create a troubleshooting guide"

1. Load config → detected custom project
2. Identify: Operations documentation
3. Suggest tags from configured vocabulary:
   `category/operations`, `category/guide`, `audience/user`
4. Recommend structure based on project patterns
5. Provide template with configured metadata format
6. Validate before saving
```

### Maintenance Tasks

Periodic maintenance based on configuration:

- **Configured Frequency**: Check `custom_rules.update_frequency`
- **Quarterly**: Review all metadata for accuracy
- **Bi-annually**: Check for documents not updated in 6+ months
- **Continuous**: Link validation on document changes

## Integration

### With Other Skills

- **markdown-docs**: Content quality evaluation (writing, technical accuracy)
- **docs-manager**: Structure, metadata, tag compliance (this skill)

Use together for complete documentation review:

1. Apply docs-manager for structure validation
2. Apply markdown-docs for content quality
3. Combine insights for comprehensive review

### With Tools

Configure external tools via `tools` section:

```json
{
  "tools": {
    "linter": "npm run lint:docs",
    "formatter": "prettier --write",
    "link_checker": "markdown-link-check"
  }
}
```

## Configuration

### Setup Instructions

1. Copy template from `templates/docs-manager-config.template.json`
2. Place as `.docs-manager-config.json` in project root
3. Customize for your project needs
4. Reference `examples/` directory for sample configurations

### Example Configurations

**Generic Project** (`examples/generic-config.json`):

- Minimal configuration
- Standard metadata format
- Basic tag vocabulary

**Specialized Projects** (`examples/dotfiles-config.json`, etc.):

- Project-specific detection patterns
- Custom tag vocabulary
- Update frequency requirements
- Performance impact tracking

### Creating Custom Configuration

1. Start with `templates/docs-manager-config.template.json`
2. Set `docs_root` to your documentation directory
3. Choose `project_type`: `generic`, `dotfiles`, `pr-labeler`, `terraform-infra`, or `custom`
4. Define `required_tags` and `optional_tags`
5. Customize `size_limits` for your needs
6. Add `custom_rules` for project-specific requirements
7. Configure `tag_vocabulary` for validation

## Quality Metrics

Calculate documentation health score:

- ✅ Metadata completeness (30%)
- ✅ Tag compliance (20%)
- ✅ Size appropriateness (15%)
- ✅ Link integrity (20%)
- ✅ Update freshness (15%)

**Score Interpretation**:

- 90-100%: Excellent (well-maintained)
- 70-89%: Good (minor improvements)
- 50-69%: Fair (several issues)
- <50%: Poor (significant work required)

## Resources

### templates/

Configuration templates:

- `docs-manager-config.template.json` - Complete JSON schema with all options

### examples/

Sample configurations for different project types:

- `generic-config.json` - Basic configuration for any project
- `dotfiles-config.json` - Configuration for dotfiles projects
- `custom-project-config.json` - Advanced custom configuration example

### references/

Reference documentation and validation rules:

- Load tag systems and validation rules from configuration
- Provide generic defaults when configuration not specified

## Common Issues

### Missing Configuration

**Problem:** No `.docs-manager-config.json` found

### Solution:

Uses generic defaults with `./docs` as documentation root. To customize:

```bash
cp templates/docs-manager-config.template.json .docs-manager-config.json
# Edit to match your project
```

### Missing Metadata

**Problem:** Document lacks required metadata fields

### Solution:

Add complete metadata block at document top using configured format:

```markdown
# 📚 [Title]

**最終更新**: 2025-10-21
**対象**: 開発者
**タグ**: `category/documentation`, `audience/developer`
```

### Wrong Tag Format

**Problem:** Tags missing prefix or using wrong separator

### Solution:

- Use `prefix/value` format
- Check configured tag separator (comma vs. space)
- Verify tags against configured vocabulary

### Document Too Large

**Problem:** Document exceeds configured maximum size

### Solution:

1. Identify logical section boundaries
2. Create separate files for major topics
3. Use main doc as index with links
4. Maintain cross-references

### Broken Links

**Problem:** Internal or external links not working

### Solution:

- Use relative paths for internal links (relative to `docs_root`)
- Run configured link checker regularly
- Update links when restructuring
- Verify file paths after renaming

## Agent Integration

このスキルはドキュメント管理タスクを実行するエージェントに専門知識を提供します。

### Docs-Manager Agent

- **提供内容**: ドキュメントディレクトリの整合性確保、リンク切れ検出・修正
- **タイミング**: ドキュメント修正・構造最適化時
- **コンテキスト**:
  - 設定ファイルベースの検証
  - リンク切れ検出と自動修正
  - メタデータ検証（設定可能なフィールド）
  - ドキュメント構造最適化
  - プロジェクト固有ルール適用

### Orchestrator Agent

- **提供内容**: ドキュメントリファクタリング計画、構造改善
- **タイミング**: ドキュメント体系の大規模改善時
- **コンテキスト**: ディレクトリ構造設計、Progressive Disclosure実装、タグシステム統合

### Researcher Agent

- **提供内容**: ドキュメント調査、情報収集
- **タイミング**: ドキュメント発見・整理時
- **コンテキスト**: ドキュメント配置原則、リソースナビゲーション

### 自動ロード条件

- "docs review"、"documentation quality"、"docs management"に言及
- 設定されたドキュメントディレクトリ操作時
- ドキュメント構造検証要求時
- プロジェクト固有ドキュメント標準適用時

**統合例**:

```
ユーザー: "ドキュメントリンクを検証・修正"
    ↓
TaskContext作成
    ↓
タスク分類: ドキュメント管理
    ↓
スキル自動ロード: docs-manager, docs-index
    ↓
設定ファイルロード: .docs-manager-config.json
    ↓
エージェント選択: docs-manager
    ↓ (スキルコンテキスト提供)
リンク切れ検出 + メタデータ検証 + 自動修正
    ↓
実行完了（リンク整合性確保、構造最適化）
```

## Trigger Conditions

Activate this skill when:

- User mentions "docs review", "documentation quality", "docs management"
- Working with files in configured documentation directory
- User asks to validate documentation structure
- Creating or updating documentation in organized projects
- Need to enforce project-specific documentation standards
