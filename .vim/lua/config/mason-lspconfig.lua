local mason_lspconfig = Safe_require "mason-lspconfig"
local lspconfig = Safe_require "lspconfig"

local with = require("utils").with
local on_attach = function() end
local languages = require("lsp.efm").get_languages()
local capabilities = require("lsp.capabilities").setup()
local config = require "lsp.config"

if not (mason_lspconfig and lspconfig) then return end

-- TODO: 他のパラメータが機能してないので、読み取るか消すか考える
-- excludeリストを動的生成
local exclude = { "rust_analyzer" }
for _, server in ipairs(config.autostart_servers) do
  local extends = Safe_require("lsp.settings." .. server)
  if extends and type(extends) == "table" and extends.autostart == false then
    table.insert(exclude, server)
  end
end

-- excludeリストをデバッグ用に表示
print("Exclude servers:")
for _, server in ipairs(exclude) do
  print(server)
end

mason_lspconfig.setup {
  ensure_installed = config.installed_servers,
  automatic_installation = true,
  automatic_enable = {
    exclude = exclude,
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
