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
    keys = {
      { "ga", "<Plug>(EasyAlign)", mode = "n", desc = "Easy Align" },
      { "ga", "<Plug>(EasyAlign)", mode = "x", desc = "Easy Align" },
    },
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
    config = true,
  },
  {
    "keaising/im-select.nvim",
    opts = require "config/im-select",
  },
  {
    "SUSTech-data/wildfire.nvim",
    opts = require "config/wildfire",
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
  {
    "Wansmer/treesj",
    keys = { "<space>m", "<space>j", "<space>s" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = require "config/treesj",
  },
}
