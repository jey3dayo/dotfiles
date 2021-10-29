nnoremap [lsp] <Nop>
nmap <C-e> [lsp]

nnoremap <C-[> :lua vim.lsp.buf.references()<CR>
nnoremap <C-]> :lua vim.lsp.buf.definition()<CR>

nnoremap [lsp]gd :lua vim.lsp.buf.definition()<CR>
nnoremap [lsp]D :lua vim.lsp.buf.declaration()<CR>
nnoremap [lsp]t :lua vim.lsp.buf.type_definition()<CR>
nnoremap [lsp]i :lua vim.lsp.buf.implementation()<CR>
nnoremap [lsp]r :lua vim.lsp.buf.rename()<CR>
nnoremap [lsp]f :lua vim.lsp.buf.formatting()<CR>
nnoremap [lsp]a :lua vim.lsp.buf.code_action()<CR>
nnoremap <silent>K :lua vim.lsp.buf.hover()<CR>
nnoremap <silent>L :lua vim.lsp.buf.signature_help()<CR>
      
nnoremap <C-k> :lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap <C-j> :lua vim.lsp.diagnostic.goto_next()<CR>

lua << EOF
local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'tsserver', 'pyright', 'emmet_ls', 'clangd', 'sqls', 'graphql', 'bashls', 'cssls', 'dockerls', 'eslint', 'jsonls', 'html', 'vimls', 'yamlls' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end
EOF
