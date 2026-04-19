local with_handler = require("lsp.handlers").with

if vim.lsp.inlay_hint then vim.lsp.inlay_hint.enable(true) end

local ui_theme = {
  border = "rounded",
  max_width = 80,
  max_height = 20,
}

vim.lsp.handlers["textDocument/hover"] = with_handler(vim.lsp.handlers.hover, {
  border = ui_theme.border,
  max_width = ui_theme.max_width,
  max_height = ui_theme.max_height,
})

vim.lsp.handlers["textDocument/signatureHelp"] = with_handler(vim.lsp.handlers.signature_help, {
  border = ui_theme.border,
  max_width = ui_theme.max_width,
})

vim.diagnostic.config {
  virtual_text = {
    spacing = 4,
    prefix = "●",
    format = function(diagnostic)
      local message = diagnostic.message
      if #message > 60 then message = message:sub(1, 57) .. "..." end
      return message
    end,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.HINT] = "",
      [vim.diagnostic.severity.INFO] = "",
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = ui_theme.border,
    source = "always",
    header = "",
    prefix = "",
    format = function(diagnostic)
      local severity_icons = {
        [vim.diagnostic.severity.ERROR] = " ",
        [vim.diagnostic.severity.WARN] = " ",
        [vim.diagnostic.severity.HINT] = " ",
        [vim.diagnostic.severity.INFO] = " ",
      }
      local icon = severity_icons[diagnostic.severity] or " "
      return string.format("%s %s", icon, diagnostic.message)
    end,
  },
}
