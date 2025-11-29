local deps = require "core.dependencies"

return {
  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    config = function()
      require("supermaven-nvim").setup {
        keymaps = {
          accept_suggestion = "<C-l>", -- avoid blink.cmp <Tab> and keep muscle memory near <C-j>
          clear_suggestion = "<C-]>",
          accept_word = "<C-j>",
        },
        ignore_filetypes = { cpp = true },
        color = {
          suggestion_color = "#ffffff",
          cterm = 244,
        },
        disable_inline_completion = false,
        disable_keymaps = false,
      }
    end,
  },
}
