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

  -- Picker
  {
    "echasnovski/mini.pick",
    version = false,
    config = function()
      require("mini.pick").setup {
        options = {
          use_cache = true,
        },
        window = {
          config = {
            border = "rounded",
          },
        },
      }

      -- Set as vim.ui.select for other plugins
      vim.ui.select = require("mini.pick").ui_select

      -- Load mini.pick keymaps
      require "config/mini-pick"
    end,
  },

  -- Completion
  {
    "echasnovski/mini.completion",
    version = false,
    event = "InsertEnter",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      require "config/mini-completion"
    end,
  },

  -- Snippets (replaces nvim-snippy)
  {
    "echasnovski/mini.snippets",
    version = false,
    event = "InsertEnter",
    config = function()
      require("mini.snippets").setup {
        expand = {
          -- Use <Tab> to expand snippets
          trigger = "<Tab>",
        },
        interact = {
          -- Use <Tab>/<S-Tab> to navigate
          jump = { forward = "<Tab>", backward = "<S-Tab>" },
        },
      }
    end,
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

          -- Settings prefix
          { mode = "n", keys = "<Leader>s" },
          { mode = "x", keys = "<Leader>s" },

          -- Yank prefix
          { mode = "n", keys = "Y" },
          { mode = "x", keys = "Y" },

          -- Format prefix
          { mode = "n", keys = "<C-e>" },
          { mode = "x", keys = "<C-e>" },

          -- Git prefix
          { mode = "n", keys = "<C-g>" },
          { mode = "x", keys = "<C-g>" },

          -- Terminal prefix
          { mode = "n", keys = "<C-t>" },
          { mode = "x", keys = "<C-t>" },

          -- LSP navigation prefix
          { mode = "n", keys = "t" },
          { mode = "x", keys = "t" },

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

          -- Custom leader key descriptions
          { mode = "n", keys = "<Leader>s", desc = "Settings" },
          { mode = "n", keys = "<Leader>f", desc = "Find" },
          { mode = "n", keys = "<Leader>b", desc = "Buffer" },
          { mode = "n", keys = "Y", desc = "Yank" },
          { mode = "n", keys = "<C-e>", desc = "LSP/Format" },
          { mode = "n", keys = "<C-g>", desc = "Git" },
          { mode = "n", keys = "<C-t>", desc = "Tab" },
          { mode = "n", keys = "t", desc = "LSP Navigate" },

          -- Individual settings descriptions
          { mode = "n", keys = "<Leader>sn", desc = "Toggle line numbers" },
          { mode = "n", keys = "<Leader>sl", desc = "Toggle list mode" },
          { mode = "n", keys = "<Leader>sp", desc = "Plugin manager" },
          { mode = "n", keys = "<Leader>sd", desc = "LspDebug" },
          { mode = "n", keys = "<Leader>sm", desc = "Update Mason" },
          { mode = "n", keys = "<Leader>st", desc = "Update TreeSitter" },
          { mode = "n", keys = "<Leader>su", desc = "Update plugins" },
          { mode = "n", keys = "<Leader>so", desc = "Source init.lua" },
          { mode = "n", keys = "<Leader>sO", desc = "Source current buffer" },

          -- Format keymaps (LSP keymaps get descriptions from vim.keymap.set directly)
          { mode = "n", keys = "<C-e>b", desc = "Format with Biome" },
          { mode = "n", keys = "<C-e>e", desc = "Format with ESLint" },
          { mode = "n", keys = "<C-e>f", desc = "Format (auto-select)" },
          { mode = "n", keys = "<C-e>p", desc = "Format with Prettier" },
          { mode = "n", keys = "<C-e>s", desc = "Format with TypeScript" },
        },

        window = {
          delay = 500,
          config = {
            width = "auto",
            border = "rounded",
          },
        },
      }

      -- Force descriptions for keymaps that might be overridden
      vim.schedule(function()
        miniclue.set_mapping_desc("n", "<Leader>so", "Source init.lua")
        miniclue.set_mapping_desc("n", "<Leader>sO", "Source current buffer")

        -- Set all <C-e> descriptions centrally to avoid conflicts

        -- Force Format keymap descriptions only (LSP descriptions set in keymaps directly)
        local format_descriptions = {
          ["<C-e>b"] = "Format with Biome", 
          ["<C-e>e"] = "Format with ESLint",
          ["<C-e>f"] = "Format (auto-select)",
          ["<C-e>p"] = "Format with Prettier",
          ["<C-e>s"] = "Format with TypeScript",
        }
        
        for lhs, desc in pairs(format_descriptions) do
          miniclue.set_mapping_desc("n", lhs, desc)
        end
      end)
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
