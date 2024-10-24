local M = {}

-- フォーマッターとリンターを分けて定義
local formatters = {
  biome = require "efmls-configs.formatters.biome",
  fixjson = require "efmls-configs.formatters.fixjson",
  prettier = require "efmls-configs.formatters.prettier",
  ruff_formatter = require "efmls-configs.formatters.ruff",
  ruff_sort = require "efmls-configs.formatters.ruff_sort",
  shfmt = require "efmls-configs.formatters.shfmt",
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
  yamllint = require "efmls-configs.linters.yamllint",
  codespell = require "efmls-configs.linters.codespell",
  jsonlint = require "efmls-configs.linters.jsonlint",
  luacheck = require "efmls-configs.linters.luacheck",
}

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

local config_files = {
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
  },
}

M.efm_languages = {
  javascript = { linters.biome, formatters.prettier },
  typescript = { linters.biome, formatters.prettier },
  html = { formatters.prettier },
  css = { formatters.prettier },
  python = { linters.ruff_linter, formatters.ruff_formatter, formatters.ruff_sort },
  lua = { formatters.stylua, linters.luacheck },
  markdown = { linters.markdownlint },
  dockerfile = { linters.hadolint },
  json = { formatters.fixjson, linters.jsonlint },
  yaml = { linters.yamllint },
  sh = { linters.shellcheck, formatters.shfmt },
  vim = { linters.vint },
  toml = { formatters.taplo },
  go = { formatters.gofmt },
  text = { linters.codespell },
}

-- 設定ファイルの存在をチェックして言語設定を更新
local function setup_languages()
  local function config_exists(tool)
    for _, file in ipairs(config_files[tool]) do
      if vim.fn.glob(file) ~= "" then
        return true
      end
    end
    return false
  end

  for tool, _ in pairs(config_files) do
    if config_exists(tool) then
      if tool == "eslint" then
        M.efm_languages.javascript = { linters.eslint, formatters.prettier }
        M.efm_languages.typescript = { linters.eslint, formatters.prettier }
      end
    end
  end
end

setup_languages()

return M
