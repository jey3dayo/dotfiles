local telescope = safe_require "telescope"
if not telescope then
  return
end
local actions = require "telescope.actions"
local builtin = require "telescope.builtin"

local fb_actions = telescope.extensions.file_browser.actions

local function telescope_buffer_dir()
  return vim.fn.expand "%:p:h"
end

local function setup_file_browser(opts)
  opts = opts or {}
  telescope.extensions.file_browser.file_browser(vim.tbl_extend("force", {
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
    ["<C-c>"] = actions.close,
    ["<C-n>"] = actions.move_selection_worse,
    ["<C-p>"] = actions.move_selection_better,
    ["d"] = actions.delete_buffer,
  },
  i = {
    ["<C-n>"] = actions.move_selection_next,
    ["<C-p>"] = actions.move_selection_previous,
    ["<C-d>"] = actions.delete_buffer,
    ["<C-j>"] = actions.cycle_history_next,
    ["<C-k>"] = actions.cycle_history_prev,
    ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
  },
}

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

local file_ignore_patterns = {
  "^.git/",
  "^node_modules/",
  "*.patch",
  "lazy-lock.json",
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
telescope.load_extension "file_browser"
telescope.load_extension "undo"
telescope.load_extension "notify"
telescope.load_extension "frecency"

-- keymaps
Keymap("<Leader>F", function()
  builtin.find_files {
    no_ignore = false,
    hidden = true,
  }
end, { desc = "Find By Fiiles" })
Keymap("<Leader>g", builtin.live_grep, { desc = "Find by Live Grep" })
Keymap("<Leader>b", builtin.buffers, { desc = "buffers" })
Keymap("<Leader>d", builtin.diagnostics, { desc = "Find by Diagnostics" })
Keymap("<Leader>u", telescope.extensions.undo.undo, { desc = "Find by Undo" })
Keymap("<Leader><Leader>", builtin.resume, { desc = "Find by Resume" })
Keymap("<Leader>gs", builtin.git_status, { desc = "Find by Git Status" })

-- extensions
Keymap("<Leader>Y", telescope.extensions.neoclip.default, { desc = "Find by Yank" })
Keymap("<leader>n", telescope.extensions.notify.notify, { desc = "Find by Notify" })

Keymap("<Leader>f", function()
  telescope.extensions.frecency.frecency { workspace = "CWD" }
end, { desc = "Find by frecency" })

Keymap("<Leader>e", function()
  local git_dir = require("utils").get_git_dir()
  setup_file_browser {
    path = git_dir ~= "" and git_dir or "%:p:h",
    cwd = git_dir ~= "" and git_dir or telescope_buffer_dir(),
  }
end, { desc = "Find by File Browser" })

Keymap("<Leader>E", function()
  setup_file_browser {
    path = "%:p:h",
    cwd = telescope_buffer_dir(),
    respect_gitignore = false,
  }
end, { desc = "Find by File Browser" })
