" js config
setlocal nowrap tabstop=2 tw=0 sw=2 expandtab
setlocal foldmethod=marker
setlocal foldmarker=/*,*/

" command! EsFix :call vimproc#system_bg("eslint --fix " . expand("%"))
command! EsFix :call vimproc#system_bg("prettier-eslint --write " . expand("%"))
map <Leader><c-f> <C-u>:!prettier-eslint --write %<CR>
