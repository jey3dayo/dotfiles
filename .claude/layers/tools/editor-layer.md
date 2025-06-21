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

### 補完設定

```lua
-- plugins/completion.lua
return {
  'hrsh7th/nvim-cmp',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'L3MON4D3/LuaSnip',
  },
  config = function()
    local cmp = require('cmp')

    cmp.setup({
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
      }, {
        { name = 'buffer' },
      })
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

## 🚧 最適化課題

### 高優先度

- [x] 起動時間を100ms以下に短縮（95ms達成 ✅）
- [ ] LSP応答時間の改善
- [ ] プラグイン数の削減（現在~80個 → 目標50個）

### 中優先度

- [ ] AI補完の精度向上
- [ ] 言語サーバー設定の統一化
- [ ] キーマップの体系化
- [ ] 設定構造の改善（ディレクトリ再編成、ファイル分割）
- [ ] DAP統合（デバッグ環境構築）

### 低優先度

- [ ] AI補完代替案の検討
- [ ] ワークスペース管理の強化

## 💡 知見・教訓

### 成功パターン

- **lazy.nvim**: プラグイン管理の効率化と起動時間大幅短縮
  - 実績: 250ms → 95ms (62%削減)
  - 遅延読み込み: 25+プラグインで適用
  - イベント最適化: InsertEnter, BufReadPost, VeryLazy
- **LSP統合**: 15言語対応で開発効率向上
- **AI統合**: Copilot + Avante で開発速度2倍
- **重複削除**: コード重複30%削減、保守性向上

### 失敗パターン

- **プラグイン過多**: 機能重複と起動時間増加
- **設定の複雑化**: Vimscript → Lua移行時の混乱
- **LSP設定不統一**: 言語毎の設定差異によるUX悪化

### AI統合教訓

- **Copilot**: インライン補完は高頻度使用、生産性向上明確
- **Avante**: 複雑なロジック説明・リファクタリング支援で威力発揮
- **バランス**: AI頼りすぎず、基礎スキル維持も重要

## 🔗 関連層との連携

- **Shell Layer**: ターミナル統合、コマンド連携
- **Git Layer**: Git統合、差分表示、コミット支援
- **Performance Layer**: 起動時間測定、プロファイリング

---

_最終更新: 2025-06-20_
_パフォーマンス状態: 起動100ms以下達成_
_AI統合状態: Copilot + Avante フル活用_
