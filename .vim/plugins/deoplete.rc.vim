call deoplete#custom#option({
\ 'enable_at_startup': 1,
\ 'auto_complete_delay': 200,
\ 'smart_case': v:true,
\ })

inoremap <expr><C-h> deoplete#smart_close_popup()."<C-h>"
inoremap <expr><BS> deoplete#smart_close_popup()."<C-h>"
