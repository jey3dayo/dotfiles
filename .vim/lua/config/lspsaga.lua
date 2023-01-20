local status, saga = pcall(require, "lspsaga")
if (not status) then return end

-- saga.setup({})
saga.init_lsp_saga {
  server_filetype_map = {
    typescript = "typescript"
  }
}
