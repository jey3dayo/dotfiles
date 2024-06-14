return {
  "nvim-lua/plenary.nvim",
  "kkharji/sqlite.lua",
  {
    "tpope/vim-repeat",
    config = function()
      require "config/vim-repeat"
    end,
  },
  "kana/vim-textobj-user",
  "Shougo/context_filetype.vim",
  {
    "kylechui/nvim-surround",
    config = true,
  },
  {
    "osyo-manga/vim-precious",
    dependencies = { "Shougo/context_filetype.vim" },
  },
  "honza/vim-snippets",
}
