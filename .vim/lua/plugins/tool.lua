return {
  {
    "lambdalisue/suda.vim",
    cmd = { "SudaRead", "SudaWrite" },
    init = function()
      -- Optional: Create aliases for backward compatibility
      vim.cmd([[command! -nargs=0 SudoWrite SudaWrite]])
      vim.cmd([[command! -nargs=0 SudoRead SudaRead]])
    end,
  },
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
}
