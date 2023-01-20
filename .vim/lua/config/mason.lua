local keymap = vim.keymap.set;
local status, mason = pcall(require, "mason")
if (not status) then return end
local status2, lspconfig = pcall(require, "mason-lspconfig")
if (not status2) then return end

local status3, nvim_lsp = pcall(require, "lspconfig")
if (not status3) then return end

local status4  = pcall(require, "lspsaga")
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
vim.api.nvim_set_keymap("n", "[lsp]", "<Nop>", set_opts)
vim.api.nvim_set_keymap("n", "<C-e>", "[lsp]", set_opts)

lspconfig.setup {
  ensure_installed = { "sumneko_lua", "tailwindcss", "tsserver" },
}

lspconfig.setup_handlers({ function(server_name)
  local opts = {}
  opts.on_attach = function(_, bufnr)
    local bufopts = { silent = true, buffer = bufnr }
    keymap("n", "<C-]>", vim.lsp.buf.definition, bufopts)
    keymap("n", "[lsp]f", vim.lsp.buf.format, bufopts)
    keymap("n", "[lsp]d", vim.lsp.buf.declaration, bufopts)
    keymap("n", "[lsp]t", vim.lsp.buf.type_definition, bufopts)
    keymap("n", "[lsp]i", vim.lsp.buf.implementation, bufopts)

    -- lspsaga
    keymap("n", "<C-j>", "<cmd>Lspsaga diagnostic_jump_next<CR>", bufopts)
    keymap("n", "<C-k>", "<cmd>Lspsaga diagnostic_jump_prev<CR>", bufopts)
    keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", bufopts)
    keymap("n", "<C-[>", "<Cmd>Lspsaga lsp_finder<CR>", bufopts)
    keymap("n", "[lsp]r", "<cmd>Lspsaga rename<CR>", bufopts)
    keymap("n", "[lsp]a", "<cmd>Lspsaga code_action<CR>", bufopts)
  end
  nvim_lsp[server_name].setup(opts)
end })
