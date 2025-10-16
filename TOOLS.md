# 設定しているツール一覧

このリポジトリで管理している主なツール・アプリケーションの設定をまとめています。

詳細な設定・使い方は各ツールのドキュメントを参照してください：

- 📚 [統合ドキュメント](./docs/) - 体系化されたドキュメント管理システム
- 🔧 [ツール別ガイド](./docs/tools/) - 詳細な設定と最適化

## シェル・ターミナル

- **Zsh** (`zsh/`) - [📖 詳細ガイド](docs/tools/zsh.md) - 1.1s起動、6段階プラグイン読み込み
- **zsh-abbr** (`zsh-abbr/`) - 省略語展開システム
- **Starship** (`starship.toml`) - クロスシェルプロンプト
- **Alacritty** (`alacritty/`) - GPU加速ターミナル
- **WezTerm** (`wezterm/`) - [📖 詳細ガイド](docs/tools/wezterm.md) - Lua設定、tmuxスタイル
- **Tmux** (`tmux/`) - ターミナルマルチプレクサ
- **SSH** (`ssh/`) - [📖 詳細ガイド](docs/tools/ssh.md) - 階層的設定管理

## 開発ツール

- **Git** (`git/`) - [📖 統合ガイド](docs/tools/fzf-integration.md) - 50+省略語、カスタムウィジェット
- **GitHub CLI** (`gh/`) - リポジトリ自動化
- **Neovim** (`nvim/`) - [📖 詳細ガイド](docs/tools/nvim.md) - <100ms起動、15+言語LSP、AI統合
- **efm-langserver** (`efm-langserver/`) - 汎用言語サーバー
- **mise** (`mise/`, `mise.toml`) - 多言語バージョン管理
- **nirc** (`nirc`) - IRC設定
- **Homebrew** (`Brewfile`) - パッケージ管理
- **AWSume** (`awsume/`) - AWS認証情報管理
- **Terraform** (via Homebrew, LSP support in Neovim) - IaC

## リンター・フォーマッター

- **Biome** (`biome.json`)
- **Hadolint** (`hadolint.yaml`)
- **shellcheck** (`shellcheckrc`)
- **pycodestyle** (`pycodestyle`)
- **Stylua** (`stylua.toml`)
- **Taplo** (`taplo.toml`)
- **Yamllint** (`yamllint/`)
- **Typos** (`typos.toml`)

## アプリケーション

- **Btop** (`btop/`) - モダンシステムモニター
- **htop** (`htop/`) - プロセスビューアー
- **Flipper** (`flipper/`) - デバッグツール
- **Karabiner** (`karabiner/`) - キーボードカスタマイズ
- **Vimium** (`vimium-options.json`) - ブラウザVimキーバインド

## 関連ドキュメント

### 📚 Core Documentation

- [README.md](README.md) - プロジェクト概要・クイックスタート
- [CLAUDE.md](CLAUDE.md) - AI向け技術詳細・設計原則

### 🔧 Tool-Specific Guides

- [Zsh Configuration](docs/tools/zsh.md) - Shell最適化、パフォーマンスチューニング
- [Neovim Configuration](docs/tools/nvim.md) - エディタ設定、LSP、AI統合
- [WezTerm Configuration](docs/tools/wezterm.md) - ターミナル設定、キーバインド
- [SSH Configuration](docs/tools/ssh.md) - SSH階層設定、セキュリティ
- [FZF Integration](docs/tools/fzf-integration.md) - Git/Zsh/ディレクトリ統合

### 🚀 Cross-Cutting Concerns

- [Performance Monitoring](docs/performance.md) - パフォーマンス測定・最適化
- [Maintenance Guide](docs/maintenance.md) - 定期メンテナンス・トラブルシューティング
- [Setup Guide](docs/setup.md) - インストール・初期設定

### 📋 Architecture & Patterns

- [Documentation Index](docs/README.md) - アーキテクチャ・設計パターン
- [Documentation Guidelines](docs/documentation-guidelines.md) - ドキュメント管理体系

---

_全てのツールはモジュラー設計で管理され、明確な責任分離と相互連携を実現しています。_
