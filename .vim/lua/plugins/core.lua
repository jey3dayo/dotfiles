return {
  "nvim-lua/popup.nvim",
  "nvim-lua/plenary.nvim",
  "kkharji/sqlite.lua",
  {
    "tpope/vim-repeat",
    config = function()
      require "config/vim-repeat"
    end,
  },
}
