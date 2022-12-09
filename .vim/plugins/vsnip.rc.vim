let g:vsnip_snippet_dir = "~/.cache/dein/repos/github.com/rafamadriz/friendly-snippets/snippets"

imap <expr> <C-k> vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-k>'
smap <expr> <C-k> vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-k>'
imap <expr> <TAB> vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<TAB>'
smap <expr> <TAB> vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<TAB>'
imap <expr> <S-TAB> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-TAB>'
smap <expr> <S-TAB> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-TAB>'

" If you want to use snippet for multiple filetypes, you can `g:vsnip_filetypes` for it.
let g:vsnip_filetypes = {}
let g:vsnip_filetypes.javascriptreact = ['javascript']
let g:vsnip_filetypes.typescriptreact = ['typescript']
