-- Mini.pick configuration and keymaps

local utils = require "core.utils"

local M = {}

-- Helper functions
local function get_git_dir()
  return utils.get_git_dir and utils.get_git_dir() or vim.fn.systemlist("git rev-parse --show-toplevel")[1] or ""
end

local function with_extra(fn)
  local pick_ok = pcall(require, "mini.pick")
  if not pick_ok then
    vim.notify("mini.pick not available", vim.log.levels.ERROR)
    return
  end

  local ok_extra, mini_extra = pcall(require, "mini.extra")
  if not ok_extra then
    vim.notify("mini.extra not available", vim.log.levels.WARN)
    return
  end
  fn(mini_extra)
end

-- Single source of truth for keymaps (used for lazy keys & setup)
local mappings = {
  {
    lhs = "<Leader>f",
    desc = "Find files",
    rhs = function()
      require("mini.pick").builtin.files()
    end,
  },
  {
    lhs = "<Leader><Leader>",
    desc = "Resume last pick",
    rhs = function()
      local ok, mini_pick = pcall(require, "mini.pick")
      if ok then
        local success = pcall(mini_pick.builtin.resume)
        if not success then vim.notify("No picker to resume", vim.log.levels.INFO) end
      else
        vim.notify("mini.pick not available", vim.log.levels.ERROR)
      end
    end,
  },
  {
    lhs = ",gr",
    desc = "Live grep",
    rhs = function()
      require("mini.pick").builtin.grep_live()
    end,
  },
  {
    lhs = "<Leader>b",
    desc = "Find buffers",
    rhs = function()
      require("mini.pick").builtin.buffers()
    end,
  },
  {
    lhs = "<Leader>Fh",
    desc = "Find help",
    rhs = function()
      require("mini.pick").builtin.help()
    end,
  },
  {
    lhs = "<Leader>Fr",
    desc = "Recent files (smart)",
    rhs = function()
      with_extra(function(extra)
        extra.pickers.visit_paths()
      end)
    end,
  },
  {
    lhs = "<Leader>Fk",
    desc = "Find keymaps",
    rhs = function()
      with_extra(function(extra)
        extra.pickers.keymaps()
      end)
    end,
  },
  {
    lhs = "<Leader>d",
    desc = "Diagnostics",
    rhs = function()
      with_extra(function(extra)
        extra.pickers.diagnostic()
      end)
    end,
  },
  {
    lhs = "<Leader>Fs",
    desc = "Document symbols",
    rhs = function()
      with_extra(function(extra)
        extra.pickers.lsp { scope = "document_symbol" }
      end)
    end,
  },
  {
    lhs = "<Leader>FS",
    desc = "Workspace symbols",
    rhs = function()
      with_extra(function(extra)
        extra.pickers.lsp { scope = "workspace_symbol" }
      end)
    end,
  },
  {
    lhs = "<Leader>e",
    desc = "Open mini.files (git root or buffer dir)",
    rhs = function()
      local git_dir = get_git_dir()
      local current_file = vim.fn.expand "%:p"
      local path = vim.fn.getcwd() -- Default to current working directory

      -- Always use cwd for special buffers like ministarter
      if string.match(current_file, "^%w+:") then
        path = vim.fn.getcwd()
      elseif current_file ~= "" and vim.fn.filereadable(current_file) == 1 then
        path = vim.fn.expand "%:p:h"
      elseif git_dir ~= "" then
        path = git_dir
      end

      require("mini.files").open(path, true)
    end,
  },
  {
    lhs = "<Leader>E",
    desc = "Open mini.files (buffer dir)",
    rhs = function()
      require("mini.files").open(vim.fn.expand "%:p:h", true)
    end,
  },
  {
    lhs = "<Leader>y",
    desc = "Pick from registers",
    rhs = function()
      with_extra(function(extra)
        extra.pickers.registers()
      end)
    end,
  },
  {
    lhs = "<leader>Fn",
    desc = "Show notification history",
    rhs = function()
      local ok = pcall(vim.cmd, "Noice history")
      if not ok then
        vim.notify("Noice not available, showing vim messages", vim.log.levels.WARN)
        vim.cmd "messages"
      end
    end,
  },
  {
    lhs = "<leader>Fm",
    desc = "Pick and yank vim messages",
    rhs = function()
      local messages_str = vim.fn.execute "messages"
      local messages = vim.split(messages_str, "\n")

      local filtered_messages = {}
      for _, msg in ipairs(messages) do
        if msg:match "%S" then table.insert(filtered_messages, msg) end
      end

      if #filtered_messages == 0 then
        vim.notify("No messages to show", vim.log.levels.INFO)
        return
      end

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
    end,
  },
}

function M.setup()
  for _, map in ipairs(mappings) do
    vim.keymap.set(map.mode or "n", map.lhs, map.rhs, { desc = map.desc })
  end
end

function M.keys()
  local keys = {}
  for _, map in ipairs(mappings) do
    table.insert(keys, { map.lhs, desc = map.desc, mode = map.mode or "n" })
  end
  return keys
end

return M
