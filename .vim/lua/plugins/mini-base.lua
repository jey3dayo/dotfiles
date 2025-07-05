-- Mini.nvim base configuration
-- Essential mini modules that should load early
return {
  -- Icons support (required by many mini modules)
  {
    "echasnovski/mini.icons",
    version = false,
    lazy = false,
    priority = 1000,
    config = function()
      require("mini.icons").setup {
        style = vim.fn.has "nvim-0.10" == 1 and "glyph" or "ascii",
      }
    end,
  },

  -- Extra utilities
  {
    "echasnovski/mini.extra",
    version = false,
    lazy = true, -- Will be loaded by other modules
  },

  -- Fuzzy matching
  {
    "echasnovski/mini.fuzzy",
    version = false,
    lazy = true, -- Will be loaded by other modules
  },
  -- Align text
  {
    "echasnovski/mini.align",
    version = false,
    keys = {
      { "ga", mode = { "n", "v" } },
      { "gA", mode = { "n", "v" } },
    },
    config = function()
      require("mini.align").setup()
    end,
  },

  -- Operators
  {
    "echasnovski/mini.operators",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.operators").setup {
        -- Each operator has separate configuration
        evaluate = {
          prefix = "g=",
        },
        exchange = {
          prefix = "gx",
        },
        multiply = {
          prefix = "gm",
        },
        replace = {
          prefix = "gr",
        },
        sort = {
          prefix = "gs",
        },
      }
    end,
  },

  -- Test runner
  {
    "echasnovski/mini.test",
    version = false,
    cmd = { "MiniTest", "MiniTestRun" },
    config = function()
      require("mini.test").setup()
    end,
  },

  -- Documentation generator
  {
    "echasnovski/mini.doc",
    version = false,
    cmd = { "MiniDoc" },
    config = function()
      require("mini.doc").setup()
    end,
  },

  -- Clue (key hints)
  {
    "echasnovski/mini.clue",
    version = false,
    event = "VeryLazy",
    config = function()
      local miniclue = require "mini.clue"
      miniclue.setup {
        triggers = {
          -- Leader triggers
          { mode = "n", keys = "<Leader>" },
          { mode = "x", keys = "<Leader>" },

          -- Built-in completion
          { mode = "i", keys = "<C-x>" },

          -- `g` key
          { mode = "n", keys = "g" },
          { mode = "x", keys = "g" },

          -- Marks
          { mode = "n", keys = "'" },
          { mode = "n", keys = "`" },
          { mode = "x", keys = "'" },
          { mode = "x", keys = "`" },

          -- Registers
          { mode = "n", keys = '"' },
          { mode = "x", keys = '"' },
          { mode = "i", keys = "<C-r>" },
          { mode = "c", keys = "<C-r>" },

          -- Window commands
          { mode = "n", keys = "<C-w>" },

          -- `z` key
          { mode = "n", keys = "z" },
          { mode = "x", keys = "z" },

          -- Mini.surround
          { mode = "n", keys = "s" },
          { mode = "x", keys = "s" },
        },

        clues = {
          -- Enhance this list with your actual mappings
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),
        },

        window = {
          delay = 500,
          config = {
            width = "auto",
            border = "rounded",
          },
        },
      }
    end,
  },

  -- Tab line
  {
    "echasnovski/mini.tabline",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.tabline").setup {
        show_icons = vim.g.have_nerd_font,
        set_vim_settings = true,
        tabpage_section = "left",
      }
    end,
  },

  -- Animations
  {
    "echasnovski/mini.animate",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.animate").setup {
        cursor = {
          enable = true,
          timing = require("mini.animate").gen_timing.linear { duration = 150, unit = "total" },
        },
        scroll = {
          enable = true,
          timing = require("mini.animate").gen_timing.linear { duration = 150, unit = "total" },
        },
        resize = {
          enable = true,
          timing = require("mini.animate").gen_timing.linear { duration = 100, unit = "total" },
        },
        open = {
          enable = false,
        },
        close = {
          enable = false,
        },
      }
    end,
  },
}
