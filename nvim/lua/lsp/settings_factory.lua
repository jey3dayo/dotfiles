local M = {}
local loader = require "core.module_loader"

-- Common dependencies loaded once and cached
local deps = loader.require_batch {
  ft = "core.filetypes",
  core_utils = "core.utils",
  utils = "lsp.utils",
  config = "lsp.config",
  capabilities = "lsp.capabilities",
  handlers = "lsp.handlers",
}

-- Base configuration templates
local base_configs = {
  -- JavaScript/TypeScript family
  js_server = {
    filetypes = deps.ft and deps.ft.js_project or { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    capabilities = deps.capabilities and deps.capabilities.setup() or nil,
    handlers = deps.handlers and deps.handlers.handlers or nil,
    on_attach = deps.handlers and deps.handlers.on_attach or nil,
  },

  -- Generic language server
  generic = {
    capabilities = deps.capabilities and deps.capabilities.setup() or nil,
    handlers = deps.handlers and deps.handlers.handlers or nil,
    on_attach = deps.handlers and deps.handlers.on_attach or nil,
  },

  -- Formatter-only server
  formatter = {
    capabilities = deps.capabilities and deps.capabilities.setup() or nil,
    on_attach = function(client, bufnr)
      -- Disable hover for formatter-only servers
      client.server_capabilities.hoverProvider = false
      if deps.handlers and deps.handlers.on_attach then deps.handlers.on_attach(client, bufnr) end
    end,
  },
}

-- Factory functions for common server types
function M.create_js_server(server_name, overrides)
  overrides = overrides or {}

  local config = vim.deepcopy(base_configs.js_server)

  -- Add root directory detection if config exists
  if deps.config and deps.config.formatters and deps.config.formatters[server_name] then
    local config_files = deps.config.formatters[server_name].config_files
    if deps.utils and deps.utils.create_root_pattern then
      config.root_dir = deps.utils.create_root_pattern(config_files)
    end
  end

  return vim.tbl_deep_extend("force", config, overrides)
end

function M.create_formatter_server(server_name, overrides)
  overrides = overrides or {}

  local config = vim.deepcopy(base_configs.formatter)

  -- Add root_dir gating for formatter servers.
  -- This keeps attach behavior project-local without relying on startup cwd.
  if deps.config and deps.config.formatters and deps.config.formatters[server_name] then
    local formatter_config = deps.config.formatters[server_name]
    if formatter_config.config_files then
      -- Add root_dir detection
      if deps.utils and deps.utils.create_root_pattern then
        config.root_dir = deps.utils.create_root_pattern(formatter_config.config_files)
      end
    end
  end

  return vim.tbl_deep_extend("force", config, overrides)
end

function M.create_generic_server(overrides)
  overrides = overrides or {}
  return vim.tbl_deep_extend("force", base_configs.generic, overrides)
end

-- Convenience function to create root directory patterns
function M.create_root_dir(config_files, fallback_files)
  if not deps.utils or not deps.utils.create_root_pattern then return nil end

  local files = vim.list_extend(vim.deepcopy(config_files or {}), fallback_files or { "package.json", ".git" })

  return deps.utils.create_root_pattern(files)
end

-- Get common filetypes
function M.get_filetypes(category)
  if not deps.ft then return {} end

  return deps.ft[category] or {}
end

-- Helper to check if dependencies are loaded
function M.check_deps()
  local missing = {}
  for name, dep in pairs(deps) do
    if not dep then table.insert(missing, name) end
  end

  if #missing > 0 then
    vim.notify("LSP Settings Factory: Missing dependencies: " .. table.concat(missing, ", "), vim.log.levels.WARN)
    return false
  end

  return true
end

return M
