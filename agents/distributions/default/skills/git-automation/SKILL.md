---
name: git-automation
description: Smart Git workflow automation - intelligent commits with quality gates and automatic PR creation with existing PR detection. Use when committing code or creating pull requests.
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash, Read, Grep, Write
argument-hint: "[commit|pr] [options]"
---

# Git Automation - スマートGitワークフロー自動化

コミット作成からPR作成までのGitワークフローを統合的に自動化します。品質ゲート、AI駆動メッセージ生成、既存PR検出機能を提供します。

## 概要

git-automationスキルは、以下の2つの主要機能を提供します：

1. **Smart Commit**: 品質チェック付きインテリジェントコミット作成
2. **Auto PR**: 自動フォーマット・コミット分割・PR作成/更新

両機能は共通の品質ゲートと署名なしポリシーを採用し、一貫性のある開発体験を提供します。

## 基本使用方法

### Smart Commit

```bash
# 基本使用（自動ステージング＋品質チェック）
/git-automation commit

# メッセージ指定
/git-automation commit "feat: add user authentication"

# 品質チェックスキップ
/git-automation commit --no-verify

# テストのみスキップ
/git-automation commit --skip-tests
```

### Auto PR

```bash
# 基本使用（フォーマット→コミット→PR作成）
/git-automation pr

# タイトル指定
/git-automation pr "feat: ユーザー認証機能の追加"

# ブランチ指定
/git-automation pr --branch feature/auth

# 既存PR自動更新
/git-automation pr --update-if-exists

# ドラフトPR作成
/git-automation pr --draft
```

## 主要オプション

### Commit オプション

| オプション     | 説明                                 |
| -------------- | ------------------------------------ |
| `[message]`    | コミットメッセージ（省略時はAI生成） |
| `--no-verify`  | すべての品質チェックをスキップ       |
| `--skip-tests` | テストのみスキップ                   |
| `--skip-build` | ビルドのみスキップ                   |
| `--skip-lint`  | Lintのみスキップ                     |
| `--amend`      | 最後のコミットを修正（注意が必要）   |

### PR オプション

| オプション           | 説明                              |
| -------------------- | --------------------------------- |
| `[title]`            | PRタイトル（省略時は自動生成）    |
| `--no-format`        | フォーマット処理をスキップ        |
| `--single-commit`    | 単一コミットで作成                |
| `--branch <name>`    | ブランチ名指定                    |
| `--base <branch>`    | ベースブランチ指定                |
| `--draft`            | ドラフトPRとして作成              |
| `--update-if-exists` | 既存PRがあれば自動更新            |
| `--force-new`        | 既存PR確認をスキップして新規作成  |
| `--check-only`       | 既存PRの確認のみ（作成/更新なし） |
| `--no-template`      | PRテンプレートを使用しない        |

## 統合ワークフロー例

### 開発中のコミット（品質チェック付き）

```bash
# 変更をコミット（Lint→Test→Build実行）
/git-automation commit

# 実行内容:
# 1. 変更ファイルを自動ステージング
# 2. Lint実行（project-detector自動検出）
# 3. Test実行（プロジェクト設定に基づく）
# 4. Build実行（必要な場合）
# 5. AI駆動メッセージ生成
# 6. コミット作成（署名なし）
```

### フィーチャー完成時（PR作成）

```bash
# フォーマット→コミット分割→PR作成
/git-automation pr

# 実行内容:
# 1. フォーマッター自動検出・実行
# 2. 変更を意味的にグループ化
# 3. コミット分割（format/feature/fix等）
# 4. 既存PR確認
# 5. PR作成または更新
```

### 既存PR更新ワークフロー

```bash
# 既存PRに追加変更を反映
/git-automation pr --update-if-exists

# 実行内容:
# 1. フォーマット実行
# 2. コミット作成
# 3. 既存PR検出（gh pr list --head）
# 4. PR自動更新（タイトル・本文を最新化）
```

## 品質ゲート

両機能は共通の品質ゲートを使用します：

### 実行順序

```
Lint → Test → Build
```

### プロジェクト自動検出

project-detector共通ユーティリティを使用：

```python
from shared.project_detector import detect_formatter, detect_project_type

# フォーマッター検出
formatters = detect_formatter()
# npm/pnpm/yarn run format
# go fmt
# black/ruff

# プロジェクトタイプ検出
project = detect_project_type()
# JavaScript/TypeScript
# Go
# Python
# Rust
```

### スキップ条件

- コマンドが存在しない場合は自動スキップ
- `--skip-*` オプション使用時
- `--no-verify` 使用時（すべてスキップ）

## AI駆動メッセージ生成

### Commit メッセージ

```
[type]([scope]): [subject]

[body]
```

### Type

### 生成プロセス

1. 変更ファイル分析
2. Diff内容解析
3. 最近のコミット履歴確認（規約検出）
4. Conventional Commits準拠メッセージ生成

### PR タイトル・本文

### タイトル

### 本文構造

```markdown
## 概要

- 変更サマリー（絵文字付き）

## 変更内容

### コミット数 (N)

- 詳細なファイルリスト

## テスト計画

- チェックリスト

## チェックリスト

- 品質項目
```

## 既存PR検出と対応

### 検出ロジック

```python
def check_existing_pr(branch_name):
    """現在のブランチに既存のPRがあるか確認"""
    result = subprocess.run(
        ["gh", "pr", "list", "--head", branch_name,
         "--json", "number,title,url,state"],
        capture_output=True,
        text=True
    )

    prs = json.loads(result.stdout)
    # OPENまたはDRAFTのPRのみ対象
    open_prs = [pr for pr in prs if pr['state'] in ['OPEN', 'DRAFT']]
    return open_prs[0] if open_prs else None
```

### 対応方針決定

| 状況                 | 動作                           |
| -------------------- | ------------------------------ |
| `--check-only`       | 確認のみ、アクションなし       |
| `--force-new`        | 強制新規作成                   |
| `--update-if-exists` | 既存PRあり→更新、なし→作成     |
| 既存PRなし           | 新規作成                       |
| 既存PRあり（対話）   | ユーザー選択（更新/新規/中止） |

### PR更新

```python
def update_pull_request(pr_number, pr_title, pr_body):
    """既存のPRのタイトルと本文を更新"""
    update_command = f"""gh pr edit {pr_number} \
        --title "{pr_title}" \
        --body "$(cat <<'EOF'
{pr_body}
EOF
)""""

    subprocess.run(update_command, shell=True)
```

## 重要な設計原則

### 署名なしポリシー

### 絶対に行わないこと

- "Co-authored-by" 追加
- "Generated with Claude Code" 追加
- AI/Assistant attribution追加
- Git設定・認証情報の変更
- 絵文字の使用（コミット、PR）

### 理由

### エラーハンドリング

- 部分的コミット防止
- 明確なエラーメッセージ
- リカバリー手順の提示
- フォールバック戦略の提供

### 依存スキル

- **integration-framework** (必須): TaskContext標準化
- **code-quality-automation** (推奨): 品質チェック統合
- **project-detector** (必須): プロジェクト自動検出

## トラブルシューティング

### 品質チェック失敗

```bash
# テストをスキップして実行
/git-automation commit --skip-tests

# すべての品質チェックをスキップ
/git-automation commit --no-verify
```

### フォーマッター未検出

```bash
# フォーマットをスキップ
/git-automation pr --no-format

# 手動フォーマット後に実行
npm run format
/git-automation pr --no-format
```

### 既存PR検出エラー

```bash
# GitHub CLI未認証
gh auth login

# 既存PRチェックをスキップ
/git-automation pr --force-new
```

## 詳細リファレンス

より詳細な情報は以下のドキュメントを参照：

- [Commit品質ゲート](references/commit-quality-gates.md) - Lint/Test/Build実行ルール
- [Commitメッセージ生成](references/commit-message-generation.md) - AI駆動生成ロジック
- [PR作成フロー](references/pr-creation-flow.md) - Format→Commit→Push→PR作成
- [PRフォーマット規則](references/pr-format-rules.md) - テンプレート、署名ポリシー
- [既存PR検出](references/existing-pr-detection.md) - 検出・更新・対応方針
- [Commitワークフロー](examples/commit-workflows.md) - 実用例とベストプラクティス
- [PRワークフロー](examples/pr-workflows.md) - 新規PR/更新/Draft等
- [トラブルシューティング](examples/troubleshooting.md) - よくある問題と解決策

## 制約・注意事項

- Git リポジトリ内での実行が必要
- GitHub CLI (`gh`) のインストール・認証が必要（PR機能）
- フォーマッターの事前インストールが推奨（PR機能）
- 保護されたブランチへの直接プッシュは失敗する可能性あり

## 統合フレームワークとの連携

TaskContextを使用した統一状態管理：

```python
from shared.task_context import TaskContext, save_context

context = TaskContext(
    task_description="Git自動化実行",
    source="/git-automation"
)

# メトリクス記録
context.metrics["quality_gate_status"] = "passed"
context.metrics["commit_count"] = len(commits)
context.communication["shared_data"]["pr_url"] = pr_url

# コンテキスト永続化
save_context(context)
```
