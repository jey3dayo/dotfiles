# トラブルシューティング

code-review-systemのよくある問題と解決方法です。

## チェックポイント関連

### チェックポイント作成が失敗する

### 症状

```
error: Nothing added to the commit but untracked files present
Pre-review checkpoint failed
```

### 原因

- 変更がステージされていない
- すべてのファイルが.gitignoreで除外されている

### 解決方法

```bash
# ステージされた変更を確認
git status

# 変更があればステージ
git add <file>

# 変更がない場合は正常（レビューは続行される）
# "No changes to commit" は問題ではない
```

### 注意

### チェックポイントのリストを確認したい

### コマンド

```bash
# 最近のコミットを確認
git log --oneline --grep="Pre-review checkpoint" | head -10

# または
git log --oneline | grep "Pre-review checkpoint" | head -10
```

### 期待される出力

```
abc1234 Pre-review checkpoint
def5678 Pre-review checkpoint
ghi9012 Pre-review checkpoint
```

### チェックポイントに戻したい

### コマンド

```bash
# チェックポイントのハッシュを確認
git log --oneline --grep="Pre-review checkpoint" | head -1

# チェックポイントに戻す（変更を破棄）
git reset --hard <checkpoint-hash>

# または、変更を保持したままチェックポイント後の変更を見る
git diff <checkpoint-hash>
```

## GitHub issue関連

### GitHub issue作成が失敗する

### 症状

```
error: gh: command not found
GitHub issue creation failed
```

### 原因

### 解決方法

```bash
# macOS
brew install gh

# Linux
# https://github.com/cli/cli#installation

# インストール後、認証
gh auth login

# 認証状態を確認
gh auth status
```

### issue作成時に認証エラーが出る

### 症状

```
error: authentication failed
```

### 原因

### 解決方法

```bash
# 認証状態を確認
gh auth status

# 再認証
gh auth login

# トークンを手動で設定する場合
gh auth login --with-token < token.txt
```

### 作成されたissueを確認したい

### コマンド

```bash
# 最近のissueを確認
gh issue list --limit 10

# 特定のissueを確認
gh issue view <issue-number>

# ブラウザで確認
gh issue view <issue-number> --web
```

## Serenaオプション関連

### Serenaオプションが動作しない

### 症状

```
error: Serena MCP server not found
--with-impact option ignored
```

### 原因

### 解決方法

#### 1. MCP設定ファイルを確認

```bash
# MCP設定ファイルの存在を確認
ls -la ~/.claude/mcp.json

# または
cat ~/.claude/mcp.json | grep serena
```

### 期待される内容

```json
{
  "mcpServers": {
    "serena": {
      "command": "npx",
      "args": ["-y", "@serena/mcp-server"],
      "env": {}
    }
  }
}
```

#### 2. Serena MCPサーバーのインストール

```bash
# npm経由でインストール
npm install -g @serena/mcp-server

# または、npx経由で実行（インストール不要）
npx -y @serena/mcp-server --version
```

#### 3. Claude Codeの再起動

MCP設定変更後は、Claude Codeを再起動してください。

### Serenaオプションが遅い

### 症状

### 原因

### 解決方法

```bash
# 対象ファイルを限定する
/review --staged --with-impact  # ステージされたファイルのみ

# または、通常のレビューを使用
/review --staged  # Serenaなし
```

## プロジェクト判定関連

### プロジェクトタイプが誤検出される

### 症状

### 原因

### デバッグ方法

```bash
# プロジェクトタイプを確認するスクリプトを実行
# （将来実装予定）
/review --debug-project-type
```

### 暫定的な解決方法

プロジェクト固有のガイドラインファイルで明示的に指定：

```markdown
# .claude/review-guidelines.md

## プロジェクト情報

- プロジェクトタイプ: nextjs
- 統合スキル: typescript, react, security
```

### 技術スタック別スキルが統合されない

### 症状

### 原因

### 解決方法

```bash
# スキルの存在を確認
ls ~/.claude/skills/
ls ~/src/github.com/jey3dayo/claude-code-marketplace/plugins/dev-tools/

# Marketplaceプラグインを確認
cat ~/.claude/config.json | grep marketplace

# Marketplaceプラグインを追加（未追加の場合）
# .claude/config.json に以下を追加
{
  "plugins": [
    {
      "path": "~/src/github.com/jey3dayo/claude-code-marketplace"
    }
  ]
}
```

## レビューモード関連

### シンプルモードが期待通りに動作しない

### 症状

### 原因

### 解決方法

```bash
# code-reviewスキルの更新
cd ~/src/github.com/jey3dayo/claude-code-marketplace
git pull

# または、Marketplaceプラグインを再追加
# .claude/config.json を編集して Claude Code を再起動
```

### 詳細モードの⭐️評価が表示されない

### 症状

### 原因

### 解決方法

```bash
# code-reviewスキルの更新
cd ~/src/github.com/jey3dayo/claude-code-marketplace/plugins/dev-tools/code-review
git pull

# 日本語出力が設定されているか確認
grep -r "日本語" ~/.claude/skills/code-review-system/
```

## CI診断モード関連

### CI診断モードでPR番号が見つからない

### 症状

```
error: PR not found for current branch
```

### 原因

### 解決方法

```bash
# PR番号を明示的に指定
/review --fix-ci 123

# または、PRを作成
gh pr create

# PRが存在するか確認
gh pr list --head $(git branch --show-current)
```

### CI診断モードでログが取得できない

### 症状

```
error: Failed to fetch CI logs
```

### 原因

### 解決方法

```bash
# GitHub Actionsの実行状況を確認
gh pr checks <pr-number>

# gh CLIの権限を確認
gh auth status

# 必要に応じて再認証
gh auth refresh -s repo
```

## PRコメント修正モード関連

### PRコメントが取得できない

### 症状

```
error: No review comments found
```

### 原因

### 解決方法

```bash
# PRコメントを確認
gh pr view <pr-number> --comments

# gh CLIの権限を確認
gh auth status

# 必要に応じて再認証
gh auth refresh -s repo
```

### 特定のボットのコメントのみを修正したい

### コマンド

```bash
# coderabbitai のコメントのみ修正
/review --fix-pr --bot coderabbitai

# github-actions のコメントのみ修正
/review --fix-pr --bot github-actions
```

## パフォーマンス関連

### レビューが非常に遅い

### 症状

### 原因

### 解決方法

```bash
# 対象を限定する
/review --staged  # ステージされたファイルのみ
/review --recent  # 直前のコミットのみ

# シンプルモードを使用（詳細モードより高速）
/review --simple --staged

# Serenaオプションを外す
/review --staged  # --with-impact を使わない
```

### 大規模なプロジェクトでレビューがタイムアウトする

### 症状

### 原因

### 解決方法

```bash
# ファイルを分割してレビュー
/review --staged  # まずステージされたファイル
/review src/api/  # 次にapiディレクトリ
/review src/components/  # 次にcomponentsディレクトリ

# または、除外ルールを設定
# .claude/review-guidelines.md に以下を追加
## 除外ルール
- generated/
- node_modules/
- dist/
```

## 一般的なトラブルシューティング

### レビュー結果が日本語で出力されない

### 症状

### 原因

### 解決方法

```bash
# CLAUDE.md に日本語出力設定があるか確認
cat ~/.claude/CLAUDE.md | grep "日本語"
cat .claude/CLAUDE.md | grep "日本語"

# code-review-systemスキルの設定を確認
cat ~/.claude/skills/code-review-system/SKILL.md | grep "日本語"
```

### コマンドが認識されない

### 症状

```
error: /review: command not found
```

### 原因

### 解決方法

```bash
# コマンドファイルの存在を確認
ls ~/.claude/commands/review.md
ls ~/src/github.com/jey3dayo/claude-code-marketplace/commands/review.md

# Claude Codeを再起動
```

### スキルが見つからない

### 症状

```
error: code-review skill not found
```

### 原因

### 解決方法

```bash
# スキルの存在を確認
ls ~/.claude/skills/code-review-system/

# Marketplaceプラグインの確認
ls ~/src/github.com/jey3dayo/claude-code-marketplace/plugins/dev-tools/code-review/

# Claude Codeを再起動
```

## デバッグ方法

### デバッグログの有効化

```bash
# 環境変数でデバッグログを有効化（将来実装予定）
export CLAUDE_DEBUG=1
/review --staged

# または、コマンドに--debugフラグを追加（将来実装予定）
/review --staged --debug
```

### ログファイルの確認

```bash
# Claude Codeのログを確認（場所は環境により異なる）
ls ~/.claude/logs/
tail -f ~/.claude/logs/claude.log
```

## 関連コマンド

レビューと関連するコマンド：

- `/fix`: 直接エラー修正を実行（error-fixerエージェント）
- `/todos`: TODOリスト管理
- `/learnings`: 学習データ閲覧
- `/task`: 汎用タスク実行

### fixコマンドとの使い分け

```bash
# レビュー結果に基づいて自動修正
/review --simple --fix

# 直接エラー修正（レビューなし）
/fix
```

### todosコマンドとの連携

```bash
# レビュー結果からTODOを作成
/review --create-issues

# TODOリストを確認
/todos

# TODOを修正
/fix-todos
```

### learningsコマンドとの連携

```bash
# レビュー結果を学習データとして記録
/review --learn

# 学習データを閲覧
/learnings list

# 特定のカテゴリを閲覧
/learnings show security
```

## よくある質問

### Q: レビュー結果を保存したい

### A

```bash
# ファイルにリダイレクト
/review > review-results.md

# または、--create-issues でGitHub issueとして保存
/review --create-issues
```

### Q: 複数のブランチをレビューしたい

### A

```bash
# 各ブランチでレビュー
git checkout feature/branch1
/review --branch main

git checkout feature/branch2
/review --branch main

git checkout feature/branch3
/review --branch main
```

### Q: レビュー基準をカスタマイズしたい

### A

```bash
# .claude/review-guidelines.md を作成
cat > .claude/review-guidelines.md << 'EOF'
# プロジェクト固有レビューガイドライン

## 評価基準

### セキュリティ（重要度: 最高）
- OWASP Top 10準拠必須

### 型安全性（重要度: 高）
- any型使用禁止

### パフォーマンス（重要度: 中）
- API応答時間200ms以内
EOF
```

## まとめ

主要なトラブルシューティング：

1. チェックポイント: 変更がない場合は正常
2. GitHub issue: gh CLIのインストールと認証を確認
3. Serena: MCP設定を確認、大規模プロジェクトでは使用を控える
4. プロジェクト判定: ガイドラインファイルで明示的に指定
5. パフォーマンス: 対象を限定、シンプルモードを使用

問題が解決しない場合は、デバッグログを有効化して詳細を確認してください。
