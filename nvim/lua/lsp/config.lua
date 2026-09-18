--- LSP Configuration - Central management for all LSP settings
--- @module lsp.config
local M = {}

--- Debug mode flag for LSP operations
--- @type boolean
M.isDebug = false

--- Default formatting configuration
--- @type table
M.format = {
  default = {
    timeout_ms = 3000,
    async = false,
  },
  state = {
    -- Single source of truth for autoformat toggles
    global = "disable_autoformat",
    buffer = "disable_autoformat",
  },
}

--- LSP-specific constants and default options
--- @type table
M.LSP = {
  PREFIX = "[lsp]",
  DEFAULT_OPTS = { silent = true },
  DEFAULT_BUF_OPTS = { noremap = true, silent = true },
  FORMAT_TIMEOUT = 5000,
}

M.servers = {
  "astro",
  "bashls",
  "cssls",
  "dockerls",
  "eslint",
  "gopls",
  "jsonls",
  "lua_ls",
  "marksman",
  "prismals",
  "pylsp",
  "ruff",
  "taplo",
  "terraformls",
  "ts_ls",
  "typos_lsp",
  "yamlls",
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
  "latex",
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

-- Linter configurations for nvim-lint
M.linters = {
  javascript = { "eslint" },
  javascriptreact = { "eslint" },
  typescript = { "eslint" },
  typescriptreact = { "eslint" },
  vue = { "eslint" },

  python = { "ruff" },
  lua = { "luacheck" },
  sh = { "shellcheck" },
  bash = { "shellcheck" },
  zsh = { "shellcheck" },
  dockerfile = { "hadolint" },
  yaml = { "yamllint" },
  ["yaml.docker-compose"] = { "yamllint" },
  ["yaml.gitlab"] = { "yamllint" },
  ["yaml.helm-values"] = { "yamllint" },
  markdown = { "markdownlint", "codespell" },
  vim = { "vint" },

  -- Global linters for any filetype
  ["*"] = { "codespell" },
}

M.formatters = {
  ts_ls = {
    config_files = { "tsconfig.json", "jsconfig.json" },
    formatter_priority = {
      priority = 4,
      overrides = {},
    },
  },
  eslint = {
    config_files = {
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
    formatter_priority = {
      priority = 3,
      overrides = {},
    },
  },
  biome = {
    config_files = { "biome.json", "biome.jsonc" },
    formatter_priority = {
      priority = 1,
      overrides = {
        -- TypeScript LSPは言語機能のため停止しない
        -- eslint = true, -- ESLintも構文チェックのため停止しない
        prettier = true, -- prettierはフォーマット専用なので置き換え可能
      },
    },
  },
  prettier = {
    config_files = {
      ".prettierrc",
      ".prettierrc.json",
      ".prettierrc.yml",
      ".prettierrc.yaml",
      ".prettierrc.js",
      ".prettierrc.cjs",
      "prettier.config.js",
      "prettier.config.cjs",
      ".prettierrc.toml",
      "package.json", -- Prettier config can be in package.json under "prettier" key
    },
    formatter_priority = {
      priority = 2,
      overrides = {
        -- TypeScript LSPは言語機能のため停止しない
        -- eslint = true, -- ESLintも構文チェックのため停止しない
      },
    },
  },
}

return M
