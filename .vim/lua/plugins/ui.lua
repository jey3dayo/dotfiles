return {
  { "nvim-lua/popup.nvim", lazy = true },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      require("config/lualine")
    end,
  },
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("config/vim-illuminate")
    end,
  },
  {
    "shellRaining/hlchunk.nvim",
    enabled = true,
    event = { "BufReadPre", "BufNewFile" },
    opts = require("config/hlchunk"),
  },
  { "lewis6991/gitsigns.nvim", event = { "BufReadPre", "BufNewFile" }, opts = require("config/gitsigns") },
  { "norcalli/nvim-colorizer.lua", event = { "BufReadPost", "BufNewFile" }, opts = {} },
  { "uga-rosa/ccc.nvim", cmd = { "CccPick", "CccConvert", "CccHighlighterToggle" } },
  { "j-hui/fidget.nvim", event = "LspAttach", tag = "legacy", opts = {} },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = require("config/noice"),
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
  },
  { "stevearc/dressing.nvim", event = "VeryLazy", opts = {} },
}
