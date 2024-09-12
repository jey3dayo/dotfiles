return {
  "nvim-lua/popup.nvim",
  {
    "rcarriga/nvim-notify",
    config = function()
      require "config/nvim-notify"
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require "config/lualine"
    end,
  },
  {
    "RRethy/vim-illuminate",
    config = function()
      require "config/vim-illuminate"
    end,
  },
  {
    "shellRaining/hlchunk.nvim",
    enabled = true,
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require "config/hlchunk"
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = require "config/gitsigns",
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = true,
  },
  "uga-rosa/ccc.nvim",
  "hrsh7th/nvim-insx",
  {
    "j-hui/fidget.nvim",
    tag = "legacy",
    config = true,
  },
}
