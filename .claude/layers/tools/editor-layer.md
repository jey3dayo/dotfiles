# Editor Layer - Neovim & Development Environment

このレイヤーでは、Neovim設定、プラグイン管理、LSP統合、AI支援ツールの最適化に関する知見を体系化します。

## 🎯 責任範囲

**🔥 主要技術**: Neovimはdotfiles環境の中核技術の一つ

- **設定量**: 全dotfilesの約30%を占める主要コンポーネント
- **技術特性**: Lua設定、LSP統合、AI支援（Copilot/Avante）
- **使用頻度**: コード編集・開発作業の中心ツール

- **Neovim Core**: 基本設定、キーマップ、オプション
- **Plugin Management**: lazy.nvim、プラグイン最適化
- **LSP Integration**: 言語サーバー、補完、診断
- **AI Tools**: Copilot、Avante、コード生成支援

## 📊 実装パターン

### Lua設定の階層構造

```lua
-- init.lua - エントリーポイント（モジュラー設計）
require('core.options')
require('core.keymaps')
require('core.autocmds')
require('plugins')

-- config/options.lua - 基本設定
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- config/keymaps.lua - キーマップ
local keymap = vim.keymap
keymap.set('n', '<leader>e', ':Neotree toggle<CR>')
keymap.set('n', '<C-h>', '<C-w>h')  -- ウィンドウ移動

-- autocmds.lua - ファイルタイプ別設定
vim.api.nvim_create_autocmd("FileType", {
    pattern = "lua",
    callback = function()
        -- Lua固有設定
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
    end,
})
```

### lazy.nvim プラグイン管理

```lua
-- config/lazy.lua - プラグインマネージャー
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup('plugins', {
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip', 'matchit', 'matchparen',
        'netrwPlugin', 'tarPlugin', 'tohtml',
        'tutor', 'zipPlugin',
      },
    },
  },
})
```

## 🔧 LSP統合パターン

### LSP設定の統一化

```lua
-- plugins/lsp.lua
return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'hrsh7th/nvim-cmp',
  },
  config = function()
    local lspconfig = require('lspconfig')
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    local servers = {
      'lua_ls', 'tsserver', 'rust_analyzer',
      'pyright', 'gopls', 'clangd'
    }

    for _, server in ipairs(servers) do
      lspconfig[server].setup({
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          -- 共通キーマップ設定
          local bufopts = { noremap=true, silent=true, buffer=bufnr }
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
        end,
      })
    end
  end,
}
```

### 補完設定 (blink.cmp)

```lua
-- plugins/completion.lua
return {
  'saghen/blink.cmp',
  lazy = false,
  dependencies = 'rafamadriz/friendly-snippets',
  version = 'v1.*',
  config = function()
    require('blink.cmp').setup({
      keymap = {
        preset = 'default',
        ['<C-k>'] = { 'accept', 'snippet_forward', 'fallback' },
        ['<Tab>'] = { 'accept', 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
          snippets = {
            score_offset = 100, -- High priority for snippets
            opts = {
              friendly_snippets = true,
              search_paths = { vim.fn.stdpath('config') .. '/snippets' },
            },
          },
        },
      },

      completion = {
        accept = {
          auto_brackets = { enabled = true },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
      },

      fuzzy = {
        implementation = 'prefer_rust_with_warning',
        use_frecency = true,
        use_proximity = true,
      },
    })
  end,
}
```

## 🤖 AI統合パターン

### GitHub Copilot設定

```lua
-- plugins/copilot.lua
return {
  'github/copilot.vim',
  event = 'InsertEnter',
  config = function()
    vim.g.copilot_no_tab_map = true
    vim.keymap.set('i', '<C-J>', 'copilot#Accept("")', {
      expr = true,
      replace_keycodes = false
    })
    vim.keymap.set('i', '<C-K>', '<Plug>(copilot-dismiss)')
    vim.keymap.set('i', '<C-N>', '<Plug>(copilot-next)')
    vim.keymap.set('i', '<C-P>', '<Plug>(copilot-previous)')
  end,
}
```

### Avante (Claude統合)

```lua
-- plugins/avante.lua
return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  lazy = false,
  version = false,
  opts = {
    provider = 'claude',
    auto_suggestions = true,
    claude = {
      endpoint = 'https://api.anthropic.com',
      model = 'claude-3-5-sonnet-20241022',
      temperature = 0,
      max_tokens = 4096,
    },
  },
  build = 'make',
  dependencies = {
    'stevearc/dressing.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
  },
}
```

## ⚡ パフォーマンス最適化

### 起動時間最適化

```lua
-- 不要なプラグイン無効化
vim.g.loaded_gzip = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1
vim.g.loaded_netrwFileHandlers = 1
```

### 遅延読み込み戦略

```lua
-- 言語固有プラグインの遅延読み込み
return {
  'rust-lang/rust.vim',
  ft = 'rust',  -- Rustファイル時のみ読み込み
}

return {
  'fatih/vim-go',
  ft = 'go',    -- Goファイル時のみ読み込み
}

-- イベント駆動の遅延読み込み
return {
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
}
```

## 🎨 UI・テーマ統合

### 統一テーマ設定

```lua
-- plugins/theme.lua
return {
  'ellisonleao/gruvbox.nvim',
  priority = 1000,
  config = function()
    require('gruvbox').setup({
      terminal_colors = true,
      undercurl = true,
      underline = true,
      bold = true,
      italic = {
        strings = true,
        emphasis = true,
        comments = true,
        operators = false,
        folds = true,
      },
      strikethrough = true,
      invert_selection = false,
      invert_signs = false,
      invert_tabline = false,
      invert_intend_guides = false,
      inverse = true,
      contrast = 'hard',
      palette_overrides = {},
      overrides = {},
      dim_inactive = false,
      transparent_mode = false,
    })
    vim.cmd('colorscheme gruvbox')
  end,
}
```

## 🔍 診断・デバッグ

### パフォーマンス測定

```lua
-- 起動時間測定
vim.cmd[[
command! StartupTime lua require('utils').measure_startup_time()
]]

-- utils.lua
local M = {}

function M.measure_startup_time()
  local start = vim.fn.reltime()
  vim.cmd('source ~/.config/nvim/init.lua')
  local elapsed = vim.fn.reltimestr(vim.fn.reltime(start))
  print('Startup time: ' .. elapsed .. 's')
end

return M
```

### LSP診断

```lua
-- LSP状態確認
vim.cmd[[
command! LspStatus lua print(vim.inspect(vim.lsp.buf_get_clients()))
command! LspLog lua vim.cmd('edit ' .. vim.lsp.get_log_path())
]]
```

## 🐛 LSPエラー対処パターン

### vscode-langservers-extracted MethodNotFoundエラー対策

#### 問題・背景

- **エラー**: `Unhandled exception: MethodNotFound`
- **原因**: vscode-langservers-extracted 4.8.0+がLSP 3.17仕様を実装、Neovimとの互換性問題
- **影響**: JSON/HTML/CSS LSPがクラッシュ、補完・検証機能停止

#### 解決策・パターン

**方法1: 安定版への切り替え（推奨）**

```bash
# 旧バージョンのvscode-json-languageserverをグローバルインストール
npm install -g vscode-json-languageserver@1.3.4
```

```lua
-- lsp/settings/jsonls.lua - 安定版使用
{
  cmd = { 'vscode-json-languageserver', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  init_options = {
    provideFormatter = true,
  },
  capabilities = capabilities,
}
```

**方法2: capabilities拡張（非推奨）**

```lua
-- lsp/settings/jsonls.lua - capabilities拡張で動的登録サポートを宣言
capabilities = (function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- 既存の設定...

  -- Fix for vscode-langservers-extracted 4.8.0+ MethodNotFound error
  capabilities.workspace = capabilities.workspace or {}
  capabilities.workspace.configuration = true
  capabilities.workspace.didChangeConfiguration = {
    dynamicRegistration = true
  }
  return capabilities
end)(),
```

#### 適用条件・注意点

- **推奨解決**: vscode-json-languageserver@1.3.4への切り替え
- **副作用**: 旧バージョンのため最新機能は利用不可だが、安定性重視
- **根本解決**: Neovim 0.12-dev以降へのアップグレード

#### 実測値

- **改善効果**: エラー100%解消、JSON LSP正常動作
- **測定日**: 2025-07-05
- **検証環境**: Neovim v0.11.2 + vscode-json-languageserver@1.3.4

## 📊 Neovim プラグイン戦略 2025年版

### 🎯 2025年プラグイン最適化方針

#### 削除・刷新候補（起動時間改善）

**❌ 削除推奨**

- **mason-lspconfig.nvim** (82.1ms) → 手動設定化で大幅軽量化
- **telescope.nvim** (151.76ms) → **fzf-lua**移行で60%高速化
- **cmp-cmdline** (3.06ms) → 使用頻度低、削除対象
- **tailwindcss-colorizer-cmp** (0.15ms) → 特定用途、汎用性低

**⚡ 高速化移行 (✅ 完了)**

- **✅ nvim-cmp** → **blink.cmp** 移行完了 (80%高速化達成)
- **nvim-web-devicons** (0.41ms) → **mini.icons** (一体化) で統合効率化

#### 2025年最新プラグイン評価

| カテゴリ     | 現在プラグイン    | 評価       | 2025年推奨     | 改善効果      |
| ------------ | ----------------- | ---------- | -------------- | ------------- |
| **補完**     | ✅ blink.cmp      | ⭐⭐⭐⭐⭐ | **blink.cmp**  | 80%高速化達成 |
| **検索**     | telescope.nvim    | ⭐⭐⭐⭐   | **fzf-lua**    | 60%高速化     |
| **UI**       | dressing.nvim     | ⭐⭐⭐⭐   | **noice.nvim** | モダン化      |
| **LSP**      | mason-lspconfig   | ⭐⭐⭐     | 手動設定       | 82ms削減      |
| **アイコン** | nvim-web-devicons | ⭐⭐⭐     | **mini.icons** | 統合効率化    |

#### プラグイン数最適化戦略

**現状**: ~50プラグイン（telescopeエコシステム含む）
**目標**: 35プラグイン（30%削減）
**手法**:

- **mini.\*** 統合で機能集約
- 機能重複プラグイン削除
- 言語固有プラグイン見直し

#### 最新ベストプラクティス適用

**2025年推奨パターン**:

1. **blink.cmp** - Rust製高速補完エンジン
2. **fzf-lua** - telescopeより高速なファジーファインダー
3. **noice.nvim** - モダンUI統合
4. **mini.files** - 軽量ファイル管理（oil.nvim置き換え）
5. **mini.icons** - 統合アイコンシステム

### 実装優先度

#### 最高優先度（即時実装）

- **✅ blink.cmp移行**: 補完性能80%向上 (完了)
- **fzf-lua移行**: 検索性能60%向上
- **mason-lspconfig削除**: 起動時間82ms削減

#### 高優先度（1-2週間）

- **不要プラグイン削除**: 全体軽量化
- **mini.icons統合**: アイコン統一化
- **設定リファクタリング**: 保守性向上

#### 中優先度（1ヶ月）

- **noice.nvim導入**: UI現代化
- **✅ mini.files移行**: oil.nvim置き換え、mini.nvim統合
- **プラグイン統合**: 機能重複解消

## 🚧 最適化課題

### 高優先度

- [x] 起動時間を100ms以下に短縮（95ms達成 ✅）
- [ ] **プラグイン2025年最適化**: blink.cmp + fzf-lua移行 (目標: 50%高速化)
- [ ] **プラグイン数削減**: 現在50個 → 目標35個 (30%削減)

### 中優先度

- [ ] **LSP設定手動化**: mason-lspconfig依存削除
- [ ] **UI現代化**: noice.nvim + mini.icons統合
- [ ] **設定リファクタリング**: 2025年パターン適用

### 低優先度

- [ ] **ワークスペース管理強化**: プロジェクト固有設定
- [ ] **DAP統合**: デバッグ環境構築

## 🛠️ フォーマット・リンティング戦略 2025年版

### null-ls.nvim アーカイブ後の状況

#### 📊 現状分析（2025年7月）

**null-ls.nvim** → **アーカイブ済み**（2023年11月）

- **後継**: nvimtools/none-ls.nvim（コミュニティフォーク）
- **API**: 完全互換、既存設定そのまま使用可能
- **メンテナンス**: 活発（2024-25年で2300+コミット）

#### 2025年推奨戦略

| 手法                         | 用途       | パフォーマンス         | 推奨度     |
| ---------------------------- | ---------- | ---------------------- | ---------- |
| **conform.nvim + nvim-lint** | 軽量・高速 | 起動1ms、メモリ0.5MB   | ⭐⭐⭐⭐⭐ |
| **none-ls.nvim**             | 機能豊富   | 起動5-7ms、メモリ1.0MB | ⭐⭐⭐⭐   |
| **純粋LSP**                  | 最小構成   | 起動0ms、メモリ0MB     | ⭐⭐⭐     |

#### 🎯 推奨構成: conform + nvim-lint

```lua
-- plugins/formatting.lua
return {
  -- フォーマット専用（軽量・高速）
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          javascript = { "prettierd", "prettier", stop_after_first = true },
          typescript = { "prettierd", "prettier", stop_after_first = true },
          go = { "gofmt", "goimports" },
          rust = { "rustfmt" },
          python = { "black", "isort" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
    end,
  },

  -- リンティング専用（診断特化）
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("lint").linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        markdown = { "markdownlint" },
        yaml = { "yamllint" },
        dockerfile = { "hadolint" },
      }

      -- 保存時自動リント
      vim.api.nvim_create_autocmd("BufWritePost", {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
}
```

#### 🔧 none-ls.nvim使用ケース

**使用推奨条件**:

- 複雑なコードアクション（eslint --fix）
- 統合的な診断・フォーマット管理
- 既存設定の継続利用

```lua
-- plugins/none-ls.lua
return {
  "nvimtools/none-ls.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local null_ls = require("null-ls")

    null_ls.setup({
      sources = {
        -- フォーマット
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.prettier,

        -- 診断
        null_ls.builtins.diagnostics.eslint_d,
        null_ls.builtins.diagnostics.markdownlint,

        -- コードアクション
        null_ls.builtins.code_actions.eslint_d,
        null_ls.builtins.code_actions.gitsigns,
      },
      -- パフォーマンス最適化
      debug = false,  -- 本番では無効化必須
    })
  end,
}
```

### パフォーマンス比較実測

#### 起動時間

- **conform + nvim-lint**: 1-2ms
- **none-ls.nvim**: 5-7ms
- **差**: 4-5ms削減効果

#### メモリ使用量

- **conform + nvim-lint**: 0.5MB
- **none-ls.nvim**: 1.0MB
- **差**: 50%メモリ削減

#### フォーマット遅延（1000行TypeScript）

- **conform + prettierd**: 18-25ms
- **none-ls + prettierd**: 25-35ms
- **差**: 20-30%高速化

### 🎯 実装判断基準

#### conform + nvim-lint選択条件

- **軽量性重視**: 起動時間・メモリ使用量最小化
- **シンプル構成**: フォーマットとリンティング分離
- **保守性**: 各ツール独立管理

#### none-ls.nvim選択条件

- **機能性重視**: コードアクション・統合管理
- **既存資産**: null-ls設定の継続利用
- **複雑要件**: 高度なカスタマイズ

### 🚀 移行戦略

#### Phase 1: 軽量化（推奨）

1. **conform.nvim導入** → フォーマット専用
2. **nvim-lint導入** → リンティング専用
3. **none-ls削除** → 起動時間5ms削減

#### Phase 2: 統合管理（既存継続）

1. **none-ls.nvim移行** → null-ls互換
2. **設定調整** → debug無効化
3. **パフォーマンス監視** → 起動時間測定

## 🔌 Current Plugin Ecosystem (2025-07-06)

### Core Plugins (Always Loaded)

#### LSP & Development

- **nvim-lspconfig**: Core LSP infrastructure (startup: 3.17ms)
- **mason.nvim + mason-lspconfig.nvim**: Package management (startup: 50.69ms)
- **conform.nvim**: Modern formatting (startup: 1.02ms)
- **nvim-lint**: Linting system (startup: 1.68ms)
- **nvim-treesitter**: Syntax highlighting (startup: 3.89ms)

#### Editor Experience

- **mini.nvim ecosystem**: Comprehensive editing tools (13+ modules, startup: ~15ms total)
  - mini.pick: Fuzzy finder (replaces Telescope)
  - mini.clue: Key hint system
  - mini.animate: Smooth animations
- **blink.cmp**: Modern Rust-based completion engine (replaces mini.completion, startup: <1ms)
  - Built-in snippet support with friendly-snippets integration
  - Custom snippet directories support
- **flash.nvim**: Enhanced navigation (startup: 0.33ms)
- **mini.files**: File manager (replaces oil.nvim, better integration)

#### AI & Productivity

- **supermaven-nvim**: AI completion (loaded on InsertEnter)

#### UI & Theming

- **lualine.nvim**: Status line (startup: 5.62ms)
- **kanagawa.nvim**: Primary colorscheme
- **nvim-web-devicons**: Icon support

### Lazy-Loaded Plugins (On-Demand)

#### Git Integration

- **gitsigns.nvim**: Git signs and hunks
- **diffview.nvim**: Git diff viewer
- **vim-fugitive + vim-rhubarb**: Comprehensive Git operations
- **gitlinker.nvim**: GitHub/GitLab link generation

#### Language Support

- **markdown-preview.nvim**: Markdown preview
- **vim-prisma**: Prisma schema support
- **vim-rails + vim-rake**: Ruby/Rails support
- **jsgf.vim**: JavaScript/TypeScript enhancements

#### Utility & Diagnostics

- **trouble.nvim**: Diagnostics panel
- **ccc.nvim**: Color picker/converter
- **suda.vim**: Sudo file operations
- **vim-startuptime**: Performance profiling

### 🔄 2025 Plugin Optimization Status

#### Recent Improvements

1. **Replaced telescope.nvim** → **mini.pick** (reduced dependencies, faster startup)
2. **Migrated nvim-cmp** → **blink.cmp** (Rust-based, 80% faster completion)
3. **Removed mini.completion** → consolidated with blink.cmp for better performance
4. **Optimized LSP loading order** → prevents client/registerCapability errors
5. **Lazy-loaded non-essential plugins** → improved startup performance

#### Recommended Updates (Based on 2025 Ecosystem Analysis)

1. **gitlinker.nvim**: Update to linrongbin16/gitlinker.nvim fork (active maintenance)
2. **✅ mini.files migration**: Replaced oil.nvim with mini.files for better integration
3. **Treesitter async install**: Enable for faster cold-start
4. **LSP migration prep**: Start using vim.lsp.config() for new servers (Neovim 0.11+)

### 🚀 Performance Metrics

#### Plugin Loading Times (Startup Profile)

- **Total plugin overhead**: ~95ms (target achieved)
- **Heaviest plugins**: mason-lspconfig.nvim (48.63ms), lazy.nvim (10.57ms)
- **Optimization opportunities**: Further lazy-loading of mason components

#### Memory Usage

- **Core plugins**: Minimal memory footprint with mini.nvim ecosystem
- **Lazy-loaded plugins**: Zero impact until activated

## 💡 知見・教訓

### 成功パターン

- **lazy.nvim**: プラグイン管理の効率化と起動時間大幅短縮
  - 実績: 250ms → 95ms (62%削減)
  - 遅延読み込み: 25+プラグインで適用
  - イベント最適化: InsertEnter, BufReadPost, VeryLazy
- **LSP統合**: 15言語対応で開発効率向上
- **AI統合**: Copilot + Avante で開発速度2倍
- **重複削除**: コード重複30%削減、保守性向上
- **mini.nvim ecosystem**: 統合ツールセットによる一貫性向上
  - mini.pick: Telescope置き換えで依存関係削減
  - mini.files: oil.nvim置き換えで統合性向上
- **blink.cmp migration**: mini.completion → blink.cmp移行で大幅高速化
  - Rust実装による80%パフォーマンス向上
  - 統合スニペット管理で設定簡素化

### 失敗パターン

- **プラグイン過多**: 機能重複と起動時間増加
- **設定の複雑化**: Vimscript → Lua移行時の混乱
- **LSP設定不統一**: 言語毎の設定差異によるUX悪化
- **vim-illuminate → mini.cursorword移行**: より軽量な実装への移行成功
  - vim-illuminate: LSP/Tree-sitter統合だが重い（~40KB）
  - mini.cursorword: 単純なテキストマッチだが軽量（~5KB、150行）
  - 移行効果: レスポンス向上、設定簡素化

### AI統合教訓

- **Copilot**: インライン補完は高頻度使用、生産性向上明確
- **Avante**: 複雑なロジック説明・リファクタリング支援で威力発揮
- **バランス**: AI頼りすぎず、基礎スキル維持も重要

### Plugin Ecosystem 2025年戦略

- **mini.nvim統合**: 一貫性とパフォーマンスの両立
- **依存関係削減**: 大型プラグインから軽量代替への移行
- **遅延読み込み最適化**: 必要時のみプラグイン活性化
- **定期的見直し**: 年次でプラグイン生態系の評価・更新

## 🔗 関連層との連携

- **Shell Layer**: ターミナル統合、コマンド連携
- **Git Layer**: Git統合、差分表示、コミット支援
- **Performance Layer**: 起動時間測定、プロファイリング

---

_最終更新: 2025-07-11_
_パフォーマンス状態: 起動95ms達成 (blink.cmp移行効果)_
_AI統合状態: Copilot + Avante フル活用_
_補完システム: blink.cmp (80%高速化達成)_
