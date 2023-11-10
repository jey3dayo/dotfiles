local status, conform = pcall(require, "conform")
if not status then
  return
end

conform.setup {
  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 2000,
    lsp_fallback = true,
  },
  formatters_by_ft = {
    lua = { "stylua" },
    go = { "gofmt" },
    javascriptreact = { { "prettierd", "prettier" } },
    typescriptreact = { { "prettierd", "prettier" } },
    python = { "isort", "black" },
    sql = { "sql_formatter" },
  },
}
