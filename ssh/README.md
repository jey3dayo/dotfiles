# SSH設定 管理・使用方法

## 📊 設定概要

階層的なSSH設定管理システムで、複数の設定ファイルを用途別に分離し、保守性とセキュリティを向上させています。

## ⚠️ セキュリティ注意事項

**機密情報管理**
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
~/.ssh/
├── config                    # メイン設定（Include指定のみ）
├── ssh_config.d/            # ローカル設定ディレクトリ（個別管理）
└── ~/.config/ssh/          # 管理対象設定（dotfiles）
    ├── ssh_config          # 基本設定
    └── ssh_config.d/       # モジュール別設定
        ├── 1Password.sshconfig    # 1Password SSH Agent
        ├── host.sshconfig         # 公開可能ホスト定義
        └── private-host.sshconfig # プライベートホスト設定
```

### Include階層構造
```bash
~/.ssh/config
├── ~/.config/ssh/ssh_config      # dotfiles管理の基本設定
├── ~/.config/ssh/ssh_config.d    # dotfiles管理のモジュール設定
├── ~/.ssh/ssh_config.d/*         # ローカル個別設定（Git管理外・機密情報）
├── ~/.orbstack/ssh/config        # OrbStack自動生成設定
└── ~/.colima/ssh_config          # Colima設定（コメントアウト）
```

## 📋 設定内容詳細

### メイン設定（~/.ssh/config）
```bash
# dotfiles管理設定の読み込み
Include ~/.config/ssh/ssh_config
Include ~/.config/ssh/ssh_config.d

# ローカル設定の読み込み
Include ~/.ssh/ssh_config.d/*

# 仮想環境設定
Include ~/.orbstack/ssh/config
#Include ~/.colima/ssh_config

# 全ホスト共通設定
Host *
  IdentityFile ~/.ssh/id_rsa
  UseKeychain yes                # macOS Keychain統合
  ServerAliveInterval 30         # 30秒ごとにKeep-Alive
  ServerAliveCountMax 10         # 最大10回再試行
  TCPKeepAlive yes              # TCP Keep-Alive有効
  IPQoS lowdelay none           # 低遅延QoS設定
  HostKeyAlgorithms +ssh-rsa    # 古いサーバー対応
  PubkeyAcceptedKeyTypes +ssh-rsa
  IdentityAgent none            # 1Password使用時は無効化

# GitHub設定（ポート443経由）
Host github.com
  Hostname ssh.github.com       # 企業ファイアウォール対応
  User git
  Port 443                      # HTTPS port経由
  IdentitiesOnly yes           # 指定鍵のみ使用

# GitLab設定
Host gitlab.com
  User T00114
  Hostname gitlab.com
```

### 1Password SSH Agent設定
```bash
# ~/.config/ssh/ssh_config.d/1Password.sshconfig
Host *
  AddKeysToAgent yes
  IdentityAgent ~/.1password/agent.sock
```

### ホスト別設定例
```bash
# ~/.config/ssh/ssh_config.d/host.sshconfig
Host pi-local
  HostName raspberrypi.local
  User pi
  Port 10022
  IdentityFile ~/.ssh/id_rsa
  IdentitiesOnly yes

Host synology
  HostName synology.local
  User admin
  Port 10022
  IdentityFile ~/.ssh/id_rsa
  IdentitiesOnly yes
```

## 🎮 基本使用方法

### SSH接続
```bash
# 基本接続
ssh hostname

# 設定済みホストへの接続
ssh pi-local
ssh synology
ssh github.com

# ポート転送
ssh -L 8080:localhost:80 hostname

# バックグラウンド接続
ssh -N -f -L 8080:localhost:80 hostname
```

### 接続確認・診断
```bash
# 設定内容確認
ssh -F ~/.ssh/config -T git@github.com

# 詳細ログ出力
ssh -v hostname

# 設定テスト
ssh -o "BatchMode yes" hostname echo "success"
```

## 🔒 セキュリティ設定

### 1Password SSH Agent統合

#### 有効化手順
1. **1Password設定**: SSH Agent機能を有効化
2. **鍵登録**: 1Password内でSSH鍵を管理
3. **設定ファイル**: 1Password.sshconfig のコメントアウト解除

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

# 設定ファイル権限
chmod 644 ~/.ssh/config
chmod 644 ~/.ssh/*.sshconfig

# 秘密鍵権限
chmod 600 ~/.ssh/id_*

# 公開鍵権限
chmod 644 ~/.ssh/id_*.pub
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

*Last Updated: 2025-06-14*  
*Status: セキュア・高性能接続環境構築完了*
