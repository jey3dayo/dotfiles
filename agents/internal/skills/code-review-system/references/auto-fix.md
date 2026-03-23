# Auto-Fix Flow

`--fix` モードで使用する自動修正の詳細フローです。

## 概要

PR レビューコメントを優先度別に分類し、`gh-address-comments` スキルと連携して自動修正を適用します。

## 実行フロー

### Step 1: コメント取得と分類

`gh-address-comments` スキルのコメント分類システムを使用:

- Critical: 即座に修正が必要（セキュリティ、データ損失）
- High: リリース前に修正が必要（バグ、型安全性）
- Major: 修正推奨（パフォーマンス、ベストプラクティス）
- Minor: 可能であれば修正（スタイル、命名）

### Step 2: 修正適用

優先度順に修正を適用:

1. Critical → High → Major → Minor の順
2. 各修正後に lint/test で検証
3. 失敗した場合はロールバック

### Step 3: トラッキングドキュメント生成

`.review-tracking/pr-{number}-fixes.md` に修正記録を生成。

## フィルタリングオプション

```bash
# Critical のみ修正
/code-review-system --fix --priority critical

# 特定ボットのコメントのみ
/code-review-system --fix --bot coderabbitai

# ドライラン（分類のみ）
/code-review-system --fix --dry-run
```

## 出力例

```markdown
# 自動修正結果

## PR #123: feature/new-api

## コメント分類

- Critical: 2 件
- High: 3 件
- Major: 5 件
- Minor: 4 件

## 修正結果

### Critical (2/2 修正済み)

- SQL Injection 修正 (src/api/users.ts:45)
- 認証チェック追加 (src/api/posts.ts:78)

### High (3/3 修正済み)

- 型アサーション削除 (src/utils/transform.ts:34)
- null チェック追加 (src/services/user.ts:56)
- エラーハンドリング改善 (src/api/auth.ts:90)

### Major (4/5 修正済み)

- N+1 クエリ修正 (src/repos/post.ts:78)
- メモ化追加 (src/components/List.tsx:23)
- 定数化 (src/utils/calc.ts:12)
- 未使用変数削除 (src/hooks/useData.ts:8)
- [スキップ] リファクタリング提案 → 別チケット推奨

### Minor (2/4 修正済み)

- 命名改善 (src/types/user.ts:5)
- コメント追加 (src/api/middleware.ts:34)

## 品質保証

- Lint: 成功
- Test: 成功
- Build: 成功

## トラッキング

.review-tracking/pr-123-fixes.md に記録済み
```
