local M = {}

local function close_files()
  pcall(vim.cmd, "MiniFilesClose")
end

local function session_name()
  return vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. ".vim"
end

local function setup_keymaps()
  local sessions = require "mini.sessions"

  vim.keymap.set("n", "<leader>ss", function()
    sessions.write(session_name())
  end, { desc = "Session save" })
  vim.keymap.set("n", "<leader>sr", function()
    sessions.select "read"
  end, { desc = "Session restore" })
  vim.keymap.set("n", "<leader>sd", function()
    sessions.select "delete"
  end, { desc = "Session delete" })
  vim.keymap.set("n", "<leader>sl", function()
    sessions.select "read"
  end, { desc = "List sessions" })
end

function M.setup()
  require("mini.sessions").setup {
    autoread = true,
    autowrite = true,
    directory = vim.fn.stdpath "state" .. "/sessions/",
    file = "session.vim",
    hooks = {
      pre = {
        write = close_files,
      },
      post = {
        read = function() end,
      },
    },
  }

  vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
  setup_keymaps()
end

return M
