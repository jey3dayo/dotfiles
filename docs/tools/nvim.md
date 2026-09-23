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
timestamp: 2026-09-23
audience: advanced
owner: dotfiles
---

# 💻 Neovim Configuration Guide

warm 起動 ~65ms（2026-09-19 実測、目標 <200ms）と15言語対応のLSPを備えたモダンなLua設定です。

## 🤖 Claude Rules

このドキュメントの凝縮版ルールは [`.claude/rules/tools/nvim.md`](../../.claude/rules/tools/nvim.md) で管理されています。

- 目的: Claude AIが常に参照する簡潔なルール
- 適用範囲: YAML frontmatter `paths:` で定義
- 関係: 本ドキュメントが詳細リファレンス（SST）、Claudeルールが強制版

## 主要機能

- 高性能: lazy.nvim 最適化による warm 起動 ~65ms（cold 初回 ~153ms、実測 2026-09-19）
- LSP対応: 15以上の言語・設定形式をフルサポート
- モダンUI: mini.pick、mini.files、flash.nvim による高速ナビゲーション
- 補完: `blink.cmp` + `friendly-snippets`
- フォーマット: 保存時自動フォーマットなし。`:Format`（`<C-e>f`）で手動実行、コミット時の整形は lefthook の pre-commit（staged files）が担う

## パフォーマンス指標

| 項目               | 起動時間     | 最適化手法       |
| ------------------ | ------------ | ---------------- |
| 全体起動           | ~65ms (warm) | lazy.nvim        |
| プラグイン読み込み | 遅延実行     | 条件付き読み込み |
| LSP初期化          | オンデマンド | 言語別設定       |

## 検証

目標 <200ms は達成済み。測定条件（2026-09-19、Mac16,6、NVIM v0.12.5、`nvim --startuptime` + `-c qa`、設定は本リポジトリ root で `XDG_CONFIG_HOME=<repo>/`）:

| 区分 | 中央値 | 最小 | 最大  | 試行数                     |
| ---- | ------ | ---- | ----- | -------------------------- |
| warm | 64.7ms | 61.6 | 69.9  | 12（1 回ウォームアップ後） |
| cold | —      | —    | 153.4 | 1（キャッシュ冷えた初回）  |

## 設定構造

```text
nvim/
├── init.lua              # エントリポイント
├── lua/
│   ├── init_lazy.lua     # lazy.nvim ブートストラップ
│   ├── config/           # プラグイン別の詳細設定
│   ├── plugins/          # lazy.nvim プラグイン定義（カテゴリ別）
│   ├── core/             # 起動・依存・ファイルタイプ基盤
│   └── lsp/              # LSP、フォーマット、診断ヘルパー
├── after/ftplugin/       # ファイルタイプ設定
└── after/lsp/            # サーバー別 LSP 上書き（12ファイル、`ls nvim/after/lsp`）
```

読み込み順序: `lua/core/bootstrap.lua` がコア（options/keymaps/lazy起動）を即座に読み込み、UI・LSPオートフォーマット・カラースキームなどの重い初期化は `vim.defer_fn` で遅延読み込みする。`after/lsp/<server>.lua` は runtimepath の読み込み順序により nvim-lspconfig 自身の `lsp/*.lua` より後に評価され、サーバー別設定を上書きする。

## サポート言語

プログラミング言語: Lua, Go, Python, JavaScript/TypeScript（JSX/TSX/Vue含む）, Bash/Shell（zsh含む）

インフラ・設定: Docker, Terraform, Prisma, TOML, JSON, YAML（docker-compose/gitlab/helm-values含む）

マークアップ: CSS, Markdown, Astro

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
<C-e>b/p/e/s    -- Biome/Prettier/ESLint/TypeScript(ts_ls) で個別フォーマット
```

### 開発ツール

```lua
<Tab>           -- 補完受諾（blink.cmp）
,sp             -- Lazy UI
,sm             -- MasonUpdate
,st             -- Treesitter 更新
,su             -- Lazy update（プラグイン更新）
```

### タブ・ウィンドウ

```lua
<C-t>c/d/o/n/p  -- タブ作成/close/split/next/prev
gt / gT         -- タブ切り替え（次/前）
<Tab>           -- ウィンドウ間循環移動（Normalモード。Insertモードでは補完受諾）
```

## プラグインエコシステム

### コア

- lazy.nvim: 遅延読み込みプラグインマネージャー
- nvim-lspconfig: サーバーごとのデフォルト設定を提供（サーバー一覧は `nvim/lua/lsp/config.lua` の `M.servers` が正本）
- mason.nvim + mason-lspconfig: `nvim/lua/config/mason-lspconfig.lua` が `M.servers` を `automatic_enable = false` でインストールし、有効化は行わない
- 有効化: `nvim/lua/lsp/setup.lua` が `vim.lsp.config` / `vim.lsp.enable` で唯一の活性化ポイントを担う。サーバー別の上書きは `after/lsp/<server>.lua`

### UI・ナビゲーション

- mini.pick + mini.extra: ファジーファインダー
- mini.files: デフォルトのファイルエクスプローラー
- flash.nvim + mini.jump + mini.jump2d: 高速モーション

### 補完

- blink.cmp + friendly-snippets

### 構文

- nvim-treesitter, ts-context-commentstring, vim-matchup, rainbow-delimiters

### 開発

- gitsigns.nvim: Git統合（サインカラム・hunk操作）
- vim-fugitive（+ vim-rhubarb, gitlinker）: Git コマンド統合
- diffview.nvim, neogit: diff表示・Git UI

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

# フォーマット/Lint バンドル（リポジトリ共通、mise タスク）
mise run format
mise run lint
mise run ci   # フルCI相当
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
