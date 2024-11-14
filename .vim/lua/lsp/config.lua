local M = {}

-- フォーマッターとリンターを分けて定義
local formatters = {
  biome = require "efmls-configs.formatters.biome",
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
  luacheck = require "efmls-configs.linters.luacheck",
}

M.installed_servers = {
  "astro",
  "bashls",
  "cssls",
  "dockerls",
  "efm",
  "jsonls",
  "lua_ls",
  "marksman",
  "prismals",
  "pylsp",
  "ruff",
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
  biome = {
    "biome.json",
    "biome.jsonc",
  },
}

-- config_filesからroot_markersを生成
local root_markers = { ".git/" }

-- 各設定ファイルをroot_markersに追加
for _, files in pairs(config_files) do
  for _, file in ipairs(files) do
    table.insert(root_markers, file)
  end
end

M.root_markers = root_markers

M.efm_languages = {
  javascript = {},
  typescript = {},
  javascriptreact = {},
  typescriptreact = {},
  html = { formatters.prettier },
  css = { formatters.prettier },
  python = { linters.ruff_linter, formatters.ruff_formatter, formatters.ruff_sort },
  lua = { formatters.stylua, linters.luacheck },
  markdown = { linters.markdownlint },
  dockerfile = { linters.hadolint },
  json = {},
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

  -- ECMA Script Linting
  -- eslint と prettier の設定ファイルがない場合は biome を使う
  local eslint_exists = config_exists "eslint"
  local prettier_exists = config_exists "prettier"

  if eslint_exists then
    M.efm_languages.javascript = { linters.eslint }
    M.efm_languages.typescript = { linters.eslint }
    M.efm_languages.javascriptreact = { formatters.eslint }
    M.efm_languages.typescriptreact = { formatters.eslint }
  elseif prettier_exists then
    M.efm_languages.javascript = { formatters.prettier }
    M.efm_languages.typescript = { formatters.prettier }
    M.efm_languages.javascriptreact = { formatters.prettier }
    M.efm_languages.typescriptreact = { formatters.prettier }
    M.efm_languages.html = { formatters.prettier }
    M.efm_languages.css = { formatters.prettier }
    M.efm_languages.json = { formatters.prettier }
    M.efm_languages.jsonc = { formatters.prettier }
    return
  end

  -- -- eslintがいないときに、biomeを実行
  if not eslint_exists then
    M.efm_languages.javascript = { formatters.biome }
    M.efm_languages.typescript = { formatters.biome }
    M.efm_languages.javascriptreact = { formatters.biome }
    M.efm_languages.typescriptreact = { formatters.biome }
  end

  if not prettier_exists then
    M.efm_languages.json = { formatters.biome }
    M.efm_languages.jsonc = { formatters.biome }
  end
end

setup_languages()

return M
