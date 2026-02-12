---
description: Automatic format, commit, and GitHub PR creation system
argument-hint: [options]
---

> ⚠️ **DEPRECATED**: このコマンドは廃止予定です。
>
> **移行先**: `git-automation` スキル (`~/.claude/skills/git-automation/`)
>
> 新しいスキルは以下の機能を提供します：
>
> - Auto PR: Format→Commit→Push→PR作成/更新の統合フロー
> - 既存PR検出と自動更新（重複防止）
> - 品質ゲート（Lint/Test/Build）
> - 日本語完全対応のPRテンプレート
>
> **Phase 3で移行完了** (2026-02-12)

# Create PR - 自動フォーマット・コミット・PR作成システム

プロジェクトのフォーマッターを自動検出し、コード整形・適切なコミット分割・GitHub PR作成を一括実行する統合コマンドです。

## 🇯🇵 重要: 日本語設定

**このコマンドで生成されるすべてのPR（プルリクエスト）の内容は日本語で作成されます。**

- PRタイトル（コミットメッセージは英語でも、PR説明は日本語）
- PR本文のセクションヘッダー（概要、変更内容、テスト計画、チェックリスト）
- すべての説明文とチェックリスト項目

## 🔗 共通ユーティリティの活用

このコマンドは以下の共通ユーティリティを活用しています：

- **`shared/project-detector.md`**: フォーマッター検出ロジック
- **`shared/task-context.md`**: 統一タスクコンテキスト

## 🚀 実装された機能

このコマンドは以下の自動化機能を提供します：

1. **フォーマッター自動検出**: npm/pnpm/yarn/Go等のプロジェクト判定
2. **コード自動整形**: 検出されたフォーマッターの実行
3. **インテリジェントコミット**: 変更内容を適切な粒度で分割
4. **既存PR検出**: 同じブランチに既存のPRがあるかを自動確認
5. **PR自動作成/更新**: 既存PRがあれば更新、なければ新規作成

## 🎯 特徴

- **プロジェクト自動判定**: package.json/go.mod等から技術スタックを検出
- **フォーマッター統合**: Prettier/gofmt/black等の主要ツール対応
- **スマートコミット分割**: 変更の意味的まとまりを解析
- **既存PR自動検出**: `gh pr list`で既存PRを確認し、重複作成を防止
- **PR柔軟更新**: 既存PRのタイトル・本文を最新のコミットに基づいて更新
- **対話的/自動モード**: ユーザー確認またはオプションで自動実行
- **PR説明自動生成**: コミット内容からサマリーとテスト計画を作成
- **PRテンプレート自動検出**: `.github/PULL_REQUEST_TEMPLATE.md`等を自動で使用
- **エラーハンドリング**: フォーマッター未設定時の適切な処理
- **日本語対応**: PR本文は必ず日本語で生成（タイトル、説明、チェックリスト等すべて）

## 使用方法

### 基本使用

```bash
# 自動検出・実行
/create-pr

# PR タイトル指定
/create-pr "feat: ユーザー認証機能の追加"

# ブランチ指定
/create-pr --branch feature/auth

# ドラフトPR作成
/create-pr --draft
```

### オプション

```bash
# フォーマット処理スキップ
/create-pr --no-format

# 単一コミットで作成
/create-pr --single-commit

# ベースブランチ指定
/create-pr --base develop

# カスタムPRテンプレート使用
/create-pr --template .github/PULL_REQUEST_TEMPLATE/feature.md

# PRテンプレートを使用しない（デフォルトフォーマットを強制）
/create-pr --no-template

# 既存PR対応オプション
/create-pr --update-if-exists    # 既存PRがあれば自動的に更新
/create-pr --force-new           # 既存PRチェックをスキップして強制新規作成
/create-pr --check-only          # 既存PRの確認のみ（作成/更新なし）
```

## 📋 実行フロー

### Phase 1: プロジェクト判定・フォーマッター検出

プロジェクトの技術スタックを自動判定し、適切なフォーマッターを選択：

```python
def detect_project_formatter():
    """プロジェクトのフォーマッターを自動検出"""

    # 共通ユーティリティを使用
    from .shared.project_detector import detect_formatter
    from .shared.task_context import TaskContext

    # TaskContextを作成
    context = TaskContext(
        task_description="PR作成のためのフォーマット実行",
        source="/create-pr"
    )

    # フォーマッター検出
    formatters = detect_formatter()

    if formatters:
        # 最初の（最も信頼度の高い）フォーマッターを使用
        formatter_info = formatters[0]

        # プロジェクトの技術スタックに基づいて適切なコマンドを構築
        if "node" in context.project["stack"]:
            # パッケージマネージャーを検出して使用
            pkg_manager = detect_package_manager()
            if formatter_info["type"] == "script":
                return f"{pkg_manager} run {formatter_info['command']}"
            else:
                return f"{pkg_manager} exec {formatter_info['command']}"
        else:
            # その他の言語はそのままコマンドを使用
            return formatter_info["command"]

    return None

def detect_package_manager():
    """Node.js パッケージマネージャーを検出"""
    # 共通ユーティリティの情報も活用可能
    from .shared.project_detector import detect_project_type

    project_info = detect_project_type()

    # project_infoに含まれるパッケージマネージャー情報を使用
    if "pnpm" in project_info.get("package_manager", ""):
        return "pnpm"
    elif "yarn" in project_info.get("package_manager", ""):
        return "yarn"
    elif "bun" in project_info.get("package_manager", ""):
        return "bun"
    else:
        return "npm"
```

### Phase 2: フォーマット実行・変更確認

検出されたフォーマッターを実行し、変更内容を確認：

```python
def execute_formatting(formatter_command, options):
    """フォーマッターを実行"""

    if options.get('no_format'):
        print("📝 フォーマット処理をスキップします")
        return True

    if not formatter_command:
        print("⚠️  フォーマッターが検出されませんでした")
        print("💡 ヒント: package.json に format スクリプトを追加してください")

        # 対話的サポート
        if prompt_yes_no("手動でフォーマットコマンドを指定しますか？"):
            formatter_command = prompt_input("フォーマットコマンド: ")
        else:
            return True  # スキップして続行

    print(f"🎨 フォーマット実行: {formatter_command}")

    try:
        # フォーマッター実行
        result = subprocess.run(
            formatter_command.split(),
            capture_output=True,
            text=True
        )

        if result.returncode == 0:
            print("✅ フォーマット完了")

            # 変更確認
            changed_files = get_git_status()
            if changed_files:
                print(f"📝 {len(changed_files)} ファイルが変更されました")

            return True
        else:
            print(f"❌ フォーマットエラー: {result.stderr}")
            return False

    except Exception as e:
        print(f"❌ 実行エラー: {e}")
        return False
```

### Phase 3: インテリジェントコミット分割

変更内容を解析し、意味的なまとまりごとにコミットを作成：

```python
def create_intelligent_commits(options):
    """変更を適切な粒度でコミット"""

    if options.get('single_commit'):
        # 単一コミットモード
        return create_single_commit()

    # 1. 変更ファイルの分類
    changes = analyze_changes()
    commit_groups = []

    # 2. 変更タイプごとにグループ化
    groups = {
        'format': [],      # フォーマットのみの変更
        'refactor': [],    # リファクタリング
        'feature': [],     # 機能追加
        'fix': [],         # バグ修正
        'test': [],        # テスト
        'docs': [],        # ドキュメント
        'config': [],      # 設定ファイル
        'deps': []         # 依存関係
    }

    for file, diff in changes.items():
        change_type = classify_change(file, diff)
        groups[change_type].append(file)

    # 3. グループごとにコミット作成
    for change_type, files in groups.items():
        if not files:
            continue

        # コミットメッセージ生成
        message = generate_commit_message(change_type, files)

        # ファイルをステージング
        for file in files:
            subprocess.run(["git", "add", file])

        # コミット作成
        commit_with_co_author(message)
        commit_groups.append({
            'type': change_type,
            'files': files,
            'message': message
        })

    return commit_groups

def classify_change(filepath, diff_content):
    """変更内容から変更タイプを分類"""

    # ファイルパスベースの分類
    if "test" in filepath or "spec" in filepath:
        return 'test'
    elif filepath.endswith(('.md', '.txt', '.rst')):
        return 'docs'
    elif filepath in ['package.json', 'go.mod', 'requirements.txt', 'Cargo.toml']:
        return 'deps'
    elif filepath.startswith('.') or 'config' in filepath:
        return 'config'

    # diff内容ベースの分類
    if is_formatting_only_change(diff_content):
        return 'format'
    elif has_bug_fix_indicators(diff_content):
        return 'fix'
    elif has_refactoring_indicators(diff_content):
        return 'refactor'
    else:
        return 'feature'

def generate_commit_message(change_type, files):
    """変更タイプとファイルからコミットメッセージを生成"""

    templates = {
        'format': "style: apply code formatting",
        'refactor': "refactor: improve code structure",
        'feature': "feat: add new functionality",
        'fix': "fix: resolve issues",
        'test': "test: update test cases",
        'docs': "docs: update documentation",
        'config': "chore: update configuration",
        'deps': "chore: update dependencies"
    }

    base_message = templates.get(change_type, "chore: update files")

    # ファイル情報を追加
    if len(files) == 1:
        scope = extract_scope(files[0])
        return f"{change_type}({scope}): {extract_action(files[0])}"
    elif len(files) <= 3:
        return f"{base_message} in {', '.join(files)}"
    else:
        return f"{base_message} ({len(files)} files)"

def commit_with_co_author(message):
    """Co-Author情報付きでコミット"""
    full_message = f"""$(cat <<'EOF'
{message}

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"""

    subprocess.run(["git", "commit", "-m", full_message])
```

### Phase 3.5: 既存PR検出と対応方針決定

コミット作成後、PRの作成/更新を判断：

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

def handle_existing_pr_workflow(commit_groups, options):
    """既存PR検出とアクション決定のワークフロー"""

    # 現在のブランチ確認
    current_branch = get_current_branch()

    # 既存PR確認
    existing_pr = check_existing_pr(current_branch)

    # 対応方針決定
    action = decide_pr_action(existing_pr, options)

    return action, existing_pr, current_branch
```

### Phase 4: GitHub PR 作成または更新

既存PR検出結果に基づいてPRを作成または更新：

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

def create_new_pull_request(commit_groups, current_branch, options):
    """新規PRを作成"""

    # 1. ブランチ確認と作成
    if current_branch in ['main', 'master', 'develop']:
        # 新規ブランチ作成
        if not options.get('branch'):
            branch_name = generate_branch_name(commit_groups)
            subprocess.run(["git", "checkout", "-b", branch_name])
            current_branch = branch_name

    # 2. リモートへプッシュ
    print("📤 変更をプッシュ中...")
    push_result = subprocess.run(
        ["git", "push", "-u", "origin", current_branch],
        capture_output=True
    )

    if push_result.returncode != 0:
        print("❌ プッシュに失敗しました")
        return None

    # 3. PR情報生成
    pr_title = generate_pr_title(commit_groups, options)
    pr_body = generate_pr_body_with_template(commit_groups, current_branch, options)

    # 4. gh コマンドでPR作成
    pr_command_str = f"""gh pr create --title "{pr_title}" --body "$(cat <<'EOF'
{pr_body}
EOF
)" """

    if options.get('base'):
        pr_command_str += f"--base {options['base']} "

    if options.get('draft'):
        pr_command_str += "--draft "

    # PR作成実行
    result = subprocess.run(
        pr_command_str,
        shell=True,
        capture_output=True,
        text=True
    )

    if result.returncode == 0:
        pr_url = result.stdout.strip()
        print(f"✅ PR作成完了: {pr_url}")
        return pr_url
    else:
        print(f"❌ PR作成エラー: {result.stderr}")
        return None

def create_or_update_pull_request(commit_groups, options):
    """既存PRがあれば更新、なければ作成"""

    # Phase 3.5: 既存PR検出と対応方針決定
    action, existing_pr, current_branch = handle_existing_pr_workflow(commit_groups, options)

    # アクションに応じた処理
    if action == 'abort':
        print("❌ 処理を中止しました")
        return None

    elif action == 'update':
        # PR情報を生成
        pr_title = generate_pr_title(commit_groups, options)
        pr_body = generate_pr_body_with_template(commit_groups, current_branch, options)

        # リモートへプッシュ（既存コミットを更新）
        print("📤 変更をプッシュ中...")
        push_result = subprocess.run(
            ["git", "push", "origin", current_branch],
            capture_output=True
        )

        if push_result.returncode != 0:
            print("❌ プッシュに失敗しました")
            return None

        # PRを更新
        return update_pull_request(existing_pr['number'], pr_title, pr_body, options)

    elif action == 'create':
        # 新規PR作成
        return create_new_pull_request(commit_groups, current_branch, options)

def generate_pr_title(commit_groups, options):
    """PRタイトルを生成"""

    if options.get('title'):
        return options['title']

    # コミットグループから主要な変更を特定
    primary_changes = []
    for group in commit_groups:
        if group['type'] in ['feature', 'fix']:
            primary_changes.append(group)

    if not primary_changes:
        primary_changes = commit_groups

    # タイトル生成
    if len(primary_changes) == 1:
        return primary_changes[0]['message']
    else:
        change_types = list(set(g['type'] for g in primary_changes))
        return f"feat: {', '.join(change_types)} updates"

def check_pr_template():
    """PRテンプレートの存在確認と内容取得（改善版）"""

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

## 既存PR対応の使用例

### 既存PRがある場合の対話的処理

```bash
/create-pr

# 実行結果:
# 🔍 既存PRを確認中: feat/fix-components
# ℹ️  既存のPR検出:
#    #414: Fix component validation
#    URL: https://github.com/org/repo/pull/414
#    状態: OPEN
#
# 既存のPRが見つかりました。どうしますか？
# 1. 更新 - 既存PRのタイトルと本文を更新
# 2. 新規作成 - 新しいPRを作成
# 3. キャンセル - 処理を中止
# 選択してください (1-3): 1
#
# 📤 変更をプッシュ中...
# 📝 PR #414 を更新中...
# ✅ PR #414 の更新完了
#    URL: https://github.com/org/repo/pull/414
```

### 既存PRの自動更新

```bash
# 確認なしで自動的に更新
/create-pr --update-if-exists

# 実行結果:
# 🔍 既存PRを確認中: feat/fix-components
# 🔄 --update-if-exists オプション: PR更新を実行
# 📤 変更をプッシュ中...
# 📝 PR #414 を更新中...
# ✅ PR #414 の更新完了
```

### 既存PRをスキップして強制新規作成

```bash
# 既存PRチェックをスキップ
/create-pr --force-new

# 実行結果:
# 🆕 --force-new オプション: 新規PR作成を実行
# 📤 変更をプッシュ中...
# ✅ PR作成完了: https://github.com/org/repo/pull/415
```

### 既存PRの確認のみ

```bash
# PRの作成/更新を行わず確認のみ
/create-pr --check-only

# 実行結果（既存PRあり）:
# 🔍 既存PRを確認中: feat/fix-components
# ℹ️  既存PR: #414 - Fix component validation
#    URL: https://github.com/org/repo/pull/414
#    状態: OPEN

# 実行結果（既存PRなし）:
# 🔍 既存PRを確認中: feat/new-feature
# ℹ️  既存PRなし
```

## 高度な機能

### インタラクティブモード

```bash
# 対話的にオプションを選択
/create-pr --interactive

# コミット前に確認
/create-pr --confirm

# ドライラン（実行内容の確認のみ）
/create-pr --dry-run
```

### カスタマイズ

```bash
# カスタムフォーマッター指定
/create-pr --formatter "deno fmt"

# コミット規約指定
/create-pr --convention conventional

# PR テンプレート選択
/create-pr --template feature
```

### CI/CD 統合

```bash
# CI チェック待機
/create-pr --wait-for-checks

# 自動マージ設定
/create-pr --auto-merge

# レビュアー自動割当
/create-pr --reviewers @team
```

## プロジェクトタイプ別の動作

### JavaScript/TypeScript

```bash
/create-pr
# 検出: package.json → npm/pnpm/yarn run format
# 実行: Prettier によるフォーマット
```

### Go

```bash
/create-pr
# 検出: go.mod → go fmt or gofumpt
# 実行: Go標準フォーマット
```

### Python

```bash
/create-pr
# 検出: pyproject.toml → black/ruff
# 実行: PEP8準拠フォーマット
```

### Multi-Language

```bash
/create-pr
# 検出: 複数の設定ファイル
# 実行: 各言語に適したフォーマッター連続実行
```

## エラーハンドリング

### フォーマッター未検出時

```
⚠️  フォーマッターが検出されませんでした

推奨アクション:
1. package.json に "format" スクリプトを追加
2. 手動でフォーマッターを指定
3. フォーマットをスキップして続行

選択してください (1-3): _
```

### コミット分割失敗時

```
⚠️  変更の自動分類に失敗しました

フォールバック:
- 全変更を単一コミットとして作成
- 手動でコミット分割を実行

続行しますか？ (y/n): _
```

### 既存PR検出エラー時

```
⚠️  PR確認エラー: gh command not found

推奨アクション:
1. GitHub CLI (gh) をインストール
2. gh auth login で認証を完了
3. --force-new で既存PRチェックをスキップ

続行方法: /create-pr --force-new
```

### PR更新失敗時

```
❌ PR更新エラー: GraphQL: Could not resolve to a PullRequest with the number of 414.

考えられる原因:
- PRが既にクローズまたはマージされている
- PR番号が間違っている
- リポジトリのアクセス権限がない

推奨アクション:
- gh pr list で現在のPR一覧を確認
- 新規PRを作成する場合は --force-new を使用
```

## メイン実行フロー

```python
def execute_create_pr(options):
    """create-prコマンドのメイン実行関数"""

    # 共通ユーティリティをインポート
    from .shared.task_context import TaskContext, save_context
    from .shared.project_detector import detect_project_type

    # TaskContextを作成
    context = TaskContext(
        task_description="自動フォーマット・コミット・PR作成",
        source="/create-pr"
    )

    try:
        # Phase 1: フォーマッター検出
        formatter_command = detect_project_formatter()
        context.communication["shared_data"]["formatter"] = formatter_command

        # Phase 2: フォーマット実行
        if execute_formatting(formatter_command, options):
            context.metrics["formatting_status"] = "success"
        else:
            context.metrics["formatting_status"] = "skipped"

        # Phase 3: コミット作成
        commit_groups = create_intelligent_commits(options)
        context.communication["shared_data"]["commits"] = commit_groups
        context.metrics["commit_count"] = len(commit_groups)

        # Phase 3.5 & 4: 既存PR検出 → PR作成または更新
        pr_url = create_or_update_pull_request(commit_groups, options)
        context.communication["shared_data"]["pr_url"] = pr_url

        # 成功時の処理
        context.metrics["end_time"] = timestamp()
        context.metrics["status"] = "success" if pr_url else "partial_success"

        # コンテキストの保存
        save_context(context)

        return pr_url, context

    except Exception as e:
        context.metrics["status"] = "failed"
        context.metrics["error"] = str(e)
        save_context(context)
        raise
```

## 関連コマンド

- **/review** - PR作成前のコードレビュー
- **/todos** - PR作成後のタスク管理
- **/fix** - フォーマット以外の品質修正

## 制約・注意事項

- Git リポジトリ内で実行する必要があります
- GitHub CLI (`gh`) がインストール・認証済みである必要があります
- フォーマッターは事前にインストールされている必要があります
- main/master ブランチからは自動的に新規ブランチを作成します

### 既存PR対応の制約

- **既存PR検出**: OPENまたはDRAFT状態のPRのみを対象とします
- **PR更新**: タイトルと本文のみを更新します（ラベル、レビュアー、マイルストーンは保持）
- **ブランチ保護**: main/develop等の保護されたブランチへの直接プッシュは失敗します
- **マージ済みPR**: 既にマージされたPRは検出対象外です（新規PR作成）
- **複数PR**: 同じブランチに複数のPRがある場合は最新のものを使用します

---

**目標**: フォーマット・コミット・PR作成の一連の作業を完全自動化し、開発フローを効率化

---

## 🎯 Skill Integration

このコマンドは以下のスキルと統合し、PR作成ワークフローを最適化します。

### integration-framework (必須)

- **理由**: TaskContext標準化とPR作成ワークフロー統合
- **タイミング**: コマンド実行開始時に自動ロード
- **トリガー**: `/create-pr` 実行時
- **提供内容**:
  - TaskContextインターフェース（フォーマッター検出・コミット分割・PR作成の状態管理）
  - Communication Busパターン（フェーズ間のデータ共有）
  - エラーハンドリング標準化
  - メトリクス収集とパフォーマンス追跡

### github-cli-helper (オプション)

- **理由**: GitHub PR操作の自動化と統合
- **タイミング**: PR作成・更新フェーズで起動
- **トリガー**: `gh pr create` や `gh pr edit` 実行時
- **提供内容**:
  - 既存PR検出ロジック
  - PR作成/更新の統一インターフェース
  - Conventional Commits準拠のメッセージ生成
  - エラーリカバリー戦略

### code-review (条件付き)

- **理由**: PR作成前の品質チェック
- **タイミング**: `--pre-review` フラグ使用時
- **トリガー**: ユーザーがPR作成前にレビューを要求した場合
- **提供内容**:
  - 自動コードレビュー
  - 品質スコア算出
  - 修正提案
  - PR本文への品質情報埋め込み

### 統合フローの例

**基本フロー（integration-framework統合）**:

```
/create-pr 実行
    ↓
TaskContext作成（source: "/create-pr"）
    ↓
Phase 1: フォーマッター検出
    ↓ (project-detector.mdユーティリティ使用)
package.json検出 → pnpm run format
    ↓
Phase 2: フォーマット実行
    ↓
context.metrics["formatting_status"] = "success"
    ↓
Phase 3: コミット分割
    ↓ (変更内容を意味的にグループ化)
commit_groups生成
    ↓
Phase 3.5: 既存PR検出
    ↓ (github-cli-helper統合)
gh pr list --head <branch> 実行
    ↓
既存PRあり？
    ↓ Yes
対話的選択（更新/新規/キャンセル）
    ↓
Phase 4: PR作成または更新
    ↓
context.metrics["status"] = "success"
    ↓
TaskContext永続化
```

**事前レビュー付きフロー（code-review統合）**:

```
/create-pr --pre-review 実行
    ↓
TaskContext作成
    ↓
フォーマット実行
    ↓
code-review スキル起動
    ↓
品質スコア算出
    ↓
スコア < 80？
    ↓ Yes
修正提案表示 → ユーザー承認待ち
    ↓
コミット作成（品質スコア付き）
    ↓
PR作成（本文に品質情報埋め込み）
```

### スキル連携の利点

1. **ワークフロー統合**: フォーマット→コミット→PR作成の一貫した状態管理
2. **既存PR対応**: 自動検出と更新により重複PR作成を防止
3. **品質保証**: 事前レビューオプションによるPR品質向上
4. **エラーハンドリング**: 統一されたエラー処理とリカバリー戦略
5. **メトリクス収集**: パフォーマンス追跡と継続的改善

---
