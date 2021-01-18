" js config
setlocal nowrap tabstop=2 tw=0 sw=2 expandtab
setlocal foldmethod=marker
setlocal foldmarker=/*,*/

nmap [lsp]e <C-u>:!eslint --fix "%"<CR>
