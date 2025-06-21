local deps = require "core.dependencies"

return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    ft = { "javascript", "typescript", "lua", "python", "go", "rust", "c", "cpp" },
    config = function()
      require "config/copilot"
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    cmd = { "CopilotChat", "CopilotChatBuffer", "CopilotChatToggle" },
    keys = {
      { "<leader>cc", "<cmd>CopilotChat<cr>", desc = "CopilotChat" },
      { "<leader>cb", "<cmd>CopilotChatBuffer<cr>", desc = "CopilotChat Buffer" },
      { "<leader>ct", "<cmd>CopilotChatToggle<cr>", desc = "CopilotChat Toggle" },
    },
    dependencies = vim.list_extend(deps.copilot, deps.plenary),
    branch = "main",
    build = "make tiktoken",
  },
  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<Tab>",
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
      })
    end,
  },
}
