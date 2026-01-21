# 🔧 Maintenance Guide

**最終更新**: 2025-12-01
**対象**: 開発者
**タグ**: `category/maintenance`, `category/guide`, `layer/support`, `audience/developer`

定期メンテナンス、トラブルシューティング、パフォーマンス監視のガイドです。

## 定期メンテナンス

### Weekly Tasks

```bash
# パッケージ更新
brew update && brew upgrade

# プラグイン更新
sheldon update                                                    # Zsh
nvim --headless -c 'lua require("lazy").sync()' -c 'q'          # Neovim
~/.tmux/plugins/tmp/bin/update_plugins all                       # Tmux
```

### Monthly Tasks

- パフォーマンス測定 (`zsh-benchmark`)
- 設定レビュー（未使用設定・プラグインの削除検討）
- ログファイルのクリーンアップ

### Quarterly Tasks

- 設定監査（全設定ファイルの整合性確認）
- 依存関係整理（不要な依存関係の削除）
- バックアップ検証

## パフォーマンス監視

- 測定コマンドと改善履歴の単一情報源は [Performance](performance.md)（本書ではスケジュールのみ保持）
- 月次レビューや設定変更後は performance.md の「Monitoring Tools」と「Performance History」に沿って測定・更新する

## トラブルシューティング

### 起動時間の突然の増加

詳細な診断・復旧手順は [Performance](performance.md) の「Troubleshooting」に集約。測定結果と差分を performance.md へ記録し、プラグイン更新や PATH 変更の影響を確認する。

### LSPサーバーエラー

**診断手順:**

1. `:LspInfo` でサーバー状態確認
2. `:Mason` でサーバーインストール状況確認
3. ログ確認: `~/.local/share/nvim/lsp.log`

**解決方法:**

- サーバーの再インストール
- Node.js/Python環境の確認

### Git認証エラー

**診断手順:**

1. SSH鍵確認: `ssh -T git@github.com`
2. 1Password CLI連携状況確認
3. SSH agent状態確認

## デバッグツール

```bash
# 環境変数・コマンドパス確認
env | grep -E "(SHELL|TERM|PATH|CONFIG)"
which command_name
type command_name

# 設定ファイル構文チェック
zsh -n config_file.zsh

# ログ確認
tail -f ~/.local/share/nvim/lsp.log
tail -f ~/.config/zsh/performance.log

# プロセス・メモリ監視
top -pid $(pgrep zsh)
ps aux | grep -E "(zsh|nvim|tmux)"
```

## 緊急時対応

```bash
# 設定破綻時の復旧
zsh --no-rcs                                    # 最小構成での起動

# 依存関係の再構築
brew bundle --force
mise install node@latest && mise install npm:@fsouza/prettierd
mise install python@latest && pip install -r requirements.txt

# バックアップからの復元
cp ~/.config/zsh/backup/zshrc ~/.zshrc
```

## メンテナンス自動化

```bash
#!/bin/zsh
# ~/.config/scripts/maintenance.sh

# パフォーマンス測定ログ
echo "$(date): $(time zsh -lic exit 2>&1)" >> ~/.config/zsh/performance.log

# プラグイン更新
sheldon update
nvim --headless -c 'lua require("lazy").sync()' -c 'q'

# 不要ファイル削除
find ~/.config -name "*.tmp" -delete
find ~/.cache -name "*.old" -delete

# 設定バックアップ
mkdir -p ~/.config/zsh/backup
cp ~/.zshrc ~/.config/zsh/backup/zshrc.$(date +%Y%m%d)
```

## Brewfile管理

### 構造

- **セクション別整理**: 20のカテゴリに分類（Taps, Core Libraries, Development Tools, etc.）
- **全パッケージ管理**: 依存関係を含む全パッケージを明示（`brew bundle dump`ベース）
- **コメント付き**: 各セクション・特殊設定に説明コメントを追加

### 特殊設定

| パッケージ      | 設定                        | 理由                                           |
| --------------- | --------------------------- | ---------------------------------------------- |
| `node`          | `link: false`               | mise (.mise.toml) で実バージョン管理、競合回避 |
| `mysql`         | `restart_service: :changed` | サービス自動再起動                             |
| `utf8proc`      | `args: ["HEAD"]`            | Julia依存のためHEADが必要                      |
| `postgresql@14` | バージョン固定              | 意図的にバージョン14を固定                     |

### mise統合

Brewfileは`mise`タスクで管理できます：

```bash
# 現在のインストール状況を保存
mise run brewfile:backup

# Brewfileからパッケージをインストール
mise run brewfile:restore

# 全依存関係を更新
mise run update
```

**新規Macセットアップ手順**:

1. Homebrewインストール:

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. dotfilesクローン後、Brewfileから一括インストール:

   ```bash
   brew bundle install
   ```

3. 以降は`mise run`コマンドが使用可能

**実行内容**（`mise run update`）:

1. Git submodules更新
2. Homebrewパッケージ更新（`brew upgrade --formula`）
3. 外部リポジトリ更新

### パッケージ追加手順

1. **インストール**:

   ```bash
   brew install <package>
   ```

2. **Brewfile更新**:

   ```bash
   # 現在の状態をダンプ
   brew bundle dump --force --file=/tmp/brewfile-new.txt

   # 差分確認
   diff Brewfile /tmp/brewfile-new.txt
   ```

3. **適切なセクションに追加**:
   - 機能・用途に応じたセクションを選択
   - アルファベット順に挿入（セクション内）
   - 必要に応じてコメント追加

4. **動作確認**:

   ```bash
   brew bundle install --no-upgrade
   ```

### Brewfile再生成手順

**定期的な全体更新（月次推奨）**:

```bash
# 1. バックアップ作成
cp Brewfile Brewfile.backup.$(date +%Y%m%d)

# 2. 現在の状態を完全ダンプ
brew bundle dump --force --file=/tmp/brewfile-complete.txt

# 3. 差分確認
diff Brewfile /tmp/brewfile-complete.txt

# 4. 新規パッケージをセクションに統合
# （手動でBrewfileの適切なセクションに追加）

# 5. 構文チェック
brew bundle check

# 6. テスト
brew bundle install --no-upgrade --verbose
```

### セクション構成

| No  | セクション名                      | 説明                                 | 主要パッケージ例                  |
| --- | --------------------------------- | ------------------------------------ | --------------------------------- |
| 1   | **Taps**                          | サードパーティリポジトリ             | aws/tap, github/gh, hashicorp/tap |
| 2   | **Core Libraries & Dependencies** | 基盤ライブラリ（X11, Cairo, Glib等） | cairo, glib, libxau, freetype     |
| 3   | **Build Tools & Compilers**       | ビルドツール、コンパイラ             | gcc, llvm, cmake, ninja           |
| 4   | **Development Tools**             | バージョン管理、コード検索           | git, gh, ghq, lazygit             |
| 5   | **Languages & Runtimes**          | プログラミング言語                   | ruby, python, lua, rust, node     |
| 6   | **Shell & Terminal**              | Shell拡張、ターミナル                | zsh, sheldon, tmux, starship      |
| 7   | **CLI Utilities**                 | 検索、テキスト処理、ファイル管理     | ripgrep, bat, fzf, jq             |
| 8   | **System Monitoring**             | システム監視、パフォーマンス         | btop, htop, dark-mode             |
| 9   | **DevOps & Cloud**                | Container、Kubernetes、IaC           | docker, kubernetes-cli, terraform |
| 10  | **Databases**                     | データベース、キャッシュ             | mysql, postgresql@14, redis       |
| 11  | **Security & Networking**         | VPN、認証、暗号化                    | gnupg, openvpn, tailscale         |
| 12  | **Linters & Formatters**          | コード品質、静的解析                 | biome, shellcheck, ruff           |
| 13  | **Package Management**            | パッケージマネージャー               | mise, pipx, uv                    |
| 14  | **Documentation**                 | Markdown、PlantUML、Graphviz         | pandoc, graphviz, marksman        |
| 15  | **Build Tools (Lang)**            | 言語固有ビルドツール                 | gradle, maven, sbt                |
| 16  | **Specialized Tools**             | 特定用途向けツール                   | aspell, mecab, grpcurl            |
| 17  | **Casks**                         | デスクトップアプリケーション         | claude-code, wezterm, raycast     |
| 18  | **Fonts**                         | フォント                             | nerd-font, powerline-symbols      |
| 19  | **MAS**                           | Mac App Store アプリ                 | Xcode, 1Password, Reeder          |
| 20  | **VSCode**                        | エディタ拡張                         | copilot, gitlens, remote-ssh      |
| 21  | **Go Packages**                   | Go開発ツール                         | golangci-lint, wire, lambroll     |

### トラブルシューティング

#### パッケージインストールエラー

```bash
# 依存関係の問題
brew doctor
brew update
brew upgrade

# 特定パッケージの再インストール
brew reinstall <package>

# Casksの問題
brew reinstall --cask <cask>
```

#### Brewfile構文エラー

```bash
# 構文チェック
brew bundle check

# Brewfileの検証
brew bundle install --no-upgrade --dry-run
```

#### 古いツールのクリーンアップ

```bash
# Brewfileに含まれないパッケージをリスト
brew bundle cleanup --force

# 未使用の依存関係削除
brew autoremove

# キャッシュクリア
brew cleanup
```

### ベストプラクティス

1. **定期的な更新**: 月次でBrewfileと実際のインストール状況を同期
2. **バージョン管理**: Brewfile をGit管理し、変更履歴を追跡
3. **コメント追加**: 特殊な設定や重要なパッケージにはコメントを付与
4. **テスト**: 変更後は必ず`brew bundle check`で検証
5. **バックアップ**: 大きな変更前にはバックアップを作成
