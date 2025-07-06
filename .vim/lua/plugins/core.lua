local deps = require "core.dependencies"

return {
  { "nvim-lua/plenary.nvim", lazy = true },
  { "kkharji/sqlite.lua", lazy = true },
  {
    "tpope/vim-repeat",
    event = "VeryLazy",
    config = function()
      require "config/vim-repeat"
    end,
  },
  { "kana/vim-textobj-user", event = "VeryLazy" },
  { "honza/vim-snippets", event = "InsertEnter" },
}
