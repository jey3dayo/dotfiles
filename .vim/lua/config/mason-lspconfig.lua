local mason_lspconfig = safe_require "mason-lspconfig"
local lspconfig = safe_require "lspconfig"
local with = require("utils").with

if not (mason_lspconfig and lspconfig) then
  return
end

local biome = require "efmls-configs.formatters.biome"
local eslint = require "efmls-configs.linters.eslint"
local fixjson = require "efmls-configs.formatters.fixjson"
local hadolint = require "efmls-configs.linters.hadolint"
local markdownlint = require "efmls-configs.linters.markdownlint"
local prettier = require "efmls-configs.formatters.prettier"
local ruff_formatter = require "efmls-configs.formatters.ruff"
local ruff_linter = require "efmls-configs.linters.ruff"
local ruff_sort = require "efmls-configs.formatters.ruff_sort"
local shellcheck = require "efmls-configs.linters.shellcheck"
local shfmt = require "efmls-configs.formatters.shfmt"
local stylua = require "efmls-configs.formatters.stylua"
local taplo = require "efmls-configs.formatters.taplo"
local vint = require "efmls-configs.linters.vint"
local yamllint = require "efmls-configs.linters.yamllint"
local codespell = require "efmls-configs.linters.codespell"
local gitlint = require "efmls-configs.linters.gitlint"
local jsonlint = require "efmls-configs.linters.jsonlint"
local luacheck = require "efmls-configs.linters.luacheck"
local gofmt = require "efmls-configs.formatters.gofmt"

mason_lspconfig.setup {
  ensure_installed = require("lsp.config").installed_servers,
  automatic_installation = true,
}

local on_attach = require("lsp.handlers").on_attach
local capabilities = require("lsp.handlers").capabilities

mason_lspconfig.setup_handlers {
  function(server)
    local opts = {
      on_attach = on_attach,
      capabilities = capabilities,
    }
    local server_custom_opts = safe_require("lsp.settings." .. server)

    lspconfig[server].setup(with(opts, server_custom_opts))
  end,
}

local languages = {
  javascript = { biome, eslint, prettier },
  typescript = { biome, eslint, prettier },
  html = { prettier },
  css = { prettier },
  python = { ruff_linter, ruff_formatter, ruff_sort },
  lua = { stylua, luacheck },
  markdown = { markdownlint },
  dockerfile = { hadolint },
  json = { fixjson, jsonlint },
  yaml = { yamllint },
  sh = { shellcheck, shfmt },
  vim = { vint },
  toml = { taplo },
  go = { gofmt },
  gitcommit = { gitlint },
  text = { codespell },
}

local efmls_config = {
  filetypes = vim.tbl_keys(languages),
  settings = {
    rootMarkers = { ".git/" },
    languages = languages,
  },
  init_options = {
    documentFormatting = true,
    -- documentRangeFormatting = true,
  },
}
lspconfig.efm.setup(with(efmls_config, {
  -- Pass your custom lsp config below like on_attach and capabilities
      on_attach = on_attach,
  capabilities = capabilities,
}))
