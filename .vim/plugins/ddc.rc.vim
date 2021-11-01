" Customize global settings
call ddc#custom#patch_global('sources', ['nvim-lsp', 'deoppet', 'around', 'file', 'cmdline', 'cmdline-history'])

call ddc#custom#patch_global('sourceOptions', {
      \ '_': {
      \   'matchers': ['matcher_head'],
      \   'sorters': ['sorter_rank']},
      \ 'around': {'mark': 'A'},
      \ 'file': {
      \   'mark': 'F',
      \   'isVolatile': v:true,
      \   'forceCompletionPattern': '\S/\S*',
      \ },
      \ 'deoppet': {'dup': v:true, 'mark': 'dp'},
      \ 'cmdline': {'mark': 'cmdLine'},
      \ 'cmdline-history': {'mark': 'history'},
      \ 'nvim-lsp': {
      \   'mark': 'LSP',
      \   'forceCompletionPattern': '\.\w*|:\w*|->\w*' },
      \ })

call ddc#custom#patch_global('sourceParams', {
      \ 'around': {'maxSize': 500},
      \ 'file': {'smartCase': v:true},
      \ 'necovim': {'smartCase': 'vim'},
      \ })


" Customize settings on a filetype
call ddc#custom#patch_filetype(
      \ ['vim', 'toml'], 'sources', ['necovim'])

call ddc#custom#patch_filetype(['markdown'], 'sourceParams', {
      \ 'around': {'maxSize': 100},
      \ })

" Mappings

" <TAB>: completion.
inoremap <silent><expr> <TAB>
\ pumvisible() ? '<C-n>' :
\ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
\ '<TAB>' : ddc#map#manual_complete()

" <S-TAB>: completion back.
inoremap <expr><S-TAB>  pumvisible() ? '<C-p>' : '<C-h>'

call ddc#enable()

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
