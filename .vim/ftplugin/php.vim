setlocal nowrap tabstop=4 tw=0 sw=4 expandtab
au Syntax php set fdm=syntax
let g:PHP_vintage_case_default_indent = 1

setlocal makeprg=php\ -l\ %
setlocal errorformat=%m\ in\ %f\ on\ line\ %l
