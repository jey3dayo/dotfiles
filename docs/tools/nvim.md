# Neovim設定

100ms未満の高速起動と15言語対応のLSPを備えたモダンなLua設定です。

## 主要機能

- **高性能**: lazy.nvim最適化による100ms未満起動
- **LSP対応**: 15以上のプログラミング言語をフルサポート
- **AI統合**: GitHub Copilot + Avante.nvim
- **モダンUI**: Telescope、nvim-tree、高速ナビゲーション

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
│   ├── config/           # コア設定
│   ├── plugins/          # プラグイン設定
│   └── utils/            # ユーティリティ
└── after/ftplugin/       # ファイルタイプ設定
```

## サポート言語

**プログラミング言語**: Lua, TypeScript/JavaScript, Python, Rust, Go, C/C++,
Java, PHP, Ruby, Swift, Kotlin, C#, Dart, Shell

**マークアップ**: HTML/CSS, JSON, YAML, TOML, Markdown, Docker

## 主要キーバインド

### ファイル・ナビゲーション（Leader: `<Space>`）

```lua
<leader>ff      -- ファイル検索
<leader>fg      -- 文字列検索
<leader>fb      -- バッファ一覧
<leader>e       -- ファイルエクスプローラー
```

### LSP機能

```lua
gd              -- 定義へ移動
gr              -- 参照を検索
K               -- ホバー表示
<leader>ca      -- コードアクション
<leader>rn      -- シンボル名変更
<leader>f       -- フォーマット
```

### AI・開発ツール

```lua
<leader>cc      -- Copilot チャット
<leader>av      -- Avante トグル
<leader>gg      -- Lazygit
<leader>tt      -- ターミナル
```

## プラグインエコシステム

### コア

- **lazy.nvim**: 遅延読み込みプラグインマネージャー
- **nvim-lspconfig**: LSP設定
- **mason.nvim**: LSPサーバー管理

### UI・ナビゲーション

- **telescope.nvim**: ファジーファインダー
- **nvim-tree.lua**: ファイルエクスプローラー
- **harpoon**: 高速ファイルナビゲーション

### AI・開発

- **copilot.lua**: GitHub Copilot
- **avante.nvim**: AI チャット統合
- **gitsigns.nvim**: Git統合

## テーマ・UI

- **メインテーマ**: Gruvbox（他ツールと統一）
- **透明背景**: ターミナル統合
- **ステータスライン**: モード、Gitブランチ、LSP状態、診断情報

## 最適化設定

```lua
-- 未使用プロバイダー無効化
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- 遅延UI読み込み
vim.defer_fn(function()
  require('nvim-tree').setup()
end, 0)

-- lazy.nvim パフォーマンス設定
defaults = { lazy = true }  -- デフォルト遅延ロード
disabled_plugins = {        -- 不要内蔵プラグイン無効化
  "gzip", "matchit", "netrwPlugin", "tarPlugin", "zipPlugin"
}

-- 大ファイル対策（Treesitter）
disable = function(_, buf)
  local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
  return ok and stats and stats.size > 1024 * 1024 * 2  -- >2MB
end
```

## カスタマイゼーション

マシン固有設定は `lua/config/local.lua` に記述：

```lua
-- テーマ変更
vim.opt.background = "light"

-- Copilot無効化
vim.g.copilot_enabled = false

-- カスタムキーマップ
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

AI支援と包括的言語サポートを備えたモダン開発環境
