# SSH設定 管理・使用方法

## 📊 設定概要

階層的なSSH設定管理システムで、複数の設定ファイルを用途別に分離し、保守性とセキュリティを向上させています。

## ⚠️ セキュリティ注意事項

### 機密情報管理

- センシティブなホスト情報・認証情報は記載しない
- 個別設定ファイル名は具体的に記載しない
- 実際のIPアドレス・ドメイン名は例示のみ

### ✨ 主な特徴

- **🔒 1Password SSH Agent統合**: パスワードレス認証
- **📁 階層的設定管理**: 用途別ファイル分離
- **⚡ 接続最適化**: Keep-Alive・圧縮設定
- **🔧 プラットフォーム統合**: OrbStack・Docker対応

## 🏗️ 設定構造

### ディレクトリ構成

```
~/.config/ssh/              # dotfiles管理（Git追跡）
├── config                  # メイン設定ファイル
├── config.d/              # 優先度付きモジュール設定
│   ├── 00-global.sshconfig      # グローバル設定（最優先）
│   ├── 01-1password.sshconfig   # 1Password SSH Agent
│   ├── 10-dev-services.sshconfig    # 開発サービス（GitHub等）
│   ├── 20-home-network.sshconfig    # ホームネットワーク
│   ├── 30-macos.sshconfig       # macOS専用設定
│   └── 31-linux.sshconfig       # Linux/WSL2専用設定
├── templates/             # 設定テンプレート
│   ├── host-template.sshconfig
│   └── service-template.sshconfig
└── README.md              # 設定ガイド

~/.ssh/                    # ローカル設定（Git管理外）
├── ssh_config.d/         # 機密・個人設定
└── sockets/              # 接続共有ソケット
```

### Include階層構造（優先度順）

```bash
~/.ssh/config
├── ~/.config/ssh/config.d/00-global.sshconfig      # 全体設定
├── ~/.config/ssh/config.d/01-1password.sshconfig   # 認証設定
├── ~/.config/ssh/config.d/10-dev-services.sshconfig    # 開発環境
├── ~/.config/ssh/config.d/20-home-network.sshconfig    # ホームラボ
├── ~/.config/ssh/config.d/30-macos.sshconfig       # macOS専用設定
├── ~/.config/ssh/config.d/31-linux.sshconfig       # Linux/WSL2専用設定
└── ~/.ssh/ssh_config.d/*         # ローカル個別設定（機密情報）
```

## 📋 設定内容詳細

### メイン設定（~/.config/ssh/config）

```bash
# SSH Configuration - Hierarchical Include Structure
# Managed by dotfiles - DO NOT EDIT MANUALLY

# Managed configs (tracked in dotfiles)
# Load in priority order
Include ~/.config/ssh/config.d/00-global.sshconfig
Include ~/.config/ssh/config.d/01-1password.sshconfig
Include ~/.config/ssh/config.d/10-dev-services.sshconfig
Include ~/.config/ssh/config.d/20-home-network.sshconfig
Include ~/.config/ssh/config.d/30-macos.sshconfig
Include ~/.config/ssh/config.d/31-linux.sshconfig

# Local overrides (untracked, for sensitive data)
Include ~/.ssh/ssh_config.d/*
```

### グローバル設定（00-global.sshconfig）

```bash
Host *
  # 接続最適化
  ServerAliveInterval 30
  ServerAliveCountMax 10
  TCPKeepAlive yes

  # 接続共有でパフォーマンス向上
  ControlMaster auto
  ControlPath ~/.ssh/sockets/%r@%h:%p
  ControlPersist 600

  # 認証最適化
  GSSAPIAuthentication no
  PreferredAuthentications publickey,password
```

### 開発サービス設定（10-dev-services.sshconfig）

```bash
# GitHub（企業ファイアウォール対応）
Host github.com
  Hostname ssh.github.com
  User git
  Port 443
  IdentitiesOnly yes

# GitLab
Host gitlab.com
  User git
  IdentitiesOnly yes
```

### ホームネットワーク設定（20-home-network.sshconfig）

```bash
# Raspberry Pi（統一設定）
Host pi
  HostName raspberrypi.local
  User pi
  Port 10022
  IdentitiesOnly yes

# Synology NAS
Host nas
  HostName synology.local
  User admin
  Port 10022
  IdentitiesOnly yes
```

### 1Password SSH Agent設定（01-1password.sshconfig）

```bash
# UNCOMMENT TO ENABLE 1Password SSH Agent
# Host *
#   AddKeysToAgent yes
#   IdentityAgent ~/.1password/agent.sock

# DISABLE when using 1Password (prevents conflicts)
Host *
  IdentityAgent none
```

## 🖥️ プラットフォーム固有設定

### macOS専用設定（30-macos.sshconfig）

macOS環境でのみ適用される設定です。Linux/WSL2では`Match exec`判定により無視されます。

#### 自動適用される設定

**macOS Keychain統合**:

- `UseKeychain yes` - SSH鍵のパスフレーズをKeychainに保存
- `AddKeysToAgent yes` - ssh-agentに鍵を自動追加

**OrbStack/Colima統合**:

- OrbStack SSH config自動読み込み（macOSのみ）
- Colima SSH config（デフォルト無効、必要に応じてコメント解除）

#### 動作の仕組み

```sshconfig
Match exec "uname | grep -qi darwin"
  UseKeychain yes
  AddKeysToAgent yes
```

- macOS: `uname`が`Darwin`を返す → Match成功 → 設定適用
- Linux/WSL2: `uname`が`Linux`を返す → Match失敗 → 設定無視

#### 確認方法

```bash
# macOS環境
ssh -G github.com | grep -i keychain
# 出力: usekeychain yes

# Linux/WSL2環境
ssh -G github.com | grep -i keychain
# 出力: usekeychain no（または出力なし）
```

### Linux/WSL2専用設定（31-linux.sshconfig）

Linux/WSL2環境でのみ適用される設定です。macOSでは`Match exec`判定により無視されます。

#### 現在の状態

**初期状態**: 空のプレースホルダー（将来の拡張用）

- Linux固有の設定が必要になった場合に使用
- WSL2専用の設定も記述可能

#### 動作の仕組み

```sshconfig
# Linux-specific settings
Match exec "uname | grep -qi linux"
  # Add Linux-specific settings here

# WSL2-specific settings
Match exec "uname -r | grep -qi microsoft"
  # Add WSL2-specific settings here
```

- Linux/WSL2: `uname`が`Linux`を返す → Match成功 → 設定適用
- macOS: `uname`が`Darwin`を返す → Match失敗 → 設定無視

#### 確認方法

```bash
# Linux/WSL2環境
uname
# 出力: Linux

uname -r | grep -i microsoft
# WSL2の場合: マッチング成功（出力あり）
# ネイティブLinuxの場合: マッチング失敗（出力なし）

# macOS環境
uname
# 出力: Darwin
```

## 🎮 モジュール管理

### 設定ファイルの優先度

#### 数字による読み込み順序制御

- `00-` : 最優先（グローバル設定）
- `01-` : 認証設定（1Password等）
- `10-` : 開発サービス
- `20-` : ホームネットワーク
- `30-` : プラットフォーム固有設定（macOS）
- `31-` : プラットフォーム固有設定（Linux/WSL2）

### 新しいホスト追加手順

1. **テンプレート使用**: `templates/host-template.sshconfig`をコピー
2. **適切なファイル選択**: 用途に応じて10-,20-,30-等に追加
3. **設定カスタマイズ**: HostName, User, Portを設定
4. **テスト**: `ssh -T hostname`で接続確認

## 🎮 基本使用方法

### SSH接続

```bash
# 基本接続
ssh hostname

# リファクタリング後のホスト接続
ssh pi                    # Raspberry Pi (ローカル)
ssh pi-remote            # Raspberry Pi (Tailscale経由)
ssh nas                  # Synology NAS
ssh github.com           # GitHub（ポート443経由）
ssh gitlab.com           # GitLab

# ポート転送
ssh -L 8080:localhost:80 hostname

# バックグラウンド接続
ssh -N -f -L 8080:localhost:80 hostname
```

### 接続確認・診断

```bash
# 設定内容確認（新構造）
ssh -F ~/.config/ssh/config -T git@github.com

# 詳細ログ出力
ssh -v hostname

# 設定テスト
ssh -o "BatchMode yes" hostname echo "success"

# モジュール別設定確認
cat ~/.config/ssh/config.d/10-dev-services.sshconfig
```

## 🔒 セキュリティ設定

### 1Password SSH Agent統合

#### 有効化手順

1. **1Password設定**: SSH Agent機能を有効化
2. **鍵登録**: 1Password内でSSH鍵を管理
3. **設定ファイル**: `01-1password.sshconfig`のコメントアウト解除
4. **確認**: `ssh-add -l`で鍵一覧表示

#### 利点

- **パスワードレス**: 鍵のパスフレーズ入力不要
- **セキュア**: 鍵の安全な保管・管理
- **統合**: 生体認証との連携

### SSH鍵管理

```bash
# 新しい鍵生成（Ed25519推奨）
ssh-keygen -t ed25519 -C "your.email@example.com"

# RSA鍵生成（古いサーバー対応）
ssh-keygen -t rsa -b 4096 -C "your.email@example.com"

# 公開鍵の表示
cat ~/.ssh/id_ed25519.pub

# 鍵の追加（1Password不使用時）
ssh-add ~/.ssh/id_ed25519
```

### ファイル権限設定

```bash
# SSH ディレクトリ権限
chmod 700 ~/.ssh
chmod 700 ~/.config/ssh

# 設定ファイル権限（新構造）
chmod 644 ~/.config/ssh/config
chmod 644 ~/.config/ssh/config.d/*.sshconfig
chmod 644 ~/.config/ssh/templates/*.sshconfig

# 秘密鍵権限
chmod 600 ~/.ssh/id_*

# 公開鍵権限
chmod 644 ~/.ssh/id_*.pub

# ソケットディレクトリ
mkdir -p ~/.ssh/sockets
chmod 700 ~/.ssh/sockets
```

## 🔧 高度な設定・カスタマイズ

### 接続最適化

```bash
# ~/.ssh/config での最適化設定
Host *
  # 接続維持
  ServerAliveInterval 30
  ServerAliveCountMax 10
  TCPKeepAlive yes

  # 圧縮有効化（低速回線用）
  Compression yes

  # 接続共有（同一ホストへの複数接続高速化）
  ControlMaster auto
  ControlPath ~/.ssh/sockets/%r@%h:%p
  ControlPersist 600

  # 認証高速化
  GSSAPIAuthentication no
  PreferredAuthentications publickey,password
```

### ProxyJump設定（踏み台サーバー）

```bash
Host bastion
  HostName bastion.example.com
  User admin
  Port 22

Host private-server
  HostName 10.0.0.100
  User app
  ProxyJump bastion
  # または ProxyCommand ssh -W %h:%p bastion
```

### 環境別設定分岐

```bash
# ~/.ssh/config.d/work.sshconfig
Match Host *.company.com
  User work-username
  IdentityFile ~/.ssh/work_id_rsa

Match Host *.personal.dev
  User personal-username
  IdentityFile ~/.ssh/personal_id_rsa
```

## 🚨 トラブルシューティング

### よくある問題と解決

#### 接続タイムアウト

```bash
# Keep-Alive設定確認
ssh -o "ServerAliveInterval=30" hostname

# MTU調整
ssh -o "IPQoS=lowdelay" hostname
```

#### 認証失敗

```bash
# 認証方法確認
ssh -o "PreferredAuthentications=publickey" -v hostname

# 1Password Agent確認
echo $SSH_AUTH_SOCK
ls -la ~/.1password/agent.sock
```

#### ホスト鍵エラー

```bash
# 古いホスト鍵削除
ssh-keygen -R hostname

# ホスト鍵確認
ssh-keyscan hostname >> ~/.ssh/known_hosts
```

### デバッグコマンド

```bash
# 詳細ログ
ssh -vvv hostname

# 設定ファイルテスト
ssh -T -o "BatchMode yes" git@github.com

# 1Password Agent状態確認
ssh-add -l
```

## 🔄 管理・メンテナンス

### 定期メンテナンス

```bash
# 接続テスト
ssh -o "BatchMode yes" -o "ConnectTimeout=5" hostname echo "OK"

# 古い接続削除
find ~/.ssh/sockets -type s -mtime +1 -delete

# 設定構文チェック
ssh -F ~/.ssh/config -T git@github.com
```

### バックアップ・復旧

```bash
# SSH設定バックアップ
tar -czf ssh_backup_$(date +%Y%m%d).tar.gz ~/.ssh ~/.config/ssh

# dotfiles経由での復旧
ln -sf $DOTFILES_DIR/ssh ~/.config/ssh
```

## 📊 パフォーマンス指標

### 現在の状況

- **接続速度**: Keep-Alive設定で高速化
- **セキュリティ**: 1Password統合・Ed25519鍵
- **管理性**: 階層的設定・用途別分離

### 改善実績

- **設定管理**: 用途別ファイル分離で保守性向上
- **セキュリティ**: 1Password統合でパスワードレス認証
- **接続安定性**: Keep-Alive設定で切断対策

## 🔗 関連ツール連携

### Git統合

- **GitHub/GitLab**: 企業ファイアウォール対応（ポート443）
- **SSH Agent**: 1Password統合による認証簡素化

### 開発環境統合

- **OrbStack**: Docker環境への自動SSH設定
- **VSCode**: Remote-SSH拡張との連携
- **Terminal**: WezTerm・Zshでの補完機能

---

_Last Updated: 2025-06-14_  
_Status: セキュア・高性能接続環境構築完了_
