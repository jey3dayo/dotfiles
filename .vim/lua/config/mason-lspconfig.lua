local utils = require "core.utils"
local mason_lspconfig = utils.safe_require "mason-lspconfig"
local lspconfig = utils.safe_require "lspconfig"

local with = utils.with
local on_attach = function() end
local languages = require("lsp.efm").get_languages()
local capabilities = require("lsp.capabilities").setup()
local config = require "lsp.config"

if not (mason_lspconfig and lspconfig) then return end

local disabled_servers = {}

for _, server in ipairs(config.enabled_servers) do
  local extends = utils.safe_require("lsp.settings." .. server)
  if extends and type(extends) == "table" and extends.autostart == false then
    table.insert(disabled_servers, server)
  else
    local opts = { on_attach = on_attach, capabilities = capabilities }
    vim.lsp.config(server, with(opts, extends))
  end
end

mason_lspconfig.setup {
  ensure_installed = config.installed_servers,
  automatic_installation = true,
  automatic_enable = {
    exclude = disabled_servers,
  },
}

lspconfig.efm.setup {
  filetypes = vim.tbl_keys(languages),
  settings = {
    rootMarkers = config.config_files,
    languages = languages,
  },
  init_options = { documentFormatting = true, documentRangeFormatting = true },
  on_attach = on_attach,
  capabilities = capabilities,
}
