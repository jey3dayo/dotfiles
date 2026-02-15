# OpenClaw 再起動後の検証手順

**作成日**: 2026-02-15
**目的**: システム再起動後にOpenClaw Gateway起動問題が解決したか確認する

## 前提条件

以下の修正が適用済みであること:

- systemd設定の改善（After/Wants/PATH/Retry）
- cleanup scriptのPATH設定追加
- Gateway serviceのWatchdog無効化
- override.conf削除完了

コミット: `8fdae8c9` (fix(openclaw): improve systemd service and cleanup script reliability)

## 検証手順

### Step 1: systemd設定のリロード

再起動後、まずsystemd設定をリロードします:

```bash
systemctl --user daemon-reload
```

### Step 2: Gateway起動状態の確認

Gateway serviceの状態を確認:

```bash
# サービスステータス確認
systemctl --user status openclaw-gateway.service

# プロセス確認（CPU使用率に注目）
ps aux | grep openclaw | grep -v grep

# ポートリスニング確認
ss -tlnp | grep 18789

# ヘルスチェック（ポートがリスニングしている場合）
curl http://localhost:18789/health
```

**期待される結果**:

- ✅ `active (running)` 状態
- ✅ プロセスのCPU使用率が正常範囲（<10%）
- ✅ ポート18789がLISTEN状態
- ✅ ヘルスチェックが応答する

**失敗した場合**:

- ❌ CPU 99%消費が継続
- ❌ ポートがリスニングしない
- ❌ プロセスが起動しない

→ **既知の問題として確定**（次のステップへ）

### Step 3: Cleanup Service/Timerの確認

```bash
# Cleanup service状態確認
systemctl --user status openclaw-cleanup.service

# Timer状態確認
systemctl --user list-timers openclaw-cleanup.timer
```

**期待される結果**:

- ✅ Timer が `NEXT` 列に次回実行時刻を表示
- ✅ Service が `inactive (dead)` または最近実行された形跡

### Step 4: Cleanup Scriptの手動実行テスト

```bash
# 手動実行
~/.config/scripts/openclaw-cleanup

# ログ確認
cat ~/.cache/openclaw/cleanup.log

# PATH設定が有効か確認
grep "PATH=" ~/.cache/openclaw/cleanup.log | tail -1
```

**期待される結果**:

- ✅ エラーなく実行完了
- ✅ `mise`, `pnpm`, `npm` が全て見つかる
- ✅ PATH に `/home/pi/.local/bin` が含まれる

### Step 5: OpenClaw診断実行

```bash
# 診断実行
openclaw doctor --deep

# 設定確認
openclaw config list
```

**期待される結果**:

- ✅ 診断でエラーなし
- ✅ Gateway設定が正しく表示される

### Step 6: システムリソース確認

```bash
# CPU負荷確認
uptime

# ディスク使用量確認
df -h /

# メモリ使用量確認
free -h
```

**期待される結果**:

- ✅ load average が正常範囲（<2.0）
- ✅ ディスク使用率が92%以下
- ✅ スワップ使用量が最小限

## 結果の判定

### シナリオA: Gateway起動成功 🎉

全てのチェックが✅の場合:

1. **問題解決を記録**:
   - `docs/troubleshooting/openclaw-gateway-raspberry-pi.md` に「再起動で解決」を追記
   - システムリソース不足が原因だったと記録

2. **定期監視を設定**:
   - Gateway serviceの定期チェックをcronまたはsystemd timerで設定
   - CPU使用率監視スクリプトを追加（オプション）

### シナリオB: Gateway起動失敗（CPU 99%継続） ❌

Step 2でCPU 99%消費が継続する場合:

1. **ログ収集**:

   ```bash
   # systemdログ
   journalctl --user -u openclaw-gateway.service -n 100 > ~/openclaw-gateway-after-reboot.log

   # プロセス詳細
   ps aux | grep openclaw | grep -v grep >> ~/openclaw-gateway-after-reboot.log

   # strace実行（詳細診断）
   systemctl --user stop openclaw-gateway.service
   strace -f ~/.mise/shims/openclaw gateway --port 18789 2>&1 | head -500 >> ~/openclaw-gateway-strace.log
   ```

2. **既知の問題として確定**:
   - `docs/troubleshooting/openclaw-gateway-raspberry-pi.md` に「再起動後も未解決」を追記
   - Raspberry Pi ARM環境固有の問題として記録

3. **代替案の検討**:
   - **Option 1**: openClawコミュニティへ報告（ログファイルとシステム情報を添付）
   - **Option 2**: 別マシン（x86_64）でGatewayを実行
   - **Option 3**: openClaw使用を一時停止し、代替ツールを検討

### シナリオC: Cleanup動作確認のみ成功 ✅

Step 2は失敗、Step 4は成功の場合:

1. **部分的な成功を記録**:
   - Cleanup機能は正常動作
   - Gateway問題は未解決

2. **定期クリーンアップ継続**:
   - `openclaw-cleanup.timer` は有効なまま
   - ディスク使用量監視を継続

## トラブルシューティング

### Gateway serviceが起動しない

```bash
# 依存関係確認
systemctl --user list-dependencies openclaw-gateway.service

# override.confが削除されているか確認
ls -la ~/.config/systemd/user/openclaw-gateway.service.d/

# miseでopenclawが利用可能か確認
mise which openclaw
~/.mise/shims/openclaw --version
```

### PATH問題が継続

```bash
# 環境変数確認
systemctl --user show-environment

# サービス起動時の環境変数確認
systemctl --user show openclaw-cleanup.service | grep Environment
```

### タイマーが動作しない

```bash
# タイマー状態確認
systemctl --user list-timers --all

# タイマー再起動
systemctl --user restart openclaw-cleanup.timer
systemctl --user status openclaw-cleanup.timer
```

## 関連ドキュメント

- 問題詳細: `docs/troubleshooting/openclaw-gateway-raspberry-pi.md`
- 修正履歴: `docs/troubleshooting/openclaw-modifications-20260215.md`
- Nix運用: `.claude/rules/nix-maintenance.md`
- Workflows: `.claude/rules/workflows-and-maintenance.md`

## Claude AI へのプロンプト例

検証結果を報告する際のプロンプト例:

### 成功時

```
OpenClaw Gateway再起動後の検証を完了しました。

結果:
- Gateway起動: ✅ 成功（CPU使用率正常、ポート18789リスニング）
- Cleanup動作: ✅ 正常
- システムリソース: 正常範囲

docs/troubleshooting/openclaw-gateway-raspberry-pi.md に
「システム再起動で解決」を追記してください。
```

### 失敗時（Gateway起動問題継続）

```
OpenClaw Gateway再起動後の検証を完了しました。

結果:
- Gateway起動: ❌ 失敗（CPU 99%消費継続、ポートリスニングせず）
- Cleanup動作: ✅ 正常
- システムリソース: load average 正常

ログファイル作成済み:
- ~/openclaw-gateway-after-reboot.log
- ~/openclaw-gateway-strace.log

docs/troubleshooting/openclaw-gateway-raspberry-pi.md に
「再起動後も未解決、コミュニティ報告推奨」を追記してください。

代替案を検討します。
```

### 部分成功時

```
OpenClaw Gateway再起動後の検証を完了しました。

結果:
- Gateway起動: ❌ 失敗（CPU 99%消費継続）
- Cleanup動作: ✅ 正常（mise/pnpm/npm全て発見）
- Timer設定: ✅ 正常（次回05:00実行予定）

Cleanup機能は正常動作しているため、
定期ディスククリーンアップは継続可能です。

Gateway問題は既知の問題として記録します。
```

## 次回メンテナンス時の確認項目

月次メンテナンス（毎月第一日曜日）で以下を確認:

1. **Cleanup実行履歴**:

   ```bash
   tail -50 ~/.cache/openclaw/cleanup.log
   ```

2. **ディスク使用量推移**:

   ```bash
   df -h / | tail -1
   ```

3. **Gateway状態**（起動成功している場合）:

   ```bash
   systemctl --user status openclaw-gateway.service
   ```

4. **mise/pnpm/npmバージョン更新**:
   ```bash
   mise upgrade
   mise prune
   ```

---

**最終更新**: 2026-02-15
**次回更新**: システム再起動後の検証結果を反映
