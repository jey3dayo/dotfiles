local M = {}

M.allow_format = {
  "null-ls",
  "eslint",
  "tsserver",
  "prettier",
}

M.installed_servers = {
  "eslint",
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
}

M.servers = {
  "eslint",
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
}

M.null_ls_ensure_installed = {
  -- formatters
  "prettier",
  "stylua",
  "shfmt",
  "shellcheck",
  "beautysh",
  "sql_formatter",
  "black",

  -- linters
  -- "luacheck",
  "yamllint",
  "markdownlint",
}

return M
