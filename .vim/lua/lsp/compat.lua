--- LSP compatibility layer for Neovim v0.10/v0.11+
--- Provides unified API for different Neovim versions
local M = {}

-- Check if new LSP API is available (v0.11+)
M.has_new_api = vim.lsp and vim.lsp.config ~= nil

--- Check if client supports a method (compatible with v0.10 and v0.11+)
--- @param client table LSP client
--- @param method string LSP method name
--- @return boolean
function M.supports_method(client, method)
  -- Safety check for nil client
  if not client then
    return false
  end
  
  -- v0.11+: client:supports_method(method) - colon syntax
  -- v0.10: client.supports_method(method) - dot syntax
  if type(client.supports_method) == "function" then
    -- Try new syntax first (v0.11+)
    local ok, result = pcall(function()
      return client:supports_method(method)
    end)
    if ok then
      return result
    end
    -- Fallback to old syntax (v0.10)
    local ok2, result2 = pcall(function()
      return client.supports_method(method)
    end)
    if ok2 then
      return result2
    end
  end
  
  -- Fallback: check server_capabilities manually
  if client.server_capabilities then
    -- TypeScript/JavaScript specific check
    if method == "textDocument/references" then
      return client.server_capabilities.referencesProvider ~= nil
    elseif method == "textDocument/documentSymbol" then
      return client.server_capabilities.documentSymbolProvider ~= nil
    elseif method == "textDocument/formatting" then
      return client.server_capabilities.documentFormattingProvider ~= nil
    end
    
    -- Generic capability check
    local capability = method:match("textDocument/(.+)")
    if capability then
      return client.server_capabilities[capability .. "Provider"] ~= nil
    end
  end
  
  -- Default to true for common TypeScript LSP methods
  local common_methods = {
    "textDocument/references",
    "textDocument/definition", 
    "textDocument/hover",
    "textDocument/documentSymbol"
  }
  for _, common_method in ipairs(common_methods) do
    if method == common_method then
      return true
    end
  end
  
  return false
end

--- Register LSP server configuration
--- @param name string Server name or "*" for global config
--- @param config table Server configuration
function M.add_config(name, config)
  if M.has_new_api then
    -- v0.11+: Use new built-in API
    vim.lsp.config(name, config)
    -- Enable the server (required in v0.11+)
    if name ~= "*" then
      vim.lsp.enable(name)
    end
  else
    -- v0.10: Use lspconfig
    if name == "*" then
      -- Global config not supported in v0.10, will be applied per-server
      M._global_config = config
    else
      local lspconfig = require("lspconfig")
      -- Merge with global config if exists
      if M._global_config then
        config = vim.tbl_deep_extend("force", M._global_config, config)
      end
      lspconfig[name].setup(config)
    end
  end
end

--- Enable LSP servers
--- @param servers? string[] List of server names (nil = all)
function M.enable(servers)
  if M.has_new_api then
    -- v0.11+: Use new enable API
    if servers then
      -- Enable each server individually
      for _, server in ipairs(servers) do
        vim.lsp.enable(server)
      end
    else
      -- Enable all servers
      vim.lsp.enable()
    end
  else
    -- v0.10: Already enabled via lspconfig.setup()
    -- Nothing to do here
  end
end

--- Storage for global config in v0.10
M._global_config = nil

return M