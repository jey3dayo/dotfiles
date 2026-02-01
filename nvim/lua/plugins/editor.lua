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

  -- Input method switcher
  {
    "keaising/im-select.nvim",
    event = "InsertEnter",
    opts = require "config/im-select",
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

      hipatterns.setup {
        highlighters = {
          fixme = hi_words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
          hack = hi_words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
          todo = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
          note = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),

          -- Enhanced color support (replaces nvim-colorizer.lua)
          hex_color = hipatterns.gen_highlighter.hex_color(),

          -- CSS color names mapped to hex (fast path, working)
          css_names = (function()
            local hex = hipatterns.gen_highlighter.hex_color()
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
            return {
              pattern = "()%f[%a]("
                .. "red|green|blue|yellow|orange|purple|pink|brown|gray|grey|black|white|"
                .. "cyan|magenta|lime|navy|teal|olive|silver|maroon|fuchsia|aqua|"
                .. "darkred|darkgreen|darkblue|lightred|lightgreen|lightblue|"
                .. "darkgray|darkgrey|lightgray|lightgrey"
                .. ")%f[%A]()",
              group = function(_, match)
                local color = colors[match.full_match:lower()]
                if color then return hex(_, { full_match = color }) end
                return nil
              end,
            }
          end)(),
        },
        delay = {
          text_change = 200, -- Slightly delayed for better performance
          scroll = 50,
        },
      }
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
      require("mini.files").setup {
        windows = {
          preview = true,
          width_focus = 30,
          width_preview = 30,
        },
        options = {
          use_as_default_explorer = true, -- Use mini.files as default explorer
        },
      }

      -- Create splits from mini.files (simplified approach)
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf_id = args.data.buf_id

          -- Split keymaps (simplified without get_target_window)
          vim.keymap.set("n", "s", function()
            local entry = require("mini.files").get_fs_entry()
            if entry and entry.fs_type == "file" then
              require("mini.files").close()
              vim.cmd("split " .. entry.path)
            end
          end, { buffer = buf_id, desc = "Open in horizontal split" })

          vim.keymap.set("n", "v", function()
            local entry = require("mini.files").get_fs_entry()
            if entry and entry.fs_type == "file" then
              require("mini.files").close()
              vim.cmd("vsplit " .. entry.path)
            end
          end, { buffer = buf_id, desc = "Open in vertical split" })

          -- Enter and 'o' to open file (default behavior)
          local open_file = function()
            require("mini.files").go_in { close_on_file = true }
          end
          vim.keymap.set("n", "<CR>", open_file, { buffer = buf_id, desc = "Open file/directory" })
          vim.keymap.set("n", "o", open_file, { buffer = buf_id, desc = "Open file/directory" })
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
        autoread = true,
        autowrite = true,
        directory = vim.fn.stdpath "state" .. "/sessions/",
        file = "session.vim",
        hooks = {
          pre = {
            write = function()
              -- Close file explorer before saving
              pcall(vim.cmd, "MiniFilesClose")
            end,
          },
          post = {
            read = function()
              -- File explorer will be reopened if needed
              -- (mini.files doesn't need explicit reopening)
            end,
          },
        },
      }

      -- Better sessionoptions
      vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

      -- Keymaps
      local ms = require "mini.sessions"
      vim.keymap.set("n", "<leader>ss", function()
        -- Create session name from current directory
        local session_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. ".vim"
        ms.write(session_name)
      end, { desc = "Session save" })
      vim.keymap.set("n", "<leader>sr", function()
        ms.select "read"
      end, { desc = "Session restore" })
      vim.keymap.set("n", "<leader>sd", function()
        ms.select "delete"
      end, { desc = "Session delete" })
      vim.keymap.set("n", "<leader>sl", function()
        ms.select "read"
      end, { desc = "List sessions" })
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
    opts = {
      animation = {
        enabled = true,
        duration = 100,
        animation_type = "fade",
        fps = 120,
        easing = "in_out_cubic",
      },
      priority = 4096,
      color_cache_size = 1000,
      debounce_delay = 50,
      -- Fallback colors for transparent terminals
      fallback_for_transparency = {
        bg = "#16161d", -- kanagawa-wave dark background
        fg = "#dcd7ba", -- kanagawa-wave foreground
      },
    },
    config = function(_, opts)
      local undo_glow = require "undo-glow"
      undo_glow.setup(opts)

      -- u/U でundo/redo（ハイライト付き）
      vim.keymap.set("n", "u", undo_glow.undo, { desc = "Undo with highlight" })
      vim.keymap.set("n", "U", undo_glow.redo, { desc = "Redo with highlight" })

      -- p/P でペーストし、`] でペースト範囲の末尾へ移動
      vim.keymap.set("n", "p", function()
        undo_glow.paste_below()
        vim.cmd.normal { args = { "`]" }, bang = true }
      end, { desc = "Paste below with highlight" })

      vim.keymap.set("n", "P", function()
        undo_glow.paste_above()
        vim.cmd.normal { args = { "`]" }, bang = true }
      end, { desc = "Paste above with highlight" })

      -- TextYankPost autocmd integration (undo-glow README recommended)
      vim.api.nvim_create_autocmd("TextYankPost", {
        group = vim.api.nvim_create_augroup("UndoGlowYank", { clear = true }),
        desc = "Highlight yanked text with undo-glow animation",
        callback = function()
          undo_glow.yank()
        end,
      })

      -- Flash.nvim integration: highlight cursor after jumping
      vim.keymap.set({ "n", "x", "o" }, "s", function()
        require("undo-glow").flash_jump()
      end, { desc = "Flash jump with highlight" })
    end,
  },

  -- Yank history and register management
  {
    "gbprod/yanky.nvim",
    event = "VeryLazy",
    dependencies = { "kkharji/sqlite.lua" }, -- optional: persistence
    opts = {
      ring = {
        history_length = 100,
        storage = "memory", -- or "sqlite" for persistence
        sync_with_numbered_registers = true,
        cancel_event = "update",
      },
      picker = {
        select = {
          action = nil, -- telescope integration can be added later
        },
      },
      system_clipboard = {
        sync_with_ring = true,
      },
      highlight = {
        on_put = true,
        on_yank = true,
        timer = 300,
      },
      preserve_cursor_position = {
        enabled = true,
      },
    },
    keys = {
      -- Yank history navigation
      {
        "<leader>p",
        function()
          require("yanky").put("p", true)
        end,
        desc = "Put with yanky",
      },
      {
        "<leader>P",
        function()
          require("yanky").put("P", true)
        end,
        desc = "Put before with yanky",
      },
      { "[y", "<Plug>(YankyCycleForward)", desc = "Cycle forward through yank history" },
      { "]y", "<Plug>(YankyCycleBackward)", desc = "Cycle backward through yank history" },
      { "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put after with filter" },
      { "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put before with filter" },
    },
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
