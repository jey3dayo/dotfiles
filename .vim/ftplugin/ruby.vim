setlocal nowrap tabstop=2 tw=0 sw=2 expandtab

setlocal makeprg=ruby\ -c\ %
setlocal errorformat=%m\ in\ %f\ on\ line\ %l

nmap [lsp]e <C-u>:!bundle exec rubocop -a "%"<CR>
