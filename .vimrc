" j138 .vimrc

if &cp | set nocp | endif
let s:cpo_save=&cpo
set cpo&vim
let &cpo=s:cpo_save
unlet s:cpo_save
let mapleader = ","

syntax enable
set encoding=utf-8
set fileencodings=utf-8,ucs-bom,iso-2022-jp-3,iso-2022-jp,eucjp-ms,euc-jisx0213,euc-jp,sjis,cp932
set fileformats=unix,mac,dos
set isfname+=32
set cindent
set virtualedit+=block
set display=lastline
set pumheight=15

" color
set t_Co=256
colorscheme desert
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
set matchtime=1
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
set undodir=~/tmp

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

" ESC ESC -> toggle hlsearch
nnoremap <Esc><Esc> :<C-u>set hlsearch!<Return>

set shellslash
set hidden
set shortmess+=I

" dein.vim {{{
function! s:source_rc(path, ...) abort "{{{
  let use_global = get(a:000, 0, !has('vim_starting'))
  let abspath = resolve(expand('~/.vim/rc/' . a:path))
  if !use_global
    execute 'source' fnameescape(abspath)
    return
  endif

  " substitute all 'set' to 'setglobal'
  let content = map(readfile(abspath),
        \ 'substitute(v:val, "^\\W*\\zsset\\ze\\W", "setglobal", "")')
  " create tempfile and source the tempfile
  let tempfile = tempname()
  try
    call writefile(content, tempfile)
    execute printf('source %s', fnameescape(tempfile))
  finally
    if filereadable(tempfile)
      call delete(tempfile)
    endif
  endtry
endfunction"}}}

augroup PluginInstall
  autocmd!
  autocmd VimEnter * if dein#check_install() | call dein#install() | endif
augroup END

let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

let s:toml      = '~/.vim/rc/dein.toml'
let s:lazy_toml = '~/.vim/rc/dein_lazy.toml'
let g:dein#install_max_processes = 16

if dein#load_state(s:toml, s:lazy_toml)
  call dein#begin(s:dein_dir)
  call s:source_rc('plugins.rc.vim')
  call dein#load_toml(s:toml,      {'lazy': 0})
  call dein#load_toml(s:lazy_toml, {'lazy': 1})
  call dein#end()
  call dein#save_state()
endif

if dein#check_install()
  call dein#install()
endif

nnoremap <Leader>sO :<C-u>call dein#update()<CR>
" }}}

let VIMRC_MINE = expand('~/.vimrc.mine')
if( filereadable(VIMRC_MINE) )
  exe "source " . VIMRC_MINE
endif

filetype on
filetype plugin on
filetype indent on

runtime! rc/*.vim
" vim: set ft=vim :
