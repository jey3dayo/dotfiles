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
set virtualedit+=block


" color
" set t_Co=88
set t_Co=256
highlight LineNr ctermfg=darkyellow
highlight NonText ctermfg=darkgrey
highlight Folded ctermfg=blue
highlight SpecialKey cterm=underline ctermfg=darkgrey
highlight SpecialKey ctermfg=grey
colorscheme wombat
" colorscheme wombat256mod
highlight Search ctermbg=7


" visible SpecialKey
set list
set listchars=tab:^\ ,trail:-


" visible fullsize space
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
set noscrollbind


set laststatus=2
set statusline=%F%m%r%h%w\%=\[%{&ff}]\[%{&fileencoding}]\[%l/%L][%3P]


" search setting
set hlsearch
set ignorecase
set incsearch
set smartcase


" tab width
set tabstop=4
set shiftwidth=4
set softtabstop=4
set noexpandtab
set textwidth=0


if v:version < 700
    set migemo
endif

filetype on
filetype plugin on
filetype indent on


" map
nnoremap <Leader>y  :<C-u>YRShow<CR>

nnoremap <Leader>s   <Nop>
nnoremap <Leader>sh :<C-u>set hlsearch<CR>
nnoremap <Leader>so :<C-u>source ~/.vimrc<CR>
nnoremap <Leader>gr :<C-u>vimgrep // %<Bar>cw<LEFT><LEFT><LEFT><LEFT><LEFT><LEFT>
nnoremap <Leader>gR :<C-u>vimgrep // **/*.*<Bar>cw<LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT>
nnoremap <Leader>gx :<C-u>vimgrep /\(TODO\<Bar>XXX\<Bar>FIXME\)/ %<Bar>cw<CR>
nnoremap <Leader>gX :<C-u>vimgrep /\(TODO\<Bar>XXX\<Bar>FIXME\)/ **/*.*<Bar>cw<CR>

nnoremap <C-c> :<C-u>badd<Space>
nnoremap <C-d> :<C-u>bd<CR>
nnoremap <Tab> :<C-u>wincmd w<CR>
nmap <silent> <F3> :execute 'vimgrep! /<C-R>=expand('<cword>')<CR>/j %'<CR>:copen10<CR>


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


" fugitive.vim
nnoremap <Leader>gb :Gblame<CR>
nnoremap <Leader>gc :Gcommit<CR>
nnoremap <Leader>gd :Gdiff<CR>
nnoremap <Leader>gg :Ggrep<Space>
nnoremap <Leader>gl :Glog<CR>
nnoremap <Leader>gr :Gremove<CR>
nnoremap <Leader>gs :Gstatus<CR>
nnoremap <Leader>gr :Gread<CR>
nnoremap <Leader>gw :Gwrite<CR>

" Kwbd.vim
nnoremap <C-D> :<C-u>Kwbd<CR>


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


" ref.vim
let g:ref_phpmanual_path = $HOME . '/.vim/dict/phpmanual'
let g:ref_jquery_path = $HOME . '/.vim/dict/jqapi-latest/docs'
noremap <Leader>d :<C-u>Ref alc<Space>


" smartchr.vim
inoremap <buffer><expr> + smartchr#one_of(' + ', '++', '+')
inoremap <buffer><expr> & smartchr#one_of(' & ', ' && ', '&')
inoremap <buffer><expr> % smartchr#one_of(' % ', '%')
inoremap <buffer><expr> <Bar> smartchr#one_of(' <Bar> ', ' <Bar><Bar> ', '<Bar>')
inoremap <buffer><expr> , smartchr#one_of(', ', ',')
inoremap <buffer><expr> ? smartchr#one_of('? ', '?')
inoremap <buffer><expr> : smartchr#one_of(': ', '::', ':')

" snipmate.vim
let g:snippets_dir = $HOME.'/.vim/snippets'


" taglist.vim
set tags=tags
nnoremap <Leader>T  :<C-u>Tlist<CR>


" unite.vim
let g:unite_enable_start_insert=1
noremap <Leader>b :Unite buffer<CR>
noremap <Leader>f :Unite file<CR>
"noremap <Leader>m :Unite file_mru<CR>
noremap <C-t>b :<C-u>tabnew<CR>:tabmove<CR>:Unite buffer<CR>
noremap <C-t>f :<C-u>tabnew<CR>:tabmove<CR>:Unite file<CR>
noremap <C-t>m :<C-u>tabnew<CR>:tabmove<CR>:Unite file_mru<CR>

au FileType unite nnoremap <silent> <buffer> <ESC><ESC> :q<CR>
au FileType unite inoremap <silent> <buffer> <ESC><ESC> <ESC>:q<CR>

au FileType unite nnoremap <silent> <buffer> <expr> <C-J> unite#do_action('split')
au FileType unite inoremap <silent> <buffer> <expr> <C-J> unite#do_action('split')
au FileType unite nnoremap <silent> <buffer> <expr> <C-K> unite#do_action('vsplit')
au FileType unite inoremap <silent> <buffer> <expr> <C-K> unite#do_action('vsplit')


" vundle.vim {{{
set nocompatible
filetype off

if has("win32") || has("win64")
  set rtp+=C:/repos/dotfiles/.vim/vundle.git/
  call vundle#rc('C:/repos/dotfiles/.vim/bundle/')
else
    set rtp+=~/.vim/bundle/vundle/
    call vundle#rc()
endif

Bundle 'Shougo/neocomplcache'
Bundle 'Shougo/unite.vim'
Bundle 'chrismetcalf/vim-yankring'
Bundle 'fuenor/qfixhowm'
Bundle 'gregsexton/VimCalc'
Bundle 'gmarik/vundle'
Bundle 'kana/vim-smartchr'
"Bundle 'koron/chalice'
Bundle 'mattn/zencoding-vim'
Bundle 'msanders/snipmate.vim'
Bundle 'rgarver/Kwbd.vim'
Bundle 'scrooloose/nerdcommenter'
Bundle 'scrooloose/nerdtree'
"Bundle 'shemerey/vim-project'
Bundle 'thinca/vim-guicolorscheme'
Bundle 'thinca/vim-quickrun'
Bundle 'thinca/vim-ref'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-surround'
Bundle 'tsaleh/vim-align'
Bundle 'tsaleh/vim-matchit'
Bundle 'vim-scripts/DoxygenToolkit.vim'
Bundle 'vim-scripts/L9.git'
Bundle 'vim-scripts/TwitVim'
Bundle 'vim-scripts/cecutil'
Bundle 'vim-scripts/eregex.vim'
Bundle 'vim-scripts/genutils'
Bundle 'vim-scripts/grep.vim'
Bundle 'vim-scripts/SQLUtilities'
Bundle 'vim-scripts/multvals.vim'
Bundle 'vim-scripts/renamer.vim'
Bundle 'vim-scripts/sudo.vim'
Bundle 'vim-scripts/taglist.vim'
Bundle 'vim-scripts/vcscommand.vim'
Bundle 'vim-scripts/wombat256.vim'
Bundle 'molokai'

filetype plugin indent on
"}}}


" yanktmp.vim
map <silent>sy :call YanktmpYank()<CR>
map <silent>sp :call YanktmpPaste_p()<CR>
map <silent>sP :call YanktmpPaste_P()<CR>


" zencoding.vim
let g:user_zen_expandabbr_key = '<c-e>'


" Rename Command
command! -nargs=1 -complete=file Rename f <args>|call delete(expand('#'))


let VIMRC_MINE = expand('~/.vimrc.mine')
if( filereadable(VIMRC_MINE) )
    exe "source " . VIMRC_MINE
endif

