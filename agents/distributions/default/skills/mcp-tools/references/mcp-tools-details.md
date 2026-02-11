# MCP Tools 詳細リファレンス

## 主要MCPサーバー

### 1. Memory Server - 会話間コンテキスト保持

### 用途

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

### 2. Filesystem Server - ファイル操作

### 用途

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/path/to/allowed/directory"
      ]
    }
  }
}
```

### セキュリティ

### 3. GitHub Server - GitHub統合（公式）

### 用途

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@github/github-mcp-server"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxxxxxxxxxxx"
      }
    }
  }
}
```

### セキュリティ

### 4. PostgreSQL/MySQL Server - データベース操作

### PostgreSQL

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "POSTGRES_CONNECTION_STRING": "postgresql://user:pass@localhost/db"
      }
    }
  }
}
```

### MySQL

```json
{
  "mcpServers": {
    "mysql": {
      "command": "node",
      "args": ["/path/to/@benborla29/mcp-server-mysql/dist/index.js"],
      "env": {
        "MYSQL_HOST": "127.0.0.1",
        "MYSQL_PORT": "3306",
        "MYSQL_USER": "root",
        "MYSQL_PASSWORD": "password",
        "MYSQL_DATABASE": "database"
      }
    }
  }
}
```

### セキュリティ

### 5. Brave Search - Web検索

### 用途

```json
{
  "mcpServers": {
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "your_api_key_here"
      }
    }
  }
}
```

### 6. Slack Server - Slack統合

### 用途

```json
{
  "mcpServers": {
    "slack": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-slack"],
      "env": {
        "SLACK_BOT_TOKEN": "xoxb-your-token",
        "SLACK_TEAM_ID": "T00000000"
      }
    }
  }
}
```

## セキュリティベストプラクティス

### ⚠️ やってはいけないこと

```json
// ❌ 悪い例: 設定ファイルに平文でパスワード
{
  "mcpServers": {
    "mysql": {
      "env": {
        "MYSQL_PASSWORD": "my_secret_password" // 平文で保存
      }
    }
  }
}
```

### ✅ 推奨される方法

#### 方法1: 環境変数の活用

```bash
# ~/.zshrc または ~/.bashrc に追加
export MYSQL_ROOT_PASSWORD="melody"
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"
export OPENAI_API_KEY="sk-xxxxxxxxxxxx"
```

設定ファイルで環境変数を参照:

```json
{
  "mcpServers": {
    "mysql": {
      "command": "sh",
      "args": [
        "-c",
        "MYSQL_PASSWORD=$MYSQL_ROOT_PASSWORD node /path/to/mysql-server.js"
      ]
    },
    "github": {
      "command": "sh",
      "args": [
        "-c",
        "GITHUB_PERSONAL_ACCESS_TOKEN=$GITHUB_TOKEN npx -y @github/github-mcp-server"
      ]
    }
  }
}
```

#### 方法2: 別ファイルでの管理

```bash
# ~/.claude/.env (gitignoreに追加)
MYSQL_ROOT_PASSWORD=melody
GITHUB_TOKEN=ghp_xxxxxxxxxxxx
OPENAI_API_KEY=sk-xxxxxxxxxxxx
```

#### 方法3: macOS Keychain活用

```bash
# パスワードをKeychainに保存
security add-generic-password -a $USER -s mysql_password -w "melody"

# 設定ファイルで取得
{
  "mcpServers": {
    "mysql": {
      "command": "sh",
      "args": [
        "-c",
        "MYSQL_PASSWORD=$(security find-generic-password -a $USER -s mysql_password -w) node /path/to/mysql-server.js"
      ]
    }
  }
}
```

### セキュリティチェックリスト

- [ ] 設定ファイルを.gitignoreに追加
- [ ] センシティブ情報を環境変数に移行
- [ ] 定期的にトークン・パスワードを変更
- [ ] 本番環境では異なる認証情報を使用
- [ ] アクセス権限を最小限に設定（Filesystem Server等）
- [ ] APIキーのスコープを制限（GitHub Token等）

## 複数サーバーの統合例

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/username/projects"
      ]
    },
    "github": {
      "command": "sh",
      "args": [
        "-c",
        "GITHUB_PERSONAL_ACCESS_TOKEN=$GITHUB_TOKEN npx -y @github/github-mcp-server"
      ]
    },
    "postgres": {
      "command": "sh",
      "args": [
        "-c",
        "POSTGRES_CONNECTION_STRING=$DATABASE_URL npx -y @modelcontextprotocol/server-postgres"
      ]
    }
  }
}
```

## トラブルシューティング

### サーバーが起動しない

### チェック項目

1. Node.jsがインストールされているか確認

   ```bash
   node --version
   npm --version
   npx --version
   ```

2. ログを確認
   - Claude Desktop → Settings → Developer → Logs

3. コマンドパスが正しいか確認

   ```bash
   # npxが利用可能か
   which npx

   # nodeが利用可能か
   which node
   ```

### 権限エラー

### 原因

### 解決策

1. パスの確認

   ```bash
   ls -la /path/to/allowed/directory
   ```

2. 環境変数の確認

   ```bash
   echo $GITHUB_TOKEN
   echo $MYSQL_ROOT_PASSWORD
   ```

3. シェル設定の再読み込み

   ```bash
   source ~/.zshrc
   # または
   source ~/.bashrc
   ```

### 環境変数が認識されない

### 原因

### 解決策

1. Claude Desktopを完全に終了

   ```bash
   osascript -e 'quit app "Claude"'
   ```

2. ターミナルから起動

   ```bash
   open -a Claude
   ```

3. または設定ファイル内で明示的に指定

   ```json
   {
     "mcpServers": {
       "github": {
         "command": "sh",
         "args": [
           "-c",
           "source ~/.zshrc && GITHUB_PERSONAL_ACCESS_TOKEN=$GITHUB_TOKEN npx -y @github/github-mcp-server"
         ]
       }
     }
   }
   ```

## 使用例

### 例1: 初めてのMCPサーバー設定

```bash
# 1. Memory Serverを追加（最もシンプル）
# 設定ファイルを開く
code ~/Library/Application\ Support/Claude/claude_desktop_config.json

# 2. 以下を追加
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}

# 3. Claude Desktopを再起動
osascript -e 'quit app "Claude"'
open -a Claude

# 4. 動作確認
# 新しいチャットで「覚えておいて」と指示
```

### 例2: GitHub統合（セキュアな方法）

```bash
# 1. GitHub Personal Access Tokenを環境変数に設定
# ~/.zshrcに追加
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"

# 2. シェル設定を再読み込み
source ~/.zshrc

# 3. 設定ファイルに追加
{
  "mcpServers": {
    "github": {
      "command": "sh",
      "args": [
        "-c",
        "GITHUB_PERSONAL_ACCESS_TOKEN=$GITHUB_TOKEN npx -y @github/github-mcp-server"
      ]
    }
  }
}

# 4. Claude Desktopを再起動
```

### 例3: データベース統合（MySQL）

```bash
# 1. 環境変数を設定
# ~/.zshrcに追加
export MYSQL_ROOT_PASSWORD="melody"
export MYSQL_DATABASE="myapp_dev"

# 2. 設定ファイルに追加
{
  "mcpServers": {
    "mysql": {
      "command": "sh",
      "args": [
        "-c",
        "MYSQL_HOST=127.0.0.1 MYSQL_PORT=3306 MYSQL_USER=root MYSQL_PASSWORD=$MYSQL_ROOT_PASSWORD MYSQL_DATABASE=$MYSQL_DATABASE node /path/to/mysql-server.js"
      ]
    }
  }
}

# 3. Claude Desktopを再起動
```

## ベストプラクティス

### 1. 段階的な導入

まずはMemory Serverから始め、必要に応じて追加:

```
Phase 1: Memory Server（シンプル、環境変数不要）
Phase 2: Filesystem Server（パス指定のみ）
Phase 3: GitHub/Slack等（トークン必要）
Phase 4: Database Server（認証情報必要）
```

### 2. 環境別の設定管理

```bash
# 開発環境
export MYSQL_DATABASE="myapp_dev"

# ステージング環境
export MYSQL_DATABASE="myapp_staging"

# 本番環境（異なる認証情報）
export MYSQL_DATABASE="myapp_prod"
export MYSQL_PASSWORD="different_secure_password"
```

### 3. 定期的なメンテナンス

- トークンの有効期限確認
- 不要なサーバーの削除
- ログの定期的なチェック
- アクセス権限の見直し

## 詳細リファレンス

より詳細な情報については、references/ディレクトリを参照してください:

- **server-configurations.md**: 全MCPサーバーの詳細設定とカタログ
- **security-and-credentials.md**: セキュリティ深掘り、認証情報管理のベストプラクティス

## 🤖 Agent Integration

このスキルはMCP統合タスクを実行するエージェントに専門知識を提供します:

### Orchestrator Agent

- **提供内容**: MCPサーバー設定ワークフロー、段階的導入戦略
- **タイミング**: MCPサーバー設定・外部ツール統合タスク実行時
- **コンテキスト**:
  - 主要MCPサーバー設定パターン（Memory, GitHub, Database等）
  - セキュリティベストプラクティス（環境変数、Keychain活用）
  - トラブルシューティング手順

### Researcher Agent

- **提供内容**: MCPサーバー調査、新規サーバー評価
- **タイミング**: 新しいMCPサーバーの調査・比較検討時
- **コンテキスト**: 利用可能なMCPサーバーカタログ、選定基準、互換性確認

### Error-Fixer Agent

- **提供内容**: MCP設定エラーの診断・修正
- **タイミング**: MCPサーバー起動失敗・権限エラー対応時
- **コンテキスト**: トラブルシューティングパターン、環境変数設定、権限設定

### 自動ロード条件

- "MCP"、"MCPサーバー"、"MCP設定"に言及
- "claude_desktop_config.json"ファイル操作時
- "外部ツール統合"、"GitHub統合"、"データベース統合"に言及
- 環境変数、APIキー、トークン管理について質問

### 統合例

```
ユーザー: "GitHub MCPサーバーを安全に設定したい"
    ↓
TaskContext作成
    ↓
プロジェクト検出: MCP設定タスク
    ↓
スキル自動ロード: mcp-tools
    ↓
エージェント選択: orchestrator
    ↓ (スキルコンテキスト提供)
GitHub MCP設定パターン + セキュリティベストプラクティス
    ↓
実行完了（環境変数利用の安全な設定）
```

## 関連スキル

- **integration-framework**: TaskContext、Communication Bus統合
- **agents-and-commands**: エージェント/コマンドとMCPツールの統合

## 参考リンク

- [MCP公式リポジトリ](https://github.com/modelcontextprotocol/servers)
- [GitHub MCP Server](https://github.com/github/github-mcp-server)
- [MCP仕様書](https://github.com/modelcontextprotocol/specification)

---

このスキルは、MCPサーバーを安全に設定・管理するための包括的なガイドです。セキュリティを最優先にし、段階的に外部ツールとの統合を進めてください。
