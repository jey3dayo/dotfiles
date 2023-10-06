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
  {
  "windwp/nvim-ts-autotag",
    config = function()
      require "config/nvim-ts-autotag"
    end,
  },
  {
    "keaising/im-select.nvim",
    config = function()
      require "config/im-select"
    end,
  },
}
