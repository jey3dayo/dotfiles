-- Mini.nvim ecosystem configuration
-- Based on https://zenn.dev/kawarimidoll/books/6064bf6f193b51
return {
  -- Extra utilities
  {
    "echasnovski/mini.misc",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.misc").setup()
      require("mini.misc").setup_restore_cursor() -- Restore cursor position

      -- Zoom functionality
      vim.api.nvim_create_user_command("Zoom", function()
        require("mini.misc").zoom(0, {})
      end, { desc = "Toggle window zoom" })
      vim.keymap.set("n", "<leader>z", function()
        require("mini.misc").zoom(0, {})
      end, { desc = "Toggle window zoom" })
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

  -- Trailing whitespace
  {
    "echasnovski/mini.trailspace",
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("mini.trailspace").setup()
      vim.api.nvim_create_user_command("TrimWhitespace", function()
        require("mini.trailspace").trim()
        require("mini.trailspace").trim_last_lines()
      end, { desc = "Trim trailing whitespace" })
    end,
  },

  -- Highlight patterns (TODO, FIXME, etc.)
  {
    "echasnovski/mini.hipatterns",
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "echasnovski/mini.extra" },
    config = function()
      local hipatterns = require "mini.hipatterns"
      local hi_words = require("mini.extra").gen_highlighter.words

      -- Helper function to create color highlighter from color string
      local function color_from_match(_, match)
        -- For now, just return a fixed highlight group for non-hex colors
        -- TODO: Convert RGB/HSL to hex and compute proper color
        return nil
      end

      hipatterns.setup {
        highlighters = {
          fixme = hi_words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
          hack = hi_words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
          todo = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
          note = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),

          -- Enhanced color support (replaces nvim-colorizer.lua)
          hex_color = hipatterns.gen_highlighter.hex_color(),

          -- RGB/RGBA color support: rgb(255, 0, 0), rgba(255, 0, 0, 0.5)
          rgb_color = {
            pattern = "()rgba?%(%d+,? %d+,? %d+,? ?[%d%.]*%)()",
            group = color_from_match,
          },

          -- HSL/HSLA color support: hsl(0, 100%, 50%), hsla(0, 100%, 50%, 0.5)
          hsl_color = {
            pattern = "()hsla?%(%d+,? %d+%%,? %d+%%,? ?[%d%.]*%)()",
            group = color_from_match,
          },

          -- CSS color names (common ones)
          css_names = {
            pattern = "()%f[%a]("
              .. "red|green|blue|yellow|orange|purple|pink|brown|gray|grey|black|white|"
              .. "cyan|magenta|lime|navy|teal|olive|silver|maroon|fuchsia|aqua|"
              .. "darkred|darkgreen|darkblue|lightred|lightgreen|lightblue|"
              .. "darkgray|darkgrey|lightgray|lightgrey"
              .. ")%f[%A]()",
            group = function(_, match)
              local colors = {
                red = "#ff0000",
                green = "#008000",
                blue = "#0000ff",
                yellow = "#ffff00",
                orange = "#ffa500",
                purple = "#800080",
                pink = "#ffc0cb",
                brown = "#a52a2a",
                gray = "#808080",
                grey = "#808080",
                black = "#000000",
                white = "#ffffff",
                cyan = "#00ffff",
                magenta = "#ff00ff",
                lime = "#00ff00",
                navy = "#000080",
                teal = "#008080",
                olive = "#808000",
                silver = "#c0c0c0",
                maroon = "#800000",
                fuchsia = "#ff00ff",
                aqua = "#00ffff",
                darkred = "#8b0000",
                darkgreen = "#006400",
                darkblue = "#00008b",
                lightred = "#ffcccb",
                lightgreen = "#90ee90",
                lightblue = "#add8e6",
                darkgray = "#a9a9a9",
                darkgrey = "#a9a9a9",
                lightgray = "#d3d3d3",
                lightgrey = "#d3d3d3",
              }
              local color = colors[match.full_match:lower()]
              if color then return hipatterns.gen_highlighter.hex_color()(_, { full_match = color }) end
              return nil
            end,
          },
        },
        delay = {
          text_change = 200, -- Slightly delayed for better performance
          scroll = 50,
        },
      }
    end,
  },

  -- Notifications
  {
    "echasnovski/mini.notify",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.notify").setup({
        window = {
          config = {
            border = "rounded",
          },
        },
      })
      vim.notify = require("mini.notify").make_notify({
        ERROR = { duration = 10000 }, -- Keep errors visible for 10s
      })
    end,
  },

  -- Enhanced editing capabilities
  {
    "echasnovski/mini.ai",
    version = false,
    event = "VeryLazy",
    config = function()
      local gen = require("mini.extra").gen_ai_spec
      require("mini.ai").setup {
        custom_textobjects = {
          B = gen.buffer(),
          D = gen.diagnostic(),
          I = gen.indent(),
          L = gen.line(),
          N = gen.number(),
          -- Date patterns: yyyy-mm-dd or yyyy/mm/dd
          J = { { "()%d%d%d%d%-%d%d%-%d%d()", "()%d%d%d%d%/%d%d%/%d%d()" } },
        },
        n_lines = 500,
      }
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

  -- File explorer
  {
    "echasnovski/mini.files",
    version = false,
    keys = {
      {
        "<leader>e",
        function()
          require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
        end,
        desc = "Open mini.files (current file)",
      },
      {
        "<leader>E",
        function()
          require("mini.files").open(vim.loop.cwd(), true)
        end,
        desc = "Open mini.files (cwd)",
      },
    },
    config = function()
      require("mini.files").setup {
        windows = {
          preview = true,
          width_focus = 30,
          width_preview = 30,
        },
        options = {
          use_as_default_explorer = false, -- Keep neo-tree as default for now
        },
      }

      -- Create splits from mini.files
      local map_split = function(buf_id, lhs, direction)
        local rhs = function()
          local new_target_window
          vim.api.nvim_win_call(require("mini.files").get_target_window(), function()
            vim.cmd(direction .. " split")
            new_target_window = vim.api.nvim_get_current_win()
          end)

          require("mini.files").set_target_window(new_target_window)
        end

        local desc = "Split " .. direction
        vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf_id = args.data.buf_id
          map_split(buf_id, "gs", "belowright horizontal")
          map_split(buf_id, "gv", "belowright vertical")
        end,
      })
    end,
  },

  -- Session management
  {
    "echasnovski/mini.sessions",
    version = false,
    lazy = false,
    config = function()
      require("mini.sessions").setup {
        autoread = false,
        autowrite = true,
        directory = vim.fn.stdpath "data" .. "/sessions/",
        file = "session.vim",
      }
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

  -- Starter screen
  {
    "echasnovski/mini.starter",
    version = false,
    event = "VimEnter",
    enabled = false, -- Disabled since dashboard-nvim is already configured
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
      require("mini.bracketed").setup {
        -- Disable some default mappings to avoid conflicts
        file = { suffix = "" },
        window = { suffix = "" },
        quickfix = { suffix = "q" },
        yank = { suffix = "y" },
        treesitter = { suffix = "t" },
      }
    end,
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

  -- Starter screen
  {
    "echasnovski/mini.starter",
    version = false,
    event = "VimEnter",
    config = function()
      require("mini.starter").setup()
    end,
  },
}

