return {
  filetypes = { "json", "jsonc" },
  commands = {
    Format = {
      function()
        vim.lsp.buf.formatexpr({}, { 0, 0 }, { vim.fn.line "$", 0 })
      end,
    },
  },
  settings = {
    json = {
      -- Schemas https://www.schemastore.org
      schemas = {
        {
          description = "NPM configuration file",
          fileMatch = { "package.json" },
          url = "https://json.schemastore.org/package.json",
        },
        {
          description = "TypeScript compiler configuration file",
          fileMatch = { "tsconfig.json", "tsconfig.*.json" },
          url = "https://json.schemastore.org/tsconfig.json",
        },
        {
          description = "Prettier config",
          fileMatch = {
            ".prettierrc",
            ".prettierrc.json",
            "prettier.config.json",
          },
          url = "https://json.schemastore.org/prettierrc.json",
        },
        {
          description = "ESLint config",
          fileMatch = { ".eslintrc", ".eslintrc.json" },
          url = "https://json.schemastore.org/eslintrc.json",
        },
        {
          description = "Babel configuration",
          fileMatch = { ".babelrc", ".babelrc.json", "babel.config.json" },
          url = "https://json.schemastore.org/babelrc.json",
        },
        {
          fileMatch = { "lerna.json" },
          url = "https://json.schemastore.org/lerna.json",
        },
        {
          fileMatch = { "now.json", "vercel.json" },
          url = "https://json.schemastore.org/now.json",
        },
        {
          fileMatch = { "now.json", "vercel.json" },
          url = "https://json.schemastore.org/now.json",
        },
        {
          fileMatch = {
            ".stylelintrc",
            ".stylelintrc.json",
            "stylelint.config.json",
          },
          url = "http://json.schemastore.org/stylelintrc.json",
        },
        {
          fileMatch = { "postcss.config.json" },
          url = "https://json.schemastore.org/postcssrc.json",
        },
        {
          description = "AWS CloudFormation",
          fileMatch = { "*.cf.json", "cloudformation.json" },
          url = "https://raw.githubusercontent.com/awslabs/goformation/v5.2.9/schema/cloudformation.schema.json",
        },
        {
          description = "Json schema for properties json file for a GitHub Workflow template",
          fileMatch = { ".github/workflow-templates/**.properties.json" },
          url = "https://json.schemastore.org/github-workflow-template-properties.json",
        },
      },
    },
  },
}
