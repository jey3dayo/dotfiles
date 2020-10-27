au VimEnter,Colorscheme * :hi IndentGuidesOdd guibg=red ctermbg=3
au VimEnter,Colorscheme * :hi IndentGuidesEven guibg=green ctermbg=4
au FileType coffee,ruby,javascript,python IndentGuidesEnable
nmap <silent><Leader>sg <Plug>IndentGuidesToggle

let g:indent_guides_auto_colors=0
let g:indent_guides_start_level=2
let g:indent_guides_guide_size=1
let g:indent_guides_enable_on_vim_startup=0
let g:indent_guides_color_change_percent=20
