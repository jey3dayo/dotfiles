---
name: mcp-tools
description: |
  [What] MCP（Model Context Protocol）サーバーのセットアップとセキュリティガイド。設定ファイルの場所、主要サーバーのインストール、環境変数管理、トラブルシューティング、セキュリティベストプラクティスを提供します。MCPサーバー設定時、外部ツール統合時、またはセキュリティ懸念がある際に
  [When] Use when: 起動します。**常に日本語で応答します**。
  [Keywords] mcp tools, MCP, Model, Context, Protocol
---

# MCP Tools

MCP（Model Context Protocol）サーバーのセットアップとセキュリティガイド。外部ツールとの統合を安全に実現します。

## 概要

MCP（Model Context Protocol）は、Claude Codeが外部ツール・サービスと統合するためのプロトコルです。このスキルは、MCPサーバーの設定、主要サーバーの使用方法、センシティブ情報の安全な管理方法を提供します。

## いつ使うか

このスキルは以下の場合に起動されます:

- MCPサーバーを初めて設定する
- 新しいMCPサーバーを追加したい
- 設定ファイルの場所が分からない
- 環境変数やトークンの安全な管理方法を知りたい
- MCPサーバーが起動しない（トラブルシューティング）
- セキュリティベストプラクティスを確認したい

## トリガーキーワード

### 日本語

- "MCP", "MCPサーバー", "MCP設定"
- "claude_desktop_config.json", "設定ファイル"
- "外部ツール統合", "GitHub統合", "データベース統合"
- "環境変数", "APIキー", "トークン管理"

### 英語

- "MCP", "MCP server", "MCP setup", "MCP configuration"
- "claude_desktop_config.json", "config file"
- "external tool integration", "GitHub integration"
- "environment variables", "API key", "token management"

## クイックスタート

### 設定ファイルの場所

```bash
# macOS
~/Library/Application Support/Claude/claude_desktop_config.json

# Windows
%APPDATA%\Claude\claude_desktop_config.json

# Linux
~/.config/Claude/claude_desktop_config.json
```

### 基本的な設定手順

```bash
# 1. Claude Desktopを終了
osascript -e 'quit app "Claude"'

# 2. 設定ファイルを編集
code ~/Library/Application\ Support/Claude/claude_desktop_config.json

# 3. MCPサーバーを追加（後述）

# 4. Claude Desktopを再起動
open -a Claude

# 5. 設定 → Developer → MCP Serversで確認
```

## 詳細リファレンス

- 主要サーバー/セキュリティ/統合例/トラブルシューティング/使用例は `references/mcp-tools-details.md` を参照

## 次のステップ

1. クイックスタートを実行
2. 必要なサーバーを選定して導入
3. セキュリティ設定を確認

## 関連リソース

- `references/mcp-tools-details.md`
