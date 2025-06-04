# Neovim Configuration

A comprehensive Neovim configuration using Lua and the lazy.nvim plugin manager.

## ディレクトリ構成 (Directory Structure)

```
.vim/
├── init.lua                    # メインエントリーポイント (Main entry point)
├── coc-settings.json          # COC設定ファイル (COC configuration)
├── lazy-lock.json            # プラグインロックファイル (Plugin lock file)
├── ftdetect/                 # ファイルタイプ検出 (File type detection)
├── ftplugin/                 # ファイルタイプ別設定 (File type specific settings)
└── lua/                      # Lua設定ファイル (Lua configuration files)
    ├── autocmds.lua          # 自動コマンド (Auto commands)
    ├── base.lua              # 基本設定 (Base settings)
    ├── colorscheme.lua       # カラースキーム (Color scheme)
    ├── global_utils.lua      # グローバルユーティリティ (Global utilities)
    ├── init_lazy.lua         # lazy.nvim初期化 (Lazy.nvim initialization)
    ├── keymaps.lua           # キーマッピング (Key mappings)
    ├── load_config.lua       # 設定読み込み (Configuration loader)
    ├── lua_rocks.lua         # Lua Rocks設定 (Lua Rocks configuration)
    ├── neovide.lua           # Neovide設定 (Neovide configuration)
    ├── options.lua           # Neovimオプション (Neovim options)
    ├── utils.lua             # ユーティリティ関数 (Utility functions)
    ├── config/               # プラグイン設定 (Plugin configurations)
    ├── lsp/                  # LSP設定 (LSP configuration)
    │   ├── autoformat.lua    # 自動フォーマット (Auto formatting)
    │   ├── capabilities.lua  # LSP機能 (LSP capabilities)
    │   ├── client_manager.lua # クライアント管理 (Client management)
    │   ├── config.lua        # LSP設定 (LSP configuration)
    │   ├── efm.lua           # EFM設定 (EFM configuration)
    │   ├── formatter.lua     # フォーマッター (Formatters)
    │   ├── highlight.lua     # ハイライト (Highlighting)
    │   ├── keymaps.lua       # LSPキーマップ (LSP keymaps)
    │   └── settings/         # 言語サーバー設定 (Language server settings)
    └── plugins/              # プラグイン定義 (Plugin definitions)
```

## 概要 (Overview)

このNeovim設定は以下の機能を提供します：

### 主な機能 (Key Features)

- **プラグイン管理**: lazy.nvim による高速なプラグイン管理
- **LSP統合**: 多言語対応のLanguage Server Protocol支援
- **AI支援**: GitHub CopilotとAvante.nvimによるAI支援コーディング
- **補完システム**: nvim-cmpによる高度な補完機能
- **ファジーファインダー**: Telescopeによる強力な検索機能
- **Git統合**: Gitサインとfugitiveによるバージョン管理統合
- **シンタックスハイライト**: Tree-sitterによる高精度なシンタックスハイライト

### 対応言語 (Supported Languages)

- JavaScript/TypeScript
- Python
- Go
- Lua
- Ruby
- CSS/SCSS/Less
- JSON/YAML
- Bash
- Markdown
- その他多数

### テーマとUI (Theme and UI)

- **カラースキーム**: Tokyo Night テーマ
- **ステータスライン**: Lualine with powerline/evil styles
- **UI強化**: Noice, hlchunk, rainbow-delimitersなど

### 動作要件 (Requirements)

- Neovim 0.9.0+
- Git
- Node.js (LSPサーバー用)
- Python (LSPサーバー用)
- ripgrep (Telescope用)

### インストール方法 (Installation)

1. このディレクトリを `~/.config/nvim` にコピー
2. Neovimを起動
3. lazy.nvimが自動的にプラグインをインストール

### カスタマイズ (Customization)

- `lua/options.lua`: Neovimの基本設定
- `lua/keymaps.lua`: キーマッピング設定
- `lua/plugins/`: プラグイン設定の追加・変更
- `lua/lsp/settings/`: 言語サーバー固有の設定

