---
name: gh-create-pr
description: |
  PRテンプレートを読んでGitHub プルリクエストを作成する。
  Use when: creating a PR, making a pull request, プルリクエスト作成, PR作成, PRを出す, PRテンプレ, プルリク,
  プルリクエスト, pull request, create PR, open PR, 差分をPRにする.
  Reads .github/PULL_REQUEST_TEMPLATE.md (or similar) and fills it based on git diff,
  then runs `gh pr create`.
---

# gh-create-pr

PRテンプレートを読んでプルリクエストを作成するスキル。

## Workflow

### Step 1: テンプレート検索

以下の順序でPRテンプレートを検索する:

1. `.github/PULL_REQUEST_TEMPLATE.md`
2. `.github/PULL_REQUEST_TEMPLATE/*.md`（複数ある場合はユーザーに選択を求める）
3. `PULL_REQUEST_TEMPLATE.md`
4. テンプレートが見つからない場合は最小限のデフォルト構造を使用

### Step 2: 変更内容の把握

```bash
# ベースブランチとの差分を確認
git log main..HEAD --oneline
git diff main..HEAD --stat
```

- コミット一覧とファイル変更の概要を把握する
- 変更の目的・影響範囲をコードから読み取る

### Step 3: テンプレート記入

テンプレートの各セクションを変更内容に基づいて記入する。記入方針:

- 概要/Summary: 変更の目的を1〜3文で要約
- 種別/Type: 変更種別（feature/fix/chore等）を選択
- 影響範囲: 変更が及ぶ機能・レイヤーを特定
- 関連Issue: コミットメッセージや変更内容からIssue番号を推定（不明な場合は空欄）
- 確認済み/Checklist: 実行済みの検証項目にチェック

### Step 4: PR作成

```bash
# タイトルは最初のコミットメッセージまたは変更内容から生成
gh pr create \
  --title "<生成したタイトル>" \
  --body "$(cat <<'EOF'
<記入済みテンプレート>
EOF
)"
```

- `--draft` は明示的に指定された場合のみ付与
- `--base` は明示的に指定された場合のみ付与（デフォルトはリポジトリの default branch）

## 出力

- PR URL を出力して完了を報告する
- 日本語で応答する

## 注意事項

- 既存PRが存在する場合は警告してユーザーに確認を求める（`gh pr list --head <branch>` で確認）
- `gh` CLIが未認証の場合は `gh auth login` を案内する
- テンプレートが複数ある場合はユーザーに選択を求める
