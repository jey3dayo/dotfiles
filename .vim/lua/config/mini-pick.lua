-- Mini.pick configuration and keymaps
-- Replacement for telescope.nvim with mini.nvim ecosystem integration

local utils = require "core.utils"

-- Use global Keymap function if available, fallback to vim.keymap.set
local Keymap = _G.Keymap or function(lhs, rhs, opts)
  vim.keymap.set("n", lhs, rhs, opts)
end

-- Helper functions
local function get_git_dir()
  return utils.get_git_dir and utils.get_git_dir() or vim.fn.systemlist("git rev-parse --show-toplevel")[1] or ""
end

-- Core pickers
Keymap("<Leader>ff", function()
  require("mini.pick").builtin.files()
end, { desc = "Find files" })

Keymap("<A-p>", function()
  require("mini.pick").builtin.files()
end, { desc = "Find files" })

Keymap("<Leader>fF", function()
  local buffer_dir = vim.fn.expand "%:p:h"
  require("mini.pick").builtin.files(nil, { source = { cwd = buffer_dir } })
end, { desc = "Find files in buffer dir" })

Keymap("<Leader><Leader>", function()
  require("mini.pick").builtin.resume()
end, { desc = "Resume last pick" })

-- Grep functionality  
Keymap("<Leader>fg", function()
  require("mini.pick").builtin.grep_live()
end, { desc = "Live grep" })

Keymap("<Leader>fG", function()
  require("mini.pick").builtin.grep()
end, { desc = "Grep (with pattern input)" })

-- Additional grep keymap for muscle memory
Keymap("<Leader>g", function()
  require("mini.pick").builtin.grep_live()
end, { desc = "Live grep (shortcut)" })

-- Buffer management
Keymap("<Leader>fb", function()
  require("mini.pick").builtin.buffers()
end, { desc = "Find buffers" })

-- Help system
Keymap("<Leader>fh", function()
  require("mini.pick").builtin.help()
end, { desc = "Find help" })

-- Mini.extra pickers (if available)
local function setup_extra_pickers()
  local ok, mini_extra = pcall(require, "mini.extra")
  if not ok then return end

  -- Git pickers (use different keys to avoid conflict)
  Keymap("<Leader>fgc", function()
    mini_extra.pickers.git_commits()
  end, { desc = "Git commits" })

  Keymap("<Leader>fgf", function()
    mini_extra.pickers.git_files()
  end, { desc = "Git files" })

  -- Diagnostic pickers
  Keymap("<Leader>fd", function()
    mini_extra.pickers.diagnostic()
  end, { desc = "Diagnostics" })

  -- LSP pickers
  Keymap("<Leader>fs", function()
    mini_extra.pickers.lsp({ scope = "document_symbol" })
  end, { desc = "Document symbols" })

  Keymap("<Leader>fS", function()
    mini_extra.pickers.lsp({ scope = "workspace_symbol" })
  end, { desc = "Workspace symbols" })

  -- Recently visited files
  Keymap("<Leader>fr", function()
    mini_extra.pickers.visit_paths()
  end, { desc = "Recent files (mini.visits)" })

  -- Colorscheme picker
  Keymap("<Leader>fc", function()
    mini_extra.pickers.hipatterns()
  end, { desc = "Highlight patterns" })
end

-- File browser replacement (use mini.files)
Keymap("<Leader>e", function()
  local git_dir = get_git_dir()
  local path = git_dir ~= "" and git_dir or vim.fn.expand("%:p:h")
  require("mini.files").open(path, true)
end, { desc = "Open mini.files (git root or buffer dir)" })

Keymap("<Leader>E", function()
  require("mini.files").open(vim.fn.expand("%:p:h"), true)
end, { desc = "Open mini.files (buffer dir)" })

-- Yank history (neoclip replacement)
Keymap("<Leader>fy", function()
  -- Use mini.pick for clipboard if available, otherwise fall back to existing neoclip
  local ok, _ = pcall(require, "mini.misc")
  if ok then
    -- Custom yank history picker (simplified)
    vim.notify("Mini.pick yank history not implemented yet, using existing neoclip", vim.log.levels.WARN)
    -- Keep existing neoclip for now
    require("telescope").extensions.neoclip.default()
  else
    require("telescope").extensions.neoclip.default()
  end
end, { desc = "Find by Yank (neoclip fallback)" })

-- Notification history (mini.notify integration)
Keymap("<leader>fn", function()
  local ok, mini_notify = pcall(require, "mini.notify")
  if ok then
    mini_notify.show_history()
  else
    vim.notify("mini.notify not available", vim.log.levels.ERROR)
  end
end, { desc = "Show notification history" })

Keymap("<leader>fN", function()
  local ok, mini_notify = pcall(require, "mini.notify")
  if ok then
    mini_notify.show_history()
  else
    vim.notify("mini.notify not available", vim.log.levels.ERROR)
  end
end, { desc = "Show notification history buffer" })

-- Messages integration
Keymap("<leader>fm", function()
  vim.cmd("messages")
end, { desc = "Show messages" })

Keymap("<leader>fM", function()
  vim.cmd("messages")
end, { desc = "Show messages" })

-- Setup extra pickers if mini.extra is available
vim.schedule(setup_extra_pickers)