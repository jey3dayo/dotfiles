local deps = require "core.dependencies"

return {
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "JoosepAlviste/nvim-ts-context-commentstring", lazy = true },
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdate", "TSInstall" },
    dependencies = deps.treesitter_with_icons,
    opts = require "config/nvim-treesitter",
  },
  { "andymass/vim-matchup", event = { "BufReadPost", "BufNewFile" }, dependencies = deps.treesitter },
  { "nvim-treesitter/nvim-tree-docs", event = { "BufReadPost", "BufNewFile" }, dependencies = deps.treesitter },
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = deps.treesitter,
    config = function()
      require "config/rainbow-delimiters"
    end,
  },
}
