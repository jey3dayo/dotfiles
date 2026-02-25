---
name: codex-plan-review
description: >-
  実装プランファイルを Codex でレビューし、潜在的リスク・欠落ステップ・技術的懸念を
  特定する。実装開始前にプランの品質チェックをしたい場合に使用する。
  Triggers: "プランをレビュー", "plan review", "実装前にチェック",
  "codex でレビュー", "プランの確認", "review the plan".
allowed-tools: Bash(codex:*), Bash(ls:*), Read
---

# Codex Plan Review

`~/.claude/plans/` の最新プランファイルを Codex でレビューし、問題点を報告する。

## Workflow

### 1. 最新プランファイルを特定

```bash
ls -t ~/.claude/plans/*.md | head -1
```

### 2. プラン内容を読み込む

Read ツールでプランファイル全体を読み込む。

### 3. Codex でレビュー実行

```bash
codex exec --model gpt-5.3-codex --sandbox read-only --full-auto "
Review the following implementation plan. Identify:
1. Potential risks and failure points
2. Missing steps or edge cases
3. Technical concerns or anti-patterns
4. Scope creep or unnecessary complexity

Be specific and concise. If the plan looks solid, say so.

---
<plan content here>
" 2>/dev/null
```

### 4. 結果を報告

- 重大な問題あり → 具体的な指摘と改善案を提示し、対応するか確認
- 軽微な懸念のみ → 注意点として共有し、実装着手は可
- 問題なし → 実装着手可の旨を伝える
