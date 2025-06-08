return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
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
    dependencies = { "zbirenbaum/copilot.lua", "nvim-lua/plenary.nvim" },
    branch = "main",
    build = "make tiktoken",
  },
}
