return {
  {
    "numToStr/Comment.nvim",
    opts = function()
      require "config/comment"
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
    config = true,
  },
  {
    "keaising/im-select.nvim",
    opts = require "config/im-select",
  },
  {
    "SUSTech-data/wildfire.nvim",
    enabled = false,
    opts = require "config/wildfire",
  },
  {
    "ggandor/lightspeed.nvim",
    enabled = true,
    config = true,
  },
  {
    "ggandor/leap.nvim",
    enabled = true,
    config = function()
      require "config/leap"
    end,
  },
  {
    "phaazon/hop.nvim",
    enabled = false,
    branch = "v2",
    config = function()
      require "config/hop"
    end,
  },
  {
    "Wansmer/treesj",
    keys = { "<space>m", "<space>j", "<space>s" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = require "config/treesj",
  },
}
