---
description: Chrome DevTools を使ったフロントエンドデバッグセッションの準備と実行
argument-hint: [url] [--mcp|--agent-browser|--manual]
---

# Chrome Debug Session

`chrome-debug` スキルを参照してデバッグセッションを実行する。

## 引数の解析

`$ARGUMENTS` から以下を抽出:

- **URL**: デバッグ対象の URL(省略時はユーザーに確認)
- **モード**: `--mcp` / `--agent-browser` / `--manual`(省略時は選択肢を提示)

## モード選択

引数にモードが指定されていない場合、以下から選択を促す:

1. **MCP Chrome DevTools** (`--mcp`): JS実行・Network・Console ログの確認が必要な場合
2. **agent-browser** (`--agent-browser`): ページ操作の自動化・スクリーンショットが必要な場合
3. **手動 DevTools** (`--manual`): Chrome F12 でのブレークポイント設定等

## 実行ステップ

### MCP モード

1. WSL2 環境チェック(Windows ホスト IP の取得)
2. Chrome をリモートデバッグモードで起動(起動スクリプトがあれば使用)
3. MCP 接続を確認
4. `chrome-debug` スキルの `references/devtools-checklist.md` に従って診断
5. 結果をサマリーとして報告

### agent-browser モード

1. 対象 URL を `agent-browser open` で開く
2. `chrome-debug` スキルの `references/agent-browser-patterns.md` に従って診断
3. スクリーンショットを保存して報告

### 手動モード

1. Chrome の起動コマンドを提示
2. `chrome-debug` スキルの `references/devtools-checklist.md` の手動 DevTools セクションを参照
3. 確認すべきポイントをチェックリストとして提示

## トラブルシューティング

問題が発生した場合は `chrome-debug` スキルの `references/troubleshooting.md` を参照。
