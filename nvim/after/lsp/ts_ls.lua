local ft = require "core.filetypes"

local preferences = {
  includeCompletionsForModuleExports = true,
  includeCompletionsWithSnippetText = true,
  disableSuggestions = true,
}

return {
  filetypes = ft.js_project,
  settings = {
    typescript = { preferences = preferences },
    javascript = { preferences = preferences },
  },
}
