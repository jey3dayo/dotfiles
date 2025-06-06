local deps = require "utils/dependencies"

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = deps.plenary,
    config = function()
      require "config/telescope"
    end,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = deps.telescope,
  },
  {
    "nvim-telescope/telescope-frecency.nvim",
    dependencies = deps.telescope,
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
    dependencies = deps.telescope,
  },
}
