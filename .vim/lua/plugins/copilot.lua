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
    dependencies = { "zbirenbaum/copilot.lua", "nvim-lua/plenary.nvim" },
    branch = "main",
    build = "make tiktoken",
  },
}
