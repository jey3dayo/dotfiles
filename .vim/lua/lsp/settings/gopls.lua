local util = require "lspconfig.util"

return {
  settings = {
    gopls = {
      analyses = { unusedparams = true },
      staticcheck = true,
      gofumpt = true,
    },
  },

  -- Prevent gopls from attaching to fugitive:// and other non-file URIs
  root_dir = function(fname, bufnr)
    -- Skip any buffer whose "file name" starts with a URI scheme
    if fname:match "^%a+://" then return nil end
    -- Otherwise use the normal Go root-detection
    return util.root_pattern("go.work", "go.mod", ".git")(fname)
  end,

  -- Extra safety: if we still somehow attached, detach immediately
  on_attach = function(client, bufnr)
    local uri = vim.uri_from_bufnr(bufnr)
    if uri:match "^%a+://" then
      client.stop() -- detach from non-file URIs
      return
    end

    -- Normal LSP keymaps and configurations for Go files
    local opts = { noremap = true, silent = true, buffer = bufnr }

    -- TODO: add more keymaps
    -- Go-specific keymaps
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
}
