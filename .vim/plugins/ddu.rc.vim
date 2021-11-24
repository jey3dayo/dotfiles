" Set default sources
call ddc#custom#patch_global('sources', ['nvim-lsp', 'file'])

" Call default sources
call ddu#start({})

" Set buffer-name specific configuration
call ddu#custom#patch_buffer('files', {
    \ 'sources': [
    \   {'name': 'file', 'params': {}},
    \   {'name': 'file_old', 'params': {}},
    \ ],
    \ })

" Specify buffer name
call ddu#start({'buffer_name': 'files'})

" lsp
call ddc#custom#patch_global('sourceOptions', {
      \ '_': { 'matchers': ['matcher_head'] },
      \ 'nvim-lsp': {
      \   'mark': 'lsp',
      \   'forceCompletionPattern': '\.\w*|:\w*|->\w*' },
      \ })
