# 実行モード詳細

code-review-systemが提供する4つの実行モードの詳細仕様です。

## 1. 詳細モード（デフォルト）

### 概要

包括的な品質評価を実施し、⭐️5段階評価体系による次元別評価を提供します。

### 特徴

- ⭐️5段階評価: 各観点を1〜5の星で評価
- プロジェクト自動検出: package.json, go.mod等から技術スタックを判定
- 技術スタック別スキル統合: TypeScript, React, Go等の専門スキルを自動ロード
- 詳細な改善提案: 具体的なコード例と修正手順
- アクションプラン: 優先順位付きの改善計画

### 実行フロー

```
1. Pre-review checkpoint作成
   ↓
2. プロジェクトタイプ判定
   ↓
3. 技術スタック別スキルロード
   ↓
4. code-reviewスキル起動
   ↓
5. 評価基準統合
   ↓
6. code-reviewerエージェント実行
   ↓
7. ⭐️評価レポート生成（日本語）
```

### コード例

```python
# Mode detection
mode = "detailed"

# Project detection
project_type = detect_project_type()  # "nextjs", "react-spa", "nodejs-api", "go-api"

# Load tech-specific skills
skills = load_skills_for_project(project_type)
# Example: ["typescript", "react", "security"] for Next.js

# Invoke code-review skill
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

### 期待される出力

```markdown
# コードレビュー結果

## プロジェクト情報

- タイプ: Next.js
- 統合スキル: TypeScript, React, Security

## 評価結果

### 型安全性 ⭐️⭐️⭐️⭐️☆ (4/5)

- any型の使用: 3箇所検出
- 修正提案: [具体的な修正例]

### セキュリティ ⭐️⭐️⭐️☆☆ (3/5)

- 🔴 高優先度: 入力検証が不十分
- ファイル: src/api/users.ts:45
- 修正例: [コード例]

### パフォーマンス ⭐️⭐️⭐️⭐️⭐️ (5/5)

- 問題なし

## アクションプラン

1. [高優先度] セキュリティ問題の修正
2. [中優先度] any型の削除
3. [低優先度] コメント追加
```

## 2. シンプルモード

### 概要

迅速な問題発見に特化し、並列エージェント実行で効率的にレビューを行います。

### 特徴

- 並列エージェント実行: security, performance, quality, architectureを同時実行
- 優先度付き問題リスト: 🔴高、🟡中、🟢低で分類
- 即座の修正提案: 具体的なコード例を提示
- GitHub issue連携: `--create-issues`で自動issue作成

### 実行フロー

```
1. Pre-review checkpoint作成
   ↓
2. プロジェクトタイプ判定
   ↓
3. 技術スタック別スキルロード
   ↓
4. 並列エージェント実行:
   - security エージェント
   - performance エージェント
   - quality エージェント
   - architecture エージェント
   ↓
5. 結果集約・優先度付け
   ↓
6. 問題リスト生成（日本語）
```

### コード例

```python
# Mode detection
mode = "simple"

# Project detection and skills loading
project_type = detect_project_type()
skills = load_skills_for_project(project_type)

# Invoke code-review skill with simple mode
skill_result = execute_skill("code-review", {
    "mode": mode,
    "options": {
        "fix": "--fix" in args,
        "create_issues": "--create-issues" in args
    },
    "targets": determine_review_targets(args)
})

# Parallel agent execution (inside code-review skill)
results = parallel_execute([
    ("security", review_security),
    ("performance", review_performance),
    ("quality", review_quality),
    ("architecture", review_architecture)
])

# Aggregate and prioritize
issues = aggregate_issues(results)
issues.sort(key=lambda x: x.priority, reverse=True)
```

### 期待される出力

````markdown
# クイックレビュー結果

## 🔴 高優先度 (2件)

### 1. セキュリティ: 入力検証が不十分

- ファイル: src/api/users.ts:45
- 問題: ユーザー入力を直接クエリに使用
- 修正例:

  ```typescript
  // Before
  const user = await db.query(
    `SELECT * FROM users WHERE id = ${req.params.id}`,
  );

  // After
  const user = await db.query("SELECT * FROM users WHERE id = $1", [
    req.params.id,
  ]);
  ```
````

### 2. パフォーマンス: N+1クエリ

- ファイル: src/api/posts.ts:78
- 問題: ループ内でクエリ実行
- 修正例: [コード例]

## 🟡 中優先度 (3件)

...

## 🟢 低優先度 (5件)

...

```

## 3. CI診断モード

### 概要

GitHub Actions CI失敗の診断と修正計画の作成を行います。

### 特徴

- **ci-diagnostics統合**: 失敗チェックの収集と分類
- **gh-fix-ci補助**: GitHub CLIでログ取得
- **失敗分類**: lint, test, build, deploy等
- **修正計画**: 優先順位付きの修正手順

### 実行フロー

```

1. PR番号の取得（自動検出 or 引数）
   ↓
2. gh-fix-ciでCI失敗ログ取得
   ↓
3. ci-diagnosticsで失敗分類
   ↓
4. エラーログ解析
   ↓
5. 影響ファイル特定
   ↓
6. 修正計画生成（日本語）

````

### コード例

```python
# CI Diagnosis Mode detection
mode = "ci_diagnosis"

# Get PR number
pr_number = None
for i, arg in enumerate(args):
    if arg == "--fix-ci" and i + 1 < len(args) and args[i + 1].isdigit():
        pr_number = int(args[i + 1])
        break

if not pr_number:
    pr_number = get_current_pr_number()

if not pr_number:
    print("エラー: PR番号を指定するか、PRに紐づくブランチで実行してください")
    exit(1)

# Invoke ci-diagnostics skill
skill_result = execute_skill("ci-diagnostics", {
    "pr_number": pr_number,
    "options": {
        "dry_run": "--dry-run" in args
    }
})
````

### 期待される出力

```markdown
# CI診断結果

## PR情報

- PR番号: #123
- ブランチ: feature/new-api

## 失敗チェック

### 1. Lint Check (失敗)

- エラー: 15件
- 主な問題:
  - unused variable: 8件
  - missing type: 5件
  - formatting: 2件
- 影響ファイル:
  - src/api/users.ts
  - src/utils/helpers.ts

### 2. Test Check (失敗)

- エラー: 3テスト失敗
- 主な問題:
  - TypeError: Cannot read property 'id' of undefined
- 影響ファイル:
  - tests/api/users.test.ts

## 修正計画

### Phase 1: Lint修正 (10分)

1. 未使用変数の削除
2. 型注釈の追加
3. フォーマット実行

### Phase 2: Test修正 (20分)

1. null/undefinedチェック追加
2. テストデータの修正

## 推奨スキル

- typescript: 型安全性の改善
- testing: テスト修正パターン
```

## 4. CI診断 + PRコメント修正モード

### 概要

CI診断とPRコメント修正を同一フローで実行し、統合修正計画を作成します。

### 特徴

- 統合実行: CI診断とPRコメント処理を同時に実行
- 統合修正計画: 両方の結果を踏まえた修正計画
- 優先度統合: CI失敗とPRコメントの優先度を統合
- 効率的: 2つの問題を一度に解決

### 実行フロー

```
1. PR番号の取得（自動検出 or 引数）
   ↓
2. 並列実行:
   - ci-diagnosticsでCI失敗診断
   - gh-fix-reviewでPRコメント取得・分類
   ↓
3. 結果統合
   ↓
4. 優先度統合（CI Critical > PR Critical > CI High > PR High...）
   ↓
5. 統合修正計画生成（日本語）
   ↓
6. 修正実行（--dry-runなし）
   ↓
7. トラッキングドキュメント生成
```

### コード例

```python
# CI + PR Combined Mode detection
mode = "ci_pr_combined"

# Get PR number (single source)
pr_number = None
for i, arg in enumerate(args):
    if arg in ("--fix-ci", "--fix-pr") and i + 1 < len(args) and args[i + 1].isdigit():
        pr_number = int(args[i + 1])
        break

if not pr_number:
    pr_number = get_current_pr_number()

if not pr_number:
    print("エラー: PR番号を指定するか、PRに紐づくブランチで実行してください")
    exit(1)

# Execute both diagnostics in parallel
ci_result = execute_skill("ci-diagnostics", {
    "pr_number": pr_number,
    "options": {"dry_run": "--dry-run" in args}
})

pr_result = execute_skill("gh-fix-review", {
    "pr_number": pr_number,
    "options": {
        "priority": get_arg_value("--priority", args),
        "bot_filter": get_arg_value("--bot", args),
        "category_filter": get_arg_value("--category", args),
        "dry_run": "--dry-run" in args
    }
})

# Integrate results
skill_result = {
    "ci": ci_result,
    "pr": pr_result,
    "integrated_plan": create_integrated_plan(ci_result, pr_result)
}
```

### 期待される出力

```markdown
# CI + PRコメント統合診断結果

## PR情報

- PR番号: #123
- ブランチ: feature/new-api

## CI診断結果

### 失敗チェック

1. Lint Check (失敗): 15件
2. Test Check (失敗): 3テスト失敗

## PRコメント分類結果

### Critical (2件)

1. [Security] SQL Injection risk
2. [Bug] Null pointer exception

### High (3件)

1. [Performance] N+1 query
2. [Bug] Race condition
3. [Security] Missing auth check

## 統合修正計画

### Phase 1: Critical問題（最優先）

1. [CI + PR] セキュリティ問題の修正 (30分)
   - SQL Injection修正
   - 認証チェック追加
2. [PR] Null pointer exception修正 (15分)

### Phase 2: High問題（高優先度）

1. [CI] Test修正 (20分)
2. [PR] Performance改善 (25分)
3. [PR] Race condition修正 (20分)

### Phase 3: Medium/Low問題（通常優先度）

1. [CI] Lint修正 (10分)
2. [PR] その他コメント対応 (30分)

## 統合優先度

1. 🔴 Critical: CI失敗 + セキュリティ
2. 🔴 Critical: PRコメント（バグ）
3. 🟡 High: CI失敗 + テスト
4. 🟡 High: PRコメント（パフォーマンス、バグ）
5. 🟢 Medium/Low: Lint、スタイル

## 推奨スキル

- typescript: 型安全性の改善
- security: セキュリティパターン
- testing: テスト修正パターン
```

## モード選択ロジック

```python
def detect_mode(args):
    """Detect execution mode from command arguments"""
    if "--fix-ci" in args and "--fix-pr" in args:
        return "ci_pr_combined"
    elif "--fix-ci" in args:
        return "ci_diagnosis"
    elif "--fix-pr" in args:
        return "pr_review_automation"
    elif "--simple" in args:
        return "simple"
    else:
        return "detailed"
```

## Serena統合オプション

詳細モードでのみ利用可能：

```python
def detect_serena_options(args):
    """Detect Serena integration options"""
    return {
        "enabled": any(opt in args for opt in ['--with-impact', '--deep-analysis', '--verify-spec']),
        "with_impact": "--with-impact" in args,      # API変更の影響範囲分析
        "deep_analysis": "--deep-analysis" in args,   # シンボルレベルの詳細解析
        "verify_spec": "--verify-spec" in args        # 仕様との整合性確認
    }
```

## Pre-review Checkpoint

すべてのモードで実行前にcheckpointを作成：

```bash
# Create checkpoint before review
git add -A
git commit -m "Pre-review checkpoint" || echo "No changes to commit"
```

これにより、レビュー前の状態を保存し、問題発生時にロールバック可能にします。
