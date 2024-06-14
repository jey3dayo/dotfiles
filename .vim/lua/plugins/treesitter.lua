local dependencies = { "nvim-treesitter/nvim-treesitter" }

return {
  "nvim-tree/nvim-web-devicons",
  "JoosepAlviste/nvim-ts-context-commentstring",
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    opts = require "config/nvim-treesitter",
  },
  {
    "windwp/nvim-autopairs",
    dependencies = dependencies,
    opts = require "config/nvim-autopairs",
  },
  {
    "andymass/vim-matchup",
    dependencies = dependencies,
  },
  {
    "nvim-treesitter/nvim-tree-docs",
    dependencies = dependencies,
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    dependencies = dependencies,
    config = function()
      require "config/rainbow-delimeters"
    end,
  },
}
