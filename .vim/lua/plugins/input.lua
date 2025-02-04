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
  { "keaising/im-select.nvim", opts = require "config/im-select" },
  {
    "keaising/im-select.nvim",
    config = function()
      require("im_select").setup {
        default_im_select = "com.apple.keylayout.ABC",
        default_command = "/opt/homebrew/bin/im-select", -- フルパスを指定
        set_default_events = { "VimEnter", "InsertLeave", "CmdlineLeave" },
      }
    end,
  },
  {
    "SUSTech-data/wildfire.nvim",
    enabled = false,
    opts = require "config/wildfire",
  },
  { "ggandor/lightspeed.nvim", enabled = false, config = true },
  {
    "ggandor/leap.nvim",
    enabled = false,
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
    "folke/flash.nvim",
    enabled = true,
    event = "VeryLazy",
    keys = {
      { "t", mode = { "n", "x", "o" }, false },
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
  },
  {
    "Wansmer/treesj",
    keys = { "<space>m", "<space>j", "<space>s" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = require "config/treesj",
  },
}
