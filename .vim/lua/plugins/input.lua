return {
  {
    "numToStr/Comment.nvim",
    keys = { "gc", "gb", { "gc", mode = "v" }, { "gb", mode = "v" } },
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    opts = require("config/comment"),
  },
  {
    "nishigori/increment-activator",
    keys = { "<C-a>", "<C-x>" },
    config = function()
      require("config/increment-activator-config")
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "xml", "tsx", "vue", "svelte", "astro" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },
  {
    "keaising/im-select.nvim",
    event = "InsertEnter",
    config = function()
      require("config/im-select")
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
    opts = require("config/treesj"),
  },
}
