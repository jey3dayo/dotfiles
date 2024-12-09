return {
  root_dir = function(fname)
    return require("lspconfig").util.root_pattern("tsconfig.json", "package.json")(fname)
  end,
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  init_options = {
    preferences = {
      disableSuggestions = true,
    },
    tsserver = {
      useSyntaxServer = "never",
    },
  },
}
