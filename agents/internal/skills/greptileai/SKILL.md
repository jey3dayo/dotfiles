---
name: greptileai
description: |
  [What] greptileai bot との連携ルール。PR レビュースレッドへの返信時に @greptileai メンションを自動付与する。
  [When] PR レビューコメントに返信する時、gh-address-comments 実行時
  [Keywords] greptileai, PR review, code review, review thread, resolve thread
user-invocable: false
---

# greptileai 連携ルール

## greptileai とは

GitHub PR レビュー bot。コードベースを解析し、レビューコメントに対してコンテキストを提供する。
**メンション（`@greptileai`）が付いたコメントにのみ反応する**。

## 必須ルール

PR レビュースレッドへの返信は、**必ず `@greptileai` で始めること**。

```
@greptileai <対応内容>
```

メンションなしで返信すると greptileai が反応しないため、レビューの解決確認ができない。

## コマンド一覧

| コマンド                 | 用途                                         |
| ------------------------ | -------------------------------------------- |
| `@greptileai review`     | PR 全体のレビューをリクエスト                |
| `@greptileai <対応内容>` | スレッドへの返信（対応完了報告・質問・議論） |
| `@greptileai LGTM`       | 対応完了を通知しスレッドを解決               |

## 実装例

### gh CLI でレビュースレッドに返信する場合

```bash
# GraphQL mutation でコメントに返信
gh api graphql -f query='
  mutation {
    addPullRequestReviewComment(input: {
      pullRequestId: "PR_ID",
      inReplyToId: "COMMENT_ID",
      body: "@greptileai 指摘の通り修正しました。`foo` 関数の引数チェックを追加しています。"
    }) {
      comment { url }
    }
  }
'
```

### REST API での返信

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  --method POST \
  --field body="@greptileai 修正しました。詳細は変更差分をご確認ください。" \
  --field in_reply_to={comment_id}
```

## gh-address-comments との統合

`gh-address-comments` スキルでレビュースレッドに返信する際は、返信本文の先頭に `@greptileai` を付与すること。

例:

- ❌ `"変数名を修正しました"`
- ✅ `"@greptileai 変数名を camelCase に修正しました"`
