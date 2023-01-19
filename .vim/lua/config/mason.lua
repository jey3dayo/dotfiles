local status, mason = pcall(require, "mason")
if (not status) then return end
local status2, lspconfig = pcall(require, "mason-lspconfig")
if (not status2) then return end

local nvim_lsp = require("lspconfig")
local status3, nvim_lsp = pcall(require, "lspconfig")
if (not status3) then return end

mason.setup({
  ui = {
    icons = {
      server_installed = "✓",
      server_pending = "➜",
      server_uninstalled = "✗",
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

lspconfig.setup {
  ensure_installed = { "sumneko_lua", "tailwindcss" },
}

lspconfig.setup_handlers({ function(server_name)
  local opts = {}
  opts.on_attach = function(_, bufnr)
    local bufopts = { silent = true, buffer = bufnr }
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
    vim.keymap.set("n", "gtD", vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set("n", "grf", vim.lsp.buf.references, bufopts)
    vim.keymap.set("n", "<space>p", vim.lsp.buf.format, bufopts)
  end
  nvim_lsp[server_name].setup(opts)
end })
