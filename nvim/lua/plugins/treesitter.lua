local deps = require "core.dependencies"

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    dependencies = { deps.ts_context_commentstring },
    config = function()
      require("config.nvim-treesitter").setup()
    end,
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    dependencies = { deps.treesitter },
    opts = { enable_autocmd = false },
    config = function(_, opts)
      require("ts_context_commentstring").setup(opts)
    end,
  },
  {
    "andymass/vim-matchup",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { deps.treesitter },
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { deps.treesitter },
    config = function()
      require "config/rainbow-delimiters"
    end,
  },
}
