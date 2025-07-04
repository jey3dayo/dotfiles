local M = {}

M.setup = function()
  -- Neovim v0.10+ 推奨: cmp_nvim_lsp.default_capabilities()を使用
  local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if not has_cmp then
    -- cmp_nvim_lspが利用できない場合のフォールバック
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.completion.completionItem.resolveSupport = {
      properties = { "documentation", "detail", "additionalTextEdits" },
    }
    capabilities.textDocument.foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    }
    return capabilities
  end
  
  -- cmp_nvim_lsp.default_capabilities()は補完関連の設定を全て含む
  local capabilities = cmp_nvim_lsp.default_capabilities()
  
  -- 補完以外の機能（foldingRange等）は手動で追加
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }
  
  return capabilities
end

return M
