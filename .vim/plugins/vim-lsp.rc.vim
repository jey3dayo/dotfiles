let g:lsp_signs_enabled = 1
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_virtual_text_enabled = 1
let g:lsp_text_edit_enabled = 1

let g:asyncomplete_auto_popup = 1
let g:asyncomplete_auto_completeopt = 0
let g:asyncomplete_popup_delay = 200

let g:lsp_signs_error = {'text': '✗'}
let g:lsp_signs_warning = {'text': '‼'}
let g:lsp_signs_information = {'text': 'i'}
let g:lsp_signs_hint = {'text': '?'}

nnoremap [lsp] <Nop>
nmap <C-e> [lsp]
nnoremap [lsp]r :<C-u>LspRename<CR>
nnoremap [lsp]f :<C-u>LspDocumentFormatSync<CR>
nnoremap [lsp]F :<C-u>LspDocumentDiagnostics<CR>
nnoremap [lsp]g :<C-u>LspWorkspaceSymbol<CR>
nnoremap [lsp]a :<C-u>LspCodeAction<CR>

nnoremap <C-[> :<C-u>LspReferences<CR>
nnoremap <C-]> :<C-u>LspDefinition<CR>
nnoremap K :<C-u>LspHover<CR>
nmap <C-k> <C-u>:LspPreviousDiagnostic<CR>
nmap <C-j> <C-u>:LspNextDiagnostic<CR>

let g:lsp_settings_filetype_javascript = ['typescript-language-server', 'eslint-language-server']
let g:lsp_settings_filetype_typescript = ['typescript-language-server', 'eslint-language-server']
let g:lsp_settings_filetype_jsx        = ['typescript-language-server', 'eslint-language-server']
let g:lsp_settings_filetype_ruby        = ['solargraph']

