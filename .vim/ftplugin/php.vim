" php config
" set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set dictionary=~/.vim/dict/php.dict
au Syntax php set fdm=syntax
let php_folding=1
let g:PHP_vintage_case_default_indent = 1

map <leader><c-e> <ESC>:!php %<CR>

" ref.vim
nmap <leader>D :Ref phpmanual<Space>


set makeprg=php\ -l\ %
set errorformat=%m\ in\ %f\ on\ line\ %l

