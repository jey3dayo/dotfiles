# SSH設定 知見・学習事項

## アーキテクチャ設計

### 階層的Include構造

#### 設定ファイル階層
```
~/.ssh/config
├── ~/.config/ssh/ssh_config         # dotfiles管理基本設定
├── ~/.config/ssh/ssh_config.d/*     # dotfiles管理モジュール設定
├── ~/.ssh/ssh_config.d/*            # ローカル個別設定（Git管理外）
├── ~/.orbstack/ssh/config           # OrbStack自動生成
└── ~/.colima/ssh_config             # Colima設定（無効化）
```

#### Include順序の重要性
- **上位設定優先**: 先に読み込まれた設定が優先される
- **Host設定**: 最初にマッチしたHost設定のみ適用
- **全般設定**: Host * での共通設定は最後に配置

### モジュラー設計パターン
```bash
# メイン設定ファイル（Include指定のみ）
Include ~/.config/ssh/ssh_config
Include ~/.config/ssh/ssh_config.d
Include ~/.ssh/ssh_config.d/*

# モジュール別設定
~/.config/ssh/ssh_config.d/
├── 1Password.sshconfig    # SSH Agent統合
├── host.sshconfig         # ホスト定義
└── private-host.sshconfig # プライベートホスト設定
```

## セキュリティ設定

### 1Password SSH Agent統合

#### 設定パターン
```bash
# 1Password SSH Agent
Host *
  AddKeysToAgent yes
  IdentityAgent ~/.1password/agent.sock
```

#### 利点と制約
- **利点**: パスワードレス認証、生体認証連携、安全な鍵管理
- **制約**: 1Password依存、特定環境での互換性問題
- **代替**: ssh-agent との併用パターン

### SSH鍵管理パターン

#### 鍵タイプ選択
```bash
# Ed25519（推奨）
ssh-keygen -t ed25519 -C "email@example.com"

# RSA（古いサーバー対応）
ssh-keygen -t rsa -b 4096 -C "email@example.com"
```

#### 鍵ファイル命名規則
- **用途別**: `id_rsa_work`, `id_rsa_personal`
- **サービス別**: `id_rsa_github`, `id_rsa_gitlab`
- **プロジェクト別**: `id_rsa_project_name`

### ファイル権限管理
```bash
# SSH ディレクトリ
chmod 700 ~/.ssh

# 設定ファイル
chmod 644 ~/.ssh/config ~/.ssh/*.sshconfig

# 秘密鍵
chmod 600 ~/.ssh/id_*

# 公開鍵
chmod 644 ~/.ssh/id_*.pub
```

## パフォーマンス最適化

### 接続維持設定
```bash
Host *
  ServerAliveInterval 30     # 30秒間隔でKeep-Alive
  ServerAliveCountMax 10     # 最大10回再試行
  TCPKeepAlive yes          # TCP レベルでのKeep-Alive
```

### 接続共有（ControlMaster）
```bash
Host *
  ControlMaster auto
  ControlPath ~/.ssh/sockets/%r@%h:%p
  ControlPersist 600        # 10分間接続維持
```

#### 利点と注意点
- **利点**: 同一ホストへの複数接続高速化
- **注意**: ソケットファイル管理、権限設定
- **メンテナンス**: 古いソケットファイルの定期削除

### 認証最適化
```bash
Host *
  PreferredAuthentications publickey,password
  GSSAPIAuthentication no   # 不要な認証方式無効化
  IdentitiesOnly yes       # 指定した鍵のみ使用
```

## 企業・ネットワーク対応

### ファイアウォール対応

#### GitHub接続（ポート443）
```bash
Host github.com
  Hostname ssh.github.com
  Port 443
  User git
```

#### ProxyJump設定（踏み台サーバー）
```bash
Host bastion
  HostName bastion.example.com
  User admin

Host private-server
  HostName 10.0.0.100
  ProxyJump bastion
```

### 企業環境特有設定
```bash
# プロキシ経由接続
Host corporate-server
  ProxyCommand nc -X 5 -x proxy.company.com:1080 %h %p

# VPN接続後のホスト
Match Host *.internal.company.com exec "ping -c1 -W1 vpn.company.com"
  User corporate-username
  IdentityFile ~/.ssh/corporate_id_rsa
```

## 開発環境統合

### Git統合設定
```bash
# GitHub設定
Host github.com
  User git
  IdentitiesOnly yes
  AddKeysToAgent yes

# GitLab設定
Host gitlab.com
  User git
  IdentitiesOnly yes
```

### Docker・仮想環境統合

#### OrbStack統合
- **自動設定**: ~/.orbstack/ssh/config の自動生成
- **コンテナアクセス**: Docker コンテナへの直接SSH接続
- **設定例**: `ssh container-name.orb.local`

#### WSL統合
```bash
# WSL ディストリビューション
Host wsl-ubuntu
  HostName localhost
  User username
  Port 22
  # WSL2 IP動的取得が必要な場合のスクリプト連携
```

## 設定管理パターン

### 環境別設定分岐
```bash
# 条件分岐設定
Match Host *.work.com
  User work-username
  IdentityFile ~/.ssh/work_id_rsa

Match Host *.personal.dev
  User personal-username
  IdentityFile ~/.ssh/personal_id_rsa

# OS別設定
Match OS darwin
  # macOS固有設定
  UseKeychain yes

Match OS linux
  # Linux固有設定
```

### 動的設定パターン
```bash
# IP アドレス動的取得
Host dynamic-server
  HostName !$(dig +short dynamic.example.com)
  User admin

# 時間帯別設定
Match Host evening-server exec "test $(date +%H) -gt 18"
  Port 2222
```

## デバッグ・トラブルシューティング

### 診断コマンドパターン
```bash
# 詳細ログ出力
ssh -vvv hostname

# 設定テスト
ssh -F ~/.ssh/config -T git@github.com

# バッチモード接続テスト
ssh -o "BatchMode yes" -o "ConnectTimeout=5" hostname echo "OK"

# 特定設定での接続
ssh -F /path/to/specific/config hostname
```

### よくある問題と解決パターン

#### 認証失敗
```bash
# 1Password Agent確認
echo $SSH_AUTH_SOCK
ls -la ~/.1password/agent.sock

# ssh-agent 確認
ssh-add -l

# 鍵権限確認
ls -la ~/.ssh/id_*
```

#### ホスト鍵関連
```bash
# ホスト鍵削除
ssh-keygen -R hostname

# ホスト鍵取得
ssh-keyscan hostname >> ~/.ssh/known_hosts

# 厳密なホスト鍵チェック無効化（テスト用）
ssh -o "StrictHostKeyChecking=no" hostname
```

#### 接続タイムアウト
```bash
# MTU調整
ssh -o "IPQoS=lowdelay" hostname

# Keep-Alive強制
ssh -o "ServerAliveInterval=10" hostname

# 圧縮有効化（低速回線）
ssh -o "Compression=yes" hostname
```

## セキュリティベストプラクティス

### 鍵ローテーション
```bash
# 古い鍵の無効化手順
# 1. 新鍵生成
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_new

# 2. 公開鍵配布
ssh-copy-id -i ~/.ssh/id_ed25519_new.pub user@hostname

# 3. 設定更新
# 4. 古い鍵削除
```

### アクセス制御
```bash
# 特定IPからのみ接続許可（サーバー側 authorized_keys）
from="192.168.1.0/24" ssh-ed25519 AAAA...

# コマンド制限
command="/usr/local/bin/backup.sh" ssh-ed25519 AAAA...

# 時間制限
expiry-time="20251231" ssh-ed25519 AAAA...
```

## 運用・メンテナンス

### 定期メンテナンスタスク
```bash
# 古い接続ソケット削除
find ~/.ssh/sockets -name "*.sock" -mtime +1 -delete

# 接続テスト自動化
for host in $(grep "^Host " ~/.ssh/config | awk '{print $2}'); do
    ssh -o "BatchMode yes" -o "ConnectTimeout=5" "$host" echo "OK" 2>/dev/null && echo "$host: OK" || echo "$host: FAIL"
done

# 設定ファイル検証
ssh -F ~/.ssh/config -T git@github.com
```

### バックアップ・復旧戦略
```bash
# SSH設定フルバックアップ
tar -czf "ssh_backup_$(date +%Y%m%d).tar.gz" ~/.ssh ~/.config/ssh

# dotfiles連携バックアップ
# dotfiles リポジトリにコミット
# 機密情報は除外（.gitignore設定）

# 復旧手順
# 1. dotfiles clone
# 2. シンボリックリンク作成
# 3. 個人鍵の復元（1Password等から）
# 4. 権限設定
```

## パフォーマンス指標

### ベンチマーク手法
```bash
# 接続時間測定
time ssh hostname exit

# Keep-Alive効果測定
ssh -o "ServerAliveInterval=30" hostname "sleep 60; echo alive"

# 接続共有効果測定
# 1回目接続時間と2回目接続時間の比較
```

### 監視・ログ
```bash
# SSH接続ログ確認（macOS）
log show --predicate 'subsystem == "com.openssh.sshd"' --last 1h

# 失敗接続の確認
grep "Failed" /var/log/auth.log  # Linux
grep "Invalid" /var/log/secure   # RHEL系
```

## 将来の改善計画

### 自動化拡張
- **動的設定生成**: DNS解決・IP取得の自動化
- **鍵管理自動化**: 定期的なローテーション
- **接続監視**: ヘルスチェック・アラート

### セキュリティ強化
- **証明書認証**: SSH CA証明書の導入検討
- **MFA統合**: 多要素認証の追加検討
- **ログ分析**: 不審な接続パターンの検出

## 学習した回避すべきパターン

### アンチパターン
1. **単一設定ファイル**: 巨大な ~/.ssh/config
2. **権限設定不備**: 過度に緩い権限設定
3. **平文パスワード**: パスワード認証の多用
4. **設定重複**: Host設定の重複・矛盾

### 改善済み問題
- **設定散在**: 階層化による整理
- **鍵管理**: 1Password統合による一元管理
- **接続安定性**: Keep-Alive設定
- **企業対応**: ポート443経由設定

---

*Last Updated: 2025-06-14*
*Status: セキュア・高性能SSH環境構築完了*