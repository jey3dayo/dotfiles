set noshowmode
set laststatus=2
let g:lightline = {
\ 'colorscheme': 'gruvbox',
\ 'active': {
\   'left': [
\     [ 'mode', 'paste' ],
\     [ 'fugitive', 'readonly', 'filename', 'modified', 'qfstatusline'],
\     [ 'lsp_warnings', 'lsp_errors' ]
\   ],
\ },
\ 'component': {
\   'fugitive': '%{exists("*fugitive#head")?fugitive#head():""}',
\ },
\'component_function': {
\   'lsp_warnings': 'LightLineLSPWarning',
\   'lsp_errors': 'LightLineLSPError',
\ },
\ 'component_visible_condition': {
\   'readonly': '(&filetype!="help"&& &readonly)',
\   'modified': '(&filetype!="help"&&(&modified||!&modifiable))',
\   'fugitive': '(exists("*fugitive#head") && ""!=fugitive#head())',
\ },
\ 'component_expand': {
\   'qfstatusline': 'qfstatusline#Update',
\  },
\ 'component_type':   {
\   'qfstatusline': 'error',
\   'lsp_warnings': 'warning',
\   'lsp_errors': 'error',
\  },
\}
function! LightLineLSPWarning() abort
  let l:count = lsp#get_buffer_diagnostics_counts().warning
  return l:count == 0 ? '' : 'W:' . l:count
endfunction

function! LightLineLSPError() abort
  let l:count = lsp#get_buffer_diagnostics_counts().error
  return l:count == 0 ? '' : 'E:' . l:count
endfunction
let g:Qfstatusline#UpdateCmd = function('lightline#update')
