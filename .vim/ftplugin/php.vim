" php config
setlocal nowrap tabstop=4 tw=0 sw=4 noexpandtab
setlocal dictionary=~/.vim/dict/php.dict
au Syntax php set fdm=syntax
let g:PHP_vintage_case_default_indent = 1

map <leader><c-e> <ESC>:!php %<CR>

setlocal makeprg=php\ -l\ %
setlocal errorformat=%m\ in\ %f\ on\ line\ %l

