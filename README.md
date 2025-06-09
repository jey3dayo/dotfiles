# Personal Dotfiles

macOSの開発環境を構築するためのdotfilesコレクション。パフォーマンス最適化とモジュラー設計に重点を置いた実用的な設定です。

📋 **対応ツール一覧**: [TOOLS.md](TOOLS.md)
🧠 **設定詳細・技術情報**: [CLAUDE.md](CLAUDE.md)

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

| ディレクトリ | 説明 | ステータス |
|-------------|------|------------|
| `zsh/` | Zsh設定（1.2s起動、モジュラー設計）[→詳細](zsh/CLAUDE.md) | ✅ 最適化完了 |
| `nvim/` | Neovim設定（Lua、LSP統合、AI支援）[→詳細](nvim/CLAUDE.md) | ✅ 機能完成 |
| `git/` | Git設定（エイリアス、ウィジェット統合） | ✅ 運用中 |
| `ssh/` | SSH設定（1Password統合） | ✅ 設定済み |

### ツール設定

| ファイル/ディレクトリ | 説明 | 統合レベル |
|---------------------|------|------------|
| `Brewfile` | Homebrew パッケージ定義 | 🔄 自動管理 |
| `mise.toml` | ランタイム管理（Node.js, Python等） | 🚀 遅延最適化 |
| `starship.toml` | プロンプト設定 | 🎨 テーマ統合 |
| `alacritty/` | メインターミナル設定 | ⚡ GPU加速 |
| `wezterm/` | 代替ターミナル設定（Lua） | 🔧 高カスタマイズ |
| `tmux/` | セッション管理・マルチプレクサ | 🔌 プラグイン生態系 |
| `karabiner/` | キーボード最適化 | ⌨️ 生産性向上 |
| `lazygit/` | Git TUI | 📊 ビジュアル操作 |

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

### 🚀 パフォーマンス重視
- **Zsh + Sheldon**: 1.2s起動（30%改善達成）
- **Neovim + lazy.nvim**: <100ms起動、15+言語LSP対応
- **mise**: 遅延ロード最適化（-39.88ms削減）

### 🎯 開発体験
- **AI統合**: GitHub Copilot + Avante.nvim
- **Git統合**: カスタムウィジェット、abbreviations、fzf連携
- **検索**: fzf（リポジトリ・ファイル・プロセス・履歴）
- **ターミナル**: Alacritty（GPU加速）+ tmux（セッション管理）

### 🔧 生産性ツール
- **1Password**: SSH鍵管理、CLI統合
- **Raycast**: システム全体のショートカット
- **Karabiner**: キーボード最適化
- **GitHub CLI**: リポジトリ管理の自動化

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

- `git/config` - XDG準拠のGitグローバル設定
- `git/local.gitconfig` - プライベートなGit設定（除外済み）
- `zsh/` - Zsh設定（詳細: [CLAUDE.md](zsh/CLAUDE.md)）

### 🎮 よく使うコマンド

```bash
# ヘルプシステム
zsh-help                    # 全体ヘルプ表示
zsh-help keybinds          # キーバインド一覧
zsh-benchmark              # 起動時間測定

# fzf統合ワークフロー
Ctrl+]                     # ghqリポジトリ選択
Ctrl+G Ctrl+G             # Gitステータス表示
Ctrl+G Ctrl+A             # Gitファイル追加
```

## 🎯 特徴

### 🏗️ アーキテクチャ
- **モジュラー設計**: 独立しつつシームレスに統合された各ツール
- **パフォーマンス最適化**: 遅延読み込み、起動時間最適化
- **ポータビリティ**: macOS重視、クロスプラットフォーム対応

### 🔧 実用性
- **設定の分離**: プライベート設定とパブリック設定の完全分離
- **自動化**: セットアップからメンテナンスまでの自動化
- **品質管理**: 複数言語対応リンター・フォーマッター統合

### 📊 実績
- **Zsh**: 1.7s → 1.2s（30%高速化）
- **プラグイン管理**: 6段階優先度システム
- **クロスツール連携**: Git + fzf + abbreviationsの統合ワークフロー

## 📝 ライセンス

MIT License
