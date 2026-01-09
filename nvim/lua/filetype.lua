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
    ["config"] = function(path, _)
      if path:match("/ghostty/config$") then
        return "toml"
      end
      return "gitconfig"
    end,
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
