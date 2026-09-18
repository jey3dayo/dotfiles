-- Everything else (on_attach registering :LspEslintFixAll, root_dir with
-- monorepo/deno awareness, before_init setting workspaceFolder, handlers)
-- comes from nvim-lspconfig's bundled lsp/eslint.lua; only `settings`
-- differs from its defaults, so only `settings` is overridden here.
-- Capability suppression (formatting is conform.nvim's job) lives in the
-- LspAttach handler in lua/autocmds.lua instead of on_attach, so the
-- plugin's on_attach (LspEslintFixAll registration) is not replaced.
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
