# Auto-Fix Flow

`--fix` モードで使用する自動修正の詳細フローです。

## 概要

PR レビューコメントを `gh-address-comments` の `fetch_comments.py` で取得し、
code-review-system 自身が優先度分類と修正適用を行います。

## 実行フロー

### Step 1: コメント取得

`gh-address-comments` スキルの `fetch_comments.py` を実行し、JSON を取得:

```bash
python3 ~/.claude/skills/gh-address-comments/scripts/fetch_comments.py
```

出力構造:

```json
{
  "pull_request": { "number": 123, "url": "...", "title": "...", "state": "OPEN" },
  "conversation_comments": [...],
  "reviews": [...],
  "review_threads": [
    {
      "id": "...",
      "isResolved": false,
      "path": "src/api/users.ts",
      "line": 45,
      "comments": { "nodes": [{ "body": "...", "author": { "login": "reviewer" } }] }
    }
  ]
}
```

### Step 2: 優先度分類

未解決の `review_threads` を以下の基準で分類:

| 優先度   | 基準                                   | 例                          |
| -------- | -------------------------------------- | --------------------------- |
| Critical | セキュリティ脆弱性、データ損失リスク   | SQL Injection, 認証バイパス |
| High     | バグ、ロジックエラー、型安全性         | null 参照, 型アサーション   |
| Major    | パフォーマンス、ベストプラクティス違反 | N+1 クエリ, メモ化不足      |
| Minor    | スタイル、命名、コメント               | 命名改善, コメント追加      |

分類ルール:

- `isResolved: true` のスレッドはスキップ
- コメント本文のキーワードと文脈から判定
- Human reviewer のコメントは bot より優先度を 1 段階上げる

### Step 3: 修正適用

Critical → High → Major → Minor の順で修正:

1. 対象ファイル・行を特定（`path`, `line` フィールド）
2. コメント内容を解析し修正方針を決定
3. コード修正を適用
4. `mise run ci:quick` で検証
5. 検証失敗時は `git checkout -- <file>` でロールバックし、次のコメントへ

### Step 4: 結果報告

修正不可能なコメント（アーキテクチャ変更提案等）は理由付きでスキップ報告。

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
- スキップ（解決済み）: 3 件

## 修正結果

### Critical (2/2 修正済み)

- SQL Injection 修正 (src/api/users.ts:45) — @reviewer
- 認証チェック追加 (src/api/posts.ts:78) — @reviewer

### High (3/3 修正済み)

- 型アサーション削除 (src/utils/transform.ts:34) — @coderabbitai
- null チェック追加 (src/services/user.ts:56) — @reviewer
- エラーハンドリング改善 (src/api/auth.ts:90) — @coderabbitai

### Major (4/5 修正済み)

- N+1 クエリ修正 (src/repos/post.ts:78) — @coderabbitai
- メモ化追加 (src/components/List.tsx:23) — @coderabbitai
- 定数化 (src/utils/calc.ts:12) — @reviewer
- 未使用変数削除 (src/hooks/useData.ts:8) — @coderabbitai
- [スキップ] リファクタリング提案 → 手動対応が必要

## 品質保証

- mise run ci:quick: 成功
```
