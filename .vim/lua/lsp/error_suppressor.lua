-- Aggressive LSP error suppression
local M = {}

-- Hijack vim.api.nvim_err_writeln to suppress specific errors
local original_err_writeln = vim.api.nvim_err_writeln
vim.api.nvim_err_writeln = function(msg)
  if type(msg) == "string" and msg:find("No client with id", 1, true) then
    return  -- Suppress these specific errors
  end
  return original_err_writeln(msg)
end

-- Override vim.schedule for any deferred error reporting
local original_schedule = vim.schedule
vim.schedule = function(fn)
  return original_schedule(function()
    local ok, err = pcall(fn)
    if not ok and type(err) == "string" and err:find("No client with id", 1, true) then
      return  -- Suppress LSP client ID errors in scheduled functions
    end
    if not ok then
      error(err)
    end
  end)
end

-- Override error handling in vim.lsp namespace
if vim.lsp and vim.lsp.rpc then
  local original_notify_error = vim.lsp.rpc.notify_error or function() end
  vim.lsp.rpc.notify_error = function(code, err, ...)
    if type(err) == "string" and err:find("No client with id", 1, true) then
      return  -- Suppress LSP RPC errors about missing clients
    end
    return original_notify_error(code, err, ...)
  end
end

return M