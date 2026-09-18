return {
  settings = {
    gopls = {
      analyses = { unusedparams = true },
      staticcheck = true,
      gofumpt = true,
    },
  },

  -- No custom root_dir: nvim-lspconfig's bundled root_dir (go.work/go.mod/
  -- .git aware) is deferred to. A previous version here used
  -- vim.uri_from_bufnr(bufnr):match("^%a+://") to skip non-file buffers,
  -- but vim.uri_from_bufnr() returns "file:///..." even for normal files,
  -- so that pattern always matched and on_dir was never called, disabling
  -- gopls entirely.

  on_attach = function(client, bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    local function jump_diagnostic(count)
      local jump = vim.diagnostic.jump
      if type(jump) == "function" then
        jump {
          count = count,
          on_jump = function(_, local_bufnr)
            vim.diagnostic.open_float(local_bufnr, { scope = "cursor", focus = false })
          end,
        }
        return
      end

      -- Neovim 0.10 fallback
      local move = count > 0 and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
      move()
      vim.diagnostic.open_float(0, { scope = "cursor", focus = false })
    end

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "[d", function()
      jump_diagnostic(-1)
    end, opts)
    vim.keymap.set("n", "]d", function()
      jump_diagnostic(1)
    end, opts)
    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
}
