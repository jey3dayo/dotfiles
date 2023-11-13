local status, conform = pcall(require, "conform")
if not status then
  return
end

local prettier = { { "prettierd", "prettier" } }

conform.setup {
  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 2000,
    lsp_fallback = true,
  },
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
  },
}
