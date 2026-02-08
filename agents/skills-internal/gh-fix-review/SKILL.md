---
name: gh-fix-review
description: |
  [What] Automated skill for GitHub PR review comment processing. Automatically classifies review comments (from CodeRabbit, human reviewers, bots) by priority (Critical/High/Major/Minor) and applies fixes in priority order. Integrates with TodoWrite for progress tracking and creates tracking documents
  [When] Use when: users mention "/review --fix-pr", "PR review automation", "CodeRabbit fixes", or need automated PR feedback processing. **Always responds in Japanese**
  [Keywords] /review --fix-pr, PR review automation, CodeRabbit fixes
---

# gh-fix-review Skill

GitHub Pull Requestのレビューコメントを自動的に分類・修正するスキルです。

## 🎯 スキルの目的

PRレビューコメント（CodeRabbit、人間レビュアー、その他ボット）を自動的に処理：

- **優先度分類**: Critical/High/Major/Minor に自動分類
- **自動修正**: 優先度順に修正を適用
- **進捗管理**: TodoWrite統合で進捗可視化
- **トラッキング**: 対応状況記録
- **カスタマイズ可能**: プロジェクト固有のレビュールールをサポート

## 🚀 主要機能

### 1. 設定ファイルサポート

プロジェクトルートまたはホームディレクトリに `.pr-review-config.json` を配置することで、レビュールールをカスタマイズできます。

```json
{
  "version": "1.0",
  "priorities": {
    "critical": {
      "keywords": ["critical", "bug", "security", "vulnerability"],
      "emoji": "🔴"
    },
    "high": {
      "keywords": ["important", "major", "should fix", "必須"],
      "emoji": "🟠"
    }
  },
  "categories": {
    "security": ["security", "vulnerability", "auth"],
    "performance": ["performance", "slow", "optimization"]
  },
  "tracking": {
    "output_path": "docs/_review-fixes.md"
  }
}
```

### 2. レビューコメント取得

GitHub CLIを使用してPRコメントを取得：

```python
from commands.shared.git_operations import get_current_pr_number
import subprocess
import json

# PR番号取得（自動検出または明示的指定）
pr_number = get_current_pr_number()

# PRレビューコメント取得
def get_pr_review_comments(pr_number):
    """Get all review comments for a PR."""
    result = subprocess.run(
        ["gh", "pr", "view", str(pr_number), "--json", "title,body,comments,reviews"],
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        return None, result.stderr

    pr_data = json.loads(result.stdout)

    # コメントとレビューを統合
    all_comments = []

    # コメント
    for comment in pr_data.get("comments", []):
        all_comments.append({
            "author": comment["author"]["login"],
            "body": comment["body"],
            "path": comment.get("path", ""),
            "line": comment.get("line", 0),
            "type": "comment"
        })

    # レビュー
    for review in pr_data.get("reviews", []):
        all_comments.append({
            "author": review["author"]["login"],
            "body": review["body"],
            "path": "",
            "line": 0,
            "type": "review"
        })

    return all_comments, pr_data.get("title", "")
```

### 3. 優先度分類（設定ファイル対応）

設定ファイルまたはデフォルトルールで自動分類：

```python
import json
import os

def load_config():
    """Load PR review configuration."""

    # プロジェクトルートの設定ファイルを優先
    config_paths = [
        ".pr-review-config.json",
        os.path.expanduser("~/.pr-review-config.json")
    ]

    for config_path in config_paths:
        if os.path.exists(config_path):
            with open(config_path) as f:
                return json.load(f)

    # デフォルト設定
    return get_default_config()


def get_default_config():
    """Get default configuration."""
    return {
        "version": "1.0",
        "priorities": {
            "critical": {
                "keywords": [
                    "critical", "bug", "security", "vulnerability",
                    "broken", "error", "failure", "crash"
                ],
                "emoji": "🔴"
            },
            "high": {
                "keywords": [
                    "important", "major", "should fix", "必須",
                    "required", "blocking", "urgent"
                ],
                "emoji": "🟠"
            },
            "major": {
                "keywords": [
                    "consider", "recommend", "推奨", "improvement",
                    "optimize", "refactor"
                ],
                "emoji": "🟡"
            },
            "minor": {
                "keywords": [
                    "nit", "style", "formatting", "typo",
                    "suggestion", "optional"
                ],
                "emoji": "🟢"
            }
        },
        "categories": {
            "security": ["security", "vulnerability", "auth", "permission", "xss", "sql injection"],
            "performance": ["performance", "slow", "optimization", "cache", "memory"],
            "bug": ["bug", "error", "broken", "fail", "incorrect"],
            "style": ["style", "format", "naming", "convention", "prettier", "eslint"],
            "refactor": ["refactor", "clean", "simplify", "duplication", "dry"],
            "test": ["test", "coverage", "mock", "assertion"],
            "docs": ["documentation", "comment", "readme", "説明"]
        },
        "tracking": {
            "output_path": "docs/_review-fixes.md",
            "include_in_git": False
        },
        "filters": {
            "ignore_bots": [],
            "only_bots": []
        }
    }


def classify_comment_priority(comment_body, config):
    """Classify comment priority based on configuration."""

    body_lower = comment_body.lower()

    for priority, settings in config["priorities"].items():
        if any(keyword in body_lower for keyword in settings["keywords"]):
            return priority

    return "minor"  # default


def classify_comment_category(comment_body, config):
    """Classify comment category based on configuration."""

    body_lower = comment_body.lower()

    for category, keywords in config["categories"].items():
        if any(keyword in body_lower for keyword in keywords):
            return category

    return "other"


def classify_pr_comments(comments, config):
    """Classify all PR comments."""

    classified = {
        "critical": [],
        "high": [],
        "major": [],
        "minor": []
    }

    for comment in comments:
        priority = classify_comment_priority(comment["body"], config)
        category = classify_comment_category(comment["body"], config)

        comment["priority"] = priority
        comment["category"] = category

        classified[priority].append(comment)

    return classified
```

### 4. トラッキングドキュメント生成

対応状況を記録：

```python
import datetime

def generate_tracking_document(pr_number, pr_title, classified_comments, config):
    """Generate tracking document for PR review fixes."""

    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # Count by priority
    counts = {
        priority: len(comments)
        for priority, comments in classified_comments.items()
    }

    total = sum(counts.values())

    content = f"""# PR #{pr_number} レビュー修正トラッキング

**最終更新**: {now}
**PR**: #{pr_number} - {pr_title}
**総コメント数**: {total}件

## 優先度別サマリー

| 優先度 | 件数 | 完了 | 残件 |
|--------|------|------|------|
"""

    for priority in ["critical", "high", "major", "minor"]:
        emoji = config["priorities"][priority]["emoji"]
        content += f"| {emoji} {priority.capitalize()} | {counts[priority]} | 0 | {counts[priority]} |\n"

    content += "\n## 詳細\n\n"

    # Add each priority section
    for priority in ["critical", "high", "major", "minor"]:
        if classified_comments[priority]:
            emoji = config["priorities"][priority]["emoji"]
            content += f"\n### {emoji} {priority.upper()}\n\n"

            for i, comment in enumerate(classified_comments[priority], 1):
                file_info = f"{comment['path']}:{comment['line']}" if comment['path'] else "全般"

                content += f"""#### [{i}] {comment['category']} - {comment['author']}

- **ファイル**: `{file_info}`
- **状態**: 未対応
- **詳細**:
```

<!-- markdownlint-disable MD052 -->

{comment['body'][:200]}...

<!-- markdownlint-enable MD052 -->

```

"""

    return content
```

### 5. 自動修正実行

優先度順に修正を適用：

```python
from commands.shared.quality_gates import QualityGates

def apply_pr_review_fixes(classified_comments, config, dry_run=False):
    """Apply fixes for PR review comments."""

    from commands.shared.todo_integration import TodoManager

    # Todoリスト作成
    todo_manager = TodoManager()

    # Critical → High → Major → Minor の順で追加
    for priority in ["critical", "high", "major", "minor"]:
        emoji = config["priorities"][priority]["emoji"]
        for comment in classified_comments[priority]:
            todo_manager.add_todo(
                f"{emoji} Fix {comment['category']}: {comment['body'][:50]}..."
            )

    # 最初のTodoをin_progressに
    if todo_manager.todos:
        todo_manager.mark_in_progress(0)

    # TodoWriteツールで表示
    # ...

    if dry_run:
        print("🔍 ドライランモード: 修正は実行しません")
        return

    # 品質ゲート
    gates = QualityGates()

    # 優先度順に修正実行
    for priority in ["critical", "high", "major", "minor"]:
        for comment in classified_comments[priority]:
            emoji = config["priorities"][priority]["emoji"]
            print(f"\n{emoji} 修正中: {comment['category']} - {comment['body'][:50]}...")

            # 修正を適用（エージェント呼び出し）
            fix_success = apply_single_fix(comment)

            if fix_success:
                # 品質チェック
                results = gates.run_all(type_check=True, lint=True, test=False)

                if all(r.success for r in results.values()):
                    print("  ✅ 修正完了")
                    todo_manager.mark_current_completed()
                    todo_manager.start_next()

                    # トラッキングドキュメント更新
                    update_tracking_status(comment, "completed")
                else:
                    print("  ❌ 品質チェック失敗、ロールバック")
                    rollback_fix(comment)
                    todo_manager.mark_current_completed()
                    todo_manager.start_next()
                    update_tracking_status(comment, "failed")


def apply_single_fix(comment):
    """Apply a single fix using appropriate agent."""

    from commands.shared.agent_selector import select_optimal_agent

    # エージェント選択
    agent_info = select_optimal_agent(
        f"Fix {comment['category']} issue: {comment['body']}",
        context={
            "file_path": comment['path'],
            "line_number": comment['line']
        }
    )

    # エージェント実行
    # Task tool を使用
    # ...

    return True  # success
```

## 📋 使用方法

### 基本実行

```bash
# 現在のブランチのPRを自動検出
/review --fix-pr

# PR番号を明示的に指定
/review --fix-pr 123

# 特定の優先度のみ
/review --fix-pr --priority critical

# ドライラン
/review --fix-pr --dry-run
```

### フィルタリングオプション

```bash
# 特定ボットのコメントのみ
/review --fix-pr --bot coderabbitai

# 特定カテゴリのみ
/review --fix-pr --category security,bug

# 複数条件の組み合わせ
/review --fix-pr --priority critical,high --category security
```

## 🔧 設定ファイル

### 配置場所

設定ファイルは以下の優先順位で読み込まれます：

1. プロジェクトルート: `.pr-review-config.json`
2. ホームディレクトリ: `~/.pr-review-config.json`
3. デフォルト設定（設定ファイルが存在しない場合）

### 設定例

詳細な設定例は `examples/` ディレクトリを参照してください。

- `examples/default-config.json` - デフォルト設定
- `examples/caad-config.json` - CAAD プロジェクト向け設定
- `examples/minimal-config.json` - 最小限の設定

## 📊 出力例

```markdown
🔧 GitHub PRレビュー修正を開始します

📊 PR情報
PR番号: #123
タイトル: VPN証明書管理の完全自動化
レビューコメント: 45件

📋 優先度別分類
🔴 Critical: 4件
🟠 High: 8件
🟡 Major: 15件
🟢 Minor: 18件

📝 トラッキングドキュメント作成
✅ docs/\_review-fixes.md を生成しました

✅ Todoリスト作成完了（45項目）

🔴 Critical問題の修正を開始します...

[1/4] terraform/scripts/1_check-certificate-expiry.sh:142
問題: ACM証明書情報パースのバグ
修正内容: --query配列の順序を修正
✅ 修正完了

...
```

## 🔗 統合機能

### GitHub CLI統合

```bash
# PR情報取得
gh pr view 123 --json title,body,comments,reviews

# PR番号自動検出
gh pr view --json number --jq '.number'
```

### 品質保証統合

```python
from commands.shared.quality_gates import QualityGates

gates = QualityGates()
results = gates.run_all(
    type_check=True,
    lint=True,
    test=False  # PRレビュー修正では通常テストはスキップ
)
```

### エージェント連携

```python
from commands.shared.agent_selector import select_optimal_agent

# 修正タイプに応じて最適なエージェントを選択
agent_info = select_optimal_agent(
    task_description=f"Fix {category} issue in {file_path}",
    context={
        "project_type": project_info.project_type,
        "category": category
    }
)
```

## ⚠️ 重要な注意事項

### GitHub CLI要件

```bash
# gh CLIのインストールと認証が必要
gh --version
gh auth status
```

### トラッキングファイル

- トラッキングファイルのパスは設定ファイルでカスタマイズ可能
- デフォルトは `docs/_review-fixes.md`
- `.gitignore`でコミット対象外に設定推奨
- 修正完了後は削除可能

### 自動修正の限界

- 単純な修正は自動化可能
- 複雑なロジック変更は人手で確認
- 品質チェック失敗時は自動ロールバック

## 🎓 トリガー条件

このスキルは以下の場合に使用：

1. `/review --fix-pr`コマンド実行時
2. GitHub PRのレビューコメント自動処理
3. CodeRabbitなどのボットコメント一括修正
4. レビュー指摘の優先度別対応

## 📝 出力形式

すべての出力は**日本語**で提供：

- 📊 PR情報サマリー
- 📋 優先度別コメント分類
- 🔧 修正進捗レポート
- 📈 完了サマリー

---

### このスキルを活用して、PRレビューのフィードバックを効率的に処理し、コード品質を向上させてください。

## 詳細リファレンス

- `references/configuration.md` - 設定ファイル詳細
- `references/customization.md` - カスタマイズガイド
- `references/integration.md` - 他ツールとの統合
- `examples/` - 設定ファイル例
