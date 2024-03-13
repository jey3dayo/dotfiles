return {
  "editorconfig/editorconfig-vim",
  "kana/vim-textobj-user",
  "Shougo/context_filetype.vim",
  {
    "kylechui/nvim-surround",
    config = function()
      require "config/nvim-surround"
    end,
  },
  {
    "osyo-manga/vim-precious",
    dependencies = { "Shougo/context_filetype.vim" },
  },
}
