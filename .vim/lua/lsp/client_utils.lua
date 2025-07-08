--- Simplified LSP client utilities
--- Replaces client_manager.lua, client_tracker.lua, and safe_client.lua
--- @module lsp.client_utils
local M = {}

--- Safely get LSP client by ID
--- @param client_id number|nil Client ID to retrieve
--- @return table|nil LSP client object or nil if not found/invalid
function M.get_client_by_id(client_id)
  if not client_id or type(client_id) ~= "number" then 
    return nil 
  end
  
  local ok, client = pcall(vim.lsp.get_client_by_id, client_id)
  return ok and client or nil
end

--- Safely get LSP clients for buffer
--- @param bufnr number|nil Buffer number (defaults to current buffer)
--- @return table[] List of LSP clients (empty if error)
function M.get_clients(bufnr)
  bufnr = bufnr or 0
  local ok, clients = pcall(vim.lsp.get_clients, { bufnr = bufnr })
  return ok and clients or {}
end

--- Get clients that support document formatting
--- @param bufnr number|nil Buffer number (defaults to current buffer)
--- @return table[] List of formatting-capable clients
function M.get_format_clients(bufnr)
  local clients = M.get_clients(bufnr)
  return vim.tbl_filter(function(client)
    return client.server_capabilities.documentFormattingProvider
  end, clients)
end

--- Get the best formatter client based on priority
--- @param bufnr number|nil Buffer number (defaults to current buffer)
--- @return table|nil Best formatter client or nil
function M.get_best_formatter(bufnr)
  local clients = M.get_format_clients(bufnr)
  if #clients == 0 then return nil end
  
  -- Use formatter priority from config
  local config = require("lsp.config").formatters
  table.sort(clients, function(a, b)
    local a_priority = config[a.name] and config[a.name].formatter_priority and config[a.name].formatter_priority.priority or 99
    local b_priority = config[b.name] and config[b.name].formatter_priority and config[b.name].formatter_priority.priority or 99
    return a_priority < b_priority
  end)
  
  return clients[1]
end

--- Check if client supports a method
--- @param client table LSP client
--- @param method string LSP method name
--- @return boolean True if method is supported
function M.supports_method(client, method)
  if not client then return false end
  return client.supports_method and client.supports_method(method) or false
end

--- Get all LSP client names for buffer (for lualine)
--- @param bufnr number|nil Buffer number (defaults to current buffer)
--- @return string Comma-separated list of client names
function M.get_all_lsp_client_names(bufnr)
  local clients = M.get_clients(bufnr)
  if #clients == 0 then return "" end
  
  local names = {}
  for _, client in ipairs(clients) do
    table.insert(names, client.name)
  end
  return table.concat(names, ", ")
end

--- Get formatting LSP client names for buffer (for lualine)
--- @param bufnr number|nil Buffer number (defaults to current buffer)
--- @return string Comma-separated list of formatting client names
function M.get_lsp_client_names(bufnr)
  local clients = M.get_format_clients(bufnr)
  if #clients == 0 then return "" end
  
  local names = {}
  for _, client in ipairs(clients) do
    table.insert(names, client.name)
  end
  return table.concat(names, ", ")
end

return M