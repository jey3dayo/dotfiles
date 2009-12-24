version 6.0
if &cp | set nocp | endif
let s:cpo_save=&cpo
set cpo&vim
nmap gx <Plug>NetrwBrowseX
nnoremap <silent> <Plug>NetrwBrowseX :call netrw#NetrwBrowseX(expand("<cWORD>"),0)
let &cpo=s:cpo_save
unlet s:cpo_save


" vim: set ft=vim :
syntax enable
set encoding=utf-8
set fileencodings=utf-8,ucs-bom,iso-2022-jp-3,iso-2022-jp,eucjp-ms,euc-jisx0213,euc-jp,sjis,cp932
set fileformats=unix,mac,dos


" color
highlight LineNr ctermfg=darkyellow
highlight NonText ctermfg=darkgrey
highlight Folded ctermfg=blue
highlight SpecialKey cterm=underline ctermfg=darkgrey
highlight SpecialKey ctermfg=grey
colorscheme desert


" show fullsize<SPACE>
highlight ZenkakuSpace cterm=underline ctermfg=lightblue guibg=white
match ZenkakuSpace /　/


" set options
set autoindent
set backspace=2
set helplang=ja
set incsearch
set modelines=0
set nocompatible
set nrformats-=octal
set number
set ruler
set showmatch
set complete+=k


" search setting
set hlsearch
set ignorecase
set incsearch
set smartcase


" tab width
set ts=4
set sw=4
set softtabstop=4
set expandtab
set tw=0


 if v:version < 700
    set migemo
 endif

filetype on
filetype plugin on
filetype indent on


" map
nnoremap ,m  :<C-u>!gcc % -o %< -framework cocoa<cr>
nnoremap ,M  :<C-u>w<cr>:!gcc % -o %< -framework cocoa<cr>:!./%<<cr>
nnoremap ,r  :<C-u>!ruby %<cr>
nnoremap ,so :<C-u>source ~/.vimrc<cr>

nnoremap <Leader>b  :<C-u>buffers<cr>
nnoremap <Leader>m  :<C-u>marks<cr>
nnoremap <Leader>r  :<C-u>registers<cr>
nnoremap <Leader>s   <Nop>
nnoremap <Leader>sH :<C-u>set nohlsearch<cr>
nnoremap <Leader>sh :<C-u>set hlsearch<cr>
nnoremap <Leader>so :<C-u>source ~/.vimrc<cr>
nnoremap <Leader>g :<C-u>vimgrep /./ %\|cwindow
nnoremap <Leader>y :<C-u>YRSearch<cr>


" link jump
nnoremap t  <Nop>
nnoremap tt  <C-]>
nnoremap tj  :<C-u>tag<cr>
nnoremap tk  :<C-u>pop<cr>
nnoremap tl  :<C-u>tags<cr>


" ruler
augroup cch
  autocmd! cch
  autocmd WinLeave * set nocursorcolumn nocursorline
  autocmd WinEnter,BufRead * set cursorcolumn cursorline
augroup END

highlight CursorLine guibg=white
highlight CursorColumn  guibg=white


"<TAB> complement
" {{{ Autocompletion using the TAB key
" This function determines, wether we are on the start of the line text (then tab indents) or
" if we want to try autocompletion
function! InsertTabWrapper()
        let col = col('.') - 1
        if !col || getline('.')[col - 1] !~ '\k'
                return "\<TAB>"
        else
                if pumvisible()
                        return "\<C-N>"
                else
                        return "\<C-N>\<C-P>"
                end
        endif
endfunction


"" Remap the tab key to select action with InsertTabWrapper
"inoremap <tab> <c-r>=InsertTabWrapper()<cr>
"" }}} Autocompletion using the TAB key


" backup
set backup
set backupdir=~/tmp
set swapfile
set directory=~/tmp


" tab
nnoremap <C-t>  <Nop>
nnoremap <C-t>n  :<C-u>tabnew<cr>
nnoremap <C-t>d  :<C-u>tabclose<cr>
nnoremap <C-t>o  :<C-u>tabonly<cr>
nnoremap <C-t>j  :<C-u>tabnext<cr>
nnoremap <C-t>k  :<C-u>tabprevious<cr>
nnoremap gt  :<C-u>tabnext<cr>
nnoremap gT  :<C-u>tabprevious<cr>

" ESC ESC -> nohlsearch
nnoremap <Esc><Esc> :<C-u>set nohlsearch<Return> 

set shellslash

" set grepprg=grep\ -nH\ $*

" create dvi command
let g:Tex_CompileRule_dvi = 'platex --interaction=nonstopmode $*'


" dvi viewer
let g:Tex_ViewRule_dvi = 'dviout'


" create pdf
let g:Tex_FormatDependency_pdf = 'dvi,pdf'
let g:Tex_CompileRule_pdf = 'dvipdfmx $*.dvi'
let g:Tex_ViewRule_pdf = 'C:\Program Files\Adobe\Acrobat 7.0\Acrobat\Acrobat.exe'


" jbitex config
let g:Tex_BibtexFlavor = 'jbibtex -kanji=sjis'
let g:Tex_ViewRule_pdf = 'open -a /Applications/Preview.app'
let g:Tex_FormatDependency_pdf = 'dvi,pdf'
let g:Tex_CompileRule_pdf = '/usr/local/bin/dvipdfmx $*.dvi'
let g:Tex_CompileRule_dvi = '/usr/local/bin/platex-sjis --interaction-nonstopmode $*'
let g:Tex_IgnoredWarnings =
      \"Underfull\n".
      \"Overfull\n".
      \"specifier changed to\n".
      \"You have requested\n".
      \"Missing number, treated as zero.\n".
      \"There were undefined references\n".
      \"Citation %.%# undefined\n".
      \'LaTeX Font Warning:'"
let g:Tex_IgnoreLevel = 8


" python setting
autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class


" java setting
let java_highlight_all=1
let java_allow_cpp_keywords=1
let java_space_errors=1
let java_highlight_functions=1


" rails.vim
let g:rails_level=4
let g:rails_default_file="app/controllers/application.rb"
let g:rails_default_database="sqlite3"


" rubycomplete.vim
autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby,eruby let g:rubycomplete_rails = 1
autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
au BufNewFile,BufRead * set tabstop=4 shiftwidth=4
au BufNewFile,BufRead *.rhtml set tabstop=2 shiftwidth=2
au BufNewFile,BufRead *.erb set tabstop=2 shiftwidth=2
au BufNewFile,BufRead *.rb set tabstop=2 shiftwidth=2
au BufNewFile,BufRead *.yml set tabstop=2 shiftwidth=2


" HTML
autocmd BufNewFile *.html 0r ~/.vim/templates/skel.html

" PHP
autocmd FileType php :set dictionary+=~/.vim/dict/PHP.dict

" PHPLint
function PHPLint()
    let result = system( &ft . ' -l ' . bufname(""))
    echo result
endfunction

nmap ,l :call PHPLint()<CR>


" Objective-C
"let objc_syntax_for_h = 1
autocmd Filetype objc setlocal showmatch dict=~/.vim/dict/objc.dict



"" compile C lang
"command! Gcc call s:Gcc()
"nmap <F5> :Gcc<CR>
"
"function! s:Gcc()
"   :w
"   :!gcc % -o %.out
"   :!%.out
"endfunction


" LookupFile.vim
nmap <unique> <silent> <C-S> :LUBufs ^.*<CR>
let g:LookupFile_AlwaysAcceptFirst=1
let g:LookupFile_PreserveLastPattern=0
let g:LookupFile_AllowNewFiles=0


" taglist.vim
set tags=tags



