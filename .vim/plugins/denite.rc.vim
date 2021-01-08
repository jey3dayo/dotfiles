augroup denite_filter
  autocmd FileType denite call s:denite_my_settings()
  function! s:denite_my_settings() abort
    nnoremap <silent><buffer><expr> <CR>
    \ denite#do_map('do_action')
    nnoremap <silent><buffer><expr> d
    \ denite#do_map('do_action', 'delete')
    nnoremap <silent><buffer><expr> p
    \ denite#do_map('do_action', 'preview')
    nnoremap <silent><buffer><expr> q
    \ denite#do_map('quit')
    nnoremap <silent><buffer><expr> <C-c>
    \ denite#do_map('quit')
    nnoremap <silent><buffer><expr> <C-d>
    \ denite#do_map('quit')
    nnoremap <silent><buffer><expr> i
    \ denite#do_map('open_filter_buffer')
    nnoremap <silent><buffer><expr> <Space>
    \ denite#do_map('toggle_select').'j'
    nnoremap <silent><buffer><expr> <BS>
    \ denite#do_map('move_up_path')
  endfunction
augroup END

" use floating
let s:denite_win_width_percent = 0.85
let s:denite_win_height_percent = 0.7
let s:denite_default_options = {
    \ 'split': 'floating',
    \ 'winwidth': float2nr(&columns * s:denite_win_width_percent),
    \ 'wincol': float2nr((&columns - (&columns * s:denite_win_width_percent)) / 2),
    \ 'winheight': float2nr(&lines * s:denite_win_height_percent),
    \ 'winrow': float2nr((&lines - (&lines * s:denite_win_height_percent)) / 2),
    \ 'highlight_filter_background': 'DeniteFilter',
    \ 'prompt': '$ ',
    \ 'start_filter': v:true,
    \ }
let s:denite_option_array = []
for [key, value] in items(s:denite_default_options)
  call add(s:denite_option_array, '-'.key.'='.value)
endfor
call denite#custom#option('default', s:denite_default_options)

call denite#custom#var('file/rec', 'command',
    \ ['ag', '--follow', '--nocolor', '--nogroup', '-g', ''])
call denite#custom#filter('matcher/ignore_globs', 'ignore_globs',
    \ [ '.git/', '.ropeproject/', '__pycache__/',
    \   'venv/', 'images/', '*.min.*', 'img/', 'fonts/'])

" Ag command on grep source
call denite#custom#var('grep', 'command', ['ag'])
call denite#custom#var('grep', 'default_opts', ['-i', '--vimgrep'])
call denite#custom#var('grep', 'recursive_opts', [])
call denite#custom#var('grep', 'pattern_opt', [])
call denite#custom#var('grep', 'separator', ['--'])
call denite#custom#var('grep', 'final_opts', [])

" grep
command! -nargs=? Dgrep call s:Dgrep(<f-args>)
function s:Dgrep(...)
  if a:0 > 0
    execute(':Denite -buffer-name=grep-buffer-denite grep -path='.a:1)
  else
    execute(':Denite -buffer-name=grep-buffer-denite '.join(s:denite_option_array, ' ').' grep')
  endif
endfunction
" show Denite grep results
command! Dresume execute(':Denite -resume -buffer-name=grep-buffer-denite '.join(s:denite_option_array, ' ').'')
" next Denite grep result
command! Dnext execute(':Denite -resume -buffer-name=grep-buffer-denite -cursor-pos=+1 -immediately '.join(s:denite_option_array, ' ').'')
" previous Denite grep result
command! Dprev execute(':Denite -resume -buffer-name=grep-buffer-denite -cursor-pos=-1 -immediately '.join(s:denite_option_array, ' ').'')

" keymap
call denite#custom#map('insert', '<C-n>', '<denite:move_to_next_line>', 'noremap')
call denite#custom#map('insert', '<C-p>', '<denite:move_to_previous_line>', 'noremap')

nnoremap [denite] <Nop>
nmap <C-u> [denite]

nnoremap <Leader>b :Denite buffer<CR>
nnoremap <Leader>f :Denite file/rec<CR>
nnoremap <Leader>m :Denite file/old<CR>
nnoremap <Leader>y :Denite neoyank<CR>
