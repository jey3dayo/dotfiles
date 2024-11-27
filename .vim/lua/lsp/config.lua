local with = require("utils").with

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
  biome = { "biome.json", "biome.jsonc" },
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

-- TODO* root_markers見て起動するようなら処理系見直す
M.languages = {
  javascript = {},
  typescript = {},
  javascriptreact = {},
  typescriptreact = {},
  html = { formatters.prettier },
  css = { formatters.prettier },
  python = {
    linters.ruff_linter,
    formatters.ruff_formatter,
    formatters.ruff_sort,
  },
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
  -- local eslint_exists = config_exists "eslint"
  local prettier_exists = config_exists "prettier"

  -- tsconfigがいるときに事故るのでコメントアウト
  -- if eslint_exists then
  --   M.languages.javascript = { linters.eslint }
  --   M.languages.typescript = { linters.eslint }
  --   M.languages.javascriptreact = { linters.eslint }
  --   M.languages.typescriptreact = { linters.eslint }
  -- end

  -- -- eslintがいないときに、biomeを実行
  -- if not eslint_exists then
  --   M.languages.javascript = { formatters.biome }
  --   M.languages.typescript = { formatters.biome }
  --   M.languages.javascriptreact = { formatters.biome }
  --   M.languages.typescriptreact = { formatters.biome }
  -- end

  if prettier_exists then
    M.languages.javascript = { formatters.prettier }
    M.languages.typescript = { formatters.prettier }
    M.languages.javascriptreact = { formatters.prettier }
    M.languages.typescriptreact = { formatters.prettier }
    M.languages.html = { formatters.prettier }
    M.languages.css = { formatters.prettier }
    M.languages.json = { formatters.prettier }
    M.languages.jsonc = { formatters.prettier }
  else
    M.languages.javascript = { formatters.biome }
    M.languages.typescript = { formatters.biome }
    M.languages.javascriptreact = { formatters.biome }
    M.languages.typescriptreact = { formatters.biome }
    M.languages.html = { formatters.biome }
    M.languages.css = { formatters.biome }
    M.languages.json = { formatters.biome }
    M.languages.jsonc = { formatters.biome }
  end
end

setup_languages()

return M
