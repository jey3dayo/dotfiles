# PR Format Rules - PRフォーマット規則

PRテンプレート、署名ポリシー、日本語対応の詳細仕様です。

## 日本語対応の原則

### すべてのPR内容は日本語で生成されます。

- PRタイトル: 日本語または英語（コミットメッセージに準拠）
- PR本文: 完全日本語
- セクションヘッダー: 日本語
- チェックリスト項目: 日本語
- 説明文: 日本語

## PRテンプレート検出

### 検出パス

```python
def check_pr_template():
    """PRテンプレートの存在確認"""

    template_paths = [
        ".github/PULL_REQUEST_TEMPLATE.md",
        ".github/pull_request_template.md",
        ".github/PULL_REQUEST_TEMPLATE",
        ".github/PULL_REQUEST_TEMPLATE/default.md",
        "docs/pull_request_template.md",
        "PULL_REQUEST_TEMPLATE.md"
    ]

    for path in template_paths:
        if os.path.exists(path):
            print(f"📋 PRテンプレート検出: {path}")
            with open(path, 'r', encoding='utf-8') as f:
                return f.read()

    print("⚠️  PRテンプレート未検出")
    return None
```

### テンプレート使用判定

```python
def should_use_template(template_content, options):
    """テンプレートを使用すべきか判定"""

    # --no-template オプション
    if options.get('no_template'):
        print("⏩ --no-template: テンプレートをスキップ")
        return False

    # テンプレートが存在しない
    if not template_content:
        return False

    # テンプレートを使用
    return True
```

## デフォルトPRフォーマット

テンプレートがない場合のデフォルト形式（日本語）:

```markdown
## 概要

- {変更サマリー}

## 変更内容

### コミット数 ({N})

**{変更タイプ}**

- {ファイル1}
- {ファイル2}
- ... 他 {N} ファイル

## テスト計画

- [ ] 既存のテストがすべて成功することを確認
- [ ] フォーマットが適用されていることを確認
- [ ] 機能が正常に動作することを確認

## チェックリスト

- [x] コードフォーマット適用済み
- [ ] テスト追加/更新
- [ ] ドキュメント更新
- [ ] 破壊的変更なし
```

### 実装

```python
def generate_pr_body(commit_groups, branch_name):
    """デフォルトフォーマットでPR本文を生成（日本語）"""

    body = "## 概要\n\n"

    # コミットグループごとのサマリー
    for group in commit_groups:
        emoji = get_emoji_for_type(group['type'])
        body += f"- {emoji} {group['message']}\n"

    body += f"\n## 変更内容\n\n### コミット数 ({len(commit_groups)})\n"

    # 詳細なコミット情報
    for group in commit_groups:
        body += f"\n**{group['type'].title()}**\n"
        for file in group['files'][:5]:
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
"""

    return body

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

## PRテンプレート埋め込み

### プレースホルダー検出

```python
def fill_pr_template(template_content, commit_groups, branch_name):
    """PRテンプレートに情報を埋め込む"""

    # コミットサマリー生成
    commit_summary = ""
    for group in commit_groups:
        emoji = get_emoji_for_type(group['type'])
        commit_summary += f"- {emoji} {group['message']}\n"

    # 変更ファイルリスト生成
    all_files = []
    for group in commit_groups:
        all_files.extend(group['files'])

    files_summary = f"変更ファイル数: {len(all_files)}"

    # プレースホルダー置換
    replacements = {
        "<!-- Summary -->": commit_summary,
        "<!-- Description -->": commit_summary,
        "<!-- Changes -->": generate_changes_section(commit_groups),
        "<!-- Testing -->": "- [x] 既存のテストが全て成功することを確認\n- [x] フォーマットが適用されていることを確認",
        "<!-- Checklist -->": "- [x] コードフォーマット適用済み",
        "<!-- Files -->": files_summary,
        "{{SUMMARY}}": commit_summary,
        "{{CHANGES}}": generate_changes_section(commit_groups),
        "{{FILES}}": files_summary
    }

    result = template_content
    for placeholder, content in replacements.items():
        result = result.replace(placeholder, content)

    return result

def generate_changes_section(commit_groups):
    """変更セクションの詳細を生成"""
    changes = f"### コミット数 ({len(commit_groups)})\n"

    for group in commit_groups:
        changes += f"\n**{group['type'].title()}**\n"
        for file in group['files'][:5]:
            changes += f"- {file}\n"
        if len(group['files']) > 5:
            changes += f"- ... 他 {len(group['files']) - 5} ファイル\n"

    return changes
```

## 署名なしポリシー

### 絶対に行わないこと

```python
# ❌ 禁止事項
FORBIDDEN_SIGNATURES = [
    "Co-authored-by: Claude",
    "Generated with Claude Code",
    "AI-assisted",
    "Claude Code Assistant",
    "Automated by AI"
]

def verify_no_signatures(message):
    """署名が含まれていないか確認"""
    for forbidden in FORBIDDEN_SIGNATURES:
        if forbidden.lower() in message.lower():
            raise ValueError(f"Forbidden signature detected: {forbidden}")
```

### 正しいPR本文生成

```python
def generate_pr_body_with_template(commit_groups, branch_name, options):
    """署名なしでPR本文を生成"""

    # テンプレート確認
    template_content = check_pr_template()

    if should_use_template(template_content, options):
        # テンプレート使用
        body = fill_pr_template(template_content, commit_groups, branch_name)
    else:
        # デフォルトフォーマット使用
        body = generate_pr_body(commit_groups, branch_name)

    # 署名検証（安全確認）
    verify_no_signatures(body)

    return body
```

## PRタイトル生成

### 生成ロジック

```python
def generate_pr_title(commit_groups, options):
    """PRタイトルを生成"""

    # ユーザー指定がある場合
    if options.get('title'):
        return options['title']

    # 主要な変更を特定
    primary_changes = []
    for group in commit_groups:
        if group['type'] in ['feature', 'fix']:
            primary_changes.append(group)

    # primary_changesがない場合は全コミット対象
    if not primary_changes:
        primary_changes = commit_groups

    # 単一の主要変更
    if len(primary_changes) == 1:
        return primary_changes[0]['message']

    # 複数の主要変更
    change_types = list(set(g['type'] for g in primary_changes))
    if len(change_types) == 1:
        # 同じタイプ
        return f"{change_types[0]}: multiple updates"
    else:
        # 混合タイプ
        return f"feat: {', '.join(change_types)} updates"
```

### タイトル形式

### 単一変更

```
feat(auth): add login functionality
fix(api): resolve timeout issue
```

### 複数変更（同じタイプ）

```
feat: multiple feature updates
fix: multiple bug fixes
```

### 複数変更（混合タイプ）

```
feat: feature, refactor, test updates
```

## PRオプション統合

### gh コマンド生成

```python
def build_gh_pr_command(pr_title, pr_body, options):
    """gh pr create コマンドを構築"""

    # HEREDOCでボディを渡す
    command = f"""gh pr create --title "{pr_title}" --body "$(cat <<'EOF'
{pr_body}
EOF
)""""

    # オプション追加
    if options.get('base'):
        command += f" --base {options['base']}"

    if options.get('draft'):
        command += " --draft"

    if options.get('reviewers'):
        reviewers = ','.join(options['reviewers'])
        command += f" --reviewer {reviewers}"

    if options.get('assignees'):
        assignees = ','.join(options['assignees'])
        command += f" --assignee {assignees}"

    if options.get('labels'):
        labels = ','.join(options['labels'])
        command += f" --label {labels}"

    if options.get('milestone'):
        command += f" --milestone {options['milestone']}"

    return command
```

## PRテンプレート例

### シンプルテンプレート

```markdown
## 概要

<!-- Summary -->

## 変更内容

<!-- Changes -->

## テスト計画

<!-- Testing -->

## チェックリスト

- [ ] テストが通ることを確認
- [ ] ドキュメント更新
- [ ] レビューを受ける
```

### 詳細テンプレート

```markdown
## 変更概要

<!-- Summary -->

## 変更詳細

<!-- Changes -->

## 変更理由

<!-- なぜこの変更が必要か -->

## 影響範囲

<!-- 影響を受けるコンポーネント -->

## テスト

<!-- Testing -->

### 手動テスト

- [ ] 機能Aを確認
- [ ] 機能Bを確認

### 自動テスト

- [ ] 既存テスト成功
- [ ] 新規テスト追加

## スクリーンショット

<!-- 必要に応じて追加 -->

## チェックリスト

- [ ] コードレビュー依頼
- [ ] ドキュメント更新
- [ ] CHANGELOG更新
- [ ] 破壊的変更の文書化
```

## 特殊なPRタイプ

### ドラフトPR

```bash
/git-automation pr --draft

# 生成されるコマンド
gh pr create --title "..." --body "..." --draft
```

### ベースブランチ指定

```bash
/git-automation pr --base develop

# 生成されるコマンド
gh pr create --title "..." --body "..." --base develop
```

### レビュアー指定

```bash
/git-automation pr --reviewers user1,user2

# 生成されるコマンド
gh pr create --title "..." --body "..." --reviewer user1,user2
```

## エラーハンドリング

### テンプレート読み込み失敗

```python
try:
    with open(template_path, 'r', encoding='utf-8') as f:
        return f.read()
except Exception as e:
    print(f"⚠️  テンプレート読み込みエラー: {e}")
    print("💡 デフォルトフォーマットを使用します")
    return None
```

### プレースホルダー未置換の検出

```python
def warn_unreplaced_placeholders(pr_body):
    """未置換のプレースホルダーを警告"""
    placeholders = re.findall(r'<!--\s*\w+\s*-->|\{\{[A-Z_]+\}\}', pr_body)

    if placeholders:
        print("⚠️  以下のプレースホルダーが未置換です:")
        for placeholder in placeholders:
            print(f"   - {placeholder}")
```

## ベストプラクティス

### テンプレートの準備

```bash
# プロジェクトにテンプレートを作成
mkdir -p .github
cat > .github/PULL_REQUEST_TEMPLATE.md <<'EOF'
## 概要

<!-- Summary -->

## 変更内容

<!-- Changes -->

## テスト計画

<!-- Testing -->

## チェックリスト

- [ ] テスト成功
- [ ] ドキュメント更新
EOF
```

### テンプレートの検証

```bash
# テンプレートが正しく検出されるか確認
/git-automation pr --check-only
```

### カスタムテンプレート使用

```bash
# 特定のテンプレートを指定
/git-automation pr --template .github/PULL_REQUEST_TEMPLATE/feature.md
```

## 制約事項

- PRテンプレートはMarkdown形式のみ対応
- テンプレート内のスクリプトは実行されません
- プレースホルダーは静的置換のみ
- 絵文字の使用はユーザー設定（CLAUDE.md）で制御可能
