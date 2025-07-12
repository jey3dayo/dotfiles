local utils = require "core.utils"
local mason_lspconfig = utils.safe_require "mason-lspconfig"
local lspconfig = utils.safe_require "lspconfig"
local compat = require "lsp.compat"

local with = utils.with
local handlers = require "lsp.handlers"
local on_attach = handlers.on_attach
local capabilities = require("lsp.capabilities").setup()
local config = require "lsp.config"

if not (mason_lspconfig and lspconfig) then return end

local disabled_servers = {} -- No manually disabled servers

-- Collect servers that should be disabled based on autostart conditions
for _, server in ipairs(config.enabled_servers) do
  local extends = utils.safe_require("lsp.settings." .. server)
  if extends then
    local should_disable = false
    if type(extends.autostart) == "function" then
      should_disable = not extends.autostart()
    elseif extends.autostart == false then
      should_disable = true
    end

    if should_disable then
      table.insert(disabled_servers, server)
      if vim.g.lsp_debug then
        vim.notify(string.format("Server %s disabled by autostart", server), vim.log.levels.INFO)
      end
    end
  end
end

mason_lspconfig.setup {
  ensure_installed = config.installed_servers,
  automatic_installation = true,
  automatic_enable = {
    exclude = disabled_servers,
  },
  handlers = {
    -- Default handler for all servers
    function(server_name)
      if vim.g.lsp_debug then
        vim.notify(string.format("Mason handler called for: %s", server_name), vim.log.levels.INFO)
      end

      -- Skip if disabled
      if vim.tbl_contains(disabled_servers, server_name) then
        if vim.g.lsp_debug then
          vim.notify(string.format("Skipping %s (disabled)", server_name), vim.log.levels.INFO)
        end
        return
      end

      -- Get server config if available
      local server_config = {
        on_attach = on_attach,
        capabilities = capabilities,
        handlers = handlers.handlers,
      }
      local extends = utils.safe_require("lsp.settings." .. server_name)
      if extends then server_config = vim.tbl_deep_extend("force", server_config, extends) end

      -- Setup the server
      if vim.g.lsp_debug then vim.notify(string.format("Setting up %s", server_name), vim.log.levels.INFO) end
      require("lspconfig")[server_name].setup(server_config)
    end,
  },
}

-- Debug: Print disabled servers
if vim.g.lsp_debug then vim.notify("Disabled servers: " .. vim.inspect(disabled_servers), vim.log.levels.INFO) end
