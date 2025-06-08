local deps = require("core.dependencies")

return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("config/copilot")
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
}
