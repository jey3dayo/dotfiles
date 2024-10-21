return {
  {
    "tpope/vim-fugitive",
    cmd = { "Gdiffsplit", "Ggrep", "Gstatus", "Gwrite", "Gcommit" },
    config = function()
      require "config/vim-fugitive"
    end,
  },
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    opts = require "config/diffview",
  },
  { "tpope/vim-rhubarb", dependencies = { "tpope/vim-fugitive" } },
  { "vim-scripts/renamer.vim", cmd = "Renamer" },
  { "vim-scripts/sudo.vim", cmd = { "SudoWrite", "SudoRead" } },
  { "dstein64/vim-startuptime", cmd = "StartupTime" },
  {
    "windwp/nvim-projectconfig",
    opts = require "config/nvim-projectconfig",
  },
  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    keys = {
      {
        "<leader>x",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
    },
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = function()
      require "config/toggleterm"
    end,
  },
  {
    "sidebar-nvim/sidebar.nvim",
    opts = {},
  },
  {
    "ruifm/gitlinker.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      mappings = "<C-g>l",
    },
  },
}
