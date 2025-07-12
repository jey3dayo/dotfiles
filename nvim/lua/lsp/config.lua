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
    global = "format_disabled",
    buffer = "b:format_disabled",
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
  astro = { installed = true, enabled = true },
  bashls = { installed = true, enabled = true },
  cssls = { installed = true, enabled = true },
  dockerls = { installed = true, enabled = true },
  gopls = { installed = true, enabled = true },
  jsonls = { installed = true, enabled = true },
  lua_ls = { installed = true, enabled = true },
  marksman = { installed = true, enabled = true },
  prismals = { installed = true, enabled = true },
  pylsp = { installed = true, enabled = true },
  ruff = { installed = true, enabled = true },
  tailwindcss = { installed = true, enabled = true },
  taplo = { installed = true, enabled = true },
  ts_ls = { installed = true, enabled = true },
  eslint = { installed = true, enabled = true },
  typos_lsp = { installed = true, enabled = true },
  vimls = { installed = true, enabled = true },
  yamlls = { installed = true, enabled = true },
  terraformls = { installed = true, enabled = true },
}

-- Helper functions for backward compatibility
function M.get_installed_servers()
  local servers = {}
  for name, config in pairs(M.servers) do
    if config.installed then table.insert(servers, name) end
  end
  return servers
end

function M.get_enabled_servers()
  local servers = {}
  for name, config in pairs(M.servers) do
    if config.enabled then table.insert(servers, name) end
  end
  return servers
end

-- Backward compatibility aliases
M.installed_servers = M.get_installed_servers()
M.enabled_servers = M.get_enabled_servers()

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
  markdown = { "markdownlint", "codespell" },
  vim = { "vint" },

  -- Global linters for any filetype
  ["*"] = { "codespell" },
}

M.formatters = {
  ts_ls = {
    config_files = { "tsconfig.json", "jsconfig.json" },
    formatter_priority = {
      priority = 3,
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
        -- ts_lsは言語機能のため停止しない
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
    },
    formatter_priority = {
      priority = 2,
      overrides = {
        -- ts_lsは言語機能のため停止しない
        -- eslint = true, -- ESLintも構文チェックのため停止しない
      },
    },
  },
  tailwindcss = {
    config_files = {
      "tailwind.config.js",
      "tailwind.config.cjs",
      "tailwind.config.ts",
      "postcss.config.js",
    },
  },
}

-- Memoized config file generation
local _config_files_cache = nil
function M.get_config_files()
  if not _config_files_cache then
    local files = { ".git/" }
    for _, formatter in pairs(M.formatters) do
      if formatter.config_files then vim.list_extend(files, formatter.config_files) end
    end
    _config_files_cache = files
  end
  return _config_files_cache
end

-- Backward compatibility
M.config_files = M.get_config_files()

return M
