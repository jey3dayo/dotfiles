-- OS-specific configurations
local M = {}

-- Detect OS type
M.is_wsl = function()
  return vim.fn.has "wsl" == 1
end

M.is_mac = function()
  return vim.fn.has "mac" == 1 or vim.fn.has "macunix" == 1
end

M.is_windows = function()
  return vim.fn.has "win32" == 1 or vim.fn.has "win64" == 1
end

M.is_linux = function()
  return vim.fn.has "unix" == 1 and not M.is_mac() and not M.is_wsl()
end

-- Setup clipboard for WSL2
M.setup_wsl_clipboard = function()
  if not M.is_wsl() then return end

  -- WSL2でwin32yank.exeを使用したクリップボード設定
  vim.g.clipboard = {
    name = "win32yank-wsl",
    copy = {
      ["+"] = "/mnt/d/Programs/Neovim/bin/win32yank.exe -i --crlf",
      ["*"] = "/mnt/d/Programs/Neovim/bin/win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "/mnt/d/Programs/Neovim/bin/win32yank.exe -o --lf",
      ["*"] = "/mnt/d/Programs/Neovim/bin/win32yank.exe -o --lf",
    },
    cache_enabled = 0,
  }
end

-- Initialize OS-specific configurations immediately when module loads
M.setup_wsl_clipboard()

return M
