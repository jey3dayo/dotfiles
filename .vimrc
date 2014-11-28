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
augroup highlightIdegraphicSpace
  au!
  au Colorscheme * highlight IdeographicSpace term=underline ctermbg=DarkGreen guibg=DarkGreen
  au VimEnter,ColorScheme * highlight IdeographicSpace term=underline ctermbg=DarkGreen guibg=DarkGreen
  au VimEnter,WinEnter * match IdeographicSpace /　/
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
set cursorcolumn
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
set undodir=~/tmp


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


" vim-coffee-script
au BufRead,BufNewFile,BufReadPre *.coffee set filetype=coffee
au FileType coffee     setlocal sw=2 sts=2 ts=2 et
au BufWritePost *.coffee silent make!
au QuickFixCmdPost * nested cwindow | redraw!


" indent_guides
au VimEnter,Colorscheme * :hi IndentGuidesOdd guibg=red ctermbg=3
au VimEnter,Colorscheme * :hi IndentGuidesEven guibg=green ctermbg=4
au FileType coffee,ruby,javascript,python IndentGuidesEnable
nmap <silent><Leader>ig <Plug>IndentGuidesToggle

let g:indent_guides_auto_colors=0
let g:indent_guides_start_level=2
let g:indent_guides_guide_size=1
let g:indent_guides_enable_on_vim_startup=0
let g:indent_guides_color_change_percent=20


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


" increment-activator.vim
let g:increment_activator_filetype_candidates = {
  \   '_' : [
  \     ['info', 'warning', 'notice', 'error', 'success'],
  \     ['mini', 'small', 'medium', 'large', 'xlarge', 'xxlarge'],
  \     ['static', 'absolute', 'relative', 'fixed', 'sticky'],
  \     ['height', 'width'],
  \     ['right', 'left'],
  \   ],
  \   'ruby': [
  \     ['if', 'unless'],
  \     ['nil', 'empty', 'blank'],
  \     ['string', 'text', 'integer', 'float', 'datetime', 'timestamp', 'timestamp'],
  \   ],
  \   'git-rebase-todo': [
  \     ['pick', 'reword', 'edit', 'squash', 'fixup', 'exec'],
  \   ],
  \ }


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


"vim-ref
"Ref webdictでalcを使う設定
let g:ref_source_webdict_cmd = 'lynx -dump -nonumbers %s'
"let g:ref_source_webdict_use_cache = 1
let g:ref_source_webdict_sites = {
            \ 'alc' : {
            \   'url' : 'http://eow.alc.co.jp/%s/UTF-8/'
            \   }
            \ }
function! g:ref_source_webdict_sites.alc.filter(output)
      return join(split(a:output, "\n")[42 :], "\n")
endfunction

noremap <Leader>D :<C-u>Ref webdict alc<Space>


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


" unite-grep
let g:unite_enable_start_insert = 1
let g:unite_enable_ignore_case = 1
let g:unite_enable_smart_case = 1
nnoremap <silent> <Leader>h :<C-u>Unite grep:. -buffer-name=search-buffer<CR>

if executable('ag')
	let g:unite_source_grep_command = 'ag'
	let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
	let g:unite_source_grep_recursive_opt = ''
	let g:unite_source_grep_max_candidates = 400
endif


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


" syntastic.vim
let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': ['ruby', 'php', 'sass', 'haml'] }
let g:syntastic_ruby_checkers = ['rubocop']
let g:syntastic_php_checkers = ['php', 'phpcs', 'phpmd']
let g:syntastic_haml_checkers = ['haml_lint']
let g:syntastic_sass_checkers = ['sass']


" tagbar.vim
nnoremap <Leader>T :<C-u>TagbarToggle<CR>


" neobundle.vim {{{
set nocompatible
filetype indent off

if has("win32") || has("win64")
  set rtp+=C:/repos/dotfiles/.vim/bundle/neobundle.vim/
  call neobundle#rc('~/Documents/GitHub/dotfiles/.vim/bundle/')
else
  set rtp+=~/.vim/bundle/neobundle.vim/
  call neobundle#begin(expand('~/.vim/bundle/'))
endif

NeoBundleFetch 'Shougo/neobundle.vim'
NeoBundle 'ekalinin/Dockerfile.vim'
NeoBundle 'Shougo/neobundle.vim'
NeoBundle 'Shougo/neocomplcache'
NeoBundle 'Shougo/neosnippet'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'Shougo/neomru.vim'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/vimproc.vim', {
\ 'build' : {
\     'windows' : 'tools\\update-dll-mingw',
\     'cygwin' : 'make -f make_cygwin.mak',
\     'mac' : 'make -f make_mac.mak',
\     'linux' : 'make',
\     'unix' : 'gmake',
\    },
\ }
NeoBundle 'mileszs/ack.vim'
NeoBundle 'majutsushi/tagbar'
NeoBundle 'nishigori/increment-activator'
NeoBundle 'ap/vim-css-color'
NeoBundle 'airblade/vim-rooter'
NeoBundle 'jiangmiao/simple-javascript-indenter'
NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'scrooloose/syntastic'
NeoBundle "pangloss/vim-javascript"
NeoBundle 'terryma/vim-multiple-cursors'
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'thinca/vim-ref'
NeoBundle 'tomtom/tcomment_vim.git'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-rails'
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
NeoBundle 'derekwyatt/vim-scala'
NeoBundle 'mattn/emmet-vim.git'
NeoBundle 'groenewege/vim-less'
NeoBundle 'tpope/vim-haml'
NeoBundle 'nathanaelkane/vim-indent-guides'

call neobundle#end()

filetype plugin indent on
" }}}


" Rename Command
command! -nargs=1 -complete=file Rename f <args>|call delete(expand('#'))


let VIMRC_MINE = expand('~/.vimrc.mine')
if( filereadable(VIMRC_MINE) )
  exe "source " . VIMRC_MINE
endif

