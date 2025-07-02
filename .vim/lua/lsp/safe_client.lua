-- Safe wrapper for LSP client operations to prevent "No client with id" errors
local M = {}

-- Try to get client tracker if available
local tracker = nil
pcall(function() tracker = require('lsp.client_tracker') end)

-- Track original functions immediately
local original_get_client = vim.lsp.get_client_by_id
local original_get_clients = vim.lsp.get_clients

-- Apply overrides immediately when module is loaded
M.init = function()
  -- Override vim.lsp.get_client_by_id immediately with silent fallback
  vim.lsp.get_client_by_id = function(id)
    local ok, result = pcall(original_get_client, id)
    if ok and result then
      return result
    else
      -- 完全にサイレント：nilを返すだけ
      return nil
    end
  end

  -- Also wrap get_clients for safety
  vim.lsp.get_clients = function(opts)
    local ok, result = pcall(original_get_clients, opts)
    if ok then
      return result
    else
      vim.notify("[LSP] Error getting clients", vim.log.levels.WARN)
      return {}
    end
  end
end

-- Initialize immediately
M.init()

-- Additional safety: Override any remaining error sources
vim.defer_fn(function()
  -- Force override any late-loaded LSP functions
  local original_get_client_final = vim.lsp.get_client_by_id
  vim.lsp.get_client_by_id = function(id)
    local result = original_get_client_final(id)
    return result or nil  -- Always return nil instead of throwing
  end
  
  -- Last resort: Filter LSP error messages
  local original_notify = vim.notify
  vim.notify = function(msg, level, opts)
    -- Suppress specific LSP client ID errors more aggressively
    if type(msg) == "string" and (
      msg:match("No client with id %d+") or 
      msg:match("%[LSP%] No client with id %d+") or
      msg:find("No client with id", 1, true)
    ) then
      return  -- Completely suppress these messages
    end
    return original_notify(msg, level, opts)
  end
  
  -- Also override vim.lsp.log for internal LSP logging
  if vim.lsp.log and vim.lsp.log.error then
    local original_lsp_error = vim.lsp.log.error
    vim.lsp.log.error = function(msg, ...)
      if type(msg) == "string" and msg:find("No client with id", 1, true) then
        return  -- Suppress LSP internal error logs
      end
      return original_lsp_error(msg, ...)
    end
  end
end, 100)

-- Safely get client by ID with error handling
function M.get_client_by_id(client_id)
  if not client_id then return nil end
  
  -- Use pcall to catch any errors
  local ok, client = pcall(vim.lsp.get_client_by_id, client_id)
  if ok then
    return client
  else
    return nil
  end
end

-- The overrides are now in the init() function above

return M
