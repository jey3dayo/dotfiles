# Security and Credentials

MCPサーバーのセキュリティベストプラクティスと認証情報管理。センシティブ情報を安全に管理する方法を詳細に解説します。

## 概要

このドキュメントでは、MCPサーバー設定時のセキュリティリスク、安全な認証情報管理方法、ベストプラクティス、セキュリティチェックリストを提供します。

---

## セキュリティリスクの理解

### ⚠️ 一般的な脆弱性

#### 1. 平文パスワードの保存

**問題**:

```json
{
  "mcpServers": {
    "mysql": {
      "env": {
        "MYSQL_PASSWORD": "my_secret_password" // ❌ 平文で保存
      }
    }
  }
}
```

**リスク**:

- 設定ファイルがGitにコミットされる
- 他のユーザーに見られる
- パスワードが漏洩する

#### 2. 過度な権限付与

**問題**:

```json
{
  "mcpServers": {
    "filesystem": {
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/" // ❌ ルートディレクトリ全体にアクセス
      ]
    }
  }
}
```

**リスク**:

- システムファイルへのアクセス
- 意図しない削除・変更
- セキュリティホール

#### 3. トークンのスコープ過多

**問題**:

```
GitHub Token with full `repo`, `admin:org`, `delete_repo` scopes
// ❌ 必要以上の権限
```

**リスク**:

- リポジトリの削除
- 組織設定の変更
- 重要データの漏洩

---

## セキュアな認証情報管理

### 方法1: 環境変数の活用

**推奨度**: ⭐️⭐️⭐️⭐️

**セットアップ手順**:

```bash
# 1. シェル設定ファイルに追加
# ~/.zshrc または ~/.bashrc

# データベース認証情報
export MYSQL_ROOT_PASSWORD="secure_password_here"
export MYSQL_DATABASE="myapp_dev"
export POSTGRES_CONNECTION_STRING="postgresql://user:pass@localhost/db"

# API トークン
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"
export SLACK_BOT_TOKEN="xoxb-xxxxxxxxxxxx"
export BRAVE_API_KEY="BSAxxxxxxxxxxxx"
export OPENAI_API_KEY="sk-xxxxxxxxxxxx"

# AWS認証情報
export AWS_ACCESS_KEY_ID="AKIAxxxxxxxxxxxx"
export AWS_SECRET_ACCESS_KEY="xxxxxxxxxxxx"
export AWS_REGION="us-east-1"
```

```bash
# 2. シェル設定を再読み込み
source ~/.zshrc
```

```json
// 3. 設定ファイルで環境変数を参照
{
  "mcpServers": {
    "github": {
      "command": "sh",
      "args": [
        "-c",
        "GITHUB_PERSONAL_ACCESS_TOKEN=$GITHUB_TOKEN npx -y @github/github-mcp-server"
      ]
    },
    "mysql": {
      "command": "sh",
      "args": [
        "-c",
        "MYSQL_HOST=127.0.0.1 MYSQL_PORT=3306 MYSQL_USER=root MYSQL_PASSWORD=$MYSQL_ROOT_PASSWORD MYSQL_DATABASE=$MYSQL_DATABASE node /path/to/mysql-server.js"
      ]
    }
  }
}
```

**利点**:

- ✅ 設定ファイルに平文パスワードなし
- ✅ 環境別に異なる値を使用可能
- ✅ Gitにコミットしても安全

**欠点**:

- ❌ シェル設定ファイルも保護が必要
- ❌ ユーザー切り替え時に再設定が必要

---

### 方法2: 別ファイルでの管理

**推奨度**: ⭐️⭐️⭐️⭐️⭐️

**セットアップ手順**:

```bash
# 1. 専用ディレクトリ作成
mkdir -p ~/.claude/secrets
chmod 700 ~/.claude/secrets

# 2. 認証情報ファイル作成
cat > ~/.claude/secrets/.env << EOF
MYSQL_ROOT_PASSWORD=secure_password_here
GITHUB_TOKEN=ghp_xxxxxxxxxxxx
SLACK_BOT_TOKEN=xoxb-xxxxxxxxxxxx
BRAVE_API_KEY=BSAxxxxxxxxxxxx
OPENAI_API_KEY=sk-xxxxxxxxxxxx
EOF

# 3. ファイル権限を制限
chmod 600 ~/.claude/secrets/.env

# 4. .gitignoreに追加
echo ".claude/secrets/" >> ~/.gitignore
```

```bash
# 5. シェル設定で読み込み
# ~/.zshrcに追加
if [ -f ~/.claude/secrets/.env ]; then
    export $(cat ~/.claude/secrets/.env | xargs)
fi
```

**利点**:

- ✅ 認証情報が集中管理
- ✅ .gitignoreで確実に除外
- ✅ ファイル権限で保護

**欠点**:

- ❌ バックアップ管理が必要
- ❌ チーム共有時の手順が増える

---

### 方法3: macOS Keychainの活用

**推奨度**: ⭐️⭐️⭐️⭐️⭐️ (macOSのみ)

**セットアップ手順**:

```bash
# 1. Keychainにパスワードを保存
security add-generic-password \
  -a $USER \
  -s mysql_root_password \
  -w "secure_password_here"

security add-generic-password \
  -a $USER \
  -s github_token \
  -w "ghp_xxxxxxxxxxxx"

# 2. 保存されたか確認
security find-generic-password -a $USER -s mysql_root_password -w

# 3. 設定ファイルでKeychainから取得
```

```json
{
  "mcpServers": {
    "mysql": {
      "command": "sh",
      "args": [
        "-c",
        "MYSQL_PASSWORD=$(security find-generic-password -a $USER -s mysql_root_password -w) MYSQL_HOST=127.0.0.1 MYSQL_PORT=3306 MYSQL_USER=root MYSQL_DATABASE=mydb node /path/to/mysql-server.js"
      ]
    },
    "github": {
      "command": "sh",
      "args": [
        "-c",
        "GITHUB_PERSONAL_ACCESS_TOKEN=$(security find-generic-password -a $USER -s github_token -w) npx -y @github/github-mcp-server"
      ]
    }
  }
}
```

**利点**:

- ✅ macOSネイティブの暗号化
- ✅ ファイルに平文で保存されない
- ✅ システムレベルのセキュリティ

**欠点**:

- ❌ macOS専用
- ❌ 初期セットアップが複雑

---

### 方法4: 1Passwordまたは他のパスワードマネージャー

**推奨度**: ⭐️⭐️⭐️⭐️⭐️

**1Password CLIの使用例**:

```bash
# 1. 1Password CLIをインストール
brew install --cask 1password-cli

# 2. 認証
eval $(op signin)

# 3. パスワードを保存
op item create \
  --category=password \
  --title="MySQL Root Password" \
  --vault="Development" \
  password="secure_password_here"

# 4. 設定ファイルで取得
```

```json
{
  "mcpServers": {
    "mysql": {
      "command": "sh",
      "args": [
        "-c",
        "MYSQL_PASSWORD=$(op item get 'MySQL Root Password' --fields password) node /path/to/mysql-server.js"
      ]
    }
  }
}
```

**利点**:

- ✅ 専用ツールによる暗号化
- ✅ チーム共有が簡単
- ✅ 監査ログ

**欠点**:

- ❌ 有料サービス
- ❌ 追加のセットアップ

---

## 権限の最小化

### Filesystem Serverのアクセス制限

**❌ 悪い例**:

```json
{
  "mcpServers": {
    "filesystem": {
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/username" // ホームディレクトリ全体
      ]
    }
  }
}
```

**✅ 良い例**:

```json
{
  "mcpServers": {
    "filesystem-projects": {
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/username/projects" // プロジェクトディレクトリのみ
      ]
    },
    "filesystem-docs": {
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/username/documents" // ドキュメントディレクトリのみ
      ]
    }
  }
}
```

**ベストプラクティス**:

- プロジェクトごとにサーバーを分ける
- 読み取り専用が必要な場合は別のインスタンス
- システムディレクトリは除外

### GitHub Tokenのスコープ制限

**❌ 悪い例**:

```
Scopes: repo, admin:org, delete_repo, workflow, write:packages
// すべての権限を付与
```

**✅ 良い例**:

```
Scopes: repo, read:org
// 必要最小限の権限のみ
```

**推奨スコープ**:

| 用途               | 必要なスコープ             |
| ------------------ | -------------------------- |
| リポジトリ読み書き | `repo`                     |
| 組織情報の読み取り | `read:org`                 |
| GitHub Actions実行 | `workflow`                 |
| Discussions管理    | `write:discussion`         |
| **避けるべき**     | `admin:org`, `delete_repo` |

### データベース接続のユーザー制限

**❌ 悪い例**:

```json
{
  "env": {
    "MYSQL_USER": "root" // root権限
  }
}
```

**✅ 良い例**:

```bash
# 1. 専用ユーザー作成
CREATE USER 'claude_app'@'localhost' IDENTIFIED BY 'secure_password';

# 2. 必要最小限の権限を付与
GRANT SELECT, INSERT, UPDATE ON myapp_dev.* TO 'claude_app'@'localhost';

# 3. 権限を反映
FLUSH PRIVILEGES;
```

```json
{
  "env": {
    "MYSQL_USER": "claude_app", // 専用ユーザー
    "MYSQL_DATABASE": "myapp_dev"
  }
}
```

---

## 環境別の設定管理

### 開発・ステージング・本番の分離

**ディレクトリ構造**:

```
~/.claude/
├── secrets/
│   ├── .env.development
│   ├── .env.staging
│   ├── .env.production
│   └── .gitignore
└── claude_desktop_config.json
```

**開発環境**:

```bash
# ~/.claude/secrets/.env.development
MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306
MYSQL_USER=dev_user
MYSQL_PASSWORD=dev_password
MYSQL_DATABASE=myapp_dev
```

**ステージング環境**:

```bash
# ~/.claude/secrets/.env.staging
MYSQL_HOST=staging-db.example.com
MYSQL_PORT=3306
MYSQL_USER=staging_user
MYSQL_PASSWORD=staging_password
MYSQL_DATABASE=myapp_staging
```

**本番環境**:

```bash
# ~/.claude/secrets/.env.production
MYSQL_HOST=prod-db.example.com
MYSQL_PORT=3306
MYSQL_USER=prod_readonly  # 読み取り専用
MYSQL_PASSWORD=prod_secure_password
MYSQL_DATABASE=myapp_prod
```

**シェル設定での環境切り替え**:

```bash
# ~/.zshrc
# デフォルトは開発環境
export CLAUDE_ENV=${CLAUDE_ENV:-development}

if [ -f ~/.claude/secrets/.env.$CLAUDE_ENV ]; then
    export $(cat ~/.claude/secrets/.env.$CLAUDE_ENV | xargs)
fi
```

**使用方法**:

```bash
# 開発環境（デフォルト）
open -a Claude

# ステージング環境
CLAUDE_ENV=staging open -a Claude

# 本番環境
CLAUDE_ENV=production open -a Claude
```

---

## セキュリティチェックリスト

### 設定ファイル

- [ ] 平文パスワードが含まれていないか
- [ ] APIキー・トークンが平文で保存されていないか
- [ ] 設定ファイルを.gitignoreに追加したか
- [ ] JSON構文が正しいか（不正な構文はエラーの原因）

### 環境変数

- [ ] シェル設定ファイル（~/.zshrc）の権限を確認（600または644）
- [ ] 環境変数が正しく設定されているか（`echo $VAR_NAME`で確認）
- [ ] Claude Desktopが環境変数を読み込めているか

### 認証情報

- [ ] トークン・パスワードを定期的に変更しているか
- [ ] 不要なトークンを削除したか
- [ ] 本番環境では異なる認証情報を使用しているか
- [ ] トークンのスコープが最小限に制限されているか

### ファイルシステム

- [ ] Filesystem Serverのパスが適切に制限されているか
- [ ] システムディレクトリへのアクセスを禁止しているか
- [ ] 読み取り専用が必要なディレクトリを分離しているか

### データベース

- [ ] rootユーザーを使用していないか
- [ ] 専用ユーザーを作成し、権限を最小化したか
- [ ] 本番データベースへの直接アクセスを制限しているか
- [ ] 接続文字列にパスワードを平文で含めていないか

### ネットワーク

- [ ] プロキシ設定が適切か
- [ ] ファイアウォール設定が適切か
- [ ] VPN経由での接続が必要な場合は設定されているか

---

## 監査とログ管理

### Claude Desktopログの確認

```bash
# macOS
~/Library/Logs/Claude/

# 主要なログファイル
- main.log          # アプリケーションログ
- mcp.log           # MCPサーバーログ
- renderer.log      # UIレンダリングログ
```

**ログ確認コマンド**:

```bash
# 最新のMCPエラーを確認
tail -f ~/Library/Logs/Claude/mcp.log

# 特定のサーバーのログをフィルタ
grep "github" ~/Library/Logs/Claude/mcp.log

# エラーのみを表示
grep "ERROR" ~/Library/Logs/Claude/mcp.log
```

### 認証情報の監査

**定期的に確認すべき項目**:

1. **使用されていないトークン**

   ```bash
   # GitHubトークンの最終使用日を確認
   # GitHub Settings → Developer settings → Personal access tokens
   ```

2. **過度な権限を持つトークン**

   ```bash
   # トークンのスコープを確認
   curl -H "Authorization: token $GITHUB_TOKEN" \
        https://api.github.com/user
   ```

3. **漏洩の可能性**

   ```bash
   # 設定ファイルがGitにコミットされていないか確認
   git log --all --full-history -- "*config.json"
   ```

---

## インシデント対応

### 認証情報漏洩時の対処

**即座に実行**:

1. **トークン・パスワードの無効化**

   ```bash
   # GitHub Token
   # GitHub Settings → Developer settings → Personal access tokens
   # → Delete token

   # データベースパスワード
   ALTER USER 'username'@'localhost' IDENTIFIED BY 'new_secure_password';
   ```

2. **環境変数の更新**

   ```bash
   # 新しいトークンを設定
   export GITHUB_TOKEN="new_token_here"
   source ~/.zshrc
   ```

3. **設定ファイルの更新**

   ```bash
   # Claude Desktopを再起動
   osascript -e 'quit app "Claude"'
   open -a Claude
   ```

**フォローアップ**:

1. **影響範囲の調査**
   - 漏洩したトークンの使用履歴を確認
   - 不正アクセスの有無を調査

2. **再発防止策**
   - より安全な管理方法に移行（Keychain、1Password等）
   - セキュリティチェックリストの再確認
   - .gitignoreの徹底

3. **チーム通知**
   - 影響を受ける可能性のあるチームメンバーに通知
   - セキュリティポリシーの見直し

---

## ベストプラクティス まとめ

### 優先度: 高

1. **平文パスワードの排除**
   - 環境変数、Keychain、パスワードマネージャーを使用

2. **最小権限の原則**
   - Filesystem: 必要なディレクトリのみ
   - GitHub Token: 必要なスコープのみ
   - Database: 専用ユーザー、必要な権限のみ

3. **.gitignoreの徹底**
   - 設定ファイル、認証情報ファイルを除外

### 優先度: 中

1. **環境別の分離**
   - 開発・ステージング・本番で異なる認証情報

2. **定期的な監査**
   - トークンの使用状況確認
   - 不要なトークンの削除

3. **ログの監視**
   - エラーログの定期的な確認
   - 不正アクセスの検知

### 優先度: 低

1. **トークンのローテーション**
   - 3-6ヶ月ごとにトークン・パスワードを変更

2. **バックアップ**
   - 認証情報の安全なバックアップ（暗号化）

---

## 関連ドキュメント

- **server-configurations.md**: 全MCPサーバーの詳細設定
- **SKILL.md**: MCP Toolsクイックスタートガイド

このドキュメントは、MCPサーバーのセキュリティを最大化するための包括的なガイドです。セキュリティは継続的なプロセスであり、定期的な見直しと改善が重要です。
