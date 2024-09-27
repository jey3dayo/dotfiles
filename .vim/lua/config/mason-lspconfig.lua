local mason_lspconfig = safe_require "mason-lspconfig"
local lspconfig = safe_require "lspconfig"

local with = require("utils").with
local on_attach = require("lsp.handlers").on_attach
local capabilities = require("lsp.handlers").capabilities
local languages = require("lsp.config").efm_languages


if not (mason_lspconfig and lspconfig) then
  return
end

mason_lspconfig.setup {
  ensure_installed = require("lsp.config").installed_servers,
  automatic_installation = true,
}

mason_lspconfig.setup_handlers {
  function(server)
    local opts = {
      on_attach = on_attach,
      capabilities = capabilities,
    }
    local extends = safe_require("lsp.settings." .. server)

    lspconfig[server].setup(with(opts, extends))
  end,
}

lspconfig.efm.setup {
  filetypes = vim.tbl_keys(languages),
  settings = {
    rootMarkers = { ".git/" },
    languages = languages,
  },
  init_options = {
    documentFormatting = true,
    documentRangeFormatting = true,
  },
  on_attach = on_attach,
  capabilities = capabilities,
}
