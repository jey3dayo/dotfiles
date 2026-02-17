# OpenClaw Gateway起動問題 - Raspberry Pi ARM環境

**ステータス**: ✅ 解決済み
**最終更新**: 2026-02-15
**環境**: Raspberry Pi, ARM64, 4コア, 3.7GB RAM
**影響**: openClaw Gateway起動時にCPU 99%消費、ポートリスニングせず → **gateway.env作成で解決**

## 問題概要

openClaw Gateway（バージョン2026.2.1、2026.2.13で確認）がRaspberry Pi ARM環境で正常に起動しない問題が発生しましたが、**gateway.envファイルの作成で解決しました**。

#### 当初の症状

- プロセスは起動するが、**CPU 99.9%を消費し続ける**
- **ポート18789をリスニングしない**
- 90秒以上待機しても状態変わらず
- systemdログに標準出力/エラー出力なし

#### 解決後の状態 (2026-02-15 14:16)

- ✅ CPU使用率: 27.5%（起動1分35秒後、正常範囲）
- ✅ ポート18789: LISTEN状態、正常動作
- ✅ WebSocketサーバー: `ws://0.0.0.0:18789` でリスニング
- ✅ 各種サービス: Discord bot, Telegram bot, Browser service 全て起動成功

#### 検証済みの動作

- ✓ mise（バージョン管理ツール）
- ✓ pnpm（パッケージマネージャー）
- ✓ systemd（サービス管理）
- ✓ openclaw CLI コマンド（config, doctor等）
- ✓ openclaw-cleanup.timer（タイマー設定）

## 実施した修復作業（2026-02-15）

### ✅ 成功した修正

1. ディスク容量改善
   - mise prune: kubectl, pnpm, python古いバージョン削除
   - pnpm store prune: 14,156ファイル、152パッケージ削除
   - nix-collect-garbage: 73.6 MiB + 古いgenerations削除
   - **結果**: ディスク使用率 94% → 92% に改善

2. systemd設定修正
   - 孤立シンボリックリンク削除: `default.target.wants/openclaw.service`
   - `openclaw-cleanup.timer`: `After=default.target` 追加
   - `openclaw-cleanup.service`: PATH設定、環境変数、Retry設定追加
   - `openclaw-gateway.service`: Watchdog無効化（タイムアウト問題回避）

3. Cleanup Script修正
   - PATH設定追加: `export PATH="$HOME/.local/bin:$PATH"`
   - PATH確認用ログ出力追加
   - npm cache clean出力フィルタリング改善

4. openClaw設定修正
   - 完全リセット＋再セットアップ実施
   - gateway.bind=lan, gateway.port=18789設定
   - override.conf復元（EnvironmentFile参照を有効化）

5. **gateway.env作成** ⭐ **決定的な解決策**
   - `~/.openclaw/gateway.env`を作成
   - `OPENCLAW_GATEWAY_PORT=18789`を定義
   - `OPENCLAW_GATEWAY_TOKEN`を新規生成（openssl rand -hex 32）
   - override.confからEnvironmentFileとして読み込み

6. openclawバージョン更新
   - 2026.2.1 → 2026.2.13に更新
   - `openclaw doctor --fix`実行で自動修復

### ✅ 解決した問題

**Gateway起動問題**は**gateway.envファイルの作成**で完全に解決しました。

## 根本原因（判明）

**原因**: `override.conf`が`~/.openclaw/gateway.env`を参照していたが、ファイルが存在しなかった。

### 問題の流れ

1. systemd の`override.conf`に`EnvironmentFile=%h/.openclaw/gateway.env`が設定されていた
2. `gateway.env`ファイルが存在しない状態で起動
3. 環境変数（特に`OPENCLAW_GATEWAY_TOKEN`）が読み込まれない
4. 認証情報不足でGatewayが初期化に失敗
5. 無限ループまたはリトライでCPU 99%消費

### 解決方法

`~/.openclaw/gateway.env`を作成し、必要な環境変数を定義：

```bash
# OpenClaw Gateway environment variables
OPENCLAW_GATEWAY_PORT=18789
OPENCLAW_GATEWAY_TOKEN=<新規生成したTOKEN>
```

これにより、systemdがEnvironmentFileを正常に読み込み、Gatewayが起動できるようになった。

## 推奨される対処法

### Option 1: システム再起動（推奨）

システムリソースをリセットして再度確認:

```bash
sudo reboot

# 再起動後、リソースがリセットされた状態で確認
systemctl --user status openclaw-gateway.service
openclaw doctor --deep
ps aux | grep openclaw
ss -tlnp | grep 18789
curl http://localhost:18789/health
```

#### 期待効果

- システムリソースのリセット
- systemd依存関係の再初期化
- CPU負荷の低減

### Option 2: openClawコミュニティへ報告

Raspberry Pi環境での既知の問題の可能性があるため、以下の情報と共に報告:

- システム: Raspberry Pi, ARM64, 4コア, 3.7GB RAM
- openClawバージョン: 2026.2.1
- 症状: Gateway起動時にCPU 99%消費、ポートリスニングせず
- ログ: journalctlに標準出力なし

### Option 3: 代替ソリューション

openClawの代わりに、以下の選択肢を検討:

- openClaw Gatewayを別のマシン（x86_64）で実行
- Raspberry Piでは軽量なエージェントのみ実行
- openClawの古い安定版を試す（入手可能な場合）

### Option 4: Node.js環境の確認

```bash
# Node.jsバージョン確認
node --version
npm --version

# openClawを直接実行してエラー確認
~/.mise/shims/openclaw gateway --port 18789 --verbose
```

## 修復されたファイル一覧

1. `/home/pi/.config/scripts/openclaw-cleanup`
   - PATH設定追加

2. `/home/pi/.config/systemd/user/openclaw-cleanup.timer`
   - After=default.target追加

3. `/home/pi/.config/systemd/user/openclaw-cleanup.service`
   - 環境変数、Retry設定追加

4. `/home/pi/.config/systemd/user/openclaw-gateway.service`
   - Watchdog無効化、リソース制限コメントアウト

5. `/home/pi/.config/systemd/user/openclaw-gateway.service.d/override.conf`
   - 復元（EnvironmentFileを参照）

6. `/home/pi/.openclaw/gateway.env` ⭐ **新規作成**
   - `OPENCLAW_GATEWAY_PORT=18789`
   - `OPENCLAW_GATEWAY_TOKEN=<新規生成>`
   - **重要**: このファイルには機密情報（TOKEN）が含まれるため、Gitで管理しないこと

7. `/home/pi/.openclaw/openclaw.json`
   - 完全リセット＋再セットアップ（バージョン2026.2.13に更新）

8. `/home/pi/.config/systemd/user/default.target.wants/openclaw.service`
   - 削除（孤立シンボリックリンク）

## バックアップ

設定のバックアップが以下に保存されています:

- `~/openclaw-backup-20260215_121920/`

## 次回の作業

システム再起動後、以下のチェックを実施:

1. Gateway自動起動確認
2. Cleanup Timer動作確認
3. Doctor診断でエラーなし確認
4. ディスク使用率安定確認（90%以下）

## 関連ドキュメント

- `docs/troubleshooting/openclaw-modifications-20260215.md` - 実施した変更の詳細履歴

---

**結論**: ディスク容量とsystemd設定の問題は解決しましたが、openClaw Gateway自体の起動問題は**Raspberry Pi環境固有の問題**または**openClawのバグ**の可能性が高く、システム再起動またはコミュニティへの報告を推奨します。
