-- Only `settings` is overridden; the rest comes from nvim-lspconfig's bundled
-- config. Do not add on_attach here: it would replace the bundled one that
-- registers :LspEslintFixAll. Capability suppression lives in lua/autocmds.lua.
return {
  settings = {
    validate = "on",
    packageManager = "npm",
    autoFixOnSave = false,
    format = false,
    quiet = false,
    onIgnoredFiles = "off",
    rulesCustomizations = {},
    run = "onType",
    workingDirectory = {
      mode = "location",
    },
    codeAction = {
      disableRuleComment = {
        enable = true,
        location = "separateLine",
      },
      showDocumentation = {
        enable = true,
      },
    },
  },
}
