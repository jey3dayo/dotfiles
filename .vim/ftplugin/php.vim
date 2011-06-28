" php config
" set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set dictionary=~/.vim/dict/php.dict
let g:PHP_vintage_case_default_indent = 1

map <C-e> <ESC>:!php %<CR>

nmap <leader>l :call PHPLint()<CR>
nmap <leader><F1> :Ref phpmanual<Space>

" PHPLint
function! PHPLint()
    let result = system( &ft . ' -l ' . expand("%:p"))
    echo result
endfunction

