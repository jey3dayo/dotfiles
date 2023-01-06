set encoding=utf-8
scriptencoding utf-8

syntax enable
let g:mapleader = ','
set fileencodings=utf-8
set fileformats=unix,mac,dos
set isfname+=32
set cindent
set virtualedit+=block
set display=lastline
set pumheight=15

" color
if &term =~? '^\(xterm\|screen\)$' && $COLORTERM ==? 'gnome-terminal'
  set t_Co=256
endif
highlight Search ctermbg=7
if has('nvim')
  set termguicolors
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

" set options
set autoindent
set smartindent
set backspace=2
set helplang=ja
set modelines=0
set nrformats-=octal
set nolazyredraw
set number
set ruler
set showmatch
set matchtime=1
set complete+=k
set cursorcolumn
set wildmenu
set foldmethod=marker
set noscrollbind
set laststatus=2
set statusline=%F%m%r%h%w\%=\[%{&ff}]\[%{&fileencoding}]\[%l/%L][%3P]
set lazyredraw
set ttyfast

" fixed neovim
set ttimeout
set ttimeoutlen=50

" search setting
set hlsearch
set ignorecase
set incsearch
set smartcase

if has('nvim')
  set inccommand=split
endif

" tab width
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set textwidth=0

" map
nnoremap <Leader>gr :<C-u>vimgrep // %<Bar>cw<LEFT><LEFT><LEFT><LEFT><LEFT><LEFT>
nnoremap <Leader>gR :<C-u>vimgrep // **/*.*<Bar>cw<LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT>
nnoremap <Leader>gx :<C-u>vimgrep /\(TODO\<Bar>XXX\<Bar>FIXME\)/ %<Bar>cw<CR>
nnoremap <Leader>gX :<C-u>vimgrep /\(TODO\<Bar>XXX\<Bar>FIXME\)/ **/*.*<Bar>cw<CR>
nnoremap <C-d> :<C-u>bd<CR>
nnoremap <Tab> :<C-u>wincmd w<CR>

" backup
set backup
set swapfile
set backupdir=~/.cache/vim
set directory=~/.cache/vim
set undodir=~/.cache/vim
set backupskip=/tmp/*,/private/tmp/*,~/.cache/vim

augroup swapchoice-readonly
  autocmd!
  autocmd SwapExists * let v:swapchoice = 'o'
augroup END

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

augroup QfAutoCommands
  autocmd!

" Auto-close quickfix window
  autocmd WinEnter * if (winnr('$') == 1) && (getbufvar(winbufnr(0), '&buftype')) == 'quickfix' | quit | endif
augroup END

" ESC ESC -> toggle hlsearch
nnoremap <Esc><Esc> :<C-u>set hlsearch!<Return>

set shellslash
set hidden
set shortmess+=I

" paste from clipboard {{{
if &term =~? 'xterm'
  let &t_SI .= "\e[?2004h"
  let &t_EI .= "\e[?2004l"
  let &pastetoggle = "\e[201~"

  function! XTermPasteBegin(ret) abort
    set paste
    return a:ret
  endfunction

  inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")
endif
" }}}



let g:denops#deno='/Users/t00114/.deno/bin/deno'
let g:python_host_prog='/Users/t00114/.pyenv/versions/py2/bin/python'
let g:python3_host_prog='/Users/t00114/.pyenv/versions/py3/bin/python'
let g:node_host_prog='~/.local/share/yarn/global/node_modules/.bin/neovim-node-host'
let g:ruby_host_prog='/Users/t00114/.rbenv/shims/neovim-ruby-host'

let g:cache_home = empty($XDG_CACHE_HOME) ? expand('$HOME/.cache') : $XDG_CACHE_HOME
let g:config_home = empty($XDG_CONFIG_HOME) ? expand('$HOME/.config') : $XDG_CONFIG_HOME
let s:dein_cache_dir = g:cache_home . '/dein'
let s:dein_repo_dir = s:dein_cache_dir . '/repos/github.com/Shougo/dein.vim'

" dein.vim {{{
augroup MyAutoCmd
  autocmd!
augroup END

if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    call system('git clone https://github.com/Shougo/dein.vim ' . shellescape(s:dein_repo_dir))
  endif
  execute 'set runtimepath^=' . s:dein_repo_dir
endif

" dein.vim settings
let g:dein#install_max_processes = 16
let g:dein#install_progress_type = 'title'
let g:dein#install_message_type = 'none'
let g:dein#enable_notification = 1

if dein#load_state(s:dein_cache_dir)
  call dein#begin(s:dein_cache_dir)
  let s:toml_dir = g:config_home . '/nvim/dein'
  call dein#load_toml(s:toml_dir . '/plugins.toml', {'lazy': 0})
  call dein#load_toml(s:toml_dir . '/style.toml', {'lazy': 0})
  call dein#load_toml(s:toml_dir . '/colorscheme.toml', {'lazy': 0})
  call dein#load_toml(s:toml_dir . '/ddc.toml', {'lazy': 0})
  call dein#load_toml(s:toml_dir . '/nvim-lsp.toml', {'lazy': 0})
  call dein#load_toml(s:toml_dir . '/lang.toml', {'lazy': 0})
  call dein#load_toml(s:toml_dir . '/lazy.toml', {'lazy': 1})
  call dein#end()
  call dein#save_state()
en

if has('vim_starting') && dein#check_install()
  call dein#install()
endif

nnoremap [core] <Nop>
nmap <Leader>s [core]
nnoremap [core]o :<C-u>source ~/.vimrc<CR>
nnoremap [core]r :<C-u>call dein#recache_runtimepath()<CR>
nnoremap [core]u :<C-u>call dein#update()<CR>

" }}}

filetype on
filetype plugin indent on

runtime! rc/*.vim

" vim: set ft=vim :
