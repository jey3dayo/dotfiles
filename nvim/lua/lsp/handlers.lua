-- LSP handlers configuration
local M = {}

local function merge_handler_config(config, overrides)
  if not overrides then return config or {} end
  return vim.tbl_deep_extend("force", config or {}, overrides)
end

-- Wraps a standard (err, result, ctx, config) handler so overrides are
-- deep-merged into the per-request config, avoiding duplicated handler bodies.
function M.with(handler, overrides)
  return function(err, result, ctx, config)
    return handler(err, result, ctx, merge_handler_config(config, overrides))
  end
end

-- Common handlers. Hover/signatureHelp are configured globally in lsp.ui
-- instead (it already overrides vim.lsp.handlers with a richer border/size
-- config); duplicating them here would win over lsp.ui via vim.lsp.config's
-- per-config handler precedence.
M.handlers = {
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
