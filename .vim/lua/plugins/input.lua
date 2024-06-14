return {
  {
    "numToStr/Comment.nvim",
    opts = function()
      require "config/comment"
    end,
  },
  {
    "junegunn/vim-easy-align",
    cmd = { "EasyAlign" },
    opts = function()
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
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
    "keaising/im-select.nvim",
    opts = require "config/im-select",
  },
  {
    "gcmt/wildfire.vim",
    config = function()
      require "config/wildfire"
    end,
  },
  {
    "ggandor/lightspeed.nvim",
    enabled = false,
    config = true,
  },
  {
    "ggandor/leap.nvim",
    enabled = true,
    config = require "config/leap",
  },
  {
    "phaazon/hop.nvim",
    enabled = false,
    branch = "v2",
    config = require "config/hop",
  },
}
