" Define mappings
autocmd FileType denite call s:denite_my_settings()
function! s:denite_my_settings() abort
  nnoremap <silent><buffer><expr> <CR>
        \ denite#do_map('do_action')
  nnoremap <silent><buffer><expr> e
        \ denite#do_map('do_action')
  nnoremap <silent><buffer><expr> d
        \ denite#do_map('do_action', 'delete')
  nnoremap <silent><buffer><expr> p
        \ denite#do_map('do_action', 'preview')
  nnoremap <silent><buffer><expr> <ESC>
        \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> q
        \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> i
        \ denite#do_map('open_filter_buffer')
  nnoremap <silent><buffer><expr> <Space>
        \ denite#do_map('toggle_select').'j'
endfunction

nnoremap [denite] <Nop>
nmap <C-u> [denite]

nnoremap <Leader>b :Denite buffer<CR>
nnoremap <Leader>f :Denite file/rec<CR>
nnoremap <Leader>m :Denite file/old<CR>
nnoremap <Leader>y :Denite neoyank<CR>

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
    let l:path = expand('%:p:h')
    if has_key(defx#get_candidate(), 'action__path')
      let l:path = fnamemodify(defx#get_candidate()['action__path'], ':p:h')
    endif
    execute(':Denite -buffer-name=grep-buffer-denite -no-empty '.join(s:denite_option_array, ' ').' grep -path='.l:path)
  endif
endfunction


" grepした結果を再表示し、次/前へ
nnoremap <silent> <Leader>g :<C-u>Denite grep -buffer-name=search-buffer-denite<CR>
nnoremap <silent> <Leader>G :<C-u>Denite -resume -buffer-name=search-buffer-denite<CR>
nnoremap <silent> <Leader>n :<C-u>Denite -resume -buffer-name=search-buffer-denite -select=+1 -immediately<CR>
nnoremap <silent> <Leader>p :<C-u>Denite -resume -buffer-name=search-buffer-denite -select=-1 -immediately<CR>

let s:ignore_globs = ['.git', '.svn', 'node_modules', '.cache']
call denite#custom#var('file/rec', 'command', [
    \ 'ag',
    \ '--follow',
    \ ] + map(deepcopy(s:ignore_globs), { k, v -> '--ignore=' . v }) + [
    \ '--nocolor',
    \ '--nogroup',
    \ '-g',
    \ ''
    \ ])
call denite#custom#source('file/rec', 'matchers', ['matcher/substring'])
call denite#custom#filter('matcher/ignore_globs', 'ignore_globs', s:ignore_globs)

