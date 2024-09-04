local lspconfig = safe_require "lspconfig"

if not lspconfig then
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

-- Or use the defaults provided by this plugin
-- check doc/SUPPORTED_LIST.md for the supported languages

local efmls_config = {
  filetypes = vim.tbl_keys(languages),
  settings = {
    rootMarkers = { ".git/" },
    languages = languages,
  },
  init_options = {
    documentFormatting = true,
    documentRangeFormatting = true,
  },
}

lspconfig.efm.setup(vim.tbl_extend("force", efmls_config, {
  -- Pass your custom lsp config below like on_attach and capabilities
  -- on_attach = on_attach,
  -- capabilities = capabilities,
}))
