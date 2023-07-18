return {
  {
    "numToStr/Comment.nvim",
    config = function()
      require "config/comment"
    end,
  },
  {
    "junegunn/vim-easy-align",
    cmd = { "EasyAlign" },
    config = function()
      require "config/vim-easy-align"
    end,
  },
  {
    "nishigori/increment-activator",
    config = function()
      require "config/increment-activator-config"
    end,
  },
  "windwp/nvim-ts-autotag",
  {
    "keaising/im-select.nvim",
    config = function()
      require "config/im-select"
    end,
  },
}
