-- Schemas https://www.schemastore.org
local schemas = {
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
    description = "Lerna config",
    fileMatch = { "lerna.json" },
    url = "https://json.schemastore.org/lerna.json",
  },
  {
    description = "Vercel Now config",
    fileMatch = { "now.json" },
    url = "https://json.schemastore.org/now",
  },
  {
    description = "Stylelint config",
    fileMatch = {
      ".stylelintrc",
      ".stylelintrc.json",
      "stylelint.config.json",
    },
    url = "https://json.schemastore.org/stylelintrc",
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
    description =
    "The AWS Serverless Application Model (AWS SAM, previously known as Project Flourish) extends AWS CloudFormation to provide a simplified way of defining the Amazon API Gateway APIs, AWS Lambda functions, and Amazon DynamoDB tables needed by your serverless application.",
    fileMatch = {
      "serverless.template",
      "*.sam.json",
      "sam.json",
    },
    url = "https://raw.githubusercontent.com/awslabs/goformation/v5.2.9/schema/sam.schema.json",
  },
  {
    description = "Json schema for properties json file for a GitHub Workflow template",
    fileMatch = { ".github/workflow-templates/**.properties.json" },
    url = "https://json.schemastore.org/github-workflow-template-properties.json",
  },
  {
    description = "JSON schema for the JSON Feed format",
    fileMatch = {
      "feed.json",
    },
    url = "https://json.schemastore.org/feed.json",
    versions = {
      ["1"] = "https://json.schemastore.org/feed-1.json",
      ["1.1"] = "https://json.schemastore.org/feed.json",
    },
  },
  {
    description = "JSON schema for Visual Studio component configuration files",
    fileMatch = {
      "*.vsconfig",
    },
    url = "https://json.schemastore.org/vsconfig.json",
  },
}

local status, jsonls_settings = pcall(require, "nlspsettings.jsonls")
if status then
  default_schemas = jsonls_settings.get_default_schemas()
end

local extended_schemas = require("utils").extend(schemas, default_schemas)

return {
  filetypes = { "json", "jsonc" },
  setup = {
    commands = {
      Format = {
        function()
          vim.lsp.buf.formatexpr({}, { 0, 0 }, { vim.fn.line "$", 0 })
          -- vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line "$", 0 })
        end,
      },
    },
  },
  settings = {
    json = {
      schemas = extended_schemas,
    },
  },
}
