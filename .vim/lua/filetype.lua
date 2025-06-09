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
    sshconfig = "sshconfig",
  },
  pattern = {
    ["cloudformation.*%.json"] = "cloudformation.json",
    ["cloudformation.*%.ya?ml"] = "cloudformation.yaml",
    ["%.ts%.bk"] = "typescriptreact",
    ["%.env.*"] = "config",
    ["user%-abbreviations"] = "zsh",
  },
}
