local M = {}

-- Core dependencies used across multiple plugins
M.plenary = { "nvim-lua/plenary.nvim", lazy = true }
M.sqlite = { "kkharji/sqlite.lua", lazy = true }
M.devicons = { "nvim-tree/nvim-web-devicons", lazy = true }
M.icons = { "echasnovski/mini.icons", version = false, lazy = true }

M.treesitter = { "nvim-treesitter/nvim-treesitter" }
M.ts_context_commentstring = { "JoosepAlviste/nvim-ts-context-commentstring" }

M.lspconfig = { "neovim/nvim-lspconfig" }
M.mason = { "williamboman/mason.nvim" }
M.fugitive = { "tpope/vim-fugitive" }
M.nui = { "MunifTanjim/nui.nvim" }

return M
