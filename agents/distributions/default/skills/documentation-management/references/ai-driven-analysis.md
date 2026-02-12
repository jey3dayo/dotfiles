# AI駆動分析

プロジェクト構造の自動解析とドキュメントコンテンツ生成手法。

## プロジェクト構造分析

### project-detector統合

project-detectorを使用してプロジェクトタイプとスタックを自動判定します。

### 判定可能なプロジェクトタイプ

- Web Application (React, Vue, Angular, Svelte等)
- API/Backend (Node.js, Python, Go, Rust等)
- CLI Tool
- Library/Framework
- Desktop Application
- Mobile Application
- Documentation Site

### 検出される技術スタック情報

```json
{
  "type": "web-app",
  "framework": "React",
  "language": "TypeScript",
  "buildTool": "Vite",
  "testFramework": "Vitest",
  "styling": "Tailwind CSS",
  "packageManager": "npm"
}
```

### 分析フロー

```python
def analyze_project():
    """プロジェクト全体の構造分析"""

    # 1. プロジェクトタイプ判定
    project_type = detect_project_type()

    # 2. 技術スタック検出
    stack = detect_tech_stack()

    # 3. ファイル構造分析
    structure = analyze_file_structure()

    # 4. コード構造分析（MCP Serena使用）
    code_structure = analyze_code_structure()

    # 5. ドキュメントギャップ特定
    gaps = identify_documentation_gaps(
        project_type, stack, structure, code_structure
    )

    return {
        "project_type": project_type,
        "stack": stack,
        "structure": structure,
        "code_structure": code_structure,
        "documentation_gaps": gaps
    }
```

## MCP Serena統合

### シンボル解析によるコード理解

### get_symbols_overview

```python
def analyze_file_structure(file_path):
    """ファイル内のシンボル構造を解析"""

    # シンボル概要を取得
    overview = mcp_serena.get_symbols_overview(
        relative_path=file_path,
        depth=1  # 即座の子シンボルまで
    )

    # クラス、関数、エクスポートを抽出
    classes = [s for s in overview if s['kind'] == 'class']
    functions = [s for s in overview if s['kind'] == 'function']
    exports = [s for s in overview if s['kind'] == 'export']

    return {
        "classes": classes,
        "functions": functions,
        "exports": exports
    }
```

### find_symbol

```python
def find_public_api():
    """公開APIを特定"""

    # エクスポートされたシンボルを検索
    exported = mcp_serena.find_symbol(
        name_path_pattern="",  # すべてのシンボル
        include_kinds=[12],    # Function kind
        relative_path="src/"
    )

    # JSDocコメントから説明を抽出
    api_docs = []
    for symbol in exported:
        if has_export_keyword(symbol):
            api_docs.append({
                "name": symbol['name'],
                "signature": symbol['signature'],
                "description": extract_jsdoc(symbol)
            })

    return api_docs
```

### find_referencing_symbols

```python
def analyze_feature_impact(feature_name):
    """機能の影響範囲を分析"""

    # 機能のエントリポイントを特定
    entry_point = mcp_serena.find_symbol(
        name_path_pattern=feature_name,
        relative_path="src/features/"
    )

    # この機能を参照するコードを追跡
    references = mcp_serena.find_referencing_symbols(
        name_path=entry_point['name_path'],
        relative_path=entry_point['file']
    )

    # 影響を受けるドキュメントを特定
    affected_docs = identify_affected_docs(references)

    return {
        "feature": feature_name,
        "references": references,
        "affected_docs": affected_docs
    }
```

## コンテンツ生成戦略

### プロジェクトタイプ別アプローチ

#### Web Application

### 重点ドキュメント

- Setup Guide: 開発環境のセットアップ
- Component Documentation: コンポーネント使用例
- Styling Guide: デザインシステム
- Deployment Guide: デプロイ手順

### 生成パターン

```markdown
# Setup Guide

## Prerequisites

- Node.js ${nodeVersion}+
- npm ${npmVersion}+

## Installation

\`\`\`bash
npm install
\`\`\`

## Development

\`\`\`bash
npm run dev
\`\`\`

## Build

\`\`\`bash
npm run build
\`\`\`

## Environment Variables

${generateEnvDocs()}
```

#### API/Backend

### 重点ドキュメント

- API Reference: エンドポイント仕様
- Authentication: 認証方法
- Database Schema: データベース構造
- Deployment: サーバーセットアップ

### 生成パターン

```markdown
# API Reference

## Endpoints

${generateEndpointDocs()}

## Authentication

${generateAuthDocs()}

## Error Codes

${generateErrorCodeDocs()}
```

#### CLI Tool

### 重点ドキュメント

- Command Reference: コマンド一覧
- Configuration: 設定ファイル
- Examples: 使用例
- Troubleshooting: よくある問題

### 生成パターン

```markdown
# Command Reference

${generateCommandDocs()}

## Global Options

${generateGlobalOptionsDocs()}

## Configuration

${generateConfigDocs()}
```

#### Library/Framework

### 重点ドキュメント

- API Reference: 完全なAPI仕様
- Getting Started: クイックスタート
- Examples: 実用例
- Migration Guides: バージョン移行

### 生成パターン

```markdown
# API Reference

${generateClassDocs()}

${generateFunctionDocs()}

${generateTypeDocs()}

## Examples

${generateUsageExamples()}
```

### セクション別生成パターン

詳細は [content-generation-patterns.md](./content-generation-patterns.md) を参照。

## ドキュメントギャップ特定

### ギャップ分析アルゴリズム

```python
def identify_documentation_gaps(project_analysis):
    """ドキュメント化されていない要素を特定"""

    gaps = []

    # 1. 公開API vs ドキュメント
    public_api = extract_public_api(project_analysis)
    documented_api = extract_documented_api()

    for api_item in public_api:
        if api_item not in documented_api:
            gaps.append({
                "type": "undocumented_api",
                "item": api_item,
                "severity": "high"
            })

    # 2. 設定オプション vs ドキュメント
    config_options = extract_config_options(project_analysis)
    documented_config = extract_documented_config()

    for option in config_options:
        if option not in documented_config:
            gaps.append({
                "type": "undocumented_config",
                "item": option,
                "severity": "medium"
            })

    # 3. エラーコード vs ドキュメント
    error_codes = extract_error_codes(project_analysis)
    documented_errors = extract_documented_errors()

    for error in error_codes:
        if error not in documented_errors:
            gaps.append({
                "type": "undocumented_error",
                "item": error,
                "severity": "low"
            })

    # 4. 必須ドキュメントの存在確認
    required_docs = get_required_docs(project_analysis['type'])
    existing_docs = list_existing_docs()

    for required in required_docs:
        if required not in existing_docs:
            gaps.append({
                "type": "missing_document",
                "item": required,
                "severity": "high"
            })

    return sorted(gaps, key=lambda x: severity_order(x['severity']))
```

### ギャップの優先順位付け

### 高優先度

- 公開APIの未ドキュメント
- READMEの不在
- セットアップ手順の不足
- 破壊的変更の未記載

### 中優先度

- 設定オプションの未ドキュメント
- トラブルシューティングガイドの不足
- パフォーマンスガイドの不足

### 低優先度

- 内部実装の詳細
- エッジケースの例
- 高度な使用例

## スマート更新ロジック

### 変更検出

```python
def detect_changes():
    """コードベースの変更を検出"""

    changes = {
        "new_features": [],
        "changed_apis": [],
        "removed_features": [],
        "new_config_options": [],
        "updated_dependencies": []
    }

    # 1. 新機能の検出
    current_exports = get_current_exports()
    previous_exports = get_previous_exports()  # from git

    for export in current_exports:
        if export not in previous_exports:
            changes["new_features"].append(export)

    # 2. API変更の検出
    for export in current_exports:
        if export in previous_exports:
            current_sig = get_signature(export)
            previous_sig = get_previous_signature(export)

            if current_sig != previous_sig:
                changes["changed_apis"].append({
                    "name": export,
                    "old": previous_sig,
                    "new": current_sig
                })

    # 3. 削除された機能の検出
    for export in previous_exports:
        if export not in current_exports:
            changes["removed_features"].append(export)

    # 4. 設定オプションの変更
    current_config = parse_config_schema()
    previous_config = get_previous_config_schema()

    new_options = set(current_config) - set(previous_config)
    changes["new_config_options"] = list(new_options)

    # 5. 依存関係の更新
    current_deps = parse_package_json()['dependencies']
    previous_deps = get_previous_package_json()['dependencies']

    for dep, version in current_deps.items():
        if dep not in previous_deps or version != previous_deps[dep]:
            changes["updated_dependencies"].append({
                "package": dep,
                "old_version": previous_deps.get(dep),
                "new_version": version
            })

    return changes
```

### 影響範囲マッピング

```python
def map_changes_to_docs(changes):
    """変更をドキュメントにマッピング"""

    updates_needed = {}

    # 新機能 → README, API docs, CHANGELOG
    if changes["new_features"]:
        updates_needed["README.md"] = {
            "section": "Features",
            "action": "add",
            "content": generate_feature_list(changes["new_features"])
        }
        updates_needed["docs/api.md"] = {
            "section": "API Reference",
            "action": "add",
            "content": generate_api_docs(changes["new_features"])
        }
        updates_needed["CHANGELOG.md"] = {
            "section": "[Unreleased] - Added",
            "action": "add",
            "content": generate_changelog_entries(changes["new_features"])
        }

    # API変更 → API docs, Migration guide, CHANGELOG
    if changes["changed_apis"]:
        updates_needed["docs/api.md"] = {
            "section": "API Reference",
            "action": "update",
            "content": generate_updated_api_docs(changes["changed_apis"])
        }

        # 破壊的変更の場合
        if has_breaking_changes(changes["changed_apis"]):
            updates_needed["docs/migration.md"] = {
                "section": f"Migrating to v{next_version()}",
                "action": "add",
                "content": generate_migration_guide(changes["changed_apis"])
            }
            updates_needed["CHANGELOG.md"] = {
                "section": "[Unreleased] - Changed (BREAKING)",
                "action": "add",
                "content": generate_breaking_change_entries(changes["changed_apis"])
            }
        else:
            updates_needed["CHANGELOG.md"] = {
                "section": "[Unreleased] - Changed",
                "action": "add",
                "content": generate_changelog_entries(changes["changed_apis"])
            }

    # 設定オプション → Configuration docs, CHANGELOG
    if changes["new_config_options"]:
        updates_needed["docs/configuration.md"] = {
            "section": "Options",
            "action": "add",
            "content": generate_config_docs(changes["new_config_options"])
        }
        updates_needed["CHANGELOG.md"] = {
            "section": "[Unreleased] - Added",
            "action": "add",
            "content": generate_config_changelog(changes["new_config_options"])
        }

    return updates_needed
```

## 会話履歴分析

### セッション・ドキュメンテーション

```python
def analyze_conversation_history():
    """会話履歴から変更内容を抽出"""

    # 会話履歴から実行されたコマンドを抽出
    commands = extract_commands_from_history()

    # ファイル変更を分析
    file_changes = analyze_file_changes(commands)

    # 変更をカテゴリ別にグループ化
    categorized = categorize_changes(file_changes)

    return {
        "features": categorized.get("feature", []),
        "fixes": categorized.get("fix", []),
        "refactoring": categorized.get("refactor", []),
        "performance": categorized.get("performance", []),
        "security": categorized.get("security", [])
    }

def categorize_changes(file_changes):
    """変更内容を自動分類"""

    categories = {}

    for change in file_changes:
        # コミットメッセージやファイルパスから分類
        if is_new_feature(change):
            categories.setdefault("feature", []).append(change)
        elif is_bug_fix(change):
            categories.setdefault("fix", []).append(change)
        elif is_refactoring(change):
            categories.setdefault("refactor", []).append(change)
        elif is_performance_improvement(change):
            categories.setdefault("performance", []).append(change)
        elif is_security_fix(change):
            categories.setdefault("security", []).append(change)

    return categories
```

## コンテキスト自動判定

### セッションタイプ判定

```python
def detect_session_type():
    """セッション内容からドキュメント更新タイプを判定"""

    changes = analyze_conversation_history()

    # 新機能追加セッション
    if changes["features"]:
        return {
            "type": "feature_addition",
            "updates": ["README.md", "docs/api.md", "CHANGELOG.md"]
        }

    # バグ修正セッション
    if changes["fixes"]:
        return {
            "type": "bug_fix",
            "updates": ["CHANGELOG.md", "docs/troubleshooting.md"]
        }

    # リファクタリングセッション
    if changes["refactoring"]:
        return {
            "type": "refactoring",
            "updates": ["docs/architecture.md", "docs/migration.md"]
        }

    # パフォーマンス改善セッション
    if changes["performance"]:
        return {
            "type": "performance_improvement",
            "updates": ["docs/performance.md", "CHANGELOG.md"]
        }

    # セキュリティ修正セッション
    if changes["security"]:
        return {
            "type": "security_fix",
            "updates": ["SECURITY.md", "CHANGELOG.md"]
        }

    # 複合セッション
    return {
        "type": "mixed",
        "updates": infer_affected_docs(changes)
    }
```

### 自動更新実行

```python
def auto_update_documentation(session_type):
    """セッションタイプに応じて適切なドキュメントを更新"""

    updates = []

    for doc_file in session_type["updates"]:
        # ドキュメントを読み込む
        content = read_file(doc_file)

        # 適切なセクションを特定
        section = identify_update_section(doc_file, session_type)

        # 更新コンテンツを生成
        new_content = generate_update_content(
            session_type,
            analyze_conversation_history()
        )

        # インプレース更新
        updated = update_section(content, section, new_content)

        # ファイルに書き込む
        write_file(doc_file, updated)

        updates.append({
            "file": doc_file,
            "section": section,
            "status": "updated"
        })

    return updates
```

## 品質保証

### 生成コンテンツの検証

```python
def validate_generated_content(content, doc_type):
    """生成されたコンテンツの品質を検証"""

    validations = []

    # 1. 構文チェック
    if doc_type == "markdown":
        validations.append(validate_markdown_syntax(content))

    # 2. リンク検証
    validations.append(validate_links(content))

    # 3. コード例の検証
    code_blocks = extract_code_blocks(content)
    for block in code_blocks:
        validations.append(validate_code_block(block))

    # 4. スタイルチェック
    validations.append(check_writing_style(content))

    # 5. 完全性チェック
    validations.append(check_completeness(content, doc_type))

    return {
        "valid": all(v["passed"] for v in validations),
        "validations": validations
    }
```

### フィードバックループ

```python
def improve_with_feedback(content, validation_results):
    """検証結果に基づいてコンテンツを改善"""

    improved = content

    for validation in validation_results["validations"]:
        if not validation["passed"]:
            # 問題を修正
            improved = apply_fix(improved, validation["issue"])

    # 再検証
    revalidated = validate_generated_content(improved, doc_type)

    if revalidated["valid"]:
        return improved
    else:
        # 再帰的に改善（最大3回）
        if validation_attempts < 3:
            return improve_with_feedback(improved, revalidated)
        else:
            # 手動レビューが必要
            return {
                "content": improved,
                "needs_manual_review": True,
                "issues": revalidated
            }
```

## まとめ

AI駆動分析により:

- **自動プロジェクト理解**: コード構造を自動的に解析
- **ギャップ特定**: ドキュメント化されていない要素を発見
- **スマート更新**: 変更内容に応じて適切なドキュメントを更新
- **品質保証**: 生成されたコンテンツの品質を検証

これらの技術により、プロジェクトの実態に即した正確なドキュメントを効率的に維持できます。
