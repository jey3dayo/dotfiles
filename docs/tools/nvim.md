---
type: reference
title: Neovim Configuration Guide
description: dotfiles repo の Neovim 設定（起動性能・LSP・プラグイン構成・キーバインド）の正本
resource: docs/tools/nvim.md
tags:
  - category/editor
  - layer/tool
  - tool/nvim
  - environment/cross-platform
  - audience/advanced
timestamp: 2026-09-08
audience: advanced
owner: dotfiles
---

# 💻 Neovim Configuration Guide

100ms未満の高速起動と15言語対応のLSPを備えたモダンなLua設定です。

## 🤖 Claude Rules

このドキュメントの凝縮版ルールは [`.claude/rules/tools/nvim.md`](../../.claude/rules/tools/nvim.md) で管理されています。

- 目的: Claude AIが常に参照する簡潔なルール
- 適用範囲: YAML frontmatter `paths:` で定義
- 関係: 本ドキュメントが詳細リファレンス（SST）、Claudeルールが強制版

## 主要機能

- 高性能: lazy.nvim最適化による100ms未満起動
- LSP対応: 15以上の言語・設定形式をフルサポート
- AI統合: Supermaven-nvim
- モダンUI: mini.pick、mini.files、flash.nvim による高速ナビゲーション

## パフォーマンス指標

| 項目               | 起動時間     | 最適化手法       |
| ------------------ | ------------ | ---------------- |
| 全体起動           | <100ms       | lazy.nvim        |
| プラグイン読み込み | 遅延実行     | 条件付き読み込み |
| LSP初期化          | オンデマンド | 言語別設定       |

## 設定構造

```text
nvim/
├── init.lua              # エントリポイント
├── lua/
│   ├── config/           # プラグイン別の詳細設定
│   ├── plugins/          # lazy.nvim プラグイン定義
│   ├── core/             # 起動・依存・ファイルタイプ基盤
│   └── lsp/              # LSP、フォーマット、診断ヘルパー
└── after/ftplugin/       # ファイルタイプ設定
```

読み込み順序: `lua/core/bootstrap.lua` がコア（options/keymaps/lazy起動）を即座に読み込み、UI・LSPオートフォーマット・カラースキームなどの重い初期化は `vim.defer_fn` で遅延読み込みする。

## サポート言語

プログラミング言語: Lua, Go, Python, JavaScript/TypeScript（JSX/TSX/Vue含む）, Bash/Shell（zsh含む）, Vim script

インフラ・設定: Docker, Terraform, Prisma, TOML, JSON, YAML（docker-compose/gitlab/helm-values含む）

マークアップ: CSS（Tailwind CSS 含む・HTML属性補完対応）, Markdown, Astro

上記に加え、`typos_lsp` が全ファイルタイプ横断でスペルチェックを行う（`nvim/lua/lsp/config.lua` の `M.servers` が正本）。

## 主要キーバインド

### ファイル・ナビゲーション（Leader: `,`）

```lua
,f              -- ファイル検索
,,              -- ピッカー再開
,gr             -- 文字列検索
,b              -- バッファ一覧
,e              -- mini.files を開く
,E              -- 現在バッファのディレクトリで mini.files を開く
```

### LSP機能

```lua
tt              -- 定義へ移動
tj              -- 参照を検索
K               -- ホバー表示
tk              -- 実装へ移動
tl              -- 型定義へ移動
<C-e>f          -- 自動選択フォーマット
```

### AI・開発ツール

```lua
<Tab>          -- AI補完受諾
<C-]>          -- AI補完クリア
,sp             -- Lazy UI
,sm             -- MasonUpdate
,st             -- Treesitter 更新
```

## プラグインエコシステム

### コア

- lazy.nvim: 遅延読み込みプラグインマネージャー
- nvim-lspconfig: LSP設定
- mason.nvim: LSPサーバー管理

### UI・ナビゲーション

- mini.pick + mini.extra: ファジーファインダー
- mini.files: デフォルトのファイルエクスプローラー
- flash.nvim + mini.jump + mini.jump2d: 高速モーション

### AI・開発

- supermaven-nvim: AI コード補完
- gitsigns.nvim: Git統合

## テーマ・UI

- メインテーマ: `0x96f.nvim`（`filipjanevski/0x96f.nvim`、`lua/colorscheme.lua` で適用）。`kanagawa.nvim` / `tokyonight.nvim` も lazy 登録済みで手動切り替え可能
- 透明背景: `Normal`/`SignColumn` 等を `guibg=NONE` にしてターミナル背景と統合
- ステータスライン: モード、Gitブランチ、LSP状態、診断情報（lualine.nvim）

## 最適化設定

```lua
-- 未使用プロバイダー無効化（lua/options.lua）
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0 -- 同期的な mise コマンド実行を回避

-- lazy.nvim パフォーマンス設定
defaults = { lazy = true }  -- デフォルト遅延ロード
disabled_plugins = {        -- 不要内蔵プラグイン無効化
  "gzip", "matchit", "matchparen", "netrwPlugin",
  "tarPlugin", "tohtml", "tutor", "zipPlugin"
}
```

大ファイル対策: `lua/core/utils.lua` の `is_large_file`（既定 2MB 超）を `lua/core/ftplugin_loader.lua` が参照し、超過時は Treesitter の `vim.treesitter.start` をスキップする。

## カスタマイゼーション

プロジェクト固有の上書きは `load_config.lua` が cwd から上方向に `nvim.config.lua` を探索して読み込む（マシン固有の `lua/config/local.lua` のような仕組みは現状存在しない）：

```lua
-- 例: リポジトリ直下に nvim.config.lua を置くと自動読み込みされる
vim.opt.background = "light"
vim.keymap.set('n', '<leader>ll', ':Lazy<CR>')
```

## メンテナンス

```bash
# プラグイン更新（週次）
:Lazy update

# LSPサーバー更新（月次）
:MasonUpdate

# ヘルスチェック
:checkhealth

# blink.cmp の checkhealth で「Some providers may show up as \"disabled\"」と表示されるのは仕様で、設定で info 扱いに変換しています
# conform は biome の設定ファイルがあるときのみ有効化され、無ければ prettier/eslint_d のみで動きます
```

## 改善機会（未対応）

- Treesitter query の最適化
- カスタムコマンドのより詳細なドキュメント化
- プラグイン間依存関係の明示

## デバッグ・プロファイリング

```bash
# 起動時間測定
nvim --startuptime startup.log

# プラグイン負荷確認
:Lazy profile

# LSP状態確認
:LspInfo
```

## トラブルシューティング

```bash
# プラグイン状態リセット
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim

# 最小構成で起動
nvim --clean
```

---

## 概要

AI支援と包括的言語サポートを備えたモダン開発環境
