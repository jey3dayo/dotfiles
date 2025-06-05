# Personal Dotfiles

macOSの開発環境を構築するためのdotfilesコレクション。

## 🚀 クイックセットアップ

### 1. リポジトリのクローン

```bash
git clone https://github.com/jey3dayo/dotfiles ~/src/github.com/jey3dayo/dotfiles
cd ~/src/github.com/jey3dayo/dotfiles
```

### 2. セットアップスクリプトの実行

```bash
sh ./setup.sh
```

### 3. Homebrewパッケージのインストール

```bash
brew bundle
```

## 📁 構成

### コア設定

| ディレクトリ | 説明 |
|-------------|------|
| `zsh/` | Zsh設定（独自管理、[詳細](zsh/README.md)） |
| `nvim/` | NeoVim設定（独自管理、[詳細](nvim/README.md)） |
| `git/` | Git設定（エイリアス、グローバル設定など） |
| `ssh/` | SSH設定 |

### ツール設定

| ファイル/ディレクトリ | 説明 |
|---------------------|------|
| `Brewfile` | Homebrew パッケージ定義 |
| `mise/config.toml` | mise（ランタイム管理） |
| `starship.toml` | プロンプト設定 |
| `alacritty/` | ターミナル設定 |
| `wezterm/` | ターミナル設定 |
| `karabiner/` | キーボード設定 |
| `lazygit/` | Git TUI設定 |

### リンター・フォーマッター

| ファイル | 説明 |
|---------|------|
| `biome.json` | JavaScript/TypeScript |
| `hadolint.yaml` | Dockerfile |
| `shellcheckrc` | シェルスクリプト |
| `stylua.toml` | Lua |
| `taplo.toml` | TOML |
| `typos.toml` | スペルチェック |
| `yamllint/config` | YAML |

### アプリケーション設定

| ディレクトリ | 説明 |
|-------------|------|
| `1Password/` | 1Password設定 |
| `raycast/` | Raycast拡張機能 |
| `btop/` | システムモニター |
| `gh/` | GitHub CLI |

## 🛠 主要ツール

### パッケージ管理
- **Homebrew**: macOSパッケージマネージャー
- **mise**: Node.js、Python、Rubyなどのランタイム管理

### 開発ツール
- **Neovim**: メインエディター
- **Git**: バージョン管理（カスタムエイリアス付き）
- **GitHub CLI**: GitHubとの連携
- **Zsh**: メインシェル（Sheldon使用）

### ターミナル・UI
- **Starship**: プロンプト
- **Alacritty/WezTerm**: ターミナル
- **Lazygit**: Git TUI
- **fzf**: ファジーファインダー

## 📦 パッケージ管理

### Homebrewパッケージの管理

```bash
# 現在のパッケージをBrewfileに出力
brew bundle dump --force

# Brewfileからパッケージをインストール
brew bundle

# 不要なパッケージの削除
brew bundle cleanup
```

### Node.jsパッケージの管理

```bash
# グローバルパッケージのバックアップ
npm list -g --json > global-package.json

# バックアップからリストア
jq -r '.dependencies | to_entries | .[] | "\(.key)@\(.value.version)"' global-package.json | xargs npm install -g
```

### ランタイム管理（mise）

```bash
# 設定されたランタイムをインストール
mise install

# 新しいランタイムの追加
mise use node@20
mise use python@latest
```

## 🔧 カスタマイズ

### ローカル設定

独立した設定ファイルでプライベート設定を管理：

- `git/local.gitconfig` - プライベートなGit設定
- `zsh/` - Zsh設定（独自管理、CLAUDE.md参照）

## 🎯 特徴

- **Homebrew Bundle**: 全パッケージを`Brewfile`で一元管理
- **mise**: Node.js、Python、Ruby等のバージョン管理
- **設定の分離**: プライベート設定とパブリック設定を分離
- **リンター統合**: 複数言語対応の品質チェック
- **効率的なワークフロー**: fzf、Raycast等による生産性向上

## 📝 ライセンス

MIT License
