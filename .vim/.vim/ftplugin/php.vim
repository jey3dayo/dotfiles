autocmd FileType php :set dictionary+=~/.vim/dict/PHP.dict


" PHPLint
function PHPLint()
    let result = system( &ft . ' -l ' . bufname(""))
    echo result
endfunction

nmap <leader>l :call PHPLint()<CR>
