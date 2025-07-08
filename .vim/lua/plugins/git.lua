local deps = require "core.dependencies"

return {
  -- Keep fugitive for specific commands like :Gblame, :Gdiffsplit
  {
    "tpope/vim-fugitive",
    cmd = { "Gdiffsplit", "Gblame", "Ggrep", "Gbrowse" },
    config = function()
      require "config/vim-fugitive"
    end,
  },
  {
    "sindrets/diffview.nvim",
    dependencies = deps.plenary,
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
    },
    opts = require "config/diffview",
  },
  { "tpope/vim-rhubarb", cmd = { "GBrowse" }, dependencies = { "tpope/vim-fugitive" } },
  { "linrongbin16/gitlinker.nvim", keys = {}, dependencies = deps.plenary, config = true },
  -- Modern Git interface
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "echasnovski/mini.pick", -- Use mini.pick instead of telescope
    },
    config = true,
    cmd = "Neogit",
    keys = {
      -- Main neogit interface
      { "<C-g><C-g>", "<cmd>Neogit<cr>", desc = "Neogit Status" },
      { "<C-g>s", "<cmd>Neogit<cr>", desc = "Neogit Status" },
      
      -- Commit workflow
      { "<C-g>c", "<cmd>Neogit commit<cr>", desc = "Neogit Commit" },
      { "<C-g>a", "<cmd>Neogit<cr>", desc = "Stage All (use 's' in Neogit)" },
      
      -- Push/Pull removed for safety - use manual commands
      
      -- Branch operations (simplified)
      { "<C-g>b", "<cmd>Neogit<cr>", desc = "Git Branches (use 'b' in Neogit)" },
      
      -- Log and history (simplified)
      { "<C-g>l", "<cmd>Neogit<cr>", desc = "Git Log (use 'l' in Neogit)" },
      
      -- Diff operations  
      { "<C-g>d", "<cmd>DiffviewOpen<cr>", desc = "Diff View" },
      { "<C-g>D", "<cmd>DiffviewClose<cr>", desc = "Close Diff" },
      
      -- Stash operations (simplified)
      { "<C-g>z", "<cmd>Neogit<cr>", desc = "Git Stash (use 'Z' in Neogit)" },
      
      -- Quick actions (legacy leader mappings for compatibility)
      { "<leader>gs", "<cmd>Neogit<cr>", desc = "Neogit Status" },
      { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Neogit Commit" },
    },
  },
}
