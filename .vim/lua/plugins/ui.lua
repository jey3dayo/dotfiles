return {
  "nvim-lua/popup.nvim",
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
    config = true,
    opts = require "config/hlchunk",
  },
  { "lewis6991/gitsigns.nvim", opts = require "config/gitsigns" },
  { "norcalli/nvim-colorizer.lua", config = true },
  "uga-rosa/ccc.nvim",
  { "j-hui/fidget.nvim", tag = "legacy", config = true },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = require "config/noice",
    config = true,
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
  },
  { "stevearc/dressing.nvim", opts = {} },
}
