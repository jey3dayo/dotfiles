nnoremap <buffer> ,l  :<C-u>execute '!' &l:filetype '-l' shellescape(expand('%'))<Return>

