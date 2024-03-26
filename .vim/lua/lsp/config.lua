local M = {}

M.installed_servers = {
  "tsserver",
  "yamlls",
  "jsonls",
  "cssls",
  "lua_ls",
  "vimls",
  "dockerls",
  "bashls",
  "prismals",
  "tailwindcss",
  "astro",
  "pylsp",
  "ruff_lsp",
  "taplo",
  "vimls",
  "marksman",
}

M.installed_tree_sitter = {
  "bash",
  "markdown",
  "markdown_inline",
  "prisma",
  "toml",
  "json",
  "yaml",
  "css",
  "html",
  "ruby",
  "lua",
  "vim",
  "javascript",
  "typescript",
  "astro",
  "tsx",
  "python",
  "diff",
}

M.config_files = {
  tsserver = { "tsconfig.json" },
  eslint = {
    ".eslintrc.js",
    ".eslintrc.cjs",
    ".eslintrc.yaml",
    ".eslintrc.yml",
    ".eslintrc.json",
    ".eslintrc",
    ".eslint.js",
  },
}

return M
