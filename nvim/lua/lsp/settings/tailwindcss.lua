local ft = require "core.filetypes"
local factory = require "lsp.settings_factory"

return factory.create_formatter_server("tailwindcss", {
  filetypes = ft.tailwind_supported,
  init_options = {
    includeLanguages = {
      eruby = "erb",
      eelixir = "html-eex",
      ["javascript.jsx"] = "javascriptreact",
    },
  },
  on_attach = function(client, bufnr)
    -- Call default on_attach first
    local handlers = require "lsp.handlers"
    if handlers and handlers.on_attach then handlers.on_attach(client, bufnr) end

    -- Minimize TailwindCSS server verbosity
    client.config.trace = "off"
  end,
  settings = {
    tailwindCSS = {
      validate = true,
      lint = {
        cssConflict = "warning",
        invalidApply = "error",
        invalidConfigPath = "off", -- Disable tsconfig resolution errors
        invalidScreen = "error",
        invalidTailwindDirective = "error",
        invalidVariant = "error",
        recommendedVariantOrder = false, -- Reduce noise
      },
      experimental = {
        classRegex = {
          "tw`([^`]*)",
          'tw"([^"]*)',
          "tw\\.\\w+`([^`]*)",
          "tw\\(.*?\\)`([^`]*)",
        },
      },
    },
  },
})
