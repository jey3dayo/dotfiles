local M = {}

-- Core dependencies used across multiple plugins
M.plenary = { "nvim-lua/plenary.nvim" }
M.treesitter = { "nvim-treesitter/nvim-treesitter" }
M.cmp = { "hrsh7th/nvim-cmp" }
M.lspconfig = { "neovim/nvim-lspconfig" }
M.telescope = { "nvim-telescope/telescope.nvim" }
M.web_devicons = { "nvim-tree/nvim-web-devicons" }

-- Combined dependencies for common use cases
M.treesitter_with_icons = {
  "nvim-tree/nvim-web-devicons",
  "JoosepAlviste/nvim-ts-context-commentstring",
}

return M