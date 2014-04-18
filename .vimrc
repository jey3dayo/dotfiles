" j138 .vimrc

if &cp | set nocp | endif
let s:cpo_save=&cpo
set cpo&vim
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
set t_Co=256
colorscheme wombat
highlight Search ctermbg=7

" set list
nmap <Leader>sn :<C-u>set number!<CR>
nmap <Leader>sl :<C-u>set list!<CR>


" visible SpecialKey
set list
set listchars=tab:>.,trail:-,extends:\


" visible fullsize space
scriptencoding utf-8
augroup highlightIdegraphicSpace
  autocmd!
  autocmd Colorscheme * highlight IdeographicSpace term=underline ctermbg=DarkGreen guibg=DarkGreen
  autocmd VimEnter,WinEnter * match IdeographicSpace /　/
augroup END

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


filetype on
filetype plugin on
filetype indent on


" map
nnoremap <Leader>s <Nop>
nnoremap <Leader>so :<C-u>source ~/.vimrc<CR>
nnoremap <Leader>gr :<C-u>vimgrep // %<Bar>cw<LEFT><LEFT><LEFT><LEFT><LEFT><LEFT>
nnoremap <Leader>gR :<C-u>vimgrep // **/*.*<Bar>cw<LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT>
nnoremap <Leader>gx :<C-u>vimgrep /\(TODO\<Bar>XXX\<Bar>FIXME\)/ %<Bar>cw<CR>
nnoremap <Leader>gX :<C-u>vimgrep /\(TODO\<Bar>XXX\<Bar>FIXME\)/ **/*.*<Bar>cw<CR>

nnoremap <C-d> :<C-u>bd<CR>
nnoremap <Tab> :<C-u>wincmd w<CR>


"set encoding
nnoremap <Leader>si :<C-u>e! ++enc=iso-2022-jp<CR>
nnoremap <Leader>su :<C-u>e! ++enc=utf-8<CR>
nnoremap <Leader>ss :<C-u>e! ++enc=sjis<CR>
nnoremap <Leader>se :<C-u>e! ++enc=euc-jp<CR>


" backup
set backup
set swapfile
set backupdir=~/tmp
set directory=~/tmp
set viminfo+=n~/tmp


" link jump
nnoremap t <Nop>
nnoremap tt <C-]>
nnoremap tj :<C-u>tag<CR>
nnoremap tk :<C-u>pop<CR>


" tab
nnoremap <C-t> <Nop>
nnoremap <C-t>c :<C-u>tabnew<CR>
nnoremap <C-t>d :<C-u>tabclose<CR>
nnoremap <C-t>o :<C-u>tabonly<CR>
nnoremap <C-t>n :<C-u>tabnext<CR>
nnoremap <C-t>p :<C-u>tabprevious<CR>
nnoremap gt :<C-u>tabnext<CR>
nnoremap gT :<C-u>tabprevious<CR>


" ESC ESC -> toggle hlsearch
nnoremap <Esc><Esc> :<C-u>set hlsearch!<Return>

set shellslash
set hidden
set shortmess+=I

" for alingta
vnoremap <silent> => :Align @1 =><CR>
vnoremap <silent> == :Align @1 =<CR>

" fugitive.vim
" The prefix key.
nnoremap [fugitive]   <Nop>
nmap <Leader>g [fugitive]

" keymap
nnoremap [fugitive]b :<C-u>Gblame<CR>
nnoremap [fugitive]d :<C-u>Gdiff<CR>
nnoremap [fugitive]g :<C-u>Ggrep<Space>
nnoremap [fugitive]s :<C-u>Gstatus<CR>
nnoremap [fugitive]w :<C-u>Gwrite<CR>
nnoremap [fugitive]c :<C-u>Gcommit<CR>


" neocomplcache.vim {{{
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 1
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Use camel case completion.
let g:neocomplcache_enable_camel_case_completion = 1
" Use underbar completion.
let g:neocomplcache_enable_underbar_completion = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
  \ 'default' : '',
  \ 'php' : $HOME . '/.vim/bundle/PHP-dictionary/PHP.dict',
  \ 'thtml' : $HOME . '/.vim/bundle/PHP-dictionary/PHP.dict',
  \ }


" Define keyword.
if !exists('g:neocomplcache_keyword_patterns')
  let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'
" }}}


" neosnippet.vim {{{
" " snippets dir
let g:neosnippet#enable_snipmate_compatibility = 1

if !exists("g:neosnippet#snippets_directory")
  let g:neosnippet#snippets_directory="."
endif

" plugin key-mappings.
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)

" SuperTab like snippets behavior.
imap <expr><TAB> neosnippet#expandable() <Bar><bar> neosnippet#jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable() <Bar><bar> neosnippet#jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" For snippet_complete marker.
if has('conceal')
  set conceallevel=2 concealcursor=i
endif
" }}}


" ref.vim
let g:ref_phpmanual_path = $HOME . '/.vim/dict/php-chunked-xhtml'
let g:ref_jquery_path = $HOME . '/.vim/dict/jqapi-latest/docs'
noremap <Leader>d :<C-u>Ref alc<Space>


" simple-javascript-indenter
let g:SimpleJsIndenter_BriefMode = 1


" unite.vim {{{
" The prefix key.

let g:unite_enable_start_insert=1
let g:unite_source_history_yank_enable =1
noremap <Leader>b :Unite buffer<CR>
noremap <Leader>f :Unite file<CR>
noremap <Leader>m :Unite file_mru<CR>
noremap <Leader>y :Unite history/yank<CR>
noremap <Leader>r :UniteResume<CR>
noremap <Leader>G :Unite grep:%<CR>
noremap <Leader>d :UniteWithBufferDir file<CR>
noremap <Leader>U :Unite neobundle/update<CR>

noremap <Leader>B :<C-u>tabnew<CR>:tabmove<CR>:Unite buffer<CR>
noremap <Leader>F :<C-u>tabnew<CR>:tabmove<CR>:Unite file<CR>
noremap <Leader>M :<C-u>tabnew<CR>:tabmove<CR>:Unite file_mru<CR>

au FileType unite nnoremap <silent> <buffer> <ESC><ESC> :q<CR>
au FileType unite inoremap <silent> <buffer> <ESC><ESC> <ESC>:q<CR>

au FileType unite nnoremap <silent> <buffer> <expr> <C-J> unite#do_action('split')
au FileType unite inoremap <silent> <buffer> <expr> <C-K> unite#do_action('vsplit')

" " unite-grep
" " unite-grepのバックエンドをagに切り替える
" " http://qiita.com/items/c8962f9325a5433dc50d
let g:unite_source_grep_command = 'ag'
let g:unite_source_grep_default_opts = '--nocolor --nogroup'
let g:unite_source_grep_recursive_opt = ''
let g:unite_source_grep_max_candidates = 200

" unite-grepのキーマップ
" 選択した文字列をunite-grep
" https://github.com/shingokatsushima/dotfiles/blob/master/.vimrc
" vnoremap /g y:Unite grep::-iHRn:<C-R>=escape(@", '\\.*$^[]')<CR><CR>
vnoremap /g y:Unite grep::-iRn:<C-R>=escape(@", '\\.*$^[]')<CR><CR>

" }}}


" lightline.vim
let g:lightline = {
  \ 'colorscheme': 'jellybeans',
  \ 'active': {
  \   'left': [ [ 'mode', 'paste' ],
  \             [ 'fugitive', 'readonly', 'filename', 'modified' ] ]
  \ },
  \ 'component': {
  \   'readonly': '%{&filetype=="help"?"":&readonly?"⭤":""}',
  \   'modified': '%{&filetype=="help"?"":&modified?"+":&modifiable?"":"-"}',
  \   'fugitive': '%{exists("*fugitive#head")?fugitive#head():""}'
  \ },
  \ 'component_visible_condition': {
  \   'readonly': '(&filetype!="help"&& &readonly)',
  \   'modified': '(&filetype!="help"&&(&modified||!&modifiable))',
  \   'fugitive': '(exists("*fugitive#head") && ""!=fugitive#head())'
  \ },
  \ 'separator': { 'left': '⮀', 'right': '⮂' },
  \ 'subseparator': { 'left': '⮁', 'right': '⮃' }
  \ }


" vimfiler.vim
let g:vimfiler_as_default_explorer = 1
nnoremap <Leader>e  :<C-u>VimFilerSplit<CR>


" neobundle.vim {{{
set nocompatible
filetype indent off

" syntastic.vim
let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': ['ruby'] }
let g:syntastic_ruby_checkers = ['rubocop']


if has("win32") || has("win64")
  set rtp+=C:/repos/dotfiles/.vim/bundle/neobundle.vim/
  call neobundle#rc('~/Documents/GitHub/dotfiles/.vim/bundle/')
else
  set rtp+=~/.vim/bundle/neobundle.vim/
  call neobundle#rc(expand('~/.vim/bundle/'))
endif

NeoBundle 'Shougo/neobundle.vim'
NeoBundle 'Shougo/neocomplcache'
NeoBundle 'Shougo/neosnippet'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'Shougo/neomru.vim'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/vimfiler'
NeoBundle 'Shougo/vimproc'
NeoBundle 'mileszs/ack.vim'
NeoBundle 'nishigori/increment-activator'
NeoBundle 'ap/vim-css-color'
NeoBundle 'airblade/vim-rooter'
NeoBundle 'jiangmiao/simple-javascript-indenter'
NeoBundle 'scrooloose/syntastic'
NeoBundle "pangloss/vim-javascript"
NeoBundle 'tomtom/tcomment_vim.git'
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'thinca/vim-ref'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-surround'
NeoBundle 'h1mesuke/vim-alignta.git'
NeoBundle 'vim-scripts/DoxygenToolkit.vim'
NeoBundle 'vim-scripts/PHP-dictionary.git'
NeoBundle 'vim-scripts/Markdown'
NeoBundle 'vim-scripts/php.vim'
NeoBundle 'vim-scripts/renamer.vim'
NeoBundle 'vim-scripts/sudo.vim'
NeoBundle 'vim-scripts/molokai'
NeoBundle 'vim-scripts/jellybeans.vim'
NeoBundle 'violetyk/cake.vim'
NeoBundle 'itchyny/lightline.vim'
filetype plugin indent on
" }}}


" Rename Command
command! -nargs=1 -complete=file Rename f <args>|call delete(expand('#'))


let VIMRC_MINE = expand('~/.vimrc.mine')
if( filereadable(VIMRC_MINE) )
  exe "source " . VIMRC_MINE
endif

