return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require "config/telescope"
    end,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
  },
  {
    "nvim-telescope/telescope-frecency.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    opts = {
      db_safe_mode = false,
    },
  },
  {
    "AckslD/nvim-neoclip.lua",
    dependencies = { "nvim-telescope/telescope.nvim", "kkharji/sqlite.lua" },
    opts = require "config/neoclip",
  },
  {
    "debugloop/telescope-undo.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
  },
}
