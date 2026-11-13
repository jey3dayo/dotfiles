local filetype = {
  extension = {
    astro = "astro",
    gotmpl = "gotmpl",
    md = "markdown",
    mdx = "markdown",
    gitconfig = "gitconfig",
    sshconfig = "sshconfig",
  },

  filename = {
    [".eslintrc"] = "json",
    [".stylintrc"] = "json",
    [".taskmasterconfig"] = "json",
    [".gitlab-ci.yml"] = "yaml.gitlab",
    [".gitlab-ci.yaml"] = "yaml.gitlab",
    ["Podfile"] = "ruby",
    ["babelrc"] = "json",
    ["compose.yaml"] = "yaml.docker-compose",
    ["compose.yml"] = "yaml.docker-compose",
    ["config"] = function(path, _)
      if path:match "/ghostty/config$" then return "toml" end
      return "gitconfig"
    end,
    ["docker-compose.yaml"] = "yaml.docker-compose",
    ["docker-compose.yml"] = "yaml.docker-compose",
    ["values.yaml"] = "yaml.helm-values",
    ["values.yml"] = "yaml.helm-values",
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
