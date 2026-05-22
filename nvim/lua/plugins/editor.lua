-- Editing stack built around mini.nvim plus a few focused helpers
-- Based on https://zenn.dev/kawarimidoll/books/6064bf6f193b51
local deps = require "core.dependencies"

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
    config = function()
      require("mini.indentscope").setup {
        symbol = "│",
        options = { try_as_border = true },
      }
    end,
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
    config = function()
      require("mini.pairs").setup()
    end,
  },

  -- Surround operations
  {
    "echasnovski/mini.surround",
    version = false,
    keys = {
      { "sa", mode = { "n", "v" } },
      { "sd", mode = { "n", "v" } },
      { "sf", mode = { "n", "v" } },
      { "sF", mode = { "n", "v" } },
      { "sh", mode = { "n", "v" } },
      { "sr", mode = { "n", "v" } },
      { "sn", mode = { "n", "v" } },
    },
    config = function()
      require("mini.surround").setup {
        mappings = {
          add = "sa",
          delete = "sd",
          find = "sf",
          find_left = "sF",
          highlight = "sh",
          replace = "sr",
          update_n_lines = "sn",
        },
      }
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
      require("mini.comment").setup {
        options = {
          custom_commentstring = function()
            return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
          end,
        },
      }
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
    config = function()
      require("mini.starter").setup()
    end,
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
    keys = {
      { "t", mode = { "n", "x", "o" }, false },
      -- Note: 's' key is managed by undo-glow.flash_jump() for highlight integration
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

  -- Better jumps
  {
    "echasnovski/mini.jump",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.jump").setup()
    end,
  },

  -- Jump to any location
  {
    "echasnovski/mini.jump2d",
    version = false,
    keys = {
      { "<CR>", mode = { "n", "x", "o" } },
    },
    config = function()
      require("mini.jump2d").setup {
        spotter = require("mini.jump2d").builtin_opts.single_character.spotter,
        mappings = {
          start_jumping = "<CR>",
        },
      }
    end,
  },

  -- Visits tracking
  {
    "echasnovski/mini.visits",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.visits").setup()
    end,
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
    config = function()
      require("mini.align").setup()
    end,
  },

  -- Animations
  {
    "echasnovski/mini.animate",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.animate").setup()
    end,
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
    config = function()
      require("mini.operators").setup()
    end,
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
    config = function()
      require("mini.fuzzy").setup()
    end,
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
    config = function()
      require("mini.tabline").setup()
    end,
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
