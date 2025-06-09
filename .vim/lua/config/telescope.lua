local utils = require "core.utils"
local telescope = utils.safe_require "telescope"
if not telescope then return end

local with = utils.with
local actions = require "telescope.actions"
local builtin = require "telescope.builtin"

local file_ignore_patterns = {
  "^.git/",
  "^node_modules/",
  "*.diff",
  "*.patch",
  "lazy-lock.json",
  "^dist/",
}

local function telescope_buffer_dir()
  return vim.fn.expand "%:p:h"
end

-- Helper function to ensure extension is loaded
local function ensure_extension_loaded(extension_name)
  pcall(telescope.load_extension, extension_name)
end

local function setup_file_browser(opts)
  opts = opts or {}
  ensure_extension_loaded "file_browser"
  telescope.extensions.file_browser.file_browser(with({
    hidden = true,
    grouped = true,
    previewer = false,
    initial_mode = "normal",
    layout_config = { height = 40 },
    respect_gitignore = true,
  }, opts))
end

local telescope_mappings = {
  n = {
    ["q"] = actions.close,
    ["<C-n>"] = actions.move_selection_worse,
    ["<C-p>"] = actions.move_selection_better,
    ["d"] = actions.delete_buffer,
    ["<C-t>"] = actions.select_tab,
  },
  i = {
    ["<C-n>"] = actions.move_selection_next,
    ["<C-p>"] = actions.move_selection_previous,
    ["<C-d>"] = actions.delete_buffer,
    ["<C-j>"] = actions.cycle_history_next,
    ["<C-k>"] = actions.cycle_history_prev,
    ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
    ["<C-t>"] = actions.select_tab,
  },
}

local fb_actions = telescope.extensions.file_browser.actions
local file_browser_mappings = {
  i = {
    ["<C-d>"] = actions.close,
    ["<C-w>"] = function()
      vim.cmd "normal vbd"
    end,
  },
  n = {
    ["<C-d>"] = actions.close,
    ["N"] = fb_actions.create,
    ["u"] = fb_actions.goto_parent_dir,
    ["/"] = function()
      vim.cmd "startinsert"
    end,
  },
}

local function get_live_grep_additional_args()
  local additional_args = { "--hidden" }

  for _, pattern in ipairs(file_ignore_patterns) do
    table.insert(additional_args, "--glob")
    table.insert(additional_args, "!" .. pattern)
  end

  return additional_args
end

local function get_find_files_command()
  local find_command = { "rg", "--files", "--hidden" }

  for _, pattern in ipairs(file_ignore_patterns) do
    table.insert(find_command, "--glob")
    table.insert(find_command, "!" .. pattern)
  end

  return find_command
end

telescope.setup {
  defaults = {
    mappings = telescope_mappings,
    file_ignore_patterns = file_ignore_patterns,
  },
  pickers = {
    find_files = {
      -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
      find_command = get_find_files_command,
    },
    live_grep = { additional_args = get_live_grep_additional_args },
  },
  extensions = {
    file_browser = {
      theme = "dropdown",
      -- disables netrw and use telescope-file-browser in its place
      hijack_netrw = true,
      mappings = file_browser_mappings,
    },
  },
}

-- 追記
telescope.load_extension "file_browser"
telescope.load_extension "undo"
telescope.load_extension "notify"
telescope.load_extension "frecency"
telescope.load_extension "neoclip"


-- keymaps
Keymap("<Leader>g", builtin.live_grep, { desc = "Find by Live Grep" })
Keymap("<Leader>b", builtin.buffers, { desc = "buffers" })
Keymap("<Leader>d", builtin.diagnostics, { desc = "Find by Diagnostics" })
Keymap("<Leader>u", function()
  ensure_extension_loaded "undo"
  telescope.extensions.undo.undo()
end, { desc = "Find by Undo" })
Keymap("<Leader><Leader>", builtin.resume, { desc = "Find by Resume" })

-- extensions
Keymap("<Leader>Y", function()
  ensure_extension_loaded "neoclip"
  telescope.extensions.neoclip.default()
end, { desc = "Find by Yank" })
Keymap("<leader>n", telescope.extensions.notify.notify, { desc = "Find by Notify" })

Keymap("<Leader>f", function()
  ensure_extension_loaded "frecency"
  telescope.extensions.frecency.frecency { workspace = "CWD" }
end, { desc = "Find CWD by frecency" })

Keymap("<A-p>", function()
  ensure_extension_loaded "frecency"
  telescope.extensions.frecency.frecency { workspace = "CWD" }
end, { desc = "Find CWD by frecency" })

Keymap("<Leader>F", function()
  ensure_extension_loaded "frecency"
  telescope.extensions.frecency.frecency {}
end, { desc = "Find by frecency" })

Keymap("<Leader>G", builtin.git_status, { desc = "Find by Git Status" })
Keymap("<Leader>e", function()
  local git_dir = utils.get_git_dir()
  setup_file_browser {
    path = git_dir ~= "" and git_dir or "%:p:h",
    cwd = git_dir ~= "" and git_dir or telescope_buffer_dir(),
  }
end, { desc = "Find git_dir by File Browser" })

Keymap("<Leader>E", function()
  setup_file_browser {
    path = "%:p:h",
    cwd = telescope_buffer_dir(),
    respect_gitignore = false,
  }
end, { desc = "Find by File Browser" })
