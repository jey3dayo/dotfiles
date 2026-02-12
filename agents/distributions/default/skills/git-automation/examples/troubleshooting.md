# Troubleshooting - トラブルシューティング

git-automationスキルのよくある問題と解決策です。

## Commit関連

### Q1: "No changes to commit" エラー

### 症状

```
No changes to commit
```

### 原因

### 解決策

```bash
# 変更ファイルをステージング
git add -u

# または特定ファイル
git add src/file.ts

# コミット
/git-automation commit
```

### Q2: Lint失敗でコミットできない

### 症状

```
❌ Lint: 失敗
src/file.ts:10:5 - error TS2345: ...
```

### 解決策

```bash
# 方法1: 自動修正
npm run lint -- --fix
/git-automation commit

# 方法2: 手動修正
# ... エラー修正 ...
/git-automation commit

# 方法3: Lintをスキップ（非推奨）
/git-automation commit --skip-lint
```

### Q3: Test失敗でコミットできない

### 症状

```
❌ Test: 失敗
FAIL src/auth.test.ts
```

### 解決策

```bash
# 方法1: テスト修正
npm test
# ... テスト修正 ...
/git-automation commit

# 方法2: テストをスキップ（非推奨）
/git-automation commit --skip-tests
```

### Q4: Build失敗でコミットできない

### 症状

```
❌ Build: 失敗
TS2322: Type 'string' is not assignable to type 'number'
```

### 解決策

```bash
# 方法1: 型エラー修正
npm run build
# ... エラー修正 ...
/git-automation commit

# 方法2: Buildをスキップ（非推奨）
/git-automation commit --skip-build
```

### Q5: コミットメッセージが不適切

### 症状

### 解決策

```bash
# 方法1: 手動でメッセージ指定
/git-automation commit "feat(auth): add login functionality"

# 方法2: コミット後に修正
/git-automation commit
git commit --amend -m "新しいメッセージ"
```

### Q6: 品質チェックが遅すぎる

### 症状

### 解決策

```bash
# 開発中: テストをスキップ
/git-automation commit --skip-tests

# レビュー前: 完全チェック
/git-automation commit
```

## PR関連

### Q7: フォーマッター未検出

### 症状

```
⚠️  フォーマッターが検出されませんでした
```

### 解決策

```bash
# 方法1: package.json に format スクリプトを追加
{
  "scripts": {
    "format": "prettier --write ."
  }
}

# 方法2: 手動でフォーマット後にスキップ
npm run format
/git-automation pr --no-format

# 方法3: フォーマッター指定
/git-automation pr --formatter "deno fmt"
```

### Q8: 既存PRとの競合

### 症状

```
ℹ️  既存のPR検出:
   #123: Add authentication
   状態: OPEN
```

### 解決策

```bash
# 方法1: 既存PRを更新
/git-automation pr  # → 1. 更新 を選択

# または
/git-automation pr --update-if-exists

# 方法2: 新規PRを作成
/git-automation pr --force-new

# 方法3: 確認のみ
/git-automation pr --check-only
```

### Q9: GitHub CLI未認証

### 症状

```
❌ PR作成エラー: HTTP 401: Bad credentials
```

### 解決策

```bash
# 1. GitHub CLI認証
gh auth login

# 2. 状態確認
gh auth status

# 3. 再実行
/git-automation pr
```

### Q10: プッシュ失敗（権限不足）

### 症状

```
❌ プッシュ失敗: remote: Permission denied
```

### 解決策

```bash
# 1. リモートURL確認
git remote -v

# 2. HTTPS → SSH または逆
git remote set-url origin git@github.com:user/repo.git

# 3. 認証情報確認
gh auth status

# 4. 再実行
/git-automation pr
```

### Q11: ブランチ保護ルール違反

### 症状

```
❌ プッシュ失敗: protected branch
```

### 解決策

```bash
# main/master への直接プッシュは禁止

# 方法1: 別ブランチ作成
git checkout -b feature/new-feature
/git-automation pr

# 方法2: ブランチ指定
/git-automation pr --branch feature/new-feature
```

### Q12: PRテンプレート未検出

### 症状

```
⚠️  PRテンプレートが見つかりませんでした
```

### 解決策

```bash
# PRテンプレート作成
mkdir -p .github
cat > .github/PULL_REQUEST_TEMPLATE.md <<'EOF'
## 概要

## 変更内容

## テスト計画
EOF

# 再実行
/git-automation pr
```

### Q13: PR更新失敗

### 症状

```
❌ PR更新エラー: Could not resolve to a PullRequest
```

### 原因

### 解決策

```bash
# 1. PR一覧確認
gh pr list

# 2. 新規PR作成
/git-automation pr --force-new
```

### Q14: PRタイトルが不適切

### 症状

### 解決策

```bash
# タイトル指定
/git-automation pr "feat: ユーザー認証機能の追加"

# または PR作成後に編集
gh pr edit <PR番号> --title "新しいタイトル"
```

### Q15: PR本文が英語になる

### 症状

### 原因

### 解決策

```bash
# デフォルトは日本語生成
# CLAUDE.mdの設定を確認

# 強制的に日本語で生成する場合
# （通常は不要、デフォルトが日本語のため）
```

## 統合環境関連

### Q16: project-detector未動作

### 症状

### 解決策

```bash
# package.json, go.mod 等が存在するか確認
ls -la

# ファイルが存在する場合は手動指定
/git-automation commit --skip-lint --skip-tests --skip-build
```

### Q17: CI/CDでの実行エラー

### 症状

### 解決策

```yaml
# GitHub Actions例
- name: Setup
  run: |
    # gh CLI認証
    echo "${{ secrets.GITHUB_TOKEN }}" | gh auth login --with-token

    # Node.js セットアップ
    npm install

- name: Create PR
  run: /git-automation pr --update-if-exists
```

### Q18: コミット分割が不適切

### 症状

### 解決策

```bash
# 方法1: 単一コミットに変更
/git-automation pr --single-commit

# 方法2: 手動でコミット
git add specific-files
git commit -m "..."
/git-automation pr --no-format
```

## パフォーマンス関連

### Q19: 品質チェックが遅い

### 症状

### 解決策

```bash
# 開発中は必要なチェックのみ
/git-automation commit --skip-tests --skip-build

# キャッシュ使用
npm test -- --cache
npm run build -- --incremental
```

### Q20: フォーマットが遅い

### 症状

### 解決策

```bash
# 方法1: 変更ファイルのみフォーマット
npm run format -- --changed

# 方法2: フォーマットをスキップ
/git-automation pr --no-format

# 方法3: 並列実行設定
# package.json
{
  "scripts": {
    "format": "prettier --write . --parallel"
  }
}
```

## その他

### Q21: Git設定が変更される

### 症状

### 原因

### 確認

```bash
# Git設定確認
git config --list

# git-automationは以下を絶対に行いません:
# - git config の変更
# - 認証情報の変更
# - 署名の追加
```

### Q22: コミットに署名が追加される

### 症状

### 原因

### 確認

```bash
# 最新のコミット確認
git log -1 --pretty=full

# git-automationは以下を絶対に追加しません:
# - Co-authored-by: Claude
# - Generated with Claude Code
# - その他のAI署名
```

### Q23: 絵文字が使用される

### 症状

### 原因

### 解決策

```bash
# CLAUDE.md に設定を追加
# 絵文字禁止設定があれば尊重されます

# ただし、PR本文の変更タイプ表示には絵文字を使用:
# ✨ feature
# 🐛 fix
# 📝 docs
```

## デバッグ方法

### 詳細ログの取得

```bash
# Git操作の詳細ログ
GIT_TRACE=1 /git-automation commit

# GitHub CLI のデバッグ
GH_DEBUG=1 /git-automation pr
```

### 手動実行での確認

```bash
# 品質チェック手動実行
npm run lint
npm test
npm run build

# フォーマット手動実行
npm run format

# GitHub PR操作手動実行
gh pr list
gh pr create
```

### ステータス確認

```bash
# Git状態
git status
git diff

# GitHub認証状態
gh auth status

# リモート状態
git remote -v
```

## サポート情報

問題が解決しない場合:

1. エラーメッセージの全文を確認
2. 環境情報を収集（OS、Node.jsバージョン等）
3. 再現手順を記録
4. 詳細ログを取得

### よくある原因

- GitHub CLI未認証
- プロジェクト設定ファイル不足（package.json等）
- 権限不足
- ネットワーク接続の問題
