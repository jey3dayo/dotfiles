local M = {}

M.setup = function()
  -- mini.completion対応: 標準的なLSP capabilitiesを使用
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  
  -- 補完機能の設定（mini.completionで使用）
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { "documentation", "detail", "additionalTextEdits" },
  }
  
  -- フォールディング機能
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }
  
  -- Disable pull diagnostics for all LSP servers to prevent issues
  -- (especially with ESLint v4.10.0 which has a bug with textDocument/diagnostic)
  capabilities.textDocument.diagnostic = nil
  
  return capabilities
end

return M
