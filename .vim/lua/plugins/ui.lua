return {
  "nvim-tree/nvim-web-devicons",
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("config/nvim-treesitter")
    end,
  },
  {
    "windwp/nvim-autopairs",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("config/nvim-autopairs")
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("config/nvim-ts-autotag")
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("config/lualine")
    end,
  },
  {
    "nathanaelkane/vim-indent-guides",
    config = function()
      vim.cmd([[ source ~/.config/nvim/plugins/vim-indent-guides.rc.vim ]])
    end,
  },
  {
    "kien/rainbow_parentheses.vim",
    config = function()
      vim.cmd([[ source ~/.config/nvim/plugins/rainbow_parentheses.rc.vim ]])
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("config/gitsigns")
    end,
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("config/nvim-colorizer")
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-file-browser.nvim",
    },
    config = function()
      require("config/telescope")
    end,
  },
  "nvim-telescope/telescope-file-browser.nvim",
  {
    "hrsh7th/vim-vsnip",
    event = { "InsertEnter" },
    dependencies = {
      "hrsh7th/vim-vsnip-integ",
      "rafamadriz/friendly-snippets"
    },
    config = function()
      vim.cmd([[ source ~/.config/nvim/plugins/vsnip.rc.vim ]])
    end,
  },
  "hrsh7th/vim-vsnip-integ",
  "rafamadriz/friendly-snippets",
}