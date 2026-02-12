# Commit Workflows - コミットワークフロー実用例

実際の開発シーンでのgit-automation commit使用例とベストプラクティスです。

## 開発中のコミット

### シンプルなコミット

```bash
# 変更をコミット（品質チェック付き）
/git-automation commit

# 実行内容:
# 1. 変更ファイル自動ステージング
# 2. Lint実行
# 3. Test実行
# 4. Build実行
# 5. AI駆動メッセージ生成
# 6. コミット作成
```

### メッセージ指定

```bash
/git-automation commit "feat: add user authentication"

# ユーザー指定メッセージを使用
# 品質チェックは実行される
```

### 時間短縮（テストスキップ）

```bash
# テストが遅い場合
/git-automation commit --skip-tests

# 実行内容:
# ✅ Lint実行
# ⏩ Test: スキップ
# ✅ Build実行
```

## レビュー前のコミット

### 完全な品質チェック

```bash
# すべてのチェックを実行
/git-automation commit

# 推奨: レビュー前は必ずすべてのチェックを実行
```

### 自動修正付き

```bash
# Lint自動修正
npm run lint -- --fix

# コミット
/git-automation commit
```

## 緊急修正

### 品質チェックスキップ

```bash
# 本番障害の緊急修正
/git-automation commit --no-verify "hotfix: resolve critical security issue"

# 注意: 緊急時のみ使用
# 理由: 品質チェックなしでコミット
```

### 最小限のチェック

```bash
# Lintのみ実行
/git-automation commit --skip-tests --skip-build
```

## 特定ファイルのコミット

### ステージング後にコミット

```bash
# 特定ファイルをステージング
git add src/auth/login.ts src/auth/logout.ts

# コミット
/git-automation commit

# ステージされたファイルのみがコミット対象
```

### 部分的変更のコミット

```bash
# 対話的ステージング
git add -p

# コミット
/git-automation commit
```

## エラーリカバリー

### Lint失敗時

```bash
# 1. 実行
/git-automation commit

# 出力:
# 🔍 Lint実行: npm run lint
# ❌ Lint: 失敗
# src/auth/login.ts:15:10 - error TS2345: ...
#
# 💡 修正方法:
#    1. npm run lint -- --fix を実行
#    2. 手動で修正
#    3. --skip-lint でスキップ

# 2. 自動修正
npm run lint -- --fix

# 3. 再度コミット
/git-automation commit
```

### Test失敗時

```bash
# 1. 実行
/git-automation commit

# 出力:
# 🔍 Lint実行: npm run lint
# ✅ Lint: 成功
# 🧪 Test実行: npm test
# ❌ Test: 失敗
#
# 💡 対処方法:
#    1. 失敗したテストを修正
#    2. --skip-tests でスキップ（推奨しない）

# 2. テストを修正
# ... コード修正 ...

# 3. テスト確認
npm test

# 4. 再度コミット
/git-automation commit
```

### Build失敗時

```bash
# 1. 実行
/git-automation commit

# 出力:
# ✅ Lint: 成功
# ✅ Test: 成功
# 🔨 Build実行: npm run build
# ❌ Build: 失敗
# TS2322: Type 'string' is not assignable to type 'number'
#
# 💡 対処方法:
#    1. ビルドエラーを修正
#    2. 依存関係を確認
#    3. --skip-build でスキップ（推奨しない）

# 2. エラー修正
# ... 型エラー修正 ...

# 3. ビルド確認
npm run build

# 4. 再度コミット
/git-automation commit
```

## プロジェクトタイプ別

### JavaScript/TypeScript

```bash
# 自動検出される品質コマンド:
# - Lint: npm run lint
# - Test: npm test
# - Build: npm run build

/git-automation commit

# パッケージマネージャーも自動検出
# pnpm/yarn/npm
```

### Go

```bash
# 自動検出される品質コマンド:
# - Lint: go vet ./...
# - Test: go test ./...
# - Build: go build ./...

/git-automation commit

# gofmt も自動適用
```

### Python

```bash
# 自動検出される品質コマンド:
# - Lint: ruff check .
# - Test: pytest
# - Build: なし（スキップ）

/git-automation commit
```

### Rust

```bash
# 自動検出される品質コマンド:
# - Lint: cargo clippy
# - Test: cargo test
# - Build: cargo build

/git-automation commit
```

## 高度な使用例

### 段階的コミット

```bash
# 1. フォーマットのみ
git add -u
/git-automation commit --skip-tests --skip-build "style: apply formatting"

# 2. 機能追加
git add src/features/
/git-automation commit "feat: add new feature"

# 3. テスト追加
git add tests/
/git-automation commit --skip-build "test: add feature tests"
```

### コミット前のプレビュー

```bash
# 変更確認
git status
git diff

# ステージング
git add -u

# コミット
/git-automation commit

# 生成されるメッセージをプレビュー:
# 📝 生成メッセージ: feat(auth): add login functionality
```

### ブランチごとの戦略

```bash
# feature ブランチ: 開発中
git checkout feature/new-feature
/git-automation commit --skip-tests  # 時間短縮

# develop ブランチ: レビュー前
git checkout develop
git merge feature/new-feature
/git-automation commit  # 完全チェック

# main ブランチ: 本番リリース
git checkout main
git merge develop
/git-automation commit  # 完全チェック
```

## ベストプラクティス

### 開発サイクル

```bash
# 1. 機能開発
# ... コード変更 ...

# 2. 定期コミット（軽量チェック）
/git-automation commit --skip-tests

# 3. 機能完成
# ... テスト追加 ...

# 4. 最終コミット（完全チェック）
/git-automation commit

# 5. PR作成
/git-automation pr
```

### コミット粒度

**推奨**:

```bash
# 意味のある単位でコミット
/git-automation commit "feat: add login form"
/git-automation commit "feat: add authentication logic"
/git-automation commit "test: add auth tests"
```

**非推奨**:

```bash
# 大きすぎるコミット
/git-automation commit "feat: add entire auth system"

# 小さすぎるコミット
/git-automation commit "fix: typo in comment"
/git-automation commit "fix: another typo"
```

### エラー予防

```bash
# 1. 品質チェック実行
npm run lint
npm test
npm run build

# 2. すべて成功したらコミット
/git-automation commit

# メリット: コミット前にエラーを検出
```

## CI/CDとの統合

### pre-commit hookとの併用

```bash
# .git/hooks/pre-commit
#!/bin/bash

# git-automation の品質チェックを活用
/git-automation commit --no-verify

# 注意: hookから呼び出す場合は--no-verifyで無限ループ防止
```

### GitHub Actionsとの連携

```yaml
# .github/workflows/ci.yml
name: CI

on: [push]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Quality Gates
        run: |
          npm run lint
          npm test
          npm run build

# git-automationと同じチェックを実行
# ローカルで通過すればCIも通過
```

## トラブルシューティング

### 変更がステージングされない

```bash
# 症状:
# "No changes to commit"

# 原因: ファイルがステージングされていない

# 解決:
git add -u  # 変更ファイルをステージング
/git-automation commit
```

### メッセージ生成が不適切

```bash
# 手動でメッセージ指定
/git-automation commit "fix(api): resolve timeout issue"

# または、コミット後に修正
git commit --amend
```

### 品質チェックが遅い

```bash
# テストキャッシュ使用
npm test -- --cache

# または特定のチェックをスキップ
/git-automation commit --skip-tests
```
