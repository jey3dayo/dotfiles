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
local jsonlint = require "efmls-configs.linters.jsonlint"
local luacheck = require "efmls-configs.linters.luacheck"
local gofmt = require "efmls-configs.formatters.gofmt"

local M = {}

M.installed_servers = {
  "astro",
  "bashls",
  "biome",
  "cssls",
  "dockerls",
  "efm",
  "jsonls",
  "lua_ls",
  "marksman",
  "prismals",
  "pylsp",
  "ruff",
  "ruff_lsp",
  "tailwindcss",
  "taplo",
  "ts_ls",
  "typos_lsp",
  "vimls",
  "yamlls",
  "terraformls",
}

M.installed_tree_sitter = {
  "astro",
  "bash",
  "css",
  "diff",
  "html",
  "javascript",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "prisma",
  "python",
  "ruby",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "yaml",
}

M.efm_languages = {
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
  text = { codespell },
}

return M
