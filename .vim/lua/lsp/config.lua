local M = {}

M.allow_format = {
  "tsserver",
  "yamlls",
  "jsonls",
  "cssls",
  "prismals",
  "lua_ls",
  "prettier",
  "astro",
}

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
  "typescript",
  "astro",
}

return M
