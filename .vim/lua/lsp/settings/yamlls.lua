local schemas = {
  schemas = {
    ["https://json.schemastore.org/gitlab-ci.json"] = {
      ".gitlab-ci.yml",
    },
    ["https://json.schemastore.org/bamboo-spec.json"] = {
      "bamboo-specs/*.{yml,yaml}",
    },
    ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = {
      "docker-compose*.{yml,yaml}",
    },
    ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.{yml,yaml}",
    ["https://json.schemastore.org/github-action.json"] = ".github/action.{yml,yaml}",
    ["https://json.schemastore.org/prettierrc.json"] = ".prettierrc.{yml,yaml}",
    ["https://json.schemastore.org/stylelintrc.json"] = ".stylelintrc.{yml,yaml}",
    ["https://json.schemastore.org/circleciconfig"] = ".circleci/**/*.{yml,yaml}",
  },
}

return {
  filetypes = { "yml", "yaml" },
  settings = {
    yaml = {
      schemas = schemas,
    },
  },
}
