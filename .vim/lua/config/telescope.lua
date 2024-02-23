local status, telescope = pcall(require, "telescope")
if not status then
  return
end
local actions = require "telescope.actions"
local builtin = require "telescope.builtin"

local function telescope_buffer_dir()
  return vim.fn.expand "%:p:h"
end

local fb_actions = telescope.extensions.file_browser.actions

telescope.setup {
  defaults = {
    mappings = {
      n = {
        ["q"] = actions.close,
        ["<C-c>"] = actions.close,
        ["<C-n>"] = actions.move_selection_worse,
        ["<C-p>"] = actions.move_selection_better,
        ["d"] = actions.delete_buffer,
      },
      i = {
        ["<C-n>"] = actions.move_selection_next,
        ["<C-p>"] = actions.move_selection_previous,
        ["<C-d>"] = actions.delete_buffer,
      },
    },
  },
  pickers = {
    find_files = {
      -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
      find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
    },
  },
  extensions = {
    file_browser = {
      theme = "dropdown",
      -- disables netrw and use telescope-file-browser in its place
      hijack_netrw = true,
      mappings = {
        -- your custom insert mode mappings
        ["i"] = {
          ["<C-d>"] = actions.close,
          ["<C-w>"] = function()
            vim.cmd "normal vbd"
          end,
        },
        ["n"] = {
          -- your custom normal mode mappings
          ["<C-d>"] = actions.close,
          ["N"] = fb_actions.create,
          ["u"] = fb_actions.goto_parent_dir,
          ["/"] = function()
            vim.cmd "startinsert"
          end,
        },
      },
    },
  },
}
telescope.load_extension "file_browser"
telescope.load_extension "notify"

-- keymaps
Keymap("<Leader>f", function()
  builtin.find_files {
    no_ignore = false,
    hidden = true,
  }
end)
Keymap("<Leader>g", builtin.live_grep)
Keymap("<Leader>b", builtin.buffers)
Keymap("<Leader>d", builtin.diagnostics)
Keymap("<Leader>y", telescope.extensions.neoclip.default)
Keymap("<Leader>,", builtin.resume)

-- Keymap("<Leader>e", function()
--   telescope.extensions.file_browser.file_browser {
--     path = "%:p:h",
--     cwd = telescope_buffer_dir(),
--     respect_gitignore = false,
--     hidden = true,
--     grouped = true,
--     previewer = false,
--     initial_mode = "normal",
--     layout_config = { height = 40 },
--   }
-- end)
