---
description: Comprehensive project cleanup with semantic analysis
argument-hint:
---

# Clean Full - 包括的プロジェクトクリーンアップ

プロジェクト全体を包括的にクリーンアップし、不要なコード、コメント、ファイル、ドキュメントの重複を整理します。MCP Serenaのセマンティック解析を活用した高精度なクリーンアップを提供します。

## 🎯 Core Mission

プロジェクトの品質と保守性を向上させるため、以下を包括的に実行：

1. **セマンティック・コード解析** - MCP Serenaによる構造理解
2. **不要コードの除去** - 未使用関数、クラス、import文の削除
3. **デバッグコードの削除** - console.log、print、TODO等の整理
4. **ファイルの整理** - 一時ファイル、ログファイルの削除
5. **ドキュメント統合** - 重複解消と一貫性確保

## 🧠 Strategic Analysis Process

### Thinking Notes

クリーンアップを安全かつ効果的に実行するため、以下の戦略を採用：

1. **安全性最優先**
   - 必ずGitチェックポイントを作成
   - セマンティック解析による誤削除防止
   - 段階的実行によるリスク最小化

2. **MCP Serenaの活用**
   - プロジェクト構造の正確な把握
   - 依存関係の追跡による安全な削除
   - パターンマッチングによる効率的検出

3. **既存機能の統合**
   - cleanproject: ファイル整理機能
   - remove-comments: コメント最適化
   - docs: ドキュメント管理

## 🚀 Implementation Strategy

### Phase 1: 安全性確保とプロジェクト解析

```bash
# 安全なチェックポイント作成
git add -A
git commit -m "Pre-cleanup checkpoint" || echo "No changes to commit"

# MCP Serenaによるプロジェクト構造解析
mcp__serena__list_dir(".", recursive=true)
mcp__serena__get_symbols_overview() # 主要ファイルの概要把握
```

### Phase 2: セマンティック・コード解析

**MCP Serenaを活用した高精度解析:**

```python
# 未使用シンボルの検出
def detect_unused_symbols():
    """セマンティック解析による未使用コードの特定"""

    # 全シンボルを取得
    all_symbols = mcp__serena__find_symbol("", substring_matching=true)

    unused_symbols = []
    for symbol in all_symbols:
        # 参照を検索
        references = mcp__serena__find_referencing_symbols(
            symbol["name_path"],
            symbol["relative_path"]
        )

        # 参照がない（自分以外）場合は未使用
        if len(references) <= 1:  # 定義のみ
            unused_symbols.append(symbol)

    return unused_symbols

# デバッグコード・TODOの検出
debug_patterns = [
    r"console\.log\s*\(",
    r"print\s*\(",
    r"debug\s*\(",
    r"TODO[:\s]",
    r"FIXME[:\s]",
    r"HACK[:\s]",
    r"XXX[:\s]"
]

for pattern in debug_patterns:
    matches = mcp__serena__search_for_pattern(
        substring_pattern=pattern,
        restrict_search_to_code_files=true,
        context_lines_before=1,
        context_lines_after=1
    )
```

### Phase 3: コード整理実行

**段階的な安全なクリーンアップ:**

1. **不要コメントの削除**
   - 既存 `remove-comments` 機能を活用
   - 明らかに冗長なコメントのみ削除
   - 重要なドキュメントは保持

2. **デバッグコードの除去**

   ```python
   def remove_debug_code():
       """デバッグコードを安全に除去"""
       for file_path, matches in debug_matches.items():
           # ファイル内容を読取り
           content = read_file(file_path)

           # 各マッチを確認し、安全に削除
           for match in matches:
               if is_safe_to_remove(match):
                   content = remove_debug_line(content, match)

           # 変更を適用
           write_file(file_path, content)
   ```

3. **未使用import文の整理**
   - セマンティック解析による正確な検出
   - 自動整理とフォーマット

### Phase 4: ファイル整理

**既存 `cleanproject` 機能の統合:**

```python
def cleanup_files():
    """安全なファイル整理"""

    # 削除対象パターン
    cleanup_patterns = [
        "**/*.log",
        "**/*.tmp",
        "**/*~",
        "**/.DS_Store",
        "**/Thumbs.db",
        "**/*.pyc",
        "**/__pycache__",
        "**/node_modules/.cache"
    ]

    for pattern in cleanup_patterns:
        files = glob(pattern)
        for file_path in files:
            # 重要ファイルは保護
            if not is_protected_file(file_path):
                safe_remove(file_path)
```

### Phase 5: ドキュメント統合と重複解消

**MCP Serenaによるドキュメント解析:**

```python
def consolidate_documentation():
    """ドキュメントの重複解消と統合"""

    # docsディレクトリの解析
    docs_structure = mcp__serena__list_dir("./docs", recursive=true)

    # 重複コンテンツの検出
    duplicate_content = []

    for doc_file in docs_structure["files"]:
        # 類似コンテンツを検索
        similar_docs = mcp__serena__search_for_pattern(
            substring_pattern=extract_key_phrases(doc_file),
            relative_path="docs",
            paths_include_glob="*.md"
        )

        if len(similar_docs) > 1:
            duplicate_content.append({
                "primary": doc_file,
                "duplicates": similar_docs
            })

    # 重複の解消方針を提案
    return create_consolidation_plan(duplicate_content)
```

## 🎛️ Execution Modes

### デフォルトモード（包括的クリーンアップ）

```bash
/cleanup
```

全ての機能を段階的に実行

### 選択的クリーンアップ

```bash
/cleanup --code-only      # コードのみ
/cleanup --docs-only      # ドキュメントのみ
/cleanup --files-only     # ファイルのみ
/cleanup --dry-run        # プレビューのみ
```

## 📊 実行レポート

クリーンアップ完了後、詳細なレポートを提供：

```markdown
🧹 **Cleanup Report**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📋 Summary

- **Files processed**: 45
- **Lines removed**: 892
- **Files deleted**: 12
- **Documentation consolidated**: 3 → 1

## 🔍 Code Analysis (MCP Serena)

- **Unused functions**: 8 removed
- **Unused imports**: 23 cleaned
- **Debug statements**: 15 removed
- **TODO items**: 7 tracked

## 📁 File Cleanup

- **Temporary files**: 12 removed (3.2MB freed)
- **Log files**: 8 removed (15.7MB freed)
- **Cache files**: 34 removed (128MB freed)

## 📖 Documentation

- **Duplicates resolved**: 3 files
- **Links fixed**: 12
- **Consistency improved**: README, CHANGELOG

## 🔄 Next Steps

- Review TODO items: 7 remaining
- Update CI/CD: Consider lint rule updates
- Team sync: Share cleanup guidelines
```

## 🛡️ Safety Features

### 自動保護機能

- **プロテクトパターン**: `.claude/`, `.git/`, `node_modules/`
- **設定ファイル保護**: `.env`, `config/*`
- **実行前バックアップ**: Gitチェックポイント必須

### リカバリー機能

```bash
# 問題が発生した場合の復旧
git reset --hard HEAD~1  # チェックポイントに戻る
```

## 🤖 MCP Serena Integration Benefits

1. **高精度解析**: 構文だけでなくセマンティクスを理解
2. **依存関係追跡**: 安全な削除判定
3. **効率的検索**: パターンマッチングの最適化
4. **構造理解**: プロジェクト全体の把握

## 🔗 Integration with Other Commands

- **`/review`**: クリーンアップ後の品質確認
- **`/test`**: 機能が破損していないことを確認
- **`/docs`**: ドキュメント品質の最終確認
- **`/format`**: コードスタイルの統一

## ⚠️ Important Notes

**実行時の注意:**

- 大規模プロジェクトでは段階的実行を推奨
- 重要な設定ファイルは事前確認
- チーム開発では事前相談を推奨

**除外設定:**
必要に応じて `.cleanupignore` ファイルで除外パターンを定義可能

これにより、プロジェクト全体が整理され、開発効率と保守性が大幅に向上します。
