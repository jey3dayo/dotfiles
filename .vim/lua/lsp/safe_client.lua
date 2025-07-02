--- Safe LSP client operations with defensive programming
--- @module lsp.safe_client
--- Provides safe wrappers around vim.lsp client operations to prevent crashes
local M = {}

--- Safely get LSP client by ID with proper error handling
--- @param client_id number|nil Client ID to retrieve
--- @return table|nil LSP client object or nil if not found/invalid
function M.get_client_by_id(client_id)
  if not client_id or type(client_id) ~= "number" then 
    return nil 
  end
  
  local ok, client = pcall(vim.lsp.get_client_by_id, client_id)
  return ok and client or nil
end

--- Safely get LSP clients with proper error handling
--- @param opts table|nil Options for vim.lsp.get_clients
--- @return table[] List of LSP clients (empty if error)
function M.get_clients(opts)
  local ok, clients = pcall(vim.lsp.get_clients, opts)
  return ok and clients or {}
end

--- Check if LSP client exists and is valid (not stopped)
--- @param client_id number Client ID to validate
--- @return boolean True if client is valid and running
function M.is_client_valid(client_id)
  local client = M.get_client_by_id(client_id)
  if not client then return false end
  
  -- Check if client has necessary methods and is not stopped
  local ok, is_stopped = pcall(function() return client.is_stopped() end)
  return ok and not is_stopped
end

--- Safely execute LSP client request with error handling
--- @param client_id number Client ID
--- @param method string LSP method name
--- @param params table|nil Request parameters
--- @param handler function|nil Response handler
--- @param bufnr number|nil Buffer number
--- @return boolean Success status
function M.safe_client_request(client_id, method, params, handler, bufnr)
  if not M.is_client_valid(client_id) then
    if handler then
      handler("Client not available", nil)
    end
    return false
  end
  
  local client = M.get_client_by_id(client_id)
  local ok, supports = pcall(function() return client:supports_method(method) end)
  if not ok or not supports then
    if handler then
      handler("Method not supported", nil)
    end
    return false
  end
  
  local success, result = pcall(client.request, client, method, params, handler, bufnr)
  return success and result or false
end

-- Safe buffer formatting
function M.safe_format(bufnr, client_id, opts)
  local client = M.get_client_by_id(client_id)
  if not client or not client:supports_method("textDocument/formatting") then
    return false
  end
  
  opts = opts or {}
  opts.bufnr = bufnr
  opts.id = client_id
  
  vim.lsp.buf.format(opts)
  return true
end

-- Get all formatting-capable clients for buffer
function M.get_format_clients(bufnr)
  local clients = M.get_clients({ bufnr = bufnr })
  return vim.tbl_filter(function(client)
    return client:supports_method("textDocument/formatting")
  end, clients)
end

-- Clean up stopped clients (called from autocmd)
function M.cleanup_stopped_clients()
  -- This is handled by Neovim internally, we just provide a safe interface
  -- No aggressive cleanup needed
end

return M