# コンテンツ生成パターン

セクション別ドキュメント自動生成パターン集。

## README.md生成

### 基本構造

```markdown
# ${projectName}

${oneLineSummary}

## Features

${generateFeaturesList()}

## Installation

${generateInstallInstructions()}

## Quick Start

${generateQuickStart()}

## Documentation

${generateDocLinks()}

## License

${license}
```

### セクション生成関数

**Features Section**:

```python
def generate_features_list(project_analysis):
    """主要機能リストを生成"""

    features = []

    # コードから機能を抽出
    public_api = extract_public_api(project_analysis)

    for api_group in group_by_feature(public_api):
        features.append(f"- **{api_group['name']}**: {api_group['description']}")

    return "\n".join(features)
```

**Installation Section**:

```python
def generate_install_instructions(project_type, package_manager):
    """インストール手順を生成"""

    if project_type == "npm-package":
        return f"""
\`\`\`bash
{package_manager} install {package_name}
\`\`\`
"""
    elif project_type == "python-package":
        return """
\`\`\`bash
pip install {package_name}
\`\`\`
"""
```

## API Documentation生成

### 関数ドキュメント

```python
def generate_function_docs(functions):
    """関数ドキュメントを生成"""

    docs = []

    for func in functions:
        doc = f"""
### `{func['name']}`

{func['description']}

**Signature**:
\`\`\`{func['language']}
{func['signature']}
\`\`\`

**Parameters**:
{generate_parameters_table(func['params'])}

**Returns**:
{func['return_type']}: {func['return_description']}

**Example**:
\`\`\`{func['language']}
{generate_usage_example(func)}
\`\`\`

**Throws**:
{generate_exceptions_list(func['exceptions'])}
"""
        docs.append(doc)

    return "\n\n".join(docs)
```

### クラスドキュメント

```python
def generate_class_docs(classes):
    """クラスドキュメントを生成"""

    docs = []

    for cls in classes:
        doc = f"""
## `{cls['name']}`

{cls['description']}

### Constructor

\`\`\`{cls['language']}
{cls['constructor_signature']}
\`\`\`

{generate_constructor_params(cls)}

### Properties

{generate_properties_table(cls['properties'])}

### Methods

{generate_methods_docs(cls['methods'])}

### Example

\`\`\`{cls['language']}
{generate_class_usage_example(cls)}
\`\`\`
"""
        docs.append(doc)

    return "\n\n".join(docs)
```

## CHANGELOG生成

### エントリ生成

```python
def generate_changelog_entry(changes, version=None):
    """CHANGELOGエントリを生成"""

    if version:
        header = f"## [{version}] - {date.today()}"
    else:
        header = "## [Unreleased]"

    sections = []

    # Added
    if changes['added']:
        added = ["### Added\n"]
        for item in changes['added']:
            added.append(f"- {item['description']}")
        sections.append("\n".join(added))

    # Changed
    if changes['changed']:
        changed = ["### Changed\n"]
        for item in changes['changed']:
            changed.append(f"- {item['description']}")
            if item.get('breaking'):
                changed[-1] += " **BREAKING**"
        sections.append("\n".join(changed))

    # Fixed
    if changes['fixed']:
        fixed = ["### Fixed\n"]
        for item in changes['fixed']:
            fixed.append(f"- {item['description']}")
        sections.append("\n".join(fixed))

    return f"{header}\n\n" + "\n\n".join(sections)
```

## Configuration Documentation生成

### オプション一覧

```python
def generate_config_docs(config_schema):
    """設定オプションドキュメントを生成"""

    docs = ["# Configuration Reference\n"]

    for option in config_schema:
        doc = f"""
### `{option['name']}`

{option['description']}

- **Type**: `{option['type']}`
- **Default**: `{option['default']}`
- **Required**: {"Yes" if option['required'] else "No"}

{generate_example_config(option)}
"""
        docs.append(doc)

    return "\n".join(docs)
```

## Migration Guide生成

### 破壊的変更ガイド

```python
def generate_migration_guide(from_version, to_version, breaking_changes):
    """マイグレーションガイドを生成"""

    guide = f"""
# Migration Guide: v{from_version} to v{to_version}

## Overview

This guide helps you migrate from version {from_version} to {to_version}.

## Breaking Changes

{generate_breaking_changes_list(breaking_changes)}

## Migration Steps

{generate_migration_steps(breaking_changes)}

## Automated Migration

{generate_codemod_instructions(breaking_changes)}
"""

    return guide

def generate_breaking_changes_list(changes):
    """破壊的変更リストを生成"""

    items = []

    for change in changes:
        item = f"""
### {change['title']}

**Before**:
\`\`\`
{change['old_code']}
\`\`\`

**After**:
\`\`\`
{change['new_code']}
\`\`\`

**Reason**: {change['reason']}
"""
        items.append(item)

    return "\n".join(items)
```

## Troubleshooting Guide生成

### よくある問題セクション

```python
def generate_troubleshooting_docs(common_issues):
    """トラブルシューティングドキュメントを生成"""

    docs = ["# Troubleshooting\n"]

    for issue in common_issues:
        doc = f"""
## {issue['title']}

**Symptoms**:
{generate_symptoms_list(issue['symptoms'])}

**Cause**:
{issue['cause']}

**Solution**:
{generate_solution_steps(issue['solution'])}

**Prevention**:
{issue['prevention']}
"""
        docs.append(doc)

    return "\n".join(docs)
```

## Performance Documentation生成

### ベンチマーク結果

```python
def generate_performance_docs(benchmarks):
    """パフォーマンスドキュメントを生成"""

    docs = ["# Performance\n"]

    # ベンチマーク結果テーブル
    docs.append("## Benchmarks\n")
    docs.append(generate_benchmark_table(benchmarks))

    # 最適化ガイド
    docs.append("\n## Optimization Guide\n")
    docs.append(generate_optimization_tips())

    return "\n".join(docs)
```

## Security Documentation生成

### セキュリティポリシー

```python
def generate_security_docs():
    """セキュリティドキュメントを生成"""

    return """
# Security Policy

## Supported Versions

${generate_supported_versions_table()}

## Reporting a Vulnerability

${generate_vulnerability_reporting_instructions()}

## Security Best Practices

${generate_security_best_practices()}
"""
```

詳細な生成パターンは各プロジェクトタイプに応じて [ai-driven-analysis.md](./ai-driven-analysis.md) を参照。
