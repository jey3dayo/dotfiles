# PR Workflows - PRワークフロー実用例

実際の開発シーンでのgit-automation pr使用例とベストプラクティスです。

## 基本的なPR作成

### シンプルなPR作成

```bash
# フォーマット→コミット→PR作成
/git-automation pr

# 実行内容:
# 1. フォーマッター自動検出・実行
# 2. 変更を意味的にグループ化してコミット
# 3. 既存PR確認
# 4. PR作成（または更新の選択）
```

### タイトル指定

```bash
/git-automation pr "feat: ユーザー認証機能の追加"

# 指定したタイトルでPR作成
```

### ドラフトPR

```bash
/git-automation pr --draft

# 作業中の内容を共有（レビュー不要）
```

## 既存PR更新

### 対話的更新

```bash
/git-automation pr

# 既存PR検出時:
# ℹ️  既存のPR検出:
#    #123: Add authentication
#    URL: https://github.com/org/repo/pull/123
#    状態: OPEN
#
# 既存のPRが見つかりました。どうしますか？
# 1. 更新 - 既存PRのタイトルと本文を更新
# 2. 新規作成 - 新しいPRを作成
# 3. キャンセル - 処理を中止
# 選択: 1

# → PR更新実行
```

### 自動更新

```bash
# 確認なしで既存PRを更新
/git-automation pr --update-if-exists

# 用途: CI/CD、自動更新
```

### 強制新規作成

```bash
# 既存PRを無視して新規作成
/git-automation pr --force-new

# 用途: 別のPRを作成したい場合
```

## フォーマット制御

### フォーマットスキップ

```bash
# 手動でフォーマット済み
npm run format

# フォーマットをスキップしてPR作成
/git-automation pr --no-format
```

### フォーマッター指定

```bash
# カスタムフォーマッター
/git-automation pr --formatter "deno fmt"
```

## コミット制御

### 単一コミット

```bash
# 変更を1つのコミットにまとめる
/git-automation pr --single-commit

# 生成されるコミット:
# feat: multiple updates
```

### コミット分割

```bash
# デフォルト: 意味的にグループ化
/git-automation pr

# 生成されるコミット例:
# 1. style: apply code formatting
# 2. feat: add login functionality
# 3. test: add authentication tests
```

## ブランチ管理

### ブランチ指定

```bash
# 新規ブランチを作成してPR
/git-automation pr --branch feature/new-auth

# 実行内容:
# 1. feature/new-auth ブランチ作成
# 2. コミット作成
# 3. プッシュ
# 4. PR作成
```

### ベースブランチ指定

```bash
# developブランチへのPR
/git-automation pr --base develop

# デフォルト: main
```

## PRテンプレート

### テンプレート使用

```bash
# .github/PULL_REQUEST_TEMPLATE.md を自動検出
/git-automation pr

# テンプレートが存在する場合:
# 📋 PRテンプレート検出: .github/PULL_REQUEST_TEMPLATE.md
# 📝 リポジトリのPRテンプレートを使用します
```

### テンプレートスキップ

```bash
# デフォルトフォーマットを使用
/git-automation pr --no-template
```

### カスタムテンプレート

```bash
# 特定のテンプレートを指定
/git-automation pr --template .github/PULL_REQUEST_TEMPLATE/feature.md
```

## 既存PR確認

### 確認のみ

```bash
# PRの作成/更新を行わず確認のみ
/git-automation pr --check-only

# 出力例（既存PRあり）:
# ℹ️  既存PR: #123 - Add authentication
#    URL: https://github.com/org/repo/pull/123
#    状態: OPEN

# 出力例（既存PRなし）:
# ℹ️  既存PRなし
```

## プロジェクトタイプ別

### JavaScript/TypeScript

```bash
/git-automation pr

# 自動検出:
# - フォーマッター: pnpm run format
# - コミット分割: 自動
# - PR本文: 日本語
```

### Go

```bash
/git-automation pr

# 自動検出:
# - フォーマッター: gofmt
# - コミット分割: 自動
# - PR本文: 日本語
```

### Python

```bash
/git-automation pr

# 自動検出:
# - フォーマッター: black
# - コミット分割: 自動
# - PR本文: 日本語
```

### Rust

```bash
/git-automation pr

# 自動検出:
# - フォーマッター: cargo fmt
# - コミット分割: 自動
# - PR本文: 日本語
```

## 高度な使用例

### レビュアー指定

```bash
# レビュアーを指定してPR作成
/git-automation pr --reviewers user1,user2

# gh pr create に渡される:
# --reviewer user1,user2
```

### ラベル指定

```bash
# ラベルを指定
/git-automation pr --labels enhancement,documentation
```

### マイルストーン指定

```bash
# マイルストーンを指定
/git-automation pr --milestone v2.0
```

### すべてのオプション

```bash
/git-automation pr \
  --branch feature/auth \
  --base develop \
  --draft \
  --reviewers user1,user2 \
  --labels enhancement \
  --milestone v2.0 \
  --template .github/PULL_REQUEST_TEMPLATE/feature.md
```

## 開発フロー統合

### 機能開発フロー

```bash
# 1. ブランチ作成
git checkout -b feature/new-feature

# 2. 開発
# ... コード変更 ...

# 3. コミット（通常のコミット）
/git-automation commit

# 4. PR作成（フォーマット→コミット分割→PR）
/git-automation pr

# 生成されるPR:
# - タイトル: feat: add new feature
# - 本文: 日本語
# - コミット: 意味的に分割
```

### レビュー修正フロー

```bash
# 1. レビューコメント受領
# ... フィードバック対応 ...

# 2. 既存PR更新
/git-automation pr --update-if-exists

# 実行内容:
# - フォーマット実行
# - 追加コミット作成
# - PRのタイトル・本文を最新化
```

### ホットフィックスフロー

```bash
# 1. ホットフィックスブランチ
git checkout -b hotfix/critical-bug

# 2. 修正
# ... バグ修正 ...

# 3. 緊急PR作成
/git-automation pr --no-format "fix: resolve critical security issue"

# --no-format: フォーマットをスキップして時間短縮
```

## CI/CD統合

### GitHub Actions

```yaml
# .github/workflows/auto-pr.yml
name: Auto PR

on:
  push:
    branches-ignore:
      - main
      - master
      - develop

jobs:
  create-pr:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node
        uses: actions/setup-node@v4

      - name: Create or Update PR
        run: |
          # 既存PRがあれば更新、なければ作成
          /git-automation pr --update-if-exists
```

### GitLab CI

```yaml
# .gitlab-ci.yml
create-pr:
  stage: deploy
  script:
    - /git-automation pr --update-if-exists
  only:
    - branches
  except:
    - main
    - master
```

## エラーリカバリー

### フォーマット失敗

```bash
# 1. 実行
/git-automation pr

# 出力:
# 🎨 フォーマット実行: npm run format
# ❌ フォーマットエラー: ...

# 2. 手動修正
npm run format -- --fix

# 3. 再実行
/git-automation pr --no-format
```

### プッシュ失敗

```bash
# 症状:
# ❌ プッシュ失敗: remote: Permission denied

# 原因: 権限不足

# 解決:
# 1. リモートURL確認
git remote -v

# 2. 認証情報更新
git config credential.helper store

# 3. 再実行
/git-automation pr
```

### PR作成失敗

```bash
# 症状:
# ❌ PR作成エラー: HTTP 401: Bad credentials

# 原因: gh CLI未認証

# 解決:
# 1. GitHub認証
gh auth login

# 2. 状態確認
gh auth status

# 3. 再実行
/git-automation pr
```

## ベストプラクティス

### PR作成前のチェックリスト

```bash
# 1. ローカルテスト実行
npm test

# 2. ビルド確認
npm run build

# 3. フォーマット確認
npm run format

# 4. PR作成
/git-automation pr

# すべて成功した状態でPR作成
```

### PRサイズの最適化

### 推奨サイズ

### 大きすぎる場合

```bash
# 機能を分割
git checkout -b feature/auth-step1
# ... 一部の変更をコミット ...
/git-automation pr

git checkout -b feature/auth-step2
# ... 残りの変更をコミット ...
/git-automation pr
```

### コミットメッセージの品質

```bash
# AI生成メッセージをプレビュー
/git-automation pr

# 生成されるメッセージ例:
# - style: apply code formatting
# - feat(auth): add login functionality
# - test: add authentication tests

# 必要に応じて手動調整
git commit --amend
```

## トラブルシューティング

### テンプレートが検出されない

```bash
# テンプレート作成
mkdir -p .github
cat > .github/PULL_REQUEST_TEMPLATE.md <<'EOF'
## 概要

## 変更内容

## テスト計画
EOF

# 再実行
/git-automation pr
```

### PR本文が日本語にならない

```bash
# CLAUDE.md に日本語設定がある場合は遵守されます
# デフォルトは日本語で生成されます

# 確認:
/git-automation pr --check-only
```

### コミット分割が不適切

```bash
# 単一コミットに変更
/git-automation pr --single-commit

# または手動でコミット
git add specific-files
git commit -m "..."
/git-automation pr --no-format
```
