local utils = require "core.utils"
local mason_lspconfig = utils.safe_require "mason-lspconfig"
if not mason_lspconfig then return end

mason_lspconfig.setup {
  ensure_installed = require("lsp.config").servers,
  automatic_enable = false,
}
