local ft = require "core.filetypes"
local lsp_utils = require "lsp.utils"
local lsp_config = require "lsp.config"
local config_files = lsp_config.formatters.tailwindcss.config_files

-- Tailwind設定ファイルの存在チェック
local function has_tailwind_config()
  for _, file in ipairs(config_files) do
    if vim.fn.filereadable(vim.fn.getcwd() .. "/" .. file) == 1 then return true end
  end
  return false
end

return {
  autostart = has_tailwind_config,
  init_options = {
    includeLanguages = {
      eruby = "erb",
      eelixir = "html-eex",
      ["javascript.jsx"] = "javascriptreact",
    },
  },
  root_dir = lsp_utils.create_root_pattern(config_files),
  filetypes = ft.tailwind_supported,
  on_attach = function(client, bufnr)
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
}
