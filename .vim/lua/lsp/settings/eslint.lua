return {
  init_options = {
    provideFormatter = false,
  },
  root_dir = function(fname)
    return require("lspconfig").util.root_pattern(
      ".eslintrc",
      ".eslintrc.json",
      ".eslintrc.js",
      ".eslintrc.yaml",
      ".eslintrc.yml",
      "eslint.config.js",
      ".eslint.config.js"
    )(fname)
  end,
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
}
