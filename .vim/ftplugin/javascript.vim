" js config
setlocal nowrap tabstop=2 tw=0 sw=2 expandtab
setlocal foldmethod=marker
setlocal foldmarker=/*,*/

nmap [lsp]j <C-u>:!babel-node "%"<CR>
nmap [lsp]J <C-u>:!jest "%"<CR>
