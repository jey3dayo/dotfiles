" php config
setlocal nowrap tabstop=4 tw=0 sw=4 expandtab
au Syntax php set fdm=syntax
let g:PHP_vintage_case_default_indent = 1

map <Leader><c-e> <C-u>:!php %<CR>

setlocal makeprg=php\ -l\ %
setlocal errorformat=%m\ in\ %f\ on\ line\ %l
