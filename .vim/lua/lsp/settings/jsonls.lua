-- Enhanced JSON Schemas with development-focused configs
local schemas = {
  -- Package managers
  {
    description = "NPM configuration file",
    fileMatch = { "package.json" },
    url = "https://json.schemastore.org/package.json",
  },
  {
    description = "Yarn package configuration",
    fileMatch = { "yarn.lock" },
    url = "https://json.schemastore.org/yarn-lock.json",
  },
  -- TypeScript & JavaScript
  {
    description = "TypeScript compiler configuration file",
    fileMatch = { "tsconfig.json", "tsconfig.*.json" },
    url = "https://json.schemastore.org/tsconfig.json",
  },
  {
    description = "JSConfig configuration",
    fileMatch = { "jsconfig.json" },
    url = "https://json.schemastore.org/jsconfig.json",
  },
  -- Formatters & Linters
  {
    description = "Prettier config",
    fileMatch = { ".prettierrc", ".prettierrc.json", "prettier.config.json" },
    url = "https://json.schemastore.org/prettierrc.json",
  },
  {
    description = "Biome config",
    fileMatch = { "biome.json", "biome.jsonc" },
    url = "https://biomejs.dev/schemas/1.8.0/schema.json",
  },
  {
    description = "ESLint config",
    fileMatch = { ".eslintrc", ".eslintrc.json" },
    url = "https://json.schemastore.org/eslintrc.json",
  },
  {
    description = "VS Code settings",
    fileMatch = { "settings.json", ".vscode/settings.json" },
    url = "https://raw.githubusercontent.com/SchemaStore/schemastore/master/src/schemas/json/vscode-settings.json",
  },
  -- Build tools
  {
    description = "Babel configuration",
    fileMatch = { ".babelrc", ".babelrc.json", "babel.config.json" },
    url = "https://json.schemastore.org/babelrc.json",
  },
  {
    description = "Webpack configuration",
    fileMatch = { "webpack.config.json" },
    url = "https://json.schemastore.org/webpack.json",
  },
  -- Web tools
  {
    description = "Stylelint config",
    fileMatch = { ".stylelintrc", ".stylelintrc.json", "stylelint.config.json" },
    url = "https://json.schemastore.org/stylelintrc",
  },
  {
    description = "PostCSS config",
    fileMatch = { "postcss.config.json" },
    url = "https://json.schemastore.org/postcssrc.json",
  },
  -- Development configs
  {
    description = "Vercel configuration",
    fileMatch = { "vercel.json" },
    url = "https://json.schemastore.org/vercel.json",
  },
  {
    description = "GitHub Workflow",
    fileMatch = { ".github/workflows/*.json" },
    url = "https://json.schemastore.org/github-workflow.json",
  },
}

return {
  -- Use global vscode-json-languageserver@1.3.4 to avoid MethodNotFound crash in vscode-langservers-extracted 4.8.0+
  cmd = { "/Users/t00114/.local/npm-global/bin/vscode-json-languageserver", "--stdio" },
  filetypes = { "json", "jsonc" },
  -- autostart = false, -- Re-enable JSON LSP with proper configuration
  init_options = {
    provideFormatter = false, -- conform.nvim handles formatting
  },
  settings = {
    json = {
      schemas = schemas,
      validate = { enable = true },
      -- Enhanced IntelliSense
      keepLines = { enable = true },
      resultLimit = 5000,
      -- Schema completion
      schemaRequest = { enable = true, timeout = 10000 },
      schemaDownload = { enable = true },
    },
  },
  capabilities = (function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
    capabilities.textDocument.completion.completionItem.documentationFormat = { "markdown", "plaintext" }
    capabilities.textDocument.completion.completionItem.deprecatedSupport = true
    capabilities.textDocument.completion.completionItem.preselectSupport = true
    -- Workspace configuration support for older vscode-json-languageserver
    capabilities.workspace = capabilities.workspace or {}
    capabilities.workspace.configuration = true
    capabilities.workspace.didChangeConfiguration = { 
      dynamicRegistration = true 
    }
    return capabilities
  end)(),
  -- Best practice: disable formatting, keep validation & IntelliSense
  on_init = function(client, _)
    -- JSON LSP role: Schema validation + IntelliSense only
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    -- Keep these for optimal JSON experience
    -- client.server_capabilities.completionProvider = true
    -- client.server_capabilities.hoverProvider = true
    -- client.server_capabilities.documentSymbolProvider = true
  end,
}
