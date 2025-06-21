-- Safe wrapper for LSP client operations to prevent "No client with id" errors
local M = {}

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

-- Override the global function to add safety
local original_get_client = vim.lsp.get_client_by_id
vim.lsp.get_client_by_id = function(id)
  local ok, result = pcall(original_get_client, id)
  if ok then
    return result
  else
    -- Silently return nil instead of throwing error
    return nil
  end
end

-- Also wrap get_active_clients for safety
local original_get_active = vim.lsp.get_active_clients
vim.lsp.get_active_clients = function(opts)
  local ok, result = pcall(original_get_active, opts)
  if ok then
    return result
  else
    -- Return empty table on error
    return {}
  end
end

return M
