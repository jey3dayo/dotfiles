---
name: code-quality-automation
description: Automated lint/format/test execution with iterative fixing. Use when ensuring code quality, fixing lint errors, or running full quality checks.
argument-hint: [--with-comments]
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash, Read, Grep, Edit
---

# Code Quality Automation Skill

コードをlint/format/testで磨き上げ、エラーが出なくなるまで自動修正を繰り返します。

## 🎯 Overview

プロジェクトのlint/format/test設定を自動検出し、品質チェックと修正を繰り返し実行します。

### Key Features

- プロジェクト設定の自動検出（mise.toml, package.json）
- エラーが出なくなるまで最大3回自動修正を繰り返す
- Format → Lint → Test の段階的実行
- オプションで冗長コメントの自動整理

### Supported Languages

- **JavaScript/TypeScript**: ESLint, Prettier, Jest
- **Python**: Black, Flake8, pytest
- **Go**: gofmt, golangci-lint
- **Rust**: rustfmt, clippy, cargo test
- **Markdown**: markdownlint, prettier
- **Ruby**: rubocop, rspec

## 🔄 Execution Flow

### 1. Project Configuration Detection

- `mise.toml` タスク検出（優先）
- `package.json` スクリプト検出（フォールバック）
- Lint/Format設定ファイル確認

### 2. Format Execution

```bash
mise run format  # または npm run format
```

- コードを自動整形
- 一貫したスタイルを適用

### 3. Lint Execution & Auto-Fix

```bash
mise run lint           # エラーチェック
mise run lint-fix       # 自動修正
# 手動修正（必要に応じて）
```

- Lintエラー検出
- 自動修正可能なエラーを修正
- 残りのエラーは手動修正を試みる

### 4. Test Execution & Fix

```bash
mise run test  # または npm test
```

- テスト実行
- 失敗したテストの修正

### 5. Iteration

- すべて成功するまで最大3回繰り返す
- 各ステップの結果を表示
- エラーが出なくなったら完了

## 📝 Basic Usage

### Standard Execution

```bash
/polish
```

すべてのステップ（format → lint → test）を実行します。

### With Comment Cleanup

```bash
/polish --with-comments
```

品質チェックに加えて、冗長なコメントを整理します：

- コードの内容を繰り返すだけのコメントを削除
- WHY説明、TODO、複雑なロジック説明は保持
- 削除前にユーザーに確認

## 📊 Execution Example

```
🔧 Code Polish を開始します

📋 プロジェクト設定検出
  ✅ mise.toml 検出: format, lint, lint-fix
  ✅ package.json 検出: なし

🎨 Step 1/3: Format実行
  $ mise run format
  ✅ フォーマット完了（3ファイル更新）

🔍 Step 2/3: Lint実行
  $ mise run lint
  ❌ 5件のエラー検出

  $ mise run lint-fix
  ✅ 5件中4件を自動修正

  🔧 残り1件を手動修正中...
  ✅ すべてのlintエラーを修正

✅ Step 3/3: Test実行（スキップ - testコマンドなし）

🎉 Code Polish 完了！
  - Format: ✅ 成功
  - Lint: ✅ 成功（5件修正）
  - Test: ⊘ スキップ

  試行回数: 2回
  総実行時間: 12.3秒
```

## 🎯 Common Use Cases

### 1. Development Quality Assurance

```bash
# コードを書いた後、PRを作る前に実行
/polish
```

開発中に定期的に実行して、品質を維持します。

### 2. Post-Review Fix

```bash
# レビュー指摘を修正した後に実行
/polish
```

レビューのフィードバックを反映した後、全体の品質を確認します。

### 3. Pre-Merge Final Check

```bash
# マージ前の最終確認
/polish
# すべて成功したら
/commit
/create-pr
```

マージ前に最終的な品質チェックを実行します。

## 📚 Detailed References

### Configuration Detection

詳細な設定検出ロジック、検出されるタスク一覧、優先順位については：
→ `references/configuration-detection.md`

### Execution Flow Details

各ステップの詳細な実行ロジック、エラーハンドリング、成功/失敗判定については：
→ `references/execution-flow.md`

### Comment Cleanup Rules

`--with-comments` オプションの動作、削除/保持されるコメントパターンについては：
→ `references/comment-cleanup.md`

### Language-Specific Support

各言語の具体的な設定例、ツール一覧については：
→ `references/supported-projects.md`

### Workflow Examples

実際のワークフロー例、実行結果サンプルについては：
→ `examples/workflow-examples.md`

### mise.toml Templates

言語別のmise.toml設定テンプレートについては：
→ `examples/mise-toml-templates.md`

## 🔗 Related Commands

- `/test` - テスト実行のみ
- `/fix-imports` - import文の修正
- `/clean:full` - プロジェクト全体のクリーンアップ
- `/review` - コードレビュー実行

## 💡 Tips

### Recommended: Use mise.toml

プロジェクトに `mise.toml` を追加すると、統一的な品質チェックが可能：

```toml
[tasks]
format = ["prettier --write ."]
lint = ["eslint .", "prettier --check ."]
lint-fix = ["eslint --fix .", "prettier --write ."]
test = ["npm test"]
```

### Iterative Fixing

このスキルは自動修正を繰り返すことで、手動介入を最小限にします：

1. 自動修正可能なエラーは `lint-fix` で解決
2. 残りのエラーは手動修正を試みる
3. すべて成功するまで繰り返す（最大3回）

### Comment Cleanup Philosophy

`--with-comments` は、コードの可読性を向上させるためのツールです：

- **削除**: コードを読めば分かる冗長なコメント
- **保持**: WHY（なぜ）を説明するコメント、TODO、警告
