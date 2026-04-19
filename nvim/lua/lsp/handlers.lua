-- LSP handlers configuration
local M = {}

local function merge_handler_config(config, overrides)
  if not overrides then return config or {} end
  return vim.tbl_deep_extend("force", config or {}, overrides)
end

function M.with(handler, overrides)
  return function(err, result, ctx, config)
    return handler(err, result, ctx, merge_handler_config(config, overrides))
  end
end

-- Setup handlers and on_attach
M.setup = function()
  -- Setup diagnostic configuration
  vim.diagnostic.config {
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  }

  -- Define diagnostic signs
  local signs = { Error = "✗ ", Warn = "⚠ ", Hint = "💡", Info = "ℹ " }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end
end

-- Common on_attach function
M.on_attach = function(client, bufnr)
  -- Enable completion
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  -- Setup keymaps
  require("lsp.keymaps").setup(client, bufnr)

  -- Enable diagnostics for this buffer
  -- v0.11+: vim.diagnostic.enable(enable:boolean, filter:table)
  if vim.diagnostic.enable then
    -- Use the new signature: enable diagnostics for this buffer
    pcall(vim.diagnostic.enable, true, { bufnr = bufnr })
  end

  -- Log attachment
  if vim.g.lsp_debug then
    vim.notify(string.format("LSP %s attached to buffer %d", client.name, bufnr), vim.log.levels.INFO)
  end
end

-- Common handlers
M.handlers = {
  ["textDocument/hover"] = M.with(vim.lsp.handlers.hover, {
    border = "rounded",
  }),
  ["textDocument/signatureHelp"] = M.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
  }),
  ["textDocument/publishDiagnostics"] = M.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
  }),
  ["textDocument/diagnostic"] = function(err, result, ctx, config)
    -- ESLintのパスエラーを抑制
    if err and err.message and err.message:match 'The "path" argument must be of type string' then
      -- エラーを無視
      return nil
    end
    -- その他のエラーは通常のハンドラーに渡す
    local handler = vim.lsp.handlers["textDocument/diagnostic"]
    if handler then return handler(err, result, ctx, config) end
  end,
}

return M
