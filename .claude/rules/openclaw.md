---
paths: systemd/user/openclaw-*.service, systemd/user/openclaw-*.timer, scripts/openclaw-*, openclaw/**
source: docs/tools/openclaw.md
---

# OpenClaw Rules

Purpose: OpenClaw Gateway 運用のクイックリファレンス。
Detailed Reference: [docs/tools/openclaw.md](../../docs/tools/openclaw.md)

## Gateway 管理コマンド

```bash
systemctl --user start openclaw-gateway.service
systemctl --user stop openclaw-gateway.service
systemctl --user restart openclaw-gateway.service
systemctl --user status openclaw-gateway.service
systemctl --user daemon-reload   # 設定変更後
```

## ログ確認

```bash
journalctl --user -u openclaw-gateway.service -n 100
tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log
curl http://localhost:18789/health
```

## 緊急時コマンド

| 症状         | コマンド                                                                         |
| ------------ | -------------------------------------------------------------------------------- |
| 応答なし     | `systemctl --user restart openclaw-gateway.service`                              |
| CPU 99%      | stop → gateway.env 修正 → start                                                  |
| ディスク逼迫 | `~/.config/scripts/openclaw-cleanup`                                             |
| ログ急増     | `rm -f /tmp/openclaw/*.log && systemctl --user restart openclaw-gateway.service` |

## Gateway 起動問題の即時診断

```bash
# 1. gateway.env 確認
ls -la ~/.openclaw/gateway.env

# 2. 環境変数が読み込まれているか
systemctl --user show openclaw-gateway.service | grep Environment

# 3. 詳細ログ
journalctl --user -u openclaw-gateway.service -n 100
```

解決（gateway.env が存在しない場合）:

```bash
cat > ~/.openclaw/gateway.env << EOF
OPENCLAW_GATEWAY_PORT=18789
OPENCLAW_GATEWAY_TOKEN=$(openssl rand -hex 32)
EOF
systemctl --user daemon-reload && systemctl --user restart openclaw-gateway.service
```

## 設定ファイル

| ファイル                                                          | 用途                                 |
| ----------------------------------------------------------------- | ------------------------------------ |
| `~/.openclaw/gateway.env`                                         | TOKEN・ポート（Git 管理しない）      |
| `~/.config/systemd/user/openclaw-gateway.service`                 | Gateway サービス定義                 |
| `~/.config/systemd/user/openclaw-gateway.service.d/override.conf` | EnvironmentFile 指定                 |
| `~/.config/scripts/openclaw-gateway`                              | ラッパースクリプト（バージョン解決） |
| `~/.config/scripts/openclaw-cleanup`                              | 月次クリーンアップ                   |

詳細は [docs/tools/openclaw.md](../../docs/tools/openclaw.md) を参照。
