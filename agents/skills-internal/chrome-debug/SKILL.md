---
name: chrome-debug
description: |
  [What] Chrome DevTools / MCP / agent-browser を使ったフロントエンドデバッグのナレッジベース。
  [When] Use when: ブラウザデバッグ、ネットワーク診断、Cookie確認、レンダリング問題調査が必要な時。
  [Keywords] chrome, devtools, debug, network, console, cookie, screenshot, WSL, mcp
---

# Chrome Debug Skill

Chrome DevTools を活用したフロントエンドデバッグのナレッジベース。
WSL2 環境でのリモートデバッグ、MCP Chrome DevTools 連携、agent-browser 自動化をカバーする。

## ツール選択ガイド

目的に応じて最適なツールを選択する:

| 目的                         | 推奨ツール          | 理由                                         |
| ---------------------------- | ------------------- | -------------------------------------------- |
| ページ操作の自動化           | agent-browser       | snapshot + ref で効率的                      |
| JavaScript 実行・Cookie 確認 | MCP Chrome DevTools | evaluate_script で直接実行可能               |
| Network/Console ログ         | MCP Chrome DevTools | list_network_requests, list_console_messages |
| 手動での深掘り               | Chrome F12          | 最も柔軟、ブレークポイント設定可能           |
| スクリーンショット           | agent-browser       | パス指定が簡単、WSL2 対応                    |

## デバッグモード

### 1. MCP Chrome DevTools(推奨)

Chrome をリモートデバッグモードで起動し、MCP 経由で操作する。

**セットアップ**: → `references/wsl-setup.md`

**ワークフロー**:

1. Chrome をデバッグモードで起動
2. MCP 接続を確認
3. `take_snapshot` → `list_console_messages` → `list_network_requests` → `evaluate_script`
4. `take_screenshot` で結果を保存

**診断チェックリスト**: → `references/devtools-checklist.md`

### 2. agent-browser

ページ操作の自動化とスクリーンショット取得に最適。

**ワークフロー**:

```bash
agent-browser open <TARGET_URL>
agent-browser snapshot -i
# 操作(click, fill 等)
agent-browser snapshot -i  # ref を更新
```

**診断パターン**: → `references/agent-browser-patterns.md`

### 3. 手動 DevTools(F12)

MCP が使えない場合のフォールバック。

1. Chrome で F12 を押して DevTools を開く
2. **Console** タブ: JavaScript エラー確認
3. **Network** タブ: リクエストの無限ループ・失敗確認
4. **Application** > **Cookies**: Cookie の確認

## よくある問題

→ `references/troubleshooting.md`

## References

- `references/wsl-setup.md` - WSL2 ↔ Windows Chrome のセットアップ・IP・MCP 設定
- `references/devtools-checklist.md` - DevTools タブ別の確認ポイント・診断スクリプト
- `references/agent-browser-patterns.md` - agent-browser の診断パターン・スクリーンショット保存
- `references/troubleshooting.md` - 接続エラー・stale ref・headed モード等の解決策
