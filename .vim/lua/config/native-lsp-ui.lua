--- Native LSP UI configuration with unified theming
--- Optimized for gruvbox-based dotfiles theme consistency

-- Enable inlay hints if available
if vim.lsp.inlay_hint then 
  vim.lsp.inlay_hint.enable(true) 
end


-- Define consistent UI theme colors (gruvbox-compatible)
local ui_theme = {
  border = "rounded",
  max_width = 80,
  max_height = 20,
  -- Gruvbox-compatible colors
  colors = {
    error = "#fb4934",   -- gruvbox red
    warn = "#fabd2f",    -- gruvbox yellow
    info = "#83a598",    -- gruvbox blue
    hint = "#8ec07c",    -- gruvbox aqua
  }
}

-- Hover handler with unified styling
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = ui_theme.border,
  max_width = ui_theme.max_width,
  max_height = ui_theme.max_height,
})

-- Signature help with consistent styling
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = ui_theme.border,
  max_width = ui_theme.max_width,
})

-- Diagnostic configuration with gruvbox-themed icons and colors
vim.diagnostic.config {
  virtual_text = {
    spacing = 4,
    prefix = "●", -- Simple bullet for consistency
    format = function(diagnostic)
      -- Truncate long messages for better readability
      local message = diagnostic.message
      if #message > 60 then
        message = message:sub(1, 57) .. "..."
      end
      return message
    end,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "", -- Error icon
      [vim.diagnostic.severity.WARN] = "", -- Warning icon  
      [vim.diagnostic.severity.HINT] = "", -- Hint icon
      [vim.diagnostic.severity.INFO] = "", -- Info icon
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
      -- Enhanced diagnostic formatting with severity icons
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
