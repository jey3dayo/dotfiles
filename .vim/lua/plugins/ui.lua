return {
  "nvim-tree/nvim-web-devicons",
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
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
    config = function()
      require "config/vim-matchup"
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require "config/nvim-ts-autotag"
    end,
  },
  {
    "p00f/nvim-ts-rainbow",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require "config/lualine"
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
    "dcampos/nvim-snippy",
    cmd = { "SnippyEdit", "SnippyReload" },
    config = function()
      require "config/nvim-snippy"
    end,
  },
  "honza/vim-snippets",
}
