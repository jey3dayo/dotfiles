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
  "eslint",
  "typos_lsp",
  "vimls",
  -- "yamlls",
  "terraformls",
}

M.enabled_servers = {
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
  "typescript-tools",
  "eslint",
  "typos_lsp",
  "vimls",
  "yamlls",
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
  },
  biome = {
    config_files = { "biome.json", "biome.jsonc" },
    formatter_priority = {
      priority = 1,
      overrides = {
        jsonls = true,
        tsserver = true,
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
        tsserver = true,
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

local function generate_config_files()
  local files = { ".git/" }
  for _, formatter in pairs(M.formatters) do
    if formatter.config_files then
      vim.list_extend(files, formatter.config_files)
    end
  end
  return files
end

M.config_files = generate_config_files()

return M
