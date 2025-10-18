# 🔐 SSH Configuration

**最終更新**: 2025-10-17
**対象**: 開発者
**タグ**: `category/configuration`, `tool/ssh`, `layer/tool`, `environment/cross-platform`, `audience/developer`

階層的なSSH設定管理システムで、用途別ファイル分離によりセキュリティと保守性を両立しています。

## 主要機能

- **1Password SSH Agent統合**: パスワードレス認証
- **階層的設定管理**: 用途別ファイル分離
- **接続最適化**: Keep-Alive・圧縮設定
- **プラットフォーム統合**: OrbStack・Docker対応

## 設定構造

```text
~/.config/ssh/              # dotfiles管理（Git追跡）
├── config                  # メイン設定ファイル
├── config.d/              # 優先度付きモジュール設定
│   ├── 00-global.sshconfig      # グローバル設定（最優先）
│   ├── 01-1password.sshconfig   # 1Password SSH Agent
│   ├── 10-dev-services.sshconfig    # 開発サービス（GitHub等）
│   ├── 20-home-network.sshconfig    # ホームネットワーク
│   └── 99-defaults.sshconfig    # デフォルト設定（最低優先）
├── templates/             # 設定テンプレート
│   ├── host-template.sshconfig
│   └── service-template.sshconfig
└── README.md              # 設定ガイド

~/.ssh/                    # ローカル設定（Git管理外）
├── ssh_config.d/         # 機密・個人設定
└── sockets/              # 接続共有ソケット
```

### 読み込み優先度

1. **00-global**: 全体設定
2. **01-1password**: 認証設定
3. **10-dev-services**: 開発環境
4. **20-home-network**: ホームラボ
5. **99-defaults**: デフォルト
6. **ローカル設定**: 機密情報（Git管理外）

## 主要設定ファイル

### グローバル設定

```bash
# 接続最適化・共有・認証設定を統合
Host *
  ServerAliveInterval 30
  ControlMaster auto
  ControlPath ~/.ssh/sockets/%r@%h:%p
  GSSAPIAuthentication no
```

### 開発・ホームネットワーク設定

```bash
# 企業ファイアウォール対応
Host github.com
  Hostname ssh.github.com
  Port 443

# ローカルデバイス（例）
Host pi
  HostName raspberrypi.local
  Port 10022
```

### 1Password SSH Agent設定

```bash
# 有効化時（コメントアウト解除）
# Host *
#   IdentityAgent ~/.1password/agent.sock
```

## ホスト追加手順

1. 用途に応じて適切な設定ファイルを選択
2. HostName, User, Portを設定
3. `ssh -T hostname` で接続テスト

## 基本使用方法

### SSH接続

```bash
ssh hostname             # 基本接続
ssh -L 8080:localhost:80 hostname  # ポート転送
```

### 接続確認・診断

```bash
ssh -v hostname          # 詳細ログ
ssh -T git@github.com    # GitHub接続テスト
```

## セキュリティ設定

### 1Password SSH Agent統合

1. 1Password でSSH Agent機能を有効化
2. 設定ファイルのコメントアウト解除
3. `ssh-add -l` で確認

**利点**: パスワードレス認証・安全な鍵管理・生体認証連携

### SSH鍵管理

```bash
# Ed25519鍵生成（推奨）
ssh-keygen -t ed25519 -C "your.email@example.com"

# 公開鍵表示
cat ~/.ssh/id_ed25519.pub
```

### 権限設定

```bash
chmod 700 ~/.ssh ~/.config/ssh
chmod 644 ~/.config/ssh/config*
chmod 600 ~/.ssh/id_*
```

## 高度な設定

### ProxyJump設定（踏み台サーバー）

```bash
Host bastion
  HostName bastion.example.com

Host private-server
  HostName 10.0.0.100
  ProxyJump bastion
```

### 環境別設定分岐

```bash
Match Host *.company.com
  User work-username
  IdentityFile ~/.ssh/work_id_rsa
```

## トラブルシューティング

### よくある問題

```bash
# 詳細ログ出力
ssh -vvv hostname

# 古いホスト鍵削除
ssh-keygen -R hostname

# 1Password Agent確認
ssh-add -l

# 設定ファイルテスト
ssh -T git@github.com
```

## メンテナンス

### 定期作業

```bash
# 古い接続削除
find ~/.ssh/sockets -type s -mtime +1 -delete

# 設定テスト
ssh -T git@github.com
```

## パフォーマンス

- **接続速度**: Keep-Alive設定・接続共有による高速化
- **セキュリティ**: 1Password統合・Ed25519鍵
- **管理性**: 階層的設定・用途別分離

## ツール連携

- **Git**: GitHub/GitLabでの企業ファイアウォール対応
- **開発環境**: OrbStack・VSCode Remote-SSH連携
- **Terminal**: WezTerm・Zsh補完機能

---

## 概要

階層的設定管理によるセキュアで高性能なSSH環境
