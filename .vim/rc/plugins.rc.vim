" alingta
vnoremap <silent> => :Align @1 =><CR>
vnoremap <silent> == :Align @1 =<CR>

" indent_guides {{{
au VimEnter,Colorscheme * :hi IndentGuidesOdd guibg=red ctermbg=3
au VimEnter,Colorscheme * :hi IndentGuidesEven guibg=green ctermbg=4
au FileType coffee,ruby,javascript,python IndentGuidesEnable
nmap <silent><Leader>sg <Plug>IndentGuidesToggle

let g:indent_guides_auto_colors=0
let g:indent_guides_start_level=2
let g:indent_guides_guide_size=1
let g:indent_guides_enable_on_vim_startup=0
let g:indent_guides_color_change_percent=20
"}}}

" fugitive.vim {{{
nnoremap [fugitive] <Nop>
nmap <Leader>g [fugitive]
nnoremap [fugitive]b :<C-u>Gblame<CR>
nnoremap [fugitive]d :<C-u>Gdiff<CR>
nnoremap [fugitive]g :<C-u>Ggrep<Space>
nnoremap [fugitive]s :<C-u>Gstatus<CR>
nnoremap [fugitive]w :<C-u>Gwrite<CR>
nnoremap [fugitive]c :<C-u>Gcommit<CR>
"}}}

" neocomplete.vim {{{
let g:acp_enableAtStartup = 1
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#enable_camel_case_completion = 1
let g:neocomplete#enable_underbar_completion = 1
let g:neocomplete#min_syntax_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplete#dictionary_filetype_lists = {
  \ 'default' : '',
\ }

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
  let g:neocomplete#keyword_patterns = {}
endif
  let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" neco-look setting
if !exists('g:neocomplete#text_mode_filetypes')
  let g:neocomplete#text_mode_filetypes = {}
endif
  let g:neocomplete#text_mode_filetypes = {
              \ 'rst': 1,
              \ 'markdown': 1,
              \ 'gitrebase': 1,
              \ 'gitcommit': 1,
              \ 'vcs-commit': 1,
              \ 'hybrid': 1,
              \ 'text': 1,
              \ 'help': 1,
              \ 'tex': 1,
              \ }

" increment-activator.vim
let g:increment_activator_filetype_candidates = {
  \ '_' : [
    \ ['info', 'warning', 'notice', 'error', 'success'],
    \ ['mini', 'small', 'medium', 'large', 'xlarge', 'xxlarge'],
    \ ['static', 'absolute', 'relative', 'fixed', 'sticky'],
    \ ['height', 'width'],
    \ ['right', 'left'],
  \ ],
  \ 'ruby': [
    \ ['if', 'unless'],
    \ ['nil', 'empty', 'blank'],
    \ ['string', 'text', 'integer', 'float', 'datetime', 'timestamp', 'timestamp'],
  \ ],
  \ 'git-rebase-todo': [
    \ ['pick', 'reword', 'edit', 'squash', 'fixup', 'exec'],
  \ ],
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

" Powerline.vim {{{
python from powerline.vim import setup as powerline_setup
python powerline_setup()
python del powerline_setup
set laststatus=2
set showtabline=2
set noshowmode
" }}}

"ref.vim {{{
"Ref webdictでalcを使う設定
let g:ref_source_webdict_cmd = 'lynx -dump -nonumbers %s'
"let g:ref_source_webdict_use_cache = 1
let g:ref_source_webdict_sites = {
  \ 'alc' : {
    \ 'url' : 'http://eow.alc.co.jp/%s/UTF-8/'
  \ }
\ }
function! g:ref_source_webdict_sites.alc.filter(output)
  return join(split(a:output, "\n")[42 :], "\n")
endfunction

noremap <Leader>D :<C-u>Ref webdict alc<Space>
"}}}

" simple-javascript-indenter
let g:SimpleJsIndenter_BriefMode = 1


" unite.vim {{{
let g:unite_enable_start_insert=1
noremap <Leader>b :Unite buffer<CR>
noremap <Leader>f :Unite file<CR>
noremap <Leader>m :Unite file_mru<CR>
noremap <Leader>y :Unite history/yank<CR>
noremap <Leader>r :UniteResume<CR>
noremap <Leader>G :Unite grep:%<CR>
noremap <Leader>d :UniteWithBufferDir file<CR>

noremap <Leader>B :<C-u>tabnew<CR>:tabmove<CR>:Unite buffer<CR>
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

" unite-outline
noremap <Leader>o <ESC>:Unite outline<Return>

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
    \ 'left': [
      \ [ 'mode', 'paste' ],
      \ [ 'fugitive', 'readonly', 'filename', 'modified' ]
    \ ]
  \ },
  \ 'component': {
    \ 'readonly': '%{&filetype=="help"?"":&readonly?"⭤":""}',
    \ 'modified': '%{&filetype=="help"?"":&modified?"+":&modifiable?"":"-"}',
    \ 'fugitive': '%{exists("*fugitive#head")?fugitive#head():""}'
  \ },
  \ 'component_visible_condition': {
    \ 'readonly': '(&filetype!="help"&& &readonly)',
    \ 'modified': '(&filetype!="help"&&(&modified||!&modifiable))',
    \ 'fugitive': '(exists("*fugitive#head") && ""!=fugitive#head())'
  \ },
  \ 'separator': { 'left': '⮀', 'right': '⮂' },
  \ 'subseparator': { 'left': '⮁', 'right': '⮃' }
\ }

" syntastic.vim
let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': ['ruby', 'php', 'sass', 'haml', 'sh', 'coffee'] }
let g:syntastic_ruby_checkers = ['rubocop']
let g:syntastic_php_checkers = ['php', 'phpcs', 'phpmd']
let g:syntastic_haml_checkers = ['haml_lint']
let g:syntastic_sass_checkers = ['sass']
let g:syntastic_sh = ['shellcheck']
let g:syntastic_coffee_checkers = ['coffeelint']

" tagbar.vim
nnoremap <Leader>T :<C-u>TagbarToggle<CR>

" rainbow_parentheses
let g:rbpt_max = 16
let g:rbpt_loadcmd_toggle = 0
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces

" Rename Command
command! -nargs=1 -complete=file Rename f <args>|call delete(expand('#'))

