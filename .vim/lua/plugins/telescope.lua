local deps = require "core.dependencies"

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = deps.plenary,
    config = function()
      require "config/telescope"
    end,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    keys = { "<Leader>e", "<Leader>E" },
    dependencies = deps.telescope,
  },
  {
    "nvim-telescope/telescope-frecency.nvim",
    keys = {
      {
        "<Leader>f",
        function()
          require("telescope").extensions.frecency.frecency { workspace = "CWD" }
        end,
        desc = "Find CWD by frecency",
      },
      {
        "<Leader>F",
        function()
          local buffer_dir = vim.fn.expand "%:p:h"
          require("telescope.builtin").find_files {
            cwd = buffer_dir,
            prompt_title = "Files (Buffer Dir)",
            hidden = true,
          }
        end,
        desc = "Find files in buffer dir",
      },
      {
        "<A-p>",
        function()
          require("telescope").extensions.frecency.frecency { workspace = "CWD" }
        end,
        desc = "Find CWD by frecency",
      },
    },
    dependencies = deps.telescope,
    opts = {
      db_safe_mode = false,
    },
  },
  {
    "AckslD/nvim-neoclip.lua",
    keys = { "<Leader>Y" },
    dependencies = { "nvim-telescope/telescope.nvim", "kkharji/sqlite.lua" },
    opts = require "config/neoclip",
  },
  {
    "debugloop/telescope-undo.nvim",
    keys = { "<Leader>u" },
    dependencies = deps.telescope,
  },
}
