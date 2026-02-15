# OpenClaw Gateway サービス - Raspberry Pi 配布手順

## 概要

このドキュメントは、OpenClaw Gateway サービスをWSL2環境からRaspberry Piに配布し、systemd user serviceとして起動するための手順を提供します。

**配布内容**:

- systemd user service定義ファイル
- サービス設定のオーバーライド
- 環境変数ファイル（認証トークンとすべての秘密情報を含む）

**対象環境**:

- **転送元**: WSL2（現在の環境）
- **転送先**: Raspberry Pi（`pi.local`）
- **ポート**: 18789
- **起動方法**: mise shim経由

---

## 前提条件

### WSL2側（転送元）

- [x] OpenClaw Gateway サービスが正常に稼働している
- [x] 必要なファイルがすべて存在する:
  - `~/.config/systemd/user/openclaw-gateway.service`
  - `~/.config/systemd/user/openclaw-gateway.service.d/override.conf`
  - `~/.openclaw/gateway.env`

### Raspberry Pi側（転送先）

- [ ] SSH経由で`pi.local`に接続可能
- [ ] miseがインストールされている
- [ ] miseでopenclawがインストールされている（`mise install openclaw`）
- [ ] `~/.mise/shims/openclaw`が存在する

---

## Phase 1: ファイル転送（WSL2 → Raspberry Pi）

### 1.1 ディレクトリ作成（Pi側）

まずPi側でSSH接続し、必要なディレクトリを作成します:

```bash
ssh pi@pi.local

# systemd user serviceディレクトリ作成
mkdir -p ~/.config/systemd/user/openclaw-gateway.service.d

# OpenClaw設定ディレクトリ作成
mkdir -p ~/.openclaw

# ログアウト
exit
```

### 1.2 ファイル転送（WSL2側で実行）

以下のコマンドをWSL2側で実行し、すべてのファイルをPiに転送します:

```bash
# 1. systemd serviceファイル転送
scp ~/.config/systemd/user/openclaw-gateway.service pi@pi.local:~/.config/systemd/user/

# 2. override.confファイル転送
scp ~/.config/systemd/user/openclaw-gateway.service.d/override.conf pi@pi.local:~/.config/systemd/user/openclaw-gateway.service.d/

# 3. 環境変数ファイル転送（すべての秘密情報含む）
scp ~/.openclaw/gateway.env pi@pi.local:~/.openclaw/
```

**転送されるファイルの内容**:

- **openclaw-gateway.service**: サービス定義（ポート18789、mise shim使用）
- **override.conf**: 環境変数ファイルの読み込み設定
- **gateway.env**: 以下の秘密情報を含む:
  - `OPENCLAW_GATEWAY_TOKEN`: 認証トークン
  - `DISCORD_BOT_TOKEN`: Discordボット認証トークン
  - `TELEGRAM_BOT_TOKEN`: Telegramボット認証トークン
  - `GOG_KEYRING_PASSWORD`: GOGキーリングパスワード
  - `NODE_OPTIONS`: Node.js DNS設定

### 1.3 転送確認

Pi側で転送が成功したか確認します:

```bash
ssh pi@pi.local

# ファイル存在確認
ls -la ~/.config/systemd/user/openclaw-gateway.service
ls -la ~/.config/systemd/user/openclaw-gateway.service.d/override.conf
ls -la ~/.openclaw/gateway.env

# ファイル内容を確認（秘密情報が含まれるので注意）
cat ~/.config/systemd/user/openclaw-gateway.service
cat ~/.openclaw/gateway.env
```

---

## Phase 2: Pi側でのセキュリティ設定

### 2.1 ファイルパーミッション設定

**重要**: 環境変数ファイルには秘密情報が含まれるため、パーミッションを600に設定します（所有者のみ読み書き可能）:

```bash
ssh pi@pi.local

# 環境変数ファイルのパーミッション設定（必須）
chmod 600 ~/.openclaw/gateway.env

# パーミッション確認（-rw------- が正しい）
ls -la ~/.openclaw/gateway.env
# 期待される出力: -rw------- 1 pi pi 456 Feb 15 12:00 gateway.env
```

---

## Phase 3: systemd serviceの設定と起動

### 3.1 systemdのリロードと有効化

```bash
ssh pi@pi.local

# systemd user serviceをリロード（新しいサービスファイルを認識）
systemctl --user daemon-reload

# サービスを有効化（起動時に自動起動）
systemctl --user enable openclaw-gateway.service

# サービスを起動
systemctl --user start openclaw-gateway.service
```

### 3.2 サービスステータス確認

```bash
# サービスが正常に起動しているか確認
systemctl --user status openclaw-gateway.service

# 期待される出力:
# ● openclaw-gateway.service - OpenClaw Gateway (v2026.2.2-3)
#      Loaded: loaded (/home/pi/.config/systemd/user/openclaw-gateway.service; enabled; preset: enabled)
#     Drop-In: /home/pi/.config/systemd/user/openclaw-gateway.service.d
#              └─override.conf
#      Active: active (running) since Sat 2026-02-15 12:00:00 JST; 10s ago
#    Main PID: 12345 (openclaw)
#       Tasks: 11 (limit: 4915)
#      Memory: 45.2M
#         CPU: 1.234s
#      CGroup: /user.slice/user-1000.slice/user@1000.service/app.slice/openclaw-gateway.service
#              └─12345 /home/pi/.mise/shims/openclaw gateway --port 18789
```

---

## Phase 4: 動作確認

### 4.1 miseとopenclawの確認

```bash
# miseでopenclawがインストールされているか確認
mise ls | grep openclaw
# 期待される出力: openclaw 2026.2.2-3 (active)

# openclaw shimが存在するか確認
ls -la ~/.mise/shims/openclaw
```

### 4.2 ポートリッスン確認

```bash
# ポート18789でListenしているか確認
ss -tlnp | grep 18789

# 期待される出力:
# LISTEN 0      511    0.0.0.0:18789      0.0.0.0:*    users:(("node",pid=12345,fd=19))
```

### 4.3 ログ確認

```bash
# 最新50行のログを表示
journalctl --user -u openclaw-gateway -n 50

# リアルタイムでログを監視（Ctrl+Cで終了）
journalctl --user -u openclaw-gateway -f
```

### 4.4 リモート接続テスト（WSL2側で実行）

WSL2側からPiのOpenClaw Gatewayに接続できるか確認します:

```bash
# curlでヘルスチェック（Pi側でエンドポイントが実装されている場合）
curl http://pi.local:18789/health

# または、telnetでポート接続確認
telnet pi.local 18789
# 接続できたらCtrl+]で終了、quitで終了
```

---

## トラブルシューティング

### 問題1: サービスが起動しない（"Failed to start"）

**原因**: mise shimが見つからない、またはopenclawがインストールされていない

**解決策**:

```bash
# miseでopenclawがインストールされているか確認
mise ls | grep openclaw

# インストールされていない場合はインストール
mise install openclaw

# shimが生成されているか確認
ls -la ~/.mise/shims/openclaw

# shimが無い場合は、miseのreshimを実行
mise reshim

# サービスを再起動
systemctl --user restart openclaw-gateway.service
```

### 問題2: "Permission denied" エラー（環境変数ファイル読み込み時）

**原因**: `gateway.env`のパーミッションが正しく設定されていない

**解決策**:

```bash
# パーミッション確認
ls -la ~/.openclaw/gateway.env

# パーミッションを600に設定（所有者のみ読み書き可能）
chmod 600 ~/.openclaw/gateway.env

# サービスを再起動
systemctl --user restart openclaw-gateway.service
```

### 問題3: ポート18789が既に使用されている

**原因**: 他のプロセスがポート18789を使用している

**解決策**:

```bash
# ポート18789を使用しているプロセスを確認
sudo lsof -i:18789

# プロセスを停止（必要に応じて）
sudo kill <PID>

# または、ポート番号を変更する場合:
# 1. gateway.envを編集
nano ~/.openclaw/gateway.env
# OPENCLAW_GATEWAY_PORT=18789 を別のポートに変更（例: 18790）

# 2. service.override.confでポートを統一するか、gateway.envのみに依存する

# 3. サービスを再起動
systemctl --user restart openclaw-gateway.service
```

### 問題4: ログに "Cannot find module" エラーが出る

**原因**: Node.jsモジュールが不足している、またはopenclawのバージョンが古い

**解決策**:

```bash
# openclawを最新バージョンに更新
mise install openclaw@latest
mise use openclaw@latest

# サービスを再起動
systemctl --user restart openclaw-gateway.service
```

### 問題5: systemd lingering未設定（再起動後にサービスが起動しない）

**原因**: Pi再起動後、ユーザーログアウト時にuser serviceが停止する

**解決策**:

```bash
# systemd lingeringを有効化（ユーザーログアウト後もuser serviceが動作し続ける）
sudo loginctl enable-linger pi

# 設定確認
ls /var/lib/systemd/linger/
# "pi" が表示されればOK
```

---

## サービス管理コマンド

### 起動・停止・再起動

```bash
# サービス起動
systemctl --user start openclaw-gateway.service

# サービス停止
systemctl --user stop openclaw-gateway.service

# サービス再起動
systemctl --user restart openclaw-gateway.service

# サービスの自動起動を有効化
systemctl --user enable openclaw-gateway.service

# サービスの自動起動を無効化
systemctl --user disable openclaw-gateway.service
```

### ステータス確認

```bash
# サービスステータス確認
systemctl --user status openclaw-gateway.service

# サービスが有効化されているか確認
systemctl --user is-enabled openclaw-gateway.service

# サービスが起動しているか確認
systemctl --user is-active openclaw-gateway.service
```

### ログ確認

```bash
# 最新50行のログ表示
journalctl --user -u openclaw-gateway -n 50

# リアルタイムログ監視
journalctl --user -u openclaw-gateway -f

# エラーログのみ表示
journalctl --user -u openclaw-gateway -p err

# 今日のログのみ表示
journalctl --user -u openclaw-gateway --since today
```

---

## セキュリティ考慮事項

### ファイルパーミッション

| ファイル                   | パーミッション | 理由                                         |
| -------------------------- | -------------- | -------------------------------------------- |
| `openclaw-gateway.service` | 644            | systemdが読めれば良い（秘密情報なし）        |
| `override.conf`            | 644            | systemdが読めれば良い（秘密情報なし）        |
| `gateway.env`              | **600**        | **秘密情報を含むため所有者のみ読み書き可能** |

### 秘密情報の管理

- **gateway.envは絶対にGitリポジトリにコミットしない**（既に`.gitignore`で除外済み）
- **scpでの転送時はSSH暗号化通信で保護される**
- **Pi側でも必ずパーミッション600に設定する**（Phase 2.1参照）

### systemd user service

- **rootless実行**: root権限不要、ユーザー権限で起動
- **systemd lingering**: `loginctl enable-linger`でユーザーログアウト後も動作継続
- **自動再起動**: `Restart=always`でクラッシュ時に自動再起動

---

## Pi固有の最適化

### メモリ制約対応

Raspberry Piではメモリが限られているため、必要に応じて`NODE_OPTIONS`を調整できます:

```bash
# gateway.envに追加（例: 最大メモリを512MBに制限）
echo 'NODE_OPTIONS="--max-old-space-size=512 --dns-result-order=ipv4first --no-network-family-autoselection"' >> ~/.openclaw/gateway.env

# サービスを再起動
systemctl --user restart openclaw-gateway.service
```

### mise設定（Pi用）

Pi用のmise設定（`config.pi.toml`）では、並列ジョブ数を削減しています:

```toml
[settings]
jobs = 2  # Pi用に並列数削減
```

---

## 完了チェックリスト

配布が完了したら、以下の項目をすべて確認してください:

- [ ] すべてのファイルがPiに転送された
- [ ] `gateway.env`のパーミッションが600に設定された
- [ ] systemd serviceが有効化された
- [ ] サービスが正常に起動している（`systemctl --user status`）
- [ ] ポート18789でListenしている（`ss -tlnp | grep 18789`）
- [ ] ログにエラーが出ていない（`journalctl --user -u openclaw-gateway`）
- [ ] WSL2側からPiに接続できる（`curl http://pi.local:18789/health`）
- [ ] systemd lingeringが有効化されている（`loginctl show-user pi`）

---

## 参考情報

### 関連ファイル

- **サービス定義**: `~/.config/systemd/user/openclaw-gateway.service`
- **オーバーライド設定**: `~/.config/systemd/user/openclaw-gateway.service.d/override.conf`
- **環境変数**: `~/.openclaw/gateway.env`（秘密情報含む、Git管理外）

### OpenClaw Gateway バージョン

- **現在のバージョン**: `v2026.2.2-3`
- **mise管理**: `mise install openclaw@2026.2.2-3`

### systemd ドキュメント

- [systemd.service — Service unit configuration](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
- [systemd.unit — Unit configuration](https://www.freedesktop.org/software/systemd/man/systemd.unit.html)
- [loginctl — Control the systemd login manager](https://www.freedesktop.org/software/systemd/man/loginctl.html)

---

**最終更新**: 2026-02-15
**作成者**: AI Assistant
**対象バージョン**: OpenClaw Gateway v2026.2.2-3
