let g:deoplete#enable_at_startup = 1
let g:deoplete#auto_complete_delay = 0

inoremap <expr><C-h> deoplete#smart_close_popup()."<C-h>"
inoremap <expr><BS> deoplete#smart_close_popup()."<C-h>"
