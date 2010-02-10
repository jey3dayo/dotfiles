autocmd FileType php :set dictionary+=~/.vim/dict/PHP.dict

" nmap <leader>l :call PHPLint()<CR>

" PHPLint
function! PHPLint()
    let result = system( &ft . ' -l ' . bufname(""))
    echo result
endfunction

