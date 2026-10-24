# Mac Health Check

最終更新: 2026-10-24
対象: 開発者
タグ: `category/operations`, `tool/launchd`, `layer/tool`, `environment/macos`, `audience/developer`

親ドキュメント: [Mise Task Catalog](mise-tasks.md)

過去に Mac を重くした事故を、課金ゼロのローカル shell script で 15 分ごとに検知する。正常時は無音で 1 行ログを残すだけ、異常時のみ通知する。

## 構成

| 要素         | 場所                                                                                                      |
| ------------ | --------------------------------------------------------------------------------------------------------- |
| 本体         | `scripts/launchd/mac-health-check.sh`（macOS 標準 `/bin/bash` 3.2 で動作）                                |
| LaunchAgent  | `mise/config.macos.toml` の `[bootstrap.macos.launchd.agents.mac-health-check]`（`start_interval = 900`） |
| タスク       | `mise/local-tasks/health.toml`（`health:*`）                                                              |
| ログ         | `~/.cache/mac-health/health.log`（1 MiB で `.1` へローテーション）                                        |
| launchd 出力 | `~/Library/Logs/mac-health-check.log`                                                                     |
| webhook 秘密 | `~/.local/state/mac-health/webhook.env`（repo 外、`chmod 600`）                                           |

## 検知項目と既定閾値

すべて `MH_*` 環境変数で上書きできる（スクリプト冒頭を参照）。

| 検知                                                                                                                                                     | 既定                   | 動作     |
| -------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------- | -------- |
| syspolicyd の CPU                                                                                                                                        | > 50%                  | 通知     |
| node 単体 / 合計 CPU / プロセス数                                                                                                                        | > 80% / > 200% / > 40  | 通知     |
| 同一コマンド名の合計 CPU（node 以外）                                                                                                                    | > 300%                 | 通知     |
| agmsg を含むプロセス                                                                                                                                     | > 0                    | 通知     |
| `session-start.sh` / `identities.sh` の滞留                                                                                                              | > 3                    | 通知     |
| agmsg hook の復活（`~/.claude/settings*.json`、`~/.codex/hooks.json`、`~/src` `~/ghq` 配下 repo の `.claude/settings.local.json` / `.codex/hooks.json`） | 1 件以上               | 通知     |
| orca hook の復活（`~/.claude/settings.json`）                                                                                                            | 1 件以上               | 通知     |
| statusLine が shim / `mise x` / `npx` / `bunx` 経由                                                                                                      | 該当                   | 通知     |
| ccstatusline widget 数                                                                                                                                   | 初回値（baseline）超過 | 通知     |
| `/usr/bin/true` の起動時間                                                                                                                               | > 1000ms               | 通知     |
| `"model"` が opus                                                                                                                                        | 該当                   | ログのみ |
| launchd 直下の dev サーバー（vite / workerd 等）                                                                                                         | 1 件以上               | ログのみ |

ccstatusline の widget を意図して増やした場合は `~/.cache/mac-health/ccstatusline.baseline` を削除すると次回実行値が新しい baseline になる。

## 通知

- macOS 通知（osascript）と、`webhook.env` があれば webhook POST（Slack の `text` / Discord の `content` 両対応）
- 新しい種類の警告が増えたときに即通知。同じ警告が続く間は 1 時間に 1 回まで（`MH_NOTIFY_COOLDOWN`）。数値の変化（`node x69` → `x70`）だけでは再通知しない
- `webhook.env` は `source` せず `MH_WEBHOOK_URL=` 行だけ読む。`600` / `400` 以外の権限なら送信しない

```bash
mkdir -p ~/.local/state/mac-health
umask 077 && printf 'MH_WEBHOOK_URL=%s\n' 'https://hooks.example/...' > ~/.local/state/mac-health/webhook.env
```

## 導入・確認・撤去

```bash
mise run health:install      # = mise bootstrap macos launchd-agents apply --yes（冪等）
mise run health:check        # 1 回実行して結果行を表示
mise run health:test-notify  # 通知経路のテスト
mise run health:status       # LaunchAgent の状態
mise run health:log          # 直近ログ

mise run health:uninstall    # = mise bootstrap services remove mac-health-check
```

`health:uninstall` は plist を unload・削除するだけで、`mise/config.macos.toml` の宣言が残っていれば次の `mise bootstrap` で再導入される。恒久的にやめる場合は宣言も削除する。ログは `rm -rf ~/.cache/mac-health` で消す。
