" php config
set noexpandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set dictionary=~/.vim/dict/php.dict
au Syntax php set fdm=syntax
let g:PHP_vintage_case_default_indent = 1

map <leader><c-E> <ESC>:!php %<CR>

set makeprg=php\ -l\ %
set errorformat=%m\ in\ %f\ on\ line\ %l

