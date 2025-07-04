local M = {}

M.buffer_not_empty = function()
  return vim.fn.empty(vim.fn.expand "%:t") ~= 1
end

M.hide_in_width = function()
  return vim.fn.winwidth(0) > 80
end

M.check_git_workspace = function()
  local filepath = vim.fn.expand "%:p:h"
  local gitdir = vim.fn.finddir(".git", filepath .. ";")
  return gitdir and #gitdir > 0 and #gitdir < #filepath
end

return M
