au BufRead,BufNewFile,BufReadPre *.coffee set filetype=coffee
au FileType coffee setlocal sw=2 sts=2 ts=2 et
au QuickFixCmdPost * nested cwindow | redraw!
nnoremap <silent> <C-E> :CoffeeCompile vert <CR><C-w>h
