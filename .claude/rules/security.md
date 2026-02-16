# セキュリティルール

このドキュメントは、dotfilesプロジェクトにおけるセキュリティベストプラクティスとガイドラインを定義します。

## 目次

- [秘密情報の分類](#秘密情報の分類)
- [.gitignoreパターン](#gitignoreパターン)
- [Pre-commit Hooksの使用](#pre-commit-hooksの使用)
- [セキュリティ監査チェックリスト](#セキュリティ監査チェックリスト)
- [インシデント対応手順](#インシデント対応手順)

---

## 秘密情報の分類

### レベル1: 高度に機密性の高い情報

**絶対にコミットしてはいけない**：

- **SSH秘密鍵**: `id_rsa`, `id_ed25519`, `*.pem`
- **GPG秘密鍵**: `secring.gpg`, `*.key`
- **APIトークン**: GitHub Personal Access Tokens, AWS Credentials
- **パスワード**: 平文パスワード、データベース認証情報
- **証明書秘密鍵**: `*.key`, `*.p12`, `*.pfx`

**除外パターン** (`.gitignore`):

```gitignore
# SSH keys
**/.ssh/*_rsa
**/.ssh/*_ed25519
**/.ssh/*.pem

# GPG keys
**/.gnupg/private-keys-v1.d/
**/.gnupg/secring.gpg

# API credentials
**/.aws/credentials
**/.config/gh/hosts.yml
```

### レベル2: 個人固有の情報

**環境ごとに異なる値、公開非推奨**：

- **環境変数ファイル**: `.env`, `.env.local`, `.envrc`
- **設定ファイルのローカル上書き**: `config.local`, `*.secret`
- **セッショントークン**: ブラウザcookies、一時認証トークン

**除外パターン** (`.gitignore`):

```gitignore
# Environment variables
.env
.env.*
!.env.example
.envrc

# Local configuration overrides
*.local
*.secret
```

### レベル3: 一時ファイルとビルド成果物

**機密性は低いが、リポジトリサイズ肥大化の原因**：

- **ビルド成果物**: `result`, `result-*`, `dist/`, `build/`
- **一時ファイル**: `*.tmp`, `*.log`, `.DS_Store`
- **依存関係キャッシュ**: `node_modules/`, `.venv/`, `__pycache__/`

**除外パターン** (`.gitignore`):

```gitignore
# Build artifacts
result
result-*
dist/
build/

# Temporary files
*.tmp
*.log
.DS_Store

# Dependencies
node_modules/
.venv/
__pycache__/
```

---

## .gitignoreパターン

### 現在の.gitignoreカバレッジ

プロジェクトの `.gitignore` は273行で、以下をカバーしています：

- **SSH keys**: 完全カバー（秘密鍵、known_hosts）
- **GPG keys**: 完全カバー（秘密鍵、トラストDB）
- **API credentials**: 完全カバー（AWS、GitHub、Linear等）
- **環境変数**: 完全カバー（`.env*`, `.envrc`）
- **Nix成果物**: 完全カバー（`result*`, `.luarocks/`）
- **IDE設定**: 完全カバー（`.vscode/`, `.idea/`）

### .gitignoreメンテナンス

新しいツールや設定を追加する際は、以下を確認：

1. **秘密情報を含む可能性**: → `.gitignore` に追加
2. **環境固有の設定**: → `.gitignore` に追加、`.example` ファイルを提供
3. **一時ファイル**: → `.gitignore` に追加

**例**: 新しいツール `newtool` を追加する場合：

```bash
# 秘密情報を含む設定ファイルを除外
echo "**/.config/newtool/credentials" >> .gitignore

# 環境固有の設定を除外
echo "**/.config/newtool/*.local" >> .gitignore

# exampleファイルを提供
cp .config/newtool/config.local .config/newtool/config.local.example
```

---

## Pre-commit Hooksの使用

### gitleaksフック

**目的**: コミット前に秘密情報をスキャンし、誤ってコミットすることを防止

**設定ファイル**: `.pre-commit-config.yaml`

```yaml
# Security scanning
- repo: https://github.com/gitleaks/gitleaks
  rev: v8.21.2
  hooks:
    - id: gitleaks
```

### セットアップ手順

#### 初回セットアップ

```bash
# 1. pre-commitとgitleaksをインストール（miseで管理済み）
mise install

# 2. gitleaksセットアップスクリプトを実行
sh ./scripts/setup-gitleaks.sh

# 3. オプション: ベースライン作成（既存の警告を無視）
sh ./scripts/setup-gitleaks.sh --create-baseline
```

#### 日常的な使用

```bash
# 通常のコミット（自動的にgitleaksが実行される）
git commit -m "feat: add new feature"

# gitleaksのみを手動実行
pre-commit run gitleaks --all-files

# すべてのフックを実行
pre-commit run --all-files
```

### gitleaks警告への対応

#### False Positiveの場合

1. **ベースラインに追加** (`.gitleaksignore`):

   ```bash
   # ベースラインを再生成
   sh ./scripts/setup-gitleaks.sh --create-baseline
   ```

2. **個別にコメントで除外**:

   ```python
   # gitleaks:allow
   API_KEY = "example_key_for_documentation"
   ```

#### True Positiveの場合

1. **即座にコミットを中止**
2. **秘密情報を削除または環境変数に移行**
3. **該当ファイルを `.gitignore` に追加**
4. **既にコミット済みの場合**: → [インシデント対応手順](#インシデント対応手順) を参照

### pre-commitフックのバイパス（非推奨）

**緊急時のみ使用** - 通常は推奨されません：

```bash
# すべてのフックをスキップ（非推奨）
git commit --no-verify -m "emergency fix"

# 特定のフックのみスキップ（gitleaks以外を実行）
SKIP=gitleaks git commit -m "commit message"
```

**バイパスする前に**:

- なぜスキップする必要があるのか？
- 本当にセキュリティリスクがないか？
- 後でレビューする計画はあるか？

---

## セキュリティ監査チェックリスト

### 定期監査（月次推奨）

```bash
# 1. 全ファイルでgitleaksスキャン
pre-commit run gitleaks --all-files

# 2. .gitignoreのカバレッジ確認
git ls-files -o --exclude-standard | grep -E "\.(env|key|pem|credentials)$"

# 3. SSH鍵のパーミッション確認
find ~/.ssh -type f -name "id_*" ! -name "*.pub" -exec ls -la {} \;

# 4. GPG鍵の有効期限確認
gpg --list-keys --with-colons | grep "^pub"

# 5. GitHub Personal Access Tokenの確認
gh auth status

# 6. AWS Credentialsの確認
aws sts get-caller-identity
```

### コミット前チェック（毎回）

```bash
# 1. ステージされたファイルの確認
git diff --cached --name-only

# 2. ステージされた変更の内容確認
git diff --cached

# 3. 秘密情報が含まれていないか目視確認
# - パスワード、トークン、APIキー
# - 個人情報（メールアドレス、電話番号）
# - 内部サーバー情報（IPアドレス、ホスト名）
```

### 新規ツール追加時チェック

```bash
# 1. 設定ファイルの場所確認
echo "New tool config: ~/.config/newtool/"

# 2. 秘密情報を含むファイルを特定
ls -la ~/.config/newtool/ | grep -E "(credential|secret|token|key)"

# 3. .gitignoreに追加
echo "**/.config/newtool/credentials" >> .gitignore

# 4. exampleファイル作成
cp ~/.config/newtool/config.secret ~/.config/newtool/config.secret.example
# 秘密情報をプレースホルダーに置換
sed -i '' 's/actual_secret/YOUR_SECRET_HERE/g' ~/.config/newtool/config.secret.example
```

---

## インシデント対応手順

### シナリオ1: 秘密情報を誤ってコミットした（プッシュ前）

**影響**: ローカルのみ、リモートには影響なし

**対応**:

```bash
# 1. 最新コミットを取り消し（変更は保持）
git reset --soft HEAD~1

# 2. 秘密情報を削除または環境変数に移行
rm path/to/secret/file
# または
mv path/to/secret/file path/to/secret/file.example

# 3. .gitignoreに追加
echo "path/to/secret/file" >> .gitignore

# 4. 再度コミット
git add .gitignore
git commit -m "fix: remove secret and update .gitignore"
```

### シナリオ2: 秘密情報をプッシュしてしまった

**影響**: リモートリポジトリに秘密情報が露出

**緊急対応（10分以内）**:

```bash
# 1. 秘密情報を即座に無効化
# - GitHub Personal Access Token: https://github.com/settings/tokens で削除
# - AWS Credentials: AWS Console で無効化
# - SSH Key: ~/.ssh/authorized_keys から削除

# 2. プッシュしたブランチを削除（可能な場合）
git push origin --delete branch-name

# 3. チームに通知（プライベートリポジトリの場合）
# Slack/Teams等で即座に報告
```

**恒久対応（1時間以内）**:

```bash
# 1. git-filter-repoで履歴から削除
# 注意: これは破壊的操作です。バックアップを取ってから実行してください。

# git-filter-repoをインストール
brew install git-filter-repo

# 秘密情報を含むファイルを履歴から完全削除
git filter-repo --path path/to/secret/file --invert-paths

# 2. 強制プッシュ（チーム全員に通知後）
git push --force-with-lease origin main

# 3. チーム全員に再クローンを依頼
# 古いクローンには秘密情報が残っているため
```

**事後対応（1日以内）**:

1. **インシデントレポート作成**:
   - 何が漏洩したか
   - いつプッシュされたか
   - 誰がアクセス可能だったか
   - どのように無効化したか

2. **再発防止策**:
   - `.gitignore` にパターン追加
   - pre-commitフックの強化
   - チームへのセキュリティトレーニング

3. **影響範囲の確認**:
   - GitHub Advanced Securityでスキャン（Enterpriseの場合）
   - gitleaksで全履歴スキャン
   - 他のリポジトリへの影響確認

### シナリオ3: パブリックリポジトリで秘密情報を発見

**影響**: 誰でもアクセス可能、最高レベルの緊急対応

**即座に（5分以内）**:

```bash
# 1. すべての秘密情報を即座に無効化
# - パスワード変更
# - トークン削除
# - APIキー再生成

# 2. リポジトリを一時的にプライベートに変更（可能な場合）
# GitHub Settings → Danger Zone → Change visibility
```

**緊急対応（30分以内）**:

```bash
# 1. 履歴から完全削除（シナリオ2と同様）
git filter-repo --path path/to/secret/file --invert-paths
git push --force-with-lease origin main

# 2. GitHub Supportに連絡してキャッシュ削除を依頼
# https://support.github.com/contact
# 件名: "Remove cached sensitive data from public repository"
```

**事後対応（1週間以内）**:

1. **セキュリティ監査**:
   - すべての設定ファイルをレビュー
   - `.gitignore` を徹底的に見直し
   - pre-commitフックを必須化

2. **アクセスログ確認**:
   - GitHub Insightsで誰がクローンしたか確認
   - 外部からのアクセスがあった場合、影響範囲を調査

3. **チームトレーニング**:
   - セキュリティベストプラクティスの再教育
   - インシデント事例の共有

---

## 参考資料

### 内部ドキュメント

- `.gitignore` - 除外パターン定義（273行）
- `.pre-commit-config.yaml` - pre-commitフック設定
- `scripts/setup-gitleaks.sh` - gitleaksセットアップスクリプト
- `.claude/rules/troubleshooting.md` - トラブルシューティングガイド

### 外部リソース

- [GitHub: Removing sensitive data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
- [Gitleaks Documentation](https://github.com/gitleaks/gitleaks)
- [Pre-commit Documentation](https://pre-commit.com/)
- [OWASP: Secrets Management](https://owasp.org/www-community/vulnerabilities/Use_of_hard-coded_password)

---

**最終更新**: 2026-02-16
**次回レビュー予定**: 2026-05-16（四半期後）
