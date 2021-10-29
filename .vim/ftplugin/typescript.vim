" ts config
setlocal nowrap tabstop=2 tw=0 sw=2 expandtab
setlocal foldmethod=marker
setlocal foldmarker=/*,*/

nmap [lsp]e <C-u>:EslintFixAll<CR>
nmap [lsp]p <C-u>:!prettier --write "%"<CR>
nmap [lsp]j <C-u>:!ts-node "%"<CR>
nmap [lsp]J <C-u>:!jest "%"<CR>
