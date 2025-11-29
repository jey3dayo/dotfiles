local M = {}

-- Core dependencies used across multiple plugins
M.plenary = { "nvim-lua/plenary.nvim", lazy = true }
-- Archived upstream: guard install so config degrades gracefully if unavailable
M.sqlite = {
  "kkharji/sqlite.lua",
  lazy = true,
  cond = function()
    return vim.fn.executable "sqlite3" == 1 and not vim.g.disable_sqlite
  end,
}
M.devicons = { "nvim-tree/nvim-web-devicons", lazy = true }
M.icons = { "echasnovski/mini.icons", version = false, lazy = true }

M.treesitter = { "nvim-treesitter/nvim-treesitter" }
M.ts_context_commentstring = { "JoosepAlviste/nvim-ts-context-commentstring" }

M.lspconfig = { "neovim/nvim-lspconfig" }
M.mason = { "williamboman/mason.nvim" }
M.fugitive = { "tpope/vim-fugitive" }
M.nui = { "MunifTanjim/nui.nvim" }

return M
