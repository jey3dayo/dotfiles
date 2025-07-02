-- Safe LSP client operations with defensive programming
local M = {}

-- Safely get client by ID with proper error handling
function M.get_client_by_id(client_id)
  if not client_id or type(client_id) ~= "number" then 
    return nil 
  end
  
  local ok, client = pcall(vim.lsp.get_client_by_id, client_id)
  return ok and client or nil
end

-- Safely get clients with proper error handling
function M.get_clients(opts)
  local ok, clients = pcall(vim.lsp.get_clients, opts)
  return ok and clients or {}
end

-- Check if client exists and is valid
function M.is_client_valid(client_id)
  local client = M.get_client_by_id(client_id)
  return client ~= nil and client.is_stopped and not client.is_stopped()
end

-- Safe client method execution
function M.safe_client_request(client_id, method, params, handler, bufnr)
  local client = M.get_client_by_id(client_id)
  if not client then
    if handler then
      handler("Client not found", nil)
    end
    return false
  end
  
  if not client:supports_method(method) then
    if handler then
      handler("Method not supported", nil)
    end
    return false
  end
  
  return client.request(method, params, handler, bufnr)
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