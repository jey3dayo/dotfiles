local M = {}

-- Core dependencies used across multiple plugins
M.plenary = { "nvim-lua/plenary.nvim" }
M.treesitter = { "nvim-treesitter/nvim-treesitter" }
M.lspconfig = { "neovim/nvim-lspconfig" }
M.mini_icons = { "echasnovski/mini.icons" }
M.mason = { "williamboman/mason.nvim" }
M.fugitive = { "tpope/vim-fugitive" }
M.context_filetype = { "Shougo/context_filetype.vim" }
M.nui = { "MunifTanjim/nui.nvim" }

-- Combined dependencies for common use cases
M.treesitter_with_icons = {
  "echasnovski/mini.icons",
  "JoosepAlviste/nvim-ts-context-commentstring",
}

return M
