" deoppet
imap <C-k>  <Plug>(deoppet_expand)
imap <expr><Tab>  deoppet#expandable() ?
\ "\<Plug>(deoppet_expand)" : "\<Tab>"
imap <C-f>  <Plug>(deoppet_jump_forward)
imap <C-b>  <Plug>(deoppet_jump_backward)
smap <C-f>  <Plug>(deoppet_jump_forward)
smap <C-b>  <Plug>(deoppet_jump_backward)

call deoppet#initialize()
call deoppet#custom#option('snippets',
\ map(globpath(&runtimepath, 'neosnippets', 1, 1),
\     { _, val -> { 'path': val } }))
