# PR Templates - PRテンプレートと本文生成

Phase 4: GitHub PR作成時のテンプレート検出とPR本文生成の完全な仕様。

## Table of Contents

- [概要](#概要)
- [PRテンプレート検出](#prテンプレート検出)
- [日本語PR本文生成](#日本語pr本文生成)
- [テンプレート埋め込み](#テンプレート埋め込み)
- [セクション構造](#セクション構造)

## 概要

PR本文は、リポジトリの `.github/PULL_REQUEST_TEMPLATE.md` を検出して使用するか、デフォルトの日本語フォーマットで生成します。

### 目的

- リポジトリのPRテンプレートを尊重
- 日本語で分かりやすいPR本文を生成
- コミット内容から自動的にサマリーを作成
- レビュアーが必要な情報を網羅

### 実行タイミング

## PRテンプレート検出

### 検出パス

以下の優先順位でテンプレートを検索します:

```python
def check_pr_template():
    """PRテンプレートの存在確認と内容取得"""

    template_paths = [
        ".github/PULL_REQUEST_TEMPLATE.md",
        ".github/pull_request_template.md",
        ".github/PULL_REQUEST_TEMPLATE",
        "docs/pull_request_template.md",
        "PULL_REQUEST_TEMPLATE.md"
    ]

    print("🔍 PRテンプレート検索中...")
    for path in template_paths:
        print(f"  - {path} をチェック中...", end=" ")
        if os.path.exists(path):
            print("✅ 検出")
            print(f"📋 PRテンプレート使用: {path}")
            with open(path, 'r') as f:
                return f.read()
        else:
            print("❌ 未検出")

    print("\n⚠️  PRテンプレートが見つかりませんでした")
    print("💡 以下のいずれかの場所にテンプレートを作成できます:")
    for path in template_paths[:3]:  # 主要な3つのパスを表示
        print(f"   - {path}")
    print("\n📝 デフォルトのPR本文を自動生成します\n")

    return None
```

### テンプレート使用制御

```python
def generate_pr_body_with_template(commit_groups, branch_name, options):
    """PRテンプレートがあれば使用、なければデフォルトフォーマットでPR本文を生成"""

    # テンプレートの存在確認
    template_content = check_pr_template()

    if template_content and not options.get('no_template'):
        # テンプレートが存在する場合、それをベースに情報を埋める
        print("📝 リポジトリのPRテンプレートを使用します")
        return fill_pr_template(template_content, commit_groups, branch_name)
    else:
        # テンプレートがない場合は既存のフォーマットを使用
        if template_content:
            print("⚠️  --no-template オプションによりテンプレートをスキップします")
        return generate_pr_body(commit_groups, branch_name)
```

### オプション

- `--template <path>`: カスタムテンプレートパスを指定
- `--no-template`: テンプレートを使用せずデフォルトフォーマットを強制

## 日本語PR本文生成

### デフォルトフォーマット

テンプレートが存在しない場合、以下のフォーマットで生成します:

```python
def generate_pr_body(commit_groups, branch_name):
    """デフォルトフォーマットでPR本文を生成（日本語）"""

    body = f"""## 概要

"""

    # コミットグループごとのサマリー
    for group in commit_groups:
        emoji = get_emoji_for_type(group['type'])
        body += f"- {emoji} {group['message']}\n"

    body += f"""

## 変更内容

### コミット数 ({len(commit_groups)})
"""

    # 詳細なコミット情報
    for group in commit_groups:
        body += f"\n**{group['type'].title()}**\n"
        for file in group['files'][:5]:  # 最初の5ファイルのみ表示
            body += f"- {file}\n"
        if len(group['files']) > 5:
            body += f"- ... 他 {len(group['files']) - 5} ファイル\n"

    body += """

## テスト計画

- [ ] 既存のテストがすべて成功することを確認
- [ ] フォーマットが適用されていることを確認
- [ ] 機能が正常に動作することを確認

## チェックリスト

- [x] コードフォーマット適用済み
- [ ] テスト追加/更新
- [ ] ドキュメント更新
- [ ] 破壊的変更なし

🤖 Generated with [Claude Code](https://claude.ai/code)
"""

    return body
```

### 絵文字マッピング

```python
def get_emoji_for_type(change_type):
    """変更タイプに対応する絵文字を返す"""

    emojis = {
        'format': '🎨',
        'refactor': '♻️',
        'feature': '✨',
        'fix': '🐛',
        'test': '✅',
        'docs': '📝',
        'config': '🔧',
        'deps': '📦'
    }
    return emojis.get(change_type, '🔨')
```

### 出力例

```markdown
## 概要

- ✨ feat(auth): add login functionality
- ✅ test(auth): update test cases
- 📝 docs: update documentation

## 変更内容

### コミット数 (3)

**Feature**

- src/auth/login.ts
- src/auth/session.ts

**Test**

- tests/auth/login.test.ts

**Docs**

- README.md

## テスト計画

- [ ] 既存のテストがすべて成功することを確認
- [ ] フォーマットが適用されていることを確認
- [ ] 機能が正常に動作することを確認

## チェックリスト

- [x] コードフォーマット適用済み
- [ ] テスト追加/更新
- [ ] ドキュメント更新
- [ ] 破壊的変更なし

🤖 Generated with [Claude Code](https://claude.ai/code)
```

## テンプレート埋め込み

リポジトリ固有のPRテンプレートがある場合、プレースホルダーを自動的に埋め込みます。

### プレースホルダー置換

```python
def fill_pr_template(template_content, commit_groups, branch_name):
    """PRテンプレートに情報を埋め込む"""

    # コミットサマリーの生成
    commit_summary = ""
    for group in commit_groups:
        emoji = get_emoji_for_type(group['type'])
        commit_summary += f"- {emoji} {group['message']}\n"

    # 変更ファイルリストの生成
    all_files = []
    for group in commit_groups:
        all_files.extend(group['files'])

    files_summary = f"変更ファイル数: {len(all_files)}"

    # テンプレート内の一般的なプレースホルダーを置換
    replacements = {
        "<!-- Summary -->": commit_summary,
        "<!-- Description -->": commit_summary,
        "<!-- Changes -->": generate_changes_section(commit_groups),
        "<!-- Testing -->": "- [x] 既存のテストが全て成功することを確認\n- [x] フォーマットが適用されていることを確認",
        "<!-- Checklist -->": "- [x] コードフォーマット適用済み",
        "<!-- Files -->": files_summary,
    }

    result = template_content
    for placeholder, content in replacements.items():
        result = result.replace(placeholder, content)

    # Claude Code署名を追加（テンプレートの最後に）
    if "Generated with" not in result:
        result += "\n\n---\n🤖 Generated with [Claude Code](https://claude.ai/code)"

    return result

def generate_changes_section(commit_groups):
    """変更セクションの詳細を生成"""

    changes = f"### Commits ({len(commit_groups)})\n"

    for group in commit_groups:
        changes += f"\n**{group['type'].title()}**\n"
        for file in group['files'][:5]:
            changes += f"- {file}\n"
        if len(group['files']) > 5:
            changes += f"- ... and {len(group['files']) - 5} more files\n"

    return changes
```

### サポートされるプレースホルダー

| プレースホルダー       | 内容                                   |
| ---------------------- | -------------------------------------- |
| `<!-- Summary -->`     | コミットサマリー（絵文字付き）         |
| `<!-- Description -->` | コミットサマリー（Summaryと同じ）      |
| `<!-- Changes -->`     | 変更詳細（コミット数とファイルリスト） |
| `<!-- Testing -->`     | テスト計画のチェックリスト             |
| `<!-- Checklist -->`   | チェックリスト項目                     |
| `<!-- Files -->`       | 変更ファイル数のサマリー               |

### テンプレート例

### 元のテンプレート

```markdown
## Description

<!-- Summary -->

## Changes

<!-- Changes -->

## Testing

<!-- Testing -->

## Checklist

<!-- Checklist -->
```

### 埋め込み後

```markdown
## Description

- ✨ feat(auth): add login functionality
- ✅ test(auth): update test cases

## Changes

### Commits (2)

**Feature**

- src/auth/login.ts

**Test**

- tests/auth/login.test.ts

## Testing

- [x] 既存のテストが全て成功することを確認
- [x] フォーマットが適用されていることを確認

## Checklist

- [x] コードフォーマット適用済み

---

🤖 Generated with [Claude Code](https://claude.ai/code)
```

## セクション構造

### 概要セクション

### 目的

### 構成

- コミットメッセージの一覧（絵文字付き）
- 変更の意図を簡潔に説明

### 例

```markdown
## 概要

- ✨ feat(auth): add login functionality
- 🐛 fix(validation): resolve input validation issues
- ✅ test(auth): update test cases
```

### 変更内容セクション

### 目的

### 構成

- コミット数の表示
- 変更タイプごとのファイルリスト
- 5ファイルを超える場合は省略表示

### 例

```markdown
## 変更内容

### コミット数 (3)

**Feature**

- src/auth/login.ts
- src/auth/session.ts

**Test**

- tests/auth/login.test.ts

**Docs**

- README.md
```

### テスト計画セクション

### 目的

### 構成

- チェックボックス形式
- 標準的なテスト項目
- 機能固有のテスト項目（必要に応じて）

### 例

```markdown
## テスト計画

- [ ] 既存のテストがすべて成功することを確認
- [ ] フォーマットが適用されていることを確認
- [ ] 機能が正常に動作することを確認
- [ ] ログイン機能の各種シナリオをテスト
```

### チェックリストセクション

### 目的

### 構成

- 自動的にチェック済み: コードフォーマット
- レビュアー確認項目: テスト、ドキュメント、破壊的変更

### 例

```markdown
## チェックリスト

- [x] コードフォーマット適用済み
- [ ] テスト追加/更新
- [ ] ドキュメント更新
- [ ] 破壊的変更なし
```

---

### 参照
