" Customize global settings
call ddc#custom#patch_global('sources', ['vsnip', 'around', 'file', 'nvim-lsp', 'around', 'cmdline', 'cmdline-history'])

call ddc#custom#patch_global('ui', 'native')

call ddc#custom#patch_global('sourceOptions', {
      \ '_': {
      \   'matchers': ['matcher_head'],
      \   'sorters': ['sorter_rank']},
      \ 'around': {'mark': 'A'},
      \ 'vsnip': {'mark': 'vsnip'},
      \ 'file': {
      \   'mark': 'F',
      \   'isVolatile': v:true,
      \   'forceCompletionPattern': '\S/\S*',
      \ },
      \ 'cmdline': {'mark': 'cmdLine'},
      \ 'cmdline-history': {'mark': 'history'},
      \ 'nvim-lsp': {
      \   'mark': 'LSP',
      \   'forceCompletionPattern': '\.\w*|:\w*|->\w*' },
      \ })

call ddc#custom#patch_global('sourceParams', {
      \ 'around': {'maxSize': 500},
      \ 'file': {'smartCase': v:true},
      \ })

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
