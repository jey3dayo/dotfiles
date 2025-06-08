local deps = require("utils/dependencies")

return {
  { "nvim-lua/plenary.nvim", lazy = true },
  { "kkharji/sqlite.lua", lazy = true },
  {
    "tpope/vim-repeat",
    event = "VeryLazy",
    config = function()
      require("config/vim-repeat")
    end,
  },
  { "kana/vim-textobj-user", event = "VeryLazy" },
  { "Shougo/context_filetype.vim", event = "VeryLazy" },
  { "kylechui/nvim-surround", event = "VeryLazy", config = true },
  { "osyo-manga/vim-precious", event = "VeryLazy", dependencies = deps.context_filetype },
  { "honza/vim-snippets", event = "InsertEnter" },
}
