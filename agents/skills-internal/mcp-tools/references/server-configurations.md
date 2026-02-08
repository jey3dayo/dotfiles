# Server Configurations

MCP（Model Context Protocol）サーバーの完全なカタログと詳細設定。すべての主要サーバー、カスタム設定、高度な使用パターンを網羅します。

## 概要

このドキュメントでは、利用可能なすべてのMCPサーバーの詳細設定、カスタマイズオプション、統合パターンを提供します。

---

## サーバーカテゴリ

### 1. コンテキスト管理

### 2. ファイル・ストレージ

### 3. バージョン管理

### 4. データベース

### 5. 外部API・サービス

### 6. Web・検索

### 7. コミュニケーション

### 8. システム・ターミナル

---

## 1. コンテキスト管理

### Memory Server

**目的**: 会話間でコンテキストを保持

**基本設定**:

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

**高度な設定**:

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-memory",
        "--storage-path",
        "~/.claude/memory"
      ]
    }
  }
}
```

**機能**:

- 会話履歴の永続化
- コンテキストの検索
- カテゴリ別の記憶管理

**使用例**:

```
ユーザー: 「このプロジェクトでReactを使っていることを覚えておいて」
Claude: 「記憶しました」
（別のチャットで）
ユーザー: 「このプロジェクトの技術スタックは？」
Claude: 「Reactを使用しています」
```

---

## 2. ファイル・ストレージ

### Filesystem Server

**目的**: 指定ディレクトリのファイル操作

**基本設定**:

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

**複数ディレクトリ指定**:

```json
{
  "mcpServers": {
    "filesystem-projects": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/username/projects"
      ]
    },
    "filesystem-docs": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/username/documents"
      ]
    }
  }
}
```

**セキュリティ考慮事項**:

- ✅ プロジェクトディレクトリのみ指定
- ✅ 読み取り専用が必要な場合は別のインスタンス
- ❌ ホームディレクトリ全体は指定しない
- ❌ システムディレクトリは指定しない

**機能**:

- ファイル読み込み
- ファイル書き込み
- ディレクトリ一覧取得
- ファイル検索

### Google Drive Server

**目的**: Google Driveファイルアクセス

**設定**:

```json
{
  "mcpServers": {
    "gdrive": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-gdrive"],
      "env": {
        "GDRIVE_CLIENT_ID": "your-client-id",
        "GDRIVE_CLIENT_SECRET": "your-client-secret",
        "GDRIVE_REFRESH_TOKEN": "your-refresh-token"
      }
    }
  }
}
```

**OAuth設定手順**:

1. Google Cloud Consoleでプロジェクト作成
2. Drive APIを有効化
3. OAuth 2.0 認証情報を作成
4. リフレッシュトークンを取得

---

## 3. バージョン管理

### GitHub Server（公式）

**目的**: GitHub統合、リポジトリ管理、Issue/PR操作

**基本設定**:

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

**セキュアな設定**:

```json
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
```

**必要なスコープ**:

- `repo`: リポジトリアクセス
- `read:org`: 組織情報の読み取り
- `workflow`: GitHub Actions管理
- `write:discussion`: Discussions管理

**機能**:

- リポジトリ作成・削除
- Issue/PR作成・編集
- ブランチ管理
- ファイル読み書き
- GitHub Actions実行

### Git Server

**目的**: ローカルGit操作

**基本設定**:

```json
{
  "mcpServers": {
    "git": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-git"]
    }
  }
}
```

**リポジトリ指定**:

```json
{
  "mcpServers": {
    "git": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-git",
        "--repository",
        "/path/to/repo"
      ]
    }
  }
}
```

**機能**:

- コミット履歴閲覧
- ブランチ管理
- ステータス確認
- diff表示

---

## 4. データベース

### PostgreSQL Server

**基本設定（接続文字列）**:

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "POSTGRES_CONNECTION_STRING": "postgresql://user:password@localhost:5432/dbname"
      }
    }
  }
}
```

**個別パラメータ設定**:

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "POSTGRES_HOST": "localhost",
        "POSTGRES_PORT": "5432",
        "POSTGRES_USER": "myuser",
        "POSTGRES_PASSWORD": "mypassword",
        "POSTGRES_DATABASE": "mydb",
        "POSTGRES_SSL": "true"
      }
    }
  }
}
```

**セキュアな設定**:

```json
{
  "mcpServers": {
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

**機能**:

- クエリ実行
- テーブル一覧取得
- スキーマ情報取得
- トランザクション管理

### MySQL Server

**基本設定**:

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
        "MYSQL_DATABASE": "mydb"
      }
    }
  }
}
```

**セキュアな設定**:

```json
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
```

**接続プーリング設定**:

```json
{
  "mcpServers": {
    "mysql": {
      "command": "node",
      "args": ["/path/to/mysql-server.js"],
      "env": {
        "MYSQL_HOST": "127.0.0.1",
        "MYSQL_PORT": "3306",
        "MYSQL_USER": "root",
        "MYSQL_PASSWORD": "$MYSQL_ROOT_PASSWORD",
        "MYSQL_DATABASE": "mydb",
        "MYSQL_POOL_SIZE": "10",
        "MYSQL_CONNECTION_TIMEOUT": "10000"
      }
    }
  }
}
```

**機能**:

- クエリ実行
- テーブル操作
- データベース管理
- インデックス情報取得

### SQLite Server

**基本設定**:

```json
{
  "mcpServers": {
    "sqlite": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-sqlite",
        "/path/to/database.db"
      ]
    }
  }
}
```

**複数データベース**:

```json
{
  "mcpServers": {
    "sqlite-dev": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sqlite", "/path/to/dev.db"]
    },
    "sqlite-test": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sqlite", "/path/to/test.db"]
    }
  }
}
```

---

## 5. 外部API・サービス

### AWS Server

**目的**: AWS サービス統合

**設定**:

```json
{
  "mcpServers": {
    "aws": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-aws"],
      "env": {
        "AWS_ACCESS_KEY_ID": "your-access-key",
        "AWS_SECRET_ACCESS_KEY": "your-secret-key",
        "AWS_REGION": "us-east-1"
      }
    }
  }
}
```

**セキュアな設定（AWSプロファイル使用）**:

```json
{
  "mcpServers": {
    "aws": {
      "command": "sh",
      "args": [
        "-c",
        "AWS_PROFILE=myprofile npx -y @modelcontextprotocol/server-aws"
      ]
    }
  }
}
```

**サポートサービス**:

- S3: バケット操作、オブジェクト管理
- EC2: インスタンス管理
- Lambda: 関数実行
- DynamoDB: テーブル操作

### Sentry Server

**目的**: エラートラッキング

**設定**:

```json
{
  "mcpServers": {
    "sentry": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sentry"],
      "env": {
        "SENTRY_AUTH_TOKEN": "your-auth-token",
        "SENTRY_ORG_SLUG": "your-org",
        "SENTRY_PROJECT_SLUG": "your-project"
      }
    }
  }
}
```

**機能**:

- エラー一覧取得
- Issue詳細表示
- エラー統計分析

---

## 6. Web・検索

### Fetch Server

**目的**: Web コンテンツ取得

**基本設定**:

```json
{
  "mcpServers": {
    "fetch": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch"]
    }
  }
}
```

**プロキシ設定**:

```json
{
  "mcpServers": {
    "fetch": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch"],
      "env": {
        "HTTP_PROXY": "http://proxy.example.com:8080",
        "HTTPS_PROXY": "http://proxy.example.com:8080"
      }
    }
  }
}
```

**機能**:

- URLからコンテンツ取得
- HTMLパース
- Markdown変換

### Brave Search Server

**目的**: Web検索

**設定**:

```json
{
  "mcpServers": {
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "your-api-key"
      }
    }
  }
}
```

**セキュアな設定**:

```json
{
  "mcpServers": {
    "brave-search": {
      "command": "sh",
      "args": [
        "-c",
        "BRAVE_API_KEY=$BRAVE_SEARCH_API_KEY npx -y @modelcontextprotocol/server-brave-search"
      ]
    }
  }
}
```

**APIキー取得**: [Brave Search API](https://brave.com/search/api/)

**機能**:

- Web検索
- ニュース検索
- 画像検索
- 検索結果のフィルタリング

### Puppeteer Server

**目的**: ブラウザ自動化

**設定**:

```json
{
  "mcpServers": {
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
    }
  }
}
```

**ヘッドレスモード設定**:

```json
{
  "mcpServers": {
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer", "--headless=new"]
    }
  }
}
```

**機能**:

- ページスクリーンショット
- フォーム入力
- クリック操作
- JavaScriptコード実行

---

## 7. コミュニケーション

### Slack Server

**基本設定**:

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

**セキュアな設定**:

```json
{
  "mcpServers": {
    "slack": {
      "command": "sh",
      "args": [
        "-c",
        "SLACK_BOT_TOKEN=$SLACK_BOT_TOKEN SLACK_TEAM_ID=$SLACK_TEAM_ID npx -y @modelcontextprotocol/server-slack"
      ]
    }
  }
}
```

**必要なスコープ**:

- `channels:read`: チャンネル一覧取得
- `channels:history`: メッセージ履歴取得
- `chat:write`: メッセージ送信
- `users:read`: ユーザー情報取得

**機能**:

- チャンネル一覧取得
- メッセージ送信
- メッセージ履歴取得
- ファイルアップロード

### Discord Server

**設定**:

```json
{
  "mcpServers": {
    "discord": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-discord"],
      "env": {
        "DISCORD_BOT_TOKEN": "your-bot-token"
      }
    }
  }
}
```

---

## 8. システム・ターミナル

### Shell/Terminal Server (wcgw)

**インストール**:

```bash
uv pip install wcgw
```

**基本設定**:

```json
{
  "mcpServers": {
    "shell": {
      "command": "wcgw",
      "args": ["--protocol", "mcp"]
    }
  }
}
```

**セーフモード設定**:

```json
{
  "mcpServers": {
    "shell": {
      "command": "wcgw",
      "args": [
        "--protocol",
        "mcp",
        "--safe-mode",
        "--allowed-commands",
        "ls,cat,grep,find"
      ]
    }
  }
}
```

**セキュリティ考慮事項**:

- ✅ 許可するコマンドを限定
- ✅ セーフモードを有効化
- ❌ 無制限のシェルアクセスは避ける
- ❌ sudoコマンドは許可しない

**機能**:

- シェルコマンド実行
- コマンド履歴管理
- 出力フォーマット

---

## 統合パターン

### パターン1: 開発環境完全セットアップ

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
    "git": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-git"]
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

### パターン2: Web開発環境

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
        "/Users/username/web-projects"
      ]
    },
    "github": {
      "command": "sh",
      "args": [
        "-c",
        "GITHUB_PERSONAL_ACCESS_TOKEN=$GITHUB_TOKEN npx -y @github/github-mcp-server"
      ]
    },
    "fetch": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch"]
    },
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
    }
  }
}
```

### パターン3: データ分析環境

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "postgres": {
      "command": "sh",
      "args": [
        "-c",
        "POSTGRES_CONNECTION_STRING=$DATABASE_URL npx -y @modelcontextprotocol/server-postgres"
      ]
    },
    "mysql": {
      "command": "sh",
      "args": [
        "-c",
        "MYSQL_PASSWORD=$MYSQL_ROOT_PASSWORD node /path/to/mysql-server.js"
      ]
    },
    "sqlite": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sqlite", "/path/to/data.db"]
    }
  }
}
```

---

## トラブルシューティング

### サーバーが認識されない

**チェック項目**:

1. JSON構文が正しいか確認
2. コマンドパスが存在するか確認
3. 環境変数が設定されているか確認
4. Claudeを再起動

### パフォーマンス問題

**原因**: 複数のデータベースサーバーが同時に動作

**解決策**:

- 不要なサーバーを無効化
- 接続プーリングを適切に設定
- タイムアウト値を調整

---

## 関連ドキュメント

- **security-and-credentials.md**: セキュリティベストプラクティス、認証情報管理
- **SKILL.md**: MCP Toolsクイックスタートガイド

このドキュメントは、すべてのMCPサーバーを活用するための完全なリファレンスです。プロジェクトのニーズに応じて、適切なサーバーを選択・設定してください。
