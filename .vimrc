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

" set list
nmap <Leader>sl :set list<CR>:set number<CR>
nmap <Leader>nl :set nolist<CR>:set nonumber<CR>

" visible SpecialKey
set list
set listchars=tab:^\ ,trail:-


" visible fullsize space
highlight ZenkakuSpace cterm=underline ctermfg=lightblue guibg=white
match ZenkakuSpace /　/

" set options
set autoindent
set smartindent
set backspace=2
set helplang=ja
set modelines=0
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
nnoremap <Leader>s <Nop>
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


"set encoding
nnoremap <Leader>si :e! ++enc=iso-2022-jp<CR>
nnoremap <Leader>su :e! ++enc=utf-8<CR>
nnoremap <Leader>ss :e! ++enc=sjis<CR>
nnoremap <Leader>se :e! ++enc=euc-jp<CR>


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
nnoremap <Leader>gd :Gdiff<CR>
nnoremap <Leader>gg :Ggrep<Space>
nnoremap <Leader>gl :Glog<CR>
nnoremap <Leader>gs :Gstatus<CR>
nnoremap <Leader>gw :Gwrite<CR>


" neocomplcache.vim
let g:NeoComplCache_SmartCase=1
let g:NeoComplCache_TagsAutoUpdate=1
let g:NeoComplCache_EnableInfo=1
let g:NeoComplCache_MinSyntaxLength=3
let g:NeoComplCache_SkipInputTime='0.1'
let g:NeoComplCache_SameFileTypeLists={}
let g:NeoComplCache_SameFileTypeLists['c']='cpp'
let g:NeoComplCache_SameFileTypeLists['cpp']='c'


" NERD_tree.vim
nnoremap <Leader>e  :<C-u>NERDTreeToggle<CR>
let g:NERDTreeHijackNetrw = 0


" ref.vim
let g:ref_phpmanual_path = $HOME . '/.vim/dict/phpmanual'
let g:ref_jquery_path = $HOME . '/.vim/dict/jqapi-latest/docs'
noremap <Leader>d :<C-u>Ref alc<Space>


"sparkup.vim
let g:sparkupExecuteMapping='<c-e>'
let g:sparkupNextMapping = '<c-j>'


" snipmate.vim
let g:snippets_dir = $HOME.'/.vim/snippets'


" syntastic
let g:syntastic_enable_signs=1
let g:syntastic_auto_loc_list=2


" taglist.vim
set tags=tags
nnoremap <Leader>T :<C-u>Tlist<CR>


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

" neobundle.vim {{{
set nocompatible
filetype indent off

if has("win32") || has("win64")
  set rtp+=C:/repos/dotfiles/.vim/bundle/neobundle.vim/
  call neobundle#rc('C:/repos/dotfiles/.vim/bundle/')
else
    set rtp+=~/.vim/bundle/neobundle.vim/
    "call neobundle#rc()
	call neobundle#rc(expand('~/.vim/bundle/'))
endif

NeoBundle 'http://github.com/chrismetcalf/vim-yankring'
NeoBundle 'http://github.com/fuenor/qfixhowm'
NeoBundle 'http://github.com/koron/chalice'
NeoBundle 'http://github.com/msanders/snipmate.vim'
" NeoBundle 'http://github.com/rstacruz/sparkup', {'rtp': 'vim/'}
NeoBundle 'http://github.com/Shougo/neobundle.vim'
NeoBundle 'http://github.com/Shougo/neocomplcache'
NeoBundle 'http://github.com/Shougo/unite.vim'
NeoBundle 'http://github.com/Shougo/vimproc'
NeoBundle 'http://github.com/Shougo/vimshell'
NeoBundle 'http://github.com/scrooloose/nerdtree'
NeoBundle 'http://github.com/sjl/gundo.vim'
" NeoBundle 'http://github.com/shemerey/vim-project'
" NeoBundle 'http://github.com/scrooloose/syntastic'
NeoBundle 'http://github.com/thinca/vim-guicolorscheme'
" NeoBundle 'http://github.com/thinca/vim-quickrun'
NeoBundle 'http://github.com/thinca/vim-ref'
NeoBundle 'http://github.com/tpope/vim-fugitive'
NeoBundle 'http://github.com/tpope/vim-surround'
NeoBundle 'http://github.com/tsaleh/vim-align'
NeoBundle 'http://github.com/tsaleh/vim-matchit'

NeoBundle 'http://github.com/vim-scripts/DBGp-client', {'rtp': 'vim/'}
NeoBundle 'http://github.com/vim-scripts/DoxygenToolkit.vim'
NeoBundle 'http://github.com/vim-scripts/L9.git'
NeoBundle 'http://github.com/vim-scripts/SQLUtilities'
NeoBundle 'http://github.com/vim-scripts/PHP-dictionary.git'
NeoBundle 'http://github.com/vim-scripts/TwitVim'
NeoBundle 'http://github.com/vim-scripts/cecutil'
NeoBundle 'http://github.com/vim-scripts/eregex.vim'
NeoBundle 'http://github.com/vim-scripts/genutils'
NeoBundle 'http://github.com/vim-scripts/grep.vim'
NeoBundle 'http://github.com/vim-scripts/multvals.vim'
NeoBundle 'http://github.com/vim-scripts/php.vim'
NeoBundle 'http://github.com/vim-scripts/phpfolding.vim'
NeoBundle 'http://github.com/vim-scripts/php.vim--Hodge'
NeoBundle 'http://github.com/vim-scripts/renamer.vim'
NeoBundle 'http://github.com/vim-scripts/sudo.vim'
NeoBundle 'http://github.com/vim-scripts/tComment'
NeoBundle 'http://github.com/vim-scripts/taglist.vim'
NeoBundle 'http://github.com/vim-scripts/vcscommand.vim'
NeoBundle 'http://github.com/vim-scripts/molokai'
NeoBundle 'http://github.com/vim-scripts/jellybeans.vim'
NeoBundle 'http://github.com/kakkyz81/evervim'

filetype plugin indent on
"}}}


" yankring.vim
nnoremap <Leader>y :<C-u>YRShow<CR>


" Rename Command
command! -nargs=1 -complete=file Rename f <args>|call delete(expand('#'))


let VIMRC_MINE = expand('~/.vimrc.mine')
if( filereadable(VIMRC_MINE) )
    exe "source " . VIMRC_MINE
endif

