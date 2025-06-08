local deps = require("utils/dependencies")

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
    },
    dependencies = deps.plenary,
    config = function()
      require("config/telescope")
    end,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    keys = { "<Leader>e", "<Leader>E" },
    dependencies = deps.telescope,
  },
  {
    "nvim-telescope/telescope-frecency.nvim",
    keys = { "<Leader>f", "<Leader>F", "<A-p>" },
    dependencies = deps.telescope,
    opts = {
      db_safe_mode = false,
    },
  },
  {
    "AckslD/nvim-neoclip.lua",
    keys = { "<Leader>Y" },
    dependencies = { "nvim-telescope/telescope.nvim", "kkharji/sqlite.lua" },
    opts = require("config/neoclip"),
  },
  {
    "debugloop/telescope-undo.nvim",
    keys = { "<Leader>u" },
    dependencies = deps.telescope,
  },
}
