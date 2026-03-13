# OpenClaw Reference

最終更新: 2026-03-13
対象: 運用担当
タグ: `category/maintenance`, `tool/openclaw`, `layer/tool`, `environment/linux`, `audience/ops`

Claude Rules: [.claude/rules/openclaw.md](../../.claude/rules/openclaw.md)

## Configuration Structure

### Environment Variables (`~/.openclaw/gateway.env`)

```bash
OPENCLAW_GATEWAY_PORT=18789
OPENCLAW_GATEWAY_TOKEN=<generated-token>
```

重要: 機密情報を含むため Git 管理しない（`.config` リポジトリ外）。

TOKEN 生成:

```bash
echo "OPENCLAW_GATEWAY_TOKEN=$(openssl rand -hex 32)" >> ~/.openclaw/gateway.env
```

### systemd Configuration

#### Gateway Service (`~/.config/systemd/user/openclaw-gateway.service`)

#### 設計原則

- ExecStart はラッパースクリプト経由（unit にバージョン埋め込みパスを直書きしない）
- ラッパースクリプトで複数候補から openclaw 実体を解決（`npm-openclaw/latest` 優先、`command -v` フォールバック）
- node は `~/.mise/installs/node/latest/bin/node` を優先（systemd での shim 依存を避ける）
- 環境変数は gateway.env 経由で読み込み
- リソース制限と Watchdog は無効化（Raspberry Pi 対応）

```ini
[Service]
ExecStart=%h/.config/scripts/openclaw-gateway gateway --port 18789
Restart=always
RestartSec=10
KillMode=mixed
Environment=HOME=%h
Environment=TMPDIR=/tmp
Environment="PATH=%h/.local/share/pnpm:%h/.local/bin:%h/bin:/usr/local/bin:/usr/bin:/bin"
Environment=OPENCLAW_GATEWAY_PORT=18789
Environment="OPENCLAW_BUNDLED_PLUGINS_DIR=%h/.openclaw/bundled-plugins"
```

override.conf (`~/.config/systemd/user/openclaw-gateway.service.d/override.conf`):

```ini
[Service]
EnvironmentFile=%h/.openclaw/gateway.env
```

#### Wrapper Script (`~/.config/scripts/openclaw-gateway`)

`openclaw` 実行ファイルを候補順に解決し、見つからない場合のみ `command -v` にフォールバック。
openclawアップデート後も設定変更不要。

`latest` シムリンクはmiseが自動更新するとは限らないため、アップデート後に確認:

```bash
ls -la ~/.mise/installs/npm-openclaw/latest
```

#### Cleanup Service (`~/.config/systemd/user/openclaw-cleanup.service`)

目的: 定期的なディスククリーンアップ（mise/pnpm/npm）

```ini
[Service]
Type=oneshot
# Wants=openclaw-gateway.service は設定しないこと
# 循環依存が発生するため: default.target → timers.target → cleanup → gateway → default.target
```

タイマー: `~/.config/systemd/user/openclaw-cleanup.timer` — 毎日 05:00 実行

### Cleanup Script (`~/.config/scripts/openclaw-cleanup`)

機能: mise prune / bundled-plugins 自動同期 / pnpm store prune / npm cache clean / ディスク使用量記録

#### bundled-plugins 自動同期 (openclaw 2026.2.26+)

1. バイナリ解決: `scripts/openclaw-gateway` と同じ候補リストで openclaw 実体を特定
2. extensions 探索: `bin/` の親ディレクトリから glob で発見
3. non-hardlink コピー: `~/.openclaw/bundled-plugins/` に `cp -r`

ログ: `~/.cache/openclaw/cleanup.log`

### systemd 設計比較

| 項目     | Gateway Service  | Cleanup Service      |
| -------- | ---------------- | -------------------- |
| Type     | simple（永続）   | oneshot              |
| PATH     | 直接バイナリ参照 | mise shim 経由       |
| Restart  | always           | on-failure           |
| KillMode | mixed            | 未設定（デフォルト） |

## Common Operations

### Gateway 管理

```bash
systemctl --user start openclaw-gateway.service
systemctl --user stop openclaw-gateway.service
systemctl --user restart openclaw-gateway.service
systemctl --user status openclaw-gateway.service
systemctl --user daemon-reload   # 設定変更後
```

### ログ確認

```bash
journalctl --user -u openclaw-gateway.service -n 100
tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log
tail -f ~/.cache/openclaw/cleanup.log
```

### 診断

```bash
openclaw doctor
openclaw doctor --fix
openclaw security audit --deep
openclaw config list
```

### 動作確認

```bash
ss -tlnp | grep 18789           # ポートリスニング確認
curl http://localhost:18789/health  # ヘルスチェック
ps aux | grep openclaw | grep -v grep
```

### 緊急時コマンド

```bash
# Gateway 応答なし
systemctl --user restart openclaw-gateway.service

# CPU 99% 消費: gateway.env 確認・修正後
systemctl --user stop openclaw-gateway.service
systemctl --user start openclaw-gateway.service

# ディスク容量逼迫
~/.config/scripts/openclaw-cleanup

# ログ急増
rm -f /tmp/openclaw/*.log
systemctl --user restart openclaw-gateway.service
```

## Maintenance

### 月次メンテナンス

1. バージョン更新: `mise upgrade && mise prune`
2. Cleanup 実行履歴確認: `tail -50 ~/.cache/openclaw/cleanup.log`
3. ディスク使用量確認: `df -h /`
4. Gateway 状態確認: `systemctl --user status openclaw-gateway.service`

### Timer 動作確認

```bash
systemctl --user list-timers
systemctl --user list-timers openclaw-cleanup.timer
~/.config/scripts/openclaw-cleanup  # 手動実行テスト
```

## Troubleshooting

### Gateway 起動問題（CPU 99% 消費、ポートリスニングせず）

```bash
# 1. gateway.env 存在確認
ls -la ~/.openclaw/gateway.env

# 2. override.conf 確認
cat ~/.config/systemd/user/openclaw-gateway.service.d/override.conf

# 3. 環境変数が読み込まれているか
systemctl --user show openclaw-gateway.service | grep Environment

# 4. 詳細ログ
journalctl --user -u openclaw-gateway.service -n 100
```

解決:

```bash
cat > ~/.openclaw/gateway.env << EOF
OPENCLAW_GATEWAY_PORT=18789
OPENCLAW_GATEWAY_TOKEN=$(openssl rand -hex 32)
EOF
systemctl --user daemon-reload
systemctl --user restart openclaw-gateway.service
ss -tlnp | grep 18789
```

### MODULE_NOT_FOUND / 起動後即終了

原因: ExecStart のパスが古いバージョンを指したまま、または mise shim のハング

```bash
systemctl --user cat openclaw-gateway.service | grep ExecStart
ls -la ~/.mise/installs/npm-openclaw/latest
```

### plugins.slots.memory: plugin not found: memory-core

原因: openclaw 2026.2.26+ のセキュリティ強化により pnpm store 内のハードリンクが "unsafe" 扱い

```bash
EXTENSIONS_SRC=$(ls -d ~/.mise/installs/npm-openclaw/*/5/.pnpm/openclaw@*/node_modules/openclaw/extensions 2>/dev/null | tail -1)
rm -rf ~/.openclaw/bundled-plugins
cp -r "$EXTENSIONS_SRC" ~/.openclaw/bundled-plugins
systemctl --user daemon-reload && systemctl --user restart openclaw-gateway.service
```

次回バージョンアップ後は `scripts/openclaw-cleanup` が自動同期するため手動対応不要。

### Gateway 起動時に循環依存エラー

症状: `Found ordering cycle on openclaw-gateway.service/start`

原因: `openclaw-cleanup.service` に `Wants=openclaw-gateway.service` がある

```bash
grep "Wants" ~/.config/systemd/user/openclaw-cleanup.service
# Wants=openclaw-gateway.service 行を削除
systemctl --user daemon-reload
systemctl --user start openclaw-gateway.service
```

### Port Already in Use

```bash
ss -tlnp | grep 18789
lsof -i :18789
systemctl --user stop openclaw-gateway.service
systemctl --user start openclaw-gateway.service
```

### Cleanup 失敗（mise/pnpm/npm が見つからない）

```bash
grep "PATH=" ~/.cache/openclaw/cleanup.log | tail -1
which mise pnpm npm
ls -la ~/.local/bin/mise
```

### Permission Denied

```bash
chmod 600 ~/.openclaw/gateway.env
chmod 755 ~/.config/scripts/openclaw-cleanup
```

## Security Best Practices

### TOKEN 管理

TOKEN 更新（推奨: 3ヶ月毎）:

```bash
sed -i "s/OPENCLAW_GATEWAY_TOKEN=.*/OPENCLAW_GATEWAY_TOKEN=$(openssl rand -hex 32)/" ~/.openclaw/gateway.env
systemctl --user restart openclaw-gateway.service
```

- TOKEN はパスワードマネージャーに記録
- `.env` ファイルとして管理しない
- Gateway は `0.0.0.0` にバインドされるため、ファイアウォール設定で外部アクセスを制限

### 定期セキュリティ監査（月次）

```bash
openclaw security audit --deep
openclaw config list
tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log
```

## Raspberry Pi ARM 環境

### 特性

- メモリ制約: 3.7GB RAM / ARM64 / k3s-server と共存

### 最適化

- リソース制限無効化（MemoryMax, CPUQuota）
- Watchdog 無効化（タイムアウト回避）
- Cleanup 並列実行数削減（mise: jobs=2）
- 起動完了まで 2〜3 分かかる。`ss -tlnp | grep 18789` でポートが出るまで待つ

参考: `mise/config.pi.toml` で環境別設定を管理

## システム再起動後の確認

```bash
systemctl --user status openclaw-gateway.service
systemctl --user list-timers openclaw-cleanup.timer
curl http://localhost:18789/health
```

## Related Documentation

- 修正履歴: `docs/troubleshooting/openclaw-modifications-20260215.md`
- 再起動後検証: `docs/troubleshooting/openclaw-post-reboot-verification.md`
- mise 設定: `.claude/rules/tools/mise.md`
