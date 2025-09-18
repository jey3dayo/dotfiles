local filetype = {
  extension = {
    astro = "astro",
    md = "markdown",
    mdx = "markdown",
    gitconfig = "gitconfig",
    sshconfig = "sshconfig",
  },

  filename = {
    [".eslintrc"] = "json",
    [".stylintrc"] = "json",
    [".taskmasterconfig"] = "json",
    ["Podfile"] = "ruby",
    ["babelrc"] = "json",
    ["config"] = "gitconfig",
  },

  pattern = {
    ["^cloudformation.*.ya?ml$"] = "cloudformation.yaml",
    ["^cloudformation.*.json$"] = "cloudformation.json",
    ["%.ts%.bk$"] = "typescriptreact",
    ["%.env.*$"] = "config",
    ["^user%-abbreviations$"] = "zsh",
  },
}

vim.filetype.add(filetype)
