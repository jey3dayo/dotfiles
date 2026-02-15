# openClaw修復 - 変更ファイル一覧

**日時**: 2026-02-15
**作業内容**: openClaw起動問題の修復とシステムメンテナンス

## 修正されたファイル

### 1. Cleanup Script

**ファイル**: `/home/pi/.config/scripts/openclaw-cleanup`

**変更内容**:

```bash
# 追加: PATH設定
export PATH="$HOME/.local/bin:$PATH"

# 追加: PATH確認用ログ
echo "PATH=$PATH"

# 修正: npm出力フィルタリング
npm cache clean --force 2>&1 | grep -v "npm warn" || true
```

**目的**: miseコマンドが見つからない問題を修正

---

### 2. Cleanup Timer

**ファイル**: `/home/pi/.config/systemd/user/openclaw-cleanup.timer`

**変更内容**:

```ini
[Unit]
Description=Run cleanup at ~05:00 daily
After=default.target  # 追加

[Timer]
OnCalendar=*-*-* 05:00:00
Persistent=true
RandomizedDelaySec=15m

[Install]
WantedBy=timers.target
```

**目的**: ユーザーセッション完全初期化後に実行

---

### 3. Cleanup Service

**ファイル**: `/home/pi/.config/systemd/user/openclaw-cleanup.service`

**変更内容**:

```ini
[Unit]
Description=Periodic cleanup (mise/pnpm/npm) to reduce disk usage
After=default.target           # 追加
Wants=openclaw-gateway.service # 追加

[Service]
Type=oneshot
Environment="PATH=%h/.local/bin:%h/.mise/shims:/usr/local/bin:/usr/bin:/bin"  # 追加
Environment=HOME=%h                                                           # 追加
ExecStart=%h/.config/scripts/openclaw-cleanup

Restart=on-failure  # 追加
RestartSec=60       # 追加
```

**目的**: PATH設定と自動リトライ機能追加

---

### 4. Gateway Service

**ファイル**: `/home/pi/.config/systemd/user/openclaw-gateway.service`

**変更内容**:

```ini
[Service]
ExecStart="%h/.mise/shims/openclaw" gateway --port 18789

Restart=always
RestartSec=5
KillMode=process

# Resource limits (temporarily disabled for debugging)
# MemoryMax=512M      # コメントアウト（起動問題のため無効化）
# MemoryHigh=384M     # コメントアウト
# CPUQuota=50%        # コメントアウト

# Watchdog (temporarily disabled - caused timeout issues)
# WatchdogSec=60      # コメントアウト（タイムアウト問題のため無効化）

Environment=HOME=%h
Environment="PATH=%h/.mise/shims:/usr/local/bin:/usr/bin:/bin:%h/.local/bin:%h/bin"
Environment=OPENCLAW_GATEWAY_PORT=18789
Environment="OPENCLAW_SYSTEMD_UNIT=openclaw-gateway.service"
Environment=OPENCLAW_SERVICE_MARKER=openclaw
Environment=OPENCLAW_SERVICE_KIND=gateway
Environment=OPENCLAW_SERVICE_VERSION=2026.2.2-3
```

**目的**: Watchdogタイムアウト問題を修正

---

### 5. Gateway Service Drop-In

**ファイル**: `/home/pi/.config/systemd/user/openclaw-gateway.service.d/override.conf`

**変更内容**: **削除**

**理由**: 存在しない`~/.openclaw/gateway.env`を参照していたため起動失敗

---

### 6. 孤立シンボリックリンク

**ファイル**: `/home/pi/.config/systemd/user/default.target.wants/openclaw.service`

**変更内容**: **削除**

**理由**: 実体ファイルが存在しない孤立リンク、Timer依存解決エラーの原因

---

### 7. openClaw設定

**ファイル**: `/home/pi/.openclaw/openclaw.json`

**変更内容**: **完全リセット＋再セットアップ**

**設定内容**:

- `gateway.bind = lan`
- `gateway.port = 18789`
- 初期設定から再生成

**バックアップ**: `~/openclaw-backup-20260215_121920/`

---

## ディスク容量改善

### 実施したクリーンアップ

1. **mise prune**
   - kubectl 1.28.15 削除
   - pnpm 10.28.2 削除
   - python 3.13.5 削除

2. **pnpm store prune**
   - 14,156ファイル削除
   - 152パッケージ削除

3. **nix-collect-garbage**
   - 73.6 MiB解放
   - 古いgenerations削除（5世代）
   - 古いprofiles削除

**結果**: ディスク使用率 94% → 92% (2.7GB空き)

---

## バージョン情報

- **openClaw**: 2026.2.1（2026.2.13へ更新試行したが問題発生のため戻した）
- **mise**: 最新版
- **pnpm**: 10.28.2（最新）
- **Node.js**: mise経由で管理

---

## 未解決の問題

### Gateway起動問題

**症状**:

- プロセスは起動するがCPU 99.9%を消費
- ポート18789をリスニングしない
- 90秒以上待機しても状態変わらず

**可能性**:

1. Raspberry Pi ARM64環境固有の問題
2. openClawの依存パッケージビルド問題
3. システムリソース不足（load average高い）

**次のステップ**:

- システム再起動推奨
- 再起動後もダメならコミュニティへ報告

---

## 参照

- 詳細レポート: `docs/troubleshooting/openclaw-gateway-raspberry-pi.md`
- バックアップ: `~/openclaw-backup-20260215_121920/`
- 一時スクリプト: `/tmp/openclaw-*.sh`

---

**最終更新**: 2026-02-15
