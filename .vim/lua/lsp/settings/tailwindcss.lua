return {
  init_options = {
    includeLanguages = {
      eruby = "erb",
      eelixir = "html-eex",
      ["javascript.jsx"] = "javascriptreact",
    },
  },
  root_dir = function(fname)
    return require("lspconfig").util.root_pattern(
      "tailwind.config.js",
      "tailwind.config.cjs",
      "tailwind.config.ts",
      "postcss.config.js"
    )(fname)
  end,
  filetypes = {
    "html",
    "css",
    "javascriptreact",
    "typescriptreact",
    "astro",
  },
  settings = {
    tailwindCSS = {
      validate = true,
    },
  },
}
