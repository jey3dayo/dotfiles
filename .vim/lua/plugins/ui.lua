return {
  "nvim-lua/popup.nvim",
  {
    "rcarriga/nvim-notify",
    config = require "config/nvim-notify",
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
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require "config/indent-blankline"
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
