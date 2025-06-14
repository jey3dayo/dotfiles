# 全般・横断的知見・学習事項

## プロジェクト全体設計

### アーキテクチャ原則

#### モジュラー設計
- **分離の原則**: 各ツール独立、疎結合
- **統合の原則**: 一貫したテーマ・キーバインド・ワークフロー
- **拡張性**: 新ツール追加の容易さ

#### パフォーマンス重視
- **遅延読み込み**: 必要時のみリソース使用
- **条件分岐**: 環境・コマンド存在での分岐
- **キャッシュ活用**: 重複処理の削減

#### 保守性確保
- **文書化**: コメント・README・知見ドキュメント
- **バージョン管理**: Git による変更履歴管理
- **テスト性**: 段階的変更・ロールバック可能性

## 設定管理パターン

### ディレクトリ構造
```
dotfiles/
├── CLAUDE.md          # プロジェクト全体ドキュメント
├── README.md          # ユーザー向けドキュメント
├── mise.toml          # 言語バージョン管理
├── Brewfile           # パッケージ管理
├── scripts/           # セットアップスクリプト
├── .claude/           # AI支援用ドキュメント
│   ├── commands/      # コマンド定義
│   ├── learnings-*.md # ツール別知見
│   └── *.md          # 統合ドキュメント
├── zsh/              # Shell設定
├── nvim/             # エディター設定
├── wezterm/          # ターミナル設定
├── git/              # バージョン管理設定
└── tmux/             # マルチプレクサ設定
```

### シンボリックリンク管理
```bash
# 基本パターン
ln -sf "$DOTFILES_DIR/tool/config" "$HOME/.config/tool"

# 一括作成スクリプト
create_symlinks() {
    local dotfiles_dir="$1"
    
    # Zsh
    ln -sf "$dotfiles_dir/zsh/.zshrc" "$HOME/.zshrc"
    
    # Neovim
    ln -sf "$dotfiles_dir/nvim" "$HOME/.config/nvim"
    
    # Git
    ln -sf "$dotfiles_dir/git/.gitconfig" "$HOME/.gitconfig"
}
```

### 環境別設定分岐
```bash
# OS判定
case "$(uname -s)" in
    Darwin)
        # macOS固有設定
        source "$DOTFILES_DIR/macos.sh"
        ;;
    Linux)
        # Linux固有設定
        source "$DOTFILES_DIR/linux.sh"
        ;;
esac

# ホスト別設定
hostname=$(hostname)
[[ -f "$DOTFILES_DIR/hosts/$hostname.sh" ]] && \
    source "$DOTFILES_DIR/hosts/$hostname.sh"
```

## テーマ・UI統一

### カラーパレット統一
- **メインテーマ**: Gruvbox Dark / Tokyo Night
- **統一箇所**: Zsh, Neovim, WezTerm, Tmux, Git差分表示
- **一貫性**: 背景・前景・アクセントカラーの統一

### フォント統一
- **メインフォント**: JetBrains Mono / UDEV Gothic
- **Nerd Font**: アイコン・シンボル表示
- **サイズ統一**: 16pt基準での統一

### アイコン・シンボル統一
- **Git状態**: ✓ ✗ ⚡ ⬆ ⬇ 統一シンボル
- **ファイルタイプ**: Nerd Font アイコン統一
- **ツール状態**: 一貫したステータス表示

## 横断的ワークフロー

### Git中心ワークフロー
1. **リポジトリ選択**: FZF + ghq でリポジトリ選択
2. **ブランチ作業**: Zsh Widget での高速Git操作
3. **コード編集**: Neovim でのLSP統合編集
4. **差分確認**: Delta での美しい差分表示
5. **コミット・プッシュ**: 略語展開での高速操作

### 開発環境セットアップ
```bash
# 1. リポジトリクローン
ghq get github.com/user/repo
cd $(ghq root)/github.com/user/repo

# 2. 言語バージョン設定
mise use node@20.10.0
mise use python@3.11

# 3. 依存関係インストール
npm install  # or pip install -r requirements.txt

# 4. エディター起動
nvim .
```

### ターミナルセッション管理
- **WezTerm**: タブ・ペイン管理
- **Tmux**: セッション永続化
- **Zsh**: 効率的なコマンド実行環境

## パッケージ管理

### Homebrew統合
```ruby
# Brewfile パターン
tap "homebrew/bundle"
tap "homebrew/cask"

# CLI tools
brew "git"
brew "neovim"
brew "fzf"
brew "ripgrep"
brew "ghq"

# Applications
cask "wezterm"
cask "raycast"
cask "1password"

# Fonts
cask "font-jetbrains-mono-nerd-font"
```

### mise（言語バージョン管理）
```toml
# mise.toml
[tools]
node = "20.10.0"
python = "3.11"
rust = "1.70"
go = "1.21"

[env]
NODE_ENV = "development"
```

## セットアップ自動化

### 初期セットアップスクリプト
```bash
#!/bin/bash
# setup.sh

set -euo pipefail

# 変数設定
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# バックアップ作成
backup_existing_configs() {
    echo "Creating backup at $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    
    # 既存設定のバックアップ
    [[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$BACKUP_DIR/"
    [[ -d "$HOME/.config/nvim" ]] && cp -r "$HOME/.config/nvim" "$BACKUP_DIR/"
}

# Homebrew インストール
install_homebrew() {
    if ! command -v brew >/dev/null 2>&1; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

# パッケージインストール
install_packages() {
    echo "Installing packages from Brewfile..."
    brew bundle --file="$DOTFILES_DIR/Brewfile"
}

# シンボリックリンク作成
create_symlinks() {
    echo "Creating symlinks..."
    # 実装
}

# メイン実行
main() {
    backup_existing_configs
    install_homebrew
    install_packages
    create_symlinks
    echo "Setup completed! Please restart your terminal."
}

main "$@"
```

## パフォーマンス監視

### ベンチマーク手法
```bash
# Zsh起動時間
zsh_benchmark() {
    for i in {1..10}; do
        time zsh -i -c exit
    done | awk '/real/ {sum += $2} END {print "Average:", sum/NR}'
}

# Neovim起動時間
nvim --startuptime nvim_startup.log
tail nvim_startup.log
```

### リソース使用量監視
```bash
# メモリ使用量
ps aux | grep -E "(zsh|nvim|wezterm)" | awk '{print $1, $4, $11}'

# プロセス監視
htop -p $(pgrep -d',' -f "(zsh|nvim|wezterm)")
```

## トラブルシューティング

### 診断チェックリスト
1. **PATH設定確認**: `echo $PATH`
2. **コマンド存在確認**: `which command_name`
3. **権限確認**: `ls -la ~/.config/`
4. **シンボリックリンク確認**: `ls -la ~/.zshrc`
5. **ログ確認**: 各ツールのログファイル

### よくある問題と解決

#### 起動時間の悪化
```bash
# 問題特定
zsh -x -c 'exit' 2>&1 | head -20

# プロファイリング
zmodload zsh/zprof
# 設定読み込み
zprof
```

#### 設定の読み込み失敗
```bash
# シンタックス確認
zsh -n ~/.zshrc

# 段階的読み込みテスト
zsh --no-rcs
source ~/.zshrc
```

#### パッケージ依存関係問題
```bash
# Homebrew問題診断
brew doctor

# mise環境確認
mise doctor
```

## セキュリティ考慮

### 機密情報管理
- **SSH鍵**: 1Password / ssh-agent管理
- **API Token**: 環境変数・1Password CLI
- **設定分離**: 公開リポジトリからの機密情報除外

### アクセス制御
```bash
# 適切なファイル権限
chmod 600 ~/.ssh/id_*
chmod 644 ~/.gitconfig
chmod 755 ~/.local/bin/*
```

## バックアップ・復旧

### 設定バックアップ
```bash
# 定期バックアップスクリプト
backup_dotfiles() {
    local backup_dir="$HOME/Backups/dotfiles_$(date +%Y%m%d)"
    mkdir -p "$backup_dir"
    
    # Git履歴付きバックアップ
    git --git-dir="$DOTFILES_DIR/.git" --work-tree="$DOTFILES_DIR" \
        archive --format=tar.gz --output="$backup_dir/dotfiles.tar.gz" HEAD
}
```

### 復旧手順
1. **バックアップから復元**: tar.gz展開
2. **シンボリックリンク再作成**: setup.sh実行
3. **パッケージ再インストール**: brew bundle
4. **設定確認**: 各ツールの動作確認

## 将来の改善計画

### 自動化拡張
- **CI/CD**: GitHub Actions での設定テスト
- **同期**: クラウド同期機能の検討
- **監視**: パフォーマンス劣化の自動検出

### 機能拡張
- **AI統合**: より高度なAI支援機能
- **クロスプラットフォーム**: Windows WSL対応強化
- **チーム共有**: 設定テンプレート化

## 知見の蓄積と共有

### ドキュメント管理
- **リアルタイム更新**: 変更時の即座なドキュメント更新
- **検索可能性**: キーワード・タグによる分類
- **実例重視**: 具体的なコード例・設定例

### 学習の継続
- **定期見直し**: 月次での設定・パフォーマンス見直し
- **新技術検証**: 新ツール・手法の評価・導入
- **コミュニティ参加**: 知見共有・フィードバック収集

---

*Last Updated: 2025-06-14*
*Status: 統合システム稼働中・継続改善*