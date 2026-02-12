---
description: Comprehensive code review with project-specific optimization
argument-hint: [--simple] [--staged|--recent|--branch <name>] [--with-impact] [--fix] [--fix-ci [pr-number]] [--fix-pr [pr-number]]
---

# Review - 統合コードレビューコマンド

包括的なコードレビューを実行するコマンドです。`code-review`スキルを呼び出し、プロジェクトに最適化されたレビューを提供します。

## ⚠️ 重要な注意事項

### GitHub連携について

- このコマンドはローカルでのレビューのみを実行します
- GitHub PRへのコメント投稿機能はありません
- レビュー結果はローカルに表示されます
- **すべてのレビュー結果は日本語で出力されます**

### 署名なしポリシー

**IMPORTANT**: すべての出力において以下を厳守：

- ❌ **NEVER** "Co-authored-by: Claude" をcommitに含めない
- ❌ **NEVER** "Generated with Claude Code" を含めない
- ❌ **NEVER** 絵文字をcommits、PRs、issuesに使用しない
- ❌ **NEVER** AI署名やウォーターマークを含めない

## 実行モード

このコマンドは2つのモードを提供します：

### 1. 詳細モード（デフォルト）

包括的な品質評価を実施：

- ⭐️ 5段階評価体系による次元別評価
- プロジェクトタイプ自動検出
- 技術スタック別スキル統合（typescript, react, golang, security, etc.）
- 詳細な改善提案とアクションプラン

**使用例**:

```bash
/review                    # 基本レビュー
/review --with-impact      # 影響分析を含む
/review --fix              # 自動修正を含む
```

### 2. シンプルモード

迅速な問題発見に特化：

- サブエージェント並列実行（security, performance, quality, architecture）
- 優先度付きの問題リスト
- 即座の修正提案
- GitHub issue連携オプション

**使用例**:

```bash
/review --simple           # クイックレビュー
/review --simple --fix     # レビュー + 自動修正
```

### 3. CI診断モード

GitHub Actions CI失敗の診断と修正計画の作成を行います。

- `ci-diagnostics` スキルで失敗分類と修正計画を生成
- `gh-fix-ci` スキルでログ取得を補助

**使用例**:

```bash
/review --fix-ci           # 現在のブランチのPRを診断
/review --fix-ci 123       # PR番号指定
/review --fix-ci --dry-run # 診断のみ（修正なし）
```

### 4. CI診断 + PRコメント修正モード

CI診断とPRコメント修正を同一フローで実行します。両方の結果を踏まえて修正計画を作成します。
PR番号は1つのみ指定してください（`--fix-ci 123 --fix-pr 456` は不可）。

**使用例**:

```bash
/review --fix-ci --fix-pr      # 現在のブランチのPRで両方実行
/review --fix-ci 123 --fix-pr  # PR番号指定
/review --fix-ci --fix-pr --dry-run # 診断/分類のみ
```

## 使用方法

### 基本的な使用

```bash
# 詳細モード（デフォルト）
/review

# シンプルモード
/review --simple
```

### 対象ファイル指定

レビュー対象は自動的に以下の優先順位で決定されます：

1. ステージされた変更（`git diff --cached`）
2. 直前のコミット（`git diff HEAD~1`）
3. 開発ブランチとの差分（`git diff origin/develop`など）
4. 最近変更されたファイル

**明示的指定**:

```bash
/review --staged           # ステージされた変更のみ
/review --recent           # 直前のコミット
/review --branch develop   # 指定ブランチとの差分
```

### Serena統合（詳細モード）

セマンティック解析機能を追加：

```bash
/review --with-impact      # API変更の影響範囲分析
/review --deep-analysis    # シンボルレベルの詳細解析
/review --verify-spec      # 仕様との整合性確認
```

### ワークフロー統合

```bash
/review --fix              # レビュー + 自動修正
/review --create-issues    # レビュー + GitHub issue作成
/review --learn            # レビュー + 学習データ記録
```

### 3. PRレビュー修正モード

GitHub PRのレビューコメントを自動修正：

- `pr-review-automation`スキル統合
- 優先度別コメント分類（Critical/High/Major/Minor）
- 自動修正と品質保証
- トラッキングドキュメント生成

**使用例**:

```bash
/review --fix-pr           # 現在のブランチのPR修正
/review --fix-pr 123       # PR番号指定
/review --fix-pr --priority critical  # Critical問題のみ修正
/review --fix-pr --dry-run # ドライラン（修正なし）
```

## 実装

このコマンドは`code-review`スキルに処理を委譲します：

````markdown
Invoke the `code-review` skill to perform comprehensive code review.

**IMPORTANT**: Respond in Japanese (日本語で回答).

## Mode Selection

```python
# Detect mode from command arguments
if "--fix-ci" in args and "--fix-pr" in args:
    mode = "ci_pr_combined"
elif "--fix-ci" in args:
    mode = "ci_diagnosis"
elif "--fix-pr" in args:
    mode = "pr_review_automation"
elif "--simple" in args:
    mode = "simple"
else:
    mode = "detailed"

# Detect Serena options
serena_enabled = any(opt in args for opt in ['--with-impact', '--deep-analysis', '--verify-spec'])
```

## Checkpoint Creation

Always create a pre-review checkpoint:

```bash
git add -A
git commit -m "Pre-review checkpoint" || echo "No changes to commit"
```

## Skill Invocation

```python
# CI + PR Combined Mode
if mode == "ci_pr_combined":
    from commands.shared.git_operations import get_current_pr_number

    pr_number = None
    for i, arg in enumerate(args):
        if arg in ("--fix-ci", "--fix-pr") and i + 1 < len(args) and args[i + 1].isdigit():
            pr_number = int(args[i + 1])
            break

    if not pr_number:
        pr_number = get_current_pr_number()

    if not pr_number:
        print("エラー: PR番号を指定するか、PRに紐づくブランチで実行してください")
        print("使用方法: /review --fix-ci --fix-pr [PR番号]")
        exit(1)

    ci_result = execute_skill("ci-diagnostics", {
        "pr_number": pr_number,
        "options": {
            "dry_run": "--dry-run" in args
        }
    })

    pr_result = execute_skill("pr-review-automation", {
        "pr_number": pr_number,
        "options": {
            "priority": get_arg_value("--priority", args),
            "bot_filter": get_arg_value("--bot", args),
            "category_filter": get_arg_value("--category", args),
            "dry_run": "--dry-run" in args
        }
    })

    skill_result = {
        "ci": ci_result,
        "pr": pr_result
    }

# CI Diagnosis Mode
elif mode == "ci_diagnosis":
    from commands.shared.git_operations import get_current_pr_number

    pr_number = None
    for i, arg in enumerate(args):
        if arg == "--fix-ci" and i + 1 < len(args) and args[i + 1].isdigit():
            pr_number = int(args[i + 1])
            break

    if not pr_number:
        pr_number = get_current_pr_number()

    if not pr_number:
        print("エラー: PR番号を指定するか、PRに紐づくブランチで実行してください")
        print("使用方法: /review --fix-ci [PR番号]")
        exit(1)

    skill_result = execute_skill("ci-diagnostics", {
        "pr_number": pr_number,
        "options": {
            "dry_run": "--dry-run" in args
        }
    })

# PR Review Automation Mode
elif mode == "pr_review_automation":
    from commands.shared.git_operations import get_current_pr_number

    # Get PR number (auto-detect or from args)
    pr_number = None
    for i, arg in enumerate(args):
        if arg == "--fix-pr" and i + 1 < len(args) and args[i + 1].isdigit():
            pr_number = int(args[i + 1])
            break

    if not pr_number:
        pr_number = get_current_pr_number()

    if not pr_number:
        print("❌ エラー: PR番号を指定するか、PRに紐づくブランチで実行してください")
        print("使用方法: /review --fix-pr [PR番号]")
        exit(1)

    # Invoke pr-review-automation skill
    skill_result = execute_skill("pr-review-automation", {
        "pr_number": pr_number,
        "options": {
            "priority": get_arg_value("--priority", args),
            "bot_filter": get_arg_value("--bot", args),
            "category_filter": get_arg_value("--category", args),
            "dry_run": "--dry-run" in args
        }
    })

# Code Review Mode (default)
else:
    skill_result = execute_skill("code-review", {
        "mode": mode,
        "options": {
            "fix": "--fix" in args,
            "create_issues": "--create-issues" in args,
            "learn": "--learn" in args,
            "with_impact": "--with-impact" in args,
            "deep_analysis": "--deep-analysis" in args,
            "verify_spec": "--verify-spec" in args
        },
        "targets": determine_review_targets(args)
    })
```

## Output

Display results in Japanese with:

- Clear priority indicators (🔴 高優先度, 🟡 中優先度, 🟢 低優先度)
- Specific file:line references
- Concrete code examples
- Actionable remediation steps
- ⭐️ ratings (detailed mode only)

## Follow-up Actions

Based on options:

- `--fix`: Apply automatic fixes via error-fixer agent
- `--create-issues`: Create GitHub issues for findings
- `--learn`: Record learning data for future improvements
````

## オプション一覧

### モード選択

- `--simple`: シンプルモードを使用（デフォルトは詳細モード）
- `--fix-ci [PR番号]`: CI診断モード（GitHub Actions）
- `--fix-ci --fix-pr [PR番号]`: CI診断 + PRコメント修正モード

### 対象指定

- `--staged`: ステージされた変更のみ
- `--recent`: 直前のコミットのみ
- `--branch <name>`: 指定ブランチとの差分

### Serena統合（詳細モードのみ）

- `--with-impact`: API変更の影響分析
- `--deep-analysis`: 深いセマンティック解析
- `--verify-spec`: 仕様との整合性確認

### ワークフロー

- `--fix`: 自動修正を適用
- `--create-issues`: GitHub issue作成
- `--learn`: 学習データ記録

### PRレビュー修正（PRレビューモードのみ）

- `--fix-pr [PR番号]`: PRレビューコメント修正モード
- `--priority <level>`: 修正する優先度（critical/high/major/minor）
- `--bot <name>`: 特定ボットのコメントのみ（例: coderabbitai）
- `--category <cat>`: 特定カテゴリのみ（security/bug/style/etc）
- `--dry-run`: ドライラン（分類のみ、修正なし）

### CI診断（CI診断モードのみ）

- `--fix-ci [PR番号]`: CI診断モード（GitHub Actions）
- `--dry-run`: ドライラン（診断のみ、修正なし）

### CI診断 + PRコメント修正（複合モードのみ）

- `--fix-ci --fix-pr [PR番号]`: CI診断 + PRコメント修正モード
- `--dry-run`: ドライラン（診断/分類のみ）

## 使用例

### 例1: 日常的なレビュー

```bash
# ステージされた変更をクイックレビュー
/review --simple --staged

# 問題発見 → 自動修正
/review --simple --fix
```

### 例2: リリース前の包括的レビュー

```bash
# 開発ブランチとの差分を詳細レビュー
/review --branch develop

# 影響分析を含む詳細レビュー
/review --with-impact --create-issues
```

### 例3: 学習と改善

```bash
# レビュー結果を学習データとして記録
/review --learn

# 継続的な品質向上
/review --fix --learn
```

### 例4: CI診断

```bash
# CI診断のみ
/review --fix-ci --dry-run

# PR番号指定で診断
/review --fix-ci 123
```

### 例5: CI診断 + PRコメント修正

```bash
# 両方を一度に実行
/review --fix-ci --fix-pr

# PR番号を指定
/review --fix-ci 123 --fix-pr
```

## プロジェクト固有カスタマイズ

### ハイブリッド動作

このコマンドは以下の優先順位で動作します：

1. **プロジェクト固有コマンド**: `./.claude/commands/review.md` が存在する場合、それを実行
2. **プロジェクト固有ガイドライン**: `./.claude/review-guidelines.md` が存在する場合、それを適用
3. **汎用レビュー**: 上記がない場合、code-reviewスキルのデフォルト動作

### ガイドラインファイルのカスタマイズ

プロジェクト固有の評価ガイドラインを定義するには、以下のいずれかにファイルを配置：

- `./.claude/review-guidelines.md`
- `./docs/review-guidelines.md`
- `./docs/guides/review-guidelines.md`

これらのファイルが存在する場合、自動的に評価ガイドラインに統合されます。

## 技術スタック別スキル

code-reviewスキルは以下のスキルを自動的に統合します：

- **typescript**: TypeScript固有の観点（型安全性、strictモード、type guards）
- **react**: React固有の観点（hooks、パフォーマンス、コンポーネント設計）
- **golang**: Go固有の観点（error handling、concurrency、idioms）
- **security**: セキュリティ観点（入力検証、認証・認可、データ保護）
- **clean-architecture**: アーキテクチャ観点（層分離、依存規則、ドメインモデリング）
- **semantic-analysis**: セマンティック解析（シンボル追跡、影響分析）

プロジェクトタイプに応じて適切なスキルが自動選択されます。

## トラブルシューティング

### チェックポイント作成が失敗する

```bash
# 変更がない場合は正常
# 既存のチェックポイントがある場合も問題なし
```

### GitHub issue作成が失敗する

```bash
# gh CLIがインストールされているか確認
gh --version

# 認証状態を確認
gh auth status
```

### Serenaオプションが動作しない

```bash
# Serena MCPサーバーが設定されているか確認
# .claude/mcp.json を確認
```

## 関連コマンド

- `/fix`: 直接エラー修正を実行（error-fixerエージェント）
- `/todos`: TODOリスト管理
- `/learnings`: 学習データ閲覧
- `/task`: 汎用タスク実行

## 📚 関連ドキュメント

### システム設計

- [Code Review システム](../skills/code-review/references/system-architecture.md) - 完全なシステム設計、アーキテクチャ、統合詳細

### スキル実装

- [code-review skill](../skills/code-review/SKILL.md) - メインレビュースキルの実装仕様
- [プロジェクト特化スキル](../skills/) - TypeScript、React、Go、セキュリティなど

### その他

- [エージェント＆コマンド活用スキル](../skills/agents-and-commands/SKILL.md) - エージェントとコマンドの使い分け

---

## 🎯 Skill Integration

このコマンドは以下のスキルと統合し、包括的なコードレビューを提供します。

### code-review (必須)

- **理由**: 統合レビューシステムのコアスキル
- **タイミング**: `/review`コマンド実行時に必ず起動
- **トリガー**: 全てのレビューモード（詳細、シンプル、PRレビュー）
- **提供内容**:
  - ⭐️5段階評価システム
  - プロジェクトタイプ自動判定
  - 技術スタック別スキル統合
  - code-reviewerエージェント連携

### ci-diagnostics (CI診断モード)

- **理由**: GitHub Actions CI失敗の診断と修正計画の作成
- **タイミング**: `/review --fix-ci` 実行時
- **提供内容**:
  - 失敗チェックの収集と分類
  - エラーログ解析と影響ファイル特定
  - 修正計画と推奨スキルの提示

### ci-diagnostics + pr-review-automation (複合モード)

- **理由**: PRコメントとCI失敗の両方を同時に修正する
- **タイミング**: `--fix-ci --fix-pr` 指定時
- **提供内容**:
  - CI失敗の診断・修正計画
  - PRコメントの分類・修正

### プロジェクト特化スキル（自動検出）

**自動統合**: プロジェクトタイプ検出に基づいて以下のスキルを自動ロード

| プロジェクトタイプ | 統合スキル                           | 評価重点                                     |
| ------------------ | ------------------------------------ | -------------------------------------------- |
| **Next.js**        | typescript, react, security          | SSR/SSG、API Routes、パフォーマンス          |
| **React SPA**      | typescript, react                    | コンポーネント設計、状態管理、バンドルサイズ |
| **Node.js API**    | typescript, security                 | RESTful設計、認証・認可、エラーハンドリング  |
| **Go API**         | golang, security, clean-architecture | イディオマティックGo、並行処理、レイヤー分離 |

### semantic-analysis (オプション)

- **理由**: シンボルレベルの深い解析
- **タイミング**: `--with-impact`, `--deep-analysis`, `--verify-spec`フラグ使用時
- **トリガー**: API変更、Breaking change検出が必要な場合
- **提供内容**:
  - シンボル検索と参照追跡
  - 影響範囲分析
  - API契約整合性検証
  - 依存関係グラフ生成

### pr-review-automation (条件付き)

- **理由**: GitHub PRコメント自動修正
- **タイミング**: `--fix-pr`フラグ使用時
- **トリガー**: PRレビューコメント処理が必要な場合
- **提供内容**:
  - コメント優先度分類（Critical/High/Major/Minor）
  - 自動修正戦略
  - トラッキングドキュメント生成
  - TodoWrite統合

### 統合フローの例

**詳細モード（自動スキル統合）**:

```
/review
    ↓
code-review スキル起動
    ↓
プロジェクト判定: Next.js
    ↓
スキル自動ロード: ["typescript", "react", "security"]
    ↓
評価基準統合
    ↓
code-reviewer エージェント実行
    ↓
⭐️評価レポート生成（日本語）
```

**シンプルモード（並列エージェント）**:

```
/review --simple
    ↓
code-review スキル起動
    ↓
プロジェクト判定 + スキルロード
    ↓
並列エージェント実行:
  - security エージェント
  - performance エージェント
  - quality エージェント
  - architecture エージェント
    ↓
結果集約・優先度付け
    ↓
問題リスト生成（日本語）
```

**PRレビュー修正モード**:

```
/review --fix-pr
    ↓
pr-review-automation スキル起動
    ↓
PR情報取得（gh CLI）
    ↓
コメント分類（優先度別）
    ↓
自動修正実行（優先度順）
    ↓
品質保証（lint/test）
    ↓
トラッキングドキュメント生成
```

### スキル連携の利点

1. **プロジェクト適応**: 技術スタックに最適化された評価基準
2. **一貫性**: 統一されたレビュー品質
3. **拡張性**: 新しい技術スタック対応が容易
4. **効率性**: Progressive Disclosureで必要な情報のみロード
5. **自動化**: 手動設定不要、プロジェクト検出で自動統合

---

**目標**: プロジェクトに最適化された、実用的で一貫性のあるコードレビューを提供すること。
