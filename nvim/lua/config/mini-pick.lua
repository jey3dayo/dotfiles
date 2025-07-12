-- Mini.pick configuration and keymaps

local utils = require "core.utils"

-- Use vim.keymap.set directly for better compatibility

-- Helper functions
local function get_git_dir()
  return utils.get_git_dir and utils.get_git_dir() or vim.fn.systemlist("git rev-parse --show-toplevel")[1] or ""
end

-- Core pickers
vim.keymap.set("n", "<Leader>f", function()
  require("mini.pick").builtin.files()
end, { desc = "Find files" })

vim.keymap.set("n", "<Leader><Leader>", function()
  local ok, mini_pick = pcall(require, "mini.pick")
  if ok and mini_pick.get_picker_state() ~= nil then
    mini_pick.builtin.resume()
  else
    vim.notify("No picker to resume", vim.log.levels.INFO)
  end
end, { desc = "Resume last pick" })

-- Additional grep keymap for muscle memory - both <Leader>fg and <Leader>g work
vim.keymap.set("n", "<Leader>g", function()
  require("mini.pick").builtin.grep_live()
end, { desc = "Live grep (shortcut)" })

-- Buffer management
vim.keymap.set("n", "<Leader>b", function()
  require("mini.pick").builtin.buffers()
end, { desc = "Find buffers" })

-- Help system
vim.keymap.set("n", "<Leader>Fh", function()
  require("mini.pick").builtin.help()
end, { desc = "Find help" })

-- Recent files (using mini.visits for smarter tracking)
vim.keymap.set("n", "<Leader>Fr", function()
  local ok, mini_extra = pcall(require, "mini.extra")
  if ok then
    mini_extra.pickers.visit_paths()
  else
    -- Fallback to basic oldfiles
    vim.ui.select(vim.v.oldfiles, {
      prompt = "Recent files:",
    }, function(choice)
      if choice then vim.cmd("edit " .. choice) end
    end)
  end
end, { desc = "Recent files (smart)" })


-- Keymaps picker
vim.keymap.set("n", "<Leader>Fk", function()
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

  -- Diagnostic pickers
  vim.keymap.set("n", "<Leader>d", function()
    mini_extra.pickers.diagnostic()
  end, { desc = "Diagnostics" })

  -- LSP pickers
  vim.keymap.set("n", "<Leader>Fs", function()
    mini_extra.pickers.lsp { scope = "document_symbol" }
  end, { desc = "Document symbols" })

  vim.keymap.set("n", "<Leader>FS", function()
    mini_extra.pickers.lsp { scope = "workspace_symbol" }
  end, { desc = "Workspace symbols" })

  -- Recently visited files

end

-- File browser replacement (use mini.files)
vim.keymap.set("n", "<Leader>e", function()
  local git_dir = get_git_dir()
  local current_file = vim.fn.expand "%:p"
  local path = vim.fn.getcwd() -- Default to current working directory

  -- Always use cwd for special buffers like ministarter
  if string.match(current_file, "^%w+:") then
    -- Special buffer (ministarter, etc.) - use current working directory
    path = vim.fn.getcwd()
  elseif current_file ~= "" and vim.fn.filereadable(current_file) == 1 then
    -- If we have a readable file, use its directory
    path = vim.fn.expand "%:p:h"
  elseif git_dir ~= "" then
    -- If we have a git directory, use it
    path = git_dir
  end

  require("mini.files").open(path, true)
end, { desc = "Open mini.files (git root or buffer dir)" })

vim.keymap.set("n", "<Leader>E", function()
  require("mini.files").open(vim.fn.expand "%:p:h", true)
end, { desc = "Open mini.files (buffer dir)" })

-- Yank history (mini.extra registers)
vim.keymap.set("n", "<Leader>y", function()
  local ok, mini_extra = pcall(require, "mini.extra")
  if ok then
    mini_extra.pickers.registers()
  else
    vim.notify("mini.extra not available", vim.log.levels.WARN)
  end
end, { desc = "Pick from registers" })

-- Notification history (using noice.nvim instead of mini.notify)
vim.keymap.set("n", "<leader>Fn", function()
  local ok = pcall(vim.cmd, "Noice history")
  if not ok then
    vim.notify("Noice not available, showing vim messages", vim.log.levels.WARN)
    vim.cmd "messages"
  end
end, { desc = "Show notification history" })

-- Messages integration with yank capability
vim.keymap.set("n", "<leader>Fm", function()
  -- Get messages
  local messages_str = vim.fn.execute "messages"
  local messages = vim.split(messages_str, "\n")

  -- Filter out empty lines
  local filtered_messages = {}
  for _, msg in ipairs(messages) do
    if msg:match "%S" then -- has non-whitespace content
      table.insert(filtered_messages, msg)
    end
  end

  if #filtered_messages == 0 then
    vim.notify("No messages to show", vim.log.levels.INFO)
    return
  end

  -- Use mini.pick to select and yank
  require("mini.pick").start {
    source = {
      items = filtered_messages,
      name = "Vim Messages",
    },
    mappings = {
      choose = function(item)
        if item then
          vim.fn.setreg("+", item)
          vim.fn.setreg('"', item)
          vim.notify("Yanked: " .. item:sub(1, 50) .. (item:len() > 50 and "..." or ""), vim.log.levels.INFO)
        end
      end,
    },
  }
end, { desc = "Pick and yank vim messages" })

-- Setup extra pickers if mini.extra is available
vim.schedule(setup_extra_pickers)
