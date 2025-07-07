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
  extensions = {},

}

-- Load extensions
local extensions = { "frecency", "neoclip" }
for _, ext in ipairs(extensions) do
  telescope.load_extension(ext)
end

-- Load custom extensions
telescope.load_extension("mini_notify")
telescope.load_extension("messages")

-- keymaps
Keymap("<Leader><Leader>", builtin.resume, { desc = "Find by Resume" })

-- extensions
Keymap("<Leader>fy", telescope.extensions.neoclip.default, { desc = "Find by Yank" })
-- mini.notify integration
-- Load notify helper
local notify_helper = require("core.notify")

Keymap("<leader>fn", function()
  -- Ensure the extension is loaded before calling it
  if telescope.extensions.mini_notify then
    telescope.extensions.mini_notify.mini_notify()
  else
    notify_helper.error(notify_helper.errors.extension_not_loaded("mini_notify"))
  end
end, { desc = "Find notifications (mini.notify)" })
Keymap("<leader>fN", function() 
  local ok, mini_notify = pcall(require, "mini.notify")
  if ok then
    mini_notify.show_history()
  else
    notify_helper.error(notify_helper.errors.module_not_available("mini.notify"))
  end
end, { desc = "Show notification history buffer" })

-- messages integration
Keymap("<leader>fm", function()
  telescope.extensions.messages.messages()
end, { desc = "Find messages (:messages)" })
Keymap("<leader>fM", "<cmd>messages<CR>", { desc = "Show messages" })

-- frecency
local function frecency_cwd()
  telescope.extensions.frecency.frecency { workspace = "CWD" }
end

local function find_files_buffer_dir()
  local buffer_dir = vim.fn.expand "%:p:h"
  builtin.find_files {
    cwd = buffer_dir,
    prompt_title = "Files (Buffer Dir)",
    hidden = true,
  }
end

Keymap("<Leader>ff", frecency_cwd, { desc = "Find CWD by frecency" })
Keymap("<A-p>", frecency_cwd, { desc = "Find CWD by frecency" })
Keymap("<Leader>fF", find_files_buffer_dir, { desc = "Find files in buffer dir" })

