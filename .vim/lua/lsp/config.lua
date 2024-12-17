local utils = require "utils"
local with = require("utils").with

local M = {}

M.isDebug = false

M.format = {
  default = {
    timeout_ms = 3000,
    async = false,
  },
  state = {
    global = "format_disabled",
    buffer = "b:format_disabled",
  },
}

M.LSP = {
  PREFIX = "[lsp]",
  DEFAULT_OPTS = { silent = true },
  DEFAULT_BUF_OPTS = { noremap = true, silent = true },
  FORMAT_TIMEOUT = 5000,
}

-- フォーマッターとリンターを分けて定義
local formatters = {
  biome = require "efmls-configs.formatters.biome",
  prettier = require "efmls-configs.formatters.prettier",
  ruff_formatter = require "efmls-configs.formatters.ruff",
  ruff_sort = require "efmls-configs.formatters.ruff_sort",
  stylua = require "efmls-configs.formatters.stylua",
  taplo = require "efmls-configs.formatters.taplo",
  gofmt = require "efmls-configs.formatters.gofmt",
}

local linters = {
  eslint = require "efmls-configs.linters.eslint",
  hadolint = require "efmls-configs.linters.hadolint",
  markdownlint = require "efmls-configs.linters.markdownlint",
  ruff_linter = require "efmls-configs.linters.ruff",
  vint = require "efmls-configs.linters.vint",
  -- yamllint = require "efmls-configs.linters.yamllint",
  codespell = require "efmls-configs.linters.codespell",
  luacheck = require "efmls-configs.linters.luacheck",
}

local opts = {
  stylua = {
    formatCommand = "stylua --config-path ~/.config/stylua.toml -",
    formatStdin = true,
  },
}
formatters.stylua = with(formatters.stylua, opts.stylua)

M.installed_servers = {
  "astro",
  "bashls",
  "cssls",
  "dockerls",
  "efm",
  "jsonls",
  "lua_ls",
  "prismals",
  "pylsp",
  "ruff",
  "tailwindcss",
  "taplo",
  "ts_ls",
  "typos_lsp",
  "vimls",
  -- "yamlls",
  "terraformls",
}

M.installed_tree_sitter = {
  "astro",
  "bash",
  "c",
  "css",
  "diff",
  "dockerfile",
  "git_config",
  "gitignore",
  "go",
  "graphql",
  "helm",
  "hlsl",
  "html",
  "javascript",
  "json",
  "jsonc",
  "lua",
  "markdown",
  "markdown_inline",
  "mermaid",
  "php",
  "prisma",
  "proto",
  "python",
  "query",
  "r",
  "regex",
  "ruby",
  "terraform",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

local config_files = {
  ts_ls = { "tsconfig.json", "jsconfig.json" },
  eslint = {
    ".eslintrc",
    ".eslintrc.json",
    ".eslintrc.js",
    ".eslintrc.yaml",
    ".eslintrc.yml",
    "eslint.config.js",
    "eslint.config.cjs",
    "eslint.config.mjs",
    "eslint.config.ts",
    "eslint.config.cts",
    "eslint.config.mts",
    ".eslintrc.config.js",
  },
  prettier = {
    ".prettierrc",
    ".prettierrc.json",
    ".prettierrc.yml",
    ".prettierrc.yaml",
    ".prettierrc.js",
    ".prettierrc.cjs",
    "prettier.config.js",
    "prettier.config.cjs",
    ".prettierrc.toml",
  },
  biome = { "biome.json", "biome.jsonc" },
  tailwindcss = {
    "tailwind.config.js",
    "tailwind.config.cjs",
    "tailwind.config.ts",
    "postcss.config.js",
  },
}
M.config_files = config_files

-- ルートマーカー生成
M.root_markers = (function()
  local markers = { ".git/" }
  for _, files in pairs(M.config_files) do
    vim.list_extend(markers, files)
  end
  return markers
end)()

-- TODO: fileTypesみて設定を変える
M.languages = {
  javascript = {},
  typescript = {},
  javascriptreact = {},
  typescriptreact = {},
  json = {},
  jsonc = {},
  gql = {},
  html = {},
  css = {},
  python = {
    linters.ruff_linter,
    formatters.ruff_formatter,
    formatters.ruff_sort,
  },
  lua = { formatters.stylua, linters.luacheck },
  markdown = { linters.markdownlint },
  dockerfile = { linters.hadolint },
  yaml = { linters.yamllint },
  vim = { linters.vint },
  toml = { formatters.taplo },
  go = { formatters.gofmt },
  text = { linters.codespell },
}

-- ECMA Script Linting
local has_prettier = utils.has_config_file(config_files.prettier)
local has_biome = utils.has_config_file(config_files.biome)

if has_biome then
  M.languages.gql = with(M.languages.gql, { formatters.biome })
  M.languages.javascript = with(M.languages.javascript, { formatters.biome })
  M.languages.typescript = with(M.languages.typescript, { formatters.biome })
  M.languages.javascriptreact = with(M.languages.javascriptreact, { formatters.biome })
  M.languages.typescriptreact = with(M.languages.typescriptreact, { formatters.biome })
  M.languages.json = with(M.languages.json, { formatters.biome })
  M.languages.jsonc = with(M.languages.jsonc, { formatters.biome })
end

if has_prettier then
  M.languages.html = with(M.languages.html, { formatters.prettier })
  M.languages.css = with(M.languages.css, { formatters.prettier })
  M.languages.javascript = with(M.languages.javascript, { formatters.prettier })
  M.languages.typescript = with(M.languages.typescript, { formatters.prettier })
  M.languages.javascriptreact = with(M.languages.javascriptreact, { formatters.prettier })
  M.languages.typescriptreact = with(M.languages.typescriptreact, { formatters.prettier })
  M.languages.json = with(M.languages.json, { formatters.prettier })
  M.languages.jsonc = with(M.languages.jsonc, { formatters.prettier })
end

return M
