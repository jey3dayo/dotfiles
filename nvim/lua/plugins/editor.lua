-- Editing stack built around mini.nvim plus a few focused helpers
-- Based on https://zenn.dev/kawarimidoll/books/6064bf6f193b51
local deps = require "core.dependencies"

local function setup(module, opts)
  return function()
    require(module).setup(opts)
  end
end

return {
  -- Extra utilities
  {
    "echasnovski/mini.misc",
    version = false,
    event = "VeryLazy",
    config = function()
      require("config/mini-misc").setup()
    end,
  },

  -- Visual helpers
  {
    "echasnovski/mini.indentscope",
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    config = setup("mini.indentscope", {
      symbol = "│",
      options = { try_as_border = true },
    }),
  },

  -- Input method switcher (disabled on WSL)
  {
    "keaising/im-select.nvim",
    cond = function()
      local ok, utils = pcall(require, "core.utils")
      if not ok then return false end
      return utils.get_os() ~= "wsl"
    end,
    event = "InsertEnter",
    opts = function()
      return require "config/im-select"
    end,
  },

  -- Extra utilities (required by many mini plugins)
  {
    "echasnovski/mini.extra",
    version = false,
    lazy = true,
  },

  -- Trailing whitespace
  {
    "echasnovski/mini.trailspace",
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("config/mini-trailspace").setup()
    end,
  },

  -- Highlight patterns (TODO, FIXME, etc.)
  {
    "echasnovski/mini.hipatterns",
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "echasnovski/mini.extra" },
    config = function()
      require("config/mini-hipatterns").setup()
    end,
  },

  -- Notifications
  -- mini.notify removed in favor of noice.nvim + nvim-notify

  -- Enhanced editing capabilities
  {
    "echasnovski/mini.ai",
    version = false,
    event = "VeryLazy",
    dependencies = { "echasnovski/mini.extra" },
    config = function()
      require("config/mini-ai").setup()
    end,
  },

  -- Auto pairs
  {
    "echasnovski/mini.pairs",
    version = false,
    event = "VeryLazy",
    config = setup "mini.pairs",
  },

  -- Surround operations
  {
    "echasnovski/mini.surround",
    version = false,
    keys = require("config/mini-surround").keys(),
    config = function()
      require("config/mini-surround").setup()
    end,
  },

  -- Auto tag handling for markup/JSX
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "xml", "tsx", "vue", "svelte", "astro" },
    dependencies = { deps.treesitter },
    opts = {},
  },

  -- File explorer
  {
    "echasnovski/mini.files",
    version = false,
    config = function()
      require("config/mini-files").setup()
    end,
  },

  -- Session management
  {
    "echasnovski/mini.sessions",
    version = false,
    lazy = false,
    config = function()
      require("config/mini-sessions").setup()
    end,
  },

  -- Buffer remove
  {
    "echasnovski/mini.bufremove",
    version = false,
    keys = {},
  },

  -- Comments
  {
    "echasnovski/mini.comment",
    version = false,
    event = "VeryLazy",
    dependencies = { deps.ts_context_commentstring },
    config = function()
      require("config/mini-comment").setup()
    end,
  },

  -- Fuzzy finder
  {
    "echasnovski/mini.pick",
    version = false,
    keys = require("config/mini-pick").keys(),
    dependencies = { "echasnovski/mini.extra" },
    config = function()
      require("config/mini-pick").setup()
    end,
  },

  -- Starter screen
  {
    "echasnovski/mini.starter",
    version = false,
    event = "VimEnter",
    config = setup "mini.starter",
  },

  -- Bracket mappings
  {
    "echasnovski/mini.bracketed",
    version = false,
    event = "VeryLazy",
    config = function()
      require("config/mini-bracketed").setup()
    end,
  },

  -- Flash search/motion
  {
    "folke/flash.nvim",
    enabled = true,
    event = "VeryLazy",
    keys = require("config/flash").keys(),
  },

  -- Better jumps
  {
    "echasnovski/mini.jump",
    version = false,
    event = "VeryLazy",
    config = setup "mini.jump",
  },

  -- Jump to any location
  {
    "echasnovski/mini.jump2d",
    version = false,
    keys = {
      { "<CR>", mode = { "n", "x", "o" } },
    },
    config = function()
      require("config/mini-jump2d").setup()
    end,
  },

  -- Visits tracking
  {
    "echasnovski/mini.visits",
    version = false,
    event = "VeryLazy",
    config = setup "mini.visits",
  },

  -- Key mapping hints and clues
  {
    "echasnovski/mini.clue",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.clue").setup(require "config/mini-clue")
    end,
  },

  -- Text alignment
  {
    "echasnovski/mini.align",
    version = false,
    event = "VeryLazy",
    config = setup "mini.align",
  },

  -- Animations
  {
    "echasnovski/mini.animate",
    version = false,
    event = "VeryLazy",
    config = setup "mini.animate",
  },

  -- Visual feedback for undo/redo operations
  {
    "y3owk1n/undo-glow.nvim",
    event = "VeryLazy",
    opts = require("config/undo-glow").opts(),
    config = function(_, opts)
      require("config/undo-glow").setup(opts)
    end,
  },

  -- Substitute operator with undo-glow integration
  {
    "gbprod/substitute.nvim",
    event = "VeryLazy",
    config = function()
      require("config/substitute").setup()
    end,
  },

  -- Yank history and register management
  {
    "gbprod/yanky.nvim",
    event = "VeryLazy",
    dependencies = { "kkharji/sqlite.lua" },
    opts = function()
      return require("config/yanky").opts()
    end,
    keys = require("config/yanky").keys(),
  },

  -- Text operators
  {
    "echasnovski/mini.operators",
    version = false,
    event = "VeryLazy",
    config = setup "mini.operators",
  },

  -- Split/Join (mini.splitjoin default keymaps, VeryLazy)
  {
    "echasnovski/mini.splitjoin",
    version = false,
    event = "VeryLazy",
    opts = {},
  },

  -- Fuzzy matching
  {
    "echasnovski/mini.fuzzy",
    version = false,
    lazy = true,
    config = setup "mini.fuzzy",
  },

  -- Enhanced increment/decrement (replacement for increment-activator)
  {
    "monaqa/dial.nvim",
    event = "VeryLazy",
    config = function()
      require "config/dial-config"
    end,
  },

  -- Tabline
  {
    "echasnovski/mini.tabline",
    version = false,
    event = "VeryLazy",
    config = setup "mini.tabline",
  },

  -- Modern completion engine (replaces mini.completion)
  {
    "saghen/blink.cmp",
    lazy = false,
    dependencies = "rafamadriz/friendly-snippets",
    version = "v1.*",
    config = function()
      require "config.blink-cmp-simple"
    end,
  },
}
