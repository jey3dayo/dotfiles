local utils = require "core.utils"
local mason_lspconfig = utils.safe_require "mason-lspconfig"
local lspconfig = utils.safe_require "lspconfig"
local compat = require "lsp.compat"

local with = utils.with
local on_attach = function() end
local languages = require("lsp.efm").get_languages()
local capabilities = require("lsp.capabilities").setup()
local config = require "lsp.config"

if not (mason_lspconfig and lspconfig) then return end

local disabled_servers = { "efm" }  -- Manually setup efm to prevent duplicate

-- Global LSP configuration (applied to all servers)
compat.add_config('*', {
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Setup individual LSP servers
for _, server in ipairs(config.enabled_servers) do
  if server ~= "efm" then
    local extends = utils.safe_require("lsp.settings." .. server)
    if extends then
      if extends.autostart == false then
        table.insert(disabled_servers, server)
      else
        -- Server-specific configuration
        compat.add_config(server, extends)
      end
    elseif not compat.has_new_api then
      -- v0.10: Setup server without custom config
      compat.add_config(server, {})
    end
  end
end

mason_lspconfig.setup {
  ensure_installed = config.installed_servers,
  automatic_installation = true,
  automatic_enable = {
    exclude = disabled_servers,
  },
}

-- Enable all configured servers (v0.11+ only)
if compat.has_new_api then
  local enabled_servers = vim.tbl_filter(function(s)
    return not vim.tbl_contains(disabled_servers, s)
  end, config.enabled_servers)
  compat.enable(enabled_servers)
end

-- Setup EFM only once using singleton pattern
local efm_singleton = require "lsp.efm_singleton"
efm_singleton.setup {
  filetypes = vim.tbl_keys(languages),
  settings = {
    rootMarkers = config.config_files,
    languages = languages,
  },
  init_options = { documentFormatting = true, documentRangeFormatting = true },
  on_attach = on_attach,
  capabilities = capabilities,
}
