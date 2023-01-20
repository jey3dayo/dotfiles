local status, mason = pcall(require, "mason")
if (not status) then return end
local status2, lspconfig = pcall(require, "mason-lspconfig")
if (not status2) then return end

local status3, nvim_lsp = pcall(require, "lspconfig")
if (not status3) then return end

local status4 = pcall(require, "lspsaga")
if (not status4) then return end

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

local set_opts = { silent = true }
Set_keymap("[lsp]", "<Nop>", set_opts)
Set_keymap("<C-e>", "[lsp]", set_opts)

lspconfig.setup {
  ensure_installed = { "sumneko_lua", "tailwindcss", "tsserver" },
}

lspconfig.setup_handlers({ function(server_name)
  local opts = {}
  opts.on_attach = function(_, bufnr)
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    Keymap("<C-]>", vim.lsp.buf.definition, bufopts)
    Keymap("[lsp]f", vim.lsp.buf.format, bufopts)
    Keymap("[lsp]d", vim.lsp.buf.declaration, bufopts)
    Keymap("[lsp]t", vim.lsp.buf.type_definition, bufopts)
    Keymap("[lsp]i", vim.lsp.buf.implementation, bufopts)

    -- lspsaga
    Keymap("<C-j>", "<cmd>Lspsaga diagnostic_jump_next<CR>", bufopts)
    Keymap("<C-k>", "<cmd>Lspsaga diagnostic_jump_prev<CR>", bufopts)
    Keymap("K", "<cmd>Lspsaga hover_doc<CR>", bufopts)
    Keymap("<C-[>", "<Cmd>Lspsaga lsp_finder<CR>", bufopts)
    Keymap("[lsp]r", "<cmd>Lspsaga rename<CR>", bufopts)
    Keymap("[lsp]a", "<cmd>Lspsaga code_action<CR>", bufopts)
  end
  nvim_lsp[server_name].setup(opts)
end })
