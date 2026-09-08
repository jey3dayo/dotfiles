# 💻 Neovim Configuration Guide

100ms未満の高速起動と15言語対応のLSPを実現できるモダンなLua設定の指標とベースライン。以下の具体例（キーバインド・プラグイン名・ディレクトリ構成）はこの dotfiles リポジトリ（`~/.config/nvim`）の実際の設定を基にしたサンプルであり、他リポジトリへ適用する際はそのリポジトリの実体に合わせて読み替えること。

## アーキテクチャの指針

- 完全Lua化: Vimscriptの排除
- 階層化設計: エントリポイント → プラグイン別設定 → プラグイン定義 → 起動基盤 の明確な分離
- 遅延読み込み戦略: プラグインの条件付き・イベント駆動読み込み
- 段階的読み込み: コア（options/keymaps/lazy起動）→ UI → LSP → AI の優先度別読み込み（この設定では `lua/core/bootstrap.lua` が `vim.defer_fn` で重い初期化を後回しにする）
- 大ファイル対策: 一定サイズ超のファイルで Treesitter を無効化
- 不要プロバイダー削除: 使わない言語プロバイダー（Ruby/Node/Perl/Python 等）を無効化して起動を軽量化

## 改善機会（微細レベル・未対応）

- Treesitter query の最適化
- カスタムコマンドのより詳細なドキュメント化
- プラグイン間依存関係の明示

## 主要機能

- 高性能: lazy.nvim最適化による100ms未満起動
- LSP対応: 15以上の言語・設定形式をフルサポート
- AI統合: Supermaven-nvim
- モダンUI: ファジーファインダー・ファイルエクスプローラー・高速モーションプラグインによるナビゲーション（この設定では mini.pick、mini.files、flash.nvim）

## パフォーマンス指標

| 項目               | 起動時間     | 最適化手法       |
| ------------------ | ------------ | ---------------- |
| 全体起動           | <100ms       | lazy.nvim        |
| プラグイン読み込み | 遅延実行     | 条件付き読み込み |
| LSP初期化          | オンデマンド | 言語別設定       |

## 設定構造（この dotfiles 設定の例）

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

## サポート言語（この設定の例）

プログラミング言語: Lua, Go, Python, JavaScript/TypeScript（JSX/TSX/Vue含む）, Bash/Shell（zsh含む）, Vim script

インフラ・設定: Docker, Terraform, Prisma, TOML, JSON, YAML

マークアップ: CSS（Tailwind CSS 含む）, Markdown, Astro

言語幅の広さ: 15言語前後の対応は業界平均（8-10言語）を上回る目安になる。

## 主要キーバインド（この dotfiles 設定の例。leader キーはリポジトリごとに異なる）

この設定では leader キーに `,`（カンマ）を使う（`vim.g.mapleader`）。Space leader は一般的な選択肢の一つであり、このリポジトリの既定ではない。

### ファイル・ナビゲーション

```lua
,f              -- ファイル検索
,,              -- ピッカー再開
,gr             -- 文字列検索
,b              -- バッファ一覧
,e              -- ファイルエクスプローラーを開く
,E              -- 現在バッファのディレクトリでファイルエクスプローラーを開く
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
<Tab>          -- AI補完受諾（AI > LSP補完 > 既定Tab の優先順）
<C-]>          -- AI補完クリア
,sp             -- プラグインマネージャーUI
,sm             -- LSPサーバー更新
,st             -- Treesitter 更新
```

## プラグインエコシステム（この設定の例）

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

## 最適化設定（パターン例）

```lua
-- 未使用プロバイダー無効化
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0

-- lazy.nvim パフォーマンス設定
defaults = { lazy = true }  -- デフォルト遅延ロード
disabled_plugins = {        -- 不要内蔵プラグイン無効化
  "gzip", "matchit", "matchparen", "netrwPlugin",
  "tarPlugin", "tohtml", "tutor", "zipPlugin"
}
```

大ファイル対策はファイルサイズ判定ユーティリティ（例: 2MB超）を Treesitter/ftplugin の読み込み判定から参照する形が典型的。具体的な実装場所はリポジトリごとに確認すること。

## カスタマイゼーション

プロジェクト固有・マシン固有の上書きを読み込む仕組みを用意する場合は、読み込み対象のファイル名・探索方法（cwd起点かホーム起点か）を実装側で確認してから記載する。dotfiles 側の実際の仕組みは `docs/tools/nvim.md` の「カスタマイゼーション」節を参照。

## メンテナンス

```bash
# プラグイン更新（週次）
:Lazy update

# LSPサーバー更新（月次）
:MasonUpdate

# ヘルスチェック
:checkhealth
```

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

AI支援と包括的言語サポートを備えたモダン開発環境の設計指標とベースライン。
