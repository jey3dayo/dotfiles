local deps = require "utils/dependencies"

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
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = deps.treesitter,
    opts = require "config/nvim-autopairs",
  },
  { "andymass/vim-matchup", dependencies = dependencies },
  { "nvim-treesitter/nvim-tree-docs", dependencies = dependencies },
  {
    "HiPhish/rainbow-delimiters.nvim",
    dependencies = deps.treesitter,
    config = function()
      require "config/rainbow-delimiters"
    end,
  },
}
