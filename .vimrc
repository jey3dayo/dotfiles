" j138 .vimrc

version 6.0
if &cp | set nocp | endif
let s:cpo_save=&cpo
set cpo&vim
nmap gx <Plug>NetrwBrowseX
nnoremap <silent> <Plug>NetrwBrowseX :call netrw#NetrwBrowseX(expand("<cWORD>"),0)
let &cpo=s:cpo_save
unlet s:cpo_save
let mapleader = ","


" vim: set ft=vim :
syntax enable
set encoding=utf-8
set fileencodings=utf-8,ucs-bom,iso-2022-jp-3,iso-2022-jp,eucjp-ms,euc-jisx0213,euc-jp,sjis,cp932
set fileformats=unix,mac,dos
set isfname+=32
set cindent


" color
set t_Co=256
highlight LineNr ctermfg=darkyellow
highlight NonText ctermfg=darkgrey
highlight Folded ctermfg=blue
highlight SpecialKey cterm=underline ctermfg=darkgrey
highlight SpecialKey ctermfg=grey
colorscheme wombat256
" colorscheme wombat
highlight Search ctermbg=7


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
"nnoremap <Leader>b  :<C-u>buffers<CR>
nnoremap <Leader>m  :<C-u>marks<CR>
nnoremap <Leader>r  :<C-u>registers<CR>
nnoremap <Leader>y  :<C-u>YRShow<CR>
nnoremap <Leader>Y  :<C-u>YRSearch<CR>

nnoremap <Leader>s   <Nop>
nnoremap <Leader>sh :<C-u>set hlsearch<CR>
nnoremap <Leader>so :<C-u>source ~/.vimrc<CR>
nnoremap gr :<C-u>vimgrep // **/*.php\|cwindow<LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT>

nnoremap <C-c> :<C-u>badd<Space>
nnoremap <C-d> :<C-u>bd<CR>
nnoremap <Tab> :<C-u>wincmd w<CR>

nnoremap <Leader>d  :<C-u>!doxygen Doxyfile<CR>


" backup
set backup
set swapfile
set backupdir=~/tmp
set directory=~/tmp
set viminfo+=n~/tmp


" link jump
nnoremap t  <Nop>
nnoremap tt  <C-]>
nnoremap tj  :<C-u>tag<CR>
nnoremap tk  :<C-u>pop<CR>


" tab
nnoremap <C-t>  <Nop>
nnoremap <C-t>c  :<C-u>tabnew<CR>
nnoremap <C-t>d  :<C-u>tabclose<CR>
nnoremap <C-t>o  :<C-u>tabonly<CR>
nnoremap <C-t>n  :<C-u>tabnext<CR>
nnoremap <C-t>p  :<C-u>tabprevious<CR>
nnoremap gt  :<C-u>tabnext<CR>
nnoremap gT  :<C-u>tabprevious<CR>


" ESC ESC -> nohlsearch
nnoremap <Esc><Esc> :<C-u>set nohlsearch<Return> 

set shellslash
set hidden
set shortmess+=I


" macro
inoremap <Leader>date <C-R>=strftime('%Y/%m/%d (%a)')<CR>
inoremap <Leader>time <C-R>=strftime('%H:%M')<CR>
inoremap <Leader>w3cd <C-R>=strftime('%Y-%m-%dT%H:%M:%S+09:00')<CR>
inoremap <Leader>sig <C-R>=strftime('%y%m%d %H:%M')<CR> Junya Nakazato
inoremap <Leader>siG <C-R>=strftime('%y%m%d')<CR> Junya Nakazato


" fuf.vim
nmap <silent> <Leader>ff :FufFile<CR>
nmap <silent> <Leader>fb :FufBuffer<CR>
nmap <silent> <Leader>ft :FufTag<CR>
nmap <silent> <Leader>fq :FufQuickfix<CR>


" git.vim
nnoremap <Leader>gp :GitPullRebase<CR>
nnoremap <Leader>gc :GitCommit<CR>
nnoremap <Leader>ga :GitAdd<CR>
nnoremap <Leader>gl :GitLog<CR>
nnoremap <Leader>gs :GitStatus<CR>
nnoremap <Leader>gD :GitDiff --cached<CR>
nnoremap <Leader>gd :GitDiff<CR>


" neocomplcache.vim
let g:NeoComplCache_SmartCase=1
let g:NeoComplCache_TagsAutoUpdate=1
let g:NeoComplCache_EnableInfo=1
let g:NeoComplCache_MinSyntaxLength=3
let g:NeoComplCache_SkipInputTime='0.1'
let g:NeoComplCache_SameFileTypeLists={}
let g:NeoComplCache_SameFileTypeLists['c']='cpp'
let g:NeoComplCache_SameFileTypeLists['cpp']='c'


" NERD_commenter.vim <leader>+x => comment out
map <Leader>x ,c<space>
let NERDShutUp=1


" NERD_tree.vim
nnoremap <Leader>e  :<C-u>NERDTreeToggle<CR>
let g:NERDTreeHijackNetrw = 0


" srcexpl.vim
nnoremap <Leader>s :<C-u>SrcExplToggle<CR>
let g:SrcExpl_UpdateTags = 1
let g:SrcExpl_RefreshMapKey = "<Space>"


" taglist.vim
set tags=tags
nnoremap <Leader>tl  :<C-u>Tlist<CR>


" Rename Command
command! -nargs=1 -complete=file Rename f <args>|call delete(expand('#'))


"dev
nnoremap <Leader>r :!/etc/init.d/httpd restart<CR>
