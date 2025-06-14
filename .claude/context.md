# プロジェクトコンテキスト

## プロジェクト概要

- **プロジェクト名**: Dotfiles管理システム
- **目的**: 個人開発環境の設定ファイルを統合管理し、モダンな開発体験を提供
- **対象ユーザー**: 開発者自身（個人環境）

## 主要コンポーネント

### 🐚 Zsh Shell Configuration
- **パフォーマンス**: 最適化されたスタートアップ時間
- **機能**: Git統合、FZF検索、略語展開、包括的ヘルプシステム
- **モジュラーローダー**: 段階的な設定読み込み

### 🚀 Neovim Editor
- **基盤**: Lua ベースのモダン設定
- **機能**: LSP統合、AI支援（Copilot/Avante）、モダンUI
- **プラグイン管理**: lazy.nvim による最適化

### 🔧 Terminal Tools
- **Alacritty**: GPU加速ターミナル
- **Tmux**: セッション管理
- **Wezterm**: Lua設定可能ターミナル

### 🛠️ Development Tools
- **Git**: カスタムエイリアスと統合
- **Mise**: 多言語バージョン管理
- **Brewfile**: 宣言的パッケージ管理

## 技術スタック

- **Shell**: Zsh + Sheldon プラグイン管理
- **Editor**: Neovim + Lua設定
- **Terminal**: Alacritty / Wezterm
- **Multiplexer**: Tmux
- **Package Manager**: Homebrew
- **Version Manager**: Mise
- **Keyboard**: Karabiner Elements
- **Launcher**: Raycast

## 設定ファイル構造

```
dotfiles/
├── zsh/           # Zsh設定
├── nvim/          # Neovim設定
├── tmux/          # Tmux設定
├── git/           # Git設定
├── alacritty/     # Alacritty設定
├── wezterm/       # Wezterm設定
├── karabiner/     # キーボード設定
├── raycast/       # Raycast設定
└── mise.toml      # バージョン管理
```

## パフォーマンス目標

- **Zsh起動時間**: 1.5秒以下
- **Neovim起動**: 100ms以下
- **モジュラー設計**: 機能別の独立性
- **保守性**: 明確な設定構造