local deps = require "core.dependencies"

return {
  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    config = function()
      require("supermaven-nvim").setup {
        keymaps = {
          accept_suggestion = "<C-l>", -- keep <C-l> as explicit supermaven accept
          clear_suggestion = "<C-]>",
          accept_word = "<C-j>",
        },
        ignore_filetypes = { cpp = true },
        color = {
          suggestion_color = "#ffffff",
          cterm = 244,
        },
        disable_inline_completion = false,
        disable_keymaps = false, -- Keep Supermaven's keymaps for <C-l>, <C-]>, <C-j>
      }
    end,
  },
}
