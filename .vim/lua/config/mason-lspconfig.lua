local mason_lspconfig = safe_require "mason-lspconfig"
local lspconfig = safe_require "lspconfig"
local with = require("utils").with

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
      on_attach = require("lsp.handlers").on_attach,
      capabilities = require("lsp.handlers").capabilities,
    }
    local server_custom_opts = safe_require("lsp.settings." .. server)

    lspconfig[server].setup(with(opts, server_custom_opts))
  end,
}
