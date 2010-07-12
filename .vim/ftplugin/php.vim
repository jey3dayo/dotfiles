set dictionary=~/.vim/dict/php.dict

nmap <leader>l :call PHPLint()<CR>

" PHPLint
function! PHPLint()
    let result = system( &ft . ' -l ' . expand("%:p"))
    echo result
endfunction

