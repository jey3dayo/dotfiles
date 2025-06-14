# Neovim設定 知見・学習事項

## パフォーマンス最適化

### 起動時間最適化

#### lazy.nvim プラグイン管理
- **実装**: 遅延読み込みによるプラグイン管理
- **効果**: 必要時のみプラグイン読み込み
- **成果**: 起動時間 100ms 以下達成

#### 条件分岐による LSP 最適化
```lua
-- 言語別条件付きLSP起動
if vim.fn.executable('node') == 1 then
    require('lspconfig').tsserver.setup{}
end
```

#### ファイルタイプ別設定
- **実装**: autocmd による条件分岐
- **効果**: 不要な設定読み込み回避
- **パターン**:
```lua
vim.api.nvim_create_autocmd("FileType", {
    pattern = "lua",
    callback = function()
        -- Lua固有設定
    end,
})
```

## Lua設定パターン

### モジュラー設計
```lua
-- init.lua パターン
require('core.options')
require('core.keymaps')
require('core.autocmds')
require('plugins')
```

### プラグイン設定パターン
```lua
-- lazy.nvim 設定パターン
return {
    'plugin/name',
    event = 'VeryLazy',  -- 遅延読み込み
    config = function()
        require('plugin-name').setup({
            -- 設定内容
        })
    end,
}
```

### キーマップ設定
```lua
-- keymap パターン
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

keymap('n', '<leader>ff', ':Telescope find_files<CR>', opts)
```

## LSP統合

### LSP設定パターン
```lua
-- 共通LSP設定
local on_attach = function(client, bufnr)
    -- LSP共通キーマップ
    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
end

-- 各言語サーバー設定
require('lspconfig').lua_ls.setup({
    on_attach = on_attach,
    settings = {
        Lua = {
            diagnostics = {
                globals = {'vim'}
            }
        }
    }
})
```

### 対応言語一覧（15言語）
- **Web**: TypeScript, JavaScript, HTML, CSS
- **システム**: Rust, Go, Python, C/C++
- **設定**: Lua, YAML, JSON
- **シェル**: Bash, Zsh
- **マークアップ**: Markdown, LaTeX

## AI統合

### Copilot設定
```lua
-- Copilot パターン
return {
    'github/copilot.vim',
    event = 'InsertEnter',
    config = function()
        vim.g.copilot_no_tab_map = true
        vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', 
                      { expr = true, replace_keycodes = false })
    end,
}
```

### Avante統合
- **機能**: AI支援によるコード生成・説明
- **設定**: カスタムキーバインドと統合
- **用途**: コードレビュー、リファクタリング支援

## UI・テーマ設定

### カラースキーム統一
```lua
-- Gruvbox/Tokyo Night 統一パターン
return {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
        vim.cmd([[colorscheme tokyonight]])
    end,
}
```

### ステータスライン設定
- **lualine**: 軽量・高速なステータスライン
- **統合**: Git, LSP, ファイル情報の表示
- **テーマ**: 全体設計との統一

## 機能実装パターン

### ファイル検索・管理
```lua
-- Telescope設定パターン
return {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        require('telescope').setup({
            defaults = {
                file_ignore_patterns = { "node_modules", ".git" }
            }
        })
    end,
}
```

### Git統合
- **fugitive**: Git操作の統合
- **gitsigns**: Git差分表示
- **keymaps**: Zshとの一貫したGitワークフロー

### TreeSitter設定
```lua
-- TreeSitter パターン
return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
        require('nvim-treesitter.configs').setup({
            ensure_installed = {
                'lua', 'typescript', 'rust', 'go', 'python'
            },
            highlight = { enable = true },
        })
    end,
}
```

## デバッグ・トラブルシューティング

### パフォーマンス診断
```lua
-- 起動時間測定
nvim --startuptime startup.log

-- プラグイン統計
:Lazy profile
```

### LSP診断
```lua
-- LSP情報確認
:LspInfo

-- LSP ログ確認
:LspLog
```

### 設定リロード
```lua
-- 設定リロードパターン
vim.keymap.set('n', '<leader>r', ':source $MYVIMRC<CR>')
```

## よく使用するパターン

### autocmd パターン
```lua
-- autocmd グループパターン
local augroup = vim.api.nvim_create_augroup('MyGroup', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
    group = augroup,
    pattern = '*.lua',
    callback = function()
        -- Lua ファイル保存時処理
    end,
})
```

### 条件分岐パターン
```lua
-- OS別設定
if vim.fn.has('mac') == 1 then
    -- macOS 固有設定
elseif vim.fn.has('unix') == 1 then
    -- Linux 固有設定
end
```

## 学習した回避すべきパターン

### アンチパターン
1. **全プラグイン同期読み込み**: 起動時間増加
2. **重複LSP設定**: メモリ使用量増加
3. **グローバル設定の濫用**: 名前空間汚染
4. **未使用プラグイン**: リソース浪費

### 改善済み問題
- **vim script から Lua 移行**: パフォーマンス向上
- **プラグイン整理**: 必要最小限に絞り込み
- **LSP設定統一**: 共通設定の分離

## パフォーマンス指標

### 現在の状況
- **起動時間**: 100ms 以下
- **LSP対応言語**: 15言語
- **プラグイン数**: 最適化済み
- **メモリ使用量**: 軽量化達成

### ベンチマーク履歴
- **2025-06-08**: 大規模リファクタリング完了
- **成果**: 起動100ms以下、15言語LSP対応

## 将来の改善計画

### 検討中の機能
- **DAP統合**: デバッガー統合の拡充
- **テスト統合**: より強力なテストサポート
- **AI機能拡張**: より高度なAI支援機能

---

*Last Updated: 2025-06-14*
*Status: 安定稼働中・継続改善*