source ~/.vimrc

colorscheme desert256
set guioptions=egmrLt
set transparency=15


" ruler
augroup cch
  autocmd! cch
  autocmd WinLeave * set nocursorcolumn nocursorline
  autocmd WinEnter,BufRead * set cursorcolumn cursorline
augroup END

highlight CursorLine ctermbg=black guibg=black
highlight CursorColumn ctermbg=black guibg=black
