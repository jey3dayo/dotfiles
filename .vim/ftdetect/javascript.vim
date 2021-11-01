"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim ftdetect file
" Language: TSX (Typescript)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

autocmd FileType javascript setlocal commentstring={/*\ %s\ */}
autocmd BufNewFile,BufRead *jsx,*.js set filetype=javascript
