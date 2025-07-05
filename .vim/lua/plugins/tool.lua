return {
  { "vim-scripts/sudo.vim", cmd = { "SudoWrite", "SudoRead" } },
  { "dstein64/vim-startuptime", cmd = "StartupTime" },
  { "windwp/nvim-projectconfig", event = "VeryLazy", opts = require "config/nvim-projectconfig" },
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
    keys = { "<Leader>T", "<c-\\>" },
    cmd = "ToggleTerm",
    config = function()
      require "config/toggleterm"
    end,
  },
  {
    "sidebar-nvim/sidebar.nvim",
    cmd = { "SidebarNvimToggle", "SidebarNvimOpen", "SidebarNvimClose" },
    config = function()
      require "config/sidebar"
    end,
  },
}
