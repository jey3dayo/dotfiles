version 6.0
if &cp | set nocp | endif
let s:cpo_save=&cpo
set cpo&vim
nmap gx <Plug>NetrwBrowseX
nnoremap <silent> <Plug>NetrwBrowseX :call netrw#NetrwBrowseX(expand("<cWORD>"),0)
let &cpo=s:cpo_save
unlet s:cpo_save
let mapleader = ","

nnoremap <Leader>ff :%s/left=/left:/g<CR>:%s/top=/top:/g<CR>
nnoremap <Leader>gg :%s/left:/left=/g<CR>:%s/top:/top=/g<CR>


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
colorscheme wombat


" show fullsize SPACE 
highlight ZenkakuSpace cterm=underline ctermfg=lightblue guibg=white
match ZenkakuSpace /　/


" set options
set autoindent
set backspace=2
set helplang=ja
set modelines=0
set nocompatible
set nrformats-=octal
set number
set ruler
set showmatch
set complete+=k
set cursorline
set wildmenu
set fdm=marker

set laststatus=2
"set statusline=%<%f\ %m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%l,%c%V%8P
set statusline=%F%m%r%h%w\%=\[%{&ff}]\[%{&fileencoding}]\[%l/%L][%3P]


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
nnoremap <Leader>b  :<C-u>buffers<CR>
nnoremap <Leader>m  :<C-u>marks<CR>
nnoremap <Leader>r  :<C-u>registers<CR>
nnoremap <Leader>y  :<C-u>YRShow<CR>
nnoremap <Leader>Y  :<C-u>YRSearch<CR>

nnoremap <Leader>s   <Nop>
nnoremap <Leader>sh :<C-u>set hlsearch<CR>
nnoremap <Leader>so :<C-u>source ~/.vimrc<CR>

nnoremap <Leader>gr :<C-u>vimgrep // *\|cwindow<LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT>
nnoremap <Leader>gx  :vimgrep /XXX/j *\|cw<CR>
nnoremap <Leader>gt :vimgrep /TODO/j *\|cw<CR>
nnoremap <Leader>gf :vimgrep /FIXME/j *\|cw<CR>

nnoremap <C-c> :<C-u>badd<Space>
nnoremap <C-d> :<C-u>bd<CR>
nnoremap <Tab> :<C-u>wincmd w<CR>

nnoremap <Leader>d  :<C-u>!doxygen Doxyfile<CR>

" ruler
" augroup cch
"   autocmd! cch
"   autocmd WinLeave * set nocursorcolumn nocursorline
"   autocmd WinEnter,BufRead * set cursorcolumn cursorline
" augroup END
" 
"highlight CursorLine guibg=white
"highlight CursorColumn  guibg=white
highlight FoldColumn  guibg=white guifg=blue


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
"inoremap <tab> <c-r>=InsertTabWrapper()<CR>
"" }}} Autocompletion using the TAB key


" backup
set backup
set swapfile
let TMP = '~/tmp'
" set backupdir=$TMP.'/vim'
" set directory=$TMP.'/vim'
set backupdir=~/tmp
set directory=~/tmp
set viminfo+=n~/tmp


" link jump
nnoremap t  <Nop>
nnoremap tt  <C-]>
nnoremap tj  :<C-u>tag<CR>
nnoremap tk  :<C-u>pop<CR>
nnoremap <Leader>t :<C-u>tags<CR>
nnoremap <C-t>t  :<C-u>pop<CR>


" tab
nnoremap <C-t>  <Nop>
nnoremap <C-t>n  :<C-u>tabnew<CR>
nnoremap <C-t>d  :<C-u>tabclose<CR>
nnoremap <C-t>o  :<C-u>tabonly<CR>
nnoremap <C-t>j  :<C-u>tabnext<CR>
nnoremap <C-t>k  :<C-u>tabprevious<CR>
nnoremap gt  :<C-u>tabnext<CR>
nnoremap gT  :<C-u>tabprevious<CR>

" ESC ESC -> nohlsearch
nnoremap <Esc><Esc> :<C-u>set nohlsearch<Return> 

set shellslash


" macro
inoremap <Leader>date <C-R>=strftime('%Y/%m/%d (%a)')<CR>
inoremap <Leader>time <C-R>=strftime('%H:%M')<CR>
inoremap <Leader>w3cd <C-R>=strftime('%Y-%m-%dT%H:%M:%S+09:00')<CR>
inoremap <Leader>sig <C-R>=strftime('%y%m%d %H:%M')<CR> Junya Nakazato
inoremap <Leader>siG <C-R>=strftime('%y%m%d')<CR> Junya Nakazato

" set grepprg=grep\ -nH\ $*


" Rename Command
command! -nargs=1 -complete=file Rename f <args>|call delete(expand('#'))


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
"let g:Tex_CompileRule_dvi = '/usr/local/bin/platex-sjis --interaction-nonstopmode $*'
let g:Tex_CompileRule_dvi = '/usr/local/bin/platex --interaction-nonstopmode $*'
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

" autocomplpop.vim
let g:acp_enableAtStartup=0

" LookupFile.vim
let g:LookupFile_AlwaysAcceptFirst=1
let g:LookupFile_PreserveLastPattern=0
let g:LookupFile_AllowNewFiles=0

" taglist.vim
set tags=tags

" NERD_commenter.vim <leader>+x => comment out
map <Leader>x ,c<space>
let NERDShutUp=1

" NERD_tree.vim
nnoremap <Leader>e  :<C-u>NERDTreeToggle<CR>

" taglist.vim
nnoremap <Leader>t  :<C-u>Tlist<CR>

" srcexpl.vim
let g:SrcExpl_RefreshTime = 0
let g:SrcExpl_UpdateTags = 1
let g:SrcExpl_RefreshMapKey = "<Space>"

" neocomplcache.vim
let g:NeoComplCache_EnableAtStartup=1
let g:NeoComplCache_SmartCase=1
let g:NeoComplCache_TagsAutoUpdate=1
let g:NeoComplCache_EnableInfo=1
let g:NeoComplCache_MinSyntaxLength=3
let g:NeoComplCache_SkipInputTime='0.1'
let g:NeoComplCache_SameFileTypeLists={}
let g:NeoComplCache_SameFileTypeLists['c']='cpp'
let g:NeoComplCache_SameFileTypeLists['cpp']='c'

