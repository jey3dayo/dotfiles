# OpenClaw Rules

Purpose: OpenClaw Gateway運用とトラブルシューティングのルール。Scope: systemd設定、環境変数管理、メンテナンス、トラブルシューティング。

## Configuration Structure

### Environment Variables Management

OpenClawの環境変数は**gateway.env**で一元管理します。

**ファイル**: `~/.openclaw/gateway.env`

```bash
# OpenClaw Gateway environment variables
OPENCLAW_GATEWAY_PORT=18789
OPENCLAW_GATEWAY_TOKEN=<新規生成したTOKEN>
```

#### 重要

- このファイルには機密情報（TOKEN）が含まれる
- Gitで管理しない（`.config`リポジトリ外に配置）
- バックアップ時は機密情報として扱う

#### TOKEN生成方法

```bash
# 新しいTOKENを生成
openssl rand -hex 32

# gateway.envに追加
echo "OPENCLAW_GATEWAY_TOKEN=$(openssl rand -hex 32)" >> ~/.openclaw/gateway.env
```

### systemd Configuration

#### Gateway Service

**ファイル**: `~/.config/systemd/user/openclaw-gateway.service`

#### 設計原則

- mise shimを使用（ポータビリティ確保）
- 環境変数はgateway.env経由で読み込み
- リソース制限とWatchdogは無効化（Raspberry Pi対応）

#### 主要設定

```ini
[Service]
ExecStart="%h/.mise/shims/openclaw" gateway --port 18789
Restart=always
RestartSec=5
Environment=HOME=%h
Environment="PATH=%h/.mise/shims:/usr/local/bin:/usr/bin:/bin:%h/.local/bin:%h/bin"
Environment=OPENCLAW_GATEWAY_PORT=18789
```

**override.conf**: `~/.config/systemd/user/openclaw-gateway.service.d/override.conf`

```ini
[Service]
EnvironmentFile=%h/.openclaw/gateway.env
```

#### Cleanup Service

**ファイル**: `~/.config/systemd/user/openclaw-cleanup.service`

**目的**: 定期的なディスククリーンアップ（mise/pnpm/npm）

#### 主要設定

```ini
[Unit]
Description=Periodic cleanup (mise/pnpm/npm) to reduce disk usage
After=default.target
Wants=openclaw-gateway.service

[Service]
Type=oneshot
Environment="PATH=%h/.local/bin:%h/.mise/shims:/usr/local/bin:/usr/bin:/bin"
Environment=HOME=%h
ExecStart=%h/.config/scripts/openclaw-cleanup
Restart=on-failure
RestartSec=60
```

**タイマー**: `~/.config/systemd/user/openclaw-cleanup.timer`

```ini
[Unit]
Description=Run cleanup at ~05:00 daily
After=default.target

[Timer]
OnCalendar=*-*-* 05:00:00
Persistent=true
RandomizedDelaySec=15m

[Install]
WantedBy=timers.target
```

### Cleanup Script

**ファイル**: `~/.config/scripts/openclaw-cleanup`

#### 機能

- mise prune: 古いバージョン削除
- pnpm store prune: 未使用パッケージ削除
- npm cache clean: キャッシュクリア
- ディスク使用量記録

#### 重要な設定

```bash
# PATH設定（mise/pnpm/npmを確実に発見）
export PATH="$HOME/.local/bin:$PATH"

# npm出力フィルタリング
npm cache clean --force 2>&1 | grep -v "npm warn" || true
```

**ログファイル**: `~/.cache/openclaw/cleanup.log`

### systemd設計の原則

#### サービスごとの最適化

OpenClawのsystemd設定は、**サービス特性に応じた最適化**を行っています。

##### Gateway Service（永続サービス）

#### PATH設計

- mise最新バイナリへの直接パス参照
- shim経由のオーバーヘッド回避（起動時間50-100ms削減）
- 永続サービスのため、起動速度が重要

**KillMode設計**: `mixed`

- メインプロセス（openclaw gateway）とその子プロセス（Telegram Bot等）を確実に終了
- ポート占有やリソースリーク防止に必須

##### Cleanup Service（ワンショット）

#### PATH設計

- mise shimを使用してポータビリティ確保
- miseが管理するバージョンを自動的に使用
- 日次1回実行のため、shimオーバーヘッド（50-100ms）は無視可能

**KillMode設計**: 未設定（デフォルトのcontrol-group）

- Type=oneshotのため、ExecStart完了時点でプロセスが終了
- 残存プロセスが存在しないため、KillMode指定は不要

#### 設計原則のまとめ

| 項目     | Gateway Service   | Cleanup Service         | 理由                             |
| -------- | ----------------- | ----------------------- | -------------------------------- |
| Type     | simple（永続）    | oneshot（ワンショット） | サービスのライフサイクルの違い   |
| PATH     | 直接バイナリ参照  | mise shim経由           | パフォーマンス vs ポータビリティ |
| KillMode | mixed（子も終了） | 未設定（デフォルト）    | 子プロセス管理の必要性           |
| Restart  | always            | on-failure              | 永続 vs エラー時のみ             |

### この分離設計により、各サービスが最適化され、保守性も確保されています

## Common Operations

### Gateway管理

#### 起動・停止・再起動

```bash
# 起動
systemctl --user start openclaw-gateway.service

# 停止
systemctl --user stop openclaw-gateway.service

# 再起動
systemctl --user restart openclaw-gateway.service

# 状態確認
systemctl --user status openclaw-gateway.service
```

#### 設定変更後のリロード

```bash
# systemd設定リロード
systemctl --user daemon-reload

# gateway.env変更後はgatewayを再起動
systemctl --user restart openclaw-gateway.service
```

#### ログ確認

```bash
# systemdログ
journalctl --user -u openclaw-gateway.service -n 100

# openclawログ
tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log

# cleanupログ
tail -f ~/.cache/openclaw/cleanup.log
```

### 診断

```bash
# 基本診断
openclaw doctor

# 詳細診断（修復付き）
openclaw doctor --fix

# セキュリティ監査
openclaw security audit --deep

# 設定確認
openclaw config list
```

### 動作確認

```bash
# ポートリスニング確認
ss -tlnp | grep 18789

# プロセス確認（CPU/メモリ使用率）
ps aux | grep openclaw | grep -v grep

# ヘルスチェック
curl http://localhost:18789/health

# システムリソース確認
uptime
df -h /
free -h
```

## Maintenance

### 定期メンテナンス（月次）

1. バージョン更新:

   ```bash
   mise upgrade
   mise prune
   ```

2. Cleanup実行履歴確認:

   ```bash
   tail -50 ~/.cache/openclaw/cleanup.log
   ```

3. ディスク使用量確認:

   ```bash
   df -h /
   ```

4. Gateway状態確認:

   ```bash
   systemctl --user status openclaw-gateway.service
   ```

### Timer動作確認

```bash
# タイマー一覧
systemctl --user list-timers

# cleanup timer確認
systemctl --user list-timers openclaw-cleanup.timer

# 手動実行テスト
~/.config/scripts/openclaw-cleanup
```

## Troubleshooting

### Gateway起動問題

**症状**: CPU 99%消費、ポートリスニングせず

#### 確認手順

1. gateway.envが存在するか:

   ```bash
   ls -la ~/.openclaw/gateway.env
   ```

2. override.confが正しいか:

   ```bash
   cat ~/.config/systemd/user/openclaw-gateway.service.d/override.conf
   ```

3. 環境変数が読み込まれているか:

   ```bash
   systemctl --user show openclaw-gateway.service | grep Environment
   ```

4. 詳細ログ確認:

   ```bash
   journalctl --user -u openclaw-gateway.service -n 100
   strace -f ~/.mise/shims/openclaw gateway --port 18789 2>&1 | head -500
   ```

#### 解決方法

1. **gateway.envを作成**（存在しない場合）:

   ```bash
   cat > ~/.openclaw/gateway.env << EOF
   # OpenClaw Gateway environment variables
   OPENCLAW_GATEWAY_PORT=18789
   OPENCLAW_GATEWAY_TOKEN=$(openssl rand -hex 32)
   EOF
   ```

2. serviceを再起動:

   ```bash
   systemctl --user daemon-reload
   systemctl --user restart openclaw-gateway.service
   ```

3. 動作確認:

   ```bash
   systemctl --user status openclaw-gateway.service
   ss -tlnp | grep 18789
   ```

### Cleanup失敗

**症状**: mise/pnpm/npm が見つからない

#### 確認手順

```bash
# PATH設定確認
grep "PATH=" ~/.cache/openclaw/cleanup.log | tail -1

# 手動実行
~/.config/scripts/openclaw-cleanup
```

#### 解決方法

1. PATHが正しく設定されているか確認:
   - scriptに`export PATH="$HOME/.local/bin:$PATH"`が含まれているか
   - serviceに`Environment="PATH=..."`が設定されているか

2. mise/pnpm/npmが実在するか:

   ```bash
   which mise pnpm npm
   ls -la ~/.local/bin/mise
   ls -la ~/.local/share/pnpm
   ```

### Permission Denied

**症状**: `EACCES: permission denied`

#### 解決方法

```bash
# ファイルパーミッション確認
ls -la ~/.openclaw/
ls -la ~/.config/scripts/openclaw-cleanup

# 必要に応じて修正
chmod 600 ~/.openclaw/gateway.env
chmod 755 ~/.config/scripts/openclaw-cleanup
```

### Port Already in Use

**症状**: `Port 18789 is already in use`

#### 確認手順

```bash
# ポート使用プロセス確認
ss -tlnp | grep 18789
lsof -i :18789
```

#### 解決方法

```bash
# 既存プロセスを停止
systemctl --user stop openclaw-gateway.service

# または強制終了
kill <PID>

# 再起動
systemctl --user start openclaw-gateway.service
```

## Security Best Practices

### TOKEN管理

1. **定期的なTOKEN更新**（推奨: 3ヶ月毎）:

   ```bash
   # 新しいTOKEN生成
   NEW_TOKEN=$(openssl rand -hex 32)

   # gateway.env更新
   sed -i "s/OPENCLAW_GATEWAY_TOKEN=.*/OPENCLAW_GATEWAY_TOKEN=${NEW_TOKEN}/" ~/.openclaw/gateway.env

   # gateway再起動
   systemctl --user restart openclaw-gateway.service
   ```

2. TOKENのバックアップ:
   - 暗号化されたストレージに保存
   - パスワードマネージャーに記録
   - `.env`ファイルとして管理しない

3. ネットワーク公開時の注意:
   - Gateway は`lan` (0.0.0.0) にバインドされている
   - ファイアウォール設定で外部アクセスを制限
   - 強力なTOKENを使用

### セキュリティ監査

```bash
# 定期的な監査実行（推奨: 月次）
openclaw security audit --deep

# 設定確認
openclaw config list

# アクセスログ確認
tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log
```

## Environment-Specific Notes

### Raspberry Pi ARM環境

#### 特性

- メモリ制約: 3.7GB RAM
- ARM64アーキテクチャ
- k3s-serverと共存

#### 最適化

- リソース制限無効化（MemoryMax, CPUQuota）
- Watchdog無効化（タイムアウト回避）
- Cleanup並列実行数削減（mise: jobs=2）

**参考**: `mise/config.pi.toml`で環境別設定を管理

### システム再起動後の確認

システム再起動後は以下を確認:

```bash
# Gateway自動起動確認
systemctl --user status openclaw-gateway.service

# Timer自動起動確認
systemctl --user list-timers openclaw-cleanup.timer

# 動作確認
curl http://localhost:18789/health
```

## Related Documentation

- 詳細トラブルシューティング: `docs/troubleshooting/openclaw-gateway-raspberry-pi.md`
- 修正履歴: `docs/troubleshooting/openclaw-modifications-20260215.md`
- 再起動後検証: `docs/troubleshooting/openclaw-post-reboot-verification.md`
- Workflows: `.claude/rules/workflows-and-maintenance.md`
- mise設定: `.claude/rules/tools/mise.md`

## Quick Reference

### 緊急時コマンド

```bash
# Gatewayが応答しない
systemctl --user restart openclaw-gateway.service

# CPU 99%消費
systemctl --user stop openclaw-gateway.service
# gateway.env確認・修正
systemctl --user start openclaw-gateway.service

# ディスク容量逼迫
~/.config/scripts/openclaw-cleanup

# ログ急増
rm -f /tmp/openclaw/*.log
systemctl --user restart openclaw-gateway.service
```

### 定期確認項目

#### 日次

- Gateway動作状態（自動監視推奨）

#### 週次

- ログファイルサイズ
- ディスク使用量

#### 月次

- mise/pnpm/npm更新
- セキュリティ監査
- TOKEN更新検討

---

**最終更新**: 2026-02-15
**次回レビュー**: 2026-05-15（四半期後）
