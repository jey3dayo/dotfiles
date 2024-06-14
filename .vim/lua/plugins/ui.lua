return {
  "nvim-lua/popup.nvim",
  "nvim-tree/nvim-web-devicons",
  "JoosepAlviste/nvim-ts-context-commentstring",
  {
    "rcarriga/nvim-notify",
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
    cmd = { "Trouble" },
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
    "dcampos/nvim-snippy",
    cmd = { "SnippyEdit", "SnippyReload" },
    config = function()
      require "config/nvim-snippy"
    end,
  },
  "uga-rosa/ccc.nvim",
  "hrsh7th/nvim-insx",
  {
    "j-hui/fidget.nvim",
    tag = "legacy",
    config = function()
      require "config/fidget"
    end,
  },
  {
    "ggandor/lightspeed.nvim",
    enabled = false,
    config = function()
      require "config/lightspeed"
    end,
  },
  {
    "ggandor/leap.nvim",
    enabled = false,
    config = function()
      require "config/leap"
    end,
  },
  {
    "phaazon/hop.nvim",
    enabled = true,
    branch = "v2",
    config = function()
      require "config/hop"
    end,
  },
  {
    "gcmt/wildfire.vim",
    config = function()
      require "config/wildfire"
    end,
  },
}
