local user_command = require("utils").user_command

local status, conform = pcall(require, "conform")
if not status then
  return
end

local prettier = { { "prettier" } }

conform.setup {
  format_on_save = function(bufnr)
    -- Disable with a global or buffer-local variable
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { async = true, timeout_ms = 4000, lsp_fallback = true }
  end,
  formatters_by_ft = {
    lua = { "stylua" },
    go = { "gofmt" },
    python = { "isort", "black" },
    sql = { "sql_formatter" },
    json = prettier,
    jsonc = prettier,
    javascriptreact = prettier,
    typescriptreact = prettier,
    javascript = prettier,
    typescript = prettier,
    astro = prettier,
  },
}

user_command("FormatDisable", function(args)
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = "Disable autoformat-on-save",
  bang = true,
})

user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = "Re-enable autoformat-on-save",
})
