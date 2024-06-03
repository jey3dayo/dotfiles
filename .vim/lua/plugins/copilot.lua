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
    -- FIXME: "zbirenbaum/copilot-cmp",
    "tris203/copilot-cmp",
    branch = "0.11_compat",
    dependencies = { "zbirenbaum/copilot.lua" },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = { "zbirenbaum/copilot.lua", "nvim-lua/plenary.nvim" },
    branch = "canary",
  },
}
