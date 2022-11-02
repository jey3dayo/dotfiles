set noshowmode
set laststatus=2
let g:lightline = {
\ 'colorscheme': 'gruvbox',
\ 'active': {
\   'left': [
\     [ 'mode', 'paste' ],
\     [ 'fugitive', 'readonly', 'filename', 'modified', 'qfstatusline'],
\   ],
\ },
\ 'component': {
\   'fugitive': '%{exists("*FugitiveHead")?FugitiveHead():""}',
\ },
\ 'component_visible_condition': {
\   'readonly': '(&filetype!="help"&& &readonly)',
\   'modified': '(&filetype!="help"&&(&modified||!&modifiable))',
\   'fugitive': '(exists("*FugitiveHead") && ""!=FugitiveHead())',
\ },
\ 'component_expand': {
\   'qfstatusline': 'qfstatusline#Update',
\  },
\ 'component_type':   {
\   'qfstatusline': 'error',
\  },
\}
let g:Qfstatusline#UpdateCmd = function('lightline#update')
