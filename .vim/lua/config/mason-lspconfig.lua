local mason_lspconfig = Safe_require "mason-lspconfig"
local lspconfig = Safe_require "lspconfig"

local with = require("utils").with
local on_attach = function() end
local languages = require("lsp.efm").get_languages()
local capabilities = require("lsp.capabilities").setup()
local config = require "lsp.config"

if not (mason_lspconfig and lspconfig) then return end

mason_lspconfig.setup {
  ensure_installed = config.installed_servers,
  automatic_installation = true,
}

mason_lspconfig.setup_handlers {
  function(server)
    local opts = { on_attach = on_attach, capabilities = capabilities }
    local extends = Safe_require("lsp.settings." .. server)
    lspconfig[server].setup(with(opts, extends))
  end,
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
