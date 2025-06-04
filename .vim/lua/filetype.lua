vim.filetype.add {
  extension = {
    astro = "astro",
    gitconfig = "gitconfig",
    md = "markdown",
    mdx = "markdown",
    eslintrc = "json",
    stylintrc = "json",
    babelrc = "json",
    Podfile = "ruby",
  },
  pattern = {
    ["cloudformation*.json"] = "cloudformation.json",
    ["cloudformation*.yaml"] = "cloudformation.yaml",
    ["*.ts.bk"] = "typescriptreact",
    [".env*"] = "config",
    [".env.*"] = "config",
  },
}
