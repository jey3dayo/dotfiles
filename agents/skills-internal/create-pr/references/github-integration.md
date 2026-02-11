# GitHub Integration - GitHub CLI統合とIssue連携

Phase 3.5とPhase 3.7: 既存PR検出、更新、GitHub Issue自動リンクの完全な仕様。

## Table of Contents

- [概要](#概要)
- [Phase 3.5: 既存PR検出と更新](#phase-35-既存pr検出と更新)
- [Phase 3.7: Issue検出とリンキング](#phase-37-issue検出とリンキング)
- [gh CLI統合](#gh-cli統合)
- [エラーハンドリング](#エラーハンドリング)

## 概要

GitHub統合は、GitHub CLI (`gh`) を使用してPRとIssueを操作します。

### 目的

- 既存PRの検出と重複作成防止
- 既存PRの更新による柔軟なワークフロー
- Issue参照の自動検出とPRへのリンク
- GitHub APIの効率的な利用

### 必須ツール

## Phase 3.5: 既存PR検出と更新

### 既存PR検出

```python
def check_existing_pr(branch_name):
    """現在のブランチに既存のPRがあるか確認"""

    print(f"🔍 既存PRを確認中: {branch_name}")

    try:
        result = subprocess.run(
            ["gh", "pr", "list", "--head", branch_name, "--json", "number,title,url,state"],
            capture_output=True,
            text=True
        )

        if result.returncode == 0 and result.stdout.strip():
            prs = json.loads(result.stdout)
            if prs:
                # OPENまたはDRAFTのPRのみを対象
                open_prs = [pr for pr in prs if pr['state'] in ['OPEN', 'DRAFT']]
                if open_prs:
                    return open_prs[0]  # 最初の（最新の）PRを返す

        return None

    except Exception as e:
        print(f"⚠️  PR確認エラー: {e}")
        return None
```

### 検出条件

- ブランチ名一致: `--head <branch_name>`
- 状態フィルター: `OPEN` または `DRAFT` のみ
- 最新PR優先: 複数PRがある場合は最初の1つ

### 対応方針決定

```python
def decide_pr_action(existing_pr, options):
    """既存PRに対する対応方針を決定"""

    # --check-only: 確認のみ
    if options.get('check_only'):
        if existing_pr:
            print(f"ℹ️  既存PR: #{existing_pr['number']} - {existing_pr['title']}")
            print(f"   URL: {existing_pr['url']}")
            print(f"   状態: {existing_pr['state']}")
        else:
            print("ℹ️  既存PRなし")
        return 'abort'

    # --force-new: 強制新規作成
    if options.get('force_new'):
        print("🆕 --force-new オプション: 新規PR作成を実行")
        return 'create'

    # 既存PRがない場合は新規作成
    if not existing_pr:
        return 'create'

    # 既存PRがある場合
    print(f"\nℹ️  既存のPR検出:")
    print(f"   #{existing_pr['number']}: {existing_pr['title']}")
    print(f"   URL: {existing_pr['url']}")
    print(f"   状態: {existing_pr['state']}")

    # --update-if-exists: 自動更新
    if options.get('update_if_exists'):
        print("🔄 --update-if-exists オプション: PR更新を実行")
        return 'update'

    # 対話的に選択
    print("\n既存のPRが見つかりました。どうしますか？")
    print("1. 更新 - 既存PRのタイトルと本文を更新")
    print("2. 新規作成 - 新しいPRを作成")
    print("3. キャンセル - 処理を中止")

    choice = prompt_choice("選択してください (1-3): ", ["1", "2", "3"])

    if choice == "1":
        return 'update'
    elif choice == "2":
        return 'create'
    else:
        return 'abort'
```

### アクション

- `abort`: 処理を中止（`--check-only` または ユーザーキャンセル）
- `create`: 新規PR作成（既存PRなし、`--force-new`、またはユーザー選択）
- `update`: 既存PR更新（`--update-if-exists` またはユーザー選択）

### PR更新

```python
def update_pull_request(pr_number, pr_title, pr_body, options):
    """既存のPRのタイトルと本文を更新"""

    print(f"📝 PR #{pr_number} を更新中...")

    # HEREDOCを使用してボディを渡す
    update_command = f"""gh pr edit {pr_number} --title "{pr_title}" --body "$(cat <<'EOF'
{pr_body}
EOF
)""""

    try:
        result = subprocess.run(
            update_command,
            shell=True,
            capture_output=True,
            text=True
        )

        if result.returncode == 0:
            # PR URLを取得
            pr_info = subprocess.run(
                ["gh", "pr", "view", str(pr_number), "--json", "url"],
                capture_output=True,
                text=True
            )

            if pr_info.returncode == 0:
                pr_data = json.loads(pr_info.stdout)
                pr_url = pr_data.get('url', '')
                print(f"✅ PR #{pr_number} の更新完了")
                print(f"   URL: {pr_url}")
                return pr_url
            else:
                print(f"✅ PR #{pr_number} の更新完了")
                return f"https://github.com/.../pull/{pr_number}"
        else:
            print(f"❌ PR更新エラー: {result.stderr}")
            return None

    except Exception as e:
        print(f"❌ PR更新例外: {e}")
        return None
```

### 更新内容

- PRタイトル: `--title`
- PR本文: `--body` (HEREDOC使用)
- 保持されるもの: ラベル、レビュアー、マイルストーン、アサイニー

## Phase 3.7: Issue検出とリンキング

### Issue番号抽出

#### ブランチ名から抽出

```python
def extract_issues_from_branch_name(branch_name):
    """ブランチ名からIssue番号を抽出

    対応パターン:
    - feat/123-description
    - fix/issue-456-bug
    - feature/GH-789-...
    - bugfix/#123-...
    """
    import re

    patterns = [
        r'(?:^|/)#?(\d+)(?:-|$)',           # feat/123-description or fix/#123
        r'(?:^|/)issue-(\d+)',               # fix/issue-456
        r'(?:^|/)GH-(\d+)',                  # feature/GH-789
    ]

    issues = []
    for pattern in patterns:
        matches = re.findall(pattern, branch_name)
        issues.extend([int(m) for m in matches])

    # 重複を削除して返す
    return list(set(issues))
```

### 対応パターン

- `feat/123-description` → `123`
- `fix/issue-456-bug` → `456`
- `feature/GH-789-...` → `789`
- `bugfix/#123-...` → `123`

#### コミットメッセージから抽出

```python
def extract_issues_from_commits(commit_groups):
    """コミットメッセージからIssue参照を抽出

    対応パターン: #123, fixes #123, closes #456, resolves #789
    """
    import re

    patterns = [
        r'(?:fixes?|closes?|resolves?)\s+#(\d+)',  # fixes #123
        r'(?:^|\s)#(\d+)(?:\s|$)',                  # #123
    ]

    issues = []
    for group in commit_groups:
        message = group.get('message', '')

        for pattern in patterns:
            matches = re.findall(pattern, message, re.IGNORECASE)
            issues.extend([int(m) for m in matches])

    # 重複を削除して返す
    return list(set(issues))
```

### 対応パターン

- `#123` → `123`
- `fixes #123` → `123`
- `closes #456` → `456`
- `resolves #789` → `789`

### Issue検証

```python
def validate_issues(issue_numbers, options={}):
    """gh issue view でIssueの存在・状態を確認

    Returns: {"valid": [...], "invalid": [...], "closed": [...]}
    """
    import subprocess
    import json

    validation_results = {
        "valid": [],      # オープンで有効なIssue
        "invalid": [],    # 存在しないIssue
        "closed": []      # クローズ済みIssue
    }

    if not issue_numbers:
        return validation_results

    print(f"🔍 {len(issue_numbers)} 件のIssueを検証中...")

    for issue_num in issue_numbers:
        try:
            result = subprocess.run(
                ["gh", "issue", "view", str(issue_num), "--json", "number,title,state,url"],
                capture_output=True,
                text=True
            )

            if result.returncode == 0:
                issue_data = json.loads(result.stdout)

                if issue_data['state'] == 'OPEN':
                    validation_results['valid'].append(issue_data)
                    print(f"  ✅ #{issue_num}: {issue_data['title']}")
                else:
                    validation_results['closed'].append(issue_data)
                    print(f"  ⚠️  #{issue_num}: {issue_data['title']} (クローズ済み)")
            else:
                validation_results['invalid'].append(issue_num)
                print(f"  ❌ #{issue_num}: Issue が見つかりません")

        except Exception as e:
            print(f"  ❌ #{issue_num}: 検証エラー ({e})")
            validation_results['invalid'].append(issue_num)

    return validation_results
```

### 検証結果

- `valid`: オープン状態のIssue（リンク可能）
- `invalid`: 存在しないIssue（除外）
- `closed`: クローズ済みIssue（警告表示、リンク可能）

### Issue選択

#### 対話的選択

```python
def prompt_issue_selection(validation_results, options={}):
    """ユーザーにリンクするIssueとキーワードを選択させる"""

    valid_issues = validation_results.get('valid', [])
    closed_issues = validation_results.get('closed', [])
    invalid_issues = validation_results.get('invalid', [])

    if not valid_issues and not closed_issues:
        print("\n⚠️  リンク可能なIssueが見つかりませんでした")
        return []

    print("\n📎 Issue リンク選択\n")

    # オープンIssue一覧
    if valid_issues:
        print("📂 オープンIssue:")
        for i, issue in enumerate(valid_issues, 1):
            print(f"  [{i}] #{issue['number']}: {issue['title']}")

    # クローズ済みIssue一覧
    if closed_issues:
        print("\n🔒 クローズ済みIssue:")
        for issue in closed_issues:
            print(f"  #{issue['number']}: {issue['title']}")

    # 無効なIssue一覧
    if invalid_issues:
        print("\n❌ 無効なIssue:")
        for issue_num in invalid_issues:
            print(f"  #{issue_num}")

    # 選択プロンプト
    print("\nどのIssueをPRにリンクしますか？")
    print("  [a] すべてのオープンIssue")
    print("  [番号] 特定のIssue（カンマ区切りで複数指定可能）")
    print("  [n] リンクしない")

    choice = input("\n選択: ").strip().lower()

    if choice == 'n':
        print("⏭️  Issue リンクをスキップします")
        return []

    selected_issues = []

    if choice == 'a':
        selected_issues = valid_issues
    else:
        # 番号を解析
        try:
            indices = [int(x.strip()) for x in choice.split(',')]
            for idx in indices:
                if 1 <= idx <= len(valid_issues):
                    selected_issues.append(valid_issues[idx - 1])
                else:
                    print(f"⚠️  無効な番号: {idx}")
        except ValueError:
            print("❌ 無効な入力です")
            return []

    if not selected_issues:
        return []

    # リンクキーワードの選択
    default_keyword = options.get('issue_keyword', 'Fixes')

    print(f"\nリンクキーワードを選択してください（デフォルト: {default_keyword}）:")
    print("  1. Fixes")
    print("  2. Closes")
    print("  3. Resolves")
    print("  4. Related to")

    keyword_choice = input(f"\n選択 (1-4, Enter で{default_keyword}): ").strip()

    keywords = {
        '1': 'Fixes',
        '2': 'Closes',
        '3': 'Resolves',
        '4': 'Related to',
        '': default_keyword
    }

    keyword = keywords.get(keyword_choice, default_keyword)

    # 選択結果を返す
    return [{'issue': issue, 'keyword': keyword} for issue in selected_issues]
```

#### 自動選択

```python
def auto_link_issues(validation_results, options={}):
    """--auto-link オプション: すべてのオープンIssueを自動リンク"""

    valid_issues = validation_results.get('valid', [])

    if not valid_issues:
        print("\n⚠️  リンク可能なオープンIssueが見つかりませんでした")
        return []

    print("\n🔗 --auto-link オプション: オープンIssueを自動リンク")
    default_keyword = options.get('issue_keyword', 'Fixes')

    linked_issues = []
    for issue in valid_issues:
        linked_issues.append({'issue': issue, 'keyword': default_keyword})
        print(f"  ✅ #{issue['number']}: {issue['title']}")

    return linked_issues
```

### PR本文への追加

```python
def add_issue_references_to_body(pr_body, linked_issues):
    """PR本文に '## 関連Issue' セクションを追加"""

    if not linked_issues:
        return pr_body

    # Issue参照セクションを生成
    issue_section = "\n## 関連Issue\n\n"

    for item in linked_issues:
        issue = item['issue']
        keyword = item['keyword']
        issue_section += f"- {keyword} #{issue['number']} - {issue['title']}\n"

    # PR本文の「## 概要」セクションの直後に挿入
    if "## 概要" in pr_body:
        parts = pr_body.split("## 概要", 1)
        if len(parts) == 2:
            # 「## 概要」の内容を取得
            summary_and_rest = parts[1].split("\n\n", 1)

            if len(summary_and_rest) == 2:
                summary = summary_and_rest[0]
                rest = summary_and_rest[1]

                # Issue参照を挿入
                pr_body = parts[0] + "## 概要" + summary + issue_section + "\n" + rest
            else:
                # 「## 概要」の後にコンテンツがない場合
                pr_body = parts[0] + "## 概要" + parts[1] + issue_section
    else:
        # 「## 概要」セクションがない場合は先頭に追加
        pr_body = issue_section + "\n" + pr_body

    return pr_body
```

### 挿入位置

### 出力例

```markdown
## 概要

- ✨ feat(auth): add login functionality

## 関連Issue

- Fixes #123 - ログイン時のタイムアウトエラー
- Related to #124 - セッション管理の改善

## 変更内容

...
```

## gh CLI統合

### 必須コマンド

- `gh pr list`: PR一覧取得
- `gh pr view`: PR詳細取得
- `gh pr create`: PR作成
- `gh pr edit`: PR更新
- `gh issue view`: Issue詳細取得

### 認証確認

```python
def check_gh_auth():
    """gh CLI認証状態を確認"""

    try:
        result = subprocess.run(
            ["gh", "auth", "status"],
            capture_output=True,
            text=True
        )

        if result.returncode == 0:
            print("✅ GitHub CLI認証済み")
            return True
        else:
            print("❌ GitHub CLI認証が必要です")
            print("💡 `gh auth login` を実行してください")
            return False

    except FileNotFoundError:
        print("❌ GitHub CLI (gh) がインストールされていません")
        print("💡 https://cli.github.com/ からインストールしてください")
        return False
```

## エラーハンドリング

### PR検出エラー

```python
# エラー例: gh command not found
try:
    result = subprocess.run(["gh", "pr", "list", ...])
except FileNotFoundError:
    print("❌ GitHub CLI (gh) がインストールされていません")
    print("💡 インストール: https://cli.github.com/")
    print("   または --force-new で既存PRチェックをスキップ")
```

### PR更新エラー

```python
# エラー例: PR not found
if result.returncode != 0:
    print(f"❌ PR更新エラー: {result.stderr}")
    print("\n考えられる原因:")
    print("- PRが既にクローズまたはマージされている")
    print("- PR番号が間違っている")
    print("- リポジトリのアクセス権限がない")
    print("\n推奨アクション:")
    print("- gh pr list で現在のPR一覧を確認")
    print("- 新規PRを作成する場合は --force-new を使用")
```

### Issue検証エラー

```python
# エラー例: Issue not found
if result.returncode != 0:
    validation_results['invalid'].append(issue_num)
    print(f"  ❌ #{issue_num}: Issue が見つかりません")

# 推奨アクション
if validation_results['invalid']:
    print("\n⚠️  無効なIssue参照が検出されました")
    print("💡 ブランチ名またはコミットメッセージのIssue番号を確認してください")
    print("   または --no-link-issues でこのフェーズをスキップ")
```

---

### 参照
