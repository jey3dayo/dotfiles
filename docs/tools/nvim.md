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
timestamp: 2026-11-13
audience: advanced
owner: dotfiles
---

# 💻 Neovim Configuration Guide

warm 起動 約50ms（ファイルなし・中央値、2026-11-09 実測、目標 <200ms）と15言語対応のLSPを備えた、Neovim 組み込みの `vim.pack` で管理するLua設定です。

## 🤖 Claude Rules

このドキュメントの凝縮版ルールは [`.claude/rules/tools/nvim.md`](../../.claude/rules/tools/nvim.md) で管理されています。

- 目的: Claude AIが常に参照する簡潔なルール
- 適用範囲: YAML frontmatter `paths:` で定義
- 関係: 本ドキュメントが詳細リファレンス（SST）、Claudeルールが強制版

## 主要機能

- 高性能: 自前ローダーによる遅延ロードで warm 起動 約50ms（ファイルなし）/ 約78ms（ファイルあり）、実測 2026-11-09（[検証](#検証)）
- LSP対応: 15以上の言語・設定形式をフルサポート
- モダンUI: mini.pick、mini.files、flash.nvim による高速ナビゲーション
- 補完: `blink.cmp` + `friendly-snippets`
- フォーマット: 保存時自動フォーマットなし。`:Format`（`<C-e>f`）で手動実行、コミット時の整形は lefthook の pre-commit（staged files）が担う

## パフォーマンス指標

| 項目               | 起動時間                               | 最適化手法                                              |
| ------------------ | -------------------------------------- | ------------------------------------------------------- |
| 全体起動           | 約50ms（ファイルなし）/ 約78ms（あり） | 自前ローダー（`nvim/lua/pack/`）による遅延ロード        |
| プラグイン読み込み | 遅延実行                               | `event` / `cmd` / `keys` / `ft` / `VeryLazy` で読み込み |
| LSP初期化          | オンデマンド                           | 言語別設定                                              |

## 検証

目標 <200ms の範囲内。測定条件（2026-11-09、Apple M4 Max（arm64）、NVIM v0.12.6、`nvim --headless --startuptime <log> [file] -c qa`、設定は本リポジトリ root の `nvim/`、ファイルなしとファイルありを交互に各 20 回）:

| 区分                                   | 中央値 | 最小 | 最大 |
| -------------------------------------- | ------ | ---- | ---- |
| ファイルなし                           | 50.2ms | 43.4 | 57.1 |
| ファイルあり（`nvim/lua/options.lua`） | 77.9ms | 70.4 | 99.4 |

- `-c qa` は `VimEnter` より前に終了するため、`VeryLazy`、`VimEnter` で読み込む plugin、`vim.defer_fn` の遅延モジュールは計測に含まれない。
- 同日の参考値として、lazy.nvim 版（タグ `nvim-lazy-last`）を同条件・各 20 回の交互実行で測った中央値は、ファイルなし 44.9ms、ファイルあり 72.1ms。上の `vim.pack` 版との差は約 5ms。簡易計測は `nvim/measure_startup.sh`。
- 同一条件でも負荷により数 ms 動く（lazy 版単体でも日により中央値が変わった）ため、差は目安として扱う。

## 設定構造

```text
nvim/
├── init.lua              # エントリポイント
├── lua/
│   ├── init_pack.lua     # vim.pack ブートストラップ（pack/ を呼ぶ）
│   ├── pack/             # 自前ローダー（spec 正規化 / 遅延ロードのスタブ / vim.pack 呼び出し）
│   ├── config/           # プラグイン別の詳細設定
│   ├── plugins/          # プラグイン定義（lazy.nvim 形式の spec、カテゴリ別）
│   ├── core/             # 起動・依存・ファイルタイプ基盤
│   └── lsp/              # LSP、フォーマット、診断ヘルパー
├── nvim-pack-lock.json   # vim.pack の lockfile（git 管理）
├── after/ftplugin/       # ファイルタイプ設定
└── after/lsp/            # サーバー別 LSP 上書き（12ファイル、`ls nvim/after/lsp`）
```

読み込み順序: `lua/core/bootstrap.lua` がコア（options/keymaps/vim.pack 起動）を即座に読み込み、UI・LSPオートフォーマット・カラースキームなどの重い初期化は `vim.defer_fn` で遅延読み込みする。`after/lsp/<server>.lua` は runtimepath の読み込み順序により nvim-lspconfig 自身の `lsp/*.lua` より後に評価され、サーバー別設定を上書きする。

## プラグイン管理（vim.pack）

プラグインは Neovim 組み込みの `vim.pack` で管理する（配置先は `~/.local/share/nvim/site/pack/core/opt`）。`vim.pack` には遅延ロードの標準機能がないため、`nvim/lua/pack/` の自前ローダーが `event` / `cmd` / `keys` / `ft` / `VeryLazy` を再現している。

- `nvim/lua/plugins/*.lua` は lazy.nvim 形式の spec をそのまま使う。ローダーは `vim.pack.add` を 1 回だけ呼び、`dependencies`（循環は許容）、`cond`、`enabled`、`priority`、`init`、`config` / `opts` を解釈する。
- ローダーが実装していない spec キーは `error` になる。`opts` または `config = true` を使う spec には、setup するモジュールを `main` で明示する。
- トリガーのない plugin のうち、config / opts を持たないライブラリは `runtimepath` に載せる。config / opts を持つものは、依存元のロード時、その module を `require` した時（`package.loaders` に追加したフックが未ロード plugin を設定つきでロードする）、またはその colorscheme を使う時（`ColorSchemePre` で `colors/` を持つ plugin をロードする）にロードされる。
- イベントでロードした plugin は、ロード後に同じイベントを対象バッファへ再発火する（最初のバッファでも gitsigns などが効く）。`VeryLazy` は `UIEnter` 後に発火する。
- lazy.nvim が無効化していた runtime plugin（gzip, matchit, matchparen, netrwPlugin, tarPlugin, zipPlugin, tutor）は `loaded_*` ガード変数で無効化している（`nvim/lua/pack/init.lua`）。
- lockfile は `nvim/nvim-pack-lock.json`（git 管理）。初回 install と別マシンでの復元は lockfile の rev で行われる。
- 更新は `,su`（`vim.pack.update()`）。確認バッファで `:write` すると適用、`:quit` で破棄する。`,sp` は `vim.pack.update(nil, { offline = true })` で、ネットワークには出ず、ローカルに取得済みの更新候補を確認バッファに表示する（`:write` で適用）。
- headless の初回 install は確認プロンプトで止まるため、`NVIM_PACK_BOOTSTRAP=1` を付けて実行する（confirm を無効化し、nvim-treesitter の build hook である `:TSUpdate` も実行しない）。

```bash
NVIM_PACK_BOOTSTRAP=1 nvim --headless -c 'lua vim.wait(1000)' -c qa
```

- ローダーのトリガー（cmd の bang・範囲・引数、keys の初回入力、event の再発火、config 失敗時の通知）は、偽 plugin を使う headless テストで確認する。実行は `mise run test:nvim`（`nvim/spec/headless/pack_loader_check.lua`、実 plugin もネットワークも不要）。nvim の無い CI では走らせていない。

- gitlinker.nvim は外した。lazy.nvim 下でも `keys = {}` のまま一度もロードされておらず、`vim.pack` で `runtimepath` に載せると `plugin/` が自動で setup して `:GitLink` が新たに生えるため。
- lazy.nvim 版の最終状態はタグ `nvim-lazy-last` に記録されています。

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
,sp             -- 取得済みの更新候補を確認（vim.pack.update, offline）
,sm             -- MasonUpdate
,st             -- Treesitter 更新
,su             -- プラグイン更新（vim.pack.update）
```

### タブ・ウィンドウ

```lua
<C-t>c/d/o/n/p  -- タブ作成/close/split/next/prev
gt / gT         -- タブ切り替え（次/前）
<Tab>           -- ウィンドウ間循環移動（Normalモード。Insertモードでは補完受諾）
```

## プラグインエコシステム

### コア

- vim.pack: Neovim 組み込みのプラグインマネージャー。遅延ロードは自前ローダー（`nvim/lua/pack/`）が担う
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
- vim-fugitive（+ vim-rhubarb）: Git コマンド統合
- diffview.nvim, neogit: diff表示・Git UI

## テーマ・UI

- メインテーマ: `0x96f.nvim`（`filipjanevski/0x96f.nvim`、`lua/colorscheme.lua` で適用）。`kanagawa.nvim` / `tokyonight.nvim` も登録済みで手動切り替え可能（遅延ロード扱いのため runtimepath には載る）
- 透明背景: `Normal`/`SignColumn` 等を `guibg=NONE` にしてターミナル背景と統合
- ステータスライン: モード、Gitブランチ、LSP状態、診断情報（lualine.nvim）

## 最適化設定

```lua
-- 未使用プロバイダー無効化（lua/options.lua）
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0 -- 同期的な mise コマンド実行を回避

-- 不要な内蔵プラグインを loaded_* ガード変数で無効化（lua/pack/init.lua）
-- gzip, matchit, matchparen, netrwPlugin, tarPlugin, zipPlugin, tutor
```

トリガー（`event` / `cmd` / `keys` / `ft`）のない plugin は起動時に `runtimepath` へ載せるだけで、config は実行しない。

大ファイル対策: `lua/core/utils.lua` の `is_large_file`（既定 2MB 超）を `lua/core/ftplugin_loader.lua` が参照し、超過時は Treesitter の `vim.treesitter.start` をスキップする。

## カスタマイゼーション

プロジェクト固有の上書きは `load_config.lua` が cwd から上方向に `nvim.config.lua` を探索して読み込む（マシン固有の `lua/config/local.lua` のような仕組みは現状存在しない）：

```lua
-- 例: リポジトリ直下に nvim.config.lua を置くと自動読み込みされる
vim.opt.background = "light"
vim.keymap.set('n', '<leader>ll', '<cmd>checkhealth<CR>')
```

## メンテナンス

```bash
# プラグイン更新（週次。`,su` と同じ）
:lua vim.pack.update()

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

## デバッグ・プロファイリング

```bash
# 起動時間測定
nvim --startuptime startup.log

# プラグイン数の確認（nvim/measure_startup.sh も参照）
:lua print(#vim.pack.get())

# LSP状態確認
:LspInfo
```

## トラブルシューティング

```bash
# プラグイン状態リセット（次回起動で lockfile の rev から再 install される）
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim

# 最小構成で起動
nvim --clean
```
