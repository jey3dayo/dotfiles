return {
  "nvim-tree/nvim-web-devicons",
  "JoosepAlviste/nvim-ts-context-commentstring",
  {
    "rcarriga/nvim-notify",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require "config/nvim-notify"
    end,
  },
  "j-hui/fidget.nvim",
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    run = ":TSUpdate",
    config = function()
      require "config/nvim-treesitter"
    end,
  },
  {
    "windwp/nvim-autopairs",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require "config/nvim-autopairs"
    end,
  },
  {
    "andymass/vim-matchup",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
    "nvim-treesitter/nvim-tree-docs",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      require "config/rainbow-delimeters"
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require "config/lualine"
    end,
  },
  {
    "RRethy/vim-illuminate",
    config = function()
      require "config/vim-illuminate"
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require "config/indent-blankline"
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require "config/gitsigns"
    end,
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require "config/nvim-colorizer"
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require "config/telescope"
    end,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
  },
  {
    "AckslD/nvim-neoclip.lua",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "kkharji/sqlite.lua",
    },
    config = function()
      require "config/neoclip"
    end,
  },
  {
    "dcampos/nvim-snippy",
    cmd = { "SnippyEdit", "SnippyReload" },
    config = function()
      require "config/nvim-snippy"
    end,
  },
  "honza/vim-snippets",
  {
    "ggandor/lightspeed.nvim",
    config = function()
      require "config/lightspeed"
    end,
  },
  "uga-rosa/ccc.nvim",
  {
    "j-hui/fidget.nvim",
    tag = "legacy",
    config = function()
      require "config/fidget"
    end,
  },
}
