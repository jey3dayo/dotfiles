# フルクリーンアップ戦略 - Serenaセマンティック解析

MCP Serenaのセマンティック解析を活用した包括的プロジェクトクリーンアップの詳細仕様。

## 概要

プロジェクト全体を包括的に解析し、不要なコード、コメント、ドキュメントの重複を整理します。構文レベルだけでなく、セマンティック（意味論）レベルでコードを理解することで、高精度かつ安全なクリーンアップを実現します。

## クリーンアップ対象

### 1. 不要コードの除去

- 未使用関数・クラス
- 未使用import文
- 到達不能コード（dead code）
- デバッグコード（console.log、print等）

### 2. コメントの最適化

- 冗長なコメント
- 古いTODO/FIXME
- コメントアウトされたコード
- 重要なドキュメントは保持

### 3. ファイルの整理

- 一時ファイル（_.log, _.tmp）
- システムファイル（.DS_Store等）
- キャッシュファイル（\*.pyc, **pycache**）
- 空ディレクトリ

### 4. ドキュメント統合

- 重複コンテンツの検出
- ドキュメント統合
- リンク修正
- 一貫性確保

## 実行フェーズ

### Phase 1: 安全性確保とプロジェクト解析

```bash
# 安全なチェックポイント作成
git add -A
git commit -m "Pre-cleanup checkpoint" || echo "No changes to commit"

# プロジェクト構造解析
mcp__serena__list_dir(".", recursive=true)
mcp__serena__get_symbols_overview()  # 主要ファイルの概要把握
```

**実行内容**:

- Gitチェックポイント作成（ロールバック用）
- プロジェクト構造の把握
- 主要ファイルのシンボル概要取得

### Phase 2: セマンティック・コード解析

MCP Serenaを活用した高精度解析により、未使用コードとデバッグコードを検出します。

#### 未使用シンボルの検出

```python
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
```

**検出ロジック**:

1. プロジェクト内の全シンボル（関数、クラス、変数）を取得
2. 各シンボルの参照箇所を検索
3. 定義のみで参照がないシンボルを未使用と判定
4. エクスポート・Public APIは除外

#### デバッグコード・TODOの検出

```python
# デバッグコード・TODOの検出パターン
debug_patterns = [
    r"console\.log\s*\(",      # JavaScript
    r"print\s*\(",             # Python
    r"debug\s*\(",             # 各種言語
    r"TODO[:\s]",              # TODO
    r"FIXME[:\s]",             # FIXME
    r"HACK[:\s]",              # HACK
    r"XXX[:\s]"                # XXX
]

for pattern in debug_patterns:
    matches = mcp__serena__search_for_pattern(
        substring_pattern=pattern,
        restrict_search_to_code_files=true,
        context_lines_before=1,
        context_lines_after=1
    )
```

**検出対象**:

- デバッグプリント文
- デバッグ用関数呼び出し
- TODO/FIXME/HACK等のマーカー
- コメントアウトされた大きなコードブロック

### Phase 3: コード整理実行

段階的な安全なクリーンアップを実行します。

#### 1. 不要コメントの削除

```python
def remove_redundant_comments():
    """明らかに冗長なコメントのみ削除"""

    redundant_patterns = [
        r"^\s*#\s*$",                    # 空コメント
        r"^\s*//\s*$",                   # 空コメント
        r"^\s*#\s*-+\s*$",               # 区切り線のみ
        r"^\s*//\s*=+\s*$"               # 区切り線のみ
    ]

    # 重要なドキュメントコメントは保持
    protected_patterns = [
        r"^\s*""".*"""",                 # Docstring
        r"^\s*/\*\*.*\*/",               # JSDoc
        r"^\s*#\s*@",                    # デコレータ
        r"^\s*//\s*@"                    # アノテーション
    ]
```

**削除基準**:

- 空のコメント行
- 区切り線のみのコメント
- コードと同じ内容を繰り返すコメント
- Docstring、JSDoc等の重要ドキュメントは保持

#### 2. デバッグコードの除去

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

def is_safe_to_remove(match):
    """削除が安全かを判定"""
    # 条件分岐内のみで使用されるデバッグコードは削除
    # 値を返すデバッグコードは保持（副作用がある可能性）
    # テストコード内のデバッグコードは保持

    if is_in_test_file(match):
        return False
    if has_side_effects(match):
        return False
    if is_conditional_debug(match):
        return True

    return True
```

**削除基準**:

- 条件分岐内の独立したデバッグコード
- 副作用のないログ出力
- テストコード内は保持
- 値を返すデバッグコードは慎重に判断

#### 3. 未使用import文の整理

```python
def cleanup_unused_imports():
    """セマンティック解析による正確なimport整理"""

    # 各ファイルのimport文を解析
    for file_path in code_files:
        symbols = mcp__serena__get_symbols_overview(file_path)

        # import文を取得
        imports = [s for s in symbols if s["kind"] == "import"]

        for imp in imports:
            # インポートされたシンボルの使用箇所を検索
            references = mcp__serena__find_referencing_symbols(
                imp["name_path"],
                file_path
            )

            # インポート文以外の参照がなければ削除
            if len(references) <= 1:
                remove_import(file_path, imp)
```

**整理ロジック**:

1. ファイル内のimport文を全て取得
2. 各インポートの参照箇所を検索
3. インポート文以外の参照がなければ未使用と判定
4. 型アノテーションでの使用も考慮

### Phase 4: ファイル整理

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

def is_protected_file(file_path):
    """重要ファイルの保護"""
    protected_patterns = [
        ".claude/",
        ".git/",
        "node_modules/",
        ".env",
        "config/"
    ]

    return any(p in file_path for p in protected_patterns)
```

**削除対象**:

- 一時ファイル（_.log, _.tmp, \*~）
- システムファイル（.DS_Store, Thumbs.db）
- コンパイル生成物（_.pyc, _.class）
- キャッシュディレクトリ

**保護対象**:

- `.claude/` ディレクトリ
- `.git/` ディレクトリ
- 依存関係ディレクトリ（node_modules等）
- 設定ファイル（.env, config/\*）

### Phase 5: ドキュメント統合と重複解消

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

def create_consolidation_plan(duplicates):
    """統合計画を作成"""

    plan = []
    for dup in duplicates:
        # 最も詳細なドキュメントを主文書として選択
        primary = select_primary_doc(dup["duplicates"])
        others = [d for d in dup["duplicates"] if d != primary]

        plan.append({
            "action": "merge",
            "primary": primary,
            "merge_from": others,
            "reason": "重複コンテンツの統合"
        })

    return plan
```

**統合ロジック**:

1. docsディレクトリ内のファイルを全て解析
2. キーフレーズを抽出して類似ドキュメントを検索
3. 重複が見つかった場合、統合計画を作成
4. 最も詳細なドキュメントを主文書として選択
5. 他のドキュメントから情報をマージ
6. リンクを修正

## MCP Serena統合の利点

### 1. 高精度解析

構文（syntax）だけでなく、セマンティクス（semantics）を理解:

- 変数の使用箇所を正確に追跡
- 型情報を考慮した解析
- スコープを考慮した判定

### 2. 依存関係追跡

安全な削除判定が可能:

- シンボル間の依存関係を完全に把握
- 間接的な参照も検出
- エクスポート・Public APIの保護

### 3. 効率的検索

パターンマッチングの最適化:

- 正規表現による柔軟な検索
- コンテキスト行の取得
- ファイルタイプによるフィルタリング

### 4. 構造理解

プロジェクト全体の把握:

- ディレクトリ構造の理解
- ファイル間の関連性
- モジュール構成の把握

## 実行モード

### デフォルトモード（包括的クリーンアップ）

```bash
/project-maintenance full
```

全てのPhaseを段階的に実行します。

### 選択的クリーンアップ

```bash
/project-maintenance full --code-only      # コードのみ
/project-maintenance full --docs-only      # ドキュメントのみ
/project-maintenance full --files-only     # ファイルのみ
/project-maintenance full --dry-run        # プレビューのみ
```

### オプション

- `--code-only`: コード解析とクリーンアップのみ実行
- `--docs-only`: ドキュメント統合のみ実行
- `--files-only`: ファイル整理のみ実行
- `--dry-run`: 実際の削除は行わず、プレビューのみ
- `--aggressive`: より積極的なクリーンアップ（要注意）

## セーフティ機能

### 自動保護機能

- **プロテクトパターン**: `.claude/`, `.git/`, `node_modules/`
- **設定ファイル保護**: `.env`, `config/*`
- **実行前バックアップ**: Gitチェックポイント必須

### リカバリー機能

```bash
# 問題が発生した場合の復旧
git reset --hard HEAD~1  # チェックポイントに戻る
```

## ベストプラクティス

### 実行前

1. **Gitコミット**: 未コミット変更をコミット
2. **テスト実行**: 既存テストが全てパス
3. **ブランチ作成**: クリーンアップ用ブランチ推奨

### 実行中

1. **段階的実行**: 大規模プロジェクトでは選択的実行
2. **dry-run確認**: まずプレビューで確認
3. **中間確認**: Phaseごとに状態確認

### 実行後

1. **テスト実行**: 機能が破損していないか確認
2. **動作確認**: 重要な機能を手動確認
3. **レビュー**: チームメンバーにレビュー依頼

## 除外設定

`.cleanupignore` ファイルで除外パターンを定義可能:

```gitignore
# 除外するファイル・ディレクトリ
legacy/
experimental/
*.backup

# 除外するパターン
**/vendor/**
**/third_party/**
```

## トラブルシューティング

### 問題: 重要なコードが未使用と判定される

**原因**: リフレクションや動的呼び出しで使用されている

**対処**:

```python
# @preserve コメントで保護
# @preserve: Used via reflection
def dynamic_handler():
    pass
```

### 問題: テストが失敗する

**原因**: テスト用のモックやフィクスチャが削除された

**対処**:

```bash
# ロールバックしてテストディレクトリを除外
git reset --hard HEAD~1
echo "tests/" >> .cleanupignore
/project-maintenance full
```

### 問題: ビルドが失敗する

**原因**: 生成コードや型定義が削除された

**対処**:

```bash
# ロールバックして生成ファイルを保護
git reset --hard HEAD~1
echo "generated/" >> .cleanupignore
echo "*.d.ts" >> .cleanupignore
/project-maintenance full
```
