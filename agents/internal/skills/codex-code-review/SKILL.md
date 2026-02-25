---
name: codex-code-review
description: >-
  Review code changes using Codex. Use when user asks to review code,
  check code quality, or wants feedback before committing or creating
  a pull request.
  Triggers: "コードレビュー", "code review with codex", "codex でレビュー",
  "変更をチェック", "review my changes", "review code".
allowed-tools: Bash(codex:*), Bash(jq:*), Bash(git:*), Read, Edit, Grep, Glob
---

# Codex Code Review

コード変更を Codex でレビューし、問題があれば修正まで行う。

## Workflow

### 1. 変更の検出とモード判定

```bash
git status --porcelain
```

- 出力あり → uncommitted changes モード
- 出力なし → ブランチ差分モード（デフォルトブランチとの差分）

### 2. レビュー実行

#### uncommitted changes モード

```bash
codex exec --model gpt-5.3-codex --sandbox read-only --full-auto "
Review the following uncommitted changes. Identify:
1. Bugs or logic errors
2. Security concerns
3. Type safety issues
4. Code style or readability problems
5. Missing error handling

Be specific and concise. Reference file paths and line numbers.
Output JSON: {\"issues\": [{\"file\": \"...\", \"line\": N, \"severity\": \"critical|warning|info\", \"message\": \"...\"}], \"summary\": \"...\"}

---
$(git diff HEAD)
$(git diff --cached)
" 2>/dev/null
```

#### ブランチ差分モード

```bash
BASE=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||'); BASE=${BASE:-main}
codex exec --model gpt-5.3-codex --sandbox read-only --full-auto "
Review the following branch changes against ${BASE}. Identify:
1. Bugs or logic errors
2. Security concerns
3. Type safety issues
4. Code style or readability problems
5. Missing error handling

Be specific and concise. Reference file paths and line numbers.
Output JSON: {\"issues\": [{\"file\": \"...\", \"line\": N, \"severity\": \"critical|warning|info\", \"message\": \"...\"}], \"summary\": \"...\"}

---
$(git diff ${BASE}...HEAD)
" 2>/dev/null
```

### 3. 結果の抽出

```bash
# JSON 出力から issues を抽出
echo '<codex output>' | jq '.issues'
```

### 4. 結果評価と対応

- critical issues あり → 該当ファイルを Read し、Edit で修正を適用
- warning のみ → ユーザーに共有し、修正するか確認
- info のみ / 問題なし → レビュー完了を報告

### 5. 修正後の再レビュー

修正を行った場合、ステップ 1 に戻り再レビューを実行する。
問題が 0 件になるまで繰り返す（最大 3 回）。
3 回で解決しない場合は残存 issues を報告し、ユーザーに判断を委ねる。
