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
timestamp: 2026-11-25
audience: advanced
owner: dotfiles
---

# Neovim Configuration Guide

Neovim 組み込みの `vim.pack` と自前ローダーで管理する Lua 設定の正本です。warm 起動 約 50ms（ファイルなし・中央値、2026-11-09 実測、目標 `<200ms`）と 15 言語以上対応の LSP を備えています。

Claude 向けの短いルールは [`.claude/rules/tools/nvim.md`](../../.claude/rules/tools/nvim.md) にあります。

## 主要機能

- 高速起動: 自前ローダーによる遅延ロードで warm 起動 約 50ms（ファイルなし）/ 約 78ms（ファイルあり）、実測 2026-11-09（[検証](#検証)）
- LSP 対応: 15 以上の言語・設定形式をサポート
- モダン UI: `mini.pick`、`mini.files`、`flash.nvim` による高速ナビゲーション
- 補完: `blink.cmp` + `friendly-snippets`
- フォーマット: 保存時の自動フォーマットは行わず、`:Format`（`<C-e>f`）で手動実行します。コミット時の整形は lefthook の `pre-commit`（staged files）が担います。

## パフォーマンス指標

| 項目               | 起動時間                                 | 最適化手法                                              |
| ------------------ | ---------------------------------------- | ------------------------------------------------------- |
| 全体起動           | 約 50ms（ファイルなし）/ 約 78ms（あり） | 自前ローダー（`nvim/lua/pack/`）による遅延ロード        |
| プラグイン読み込み | 遅延実行                                 | `event` / `cmd` / `keys` / `ft` / `VeryLazy` で読み込み |
| LSP 初期化         | オンデマンド                             | 言語別設定                                              |

## 検証

目標 `<200ms` の範囲内です。測定条件は 2026-11-09、Apple M4 Max（arm64）、NVIM v0.12.6、`nvim --headless --startuptime <log> [file] -c qa`、設定は本リポジトリ直下の `nvim/`、ファイルなしとファイルありを交互に各 20 回計測しています。

| 区分                                                                                  | 中央値 | 最小 | 最大 |
| ------------------------------------------------------------------------------------- | ------ | ---- | ---- |
| ファイルなし                                                                          | 50.2ms | 43.4 | 57.1 |
| ファイルあり（測定時: `nvim/lua/options.lua`、現行: `nvim/lua/settings/options.lua`） | 77.9ms | 70.4 | 99.4 |

- `-c qa` は `VimEnter` より前に終了するため、`VeryLazy`、`VimEnter` で読み込むプラグイン、`vim.defer_fn` の遅延モジュールは計測に含まれません。
- 同日の参考値として、`lazy.nvim` 版（タグ `nvim-lazy-last`）を同条件・各 20 回の交互実行で測った中央値はファイルなし 44.9ms、ファイルあり 72.1ms で、`vim.pack` 版との差は約 5ms でした。簡易計測には `nvim/measure_startup.sh` を使えます。
- 同一条件でも負荷により数 ms 変動する（lazy 版単体でも日により中央値が変動した）ため、差は目安として扱います。

## 設定構造

```text
nvim/
├── init.lua              # エントリポイント
├── lua/
│   ├── settings/         # options, keymaps, autocmds, colorscheme, filetype, neovide
│   ├── pack/             # 自前ローダー（spec 正規化 / 遅延ロードのスタブ / vim.pack 呼び出し）
│   ├── config/           # プラグイン別の詳細設定
│   ├── plugins/          # プラグイン定義（lazy.nvim 形式の spec、カテゴリ別）
│   ├── core/             # 起動・依存・ファイルタイプ基盤、plugins, lua_rocks, project_config
│   └── lsp/              # LSP、フォーマット、診断ヘルパー
├── nvim-pack-lock.json   # vim.pack の lockfile（git 管理）
├── after/ftplugin/       # ファイルタイプ設定
└── after/lsp/            # サーバー別 LSP 上書き（12 ファイル、`ls nvim/after/lsp`）
```

読み込み順序として、`lua/core/bootstrap.lua` がコア（options / keymaps / `vim.pack` 起動）を即座に読み込み、UI・LSP オートフォーマット・カラースキームなどの重い初期化は `vim.defer_fn` で遅延読み込みします。`after/lsp/<server>.lua` は `runtimepath` の読み込み順序により `nvim-lspconfig` 自身の `lsp/*.lua` より後に評価され、サーバー別設定を上書きします。

## プラグイン管理（`vim.pack`）

プラグインは Neovim 組み込みの `vim.pack` で管理しています（配置先は `~/.local/share/nvim/site/pack/core/opt`）。`vim.pack` には遅延ロードの標準機能がないため、`nvim/lua/pack/` の自前ローダーで `event` / `cmd` / `keys` / `ft` / `VeryLazy` を再現しています。

### 自前ローダーの仕様

- `nvim/lua/plugins/*.lua` は `lazy.nvim` 形式の spec をそのまま使用します。ローダーは `vim.pack.add` を 1 回だけ呼び、`dependencies`（循環は許容）、`cond`、`enabled`、`priority`、`init`、`config` / `opts` を解釈します。
- ローダーが未実装の spec キーを指定すると `error` になります。`opts` または `config = true` を使う spec では、setup 対象のモジュールを `main` で明示します。
- トリガーのないプラグインのうち、`config` / `opts` を持たないライブラリは起動時に `runtimepath` へ載せます。`config` / `opts` を持つものは、依存元のロード時、対象モジュールの `require` 時（`package.loaders` に追加したフックが未ロードのプラグインを設定付きでロード）、または対象カラースキームの使用時（`ColorSchemePre` で `colors/` を持つプラグインをロード）に読み込みます。
- イベントでロードしたプラグインは、ロード後に同じイベントを対象バッファへ再発火します（最初のバッファでも `gitsigns` などが有効になります）。`VeryLazy` は `UIEnter` 後に発火します。
- `lazy.nvim` が無効化していた内蔵プラグイン（`gzip`, `matchit`, `matchparen`, `netrwPlugin`, `tarPlugin`, `zipPlugin`, `tutor`）は、`nvim/lua/pack/init.lua` の `loaded_*` ガード変数で無効化しています。

### 更新と初回導入

- lockfile は `nvim/nvim-pack-lock.json`（Git 管理）です。初回インストールと別マシンでの復元は lockfile の rev に従って行われます。
- 更新は `,su`（`vim.pack.update()`）で実行します。確認バッファで `:write` すると適用、`:quit` で破棄します。`,sp` は `vim.pack.update(nil, { offline = true })` を呼び、ネットワークへ出ずにローカル取得済みの更新候補を確認バッファへ表示します（`:write` で適用）。
- headless 環境での初回インストールは確認プロンプトで停止するため、`NVIM_PACK_BOOTSTRAP=1` を付けて実行します（confirm を無効化し、`nvim-treesitter` の build hook である `:TSUpdate` もスキップします）。

```bash
NVIM_PACK_BOOTSTRAP=1 nvim --headless -c 'lua vim.wait(1000)' -c qa
```

### テストと移行履歴

- ローダーのトリガー（`cmd` の bang・範囲・引数、`keys` の初回入力、`event` の再発火、`config` 失敗時の通知）は、偽プラグインを使う headless テストで検証します。実行は `mise run test:nvim`（`nvim/spec/headless/pack_loader_check.lua`、実プラグイン・ネットワーク不要）で行います。Neovim の入っていない CI 環境では実行していません。
- `gitlinker.nvim` は削除しています。`lazy.nvim` 下でも `keys = {}` のまま一度もロードされておらず、`vim.pack` で `runtimepath` に載せると `plugin/` が自動 setup されて `:GitLink` が意図せず生えるためです。
- `lazy.nvim` 版の最終状態は Git タグ `nvim-lazy-last` に記録されています。

## サポート言語

- プログラミング言語: Lua, Go, Python, JavaScript / TypeScript（JSX / TSX / Vue 含む）, Bash / Shell（zsh 含む）
- インフラ・設定: Docker, Terraform, Prisma, TOML, JSON, YAML（docker-compose / gitlab / helm-values 含む）
- マークアップ: CSS, Markdown, Astro

上記に加え、`typos_lsp` が全ファイルタイプ横断でスペルチェックを行います（サーバー一覧の正本は `nvim/lua/lsp/config.lua` の `M.servers` です）。

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

### LSP 機能

```lua
tt              -- 定義へ移動
tj              -- 参照を検索
K               -- ホバー表示
tk              -- 実装へ移動
tl              -- 型定義へ移動
<C-e>f          -- 自動選択フォーマット
<C-e>b/p/e/s    -- Biome / Prettier / ESLint / TypeScript(ts_ls) で個別フォーマット
```

### 開発ツール

```lua
<Tab>           -- 補完受諾（blink.cmp）
,sp             -- 取得済みの更新候補を確認（vim.pack.update, offline）
,sm             -- MasonUpdate
,st             -- Treesitter 更新
,su             -- プラグイン更新（vim.pack.update）
```

### タブ・ウィンドウ

```lua
<C-t>c/d/o/n/p  -- タブ作成 / close / split / next / prev
gt / gT         -- タブ切り替え（次 / 前）
<Tab>           -- ウィンドウ間循環移動（Normal モード。Insert モードでは補完受諾）
```

## プラグインエコシステム

### コア

- `vim.pack`: Neovim 組み込みのプラグインマネージャー（遅延ロードは自前ローダー `nvim/lua/pack/` が担当）
- `nvim-lspconfig`: サーバーごとの既定設定を提供（一覧の正本は `nvim/lua/lsp/config.lua` の `M.servers`）
- `mason.nvim` + `mason-lspconfig`: `nvim/lua/config/mason-lspconfig.lua` が `M.servers` を `automatic_enable = false` でインストールし、有効化は行いません
- 有効化: `nvim/lua/lsp/setup.lua` が `vim.lsp.config` / `vim.lsp.enable` による唯一の活性化ポイントを担い、サーバー別の上書きは `after/lsp/<server>.lua` に置きます

### UI・ナビゲーション

- `mini.pick` + `mini.extra`: ファジーファインダー
- `mini.files`: 既定のファイルエクスプローラー
- `flash.nvim` + `mini.jump` + `mini.jump2d`: 高速モーション

### 補完

- `blink.cmp` + `friendly-snippets`

### 構文

- `nvim-treesitter`, `ts-context-commentstring`, `vim-matchup`, `rainbow-delimiters`

### 開発

- `gitsigns.nvim`: Git 統合（サインカラム・hunk 操作）
- `vim-fugitive`（+ `vim-rhubarb`）: Git コマンド統合
- `diffview.nvim`, `neogit`: diff 表示・Git UI

## テーマ・UI

- メインテーマ: `0x96f.nvim`（`filipjanevski/0x96f.nvim`、`lua/settings/colorscheme.lua` で適用）。`kanagawa.nvim` / `tokyonight.nvim` も登録済みで手動切り替えが可能です（遅延ロード扱いのため `runtimepath` に載ります）。
- 透明背景: `Normal` / `SignColumn` などを `guibg=NONE` にし、ターミナル背景と統合しています。
- ステータスライン: モード、Git ブランチ、LSP 状態、診断情報を表示します（`lualine.nvim`）。

## 最適化設定

```lua
-- 未使用プロバイダー無効化（lua/settings/options.lua）
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0 -- 同期的な mise コマンド実行を回避

-- 不要な内蔵プラグインを loaded_* ガード変数で無効化（lua/pack/init.lua）
-- gzip, matchit, matchparen, netrwPlugin, tarPlugin, zipPlugin, tutor
```

- トリガー（`event` / `cmd` / `keys` / `ft`）のないプラグインは、起動時に `runtimepath` へ載せるのみで `config` は実行しません。
- 大ファイル対策: `lua/core/utils.lua` の `is_large_file`（既定 2MB 超）を `lua/core/ftplugin_loader.lua` が参照し、超過時は Treesitter の `vim.treesitter.start` をスキップします。

## カスタマイゼーション

プロジェクト固有の上書きは、`lua/core/project_config.lua` が cwd から上方向に `nvim.config.lua` を探索して自動で読み込みます（マシン固有の `lua/config/local.lua` に相当する仕組みはありません）。

```lua
-- 例: リポジトリ直下に nvim.config.lua を置くと自動読み込みされます
vim.opt.background = "light"
vim.keymap.set('n', '<leader>ll', '<cmd>checkhealth<CR>')
```

## メンテナンス

```bash
# プラグイン更新（週次。`,su` と同等）
:lua vim.pack.update()

# LSP サーバー更新（月次）
:MasonUpdate

# ヘルスチェック
:checkhealth

# フォーマット / Lint バンドル（リポジトリ共通、mise タスク）
mise run format
mise run lint
mise run ci   # フル CI 相当
```

- `blink.cmp` の `:checkhealth` で「Some providers may show up as "disabled"」と表示されるのは仕様であり、設定側で info 扱いへ変換しています。
- `conform` は Biome の設定ファイルが存在するときのみ Biome を有効化し、存在しない場合は Prettier / `eslint_d` のみで動作します。

## デバッグ・プロファイリング

```bash
# 起動時間測定
nvim --startuptime startup.log

# プラグイン数の確認（nvim/measure_startup.sh も参照）
:lua print(#vim.pack.get())

# LSP 状態確認
:LspInfo
```

## トラブルシューティング

```bash
# プラグイン状態のリセット（次回起動時に lockfile の rev から再インストールされます）
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim

# 最小構成で起動
nvim --clean
```
