return {
  "nvim-lua/plenary.nvim",
  "kkharji/sqlite.lua",
  {
    "tpope/vim-repeat",
    event = "VeryLazy",
    config = function()
      require "config/vim-repeat"
    end,
  },
  { "kana/vim-textobj-user", event = "VeryLazy" },
  { "Shougo/context_filetype.vim", event = "VeryLazy" },
  { "kylechui/nvim-surround", event = "VeryLazy", config = true },
  { "osyo-manga/vim-precious", event = "VeryLazy", dependencies = { "Shougo/context_filetype.vim" } },
  { "honza/vim-snippets", event = "InsertEnter" },
}
