-- Mini.pick configuration and keymaps

local utils = require "core.utils"

-- Use vim.keymap.set directly for better compatibility

-- Helper functions
local function get_git_dir()
  return utils.get_git_dir and utils.get_git_dir() or vim.fn.systemlist("git rev-parse --show-toplevel")[1] or ""
end

-- Core pickers
vim.keymap.set("n", "<Leader>ff", function()
  require("mini.pick").builtin.files()
end, { desc = "Find files" })

vim.keymap.set("n", "<A-p>", function()
  require("mini.pick").builtin.files()
end, { desc = "Find files" })

vim.keymap.set("n", "<Leader>fF", function()
  local buffer_dir = vim.fn.expand "%:p:h"
  require("mini.pick").builtin.files(nil, { source = { cwd = buffer_dir } })
end, { desc = "Find files in buffer dir" })

vim.keymap.set("n", "<Leader><Leader>", function()
  require("mini.pick").builtin.resume()
end, { desc = "Resume last pick" })

-- Grep functionality
vim.keymap.set("n", "<Leader>fg", function()
  require("mini.pick").builtin.grep_live()
end, { desc = "Live grep" })

vim.keymap.set("n", "<Leader>fG", function()
  require("mini.pick").builtin.grep()
end, { desc = "Grep (with pattern input)" })

-- Additional grep keymap for muscle memory
vim.keymap.set("n", "<Leader>g", function()
  require("mini.pick").builtin.grep_live()
end, { desc = "Live grep (shortcut)" })

-- Buffer management
vim.keymap.set("n", "<Leader>fb", function()
  require("mini.pick").builtin.buffers()
end, { desc = "Find buffers" })

-- Help system
vim.keymap.set("n", "<Leader>fh", function()
  require("mini.pick").builtin.help()
end, { desc = "Find help" })

-- Recent files (oldfiles replacement)
vim.keymap.set("n", "<Leader>fo", function()
  local ok, mini_extra = pcall(require, "mini.extra")
  if ok then
    mini_extra.pickers.oldfiles()
  else
    -- Fallback to vim's oldfiles
    vim.ui.select(vim.v.oldfiles, {
      prompt = "Recent files:",
    }, function(choice)
      if choice then vim.cmd("edit " .. choice) end
    end)
  end
end, { desc = "Find recent files" })

-- Commands picker
vim.keymap.set("n", "<Leader>fc", function()
  local ok, mini_extra = pcall(require, "mini.extra")
  if ok then
    mini_extra.pickers.commands()
  else
    -- Fallback to built-in command completion
    vim.ui.input({ prompt = "Command: ", completion = "command" }, function(input)
      if input then vim.cmd(input) end
    end)
  end
end, { desc = "Find commands" })

-- Keymaps picker
vim.keymap.set("n", "<Leader>fk", function()
  local ok, mini_extra = pcall(require, "mini.extra")
  if ok then
    mini_extra.pickers.keymaps()
  else
    vim.notify("Keymaps picker requires mini.extra", vim.log.levels.WARN)
  end
end, { desc = "Find keymaps" })

-- Mini.extra pickers (if available)
local function setup_extra_pickers()
  local ok, mini_extra = pcall(require, "mini.extra")
  if not ok then return end

  -- Git pickers (use different keys to avoid conflict)
  vim.keymap.set("n", "<Leader>fgc", function()
    mini_extra.pickers.git_commits()
  end, { desc = "Git commits" })

  vim.keymap.set("n", "<Leader>fgf", function()
    mini_extra.pickers.git_files()
  end, { desc = "Git files" })

  -- Diagnostic pickers
  vim.keymap.set("n", "<Leader>fd", function()
    mini_extra.pickers.diagnostic()
  end, { desc = "Diagnostics" })

  -- LSP pickers
  vim.keymap.set("n", "<Leader>fs", function()
    mini_extra.pickers.lsp { scope = "document_symbol" }
  end, { desc = "Document symbols" })

  vim.keymap.set("n", "<Leader>fS", function()
    mini_extra.pickers.lsp { scope = "workspace_symbol" }
  end, { desc = "Workspace symbols" })

  -- Recently visited files
  vim.keymap.set("n", "<Leader>fr", function()
    mini_extra.pickers.visit_paths()
  end, { desc = "Recent files (mini.visits)" })

  -- Colorscheme picker
  vim.keymap.set("n", "<Leader>fc", function()
    mini_extra.pickers.hipatterns()
  end, { desc = "Highlight patterns" })
end

-- File browser replacement (use mini.files)
vim.keymap.set("n", "<Leader>e", function()
  local git_dir = get_git_dir()
  local path = git_dir ~= "" and git_dir or vim.fn.expand "%:p:h"
  require("mini.files").open(path, true)
end, { desc = "Open mini.files (git root or buffer dir)" })

vim.keymap.set("n", "<Leader>E", function()
  require("mini.files").open(vim.fn.expand "%:p:h", true)
end, { desc = "Open mini.files (buffer dir)" })

-- Yank history (neoclip)
vim.keymap.set("n", "<Leader>fy", function()
  local ok, _ = pcall(require, "neoclip")
  if ok then
    -- Open neoclip with default UI
    vim.cmd "Neoclip"
  else
    vim.notify("Neoclip not available", vim.log.levels.ERROR)
  end
end, { desc = "Yank history (neoclip)" })

-- Notification history (mini.notify integration)
vim.keymap.set("n", "<leader>fn", function()
  local ok, mini_notify = pcall(require, "mini.notify")
  if ok then
    mini_notify.show_history()
  else
    vim.notify("mini.notify not available", vim.log.levels.ERROR)
  end
end, { desc = "Show notification history" })

vim.keymap.set("n", "<leader>fN", function()
  local ok, mini_notify = pcall(require, "mini.notify")
  if ok then
    mini_notify.show_history()
  else
    vim.notify("mini.notify not available", vim.log.levels.ERROR)
  end
end, { desc = "Show notification history buffer" })

-- Messages integration
vim.keymap.set("n", "<leader>fm", function()
  vim.cmd "messages"
end, { desc = "Show messages" })

vim.keymap.set("n", "<leader>fM", function()
  vim.cmd "messages"
end, { desc = "Show messages" })

-- Setup extra pickers if mini.extra is available
vim.schedule(setup_extra_pickers)
