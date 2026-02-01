local deps = require "core.dependencies"

return {
  -- Notifications and UI polish
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = false,
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
      },
    },
    dependencies = {
      deps.nui,
      "rcarriga/nvim-notify",
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { deps.devicons },
    config = function()
      require "config/lualine"
    end,
  },
  {
    "echasnovski/mini.cursorword",
    version = false,
    event = "VeryLazy",
    opts = { delay = 100 },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = require "config/gitsigns",
  },
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {},
  },
}
