# Comment Handling Flow

`--comments` モードで使用する PR コメント対応の詳細フローです。

## 概要

GitHub PR のレビューコメントを取得・分類し、`gh-address-comments` スキルと連携して対応します。

## 実行フロー

### Step 1: コメント取得

```bash
# PR レビューコメントを取得
gh api repos/{owner}/{repo}/pulls/{pr}/reviews --jq '.[].body'

# インラインコメントを取得
gh api repos/{owner}/{repo}/pulls/{pr}/comments --jq '.[] | {body, path, line, user: .user.login}'
```

### Step 2: ソース分類

| ソース         | 判定基準              | 対応方針          |
| -------------- | --------------------- | ----------------- |
| Human reviewer | ユーザーアカウント    | 最優先で対応      |
| CodeRabbit     | `coderabbitai[bot]`   | 自動分類して対応  |
| GitHub Actions | `github-actions[bot]` | CI と連携して対応 |
| Other bots     | `[bot]` サフィックス  | 優先度低め        |

### Step 3: 優先度分類

コメント内容から優先度を判定:

- **Critical**: セキュリティ脆弱性、データ損失リスク
- **High**: バグ、ロジックエラー、型安全性
- **Major**: パフォーマンス、ベストプラクティス違反
- **Minor**: スタイル、命名、コメント

### Step 4: 対応実行

`gh-address-comments` スキルに委譲:

1. 各コメントに対して修正方針を決定
2. コード修正を適用
3. 修正不可能なものはスキップして報告

### フィルタリング

```bash
# 特定ボットのコメントのみ
/code-review-system --comments --bot coderabbitai

# 特定カテゴリのみ
/code-review-system --comments --category security
```

## 出力例

```markdown
# PR コメント対応結果

## コメント分類

| ソース     | 件数 | Critical | High | Major | Minor |
| ---------- | ---- | -------- | ---- | ----- | ----- |
| Human      | 5    | 1        | 2    | 1     | 1     |
| CodeRabbit | 8    | 0        | 3    | 4     | 1     |

## 対応結果

### Critical (1 件)

- [Human] SQL Injection リスク → 修正済み (src/api/users.ts:45)

### High (5 件)

- [Human] 型アサーション → 修正済み (src/utils/transform.ts:34)
- [CodeRabbit] N+1 クエリ → 修正済み (src/repos/post.ts:78)
  ...

### 未対応 (2 件)

- [Human] アーキテクチャ変更の提案 → 手動対応が必要
- [CodeRabbit] テストカバレッジ向上 → 別チケットで対応推奨
```
