" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
autoload/neocomplcache/cache.vim	[[[1
403
"=============================================================================
" FILE: cache.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 01 Sep 2010
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditionneocomplcache#cache#
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

" Cache loader.
function! neocomplcache#cache#load_from_cache(cache_dir, filename)"{{{
  if neocomplcache#cache#check_old_cache(a:cache_dir, a:filename)
    return []
  endif

  let l:keyword_lists = []
  let l:lines = readfile(neocomplcache#cache#encode_name(a:cache_dir, a:filename))
  let l:max_lines = len(l:lines)

  if empty(l:lines)
    return []
  endif

  if l:max_lines > 3000
    call neocomplcache#print_caching('Caching from cache "' . a:filename . '"... please wait.')
  endif
  if l:max_lines > 10000
    let l:print_cache_percent = l:max_lines / 5
  elseif l:max_lines > 5000
    let l:print_cache_percent = l:max_lines / 4
  elseif l:max_lines > 3000
    let l:print_cache_percent = l:max_lines / 3
  else
    let l:print_cache_percent = -1
  endif
  let l:line_cnt = l:print_cache_percent

  try
    let l:line_num = 1
    for l:line in l:lines"{{{
      " Percentage check."{{{
      if l:print_cache_percent > 0
        if l:line_cnt == 0
          call neocomplcache#print_caching(printf('Caching(%s): %d%%', a:filename, l:line_num*100 / l:max_lines))
          let l:line_cnt = l:print_cache_percent
        endif
        let l:line_cnt -= 1
        
        let l:line_num += 1
      endif
      "}}}

      let l:cache = split(l:line, '|||', 1)
      let l:keyword = {
            \ 'word' : l:cache[0], 'abbr' : l:cache[1], 'menu' : l:cache[2],
            \}
      if l:cache[3] != ''
        let l:keyword.kind = l:cache[3]
      endif
      if l:cache[4] != ''
        let l:keyword.class = l:cache[4]
      endif

      call add(l:keyword_lists, l:keyword)
    endfor"}}}
  catch /E684:/
    call neocomplcache#print_error(v:exception)
    call neocomplcache#print_error('Error occured while analyzing cache!')
    let l:cache_dir = g:neocomplcache_temporary_dir . '/' . a:cache_dir
    call neocomplcache#print_error('Please delete cache directory: ' . l:cache_dir)
    return []
  endtry

  if l:max_lines > 3000
    call neocomplcache#print_caching('')
  endif

  return l:keyword_lists
endfunction"}}}
function! neocomplcache#cache#index_load_from_cache(cache_dir, filename, completion_length)"{{{
  let l:keyword_lists = {}

  for l:keyword in neocomplcache#cache#load_from_cache(a:cache_dir, a:filename)
    let l:key = tolower(l:keyword.word[: a:completion_length-1])
    if !has_key(l:keyword_lists, l:key)
      let l:keyword_lists[l:key] = []
    endif
    call add(l:keyword_lists[l:key], l:keyword)
  endfor 

  return l:keyword_lists
endfunction"}}}
function! neocomplcache#cache#load_from_file(filename, pattern, mark)"{{{
  if bufloaded(a:filename)
    let l:lines = getbufline(bufnr(a:filename), 1, '$')
  elseif filereadable(a:filename)
    let l:lines = readfile(a:filename)
  else
    " File not found.
    return []
  endif
  
  let l:max_lines = len(l:lines)
  let l:menu = printf('[%s] %.' . g:neocomplcache_max_filename_width . 's', a:mark, fnamemodify(a:filename, ':t'))

  if l:max_lines > 1000
    call neocomplcache#print_caching('Caching from file "' . a:filename . '"... please wait.')
  endif
  if l:max_lines > 10000
    let l:print_cache_percent = l:max_lines / 9
  elseif l:max_lines > 7000
    let l:print_cache_percent = l:max_lines / 6
  elseif l:max_lines > 5000
    let l:print_cache_percent = l:max_lines / 5
  elseif l:max_lines > 3000
    let l:print_cache_percent = l:max_lines / 4
  elseif l:max_lines > 2000
    let l:print_cache_percent = l:max_lines / 3
  elseif l:max_lines > 1000
    let l:print_cache_percent = l:max_lines / 2
  else
    return s:load_from_file_fast(l:lines, a:pattern, l:menu)
  endif
  let l:line_cnt = l:print_cache_percent

  let l:line_num = 1
  let l:keyword_lists = []
  let l:dup_check = {}
  let l:keyword_pattern2 = '^\%('.a:pattern.'\m\)'

  for l:line in l:lines"{{{
    " Percentage check."{{{
    if l:print_cache_percent > 0
      if l:line_cnt == 0
        call neocomplcache#print_caching(printf('Caching(%s): %d%%', a:filename, l:line_num*100 / l:max_lines))
        let l:line_cnt = l:print_cache_percent
      endif
      let l:line_cnt -= 1

      let l:line_num += 1
    endif
    "}}}

    let l:match = match(l:line, a:pattern)
    while l:match >= 0"{{{
      let l:match_str = matchstr(l:line, l:keyword_pattern2, l:match)

      " Ignore too short keyword.
      if !has_key(l:dup_check, l:match_str) && len(l:match_str) >= g:neocomplcache_min_keyword_length
        " Append list.
        call add(l:keyword_lists, { 'word' : l:match_str, 'menu' : l:menu })

        let l:dup_check[l:match_str] = 1
      endif

      let l:match = match(l:line, a:pattern, l:match + len(l:match_str))
    endwhile"}}}
  endfor"}}}

  if l:max_lines > 1000
    call neocomplcache#print_caching('')
  endif

  return l:keyword_lists
endfunction"}}}
function! s:load_from_file_fast(lines, pattern, menu)"{{{
  let l:line_num = 1
  let l:keyword_lists = []
  let l:dup_check = {}
  let l:keyword_pattern2 = '^\%('.a:pattern.'\m\)'
  let l:line = join(a:lines)

  let l:match = match(l:line, a:pattern)
  while l:match >= 0"{{{
    let l:match_str = matchstr(l:line, l:keyword_pattern2, l:match)

    " Ignore too short keyword.
    if !has_key(l:dup_check, l:match_str) && len(l:match_str) >= g:neocomplcache_min_keyword_length
      " Append list.
      call add(l:keyword_lists, { 'word' : l:match_str, 'menu' : a:menu })

      let l:dup_check[l:match_str] = 1
    endif

    let l:match = match(l:line, a:pattern, l:match + len(l:match_str))
  endwhile"}}}

  return l:keyword_lists
endfunction"}}}
function! neocomplcache#cache#load_from_tags(cache_dir, filename, tags_list, mark, filetype)"{{{
  let l:max_lines = len(a:tags_list)

  if l:max_lines > 1000
    call neocomplcache#print_caching('Caching from tags "' . a:filename . '"... please wait.')
  endif
  if l:max_lines > 10000
    let l:print_cache_percent = l:max_lines / 9
  elseif l:max_lines > 7000
    let l:print_cache_percent = l:max_lines / 6
  elseif l:max_lines > 5000
    let l:print_cache_percent = l:max_lines / 5
  elseif l:max_lines > 3000
    let l:print_cache_percent = l:max_lines / 4
  elseif l:max_lines > 2000
    let l:print_cache_percent = l:max_lines / 3
  elseif l:max_lines > 1000
    let l:print_cache_percent = l:max_lines / 2
  else
    let l:print_cache_percent = -1
  endif
  let l:line_cnt = l:print_cache_percent

  let l:menu_pattern = printf('[%s] %%.%ds %%.%ds', a:mark, g:neocomplcache_max_filename_width, g:neocomplcache_max_filename_width)
  let l:keyword_lists = []
  let l:dup_check = {}
  let l:line_num = 1

  try
    for l:line in a:tags_list"{{{
      " Percentage check."{{{
      if l:line_cnt == 0
        call neocomplcache#print_caching(printf('Caching(%s): %d%%', a:filename, l:line_num*100 / l:max_lines))
        let l:line_cnt = l:print_cache_percent
      endif
      let l:line_cnt -= 1"}}}

      let l:tag = split(substitute(l:line, "\<CR>", '', 'g'), '\t', 1)
      " Add keywords.
      if l:line !~ '^!' && len(l:tag) >= 3 && len(l:tag[0]) >= g:neocomplcache_min_keyword_length
            \&& !has_key(l:dup_check, l:tag[0])
        let l:option = {
              \ 'cmd' : substitute(substitute(l:tag[2], '^\%([/?]\^\)\?\s*\|\%(\$\?[/?]\)\?;"$', '', 'g'), '\\\\', '\\', 'g'), 
              \ 'kind' : ''
              \}
        if l:option.cmd =~ '\d\+'
          let l:option.cmd = l:tag[0]
        endif

        for l:opt in l:tag[3:]
          let l:key = matchstr(l:opt, '^\h\w*\ze:')
          if l:key == ''
            let l:option['kind'] = l:opt
          else
            let l:option[l:key] = matchstr(l:opt, '^\h\w*:\zs.*')
          endif
        endfor

        if has_key(l:option, 'file') || (has_key(l:option, 'access') && l:option.access != 'public')
          let l:line_num += 1
          continue
        endif

        let l:abbr = has_key(l:option, 'signature')? l:tag[0] . l:option.signature : (l:option['kind'] == 'd' || l:option['cmd'] == '')?  l:tag[0] : l:option['cmd']
        let l:keyword = {
              \ 'word' : l:tag[0], 'abbr' : l:abbr, 'kind' : l:option['kind'], 'dup' : 1,
              \}
        if has_key(l:option, 'struct')
          let keyword.menu = printf(l:menu_pattern, fnamemodify(l:tag[1], ':t'), l:option.struct)
          let keyword.class = l:option.struct
        elseif has_key(l:option, 'class')
          let keyword.menu = printf(l:menu_pattern, fnamemodify(l:tag[1], ':t'), l:option.class)
          let keyword.class = l:option.class
        elseif has_key(l:option, 'enum')
          let keyword.menu = printf(l:menu_pattern, fnamemodify(l:tag[1], ':t'), l:option.enum)
          let keyword.class = l:option.enum
        elseif has_key(l:option, 'union')
          let keyword.menu = printf(l:menu_pattern, fnamemodify(l:tag[1], ':t'), l:option.union)
          let keyword.class = l:option.union
        else
          let keyword.menu = printf(l:menu_pattern, fnamemodify(l:tag[1], ':t'), '')
          let keyword.class = ''
        endif

        call add(l:keyword_lists, l:keyword)
        let l:dup_check[l:tag[0]] = 1
      endif

      let l:line_num += 1
    endfor"}}}
  catch /E684:/
    call neocomplcache#print_warning('Error occured while analyzing tags!')
    call neocomplcache#print_warning(v:exception)
    let l:log_file = g:neocomplcache_temporary_dir . '/' . a:cache_dir . '/error_log'
    call neocomplcache#print_warning('Please look tags file: ' . l:log_file)
    call writefile(a:tags_list, l:log_file)
    return []
  endtry

  if l:max_lines > 1000
    call neocomplcache#print_caching('')
  endif

  if a:filetype != '' && has_key(g:neocomplcache_tags_filter_patterns, a:filetype)
    call filter(l:keyword_lists, g:neocomplcache_tags_filter_patterns[a:filetype])
  endif

  return l:keyword_lists
endfunction"}}}

function! neocomplcache#cache#save_cache(cache_dir, filename, keyword_list)"{{{
  " Create cache directory.
  call neocomplcache#cache#check_dir(a:cache_dir)

  let l:cache_name = neocomplcache#cache#encode_name(a:cache_dir, a:filename)

  " Create dictionary key.
  for keyword in a:keyword_list
    if !has_key(keyword, 'kind')
      let keyword.kind = ''
    endif
    if !has_key(keyword, 'class')
      let keyword.class = ''
    endif
    if !has_key(keyword, 'abbr')
      let keyword.abbr = keyword.word
    endif
  endfor

  " Output cache.
  let l:word_list = []
  for keyword in a:keyword_list
    call add(l:word_list, printf('%s|||%s|||%s|||%s|||%s', 
          \keyword.word, keyword.abbr, keyword.menu, keyword.kind, keyword.class))
  endfor

  call writefile(l:word_list, l:cache_name)
endfunction"}}}

" Cache helper.
function! neocomplcache#cache#getfilename(cache_dir, filename)"{{{
  let l:cache_name = neocomplcache#cache#encode_name(a:cache_dir, a:filename)
  return l:cache_name
endfunction"}}}
function! neocomplcache#cache#filereadable(cache_dir, filename)"{{{
  let l:cache_name = neocomplcache#cache#encode_name(a:cache_dir, a:filename)
  return filereadable(l:cache_name)
endfunction"}}}
function! neocomplcache#cache#readfile(cache_dir, filename)"{{{
  let l:cache_name = neocomplcache#cache#encode_name(a:cache_dir, a:filename)
  return filereadable(l:cache_name) ? readfile(l:cache_name) : []
endfunction"}}}
function! neocomplcache#cache#writefile(cache_dir, filename, list)"{{{
  call neocomplcache#cache#check_dir(a:cache_dir)

  let l:cache_name = neocomplcache#cache#encode_name(a:cache_dir, a:filename)

  call writefile(a:list, l:cache_name)
endfunction"}}}
function! neocomplcache#cache#encode_name(cache_dir, filename)
  let l:dir = printf('%s/%s/', g:neocomplcache_temporary_dir, a:cache_dir) 
  return l:dir . s:create_hash(l:dir, a:filename)
endfunction
function! neocomplcache#cache#check_dir(cache_dir)"{{{
  " Check cache directory.
  let l:cache_dir = g:neocomplcache_temporary_dir . '/' . a:cache_dir
  if !isdirectory(l:cache_dir)
    call mkdir(l:cache_dir, 'p')
  endif
endfunction"}}}
function! neocomplcache#cache#check_old_cache(cache_dir, filename)"{{{
  " Check old cache file.
  let l:cache_name = neocomplcache#cache#encode_name(a:cache_dir, a:filename)
  return getftime(l:cache_name) == -1 || getftime(l:cache_name) <= getftime(a:filename)
endfunction"}}}

" Check md5.
let s:is_md5 = exists('*md5#md5')
function! s:create_hash(dir, str)
  if len(a:dir) + len(a:str) < 150
    let l:hash = substitute(substitute(a:str, ':', '=-', 'g'), '[/\\]', '=+', 'g')
  elseif s:is_md5
    " Use md5.vim.
    let l:hash = md5#md5(a:str)
  else
    " Use simple hash.
    let l:sum = 0
    for i in range(len(a:str))
      let l:sum += char2nr(a:str[i]) * 2
    endfor

    let l:hash = printf('%x', l:sum)
  endif

  return l:hash
endfunction
" vim: foldmethod=marker
autoload/neocomplcache/sources/abbrev_complete.vim	[[[1
65
"=============================================================================
" FILE: abbrev_complete.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 17 Aug 2010
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:source = {
      \ 'name' : 'abbrev_complete',
      \ 'kind' : 'plugin',
      \}

function! s:source.initialize()"{{{
  " Initialize.
endfunction"}}}

function! s:source.finalize()"{{{
endfunction"}}}

function! s:source.get_keyword_list(cur_keyword_str)"{{{
  " Get current abbrev list.
  let l:abbrev_list = ''
  redir => l:abbrev_list
  silent! iabbrev
  redir END

  let l:list = []
  for l:line in split(l:abbrev_list, '\n')
    let l:abbrev = split(l:line)

    if l:abbrev[0] !~ '^[!i]$'
      " No abbreviation found.
      return []
    endif

    call add(l:list, 
          \{ 'word' : l:abbrev[1], 'menu' : printf('[A] %.'. g:neocomplcache_max_filename_width.'s', l:abbrev[2]) })
  endfor

  return neocomplcache#keyword_filter(l:list, a:cur_keyword_str)
endfunction"}}}

function! neocomplcache#sources#abbrev_complete#define()"{{{
  return s:source
endfunction"}}}
" vim: foldmethod=marker
autoload/neocomplcache/sources/buffer_complete.vim	[[[1
682
"=============================================================================
" FILE: buffer_complete.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 16 Sep 2010
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

" Important variables.
if !exists('s:buffer_sources')
  let s:buffer_sources = {}
endif

let s:source = {
      \ 'name' : 'buffer_complete',
      \ 'kind' : 'plugin',
      \}

function! s:source.initialize()"{{{
  augroup neocomplcache"{{{
    " Caching events
    autocmd FileType,BufWritePost * call s:check_source()
    autocmd CursorHold * call s:rank_caching_current_cache_line(1)
    autocmd InsertEnter,CursorHoldI * call s:rank_caching_current_cache_line(0)
    autocmd InsertLeave * call neocomplcache#sources#buffer_complete#caching_current_cache_line()
    autocmd VimLeavePre * call s:save_all_cache()
  augroup END"}}}

  " Set rank.
  call neocomplcache#set_dictionary_helper(g:neocomplcache_plugin_rank, 'buffer_complete', 4)
  
  " Set completion length.
  call neocomplcache#set_completion_length('buffer_complete', 0)

  " Create cache directory.
  if !isdirectory(g:neocomplcache_temporary_dir . '/buffer_cache')
    call mkdir(g:neocomplcache_temporary_dir . '/buffer_cache', 'p')
  endif
  
  " Initialize script variables."{{{
  let s:buffer_sources = {}
  let s:filetype_frequencies = {}
  let s:cache_line_count = 70
  let s:rank_cache_count = 1
  let s:disable_caching_list = {}
  let s:completion_length = g:neocomplcache_auto_completion_start_length
  "}}}

  " Add commands."{{{
  command! -nargs=? -complete=buffer NeoComplCacheCachingBuffer call s:caching_buffer(<q-args>)
  command! -nargs=? -complete=buffer NeoComplCachePrintSource call s:print_source(<q-args>)
  command! -nargs=? -complete=buffer NeoComplCacheOutputKeyword call s:output_keyword(<q-args>)
  command! -nargs=? -complete=buffer NeoComplCacheSaveCache call s:save_all_cache()
  command! -nargs=? -complete=buffer NeoComplCacheDisableCaching call s:disable_caching(<q-args>)
  command! -nargs=? -complete=buffer NeoComplCacheEnableCaching call s:enable_caching(<q-args>)
  "}}}

  " Initialize cache.
  call s:check_source()
endfunction
"}}}

function! s:source.finalize()"{{{
  delcommand NeoComplCacheCachingBuffer
  delcommand NeoComplCachePrintSource
  delcommand NeoComplCacheOutputKeyword
  delcommand NeoComplCacheSaveCache
  delcommand NeoComplCacheDisableCaching
  delcommand NeoComplCacheEnableCaching

  call s:save_all_cache()

  let s:buffer_sources = {}
endfunction"}}}

function! s:source.get_keyword_list(cur_keyword_str)"{{{
  if neocomplcache#is_auto_complete() && len(a:cur_keyword_str) < s:completion_length
    
    " Check member prefix pattern.
    let l:filetype = neocomplcache#get_context_filetype()
    if !has_key(g:neocomplcache_member_prefix_patterns, l:filetype)
          \ || g:neocomplcache_member_prefix_patterns[l:filetype] == ''
      return []
    endif

    let l:cur_text = neocomplcache#get_cur_text()
    let l:var_name = matchstr(l:cur_text, '\%(\h\w*\%(()\?\)\?\%(' .
          \ g:neocomplcache_member_prefix_patterns[l:filetype] . '\m\)\)\+$')
    if l:var_name == ''
      return []
    endif

    let l:keyword_list = []
    for src in s:get_sources_list()
      if has_key(s:buffer_sources[src].member_cache, l:var_name)
        let l:keyword_list += values(s:buffer_sources[src].member_cache[l:var_name])
      endif
    endfor
    
    return l:keyword_list
  endif
  
  let l:keyword_list = []

  let l:current = bufnr('%')
  
  if len(a:cur_keyword_str) < s:completion_length ||
        \neocomplcache#check_match_filter(a:cur_keyword_str, s:completion_length)
    for src in s:get_sources_list()
      let l:keyword_cache = neocomplcache#keyword_filter(
            \neocomplcache#unpack_dictionary_dictionary(s:buffer_sources[src].keyword_cache), a:cur_keyword_str)
      if src == l:current
        call s:calc_frequency(l:keyword_cache)
      endif
      let l:keyword_list += l:keyword_cache
    endfor
  else
    let l:key = tolower(a:cur_keyword_str[: s:completion_length-1])
    for src in s:get_sources_list()
      if has_key(s:buffer_sources[src].keyword_cache, l:key)
        let l:keyword_cache = neocomplcache#keyword_filter(values(s:buffer_sources[src].keyword_cache[l:key]), a:cur_keyword_str)

        if src == l:current
          call s:calc_frequency(l:keyword_cache)
        endif

        let l:keyword_list += l:keyword_cache
      endif
    endfor
  endif

  return l:keyword_list
endfunction"}}}

function! neocomplcache#sources#buffer_complete#define()"{{{
  return s:source
endfunction"}}}

function! neocomplcache#sources#buffer_complete#get_frequencies()"{{{
  let l:filetype = neocomplcache#get_context_filetype()
  if !has_key(s:filetype_frequencies, l:filetype)
    return {}
  endif

  return s:filetype_frequencies[l:filetype]
endfunction"}}}

function! neocomplcache#sources#buffer_complete#caching_current_cache_line()"{{{
  " Current line caching.
  
  if !s:exists_current_source() || has_key(s:disable_caching_list, bufnr('%'))
    return
  endif

  let l:source = s:buffer_sources[bufnr('%')]
  let l:filename = fnamemodify(l:source.name, ':t')
  let l:menu = printf('[B] %.' . g:neocomplcache_max_filename_width . 's', l:filename)
  let l:keyword_pattern = l:source.keyword_pattern
  let l:keyword_pattern2 = '^\%('.l:keyword_pattern.'\m\)'
  let l:keywords = l:source.keyword_cache

  let l:line = join(getline(line('.')-1, line('.')+1))
  let l:match = match(l:line, l:keyword_pattern)
  while l:match >= 0"{{{
    let l:match_str = matchstr(l:line, l:keyword_pattern2, l:match)

    " Ignore too short keyword.
    if len(l:match_str) >= g:neocomplcache_min_keyword_length"{{{
      " Check dup.
      let l:key = tolower(l:match_str[: s:completion_length-1])
      if !has_key(l:keywords, l:key)
        let l:keywords[l:key] = {}
      endif
      if !has_key(l:keywords[l:key], l:match_str)
        " Append list.
        let l:keywords[l:key][l:match_str] = { 'word' : l:match_str, 'menu' : l:menu }
      endif
    endif"}}}

    " Next match.
    let l:match = match(l:line, l:keyword_pattern, l:match + len(l:match_str))
  endwhile"}}}
endfunction"}}}

function! s:calc_frequency(list)"{{{
  if !s:exists_current_source()
    return
  endif

  let l:list_len = len(a:list)

  if l:list_len > g:neocomplcache_max_list * 5
    let l:calc_cnt = 15
  elseif l:list_len > g:neocomplcache_max_list * 3
    let l:calc_cnt = 13
  elseif l:list_len > g:neocomplcache_max_list
    let l:calc_cnt = 10
  elseif l:list_len > g:neocomplcache_max_list / 2
    let l:calc_cnt = 8
  elseif l:list_len > g:neocomplcache_max_list / 3
    let l:calc_cnt = 5
  elseif l:list_len > g:neocomplcache_max_list / 4
    let l:calc_cnt = 4
  else
    let l:calc_cnt = 3
  endif

  let l:source = s:buffer_sources[bufnr('%')]
  let l:frequencies = l:source.frequencies
  let l:filetype = neocomplcache#get_context_filetype()
  if !has_key(s:filetype_frequencies, l:filetype)
    let s:filetype_frequencies[l:filetype] = {}
  endif
  let l:filetype_frequencies = s:filetype_frequencies[l:filetype]
  
  for keyword in a:list
    if s:rank_cache_count <= 0
      " Set rank.
      
      let l:word = keyword.word
      let l:frequency = 0
      for rank_lines in values(l:source.rank_lines)
        if has_key(rank_lines, l:word)
          let l:frequency += rank_lines[l:word]
        endif
      endfor
      
      if !has_key(l:filetype_frequencies, l:word)
        let l:filetype_frequencies[l:word] = 0
      endif
      if has_key(l:frequencies, l:word)
        let l:filetype_frequencies[l:word] -= l:frequencies[l:word]
      endif
      if l:frequency == 0
        " Garbage collect
        let l:ignorecase_save = &ignorecase
        let &ignorecase = 0
        let l:pos = searchpos(neocomplcache#escape_match(l:word), 'ncw', 0)
        let &ignorecase = l:ignorecase_save
        
        if l:pos[0] == 0
          " Delete.
          let l:key = tolower(l:word[: s:completion_length-1])
          if has_key(l:source.keyword_cache[l:key], l:word)
            call remove(l:source.keyword_cache[l:key], l:word)
          endif
          if has_key(l:source.frequencies, l:word)
            call remove(l:source.frequencies, l:word)
          endif
          if l:filetype_frequencies[l:word] == 0
            call remove(l:filetype_frequencies, l:word)
          endif
        else
          let l:frequencies[l:word] = 1
          let l:filetype_frequencies[l:word] += 1
        endif
      else
        let l:frequencies[l:word] = l:frequency
        let l:filetype_frequencies[l:word] += l:frequency
      endif

      " Reset count.
      let s:rank_cache_count = neocomplcache#rand(l:calc_cnt)
    endif

    let s:rank_cache_count -= 1
  endfor
endfunction"}}}

function! s:get_sources_list()"{{{
  let l:sources_list = []

  let l:filetypes = neocomplcache#get_source_filetypes(neocomplcache#get_context_filetype())
  for key in keys(s:buffer_sources)
    if has_key(l:filetypes, s:buffer_sources[key].filetype) || bufnr('%') == key
      call add(l:sources_list, key)
    endif
  endfor

  return l:sources_list
endfunction"}}}

function! s:rank_caching_current_cache_line(is_force)"{{{
  if !s:exists_current_source() || neocomplcache#is_locked()
    return
  endif

  let l:source = s:buffer_sources[bufnr('%')]
  let l:filename = fnamemodify(l:source.name, ':t')

  let l:start_line = (line('.')-1)/l:source.cache_line_cnt*l:source.cache_line_cnt+1
  let l:end_line = l:start_line + l:source.cache_line_cnt-1
  let l:cache_num = (l:start_line-1) / l:source.cache_line_cnt

  " For debugging.
  "echomsg printf("start=%d, end=%d", l:start_line, l:end_line)

  if !a:is_force && has_key(l:source.rank_lines, l:cache_num)
    return
  endif
  
  " Clear cache line.
  let l:source.rank_lines[l:cache_num] = {}
  let l:rank_lines = l:source.rank_lines[l:cache_num]

  let l:buflines = getline(l:start_line, l:end_line)
  let l:menu = printf('[B] %.' . g:neocomplcache_max_filename_width . 's', l:filename)
  let l:keyword_pattern = l:source.keyword_pattern
  let l:keyword_pattern2 = '^\%('.l:keyword_pattern.'\m\)'

  let [l:line_num, l:max_lines] = [0, len(l:buflines)]
  while l:line_num < l:max_lines
    let l:line = buflines[l:line_num]
    let l:match = match(l:line, l:keyword_pattern)

    while l:match >= 0"{{{
      let l:match_str = matchstr(l:line, l:keyword_pattern2, l:match)

      " Ignore too short keyword.
      if len(l:match_str) >= g:neocomplcache_min_keyword_length"{{{
        if !has_key(l:rank_lines, l:match_str)
          let l:rank_lines[l:match_str] = 1
        else
          let l:rank_lines[l:match_str] += 1
        endif
      endif"}}}

      " Next match.
      let l:match = match(l:line, l:keyword_pattern, l:match + len(l:match_str))
    endwhile"}}}

    let l:line_num += 1
  endwhile
  
  let l:filetype = neocomplcache#get_context_filetype(1)
  if !has_key(g:neocomplcache_member_prefix_patterns, l:filetype)
        \ || g:neocomplcache_member_prefix_patterns[l:filetype] == ''
    return
  endif
  
  let l:menu = '[B] member'
  let l:keyword_pattern = '\%(\h\w*\%(()\?\)\?\%(' . g:neocomplcache_member_prefix_patterns[l:filetype] . '\m\)\)\+\h\w*\%(()\?\)\?'
  let l:keyword_pattern2 = '^'.l:keyword_pattern
  let l:member_pattern = '\h\w*\%(()\?\)\?$'
  
  " Cache member pattern.
  let [l:line_num, l:max_lines] = [0, len(l:buflines)]
  while l:line_num < l:max_lines
    let l:line = buflines[l:line_num]
    let l:match = match(l:line, l:keyword_pattern)

    while l:match >= 0"{{{
      let l:match_str = matchstr(l:line, l:keyword_pattern2, l:match)

      " Next match.
      let l:match = matchend(l:line, l:keyword_pattern, l:match + len(l:match_str))
      
      while l:match_str != ''
        let l:member_name = matchstr(l:match_str, l:member_pattern)
        let l:var_name = l:match_str[ : -len(l:member_name)-1]

        if !has_key(l:source.member_cache, l:var_name)
          let l:source.member_cache[l:var_name] = {}
        endif
        if !has_key(l:source.member_cache[l:var_name], l:member_name)
          let l:source.member_cache[l:var_name][l:member_name] = { 'word' : l:member_name, 'menu' : l:menu }
        endif

        let l:match_str = matchstr(l:var_name, l:keyword_pattern2)
      endwhile
    endwhile"}}}

    let l:line_num += 1
  endwhile
endfunction"}}}

function! s:initialize_source(srcname)"{{{
  let l:filename = fnamemodify(bufname(a:srcname), ':t')

  " Set cache line count.
  let l:buflines = getbufline(a:srcname, 1, '$')
  let l:end_line = len(l:buflines)

  if l:end_line > 150
    let cnt = 0
    for line in l:buflines[50:150] 
      let cnt += len(line)
    endfor

    if cnt <= 3000
      let l:cache_line_cnt = s:cache_line_count
    elseif cnt <= 4000
      let l:cache_line_cnt = s:cache_line_count*7 / 10
    elseif cnt <= 5000
      let l:cache_line_cnt = s:cache_line_count / 2
    elseif cnt <= 7500
      let l:cache_line_cnt = s:cache_line_count / 3
    elseif cnt <= 10000
      let l:cache_line_cnt = s:cache_line_count / 5
    elseif cnt <= 12000
      let l:cache_line_cnt = s:cache_line_count / 7
    elseif cnt <= 14000
      let l:cache_line_cnt = s:cache_line_count / 10
    else
      let l:cache_line_cnt = s:cache_line_count / 13
    endif
  elseif l:end_line > 100
    let l:cache_line_cnt = s:cache_line_count / 3
  else
    let l:cache_line_cnt = s:cache_line_count / 5
  endif

  let l:ft = getbufvar(a:srcname, '&filetype')
  if l:ft == ''
    let l:ft = 'nothing'
  endif

  let l:keyword_pattern = neocomplcache#get_keyword_pattern(l:ft)

  let s:buffer_sources[a:srcname] = {
        \'keyword_cache' : {}, 'rank_lines' : {}, 'member_cache' : {},
        \'name' : l:filename, 'filetype' : l:ft, 'keyword_pattern' : l:keyword_pattern, 
        \'end_line' : l:end_line , 'cache_line_cnt' : l:cache_line_cnt, 
        \'frequencies' : {}, 'check_sum' : len(join(l:buflines[:4], '\n'))
        \}
endfunction"}}}

function! s:word_caching(srcname)"{{{
  " Initialize source.
  call s:initialize_source(a:srcname)

  if s:caching_from_cache(a:srcname) == 0
    " Caching from cache.
    return
  endif

  let l:bufname = bufname(str2nr(a:srcname))
  if fnamemodify(l:bufname, ':t') ==# '[Command Line]'
    " Ignore caching.
    return
  endif

  let l:keyword_cache = s:buffer_sources[a:srcname].keyword_cache
  for l:keyword in neocomplcache#cache#load_from_file(bufname(str2nr(a:srcname)), s:buffer_sources[a:srcname].keyword_pattern, 'B')
    let l:key = tolower(l:keyword.word[: s:completion_length-1])
    if !has_key(l:keyword_cache, l:key)
      let l:keyword_cache[l:key] = {}
    endif
    let l:keyword_cache[l:key][l:keyword.word] = l:keyword
  endfor
endfunction"}}}

function! s:caching_from_cache(srcname)"{{{
  if getbufvar(a:srcname, '&buftype') =~ 'nofile'
    return -1
  endif

  let l:srcname = fnamemodify(bufname(str2nr(a:srcname)), ':p')

  if neocomplcache#cache#check_old_cache('buffer_cache', l:srcname)
    return -1
  endif

  let l:source = s:buffer_sources[a:srcname]
  for l:keyword in neocomplcache#cache#load_from_cache('buffer_cache', l:srcname)
    let l:key = tolower(l:keyword.word[: s:completion_length-1])
    if !has_key(l:source.keyword_cache, l:key)
      let l:source.keyword_cache[l:key] = {}
    endif

    let l:source.keyword_cache[l:key][l:keyword.word] = l:keyword
  endfor 

  return 0
endfunction"}}}

function! s:check_changed_buffer(bufnumber)"{{{
  let l:source = s:buffer_sources[a:bufnumber]
  
  if getbufvar(a:bufnumber, '&buftype') =~ 'nofile'
    " Check buffer changed.
    let l:check_sum = len(join(getbufline(a:bufnumber, 1, 5), '\n'))
    if l:check_sum != l:source.check_sum
      " Recaching.
      return 1
    endif
  endif

  let l:ft = getbufvar(a:bufnumber, '&filetype')
  if l:ft == ''
    let l:ft = 'nothing'
  endif

  return s:buffer_sources[a:bufnumber].name != fnamemodify(bufname(a:bufnumber), ':t')
        \ || s:buffer_sources[a:bufnumber].filetype != l:ft
endfunction"}}}

function! s:check_source()"{{{
  call s:check_deleted_buffer()

  let l:bufnumber = 1

  " Check new buffer.
  while l:bufnumber <= bufnr('$')
    if bufwinnr(l:bufnumber) >= 0
      let l:bufname = fnamemodify(bufname(l:bufnumber), ':p')
      if (!has_key(s:buffer_sources, l:bufnumber) || s:check_changed_buffer(l:bufnumber))
            \&& !has_key(s:disable_caching_list, l:bufnumber)
            \&& (g:neocomplcache_disable_caching_buffer_name_pattern == '' || l:bufname !~ g:neocomplcache_disable_caching_buffer_name_pattern)
            \&& !neocomplcache#is_locked(l:bufnumber)
        if getfsize(l:bufname) < g:neocomplcache_caching_limit_file_size
              \ && ((g:neocomplcache_force_caching_buffer_name_pattern != '' && l:bufname =~ g:neocomplcache_force_caching_buffer_name_pattern)
              \       || (getbufvar(l:bufnumber, '&modifiable') && !getbufvar(l:bufnumber, '&readonly') && getbufvar(l:bufnumber, '&buftype') !~ 'help')
              \)
          " Caching.
          call s:word_caching(l:bufnumber)
        endif
      endif
    endif

    let l:bufnumber += 1
  endwhile
endfunction"}}}
function! s:check_deleted_buffer()"{{{
  " Check deleted buffer.
  for key in keys(s:buffer_sources)
    if !bufloaded(str2nr(key))
      " Save cache.
      call s:save_cache(key)

      " Remove item.
      call remove(s:buffer_sources, key)
    endif
  endfor
endfunction"}}}

function! s:exists_current_source()"{{{
  return has_key(s:buffer_sources, bufnr('%'))
endfunction"}}}

function! s:save_cache(srcname)"{{{
  if s:buffer_sources[a:srcname].end_line < 500
    return
  endif

  if getbufvar(a:srcname, '&buftype') =~ 'nofile'
    return
  endif

  let l:srcname = fnamemodify(bufname(str2nr(a:srcname)), ':p')
  if !filereadable(l:srcname)
    return
  endif

  let l:cache_name = neocomplcache#cache#encode_name('buffer_cache', l:srcname)
  if getftime(l:cache_name) >= getftime(l:srcname)
    return -1
  endif

  " Output buffer.
  call neocomplcache#cache#save_cache('buffer_cache', l:srcname, neocomplcache#unpack_dictionary_dictionary(s:buffer_sources[a:srcname].keyword_cache))
endfunction "}}}
function! s:save_all_cache()"{{{
  for l:key in keys(s:buffer_sources)
    call s:save_cache(l:key)
  endfor
endfunction"}}}

" Command functions."{{{
function! s:caching_buffer(name)"{{{
  if a:name == ''
    let l:number = bufnr('%')
  else
    let l:number = bufnr(a:name)

    if l:number < 0
      call neocomplcache#print_error('Invalid buffer name.')
      return
    endif
  endif

  " Word recaching.
  call s:word_caching(l:number)
endfunction"}}}
function! s:print_source(name)"{{{
  if a:name == ''
    let l:number = bufnr('%')
  else
    let l:number = bufnr(a:name)

    if l:number < 0
      call neocomplcache#print_error('Invalid buffer name.')
      return
    endif
  endif

  if !has_key(s:buffer_sources, l:number)
    return
  endif

  silent put=printf('Print neocomplcache %d source.', l:number)
  for l:key in keys(s:buffer_sources[l:number])
    silent put =printf('%s => %s', l:key, string(s:buffer_sources[l:number][l:key]))
  endfor
endfunction"}}}
function! s:output_keyword(name)"{{{
  if a:name == ''
    let l:number = bufnr('%')
  else
    let l:number = bufnr(a:name)

    if l:number < 0
      call neocomplcache#print_error('Invalid buffer name.')
      return
    endif
  endif

  if !has_key(s:buffer_sources, l:number)
    return
  endif

  " Output buffer.
  for keyword in neocomplcache#unpack_dictionary_dictionary(s:buffer_sources[l:number].keyword_cache)
    silent put=string(keyword)
  endfor
endfunction "}}}
function! s:disable_caching(name)"{{{
  if a:number == ''
    let l:number = bufnr('%')
  else
    let l:number = bufnr(a:name)

    if l:number < 0
      call neocomplcache#print_error('Invalid buffer name.')
      return
    endif
  endif

  let s:disable_caching_list[l:number] = 1

  if has_key(s:buffer_sources, l:number)
    " Delete source.
    call remove(s:buffer_sources, l:number)
  endif
endfunction"}}}
function! s:enable_caching(name)"{{{
  if a:number == ''
    let l:number = bufnr('%')
  else
    let l:number = bufnr(a:number)

    if l:number < 0
      call neocomplcache#print_error('Invalid buffer name.')
      return
    endif
  endif

  if has_key(s:disable_caching_list, l:number)
    call remove(s:disable_caching_list, l:number)
  endif
endfunction"}}}
"}}}

" vim: foldmethod=marker
autoload/neocomplcache/sources/completefunc_complete.vim	[[[1
114
"=============================================================================
" FILE: completefunc_complete.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 25 Jul 2010
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:source = {
      \ 'name' : 'completefunc_complete',
      \ 'kind' : 'complfunc',
      \}

function! s:source.initialize()"{{{
  " Set rank.
  call neocomplcache#set_dictionary_helper(g:neocomplcache_plugin_rank, 'completefunc_complete', 5)
endfunction"}}}
function! s:source.finalize()"{{{
endfunction"}}}

function! s:source.get_keyword_pos(cur_text)"{{{
  return -1
endfunction"}}}

function! s:source.get_complete_words(cur_keyword_pos, cur_keyword_str)"{{{
  return []
endfunction"}}}

function! neocomplcache#sources#completefunc_complete#define()"{{{
  return s:source
endfunction"}}}

function! neocomplcache#sources#completefunc_complete#call_completefunc(funcname)"{{{
  let l:cur_text = neocomplcache#get_cur_text()

  " Save pos.
  let l:pos = getpos('.')
  let l:line = getline('.')

  let l:cur_keyword_pos = call(a:funcname, [1, ''])

  " Restore pos.
  call setpos('.', l:pos)

  if l:cur_keyword_pos < 0
    return ''
  endif
  let l:cur_keyword_str = l:cur_text[l:cur_keyword_pos :]

  let l:pos = getpos('.')

  let l:list = call(a:funcname, [0, l:cur_keyword_str])

  call setpos('.', l:pos)

  if empty(l:list)
    return ''
  endif

  let l:list = s:get_completefunc_list(l:list)

  " Start manual complete.
  return neocomplcache#start_manual_complete_list(l:cur_keyword_pos, l:cur_keyword_str, l:list)
endfunction"}}}

function! s:get_completefunc_list(list)"{{{
  let l:comp_list = []

  " Convert string list.
  for str in filter(copy(a:list), 'type(v:val) == '.type(''))
    let l:dict = { 'word' : str, 'menu' : '[C]' }

    call add(l:comp_list, l:dict)
  endfor

  for l:comp in filter(a:list, 'type(v:val) != '.type(''))
    let l:dict = {
          \'word' : l:comp.word, 'menu' : '[C]', 
          \'abbr' : has_key(l:comp, 'abbr')? l:comp.abbr : l:comp.word
          \}

    if has_key(l:comp, 'kind')
      let l:dict.kind = l:comp.kind
    endif

    if has_key(l:comp, 'menu')
      let l:dict.menu .= ' ' . l:comp.menu
    endif

    call add(l:comp_list, l:dict)
  endfor

  return l:comp_list
endfunction"}}}

" vim: foldmethod=marker
autoload/neocomplcache/sources/dictionary_complete.vim	[[[1
152
"=============================================================================
" FILE: dictionary_complete.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 29 Aug 2010
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:source = {
      \ 'name' : 'dictionary_complete',
      \ 'kind' : 'plugin',
      \}

function! s:source.initialize()"{{{
  " Initialize.
  let s:dictionary_list = {}
  let s:completion_length = neocomplcache#get_auto_completion_length('dictionary_complete')

  " Initialize dictionary."{{{
  if !exists('g:neocomplcache_dictionary_filetype_lists')
    let g:neocomplcache_dictionary_filetype_lists = {}
  endif
  if !has_key(g:neocomplcache_dictionary_filetype_lists, 'default')
    let g:neocomplcache_dictionary_filetype_lists['default'] = ''
  endif
  "}}}

  " Set caching event.
  autocmd neocomplcache FileType * call s:caching()

  " Add command.
  command! -nargs=? -complete=customlist,neocomplcache#filetype_complete NeoComplCacheCachingDictionary call s:recaching(<q-args>)

  " Create cache directory.
  if !isdirectory(g:neocomplcache_temporary_dir . '/dictionary_cache')
    call mkdir(g:neocomplcache_temporary_dir . '/dictionary_cache')
  endif

  " Initialize check.
  call s:caching()
endfunction"}}}

function! s:source.finalize()"{{{
  delcommand NeoComplCacheCachingDictionary
endfunction"}}}

function! s:source.get_keyword_list(cur_keyword_str)"{{{
  let l:list = []

  let l:key = neocomplcache#is_text_mode() ? 'text' : neocomplcache#get_context_filetype()
  if neocomplcache#is_text_mode() && !has_key(s:dictionary_list, 'text')
    " Caching.
    call s:caching()
  endif

  for l:source in neocomplcache#get_sources_list(s:dictionary_list, l:key)
    let l:list += neocomplcache#dictionary_filter(l:source, a:cur_keyword_str, s:completion_length)
  endfor

  return l:list
endfunction"}}}

function! neocomplcache#sources#dictionary_complete#define()"{{{
  return s:source
endfunction"}}}

function! s:caching()"{{{
  if !bufloaded(bufnr('%'))
    return
  endif

  let l:key = neocomplcache#is_text_mode() ? 'text' : neocomplcache#get_context_filetype()
  for l:filetype in keys(neocomplcache#get_source_filetypes(l:key))
    if !has_key(s:dictionary_list, l:filetype)
      let s:dictionary_list[l:filetype] = s:initialize_dictionary(l:filetype)
    endif
  endfor
endfunction"}}}

function! s:recaching(filetype)"{{{
  if a:filetype == ''
    let l:filetype = neocomplcache#get_context_filetype(1)
  else
    let l:filetype = a:filetype
  endif

  " Caching.
  let s:dictionary_list[l:filetype] = s:caching_from_dict(l:filetype)
endfunction"}}}

function! s:initialize_dictionary(filetype)"{{{
  let l:keyword_lists = neocomplcache#cache#index_load_from_cache('dictionary_cache', a:filetype, s:completion_length)
  if !empty(l:keyword_lists)
    " Caching from cache.
    return l:keyword_lists
  endif

  return s:caching_from_dict(a:filetype)
endfunction"}}}

function! s:caching_from_dict(filetype)"{{{
  if has_key(g:neocomplcache_dictionary_filetype_lists, a:filetype)
    let l:dictionaries = g:neocomplcache_dictionary_filetype_lists[a:filetype]
  elseif a:filetype != &filetype || &l:dictionary == ''
    return {}
  else
    let l:dictionaries = &l:dictionary
  endif

  let l:keyword_list = []

  for l:dictionary in split(l:dictionaries, ',')
    if filereadable(l:dictionary)
      let l:keyword_list += neocomplcache#cache#load_from_file(l:dictionary, 
            \neocomplcache#get_keyword_pattern(a:filetype), 'D')
    endif
  endfor

  let l:keyword_dict = {}

  for l:keyword in l:keyword_list
    let l:key = tolower(l:keyword.word[: s:completion_length-1])
    if !has_key(l:keyword_dict, l:key)
      let l:keyword_dict[l:key] = []
    endif
    call add(l:keyword_dict[l:key], l:keyword)
  endfor 

  " Save dictionary cache.
  call neocomplcache#cache#save_cache('dictionary_cache', a:filetype, neocomplcache#unpack_dictionary(l:keyword_dict))

  return l:keyword_dict
endfunction"}}}
" vim: foldmethod=marker
autoload/neocomplcache/sources/filename_complete.vim	[[[1
179
"=============================================================================
" FILE: filename_complete.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 29 Sep 2010
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:source = {
      \ 'name' : 'filename_complete',
      \ 'kind' : 'complfunc',
      \}

function! s:source.initialize()"{{{
  " Initialize.
  let s:skip_dir = {}
  let s:completion_length = neocomplcache#get_auto_completion_length('filename_complete')
  
  " Set rank.
  call neocomplcache#set_dictionary_helper(g:neocomplcache_plugin_rank, 'filename_complete', 2)
endfunction"}}}
function! s:source.finalize()"{{{
endfunction"}}}

function! s:source.get_keyword_pos(cur_text)"{{{
  if &filetype ==# 'vimshell' || neocomplcache#within_comment()
    return -1
  endif

  let l:is_win = has('win32') || has('win64')

  " Not Filename pattern.
  if a:cur_text =~ 
        \'\*$\|\.\.\+$\|[/\\][/\\]\f*$\|/c\%[ygdrive/]$\|\\|$\|\a:[^/]*$'
    return -1
  endif

  " Filename pattern.
  let l:pattern = neocomplcache#get_keyword_pattern_end('filename')
  let [l:cur_keyword_pos, l:cur_keyword_str] = neocomplcache#match_word(a:cur_text, l:pattern)
  if neocomplcache#is_auto_complete() && len(l:cur_keyword_str) < s:completion_length
    return -1
  endif

  " Not Filename pattern.
  if l:is_win && &filetype == 'tex' && l:cur_keyword_str =~ '\\'
    return -1
  endif

  " Skip directory.
  if neocomplcache#is_auto_complete()
    let l:dir = simplify(fnamemodify(l:cur_keyword_str, ':p:h'))
    if l:dir != '' && has_key(s:skip_dir, l:dir)
      return -1
    endif
  endif

  return l:cur_keyword_pos
endfunction"}}}

function! s:source.get_complete_words(cur_keyword_pos, cur_keyword_str)"{{
  let l:cur_keyword_str = escape(a:cur_keyword_str, '[]')

  let l:is_win = has('win32') || has('win64')

  if a:cur_keyword_str =~ '^\$\h\w*'
    let l:env = matchstr(a:cur_keyword_str, '^\$\h\w*')
    let l:env_ev = eval(l:env)
    if l:is_win
      let l:env_ev = substitute(l:env_ev, '\\', '/', 'g')
    endif
    let l:len_env = len(l:env_ev)
  else
    let l:len_env = 0
    
    if a:cur_keyword_str =~ '^\~\h\w*'
      let l:cur_keyword_str = simplify($HOME . '/../' . l:cur_keyword_str[1:])
    endif
  endif
  
  let l:cur_keyword_str = substitute(l:cur_keyword_str, '\\ ', ' ', 'g')

  " Glob by directory name.
  let l:cur_keyword_str = substitute(l:cur_keyword_str, '\%(^\.\|/\.\?\)\?\zs[^/]*$', '', '')

  let l:path = (!neocomplcache#is_auto_complete() && a:cur_keyword_str !~ '^\.\.\?/')? &path : ','
  let l:glob = (l:cur_keyword_str !~ '\*$')?  l:cur_keyword_str . '*' : l:cur_keyword_str

  try
    let l:files = split(substitute(globpath(l:path, l:glob), '\\', '/', 'g'), '\n')
  catch
    return []
  endtry
  
  if empty(l:files)
    " Add '*' to a delimiter.
    let l:cur_keyword_str = substitute(l:cur_keyword_str, '\w\+\ze[/._-]', '\0*', 'g')
    let l:glob = (l:cur_keyword_str !~ '\*$')?  l:cur_keyword_str . '*' : l:cur_keyword_str
    
    try
      let l:files = split(substitute(globpath(l:path, l:glob), '\\', '/', 'g'), '\n')
    catch
      return []
    endtry
  endif
  if empty(l:files) || (neocomplcache#is_auto_complete() && len(l:files) > g:neocomplcache_max_list)
    return []
  endif

  let l:dir_list = []
  let l:file_list = []
  let l:home_pattern = '^'.substitute($HOME, '\\', '/', 'g').'/'
  let l:paths = map(split(&path, ','), 'substitute(v:val, "\\\\", "/", "g")')
  let l:exts = escape(substitute($PATHEXT, ';', '\\|', 'g'), '.')
  for word in l:files
    let l:dict = { 'word' : word, 'menu' : '[F]' }

    let l:cur_keyword_str = $HOME . '/../' . l:cur_keyword_str[1:]
    if l:len_env != 0 && l:dict.word[: l:len_env-1] == l:env_ev
      let l:dict.word = l:env . l:dict.word[l:len_env :]
    elseif a:cur_keyword_str =~ '^\~/'
      let l:dict.word = substitute(word, l:home_pattern, '\~/', '')
    elseif !neocomplcache#is_auto_complete() && a:cur_keyword_str !~ '^\.\.\?/'
      " Path search.
      for path in l:paths
        if path != '' && neocomplcache#head_match(word, path . '/')
          let l:dict.word = l:dict.word[len(path)+1 : ]
          break
        endif
      endfor
    endif

    let l:abbr = l:dict.word
    if isdirectory(l:word)
      let l:abbr .= '/'
      if g:neocomplcache_enable_auto_delimiter
        let l:dict.word .= '/'
      endif
    elseif l:is_win
      if '.'.fnamemodify(l:word, ':e') =~ l:exts
        let l:abbr .= '*'
      endif
    elseif executable(l:word)
      let l:abbr .= '*'
    endif
    let l:dict.abbr = l:abbr

    " Escape word.
    let l:dict.word = escape(l:dict.word, ' *?[]"={}')

    call add(isdirectory(l:word) ? l:dir_list : l:file_list, l:dict)
  endfor

  return neocomplcache#keyword_filter(l:dir_list, a:cur_keyword_str) + neocomplcache#keyword_filter(l:file_list, a:cur_keyword_str)
endfunction"}}

function! neocomplcache#sources#filename_complete#define()"{{{
  return s:source
endfunction"}}}

" vim: foldmethod=marker
autoload/neocomplcache/sources/include_complete.vim	[[[1
382
"=============================================================================
" FILE: include_complete.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 30 Sep 2010
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:include_info = {}

let s:source = {
      \ 'name' : 'include_complete',
      \ 'kind' : 'plugin',
      \}

function! s:source.initialize()"{{{
  " Initialize
  let s:include_info = {}
  let s:include_cache = {}
  let s:cached_pattern = {}
  let s:completion_length = neocomplcache#get_auto_completion_length('include_complete')
  
  " Set rank.
  call neocomplcache#set_dictionary_helper(g:neocomplcache_plugin_rank, 'include_complete', 7)

  augroup neocomplcache
    " Caching events
    autocmd FileType * call s:check_buffer_all()
    autocmd BufWritePost * call s:check_buffer('')
  augroup END

  " Initialize include pattern."{{{
  call neocomplcache#set_dictionary_helper(g:neocomplcache_include_patterns, 'java,haskell', '^import')
  "}}}
  " Initialize expr pattern."{{{
  call neocomplcache#set_dictionary_helper(g:neocomplcache_include_exprs, 'haskell',
        \'substitute(v:fname,''\\.'',''/'',''g'')')
  "}}}
  " Initialize path pattern."{{{
  "}}}
  " Initialize suffixes pattern."{{{
  call neocomplcache#set_dictionary_helper(g:neocomplcache_include_suffixes, 'haskell', '.hs')
  "}}}

  " Create cache directory.
  if !isdirectory(g:neocomplcache_temporary_dir . '/include_cache')
    call mkdir(g:neocomplcache_temporary_dir . '/include_cache', 'p')
  endif

  " Add command.
  command! -nargs=? -complete=buffer NeoComplCacheCachingInclude call s:check_buffer(<q-args>)

  if neocomplcache#exists_echodoc()
    call echodoc#register('include_complete', s:doc_dict)
  endif
  
  " Initialize check.
  call s:check_buffer_all()
endfunction"}}}

function! s:source.finalize()"{{{
  delcommand NeoComplCacheCachingInclude
  
  if neocomplcache#exists_echodoc()
    call echodoc#unregister('include_complete')
  endif
endfunction"}}}

function! s:source.get_keyword_list(cur_keyword_str)"{{{
  if !has_key(s:include_info, bufnr('%')) || neocomplcache#within_comment()
    return []
  endif

  let l:keyword_list = []
  if len(a:cur_keyword_str) < s:completion_length ||
        \neocomplcache#check_match_filter(a:cur_keyword_str, s:completion_length)
    for l:include in s:include_info[bufnr('%')].include_files
      if !bufloaded(l:include)
        let l:keyword_list += neocomplcache#unpack_dictionary(s:include_cache[l:include])
      endif
    endfor
  else
    let l:key = tolower(a:cur_keyword_str[: s:completion_length-1])
    for l:include in s:include_info[bufnr('%')].include_files
      if !bufloaded(l:include) && has_key(s:include_cache[l:include], l:key)
        let l:keyword_list += s:include_cache[l:include][l:key]
      endif
    endfor
  endif

  return neocomplcache#keyword_filter(neocomplcache#dup_filter(l:keyword_list), a:cur_keyword_str)
endfunction"}}}

function! neocomplcache#sources#include_complete#define()"{{{
  return s:source
endfunction"}}}

function! neocomplcache#sources#include_complete#get_include_files(bufnumber)"{{{
  if has_key(s:include_info, a:bufnumber)
    return s:include_info[a:bufnumber].include_files
  else
    return []
  endif
endfunction"}}}

" For echodoc."{{{
let s:doc_dict = {
      \ 'name' : 'include_complete',
      \ 'rank' : 5,
      \ 'filetypes' : {},
      \ }
function! s:doc_dict.search(cur_text)"{{{
  if &filetype ==# 'vim' || !has_key(s:include_info, bufnr('%'))
    return []
  endif
  
  " Collect words.
  let l:words = []
  let i = 0
  while i >= 0
    let l:word = matchstr(a:cur_text, '\k\+', i)
    if len(l:word) >= s:completion_length
      call add(l:words, l:word)
    endif
    
    let i = matchend(a:cur_text, '\k\+', i)
  endwhile

  for l:word in reverse(l:words)
    let l:key = tolower(l:word[: s:completion_length-1])
    
    for l:include in s:include_info[bufnr('%')].include_files
      if has_key(s:include_cache[l:include], l:key)
        let l:cache = filter(copy(s:include_cache[l:include][l:key]), 'stridx(v:val.word, ' . string(l:word) . ') == 0')
        if !empty(l:cache) && has_key(l:cache[0], 'kind') && l:cache[0].kind != ''
          let l:match = match(neocomplcache#escape_match(l:cache[0].abbr), l:word)
          if l:match >= 0
            let l:ret = []

            if l:match > 0
              call add(l:ret, { 'text' : l:cache[0].abbr[ : l:match-1] })
            endif
            
            call add(l:ret, { 'text' : l:word, 'highlight' : 'Identifier' })
            call add(l:ret, { 'text' : l:cache[0].abbr[l:match+len(l:word) :] })

            if l:match > 0 || len(l:ret[-1].text) > 0
              return l:ret
            endif
          endif
        endif
      endif
    endfor
  endfor
  
  return []
endfunction"}}}
"}}}

function! s:check_buffer_all()"{{{
  let l:bufnumber = 1

  " Check buffer.
  while l:bufnumber <= bufnr('$')
    if bufloaded(l:bufnumber) && !has_key(s:include_info, l:bufnumber)
      call s:check_buffer(bufname(l:bufnumber))
    endif

    let l:bufnumber += 1
  endwhile
endfunction"}}}
function! s:check_buffer(bufname)"{{{
  let l:bufname = fnamemodify((a:bufname == '' ? bufname('%') : a:bufname), ':p')
  let l:bufnumber = bufnr(l:bufname)
  let s:include_info[l:bufnumber] = {}
  if (g:neocomplcache_disable_caching_buffer_name_pattern == '' || l:bufname !~ g:neocomplcache_disable_caching_buffer_name_pattern)
        \&& getbufvar(l:bufnumber, '&readonly') == 0
    let l:filetype = getbufvar(l:bufnumber, '&filetype')
    if l:filetype == ''
      let l:filetype = 'nothing'
    endif

    " Check include.
    let l:include_files = s:get_buffer_include_files(l:bufnumber)
    for l:filename in l:include_files
      if !has_key(s:include_cache, l:filename)
        " Caching.
        let s:include_cache[l:filename] = s:load_from_tags(l:filename, l:filetype)
      endif
    endfor

    let s:include_info[l:bufnumber].include_files = l:include_files
  else
    let s:include_info[l:bufnumber].include_files = []
  endif
endfunction"}}}
function! s:get_buffer_include_files(bufnumber)"{{{
  let l:filetype = getbufvar(a:bufnumber, '&filetype')
  if l:filetype == ''
    return []
  endif

  if l:filetype == 'python'
        \ && !has_key(g:neocomplcache_include_paths, 'python')
        \ && executable('python')
    " Initialize python path pattern.
    call neocomplcache#set_dictionary_helper(g:neocomplcache_include_paths, 'python',
          \ neocomplcache#system('python -', 'import sys;sys.stdout.write(",".join(sys.path))'))
  elseif l:filetype == 'cpp'
        \ && !neocomplcache#is_win()
    " Add cpp path.
    call neocomplcache#set_dictionary_helper(g:neocomplcache_include_paths, 'cpp',
          \ getbufvar(a:bufnumber, '&path') . ',/usr/include/c++/*')
  endif

  let l:pattern = has_key(g:neocomplcache_include_patterns, l:filetype) ? 
        \g:neocomplcache_include_patterns[l:filetype] : getbufvar(a:bufnumber, '&include')
  if l:pattern == ''
    return []
  endif
  let l:path = has_key(g:neocomplcache_include_paths, l:filetype) ? 
        \g:neocomplcache_include_paths[l:filetype] : getbufvar(a:bufnumber, '&path')
  let l:expr = has_key(g:neocomplcache_include_exprs, l:filetype) ? 
        \g:neocomplcache_include_exprs[l:filetype] : getbufvar(a:bufnumber, '&includeexpr')
  if has_key(g:neocomplcache_include_suffixes, l:filetype)
    let l:suffixes = &l:suffixesadd
  endif

  " Change current directory.
  let l:cwd_save = getcwd()
  if isdirectory(fnamemodify(bufname(a:bufnumber), ':p:h'))
    lcd `=fnamemodify(bufname(a:bufnumber), ':p:h')`
  endif

  let l:include_files = s:get_include_files(0, getbufline(a:bufnumber, 1, 100), l:filetype, l:pattern, l:path, l:expr)

  lcd `=l:cwd_save`

  " Restore option.
  if has_key(g:neocomplcache_include_suffixes, l:filetype)
    let &l:suffixesadd = l:suffixes
  endif

  return l:include_files
endfunction"}}}
function! s:get_include_files(nestlevel, lines, filetype, pattern, path, expr)"{{{
  let l:include_files = []
  for l:line in a:lines"{{{
    if l:line =~ a:pattern
      let l:match_end = matchend(l:line, a:pattern)
      if a:expr != ''
        let l:eval = substitute(a:expr, 'v:fname', string(matchstr(l:line[l:match_end :], '\f\+')), 'g')
        let l:filename = fnamemodify(findfile(eval(l:eval), a:path), ':p')
      else
        let l:filename = fnamemodify(findfile(matchstr(l:line[l:match_end :], '\f\+'), a:path), ':p')
      endif
      if filereadable(l:filename) && getfsize(l:filename) < g:neocomplcache_caching_limit_file_size
        call add(l:include_files, l:filename)

        if (a:filetype == 'c' || a:filetype == 'cpp') && a:nestlevel < 1
          let l:include_files += s:get_include_files(a:nestlevel + 1, readfile(l:filename)[:100],
                \a:filetype, a:pattern, a:path, a:expr)
        endif
      endif
    endif
  endfor"}}}

  return l:include_files
endfunction"}}}

function! s:load_from_tags(filename, filetype)"{{{
  " Initialize include list from tags.

  let l:keyword_lists = s:load_from_cache(a:filename)
  if !empty(l:keyword_lists) || getfsize(neocomplcache#cache#encode_name('include_cache', a:filename)) == 0
    return l:keyword_lists
  endif

  if !executable(g:neocomplcache_ctags_program)
    return s:load_from_file(a:filename, a:filetype)
  endif

  let l:args = has_key(g:neocomplcache_ctags_arguments_list, a:filetype) ? 
        \g:neocomplcache_ctags_arguments_list[a:filetype] : g:neocomplcache_ctags_arguments_list['default']
  let l:command = has('win32') || has('win64') ? 
        \printf('%s -f - %s %s', g:neocomplcache_ctags_program, l:args, fnamemodify(a:filename, ':p:.')) : 
        \printf('%s -f /dev/stdout 2>/dev/null %s %s', g:neocomplcache_ctags_program, l:args, fnamemodify(a:filename, ':p:.'))
  let l:lines = split(neocomplcache#system(l:command), '\n')

  if !empty(l:lines)
    " Save ctags file.
    call neocomplcache#cache#writefile('include_tags', a:filename, l:lines)
  endif

  let l:keyword_lists = {}

  for l:keyword in neocomplcache#cache#load_from_tags('include_cache', a:filename, l:lines, 'I', a:filetype)
    let l:key = tolower(l:keyword.word[: s:completion_length-1])
    if !has_key(l:keyword_lists, l:key)
      let l:keyword_lists[l:key] = []
    endif

    call add(l:keyword_lists[l:key], l:keyword)
  endfor 

  call neocomplcache#cache#save_cache('include_cache', a:filename, neocomplcache#unpack_dictionary(l:keyword_lists))

  if empty(l:keyword_lists)
    return s:load_from_file(a:filename, a:filetype)
  endif

  return l:keyword_lists
endfunction"}}}
function! s:load_from_file(filename, filetype)"{{{
  " Initialize include list from file.

  let l:keyword_lists = {}
  let l:loaded_list = neocomplcache#cache#load_from_file(a:filename, neocomplcache#get_keyword_pattern(), 'I')
  if len(l:loaded_list) > 300
    call neocomplcache#cache#save_cache('include_cache', a:filename, l:loaded_list)
  endif

  for l:keyword in l:loaded_list
    let l:key = tolower(l:keyword.word[: s:completion_length-1])
    if !has_key(l:keyword_lists, l:key)
      let l:keyword_lists[l:key] = []
    endif
    call add(l:keyword_lists[l:key], l:keyword)
  endfor"}}}

  return l:keyword_lists
endfunction"}}}
function! s:load_from_cache(filename)"{{{
  let l:keyword_lists = {}

  for l:keyword in neocomplcache#cache#load_from_cache('include_cache', a:filename)
    let l:keyword.dup = 1
    
    let l:key = tolower(l:keyword.word[: s:completion_length-1])
    if !has_key(l:keyword_lists, l:key)
      let l:keyword_lists[l:key] = []
    endif
    call add(l:keyword_lists[l:key], l:keyword)
  endfor 

  return l:keyword_lists
endfunction"}}}

" Global options definition."{{{
if !exists('g:neocomplcache_include_patterns')
  let g:neocomplcache_include_patterns = {}
endif
if !exists('g:neocomplcache_include_exprs')
  let g:neocomplcache_include_exprs = {}
endif
if !exists('g:neocomplcache_include_paths')
  let g:neocomplcache_include_paths = {}
endif
if !exists('g:neocomplcache_include_suffixes')
  let g:neocomplcache_include_suffixes = {}
endif
"}}}

" vim: foldmethod=marker
autoload/neocomplcache/sources/keyword_complete.vim	[[[1
96
"=============================================================================
" FILE: keyword_complete.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 20 Aug 2010
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:source = {
      \ 'name' : 'keyword_complete',
      \ 'kind' : 'complfunc',
      \}

function! s:source.initialize()"{{{
  " Set rank.
  call neocomplcache#set_dictionary_helper(g:neocomplcache_plugin_rank, 'keyword_complete', 5)
  
  " Set completion length.
  call neocomplcache#set_completion_length('keyword_complete', 0)
  
  " Initialize.
  for l:plugin in values(neocomplcache#available_plugins())
    call l:plugin.initialize()
  endfor
endfunction"}}}
function! s:source.finalize()"{{{
  for l:plugin in values(neocomplcache#available_plugins())
    call l:plugin.finalize()
  endfor
endfunction"}}}

function! s:source.get_keyword_pos(cur_text)"{{{
  let [l:cur_keyword_pos, l:cur_keyword_str] = neocomplcache#match_word(a:cur_text)
  if l:cur_keyword_pos < 0
    " Empty string.
    return len(a:cur_text)
  endif

  return l:cur_keyword_pos
endfunction"}}}

function! s:source.get_complete_words(cur_keyword_pos, cur_keyword_str)"{{{
  " Get keyword list.
  let l:cache_keyword_list = []
  for [l:name, l:plugin] in items(neocomplcache#available_plugins())
    if (has_key(g:neocomplcache_plugin_disable, l:name)
        \ && g:neocomplcache_plugin_disable[l:name])
        \ || len(a:cur_keyword_str) < neocomplcache#get_completion_length(l:name)
      " Skip plugin.
      continue
    endif
    
    try
      let l:list = l:plugin.get_keyword_list(a:cur_keyword_str)
    catch
      call neocomplcache#print_error(v:throwpoint)
      call neocomplcache#print_error(v:exception)
      call neocomplcache#print_error('Error occured in plugin''s get_keyword_list()!')
      call neocomplcache#print_error('Plugin name is ' . l:name)
      return []
    endtry
    
    let l:rank = has_key(g:neocomplcache_plugin_rank, l:name)? 
          \ g:neocomplcache_plugin_rank[l:name] : g:neocomplcache_plugin_rank['keyword_complete']
    for l:keyword in l:list
      let l:keyword.rank = l:rank
    endfor
    let l:cache_keyword_list += l:list
  endfor

  return l:cache_keyword_list
endfunction"}}}

function! neocomplcache#sources#keyword_complete#define()"{{{
  return s:source
endfunction"}}}

" vim: foldmethod=marker
autoload/neocomplcache/sources/omni_complete.vim	[[[1
253
"=============================================================================
" FILE: omni_complete.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 04 Sep 2010
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:source = {
      \ 'name' : 'omni_complete',
      \ 'kind' : 'complfunc',
      \}

function! s:source.initialize()"{{{
  " Initialize omni completion pattern."{{{
  if !exists('g:neocomplcache_omni_patterns')
    let g:neocomplcache_omni_patterns = {}
  endif
  "if has('ruby')
    "try 
      "ruby 1
      "call neocomplcache#set_dictionary_helper(g:neocomplcache_omni_patterns, 'ruby',
            "\'[^. *\t]\.\h\w*\|\h\w*::')
    "catch
    "endtry
  "endif
  if has('python')
    try 
      python 1
      call neocomplcache#set_dictionary_helper(g:neocomplcache_omni_patterns, 'python',
            \'[^. \t]\.\w*')
    catch
    endtry
  endif
  call neocomplcache#set_dictionary_helper(g:neocomplcache_omni_patterns, 'html,xhtml,xml,markdown',
        \'<[^>]*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_omni_patterns, 'css',
        \'^\s\+\w+\|\w+[):;]?\s\+\|[@!]')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_omni_patterns, 'javascript',
        \'[^. \t]\.\%(\h\w*\)\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_omni_patterns, 'actionscript',
        \'[^. \t][.:]\h\w*')
  "call neocomplcache#set_dictionary_helper(g:neocomplcache_omni_patterns, 'php',
        "\'[^. \t]->\h\w*\|\$\h\w*\|\%(=\s*new\|extends\)\s\+\|\h\w*::')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_omni_patterns, 'java',
        \'\%(\h\w*\|)\)\.')
  "call neocomplcache#set_dictionary_helper(g:neocomplcache_omni_patterns, 'perl',
  "\'\h\w*->\h\w*\|\h\w*::')
  "call neocomplcache#set_dictionary_helper(g:neocomplcache_omni_patterns, 'c',
        "\'\h\w\+\|\%(\h\w*\|)\)\%(\.\|->\)\h\w*')
  "call neocomplcache#set_dictionary_helper(g:neocomplcache_omni_patterns, 'cpp',
        "\'\h\w*\%(\.\|->\)\h\w*\|\h\w*::')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_omni_patterns, 'vimshell',
        \'\%(\\[^[:alnum:].-]\|[[:alnum:]@/.-_+,#$%~=*]\)\{2,}')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_omni_patterns, 'objc',
        \'\h\w\+\|\h\w*\%(\.\|->\)\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_omni_patterns, 'objj',
        \'[\[ \.]\w\+$\|:\w*$')
  "}}}
  
  " Initialize omni function list."{{{
  if !exists('g:neocomplcache_omni_functions')
    let g:neocomplcache_omni_functions = {}
  endif
  "}}}

  " Set rank.
  call neocomplcache#set_dictionary_helper(g:neocomplcache_plugin_rank, 'omni_complete', 100)
  
  " Set completion length.
  call neocomplcache#set_completion_length('omni_complete', 0)
endfunction"}}}
function! s:source.finalize()"{{{
endfunction"}}}

function! s:source.get_keyword_pos(cur_text)"{{{
  if neocomplcache#within_comment()
    return -1
  endif

  let l:filetype = neocomplcache#get_context_filetype()
  if neocomplcache#is_eskk_enabled()
    let l:omnifunc = &l:omnifunc
  elseif has_key(g:neocomplcache_omni_functions, l:filetype)
    let l:omnifunc = g:neocomplcache_omni_functions[l:filetype]
  elseif &filetype == l:filetype
    let l:omnifunc = &l:omnifunc
  else
    " &omnifunc is irregal.
    return -1
  endif

  if l:omnifunc == ''
    return -1
  endif
  
  if has_key(g:neocomplcache_omni_patterns, l:omnifunc)
    let l:pattern = g:neocomplcache_omni_patterns[l:omnifunc]
  elseif l:filetype != '' && has_key(g:neocomplcache_omni_patterns, l:filetype)
    let l:pattern = g:neocomplcache_omni_patterns[l:filetype]
  else
    let l:pattern = ''
  endif

  if !neocomplcache#is_eskk_enabled() && l:pattern == ''
    return -1
  endif

  let l:is_wildcard = g:neocomplcache_enable_wildcard && a:cur_text =~ '\*\w\+$'
        \&& neocomplcache#is_auto_complete()

  " Check wildcard.
  if l:is_wildcard
    " Check wildcard.
    let l:cur_text = a:cur_text[: match(a:cur_text, '\%(\*\w\+\)\+$') - 1]
  else
    let l:cur_text = a:cur_text
  endif

  if !neocomplcache#is_eskk_enabled()
        \ && l:cur_text !~ '\%(' . l:pattern . '\m\)$'
    return -1
  endif

  " Save pos.
  let l:pos = getpos('.')
  let l:line = getline('.')

  if neocomplcache#is_auto_complete() && l:is_wildcard
    call setline('.', l:cur_text)
  endif

  try
    let l:cur_keyword_pos = call(l:omnifunc, [1, ''])
  catch
    call neocomplcache#print_error(v:exception)
    let l:cur_keyword_pos = -1
  endtry

  " Restore pos.
  if neocomplcache#is_auto_complete() && l:is_wildcard
    call setline('.', l:line)
  endif
  call setpos('.', l:pos)

  return l:cur_keyword_pos
endfunction"}}}

function! s:source.get_complete_words(cur_keyword_pos, cur_keyword_str)"{{{
  let l:is_wildcard = g:neocomplcache_enable_wildcard && a:cur_keyword_str =~ '\*\w\+$'
        \&& neocomplcache#is_eskk_enabled() && neocomplcache#is_auto_complete()

  let l:filetype = neocomplcache#get_context_filetype()
  if neocomplcache#is_eskk_enabled()
    let l:omnifunc = &l:omnifunc
  elseif has_key(g:neocomplcache_omni_functions, l:filetype)
    let l:omnifunc = g:neocomplcache_omni_functions[l:filetype]
  elseif &filetype == l:filetype
    let l:omnifunc = &l:omnifunc
  endif

  let l:pos = getpos('.')
  if l:is_wildcard
    " Check wildcard.
    let l:cur_keyword_str = a:cur_keyword_str[: match(a:cur_keyword_str, '\%(\*\w\+\)\+$') - 1]
  else
    let l:cur_keyword_str = a:cur_keyword_str
  endif

  try
    if l:filetype == 'ruby' && l:is_wildcard
      let l:line = getline('.')
      let l:cur_text = neocomplcache#get_cur_text()
      call setline('.', l:cur_text[: match(l:cur_text, '\%(\*\w\+\)\+$') - 1])
    endif

    let l:list = call(l:omnifunc, [0, (l:filetype == 'ruby')? '' : l:cur_keyword_str])

    if l:filetype == 'ruby' && l:is_wildcard
      call setline('.', l:line)
    endif
  catch
    call neocomplcache#print_error(v:exception)
    let l:list = []
  endtry
  call setpos('.', l:pos)

  if empty(l:list)
    return []
  endif

  if l:is_wildcard
    let l:list = neocomplcache#keyword_filter(s:get_omni_list(l:list), a:cur_keyword_str)
  else
    let l:list = s:get_omni_list(l:list)
  endif

  return l:list
endfunction"}}}

function! neocomplcache#sources#omni_complete#define()"{{{
  return s:source
endfunction"}}}

function! s:get_omni_list(list)"{{{
  let l:omni_list = []

  " Convert string list.
  for str in filter(copy(a:list), 'type(v:val) == '.type(''))
    let l:dict = { 'word' : str, 'menu' : '[O]' }

    call add(l:omni_list, l:dict)
  endfor

  for l:omni in filter(a:list, 'type(v:val) != '.type(''))
    let l:dict = {
          \'word' : l:omni.word, 'menu' : '[O]',
          \'abbr' : has_key(l:omni, 'abbr')? l:omni.abbr : l:omni.word,
          \}

    if has_key(l:omni, 'kind')
      let l:dict.kind = l:omni.kind
    endif

    if has_key(l:omni, 'menu')
      let l:dict.menu .= ' ' . l:omni.menu
    endif

    call add(l:omni_list, l:dict)
  endfor

  return l:omni_list
endfunction"}}}

" vim: foldmethod=marker
autoload/neocomplcache/sources/snippets_complete/_.snip	[[[1
56
# Global snippets

snippet     date
    `strftime("%d %b %Y")`

snippet     date_full
alias       df
    `strftime("%Y-%m-%dT%H:%M:%S")`

snippet     date_day
alias       dd
    `strftime("%Y-%m-%d")`

snippet     date_time
alias       dt
    `strftime("%H:%M:%S")`

snippet     register*
    `@*`

snippet     register+
    `@+`

snippet     register"
    `@"`

snippet     register0
    `@0`

snippet     register1
    `@1`

snippet     register2
    `@2`

snippet     register3
    `@3`

snippet     register4
    `@4`

snippet     register5
    `@5`

snippet     register6
    `@6`

snippet     register7
    `@7`

snippet     register8
    `@8`

snippet     register9
    `@9`

autoload/neocomplcache/sources/snippets_complete/actionscript.snip	[[[1
273
snippet ec 
    #endinitclip


snippet inc
    #include "${1}"


snippet br
    break;


snippet ca
    call(${1:frame});


snippet case
abbr ce
	case ${1:expression} :
		${1:statement}


snippet catch
abbr ch
	catch ($1) {
		$2
	}
    

snippet class
	class ${1:ClassName} {
		var _${2};
		function ${1}(${2}){
			_${2} = ${2};${0}
		}
	}
	    
    
snippet co
    continue;


snippet dt
	default :
		${1:statement}


snippet de
    delete ${1};


snippet do
	do {
		${1}
	} while (${2:condition});
    

snippet dm
    duplicateMovieClip(${1:target}, ${2:newName}, ${3:depth});


snippet ei
	else if (${1}) {
		${2}
	}


snippet fori
abbr fi
	for ( var ${1} in ${2} ){
		${3}
	};


snippet for
abbr fr
	for ( var ${1}=0; ${1}<${3}.length; ${1}++ ) {
		${4}
	};


snippet fs
    fscommand(${1:command}, ${2:paramaters});


snippet fn
	function ${1}(${2}):${3}{
		${4}
	};
    

snippet gu
    getURL(${1});


snippet gp
    gotoAndPlay(${1});


snippet gs
	gotoAndStop(${1});

snippet if
	if (${1}) {
		${2}
	}
    

snippet il
	ifFrameLoaded (${1}) {
		${2}
	}
	    

snippet ip
    import ${1};


snippet it
    interface ${1}{
    	${2}
    }


snippet lm
	loadMovie( ${1:url}, ${2:target}, ${3:method});


snippet ln
	loadMovieNum( ${1:url}, ${2:level}, ${3:method});
    
    
snippet lv
    loadVariables( ${1:url}, ${2:target}, ${3:method});


snippet vn
    loadVariables( ${1:url}, ${2:level}, ${3:method});


snippet mc
    MovieClip


snippet nf
    nextFrame();


snippet ns
    nextScene();


snippet on
    on (${1}) {
    	${2}
    };


snippet  oc
	onClipEvent (${1}) {
		${2}
	};
    

snippet pl
    play();


snippet pf
    pravFrame();


snippet ps
    prevScene();


snippet pr
    print( ${1:target}, ${2:type} );


snippet bn
    printAsBitmapNum( ${1:level}, ${2:type} );


snippet pn
    printNum( ${1:level}, ${2:type} );


snippet rm
    removeMovieClip( ${1:target} );


snippet rt
    return ${1};


snippet sp
    setProperty( ${1:target}, ${2:property}, ${3:value} );


snippet sv
    set( ${1:name}, ${2:value} );


snippet dr
    startDrag(${1:target}, ${2:lockcenter}, ${3:l}, ${4:t}, ${5:r}, ${6:b} );


snippet st
    stop();


snippet ss
    stopAllSounds();


snippet sd
    stopDrag();


snippet sw
	switch ( ${1:condition} ) {
		${2}
	}
    

snippet tt
	tellTarget( ${1:target} ) {
		${2}
	}
	    

snippet th
    throw ${1};


snippet tq
    toggleHighQuality();


snippet tr
    trace(${1:"$0"});


snippet ty
	try {
		${1}
	};
    

snippet um
    unloadMovie(${1:target});


snippet un
    unloadMovieNum(${1:level});


snippet vr
    var ${1}:${2};


snippet wh
	while (${1:condition}) {
		${2}
	};


snippet wt
	with (${1:target});
		${2}
	};
    
autoload/neocomplcache/sources/snippets_complete/apache.snip	[[[1
23
snippet allow
    AllowOverride ${1:AuthConfig} ${2:FileInfo} ${3:Indexes} ${4:Limit} ${5:Options}


snippet opt
    Options ${1:All} ${2:ExecCGI} ${3:FollowSymLinks} ${4:Includes} ${5:IncludesNOEXEC} ${6:Indexes} ${7:MultiViews} ${8:SymLinksIfOwnerMatch}


snippet vhost
	<VirtualHost ${1:example.org}>
		ServerAdmin webmaster@${1}
		DocumentRoot /www/vhosts/${1}
		ServerName ${1}
		ErrorLog logs/${1}-error_log
		CustomLog logs/${1}-access_log common
	</VirtualHost>
    

snippet dir
	<Directory ${1:/Library/WebServer/}>
		${0}
	</Directory>
    
autoload/neocomplcache/sources/snippets_complete/applescript.snip	[[[1
201
snippet script
	script ${1:new_object}
		on run
			${2:-- do something interesting}
		end run
	end script


snippet on
	on ${1:functionName}(${2:arguments})
		${3:-- function actions}
	end ${1}


snippet tell
	tell ${1:app}
		${0:-- insert actions here}
	end tell
    
snippet terms
	using terms from ${1:app}
		${0:-- insert actions here}
	end using terms from


snippet if
	if ${1:true} then
		${0:-- insert actions here}
	end if


snippet rept
abbr rep
	repeat ${1} times}
		${0:-- insert actions here}
	end repeat


snippet repwh
abbr rep
	repeat while ${1:condition}
		${0}
	end repeat
	    

snippet repwi
abbr rep
	repeat with ${1} in ${2}
		${0}
	end repeat
    

snippet try
	try
		${0:-- actions to try}
	on error
		-- error handling
	end try
	    <D-c>
	    

snippet timeout
	with timeout ${1:number} seconds
		${0:-- insert actions here}
	end timeout


snippet con
	considering ${1:case}
		${0:-- insert actions here}
	end considering
    
    
snippet ign
	ignoring ${1:application responses}
		${0:-- insert actions here}
	end ignoring
   

snippet shell
	${1:set shell_stdout to }do shell script ${3:"${2:#script}"} 
		without altering line endings
	${0}
    


snippet delim
	set oldDelims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to {"${1:,}"}
	${0:-- insert actions here}
	set AppleScript's text item delimiters to oldDelims


snippet parent
    prop parent : app "${1}"


snippet alert
	display alert "${1:alert text}" 
		${2:message} "${3:message text}" 
		${4:as warning}
	    

snippet dialog_OK
abbr dialog
	display dialog "${1:text}" 
		${2:with icon} ${3:1} 
		buttons {"${4:OK}"} default button 1


snippet dialog_OK/Cancel
abbr dialog
	display dialog "${1:text}" 
		${2:with icon} 
		buttons {"${3:Cancel}", "${4:OK}"} 
		default button "${4}"
	set button_pressed to button returned of result
	if button_pressed is "${4}" then
		${5:-- action for default button button goes here}
	else
		-- action for cancel button goes here
	end if
    
    
snippet dialog_OK/Cancel/Other
abbr dialog
	display dialog "${1:text}" 
		${2:with icon} 
		buttons {"${3:Cancel}", "${4:Other Choice}", "${5:OK}"} 
		default button "${5}"
	set button_pressed to button returned of result
	if button_pressed is "${5}" then
		${6:-- action for default button button goes here}
	else if button_pressed is "${3}" then
		-- action for cancel button goes here
	else
		-- action for other button goes here
	end if
    

snippet dialog_TextFierld
abbr dialog
	set the_result to display dialog "${1:text}" 
		default answer "${2:type here}" 
		${3:with icon}  
		buttons {"${4:Cancel}", "${5:OK}"} 
		default button "${5}"
	set button_pressed to button returned of the_result
	set text_typed to text returned of the_result
	if button_pressed is "${5}" then
		${6:-- action for default button button goes here}
	else
		-- action for cancel button goes here
	end if
    

snippet choose_Applications
abbr choose
	${1:set the_application to }choose application with prompt "${2:Choose an application:}"${3:with multiple selections allowed}
    

snippet choose_Files
abbr choose
	${1:set the_file to }choose file with prompt "${2:Pick a file:}"
	${3:default location path to home folder}
	${4:with invisibles}
	${5:with multiple selections allowed}
	${6:with showing package contents}


snippet choose_Folders
abbr choose
	${1:set the_folder to }choose folder with prompt "${2:Pick a folder:}"
	${3:default location path to home folder}
	${4:with invisibles}
	${5:with multiple selections allowed}
	${6:with showing package contents}
	${0}

    

snippet choose_NewFile
abbr choose
	${1:set the_filename to }choose file name with prompt "${2:Name this file:}" 
		default name "${3:untitled}" default location ${4:path to home folder}


snippet choose_URL
abbr choose
	${1:set the_url to }choose URL showing ${2:Web} servers with editable URL
    

snippet choose_Color
abbr choose
	${1:set the_color to }choose color default color ${2:{65536, 65536, 65536\}}
    

snippet choose_ItemFromList
abbr choose
	set the_choice to choose from list ${1}"\}}
    
autoload/neocomplcache/sources/snippets_complete/c.snip	[[[1
124
snippet     if
abbr        if () {}
    if (${1:/* condition */}) {
        ${0:/* code */}
    }

snippet else
    else {
        ${0}
    }

snippet elseif
    else if (${1:/* condition */}) {
        ${0}
    }

snippet     ifelse
abbr        if () {} else {}
    if (${1:condition}) {
        ${2}
    } else {
        ${3}
    }

snippet     for
abbr        for () {}
    for (${1} = 0; $1 < ${2}; $1++) {
        ${0}
    }

snippet     while
abbr        while () {}
    while (${1:/* condition */}) {
        ${0:/* code */}
    }

snippet     do_while
    do {
        ${0:/* code */}
    } while (${1:/* condition */});

snippet     switch
abbr        switch () {}
    switch (${1:var}) {
        case ${2:val}:
            ${0}
            break;
    }

snippet     function
abbr        func() {}
    ${1:void} ${2:func_name}(${3}) {
        ${0}
    }

snippet     struct
abbr        struct {}
    struct ${1:name} {
        ${0:/* data */}
    };

# Typedef struct
snippet struct_typedef
    typedef struct ${1:name}{
        ${0:/* data */}
    };

snippet     enum
abbr        enum {}
    enum ${1:name} {
        ${0}
    };

# main function.
snippet main
    int main(int argc, char const* argv[])
    {
        ${0}
        return 0;
    }

# #include <...>
snippet inc
    #include <${1:stdio}.h>${0}
# #include "..."
snippet Inc
    #include "${1:}.h"${0}

snippet Def
abbr #ifndef ... #define ... #endif
    #ifndef $1
    #define ${1:SYMBOL} ${2:value}
    #endif${0}

snippet def
    #define 

# Include-Guard
snippet once
abbr include-guard
    #ifndef ${1:SYMBOL}
        #define $1

        ${0}
    #endif /* end of include guard */

# Tertiary conditional
snippet conditional
    (${1:/* condition */})? ${2:a} : ${3:b}

# Typedef
snippet typedef
    typedef ${1:base_type} ${2:custom_type};

snippet printf
    printf("${1}\n"${2});${0}

snippet fprintf
    fprintf(${1:stderr}, "${2}\n"${3});${0}

snippet comment
alias /*
    /* ${1:comment} */
    ${0}
autoload/neocomplcache/sources/snippets_complete/cpp.snip	[[[1
20
include c

snippet     template
abbr        template <T>
    template<typename ${1:T}> 

snippet     class
abbr        class {}
    class ${1:name} {
        ${2}
    };

snippet     try
abbr        try catch
    try {
        ${1}
    } catch (${2:exception}) {
        ${3}
    }

autoload/neocomplcache/sources/snippets_complete/css.snip	[[[1
252
snippet	background
alias	bg
    background:${1};${2}
snippet	backattachment
alias	ba
    background-attachment:${1};${2}

snippet	backcolor
alias	bc
    background-color:${1};${2}

snippet	backimage
alias	bi
    background-image:${1};${2}

snippet	backposition
alias	bp
    background-position:${1};${2}

snippet	backrepeat
alias	br
    background-repeat:${1};${2}



snippet	border
alias	b
    border:${1};${2}

snippet	border-style
alias	bs
    border-style:${1};${2}

snippet	border-color
alias	bc
    border-color:${1};${2}

snippet	border-width
alias	bw
    border-width:${1};${2}

snippet	border-bottom-width
alias	bbw
    border-bottom-width:${1};${2}

snippet	border-top-width
alias	btw
    border-top-width:${1};${2}

snippet	border-left-width
alias	blw
    border-left-width:${1};${2}
snippet	border-right-width
alias	brw
    border-right-width:${1};${2}


snippet	border-bottom-style
alias	bbs
    border-bottom-style:${1};${2}

snippet	border-top-style
alias	bts
    border-top-style:${1};${2}

snippet	border-left-style
alias	bls
    border-left-style:${1};${2}
snippet	border-right-style
alias	brs
    border-right-style:${1};${2}


snippet	border-bottom-color
alias	bbc
    border-bottom-color:${1};${2}

snippet	border-top-color
alias	btc
    border-top-color:${1};${2}

snippet	border-left-color
alias	blc
    border-left-color:${1};${2}
snippet	border-right-color
alias	brc
    border-right-color:${1};${2}

snippet	outline
alias	ol
    outline:${1};${2}

snippet	outline-color
alias	oc
    outline-color:${1};${2}

snippet	outline-style
alias	os
    outline-style:${1};${2}

snippet	outline-width
alias	ow
    outline-width:${1};${2}

snippet	color
alias	c
    color:${1};${2}

snippet	direction
alias	d
    direction:${1};${2}

snippet	letter-spacing
alias	ls
    letter-spacing:${1};${2}

snippet	line-height
alias	lh
    line-height:${1};${2}

snippet	text-align
alias	ta
    text-align:${1};${2}

snippet	text-decoration
alias	td
    text-decoration:${1};${2}

snippet	text-indent
alias	ti
    text-indent:${1};${2}

snippet	text-transform
alias	tt
    text-transform:${1};${2}

snippet	unicode-bidi
alias	ub
    unicode-bidi:${1};${2}

snippet	white-space
alias	ws
    white-space:${1};${2}

snippet	word-spacing
alias	ws
    word-spacing:${1};${2}

snippet	font
alias	f
    font:${1};${2}

snippet	font-family
alias	ff
    font-family:${1:"Times New Roman",Georgia,Serif};${2}

snippet	font-size
alias	fs
    font-size:${1};${2}

snippet	font-style
alias	fs
    font-style:${1};${2}

snippet	font-weight
alias	fw
    font-weight:${1};${2}

snippet	margin
alias	m
    margin:${1};${2}

snippet	margin-bottom
alias	mb
    margin-bottom:${1};${2}

snippet	margin-top
alias	mt
    margin-top:${1};${2}

snippet	margin-left
alias	ml
    margin-left:${1};${2}

snippet	margin-right
alias	mr
    margin-right:${1};${2}

snippet	padding
alias	p
    padding:${1};${2}

snippet	padding-bottom
alias	pb
    padding-bottom:${1};${2}

snippet	padding-top
alias	pt
    padding-top:${1};${2}

snippet	padding-left
alias	pl
    padding-left:${1};${2}

snippet	padding-right
alias	pr
    padding-right:${1};${2}

snippet	list-style
alias	ls
    list-style:${1};${2}

snippet	list-style-image
alias	lsi
    list-style-image:${1};${2}

snippet	list-style-position
alias	lsp
    list-style-position:${1};${2}

snippet	list-style-type
alias	lst
    list-style-type:${1};${2}

snippet	content
alias	c
    content:${1};${2}

snippet	height
alias	h
    height:${1};${2}

snippet	max-height
alias	mah
    max-height:${1};${2}

snippet	max-width
alias	maw
    max-width:${1};${2}

snippet	min-height
alias	mih
    min-height:${1};${2}

snippet	min-width
alias	miw
    min-width:${1};${2}

snippet	width
alias	w
    width:${1};${2}

autoload/neocomplcache/sources/snippets_complete/d.snip	[[[1
38
include c

# Delete snippet depended on C.
delete struct
delete struct_typedef
delete enum
delete main
delete inc
delete Inc
delete Def
delete def
delete once
delete printf
delete fprintf

snippet     foreach
abbr        foreach() {}
    foreach (${1:var}; ${2:list}) {
        ${3}
    }

snippet     class
abbr        class {}
    class ${1:name} {
        ${2}
    }

snippet     struct
abbr        struct {}
    struct ${1:name} {
        ${2}
    }

snippet     enum
abbr        enum {}
    enum ${1:name} {
        ${2}
    }
autoload/neocomplcache/sources/snippets_complete/eruby.snip	[[[1
19
snippet     ruby_print
abbr        <%= %>
    <%= ${1:Ruby print code} %>${2}

snippet     ruby_code
abbr        <% %>
    <% ${1:Ruby code} %>${2}

snippet     ruby_print_nonl
abbr        <%= -%>
    <%= ${1:Ruby print code} -%>${2}

snippet     ruby_code_nonl
abbr        <% -%>
    <% ${1:Ruby code} -%>${2}

snippet     comment
abbr        <%# %>
    <%# ${1:Comment} %>${2}
autoload/neocomplcache/sources/snippets_complete/java.snip	[[[1
274
snippet pu
    public


snippet po
    protected


snippet pr
    private


snippet st
    static


snippet fi
    final


snippet ab
    abstract


snippet cl
	class ${1} ${2:extends} ${3:Parent} ${4:implements} ${5:Interface} {
		${0}
	}


snippet in
	interface ${1} ${2:extends} ${3:Parent} {
		${0}
	}


snippet m
	${1:void} ${2:method}(${3}) ${4:throws} {
		${0}
	}
    

snippet v
    ${1:String} ${2:var}${3};


snippet co
    static public final ${1:String} ${2:var} = ${3};${4}


snippet cos
    static public final String ${1:var} = "${2}";${4}


snippet re
    return


snippet as
    assert ${1:test} ${2:Failure message};${3}


snippet if
	if (${1}) {
		${2}
	}

snippet elif
	else if (${1}) {
		${2}
	}
    

snippet wh
	while (${1}) {
		${2}
	}
    

snippet for
	for (${1}; ${2}; ${3}) {
		${4}
	}
	    
	    
snippet fore
	for (${1} : ${2}) {
	${3}
}


snippet sw
	switch (${1}) {
		${2}
	}
    
    
snippet case
abbr ce
	case ${1}:
		${2}
	${0}
	    

snippet br
    break;


snippet de
	default:
		${0}


snippet ca
	catch (${1:Exception} ${2:e}) {
		${0}
	}
    
    
snippet th
    throw ${0}


snippet sy
    synchronized


snippet im
    import


snippet pa
    package


snippet tc
	public class ${1} extends ${2:TestCase} {
		${0}
	}
    

snippet test
	public void test${1:Name}() throws Exception {
		${0}
	}
    

snippet imt
	import junit.framework.TestCase;
	${0}
    

snippet j.u
    java.util.


snippet j.i
    java.io.


snippet j.b
    java.beans.


snippet j.n
    java.net


snippet j.m
    java.math.


snippet main
	public static void main(String[] args) {
		${0}
	}
    

snippet pl
    System.out.println(${1});${0}


snippet p
    System.out.print(${1});${0}


#javadoc
snippet c
	/**
	 * ${0}
	 */
    

snippet a
    @author ${0:$TM_FULLNAME}


snippet {code
abbr {
    {@code ${0}


snippet d
    @deprecated ${0:description}


snippet {docRoot
abbr {
    {@docRoot


snippet {inheritDoc
abbr {
    {@inheritDoc


snippet {link
abbr {
    {@link ${1:target} ${0:label}


snippet {linkplain
abbr {
    {@linkplain ${1:target} ${0:label}


snippet {literal
abbr {
    {@literal ${0}


snippet param
    @param ${1:var} ${0:description}


snippet r
    @return ${0:description}


snippet s
    @see ${0:reference}


snippet se
    @serial ${0:description}


snippet sd
    @serialField ${0:description}


snippet sf
    @serialField ${1:name} ${2:type} ${0:description}


snippet si
    @since ${0:version}


snippet t
    @throws ${1:class} ${0:description}


snippet {value
abbr {
    {@value ${0}


snippet ver
    @version ${0:version}


snippet null
    {@code null}
autoload/neocomplcache/sources/snippets_complete/javascript.snip	[[[1
47
snippet :f 
	${1:method_name}: function(${2:attribute}){
		${0}
	}


snippet func
	function ${1:function_name} (${2:argument}) {
		${0:// body...}
	}


snippet proto
	${1:class_name}.prototype.${2:method_name} = function(${3:first_argument}) {
		${0:// body...}
	};
    

snippet f
    function(${1}) {${0:$TM_SELECTED_TEXT}};


snippet if
    if (${1:true}) {${0:$TM_SELECTED_TEXT}};


snippet ife
    if (${1:true}) {${0:$TM_SELECTED_TEXT}} else{};


snippet for
	for (var ${2:i}=0; ${2:i} < ${1:Things}.length; ${2:i}++) {
		${0}
	};
    
    
snippet ;,
    ${1:value_name}:${0:value},


snippet key
    ${1:key}: "${2:value}"}${3:, }


snippet timeout
    setTimeout(function() {${0}}${2:}, ${1:10});

autoload/neocomplcache/sources/snippets_complete/markdown.snip	[[[1
51
snippet link
abbr [link][]
    [${1:link_id}][]${2}
snippet linkid
abbr [link][id]
    [${1:link}][${2:id}]${3}
snippet linkurl
abbr [link](url)
    [${1:link}](http://${2:url})${3}
snippet linkemail
abbr [link](email)
    [${1:link}](mailto:${2:email})${3}
snippet linkurltitle
abbr [link](url "title")
    [${1:link}](${2:url} "${3:title}")${4}

snippet idurl
abbr [id]: url "title"
    [${1:id}]: http://${2:url} "${3:title}"
snippet idemail
abbr [id]: email "title"
    [${1:id}]: mailto:${2:url} "${3:title}"

snippet altid
abbr ![alt][id]
    ![${1:alt}][${2:id}]${3}
snippet alturl
abbr ![alt](url)
    ![${1:alt}](${2:url})${3}
snippet alturltitle
abbr ![alt](url "title")
    ![${1:alt}](${2:url} "${3:title}")${4}

snippet emphasis1
abbr *emphasis*
    *${1}*${2}
snippet emphasis2
abbr _emphasis_
    _${1}_${2}

snippet strong1
abbr **strong**
    **${1}**${2}

snippet strong2
abbr __strong__
    __${1}__${2}

snippet code
abbr `code`
    `${1}`${2}
autoload/neocomplcache/sources/snippets_complete/objc.snip	[[[1
352
snippet sel
    @selector(${1:method}:)


snippet imp
    #import <${1:Cocoa/Cocoa.h}>


snippet Imp
    #import "${1}}"


snippet log
abbr NSLog(...)
    NSLog(@"${1}")


snippet cl
abbr Class
	@interface ${1} : ${2:NSObject}
	{
	}
	@end
	
	@implementation ${1}
	- (id)init
	{
		if((self = [super init]))
		{${0}
		}
		return self;
	}
	@end
    

snippet cli
abbr ClassInterface
	@interface ${1} : ${2:NSObject}
	{${3}
	}
	${0}
	@end
    

snippet clm
abbr ClassImplementation
	@implementation ${1:object}
	- (id)init
	{
		if((self = [super init]))
		{${0}
		}
		return self;
	}
	@end
    

snippet cat
abbr Category
	@interface ${1:NSObject} (${2:Category})
	@end
	
	@implementation ${1} (${2})
	${0}
	@end
    

snippet cati
abbr CategoryInterface
	@interface ${1:NSObject)} (${2:Category)})
	${0}
	@end
    

snippet array
    NSMutableArray *${1:array} = [NSMutableArray array];


snippet dict
    NSMutableDictionary *${1:dict} = [NSMutableDictionary dictionary];


snippet bez
	NSBezierPath *${1:path} = [NSBezierPath bezierPath];
	${0}
    

snippet m
abbr Method
	- (${1:id})${2:method}${3:(id)}${4:anArgument}
	{
    	${0}
		return nil;
	}
    

snippet M
abbr Method
    - (${1:id})${2:method}${3:(id)}${4:anArgument};


snippet cm
abbr ClassMethod
	+ (${1:id})${2:method}${3:(id)}${4:anArgument}
	{
    	${0}
		return nil;
	}


snippet icm
abbr InterfaceClassMethod
    + (${1:id})${0:method};


snippet sm
abbr SubMethod
	- (${1:id})${2:method}${3:(id)}${4:anArgument}
	{
		${1} res = [super ${2:method}]
		return res;
	}


snippet mi
abbr MethodInitialize
	+ (void)initialize
	{
		[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
			${0}@"value", @"key",
			nil]];
	}
    

snippet obj
	- (${1:id})${2:thing}
	{
		return ${2};
	}
	
	- (void)set${2}:(${1})aValue
	{
		${0}${1}old${2} = ${2};
		${2} = [aValue retain];
		[old${2} release];
	}


snippet iobj
	- (${1:id})${2:thing};
	- (void)set${2}:(${1})aValue;
    

snippet str
	- (NSString${$1: *)})${1:thing}
	{
		return ${2};
	}
	
	- (void)set${1}:(NSString${2: *})${3}
	{
		${3} = [${3} copy];
		[${2} release];
		${2} = ${3};
	}
    

snippet istr
	- (NSString${1: *)}${1:thing};
	- (void)set${1}:(NSString${2: *})${2};
    

snippet cd
abbr CoreData
	- (${1:id})${2:attribute}
	{
		[self willAccessValueForKey:@"${2: attribute}"];
		${1:id} value = [self primitiveValueForKey:@"${2: attribute}"];
		[self didAccessValueForKey:@"${2: attribute}"];
		return value;
	}
	
	- (void)set${2}:(${1})aValue
	{
		[self willChangeValueForKey:@"${2: attribute}"];
		[self setPrimitiveValue:aValue forKey:@"${2: attribute}"];
		[self didChangeValueForKey:@"${2: attribute}"];
	}
    

snippet karray
abbr KVCArry
	- (void)addObjectTo${1:Things}:(${2:id})anObject
	{
		[${3}} addObject:anObject];
	}
	
	- (void)insertObject:(${2})anObject in${1}AtIndex:(unsigned int)i 
	{
		[${3} insertObject:anObject atIndex:i];
	}
	
	- (${2})objectIn${1}AtIndex:(unsigned int)i
	{
		return [${3} objectAtIndex:i];
	}
	
	- (unsigned int)indexOfObjectIn${1}:(${2})anObject
	{
		return [${3} indexOfObject:anObject];
	}
	
	- (void)removeObjectFrom${1}AtIndex:(unsigned int)i
	{
		 [${3} removeObjectAtIndex:i]; 
	}
	
	- (unsigned int)countOf${1}
	{
		return [${3} count];
	}
	
	- (NSArray${4: *}${1}
	{
		return ${3}
	}
	
	- (void)set${1}:(NSArray${4: *})new${1}
	{
		[${3} setArray:new${1}];
	}
    

snippet iarray
abbr InterfaceAccessorsForKVCArray
	- (void)addObjectTo${1:Things}:(${2:id})anObject;
	- (void)insertObject:(${2})anObject in${1}AtIndex:(unsigned int)i;
	- (${2})objectIn${1}AtIndex:(unsigned int)i;
	- (unsigned int)indexOfObjectIn${1}:(${2})anObject;
	- (void)removeObjectFrom${1}AtIndex:(unsigned int)i;
	- (unsigned int)countOf${1};
	- (NSArray${3: *})${1};
	- (void)set${1}:(NSArray${3: *})new${1};


snippet acc
abbr PrimitiveType
	- (${1:unsigned int})${2:thing}
	{
		return ${3};
	}
	
	- (void)set${2}:(${1:unsigned int})new${2}
	{
		${3} = new${2};
	}


snippet iacc
abbr Interface:AccessorsForPrimitiveType
	- (${1:unsigned int})${2:thing};
	- (void)set${2}:($1)new${2};
    

snippet rdef
abbr ReadDefaultsValue
    [[NSUserDefaults standardUserDefaults] objectForKey:${1:key}];


snippet wdef
abbr WriteDefaultsValue
    [[NSUserDefaults standardUserDefaults] setObject:${1:object} forKey:${2:key}];


snippet ibo
abbr IBOutlet
    IBOutlet ${1}${2: *}${3};


snippet syn
    @synthesize ${1:property};


snippet bind
    bind:@"${2:binding}" toObject:${3:observableController} withKeyPath:@"${4:keyPath}" options:${5:nil}


snippet reg
    [[NSNotificationCenter defaultCenter] addObserver:${1:self} selector:@selector(${3}) name:${2:NSWindowDidBecomeMainNotification} object:${4:nil}];


snippet focus
	[self lockFocus];
	${0}
	[self unlockFocus];
    

snippet forarray
	unsigned int	${1:object}Count = [${2:array} count];
	
	for(unsigned int index = 0; index < ${1}Count; index += 1)
	{
		${3:id}	${1} = [${2} objectAtIndex:index];
		${0}
	}
    

snippet alert
	int choice = NSRunAlertPanel(@"${1:Something important!}", @"${2:Something important just happend, and now I need to ask you, do you want to continue?}", @"${3:Continue}", @"${4:Cancel}", nil);
	if(choice == NSAlertDefaultReturn) // "${3:Continue}"
	{
		${0};
	}
	else if(choice == NSAlertAlternateReturn) // "${4:Cancel}"
	{
		
	}
    

snippet res
	${1} Send ${2} to ${1}, if ${1} supports it}${3}
	if ([${1:self} respondsToSelector:@selector(${2:someSelector:})])
	{
	    [${1} ${3}];
	}
    

snippet del
	if([${1:[self delegate]} respondsToSelector:@selector(${2:selfDidSomething:})])
		[${1} ${3}];


snippet format
   [NSString stringWithFormat:@"${1}", ${2}]${0} 


snippet save
	[NSGraphicsContext saveGraphicsState];
	${0}
	[NSGraphicsContext restoreGraphicsState];


snippet thread
    [NSThread detachNewThreadSelector:@selector(${1:method}:) toTarget:${2:aTarget} withObject:${3:anArgument}]


snippet pool
	NSAutoreleasePool${TM_C_POINTER: *}pool = [NSAutoreleasePool new];
	${0}
	[pool drain];
    
    
autoload/neocomplcache/sources/snippets_complete/perl.snip	[[[1
76
snippet perl 
	#!/opt/local/bin/perl

	use strict;
	use warnings;
	${1}

snippet sub
	sub ${1:function_name} {
		${2:# body...}
	}

snippet if
	if (${1}) {
		${2:# body...}
	}

snippet ife
	if (${1}) {
		${2:# body...}
	} else {
		${3:# else...}
	}

snippet ifee
	if (${1}) {
		${2:# body...}
	} elsif (${3}) {
		${4:# elsif...}
	} else {
		${5:# else...}
	}

snippet xif
	${1:expression} if ${2:condition};

snippet while
abbr wh
	while (${1}) {
		${2:# body...}
	}
    
snippet xwhile
abbr xwh
	${1:expression} while ${2:condition};

snippet for
	for (my $${1:var} = 0; $$1 < ${2:expression}; $$1++) {
		${3:# body...}
	}
    
snippet fore
	for ${1} (${2:expression}){
		${3:# body...}
	}

snippet xfor
	${1:expression} for @${2:array};

snippet unless
abbr un
	unless (${1}) {
		${2:# body...}
	}

snippet xunless
abbr xun
	${1:expression} unless ${2:condition};

snippet eval
	eval {
		${1:# do something risky...}
	};
	if ($@) {
		${2:# handle failure...}
	}
autoload/neocomplcache/sources/snippets_complete/php.snip	[[[1
266
snippet function
abbr func
	${1:public }function ${2:FunctionName}(${3})
	{
		${4:// code...}
	}

snippet php
	<?php
	${1}
	?>

snippet pecho
	<?php echo ${1} ?>${0}

snippet echoh
	<?php echo htmlentities(${1}, ENT_QUOTES, 'utf-8') ?>${0}

snippet pfore
	<?$php foreach ($${1:variable} as $${2:key}${3: =>}): ?>
	${0}
	<?php endforeach ?>

snippet pife
	<?php if (${1:condition}): ?>
	${2}
	<?php else: ?>
	${0}
	<?php endif ?>

snippet pif
	<?php if (${1:condition}): ?>
	${0}
	<?php endif ?>

snippet pelse
	<?php else: ?>

snippet this
	<?php $this->${0} ?>

snippet ethis
	<?php echo $this->${0} ?>

snippet docc
	/**
	 * ${3:undocumented class variable}
	 *
	 * @var ${4:string}
	 **/
	${1:var} \$${2};${0}

snippet docd
	/**
	 * ${3:undocumented constant}
	 **/
	define(${1} ${2});${0}

snippet docs
	/**
	 * ${4:undocumented function}
	 *
	 * @return ${5:void}
	 * @author ${6}
	 **/
	${1}function ${2}(${3});${0}

snippet docf
	/**
	 * ${4:undocumented function}
	 *
	 * @return ${5:void}
	 * @author ${6}
	 **/
	${1}function ${2}(${3})
	{
		${0}
	}


snippet doch
	/**
	 * ${1}
	 *
	 * @author ${2}
	 * @version ${3}
	 * @copyright ${4}
	 * @package ${5:default}
	 **/
	
	/**
	 * Define DocBlock
	 **/

snippet doci
	/**
	 * ${2:undocumented class}
	 *
	 * @package ${3:default}
	 * @author ${4}
	 **/
	interface ${1}
	{
		${0}
	} // END interface ${1}

snippet c
	/**
	 * $0
	 */

snippet class
	/**
	 * ${1}
	 */
	class ${2:ClassName}${3:extends}}
	{
		$5
		function ${4:__construct}(${5:argument})
		{
			${0:# code...}
		}
	}

snippet def
	${1}defined('${2}')${0}


snippet do
	do {
		${0:# code...}
	} while (${1});

snippet if? 
	$${1:retVal} = (${2:condition}) ? ${3:a} : ${4:b} ;

snippet ifelse
	if (${1:condition}) {
		${2:# code...}
	} else {
		${3:# code...}
	}
	${0}

snippet if
	if (${1:condition}) {
		${0:# code...}
	}

snippet echo
	echo "${1:string}"${0};

snippet else
	else {
		${0:# code...}
	}

snippet elseif
	elseif (${1:condition}) {
		${0:# code...}
	}

snippet for
	for ($${1:i}=${2:0}; $${1:i} < ${3}; $${1:i}++) { 
		${0:# code...}
	}

snippet fore
	foreach ($${1:variable} as $${2:key}${3: =>} ${4:value}) {
		${0:# code...}
	}

snippet func
    ${1:public }function ${2:FunctionName}(${3}})
 {
  ${0:# code...}
 }

snippet con
	function __construct(${1})
	{
		${0}
	}

snippet here
	<<<${1:HTML}
	${2:content here}
	$1;

snippet inc
	include '${1:file}';${0}

snippet inco
	include_once '${1:file}';${0}

snippet array
	$${1:arrayName} = array('${2}' => ${3} ${0});

snippet req
	require '${1:file}';${0}

snippet reqo
	require_once '${1:file}';${0}

snippet ret
	return${1};${0}

snippet retf
	return false;

snippet rett
	return true;

snippet case
	case '${1:variable}':
		${0:# code...}
		break;

snippet switch
abbr sw
	switch (${1:variable}) {
	case '${2:value}':
		${3:# code...}
		break;
	${0}
	default:
		${4:# code...}
		break;
	}

snippet throw
	throw new ${1}Exception(${2:"${3:Error Processing Request}"}${4:});
	${0}

snippet while
abbr wh
	while (${1}) {
		${0:# code...}
	}

snippet gloabals
	\$GLOBALS['${1:variable}']${2: = }${3:something}${4:;}${0}

snippet cookie
	\$_COOKIE['${1:variable}']

snippet env
	\$_ENV['${1:variable}']

snippet files
	\$_FILES['${1:variable}']

snippet get
	\$_GET['${1:variable}']

snippet post
	\$_POST['${1:variable}']

snippet request
	\$_REQUEST['${1:variable}']

snippet server
	\$_SERVER['${1:variable}']

snippet session
	\$_SESSION['${1:variable}']
autoload/neocomplcache/sources/snippets_complete/python.snip	[[[1
85
snippet     class
abbr        class Class(...): ...
prev_word   '^'
    class ${1:name}(${2:object}):
        """${3:class documentation}"""
        def __init__(self, ${4}):
            """${5:__init__ documentation}"""
            ${6:pass}

snippet     def
abbr        def function(...): ...
prev_word   '^'
    def ${1:name}(${2}):
        """${3:function documentation}"""
        ${4:pass}

snippet     defm
abbr        def method(self, ...): ...
prev_word   '^'
    def ${1:name}(self, ${2}):
        """${3:method documentation}"""
        ${4:pass}

snippet     elif
abbr        elif ...: ...
prev_word   '^'
    elif ${1:condition}:
        ${2:pass}

snippet     else
abbr        else: ...
prev_word   '^'
    else:
        ${1:pass}

snippet     fileidiom
abbr        f = None try: f = open(...) finally: ...
prev_word   '^'
    ${1:f} = None
    try:
        $1 = open(${2})
        ${3}
    finally:
        if $1:
            $1.close()

snippet     for
abbr        for ... in ...: ...
prev_word   '^'
    for ${1:value} in ${2:list}:
        ${3:pass}

snippet     if
abbr        if ...: ...
prev_word   '^'
    if ${1:condition}:
        ${2:pass}

snippet     ifmain
abbr        if __name__ == '__main__': ...
prev_word   '^'
    if __name__ == '__main__':
        ${1:pass}

snippet     tryexcept
abbr        try: ... except ...: ...
prev_word   '^'
    try:
        ${1:pass}
    except ${2:ExceptionClass}:
        ${3:pass}

snippet     tryfinally
abbr        try: ... finally: ...
prev_word   '^'
    try:
        ${1:pass}
    finally:
        ${2:pass}

snippet     while
abbr        while ...: ...
prev_word   '^'
    while ${1:condition}:
        ${2:pass}
autoload/neocomplcache/sources/snippets_complete/rails.snip	[[[1
167
snippet     rr
abbr        render
    render

snippet     ra
abbr        render :action
    render :action => 

snippet     rc
abbr        render :controller
    render :controller => 

snippet     rf
abbr        render :file
    render :file => 

snippet     ri
abbr        render :inline
    render :inline => 

snippet     rj
abbr        render :json
    render :json => 

snippet     rl
abbr        render :layout
    render :layout => 

snippet     rp
abbr        render :partial
    render :partial => 

snippet     rt
abbr        render :text
    render :text => 

snippet     rx
abbr        render :xml
    render :xml => 

snippet     dotiw
abbr        distance_of_time_in_words
    distance_of_time_in_words

snippet     taiw
abbr        time_ago_in_words
    time_ago_in_words

snippet     re
abbr        redirect_to
    redirect_to

snippet     rea
abbr        redirect_to :action
    redirect_to :action => 

snippet     rec
abbr        redirect_to :controller
    redirect_to :controller => 

snippet     rst
abbr        respond_to
    respond_to

snippet     bt
abbr        belongs_to
    belongs_to

snippet     ho
abbr        has_one
    has_one

snippet     hm
abbr        has_many
    has_many

snippet     habtm
abbr        has_and_belongs_to_many
    has_and_belongs_to_many

snippet     co
abbr        composed_of
    composed_of

snippet     va
abbr        validates_associated
    validates_associated

snippet     vb
abbr        validates_acceptance_of
    validates_acceptance_of

snippet     vc
abbr        validates_confirmation_of
    validates_confirmation_of

snippet     ve
abbr        validates_exclusion_of
    validates_exclusion_of

snippet     vf
abbr        validates_format_of
    validates_format_of

snippet     vi
abbr        validates_inclusion_of
    validates_inclusion_of

snippet     vl
abbr        validates_length_of
    validates_length_of

snippet     vn
abbr        validates_numericality_of
    validates_numericality_of

snippet     vp
abbr        validates_presence_of
    validates_presence_of

snippet     vu
abbr        validates_uniqueness_of
    validates_uniqueness_of

snippet     vu
abbr        validates_uniqueness_of
    validates_uniqueness_of

snippet     logd
abbr        logger.debug
    logger.debug

snippet     logi
abbr        logger.info
    logger.info

snippet     logw
abbr        logger.warn
    logger.warn

snippet     loge
abbr        logger.error
    logger.error

snippet     logf
abbr        logger.fatal
    logger.fatal

snippet     action
abbr        :action => 
    :action => 

snippet     co
abbr        :co________ => 
    :co________ => 

snippet     id
abbr        :id => 
    :id => 

snippet     object
abbr        :object => 
    :object => 

snippet     partial
abbr        :partial => 
    :partial => 
autoload/neocomplcache/sources/snippets_complete/ruby.snip	[[[1
40
snippet     if
abbr        if end
    if ${1:condition}
        ${2}
    end

snippet     def
abbr        def end
    def ${1:func_name}
        ${2}
    end

snippet     do
abbr        do end
    do
        ${1}
    end

snippet     dovar
abbr        do |var| end
    do |${1:var}|
        ${2}
    end

snippet     block
abbr        { |var| }
    {
        ${1}
    }

snippet     blockvar
abbr        { |var| }
    { |${1:var}|
        ${2}
    }

snippet     edn
abbr        => end?
    end

autoload/neocomplcache/sources/snippets_complete/sh.snip	[[[1
59
snippet if
	if [ ${1:condition} ]; then
		${0:#statements}
	fi


snippet el
	else
    	${0:#statements}


snippet elif
	elif [ ${1:condition} ]; then
		${0:#statements}


snippet for
	for ${1:i} in ${2:words}; do
		${0:#statements}
	done
    

snippet wh
abbr while
	while ${1:condition} ; do
		${0:#statements}
	done


snippet until
	until ${1:condition} ; do
		${0:#statements}
	done


snippet case
	case ${1:word} in
		${2:pattern} )
			${0}
            ;;
	esac
    
    
snippet h
	<<${1}
		${0}
    

snippet env
	#!/usr/bin/env ${1}


snippet tmp
	${1:TMPFILE}="mktemp -t ${2:untitled}"
	trap "rm -f '$${1}'" 0               # EXIT
	trap "rm -f '$${1}'; exit 1" 2       # INT
	trap "rm -f '$${1}'; exit 1" 1 15    # HUP TERM
    ${0}
    
autoload/neocomplcache/sources/snippets_complete/snippet.snip	[[[1
8
snippet     snippet
abbr        snippet abbr prev_word <snippet code>
alias       snip
prev_word   '^'
    snippet     ${1:trigger}
    abbr        ${2:abbr}
    prev_word   '^'
        ${3:snippet code}
autoload/neocomplcache/sources/snippets_complete/tex.snip	[[[1
15
snippet     math
abbr        $ expression $
    $${1:expression}$${2}

snippet     begin
    \begin{${1:type}}
       ${2}
   \end{$1}
   ${0}

snippet     \begin
    \begin{${1:type}}
       ${2}
   \end{$1}
   ${0}
autoload/neocomplcache/sources/snippets_complete/vim.snip	[[[1
56
snippet     if
abbr        if endif
prev_word   '^'
    if ${1:condition}
        ${0}
    endif

snippet elseif
prev_word   '^'
    else if ${1:/* condition */}
        ${0}

snippet     ifelse
abbr        if else endif
prev_word   '^'
    if ${1:condition}
        ${2}
    else
        ${3}  
    endif

snippet     for
abbr        for in endfor
prev_word   '^'
    for ${1:var} in ${2:list}
        ${0}
    endfor

snippet     while
abbr        while endwhile
prev_word   '^'
    while ${1:condition}
        ${0}
    endwhile

snippet     function
abbr        func endfunc
alias       func
prev_word   '^'
    function! ${1:func_name}(${2})
        ${0}
    endfunction

snippet     try
abbr        try endtry
prev_word   '^'
    try
        ${1}
    catch /${2:pattern}/
        ${3}
    endtry

snippet     log
prev_word   '^'
    echomsg string(${1})

autoload/neocomplcache/sources/snippets_complete/vimshell.snip	[[[1
4
snippet     sl
abbr        => ls?
    ls

autoload/neocomplcache/sources/snippets_complete/xhtml.snip	[[[1
235
snippet doctypetransitional
    <!DOCTYPE html
    PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" 
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

snippet doctypeframeset
    <!DOCTYPE html
    PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" 
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">

snippet doctypestrict
    <!DOCTYPE html
    PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" 
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

snippet xhtml
    <html xmlns="http://www.w3.org/1999/xhtml">
        ${1}
    </html>
snippet head
    <head>
        <meta http-equiv="content-type" content="text/html; charset=${1:utf-8}">
        <title>${2}</title>
    <style type="text/css">
        ${3}
    </style>
        ${4}
    </head>${5}

snippet metaauthor
    <meta name="author" content="${1}">${2}
snippet keywords
    <meta name="keywords" content="${1}">${2}
snippet metaothers
    <meta name="others" content="${1}">${2}
snippet metagenerator
    <meta name="generator" content="${1}">${2}
snippet metadescription
    <meta name="description" content="${1}">${2}

snippet scriptcharset
    <script type="text/javascript" charset="${1:UTF-8}">
    ${2}
    </script>${3}
snippet script
    <script type="text/javascript">
    ${1}
    </script>${2}

snippet body
    <body>
       ${1} 
    </body>

snippet h
    <h${1:1}>${2}</h$1>${3}

snippet p
    <p>${1}</p>${2}

snippet br
    <br />

snippet hr
    <hr />

snippet comment
    <!--${1}-->${2}

snippet b
    <b>${1}</b>${2}
snippet small
    <small>${1}</small>${2}
snippet strong
    <strong>${1}</strong>${2}
snippet sub
    <sub>${1}</sub>${2}
snippet sup
    <sup>${1}</sup>${2}
snippet ins
    <ins>${1}</ins>${2}
snippet del
    <del>${1}</del>${2}
snippet em
    <em>${1}</em>${2}
snippet bdo
    <bdo dir="${1:rtl}">${2}</bdo>${3}
snippet pre
    <pre>
    ${1}
    </pre>${2}
snippet blockquote
    <blockquote>
    ${1}
    </blockquote>
    ${2}
snippet link
abbr    link stylesheet css
    <link rel="${1:stylesheet}" href="${2}.css" type="text/css" media="${3:screen}" charset="utf-8">${4}

snippet alignl
    text-align="left"
snippet alignr
    text-align="right"
snippet alignc
    text-align="center"

snippet bgcolor
    bgcolor="${1}"${2}

snippet ahref
    <a href="${1}">${2}</a>${3}
snippet ahref_blank
    <a href="${1}" target="_blank">${2}</a>${3}
snippet ahref_parent
    <a href="${1}" target="_parent">${2}</a>${3}
snippet ahref_top
    <a href="${1}" target="_top">${2}</a>${3}
snippet aname
    <a name="${1}">${2}</a>${3}

snippet framesetcols
    <frameset cols="${1}">
    ${2}
    </frameset>${3}
snippet framesetrows
    <frameset rows="${1}"
    ${2}
    </frameset>${3}

snippet iframe
    <iframe src="${1}"></iframe>${2}
snippet table
    <table border="${1}">
    ${2}
    </table>${3}

snippet th
    <th>${1}</th>${2}

snippet ulsquare
    <ul type="square">${1}</ul>${2}
snippet uldisc
    <ul type="cicle">${1}</ul>${2}
snippet ulcicle
    <ul type="disc">${1}</ul>${2}

snippet ol
    <ol>${1}</ol>${2}
snippet olA
    <ol type="A">${1}</ol>${2}
snippet ola
    <ol type="a">${1}</ol>${2}
snippet olI
    <ol type="I">${1}</ol>${2}
snippet oli
    <ol type="i">${1}</ol>${2}

snippet li
    <li>${1}</li>${2}

snippet dl
    <dl>${1}</dl>${2}
snippet dt
    <dt>${1}</dt>${2}
snippet dd
    <dd>${1}</dd>${2}

snippet form
    <form>
    ${1}
    </form>${2}

snippet inputtext
    <input type="text" name="${1:user}">${2}
snippet inputpassword
    <input type="password" name="${1:password}">${2}
snippet inputradio
    <input type="radio" name="${1}" value="value">${2}
snippet inputcheckbox
    <input type="checkbox" name="${1}">${2}

snippet textarea
    <textarea rows="${1}" cols="${2}">
    ${3}
    </textarea>
    ${4}

snippet button
    <button>${1}</button>${2}

snippet select
    <select>${1}</select>${2}

snippet optgroup
    <optgroup label="${1}">
    ${2}
    <optgroup>${3}
snippet option
    <option value="${1}">${2}</option>${3}

snippet label
    <label>${1}: <input type="${2}" /><label>${3}
snippet labelfor
    <label for="${1}:id">${2}</label>${3}

snippet fiedset
    <fiedlset>${1}</fiedset>${2}

snippet legend
    <legend>${1}</legend>${2}

snippet id
    id="${1}"${2}

snippet class
    class="${1}"${2}

snippet pclass
    <p class="${1}">${2}</p>${3}

snippet pid
    <p id="${1}">${2}</p>${3}

snippet divid
    <div id="${1}">${2}</div>${3}

snippet divclass
    <div class="${1}">${2}</div>${3}

snippet img
    <img src="${1}">${2}

snippet div
    <div ${1:id="${2:someid\}"}>${3}</div>${4}
autoload/neocomplcache/sources/snippets_complete.vim	[[[1
750
"=============================================================================
" FILE: snippets_complete.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 23 Sep 2010
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:begin_snippet = 0
let s:end_snippet = 0

if !exists('s:snippets')
  let s:snippets = {}
endif

let s:source = {
      \ 'name' : 'snippets_complete',
      \ 'kind' : 'plugin',
      \}

function! s:source.initialize()"{{{
  " Initialize.
  let s:snippets = {}
  let s:begin_snippet = 0
  let s:end_snippet = 0
  let s:snippet_holder_cnt = 1

  " Set snips_author.
  if !exists('snips_author')
    let g:snips_author = 'Me'
  endif

  " Set snippets dir.
  let s:runtime_dir = split(globpath(&runtimepath, 'autoload/neocomplcache/sources/snippets_complete'), '\n')
  let s:snippets_dir = split(globpath(&runtimepath, 'snippets'), '\n') + s:runtime_dir
  if exists('g:neocomplcache_snippets_dir')
    for l:dir in split(g:neocomplcache_snippets_dir, ',')
      let l:dir = expand(l:dir)
      if !isdirectory(l:dir)
        call mkdir(l:dir, 'p')
      endif
      call add(s:snippets_dir, l:dir)
    endfor
  endif

  augroup neocomplcache"{{{
    " Set caching event.
    autocmd FileType * call s:caching()
    " Recaching events
    autocmd BufWritePost *.snip,*.snippets call s:caching_snippets(expand('<afile>:t:r')) 
    " Detect syntax file.
    autocmd BufNewFile,BufRead *.snip,*.snippets set filetype=snippet
    autocmd BufNewFile,BufWinEnter * syn match   NeoComplCacheExpandSnippets         
          \'\${\d\+\%(:.\{-}\)\?\\\@<!}\|\$<\d\+\%(:.\{-}\)\?\\\@<!>\|\$\d\+'
  augroup END"}}}

  command! -nargs=? -complete=customlist,neocomplcache#filetype_complete NeoComplCacheEditSnippets call s:edit_snippets(<q-args>, 0)
  command! -nargs=? -complete=customlist,neocomplcache#filetype_complete NeoComplCacheEditRuntimeSnippets call s:edit_snippets(<q-args>, 1)
  command! -nargs=? -complete=customlist,neocomplcache#filetype_complete NeoComplCachePrintSnippets call s:print_snippets(<q-args>)

  hi def link NeoComplCacheExpandSnippets Special

  " Select mode mappings.
  if !exists('g:neocomplcache_disable_select_mode_mappings')
    snoremap <CR>     a<BS>
    snoremap <BS> a<BS>
    snoremap <right> <ESC>a
    snoremap <left> <ESC>bi
    snoremap ' a<BS>'
    snoremap ` a<BS>`
    snoremap % a<BS>%
    snoremap U a<BS>U
    snoremap ^ a<BS>^
    snoremap \ a<BS>\
    snoremap <C-x> a<BS><c-x>
  endif

  " Caching _ snippets.
  call s:caching_snippets('_')

  " Initialize check.
  call s:caching()

  if neocomplcache#exists_echodoc()
    call echodoc#register('snippets_complete', s:doc_dict)
  endif
endfunction"}}}

function! s:source.finalize()"{{{
  delcommand NeoComplCacheEditSnippets
  delcommand NeoComplCacheEditRuntimeSnippets
  delcommand NeoComplCachePrintSnippets

  hi clear NeoComplCacheExpandSnippets
  
  if neocomplcache#exists_echodoc()
    call echodoc#unregister('snippets_complete')
  endif
endfunction"}}}

function! s:source.get_keyword_list(cur_keyword_str)"{{{
  if !has_key(s:snippets, '_')
    " Caching _ snippets.
    call s:caching_snippets('_')
  endif
  let l:snippets = values(s:snippets['_'])

  let l:filetype = neocomplcache#get_context_filetype()
  if !has_key(s:snippets, l:filetype)
    " Caching snippets.
    call s:caching_snippets(l:filetype)
  endif
  for l:source in neocomplcache#get_sources_list(s:snippets, l:filetype)
    let l:snippets += values(l:source)
  endfor

  return s:keyword_filter(neocomplcache#dup_filter(l:snippets), a:cur_keyword_str)
endfunction"}}}

function! neocomplcache#sources#snippets_complete#define()"{{{
  return s:source
endfunction"}}}

function! s:compare_words(i1, i2)
  return a:i1.menu - a:i2.menu
endfunction

" For echodoc."{{{
let s:doc_dict = {
      \ 'name' : 'snippets_complete',
      \ 'rank' : 100,
      \ 'filetypes' : {},
      \ }
function! s:doc_dict.search(cur_text)"{{{
  if mode() !=# 'i'
    return []
  endif
  
  let l:snippets = s:get_snippets()

  let l:cur_word = matchstr(a:cur_text, neocomplcache#get_keyword_pattern_end())
  if !has_key(l:snippets, l:cur_word)
    let l:cur_word = matchstr(a:cur_text, '\S\+$')
  endif
  if !has_key(l:snippets, l:cur_word)
    return []
  endif

  let l:snip = l:snippets[l:cur_word]
  let l:ret = []
  call add(l:ret, { 'text' : l:snip.word, 'highlight' : 'String' })
  call add(l:ret, { 'text' : ' ' })
  call add(l:ret, { 'text' : l:snip.menu, 'highlight' : 'Special' })
  call add(l:ret, { 'text' : ' ' })
  call add(l:ret, { 'text' : l:snip.snip})

  return l:ret
endfunction"}}}
"}}}

function! s:keyword_filter(list, cur_keyword_str)"{{{
  let l:keyword_escape = neocomplcache#keyword_escape(a:cur_keyword_str)

  let l:prev_word = neocomplcache#get_prev_word(a:cur_keyword_str)
  " Keyword filter.
  let l:pattern = printf('v:val.word =~ %s && (!has_key(v:val, "prev_word") || v:val.prev_word == %s)', 
        \string('^' . l:keyword_escape), string(l:prev_word))

  let l:list = filter(a:list, l:pattern)

  " Substitute abbr.
  let l:abbr_pattern = printf('%%.%ds..%%s', g:neocomplcache_max_keyword_width-10)
  for snippet in l:list
    if snippet.snip =~ '\\\@<!`.*\\\@<!`'
      let snippet.menu = s:eval_snippet(snippet.snip)

      if len(snippet.menu) > g:neocomplcache_max_keyword_width 
        let snippet.menu = printf(l:abbr_pattern, snippet.menu, snippet.menu[-8:])
      endif
      let snippet.menu = '`Snip` ' . snippet.menu
    endif
  endfor

  return l:list
endfunction"}}}

function! neocomplcache#sources#snippets_complete#expandable()"{{{
  let l:snippets = s:get_snippets()
  let l:cur_text = neocomplcache#get_cur_text(1)

  if has_key(l:snippets, matchstr(l:cur_text, neocomplcache#get_keyword_pattern_end()))
        \ || has_key(l:snippets, matchstr(l:cur_text, '\S\+$'))
    " Found snippet trigger.
    return 1
  elseif search('\${\d\+\%(:.\{-}\)\?\\\@<!}\|\$<\d\+\%(:.\{-}\)\?\\\@<!>', 'nw') > 0
    " Found snippet placeholder.
    return 2
  else
    " Not found.
    return 0
  endif
endfunction"}}}

function! s:caching()"{{{
  for l:filetype in keys(neocomplcache#get_source_filetypes(neocomplcache#get_context_filetype(1)))
    if !has_key(s:snippets, l:filetype)
      call s:caching_snippets(l:filetype)
    endif
  endfor
endfunction"}}}

function! s:set_snippet_pattern(dict)"{{{
  let l:abbr_pattern = printf('%%.%ds..%%s', g:neocomplcache_max_keyword_width-10)

  let l:word = substitute(a:dict.word, '\%(<\\n>\)\+$', '', '')
  let l:menu_pattern = a:dict.word =~ '\${\d\+\%(:.\{-}\)\?\\\@<!}' ? '<Snip> ' : '[Snip] '

  let l:abbr = has_key(a:dict, 'abbr')? a:dict.abbr : 
        \substitute(a:dict.word, '\${\d\+\%(:.\{-}\)\?\\\@<!}\|\$<\d\+\%(:.\{-}\)\?\\\@<!>\|\$\d\+\|<\%(\\n\|\\t\)>\|\s\+', ' ', 'g')
  let l:abbr = (len(l:abbr) > g:neocomplcache_max_keyword_width)? 
        \ printf(l:abbr_pattern, l:abbr, l:abbr[-8:]) : l:abbr

  let l:dict = {
        \'word' : a:dict.name, 'snip' : l:word, 'abbr' : a:dict.name, 
        \'menu' : l:menu_pattern . l:abbr, 'dup' : 1
        \}
  if has_key(a:dict, 'prev_word')
    let l:dict.prev_word = a:dict.prev_word
  endif
  return l:dict
endfunction"}}}

function! s:edit_snippets(filetype, isruntime)"{{{
  if a:filetype == ''
    let l:filetype = neocomplcache#get_context_filetype(1)
  else
    let l:filetype = a:filetype
  endif

  " Edit snippet file.
  if a:isruntime
    if empty(s:runtime_dir)
      return
    endif

    let l:filename = s:runtime_dir[0].'/'.l:filetype.'.snip'
  else
    if empty(s:snippets_dir) 
      return
    endif

    let l:filename = s:snippets_dir[-1].'/'.l:filetype.'.snip'
  endif

  " Split nicely.
  if winheight(0) > &winheight
    split
  else
    vsplit
  endif

  if filereadable(l:filename)
    edit `=l:filename`
  else
    enew
    setfiletype snippet
    saveas `=l:filename`
  endif
endfunction"}}}
function! s:print_snippets(filetype)"{{{
  let l:list = values(s:snippets['_'])

  let l:filetype = (a:filetype != '')?    a:filetype : neocomplcache#get_context_filetype(1)

  if l:filetype != ''
    if !has_key(s:snippets, l:filetype)
      call s:caching_snippets(l:filetype)
    endif

    let l:list += values(s:snippets[l:filetype])
  endif

  for snip in sort(l:list, 's:compare_words')
    echohl String
    echo snip.word
    echohl Special
    echo snip.menu
    echohl None
    echo snip.snip
    echo ' '
  endfor

  echohl None
endfunction"}}}

function! s:caching_snippets(filetype)"{{{
  let l:snippet = {}
  let l:snippets_files = split(globpath(join(s:snippets_dir, ','), a:filetype .  '.snip*'), '\n')
  for snippets_file in l:snippets_files
    call extend(l:snippet, s:load_snippets(snippets_file, a:filetype))
  endfor

  let s:snippets[a:filetype] = l:snippet
endfunction"}}}

function! s:load_snippets(snippets_file, filetype)"{{{
  let l:snippet = {}
  let l:snippet_pattern = { 'word' : '' }
  let l:abbr_pattern = printf('%%.%ds..%%s', g:neocomplcache_max_keyword_width-10)

  let l:linenr = 1

  for line in readfile(a:snippets_file)
    if line =~ '^\h\w*.*\s$'
      " Delete spaces.
      let line = substitute(line, '\s\+$', '', '')
    endif
    
    if line =~ '^include'
      " Include snippets.
      let l:filetype = matchstr(line, '^include\s\+\zs.*$')
      let l:snippets_files = split(globpath(join(s:snippets_dir, ','), l:filetype .  '.snip'), '\n')
      for snippets_file in l:snippets_files
        call extend(l:snippet, s:load_snippets(snippets_file, l:filetype))
      endfor
    elseif line =~ '^delete\s'
      let l:name = matchstr(line, '^delete\s\+\zs.*$')
      if l:name != '' && has_key(l:snippet, l:name)
        call remove(l:snippet, l:name)
      endif
    elseif line =~ '^snippet\s'
      if has_key(l:snippet_pattern, 'name')
        let l:pattern = s:set_snippet_pattern(l:snippet_pattern)
        let l:snippet[l:snippet_pattern.name] = l:pattern
        if has_key(l:snippet_pattern, 'alias')
          for l:alias in l:snippet_pattern.alias
            let l:alias_pattern = copy(l:pattern)
            let l:alias_pattern.word = l:alias

            let l:abbr = (len(l:alias) > g:neocomplcache_max_keyword_width)? 
                  \ printf(l:abbr_pattern, l:alias, l:alias[-8:]) : l:alias
            let l:alias_pattern.abbr = l:abbr

            let l:snippet[alias] = l:alias_pattern
          endfor
        endif
        let l:snippet_pattern = { 'word' : '' }
      endif

      let l:snippet_pattern.name = matchstr(line, '^snippet\s\+\zs.*$')
      
      " Check for duplicated names.
      if has_key(l:snippet, l:snippet_pattern.name)
        call neocomplcache#print_error('Warning: ' . a:snippets_file . ':' . l:linenr . ': duplicated snippet name `' . l:snippet_pattern.name . '`')
        call neocomplcache#print_error('Please delete this snippet name before.')
      endif
    elseif has_key(l:snippet_pattern, 'name')
      " Only in snippets.
      if line =~ '^abbr\s'
        let l:snippet_pattern.abbr = matchstr(line, '^abbr\s\+\zs.*$')
      elseif line =~ '^alias\s'
        let l:snippet_pattern.alias = split(matchstr(line, '^alias\s\+\zs.*$'), '[,[:space:]]\+')
      elseif line =~ '^prev_word\s'
        let l:snippet_pattern.prev_word = matchstr(line, '^prev_word\s\+[''"]\zs.*\ze[''"]$')
      elseif line =~ '^\s'
        if l:snippet_pattern.word == ''
          let l:snippet_pattern.word = matchstr(line, '^\s\+\zs.*$')
        elseif line =~ '^\t'
          let line = substitute(line, '^\s', '', '')
          let l:snippet_pattern.word .= '<\n>' . 
                \substitute(line, '^\t\+', repeat('<\\t>', matchend(line, '^\t\+')), '')
        else
          let l:snippet_pattern.word .= '<\n>' . matchstr(line, '^\s\+\zs.*$')
        endif
      elseif line =~ '^$'
        " Blank line.
        let l:snippet_pattern.word .= '<\n>'
      endif
    endif

    let l:linenr += 1
  endfor

  if has_key(l:snippet_pattern, 'name')
    let l:pattern = s:set_snippet_pattern(l:snippet_pattern)
    let l:snippet[l:snippet_pattern.name] = l:pattern
    if has_key(l:snippet_pattern, 'alias')
      for l:alias in l:snippet_pattern.alias
        " Check for duplicated names.
        if has_key(l:snippet, l:alias)
          call neocomplcache#print_error('Warning: ' . a:snippets_file . ':' . l:linenr . ': duplicated snippet name `' . l:alias . '`')
          call neocomplcache#print_error('Please delete this snippet name before.')
        endif
        
        let l:alias_pattern = copy(l:pattern)
        let l:alias_pattern.word = l:alias

        let l:abbr = (len(l:alias) > g:neocomplcache_max_keyword_width)? 
              \ printf(l:abbr_pattern, l:alias, l:alias[-8:]) : l:alias
        let l:alias_pattern.abbr = l:abbr

        let l:snippet[alias] = l:alias_pattern
      endfor
    endif
  endif

  return l:snippet
endfunction"}}}

function! s:snippets_expand(cur_text, col)"{{{
  let l:snippets = s:get_snippets()

  let l:cur_word = matchstr(a:cur_text, neocomplcache#get_keyword_pattern_end())
  if !has_key(l:snippets, l:cur_word)
    let l:cur_word = matchstr(a:cur_text, '\S\+$')
  endif
  if !has_key(l:snippets, l:cur_word)
    call s:snippets_jump(a:cur_text, a:col)
    return
  endif
  
  let l:snippet = l:snippets[l:cur_word]
  let l:cur_text = a:cur_text[: -1-len(l:cur_word)]

  let l:snip_word = l:snippet.snip
  if l:snip_word =~ '\\\@<!`.*\\\@<!`'
    let l:snip_word = s:eval_snippet(l:snip_word)
  endif
  if l:snip_word =~ '\n'
    let snip_word = substitute(l:snip_word, '\n', '<\\n>', 'g')
  endif
  
  " Substitute escaped `.
  let snip_word = substitute(l:snip_word, '\\`', '`', 'g')

  " Insert snippets.
  let l:next_line = getline('.')[a:col-1 :]
  call setline(line('.'), l:cur_text . l:snip_word . l:next_line)
  call setpos('.', [0, line('.'), len(l:cur_text)+len(l:snip_word)+1, 0])
  let l:old_col = len(l:cur_text)+len(l:snip_word)+1

  if l:snip_word =~ '<\\t>'
    call s:expand_tabline()
  else
    call s:expand_newline()
  endif
  if l:old_col < col('$')
    startinsert
  else
    startinsert!
  endif

  if l:snip_word =~ '\${\d\+\%(:.\{-}\)\?\\\@<!}'
    call s:snippets_jump(a:cur_text, a:col)
  endif

  let &l:iminsert = 0
  let &l:imsearch = 0
endfunction"}}}
function! s:expand_newline()"{{{
  let l:match = match(getline('.'), '<\\n>')
  let s:snippet_holder_cnt = 1
  let s:begin_snippet = line('.')
  let s:end_snippet = line('.')

  let l:formatoptions = &l:formatoptions
  setlocal formatoptions-=r

  let l:pos = col('.')

  while l:match >= 0
    let l:end = getline('.')[matchend(getline('.'), '<\\n>') :]
    " Substitute CR.
    silent! s/<\\n>//

    " Return.
    call setpos('.', [0, line('.'), l:match+1, 0])
    silent execute 'normal!' (l:match+1 >= col('$')? 'a' : 'i')."\<CR>"

    " Next match.
    let l:match = match(getline('.'), '<\\n>')
    let s:end_snippet += 1
  endwhile

  let &l:formatoptions = l:formatoptions
endfunction"}}}
function! s:expand_tabline()"{{{
  let l:tablines = split(getline('.'), '<\\n>')

  let l:indent = matchstr(l:tablines[0], '^\s\+')
  let l:line = line('.')
  call setline(line, l:tablines[0])
  for l:tabline in l:tablines[1:]
    if &expandtab
      let l:tabline = substitute(l:tabline, '<\\t>', repeat(' ', &softtabstop ? &softtabstop : &shiftwidth), 'g')
    else
      let l:tabline = substitute(l:tabline, '<\\t>', '\t', 'g')
    endif

    call append(l:line, l:indent . l:tabline)
    let l:line += 1
  endfor

  let s:snippet_holder_cnt = 1
  let s:begin_snippet = line('.')
  let s:end_snippet = line('.') + len(l:tablines) - 1
endfunction"}}}
function! s:snippets_jump(cur_text, col)"{{{
  if !s:search_snippet_range(s:begin_snippet, s:end_snippet)
    if s:snippet_holder_cnt != 0
      " Search placeholder 0.
      let s:snippet_holder_cnt = 0
      if s:search_snippet_range(s:begin_snippet, s:end_snippet)
        let &iminsert = 0
        let &imsearch = 0
        return
      endif
    endif

    " Not found.
    let s:begin_snippet = 1
    let s:end_snippet = 0
    let s:snippet_holder_cnt = 1

    call s:search_outof_range(a:col)
  endif

  let &iminsert = 0
  let &imsearch = 0
endfunction"}}}
function! s:search_snippet_range(start, end)"{{{
  call s:substitute_marker(a:start, a:end)

  let l:pattern = '\${'.s:snippet_holder_cnt.'\%(:.\{-}\)\?\\\@<!}'
  let l:pattern2 = '\${'.s:snippet_holder_cnt.':\zs.\{-}\ze\\\@<!}'

  let l:line = a:start
  while l:line <= a:end
    let l:match = match(getline(l:line), l:pattern)
    if l:match >= 0
      let l:default = substitute(matchstr(getline(l:line), l:pattern2), '\\\ze.', '', 'g')
      let l:match_len2 = len(l:default)

      if s:search_sync_placeholder(a:start, a:end, s:snippet_holder_cnt)
        " Substitute holder.
        call setline(l:line, substitute(getline(l:line), l:pattern, '\$<'.s:snippet_holder_cnt.':'.escape(l:default, '\').'>', ''))
        call setpos('.', [0, l:line, l:match+1 + len('$<'.s:snippet_holder_cnt.':'), 0])
        let l:pos = l:match+1 + len('$<'.s:snippet_holder_cnt.':')
      else
        " Substitute holder.
        call setline(l:line, substitute(getline(l:line), l:pattern, escape(l:default, '\'), ''))
        call setpos('.', [0, l:line, l:match+1, 0])
        let l:pos = l:match+1
      endif

      if l:match_len2 > 0
        " Select default value.
        let l:len = l:match_len2-1
        if &l:selection == "exclusive"
          let l:len += 1
        endif

        execute 'normal! v'. repeat('l', l:len) . "\<C-g>"
      elseif l:pos < col('$')
        startinsert
      else
        startinsert!
      endif

      " Next count.
      let s:snippet_holder_cnt += 1
      return 1
    endif

    " Next line.
    let l:line += 1
  endwhile

  return 0
endfunction"}}}
function! s:search_outof_range(col)"{{{
  call s:substitute_marker(1, 0)

  let l:pattern = '\${\d\+\%(:.\{-}\)\?\\\@<!}'
  if search(l:pattern, 'w') > 0
    let l:line = line('.')
    let l:match = match(getline(l:line), l:pattern)
    let l:pattern2 = '\${\d\+:\zs.\{-}\ze\\\@<!}'
    let l:default = substitute(matchstr(getline(l:line), l:pattern2), '\\\ze.', '', 'g')
    let l:match_len2 = len(l:default)

    " Substitute holder.
    let l:cnt = matchstr(getline(l:line), '\${\zs\d\+\ze\%(:.\{-}\)\?\\\@<!}')
    if search('\$'.l:cnt.'\d\@!', 'nw') > 0
      let l:pattern = '\${' . l:cnt . '\%(:.\{-}\)\?\\\@<!}'
      call setline(l:line, substitute(getline(l:line), l:pattern, '\$<'.s:snippet_holder_cnt.':'.escape(l:default, '\').'>', ''))
      call setpos('.', [bufnr('.'), l:line, l:match+1 + len('$<'.l:cnt.':'), 0])
      let l:pos = l:match+1 + len('$<'.l:cnt.':')
    else
      " Substitute holder.
      call setline(l:line, substitute(getline(l:line), l:pattern, escape(l:default, '\'), ''))
      call setpos('.', [bufnr('.'), l:line, l:match+1, 0])
      let l:pos = l:match+1
    endif

    if l:match_len2 > 0
      " Select default value.
      let l:len = l:match_len2-1
      if &l:selection == 'exclusive'
        let l:len += 1
      endif

      execute 'normal! v'. repeat('l', l:len) . "\<C-g>"

      return
    endif

    if l:pos < col('$')
      startinsert
    else
      startinsert!
    endif
  elseif a:col == 1
    call setpos('.', [bufnr('.'), line('.'), 1, 0])
    startinsert
  elseif a:col == col('$')
    startinsert!
  else
    call setpos('.', [0, line('.'), a:col+1, 0])
    startinsert
  endif
endfunction"}}}
function! s:search_sync_placeholder(start, end, number)"{{{
  let l:line = a:start
  let l:pattern = '\$'.a:number.'\d\@!'

  while l:line <= a:end
    if getline(l:line) =~ l:pattern
      return 1
    endif

    " Next line.
    let l:line += 1
  endwhile

  return 0
endfunction"}}}
function! s:substitute_marker(start, end)"{{{
  if s:snippet_holder_cnt > 1
    let l:cnt = s:snippet_holder_cnt-1
    let l:marker = '\$<'.l:cnt.'\%(:.\{-}\)\?\\\@<!>'
    let l:line = a:start
    while l:line <= a:end
      if getline(l:line) =~ l:marker
        let l:sub = escape(matchstr(getline(l:line), '\$<'.l:cnt.':\zs.\{-}\ze\\\@<!>'), '/\')
        silent! execute printf('%d,%ds/$%d\d\@!/%s/g', 
              \a:start, a:end, l:cnt, l:sub)
        silent! execute l:line.'s/'.l:marker.'/'.l:sub.'/'
        break
      endif

      let l:line += 1
    endwhile
  elseif search('\$<\d\+\%(:.\{-}\)\?\\\@<!>', 'wb') > 0
    let l:sub = escape(matchstr(getline('.'), '\$<\d\+:\zs.\{-}\ze\\\@<!>'), '/\')
    let l:cnt = matchstr(getline('.'), '\$<\zs\d\+\ze\%(:.\{-}\)\?\\\@<!>')
    silent! execute printf('%%s/$%d\d\@!/%s/g', l:cnt, l:sub)
    silent! execute '%s/'.'\$<'.l:cnt.'\%(:.\{-}\)\?\\\@<!>'.'/'.l:sub.'/'
  endif
endfunction"}}}
function! s:trigger(function)"{{{
  let l:cur_text = neocomplcache#get_cur_text(1)
  return printf("\<ESC>:call %s(%s,%d)\<CR>", a:function, string(l:cur_text), col('.'))
endfunction"}}}
function! s:eval_snippet(snippet_text)"{{{
  let l:snip_word = ''
  let l:prev_match = 0
  let l:match = match(a:snippet_text, '\\\@<!`.\{-}\\\@<!`')

  try
    while l:match >= 0
      if l:match - l:prev_match > 0
        let l:snip_word .= a:snippet_text[l:prev_match : l:match - 1]
      endif
      let l:prev_match = matchend(a:snippet_text, '\\\@<!`.\{-}\\\@<!`', l:match)
      let l:snip_word .= eval(a:snippet_text[l:match+1 : l:prev_match - 2])

      let l:match = match(a:snippet_text, '\\\@<!`.\{-}\\\@<!`', l:prev_match)
    endwhile
    if l:prev_match >= 0
      let l:snip_word .= a:snippet_text[l:prev_match :]
    endif
  catch
    return ''
  endtry

  return l:snip_word
endfunction"}}}
function! s:get_snippets()"{{{
  " Get buffer filetype.
  let l:ft = neocomplcache#get_context_filetype(1)

  let l:snippets = copy(s:snippets['_'])
  for l:t in split(l:ft, '\.')
    if has_key(s:snippets, l:t)
      call extend(l:snippets, s:snippets[l:t])
    endif
  endfor

  " Get same filetype.
  if has_key(g:neocomplcache_same_filetype_lists, l:ft)
    for l:same_ft in split(g:neocomplcache_same_filetype_lists[l:ft], ',')
      if has_key(s:snippets, l:same_ft)
        call extend(l:snippets, s:snippets[l:same_ft], 'keep')
      endif
    endfor
  endif

  return l:snippets
endfunction"}}}

function! s:SID_PREFIX()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction

" Plugin key-mappings.
inoremap <silent><expr> <Plug>(neocomplcache_snippets_expand) <SID>trigger(<SID>SID_PREFIX().'snippets_expand')
snoremap <silent><expr> <Plug>(neocomplcache_snippets_expand) <SID>trigger(<SID>SID_PREFIX().'snippets_expand')
inoremap <silent><expr> <Plug>(neocomplcache_snippets_jump) <SID>trigger(<SID>SID_PREFIX().'snippets_jump')
snoremap <silent><expr> <Plug>(neocomplcache_snippets_jump) <SID>trigger(<SID>SID_PREFIX().'snippets_jump')

" vim: foldmethod=marker
autoload/neocomplcache/sources/syntax_complete.vim	[[[1
319
"=============================================================================
" FILE: syntax_complete.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 01 Sep 2010
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:source = {
      \ 'name' : 'syntax_complete',
      \ 'kind' : 'plugin',
      \}

function! s:source.initialize()"{{{
  " Initialize.
  let s:syntax_list = {}
  let s:completion_length = neocomplcache#get_auto_completion_length('syntax_complete')
  
  " Set rank.
  call neocomplcache#set_dictionary_helper(g:neocomplcache_plugin_rank, 'syntax_complete', 8)

  " Set caching event.
  autocmd neocomplcache Syntax * call s:caching()

  " Add command.
  command! -nargs=? -complete=customlist,neocomplcache#filetype_complete NeoComplCacheCachingSyntax call s:recaching(<q-args>)

  " Create cache directory.
  if !isdirectory(g:neocomplcache_temporary_dir . '/syntax_cache')
    call mkdir(g:neocomplcache_temporary_dir . '/syntax_cache')
  endif
  
  " Initialize check.
  call s:caching()
endfunction"}}}

function! s:source.finalize()"{{{
  delcommand NeoComplCacheCachingSyntax
endfunction"}}}

function! s:source.get_keyword_list(cur_keyword_str)"{{{
  if neocomplcache#within_comment()
    return []
  endif
  
  let l:list = []

  let l:filetype = neocomplcache#get_context_filetype()
  if !has_key(s:syntax_list, l:filetype)
    let l:keyword_lists = neocomplcache#cache#index_load_from_cache('syntax_cache', l:filetype, s:completion_length)
    if !empty(l:keyword_lists)
      " Caching from cache.
      let s:syntax_list[l:filetype] = l:keyword_lists
    endif
  endif
  
  for l:source in neocomplcache#get_sources_list(s:syntax_list, l:filetype)
    let l:list += neocomplcache#dictionary_filter(l:source, a:cur_keyword_str, s:completion_length)
  endfor

  return l:list
endfunction"}}}

function! neocomplcache#sources#syntax_complete#define()"{{{
  return s:source
endfunction"}}}

function! s:caching()"{{{
  if &filetype == '' || &filetype ==# 'vim'
    return
  endif

  for l:filetype in keys(neocomplcache#get_source_filetypes(&filetype))
    if !has_key(s:syntax_list, l:filetype)
      let l:keyword_lists = neocomplcache#cache#index_load_from_cache('syntax_cache', l:filetype, s:completion_length)
      if !empty(l:keyword_lists)
        " Caching from cache.
        let s:syntax_list[l:filetype] = l:keyword_lists
      elseif l:filetype == &filetype
        " Caching from syn list.
        let s:syntax_list[l:filetype] = s:caching_from_syn(l:filetype)
      endif
    endif
  endfor
endfunction"}}}

function! s:recaching(filetype)"{{{
  if a:filetype == ''
    let l:filetype = &filetype
  else
    let l:filetype = a:filetype
  endif

  " Caching.
  let s:syntax_list[l:filetype] = s:caching_from_syn(l:filetype)
endfunction"}}}

function! s:caching_from_syn(filetype)"{{{
  call neocomplcache#print_caching('Caching syntax "' . a:filetype . '"... please wait.')

  " Get current syntax list.
  redir => l:syntax_list
  silent! syntax list
  redir END

  if l:syntax_list =~ '^E\d\+' || l:syntax_list =~ '^No Syntax items'
    return []
  endif

  let l:group_name = ''
  let l:keyword_pattern = neocomplcache#get_keyword_pattern()

  let l:dup_check = {}
  let l:menu = '[S] '

  let l:keyword_lists = {}
  for l:line in split(l:syntax_list, '\n')
    if l:line =~ '^\h\w\+'
      " Change syntax group name.
      let l:menu = printf('[S] %.'. g:neocomplcache_max_filename_width.'s', matchstr(l:line, '^\h\w\+'))
      let l:line = substitute(l:line, '^\h\w\+\s*xxx', '', '')
    endif

    if l:line =~ 'Syntax items' || l:line =~ '^\s*links to' ||
          \l:line =~ '^\s*nextgroup='
      " Next line.
      continue
    endif

    let l:line = substitute(l:line, 'contained\|skipwhite\|skipnl\|oneline', '', 'g')
    let l:line = substitute(l:line, '^\s*nextgroup=.*\ze\s', '', '')

    if l:line =~ '^\s*match'
      let l:line = s:substitute_candidate(matchstr(l:line, '/\zs[^/]\+\ze/'))
    elseif l:line =~ '^\s*start='
      let l:line = 
            \s:substitute_candidate(matchstr(l:line, 'start=/\zs[^/]\+\ze/')) . ' ' .
            \s:substitute_candidate(matchstr(l:line, 'end=/zs[^/]\+\ze/'))
    endif

    " Add keywords.
    let l:match_num = 0
    let l:match_str = matchstr(l:line, l:keyword_pattern, l:match_num)
    while l:match_str != ''
      " Ignore too short keyword.
      if len(l:match_str) >= g:neocomplcache_min_syntax_length && !has_key(l:dup_check, l:match_str)
            \&& l:match_str =~ '^[[:print:]]\+$'
        let l:keyword = { 'word' : l:match_str, 'menu' : l:menu }

        let l:key = tolower(l:keyword.word[: s:completion_length-1])
        if !has_key(l:keyword_lists, l:key)
          let l:keyword_lists[l:key] = []
        endif
        call add(l:keyword_lists[l:key], l:keyword)

        let l:dup_check[l:match_str] = 1
      endif

      let l:match_num += len(l:match_str)

      let l:match_str = matchstr(l:line, l:keyword_pattern, l:match_num)
    endwhile
  endfor

  " Save syntax cache.
  call neocomplcache#cache#save_cache('syntax_cache', &filetype, neocomplcache#unpack_dictionary(l:keyword_lists))

  call neocomplcache#print_caching('')

  return l:keyword_lists
endfunction"}}}

" LengthOrder."{{{
function! s:compare_length(i1, i2)
  return a:i1.word < a:i2.word ? 1 : a:i1.word == a:i2.word ? 0 : -1
endfunction"}}}

function! s:substitute_candidate(candidate)"{{{
  let l:candidate = a:candidate

  " Collection.
  let l:candidate = substitute(l:candidate,
        \'\\\@<!\[[^\]]*\]', ' ', 'g')

  " Delete.
  let l:candidate = substitute(l:candidate,
        \'\\\@<!\%(\\[=?+]\|\\%[\|\\s\*\)', '', 'g')
  " Space.
  let l:candidate = substitute(l:candidate,
        \'\\\@<!\%(\\[<>{}]\|[$^]\|\\z\?\a\)', ' ', 'g')

  if l:candidate =~ '\\%\?('
    let l:candidate = join(s:split_pattern(l:candidate))
  endif

  " \
  let l:candidate = substitute(l:candidate, '\\\\', '\\', 'g')
  " *
  let l:candidate = substitute(l:candidate, '\\\*', '*', 'g')
  return l:candidate
endfunction"}}}

function! s:split_pattern(keyword_pattern)"{{{
  let l:original_pattern = a:keyword_pattern
  let l:result_patterns = []
  let l:analyzing_patterns = [ '' ]

  let l:i = 0
  let l:max = len(l:original_pattern)
  while l:i < l:max
    if match(l:original_pattern, '^\\%\?(', l:i) >= 0
      " Grouping.
      let l:end = s:match_pair(l:original_pattern, '\\%\?(', '\\)', l:i)
      if l:end < 0
        "call neocomplcache#print_error('Unmatched (.')
        return [ a:keyword_pattern ]
      endif

      let l:save_pattern = l:analyzing_patterns
      let l:analyzing_patterns = []
      for l:keyword in split(l:original_pattern[matchend(l:original_pattern, '^\\%\?(', l:i) : l:end], '\\|')
        for l:prefix in l:save_pattern
          call add(l:analyzing_patterns, l:prefix . l:keyword)
        endfor
      endfor

      let l:i = l:end + 1
    elseif match(l:original_pattern, '^\\|', l:i) >= 0
      " Select.
      let l:result_patterns += l:analyzing_patterns
      let l:analyzing_patterns = [ '' ]
      let l:original_pattern = l:original_pattern[l:i+2 :]
      let l:max = len(l:original_pattern)

      let l:i = 0
    elseif l:original_pattern[l:i] == '\' && l:i+1 < l:max
      let l:save_pattern = l:analyzing_patterns
      let l:analyzing_patterns = []
      for l:prefix in l:save_pattern
        call add(l:analyzing_patterns, l:prefix . l:original_pattern[l:i] . l:original_pattern[l:i+1])
      endfor

      " Escape.
      let l:i += 2
    else
      let l:save_pattern = l:analyzing_patterns
      let l:analyzing_patterns = []
      for l:prefix in l:save_pattern
        call add(l:analyzing_patterns, l:prefix . l:original_pattern[l:i])
      endfor

      let l:i += 1
    endif
  endwhile

  let l:result_patterns += l:analyzing_patterns
  return l:result_patterns
endfunction"}}}

function! s:match_pair(string, start_pattern, end_pattern, start_cnt)"{{{
  let l:end = -1
  let l:start_pattern = '\%(' . a:start_pattern . '\)'
  let l:end_pattern = '\%(' . a:end_pattern . '\)'

  let l:i = a:start_cnt
  let l:max = len(a:string)
  let l:nest_level = 0
  while l:i < l:max
    let l:start = match(a:string, l:start_pattern, l:i)
    let l:end = match(a:string, l:end_pattern, l:i)

    if l:start >= 0 && (l:end < 0 || l:start < l:end)
      let l:i = matchend(a:string, l:start_pattern, l:i)
      let l:nest_level += 1
    elseif l:end >= 0 && (l:start < 0 || l:end < l:start)
      let l:nest_level -= 1

      if l:nest_level == 0
        return l:end
      endif

      let l:i = matchend(a:string, l:end_pattern, l:i)
    else
      break
    endif
  endwhile

  if l:nest_level != 0
    return -1
  else
    return l:end
  endif
endfunction"}}}

" Global options definition."{{{
if !exists('g:neocomplcache_min_syntax_length')
  let g:neocomplcache_min_syntax_length = 4
endif
"}}}

" vim: foldmethod=marker
autoload/neocomplcache/sources/tags_complete.vim	[[[1
122
"=============================================================================
" FILE: tags_complete.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 10 Jul 2010
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:source = {
      \ 'name' : 'tags_complete',
      \ 'kind' : 'plugin',
      \}

function! s:source.initialize()"{{{
  " Initialize
  let s:tags_list = {}
  let s:completion_length = neocomplcache#get_auto_completion_length('tags_complete')

  " Create cache directory.
  if !isdirectory(g:neocomplcache_temporary_dir . '/tags_cache')
    call mkdir(g:neocomplcache_temporary_dir . '/tags_cache', 'p')
  endif

  command! -nargs=? -complete=buffer NeoComplCacheCachingTags call s:caching_tags(<q-args>, 1)
endfunction"}}}

function! s:source.finalize()"{{{
  delcommand NeoComplCacheCachingTags
endfunction"}}}

function! neocomplcache#sources#tags_complete#define()"{{{
  return s:source
endfunction"}}}

function! s:source.get_keyword_list(cur_keyword_str)"{{{
  if !has_key(s:tags_list, bufnr('%'))
    call s:caching_tags(bufnr('%'), 0)
  endif

  if empty(s:tags_list[bufnr('%')]) || neocomplcache#within_comment()
    return []
  endif
  let l:tags_list = s:tags_list[bufnr('%')]

  let l:keyword_list = []
  let l:key = tolower(a:cur_keyword_str[: s:completion_length-1])
  if len(a:cur_keyword_str) < s:completion_length || neocomplcache#check_match_filter(l:key)
    for tags in values(l:tags_list)
      let l:keyword_list += neocomplcache#unpack_dictionary(tags)
    endfor
  else
    for tags in values(l:tags_list)
      if has_key(tags, l:key)
        let l:keyword_list += tags[l:key]
      endif
    endfor
  endif

  return neocomplcache#keyword_filter(l:keyword_list, a:cur_keyword_str)
endfunction"}}}

function! s:caching_tags(bufname, force)"{{{
  let l:bufnumber = (a:bufname == '') ? bufnr('%') : bufnr(a:bufname)
  let s:tags_list[l:bufnumber] = {}
  for tags in split(getbufvar(l:bufnumber, '&tags'), ',')
    let l:filename = fnamemodify(tags, ':p')
    if filereadable(l:filename)
          \&& (a:force || getfsize(l:filename) < g:neocomplcache_caching_limit_file_size)
      let s:tags_list[l:bufnumber][l:filename] = s:initialize_tags(l:filename)
    endif
  endfor
endfunction"}}}
function! s:initialize_tags(filename)"{{{
  " Initialize tags list.

  let l:keyword_lists = neocomplcache#cache#index_load_from_cache('tags_cache', a:filename, s:completion_length)
  if !empty(l:keyword_lists)
    return l:keyword_lists
  endif

  let l:ft = &filetype
  if l:ft == ''
    let l:ft = 'nothing'
  endif

  let l:keyword_lists = {}
  let l:loaded_list = neocomplcache#cache#load_from_tags('tags_cache', a:filename, readfile(a:filename), 'T', l:ft)
  if len(l:loaded_list) > 300
    call neocomplcache#cache#save_cache('tags_cache', a:filename, l:loaded_list)
  endif

  for l:keyword in l:loaded_list
    let l:key = tolower(l:keyword.word[: s:completion_length-1])
    if !has_key(l:keyword_lists, l:key)
      let l:keyword_lists[l:key] = []
    endif

    call add(l:keyword_lists[l:key], l:keyword)
  endfor 

  return l:keyword_lists
endfunction"}}}

" vim: foldmethod=marker
autoload/neocomplcache/sources/vim_complete/autocmds.dict	[[[1
82
BufNewFile ; starting to edit a file that doesn't exist
BufReadPre ; starting to edit a new buffer, before reading the file
BufRead ; starting to edit a new buffer, after reading the file
BufReadPost ; starting to edit a new buffer, after reading the file
BufReadCmd ; before starting to edit a new buffer |Cmd-event|
FileReadPre ; before reading a file with a ":read" command
FileReadPost ; after reading a file with a ":read" command
FileReadCmd ; before reading a file with a ":read" command |Cmd-event|
FilterReadPre ; before reading a file from a filter command
FilterReadPost ; after reading a file from a filter command
StdinReadPre ; before reading from stdin into the buffer
StdinReadPost ; After reading from the stdin into the buffer
BufWrite ; starting to write the whole buffer to a file
BufWritePre ; starting to write the whole buffer to a file
BufWritePost ; after writing the whole buffer to a file
BufWriteCmd ; before writing the whole buffer to a file |Cmd-event|
FileWritePre ; starting to write part of a buffer to a file
FileWritePost ; after writing part of a buffer to a file
FileWriteCmd ; starting to append to a file
FileAppendPre ; after appending to a file
FileAppendPost ; before appending to a file |Cmd-event|
FileAppendCmd ; starting to write a file for a filter command or diff
FilterWritePre ; after writing a file for a filter command or diff
FilterWritePost ; just after adding a buffer to the buffer list
BufAdd ; just after adding a buffer to the buffer list
BufCreate ; just after adding a buffer to the buffer list
BufDelete ; before deleting a buffer from the buffer list
BufWipeout ; before completely deleting a buffer
BufFilePre ; before changing the name of the current buffer
BufFilePost ; after changing the name of the current buffer
BufEnter ; after entering a buffer
BufLeave ; before leaving to another buffer
BufWinEnter ; after a buffer is displayed in a window
BufWinLeave ; before a buffer is removed from a window
BufUnload ; before unloading a buffer
BufHidden ; just after a buffer has become hidden
BufNew ; just after creating a new buffer
SwapExists ; detected an existing swap file
FileType ; when the 'filetype' option has been set
Syntax ; when the 'syntax' option has been set
EncodingChanged ; after the 'encoding' option has been changed
TermChanged ; after the value of 'term' has changed
VimEnter ; after doing all the startup stuff
GUIEnter ; after starting the GUI successfully
TermResponse ; after the terminal response to |t_RV| is received
VimLeavePre ; before exiting Vim, before writing the viminfo file
VimLeave ; before exiting Vim, after writing the viminfo file
FileChangedShell ; Vim notices that a file changed since editing started
FileChangedShellPost ; After handling a file changed since editing started
FileChangedRO ; before making the first change to a read-only file
ShellCmdPost ; after executing a shell command
ShellFilterPost ; after filtering with a shell command
FuncUndefined ; a user function is used but it isn't defined
SpellFileMissing ; a spell file is used but it can't be found
SourcePre ; before sourcing a Vim script
SourceCmd ; before sourcing a Vim script |Cmd-event|
VimResized ; after the Vim window size changed
FocusGained ; Vim got input focus
FocusLost ; Vim lost input focus
CursorHold ; the user doesn't press a key for a while
CursorHoldI ; the user doesn't press a key for a while in Insert mode
CursorMoved ; the cursor was moved in Normal mode
CursorMovedI ; the cursor was moved in Insert mode
WinEnter ; after entering another window
WinLeave ; before leaving a window
TabEnter ; after entering another tab page
TabLeave ; before leaving a tab page
CmdwinEnter ; after entering the command-line window
CmdwinLeave ; before leaving the command-line window
InsertEnter ; starting Insert mode
InsertChange ; when typing <Insert> while in Insert or Replace mode
InsertLeave ; when leaving Insert mode
ColorScheme ; after loading a color scheme
RemoteReply ; a reply from a server Vim was received
QuickFixCmdPre ; before a quickfix command is run
QuickFixCmdPost ; after a quickfix command is run
SessionLoadPost ; after loading a session file
MenuPopup ; just before showing the popup menu
User ; to be used in combination with ":doautocmd"
<buffer> ; buffer-local autocommands
<afile> ; for the file name that is being
<abuf> ; for the buffer name that is being
autoload/neocomplcache/sources/vim_complete/command_args.dict	[[[1
33
-nargs=0 ; no arguments are allowed (the default)
-nargs=1 ; exactly one argument is required
-nargs=* ; any number of arguments are allowed (0, 1, or many)
-nargs=? ; 0 or 1 arguments are allowed
-nargs=+ ; arguments must be supplied, but any number are allowed
-complete=augroup ; autocmd groups
-complete=buffer ; buffer names
-complete=command ; Ex command (and arguments)
-complete=dir ; directory names
-complete=environment ; environment variable names
-complete=event ; autocommand events
-complete=expression ; Vim expression
-complete=file ; file and directory names
-complete=shellcmd ; Shell command
-complete=function ; function name
-complete=help ; help subjects
-complete=highlight ; highlight groups
-complete=mapping ; mapping name
-complete=menu ; menus
-complete=option ; options
-complete=tag ; tags
-complete=tag_list ; tags, file names are shown when CTRL-D is hit
-complete=var ; user variables
-complete=custom ; custom completion, defined via {func}
-complete=customlist ; custom completion, defined via {func}
-count= ; a count (default N) in the line or as an initial argument
-range ; range allowed, default is current line
-range= ; a count (default N) which is specified in the line
-range=% ; range allowed, default is whole file (1,$)
-bang ; the command can take a ! modifier (like :q or :w)
-bar ; the command can be followed by a "|" and another command
-register ; the first argument to the command can be an optional register name
-buffer ; the command will only be available in the current buffer
autoload/neocomplcache/sources/vim_complete/command_completions.dict	[[[1
498
N[ext]
P[rint]
a[ppend]
ab[breviate]    abbreviation
abc[lear]
abo[veleft]     command
al[l]           
am[enu]
an[oremenu]     menu
ar[gs]          file
arga[dd]        file
argd[elete]     file
argdo           command
arge[dit]       file
argg[lobal]     file
argl[ocal]      file
argu[ment]      
as[cii]
au[tocmd]       autocmd_args
aug[roup]       augroup
aun[menu]       menu
bN[ext]         
b[uffer]        buffer
ba[ll]          
bad[d]          file
bd[elete]       buffer
be[have]        
bel[owright]    command
bf[irst]
bl[ast]
bm[odified]     
bn[ext]         
bo[tright]      command
bp[revious]     
br[ewind]
brea[k]
breaka[dd]      function
breakd[el]      
breakl[ist]
bro[wse]        command
bufdo           command
buffers
bun[load]       buffer
bw[ipeout]      buffer
cN[ext]
cNf[ile]
c[hange]
ca[bbrev]       abbreviation
cabc[lear]
cad[dexpr]      expression
caddb[uffer]    
caddf[ile]      file
cal[l]          function
cat[ch]         
cb[uffer]     
cc             
ccl[ose]
cd              dir
ce[nter]        
cex[pr]         expression
cf[ile]         file
cfir[st]        
cg[etfile]      file
cgetb[uffer]    
cgete[xpr]      expression
changes
chd[ir]         dir
che[ckpath]
checkt[ime]
cl[ist]         
cla[st]         
clo[se]
cm[ap]          mapping
cmapc[lear]
cme[nu]         menu
cn[ext]
cnew[er]        
cnf[ile]
cno[remap]      mapping
cnorea[bbrev]   abbreviation
cnoreme[nu]     menu
co[py]          
col[der]        
colo[rscheme]   colorscheme_args
com[mand]       command_args
comc[lear]
comp[iler]      compiler_args
con[tinue]
conf[irm]       command
cope[n]         
cp[revious]
cpf[ile]
cq[uit]
cr[ewind]       
cs[cope]        cscope_args
cst[ag]
cu[nmap]        mapping
cuna[bbrev]     abbreviation
cunme[nu]       menu
cw[indow]       
d[elete]        
deb[ug]         command
debugg[reedy]
del[command]    command
delf[unction]   function
delm[arks]      
di[splay]       
diffg[et]       
diffo[ff]
diffp[atch]     file
diffpu[t]       
diffs[plit]     file
diffthis
diffu[pdate]
dig[raphs]      
dj[ump]         
dl[ist]         
do[autocmd]     autocmd_args
doautoa[ll]     autocmd_args
dr[op]          file
ds[earch]       
dsp[lit]        
e[dit]          file          
ea[rlier]       
ec[ho]          expression
echoe[rr]       expression
echoh[l]        expression
echom[sg]       expression
echon           expression
el[se]
elsei[f]        expression
em[enu]         menu
en[dif]
endf[unction]
endfo[r]
endt[ry]
endw[hile]
ene[w]
ex              file
exe[cute]       expression
exi[t]          file
exu[sage]
f[ile]
files
filet[ype]
fin[d]          file
fina[lly]
fini[sh]
fir[st]         
fix[del]
fo[ld]
foldc[lose]
foldd[oopen]    command
folddoc[losed]  command
foldo[pen]
for             expression
fu[nction]      function_args
go[to]          
gr[ep]          file
grepa[dd]       file
gu[i]           file
gv[im]          file
h[elp]          help
ha[rdcopy]      
helpf[ind]
helpg[rep]      
helpt[ags]      dir
hi[ghlight]     highlight
hid[e]          command
his[tory]       
i[nsert]
ia[bbrev]       abbreviation
iabc[lear]
if              expression
ij[ump]       
il[ist]         
im[ap]          mapping
imapc[lear]
imenu           menu
ino[remap]      mapping
inorea[bbrev]   mapping
inoreme[nu]     menu
int[ro]
is[earch]       
isp[lit]        
iu[nmap]        mapping
iuna[bbrev]     abbreviation
iunme[nu]       menu
j[oin]          
ju[mps]
kee[pmarks]     command
keep[jumps]     command
keepa[lt]       command
lN[ext]
lNf[ile]
l[ist]          
la[st]          
lad[dexpr]      expr
laddb[uffer]    
laddf[ile]      file
lan[guage]      language_args
lat[er]         
lb[uffer]       
lc[d]           dir
lch[dir]        dir
lcl[ose]
lcs[cope]       cscope_args
le[ft]          
lefta[bove]     command
let             let
lex[pr]         expression
lf[ile]         file
lfir[st]        
lg[etfile]      file
lgetb[uffer]    
lgete[xpr]      expression
lgr[ep]         file
lgrepa[dd]      file
lh[elpgrep]     
ll              
lla[st]         
lli[st]         
lm[ap]          mapping
lmak[e]         file
lmapc[lear]
ln[oremap]      mapping
lne[xt]
lnew[er]        
lnf[ile]
lo[adview]      
loadk[eymap]
loc[kmarks]     command
lockv[ar]       var
lol[der]        
lop[en]         
lp[revious]
lpf[ile]
lr[ewind]       
ls
lt[ag]          
lu[nmap]        mapping
lua
luado
luafile         file
lv[imgrep]      file
lvimgrepadd     file
lwindow         
m[ove]          
ma[rk]          
mak[e]          file
map             mapping
mapc[lear]
marks
match           
menu            menu
menut[ranslate] menutranslate_args
mes[sages]      
mk[exrc]        file
mks[ession]     file
mksp[ell]       file
mkv[imrc]       file
mkvie[w]        file
mod[e]          
mz[scheme]      file
mzf[ile]        file
n[ext]          
nb[key]         
new
nm[ap]          mapping
nmapc[lear]
nmenu           menu
nno[remap]      mapping
nnoreme[nu]     menu
no[remap]       mapping
noa[utocmd]     command
noh[lsearch]    
norea[bbrev]    abbreviation
noreme[nu]      menu
norm[al]        
nu[mber]        
nun[map]        mapping
nunme[nu]       menu
o[pen]          
ol[dfiles]
om[ap]          mapping
omapc[lear]
ome[nu]         menu
on[ly]
ono[remap]      mapping
onoreme[nu]     menu
opt[ions]
ou[nmap]        lhs
ounmenu         menu
ownsyntax       syntax_args
p[rint]         
pc[lose]
pe[rl]          
ped[it]         file
perld[o]        
po[p]
popu[p]         
pp[op]
pre[serve]
prev[ious]      
prof[ile]       profile_args
profd[el]       
promptf[ind]    
promptr[epl]    
ps[earch]       
ptN[ext]
pta[g]          tag
ptf[irst]
ptj[ump]
ptl[ast]
ptn[ext]
ptp[revious]
ptr[ewind]
pts[elect]      tag
pu[t]           
pw[d]
py3f[ile]       file
py[thon]        
pyf[ile]        file
python3        
q[uit]
qa[ll]
quita[ll]
r[ead]          
rec[over]       file
red[o]
redi[r]         
redr[aw]
redraws[tatus]
reg[isters]     
res[ize]
ret[ab]         
retu[rn]        expression
rew[ind]        
ri[ght]         
rightb[elow]    command
rub[y]          
rubyd[o]        
rubyf[ile]      file
runtime         file
rv[iminfo]      file
sN[ext]         
s[ubstitute]    
sa[rgument]     
sal[l]
san[dbox]       command
sav[eas]        file
sbN[ext]        
sb[uffer]       buffer
sba[ll]         
sbf[irst]
sbl[ast]
sbm[odified]    
sbn[ext]        
sbp[revious]    
sbr[ewind]
scrip[tnames]
scripte[ncoding] encoding
scscope          cscope_args
se[t]            option
setf[iletype]   filetype
setg[lobal]     option
setl[ocal]      option
sf[ind]         file
sfir[st]        
sh[ell]
sig[n]          sign_args
sil[ent]        command
sim[alt]        
sl[eep]         
sla[st]         
sm[agic]        
sm[ap]          mapping
smapc[lear]
sme[nu]         menu
sn[ext]         file
sni[ff]         
sno[remap]      mapping
snoreme[nu]     menu
so[urce]        file
sor[t]          
sp[lit]         
spe[llgood]     
spelld[ump]
spelli[nfo]     
spellr[epall]
spellu[ndo]     
spellw[rong]    
spr[evious]     
sre[wind]       
st[op]
sta[g]          tag
star[tinsert]
startg[replace]
startr[eplace]
stj[ump]        tag
stopi[nsert]
sts[elect]      tag
sun[hide]       
sunm[ap]        mapping
sunme[nu]       menu
sus[pend]
sv[iew]         file
sw[apname]
sy[ntax]        syntax_args
sync[bind]
t
tN[ext]
ta[g]           tag
tab             command
tabN[ext]
tabc[lose]
tabd[o]         command
tabe[dit]       file
tabf[ind]       file
tabfir[st]
tabl[ast]
tabm[ove]       
tabn[ext]
tabnew          file
tabo[nly]
tabp[revious]
tabr[ewind]
tabs
tags
tc[l]           
tcld[o]         
tclf[ile]       file
te[aroff]       menu
tf[irst]
th[row]         expression
tj[ump]         tag
tl[ast]         
tm[enu]         menu
tn[ext]
to[pleft]       command
tp[revious]
tr[ewind]
try
tselect
tu[nmenu]       menu
u[ndo]          
una[bbreviate]  abbreviation
undoj[oin]
undol[ist]
unh[ide]        
unl[et]         var
unlo[ckvar]     var
unm[ap]         mapping
unme[nu]        menu
uns[ilent]      command
up[date]        file
ve[rsion]
verb[ose]       command
vert[ical]      command
vg[lobal]       
vi[sual]        file
vie[w]          file
vim[grep]       file
vimgrepa[dd]    file
viu[sage]
vm[ap]          mapping
vmapc[lear]
vmenu           menu
vn[oremap]      mapping
vne[w]          file
vnoremenu       menu
vsp[lit]        file
vu[nmap]        mapping
vunmenu         menu
wN[ext]         file
w[rite]         file
wa[ll]
wh[ile]         expression
win[size]       
winc[md]        
windo           command
winp[os]        
wn[ext]         
wp[revious]     file
wq              
wqa[ll]         
ws[verb]        
wv[iminfo]      file
x[it]           file
xa[ll]          
xm[ap]          mapping
xmapc[lear]
xmenu           menu
xn[oremap]      mapping
xnoremenu       menu
xu[nmap]        mapping
xunmenu         menu
y[ank]          
autoload/neocomplcache/sources/vim_complete/command_prototypes.dict	[[[1
498
N[ext]          [count] [++opt] [+cmd]
P[rint]         [count] [flags]
a[ppend]
ab[breviate]
abc[lear]
abo[veleft]     {cmd}
al[l]           [N]
am[enu]
an[oremenu]     {menu}
ar[gs]
arga[dd]        {name} ..
argd[elete]     {pattern} ..
argdo           {cmd}
arge[dit]       [++opt] [+cmd] {name}
argg[lobal]     [++opt] [+cmd] {arglist}
argl[ocal]      [++opt] [+cmd] {arglist}
argu[ment]      [count] [++opt] [+cmd]
as[cii]
au[tocmd]       [group] {event} {pat} [nested] {cmd}
aug[roup]       {name}
aun[menu]       {menu}
bN[ext]         [N]
b[uffer]        {bufname}
ba[ll]          [N]
bad[d]          [+lnum] {fname}
bd[elete]       {bufname}
be[have]        {model}
bel[owright]    {cmd}
bf[irst]
bl[ast]
bm[odified]     [N]
bn[ext]         [N]
bo[tright]      {cmd}
bp[revious]     [N]
br[ewind]
brea[k]
breaka[dd]      func [lnum] {name}
breakd[el]      {nr}
breakl[ist]
bro[wse]        {command}
bufdo         {cmd}
buffers
bun[load]       {bufname}
bw[ipeout]      {bufname}
cN[ext]
cNf[ile]
c[hange]
ca[bbrev]       [<expr>] [lhs] [rhs]
cabc[lear]
cad[dexpr]      {expr}
caddb[uffer]    [bufnr]
caddf[ile]      [errorfile]
cal[l]          {name}([arguments])
cat[ch]         /{pattern}/
cb[uffer]     [bufnr]
cc              [nr]
ccl[ose]
cd            {path}
ce[nter]        [width]
cex[pr]         {expr}
cf[ile]         [errorfile]
cfir[st]        [nr]
cg[etfile]      [errorfile]
cgetb[uffer]    [bufnr]
cgete[xpr]      {expr}
changes
chd[ir]         [path]
che[ckpath]
checkt[ime]
cl[ist]         [from] [, [to]]
cla[st]         [nr]
clo[se]
cm[ap]          {lhs} {rhs}
cmapc[lear]
cme[nu]         {menu}
cn[ext]
cnew[er]        [count]
cnf[ile]
cno[remap]      {lhs} {rhs}
cnorea[bbrev]   [<expr>] [lhs] [rhs]
cnoreme[nu]     {menu}
co[py]          {address}
col[der]        [count]
colo[rscheme]   {name}
com[mand]       [{attr}...] {cmd} {rep}
comc[lear]
comp[iler]      {name}
con[tinue]
conf[irm]       {command}
cope[n]         [height]
cp[revious]
cpf[ile]
cq[uit]
cr[ewind]       [nr]
cs[cope]        add {file|dir} [pre-path] [flags] | find {querytype} {name} | kill {num|partial_name} | help | reset | show
cst[ag]
cu[nmap]        {lhs}
cuna[bbrev]     {lhs}
cunme[nu]       {menu}
cw[indow]       [height]
d[elete]        [x]
deb[ug]         {cmd}
debugg[reedy]
del[command]    {cmd}
delf[unction]   {name}
delm[arks]      {marks}
di[splay]       [arg]
diffg[et]       [bufspec]
diffo[ff]
diffp[atch]     {patchfile}
diffpu[t]       [bufspec]
diffs[plit]     {filename}
diffthis
diffu[pdate]
dig[raphs]      {char1}{char2} {number} ...
dj[ump]         [count] [/]string[/]
dl[ist]         [/]string[/]
do[autocmd]     [group] {event} [fname]
doautoa[ll]     [group] {event} [fname]
dr[op]          [++opt] [+cmd] {file} ..
ds[earch]       [count] [/]string[/]
dsp[lit]        [count] [/]string[/]
e[dit]          [++opt] [+cmd] {file}
ea[rlier]       {count} | {N}s | {N}h
ec[ho]          {expr1} ..
echoe[rr]       {expr1} ..
echoh[l]        {expr1} ..
echom[sg]       {expr1} ..
echon           {expr1} ..
el[se]
elsei[f]        {expr1}
em[enu]         {menu}
en[dif]
endf[unction]
endfo[r]
endt[ry]
endw[hile]
ene[w]
ex              [++opt] [+cmd] [file]
exe[cute]       {expr1} ..
exi[t]          [++opt] [file]
exu[sage]
f[ile]
files
filet[ype]
fin[d]          [++opt] [+cmd] {file}
fina[lly]
fini[sh]
fir[st]         [++opt] [+cmd]
fix[del]
fo[ld]
foldc[lose]
foldd[oopen]    {cmd}
folddoc[losed]  {cmd}
foldo[pen]
for             {var} in {list}
fu[nction]      {name}([arguments]) [range] [abort] [dict]
go[to]          [count]
gr[ep]          [arguments]
grepa[dd]       [arguments]
gu[i]           [++opt] [+cmd] [-f|-b] [files...]
gv[im]          [++opt] [+cmd] [-f|-b] [files...]
h[elp]          {subject}
ha[rdcopy]      [arguments]
helpf[ind]
helpg[rep]      {pattern}[@xx]
helpt[ags]      [++t] {dir}
hi[ghlight]     [default] {group-name} {key}={arg} ..
hid[e]          {cmd}
his[tory]       [{name}] [{first}][, [{last}]]
i[nsert]
ia[bbrev]       [<expr>] [lhs] [rhs]
iabc[lear]
if              {expr1}
ij[ump]       [count] [/]pattern[/]
il[ist]         [/]pattern[/]
im[ap]          {lhs} {rhs}
imapc[lear]
imenu           {menu}
ino[remap]      {lhs} {rhs}
inorea[bbrev]   [<expr>] [lhs] [rhs]
inoreme[nu]     {menu}
int[ro]
is[earch]       [count] [/]pattern[/]
isp[lit]        [count] [/]pattern[/]
iu[nmap]        {lhs}
iuna[bbrev]     {lhs}
iunme[nu]       {menu}
j[oin]          {count} [flags]
ju[mps]
kee[pmarks]     {command}
keep[jumps]     {command}
keepa[lt]       {cmd}
lN[ext]
lNf[ile]
l[ist]          [count] [flags]
la[st]          [++opt] [+cmd]
lad[dexpr]      {expr}
laddb[uffer]    [bufnr]
laddf[ile]      [errorfile]
lan[guage]      {name} | mes[sages] {name} | cty[pe] {name} | tim[e] {name}
lat[er]         {count} | {N}s | {N}m | {N}h
lb[uffer]       [bufnr]
lc[d]           {path}
lch[dir]        {path}
lcl[ose]
lcs[cope]       add {file|dir} [pre-path] [flags] | find {querytype} {name} | kill {num|partial_name} | help | reset | show
le[ft]          [indent]
lefta[bove]     {cmd}
let             {var-name} = {expr1}
lex[pr]         {expr}
lf[ile]         [errorfile]
lfir[st]        [nr]
lg[etfile]      [errorfile]
lgetb[uffer]    [bufnr]
lgete[xpr]      {expr}
lgr[ep]         [arguments]
lgrepa[dd]      [arguments]
lh[elpgrep]     {pattern}[@xx]
ll              [nr]
lla[st]         [nr]
lli[st]         [from] [, [to]]
lm[ap]          {lhs} {rhs}
lmak[e]         [arguments]
lmapc[lear]
ln[oremap]      {lhs} {rhs}
lne[xt]
lnew[er]        [count]
lnf[ile]
lo[adview]      [nr]
loadk[eymap]
loc[kmarks]     {command}
lockv[ar]       [depth] {name} ...
lol[der]        [count]
lop[en]         [height]
lp[revious]
lpf[ile]
lr[ewind]       [nr]
ls
lt[ag]          [ident]
lua             {chunk} | << {endmarker}
luado           {body}
luafile         {file}
lu[nmap]        {lhs}
lv[imgrep]      /{pattern}/[g][j] {file} ... | {pattern} {file} ...
lvimgrepadd     /{pattern}/[g][j] {file} ... | {pattern} {file} ...
lwindow         [height]
m[ove]          {address}
ma[rk]          {a-zA-z'}
mak[e]          [arguments]
map             {lhs} {rhs}
mapc[lear]
marks
match           {group} /{pattern}/
menu            {menu}
menut[ranslate] clear | {english} {mylang}
mes[sages]      
mk[exrc]        [file]
mks[ession]     [file]
mksp[ell]       [-ascii] {outname} {inname} ...
mkv[imrc]       [file]
mkvie[w]        [file]
mod[e]          [mode]
mz[scheme]      {stmt} | << {endmarker} {script} {endmarker} | {file}
mzf[ile]        {file}
n[ext]          [++opt] [+cmd]
nb[key]         key
new
nm[ap]          {lhs} {rhs}
nmapc[lear]
nmenu           {menu}
nno[remap]      {lhs} {rhs}
nnoreme[nu]     {menu}
no[remap]       {lhs} {rhs} 
noa[utocmd]     {cmd}
noh[lsearch]    
norea[bbrev]    [<expr>] [lhs] [rhs]
noreme[nu]      {menu}
norm[al]        {commands}
nu[mber]        [count] [flags]
nun[map]        {lhs}
nunme[nu]       {menu}
o[pen]          /pattern/
ol[dfiles]
om[ap]          {lhs} {rhs}
omapc[lear]
ome[nu]         {menu}
on[ly]
ono[remap]      {lhs} {rhs}
onoreme[nu]     {menu}
opt[ions]
ou[nmap]        {lhs}
ounmenu         {menu}
ownsyntax       list {group-name} | list @{cluster-name}
p[rint]         {count} [flags]
pc[lose]
pe[rl]          {cmd} | << {endpattern} {script} {endpattern}
ped[it]         [++opt] [+cmd] {file}
perld[o]        {cmd}
po[p]
popu[p]         {name}
pp[op]
pre[serve]
prev[ious]      [count] [++opt] [+cmd]
prof[ile]       start {fname} | pause | continue | func {pattern} | file {pattern}
profd[el]       ...
promptf[ind]    [string]
promptr[epl]    [string]
ps[earch]       [count] [/]pattern[/]
ptN[ext]
pta[g]          [tagname]
ptf[irst]
ptj[ump]
ptl[ast]
ptn[ext]
ptp[revious]
ptr[ewind]
pts[elect]      [ident]
pu[t]           [x]
pw[d]
py[thon]        {stmt} | << {endmarker} {script} {endmarker}
python3         {stmt} | << {endmarker} {script} {endmarker}
pyf[ile]        {file}
py3f[ile]       {file}
q[uit]
qa[ll]
quita[ll]
r[ead]          [++opt] [name]
rec[over]       [file]
red[o]
redi[r]         > {file} | >> {file} | @{a-zA-Z} | => {var} | END
redr[aw]
redraws[tatus]
reg[isters]     {arg}
res[ize]
ret[ab]         [new_tabstop]
retu[rn]        [expr]
rew[ind]        [++opt] [+cmd]
ri[ght]         [width]
rightb[elow]    {cmd}
rub[y]          {cmd} | << {endpattern} {script} {endpattern}
rubyd[o]        {cmd}
rubyf[ile]      {file}
runtime         {file} ..
rv[iminfo]      [file]
sN[ext]         [++opt] [+cmd] [N]
s[ubstitute]    /{pattern}/{string}/[flags] [count]
sa[rgument]     [++opt] [+cmd] [N]
sal[l]
san[dbox]       {cmd}
sav[eas]        [++opt] {file}
sbN[ext]        [N]
sb[uffer]       {bufname}
sba[ll]         [N]
sbf[irst]
sbl[ast]
sbm[odified]    [N]
sbn[ext]        [N]
sbp[revious]    [N]
sbr[ewind]
scrip[tnames]
scripte[ncoding] [encoging]
scscope               add {file|dir} [pre-path] [flags] | find {querytype} {name} | kill {num|partial_name} | help | reset | show
se[t]                 {option}={value} {option}? | {option} | {option}&
setf[iletype]   {filetype}
setg[lobal]     ...
setl[ocal]      ...
sf[ind]         [++opt] [+cmd] {file}
sfir[st]        [++opt] [+cmd]
sh[ell]
sig[n]          define {name} {argument}... | icon={pixmap} | linehl={group} | text={text} | texthl={group}
sil[ent]        {command}
sim[alt]        {key}
sl[eep]         [N] [m]
sla[st]         [++opt] [+cmd]
sm[agic]        ...
sm[ap]          {lhs} {rhs}
smapc[lear]
sme[nu]         {menu}
sn[ext]         [++opt] [+cmd] [file ..]
sni[ff]         request [symbol]
sno[remap]      {lhs} {rhs}
snoreme[nu]     {menu}
so[urce]        {file}
sor[t]          [i][u][r][n][x][o] [/{pattern}/]
sp[lit]         [++opt] [+cmd]
spe[llgood]     {word}
spelld[ump]
spelli[nfo]     
spellr[epall]
spellu[ndo]     {word}
spellw[rong]    {word}
spr[evious]     [++opt] [+cmd] [N]
sre[wind]       [++opt] [+cmd]
st[op]
sta[g]          [tagname]
star[tinsert]
startg[replace]
startr[eplace]
stj[ump]        [ident]
stopi[nsert]
sts[elect]      [ident]
sun[hide]       [N]
sunm[ap]        {lhs}
sunme[nu]       {menu}
sus[pend]
sv[iew]         [++opt] [+cmd] {file}
sw[apname]
sy[ntax]        list {group-name} | list @{cluster-name}
sync[bind]
t
tN[ext]
ta[g]           {ident}
tab             {cmd}
tabN[ext]
tabc[lose]
tabd[o]         {cmd}
tabe[dit]       [++opt] [+cmd] {file}
tabf[ind]       [++opt] [+cmd] {file}
tabfir[st]
tabl[ast]
tabm[ove]       [N]
tabn[ext]
tabnew          [++opt] [+cmd] {file}
tabo[nly]
tabp[revious]
tabr[ewind]
tabs
tags
tc[l]           {cmd} | {endmarker} {script} {endmarker}
tcld[o]         {cmd}
tclf[ile]       {file}
te[aroff]       {name}
tf[irst]
th[row]         {expr1}
tj[ump]         [ident]
tl[ast]         
tm[enu]         {menu}
tn[ext]
to[pleft]       {cmd}
tp[revious]
tr[ewind]
try
tselect
tu[nmenu]       {menu}
u[ndo]          {N}
una[bbreviate]  {lhs}
undoj[oin]
undol[ist]
unh[ide]        [N]
unl[et]         {name} ...
unlo[ckvar]     [depth] {name} ...
unm[ap]         {lhs}
unme[nu]        {menu}
uns[ilent]      {command}
up[date]        [++opt] [>>] [file]
ve[rsion]
verb[ose]       {command}
vert[ical]      {cmd}
vg[lobal]       /{pattern}/[cmd]
vi[sual]        [++opt] [+cmd] [file]
vie[w]          [++opt] [+cmd] file
vim[grep]       /{pattern}/[g][j] {file} ... | {pattern} {file} ...
vimgrepa[dd]    /{pattern}/[g][j] {file} ... | {pattern} {file} ...
viu[sage]
vm[ap]          {lhs} {rhs}
vmapc[lear]
vmenu           {menu}
vn[oremap]      {lhs} {rhs}
vne[w]          [++opt] [+cmd] [file]
vnoremenu       {menu}
vsp[lit]        [++opt] [+cmd] [file]
vu[nmap]        {lhs}
vunmenu         {menu}
wN[ext]         [++opt] [file]
w[rite]         [++opt] [file]
wa[ll]
wh[ile]         {expr1}
win[size]       {width} {height}
winc[md]        {arg}
windo           {cmd}
winp[os]        {X} {Y}
wn[ext]         [++opt]
wp[revious]     [++opt] [file]
wq              [++opt]
wqa[ll]         [++opt]
ws[verb]        verb
wv[iminfo]      [file]
x[it]           [++opt] [file]
xa[ll]          [++opt]
xm[ap]          {lhs} {rhs}
xmapc[lear]
xmenu           {menu}
xn[oremap]      {lhs} {rhs}
xnoremenu       {menu}
xu[nmap]        {lhs}
xunmenu         {menu}
y[ank]          [x] {count}
autoload/neocomplcache/sources/vim_complete/command_replaces.dict	[[[1
10
<line1> ; the starting line of the command range
<line2> ; the final line of the command range
<count> ; any count supplied (as described for the '-range' and '-count' attributes)
<bang> ; expands to a ! if the command was executed with a ! modifier
<reg> ; the optional register, if specified
<args> ; the command arguments, exactly as supplied
<lt> ; a single '<' (Less-Than) character
<q-args> ; the value is quoted in such a way as to make it a valid value for use in an expression
<f-args> ; splits the command arguments at spaces and tabs, quotes each argument individually
<sid> ; defining a user command in a script
autoload/neocomplcache/sources/vim_complete/commands.dict	[[[1
492
Next	; go to previous file in the argument list
Print	; print lines
abbreviate	; enter abbreviation
abclear	; remove all abbreviations
aboveleft	; make split window appear left or above
all	; open a window for each file in the argument list
amenu	; enter new menu item for all modes
anoremenu	; enter a new menu for all modes that will not be remapped
append	; append text
argadd	; add items to the argument list
argdelete	; delete items from the argument list
argdo	; do a command on all items in the argument list
argedit	; add item to the argument list and edit it
argglobal	; define the global argument list
arglocal	; define a local argument list
args	; print the argument list
argument	; go to specific file in the argument list
ascii	; print ascii value of character under the cursor
augroup	; select the autocommand group to use
aunmenu	; remove menu for all modes
autocmd	; enter or show autocommands
bNext	; go to previous buffer in the buffer list
badd	; add buffer to the buffer list
ball	; open a window for each buffer in the buffer list
bdelete	; remove a buffer from the buffer list
behave	; set mouse and selection behavior
belowright	; make split window appear right or below
bfirst	; go to first buffer in the buffer list
blast	; go to last buffer in the buffer list
bmodified	; go to next buffer in the buffer list that has been modified
bnext	; go to next buffer in the buffer list
botright	; make split window appear at bottom or far right
bprevious	; go to previous buffer in the buffer list
break	; break out of while loop
breakadd	; add a debugger breakpoint
breakdel	; delete a debugger breakpoint
breaklist	; list debugger breakpoints
brewind	; go to first buffer in the buffer list
browse	; use file selection dialog
bufdo	; execute command in each listed buffer
buffer	; go to specific buffer in the buffer list
buffers	; list all files in the buffer list
bunload	; unload a specific buffer
bwipeout	; really delete a buffer
cNext	; go to previous error
cNfile	; go to last error in previous file
cabbrev	; like "abbreviate" but for Command-line mode
cabclear	; clear all abbreviations for Command-line mode
caddbuffer	; add errors from buffer
caddexpr	; add errors from expr
caddfile	; add error message to current quickfix list
call	; call a function
catch	; part of a try command
cbuffer	; parse error messages and jump to first error
cclose	; close quickfix window
center	; format lines at the center
cexpr	; read errors from expr and jump to first
cfile	; read file with error messages and jump to first
cfirst	; go to the specified error, default first one
cgetbuffer	; get errors from buffer
cgetexpr	; get errors from expr
cgetfile	; read file with error messages
change	; replace a line or series of lines
changes	; print the change list
chdir	; change directory
checkpath	; list included files
checktime	; check timestamp of loaded buffers
clast	; go to the specified error, default last one
clist	; list all errors
close	; close current window
cmap	; like "map" but for Command-line mode
cmapclear	; clear all mappings for Command-line mode
cmenu	; add menu for Command-line mode
cnewer	; go to newer error list
cnext	; go to next error
cnfile	; go to first error in next file
cnoreabbrev	; like "noreabbrev" but for Command-line mode
cnoremap	; like "noremap" but for Command-line mode
cnoremenu	; like "noremenu" but for Command-line mode
colder	; go to older error list
colorscheme	; load a specific color scheme
comclear	; clear all user-defined commands
command	; create user-defined command
compiler	; do settings for a specific compiler
confirm	; prompt user when confirmation required
continue	; go back to while
copen	; open quickfix window
copy	; copy lines
cpfile	; go to last error in previous file
cprevious	; go to previous error
cquit	; quit Vim with an error code
crewind	; go to the specified error, default first one
cscope	; execute cscope command
cstag	; use cscope to jump to a tag
cunabbrev	; like "unabbrev" but for Command-line mode
cunmap	; like "unmap" but for Command-line mode
cunmenu	; remove menu for Command-line mode
cwindow	; open or close quickfix window
debug	; run a command in debugging mode
debuggreedy	; read debug mode commands from normal input
delcommand	; delete user-defined command
delete	; delete lines
delfunction	; delete a user function
delmarks	; delete marks
diffget	; remove differences in current buffer
diffoff	; switch off diff mode
diffpatch	; apply a patch and show differences
diffput	; remove differences in other buffer
diffsplit	; show differences with another file
diffthis	; make current window a diff window
diffupdate	; update 'diff' buffers
digraphs	; show or enter digraphs
display	; display registers
djump	; jump to #define
dlist	; list #defines
doautoall	; apply autocommands for all loaded buffers
doautocmd	; apply autocommands to current buffer
drop	; jump to window editing file or edit file in current window
dsearch	; list one #define
dsplit	; split window and jump to #define
earlier	; go to older change, undo
echo	; echoes the result of expressions
echoerr	; like echo, show like an error and use history
echohl	; set highlighting for echo commands
echomsg	; same as echo, put message in history
echon	; same as echo, but without <EOL>
edit	; edit a file
else	; part of an if command
elseif	; part of an if command
emenu	; execute a menu by name
endfor	; end previous for
endfunction	; end of a user function
endif	; end previous if
endtry	; end previous try
endwhile	; end previous while
enew	; edit a new, unnamed buffer
execute	; execute result of expressions
exit	; same as "xit"
exusage	; overview of Ex commands
file	; show or set the current file name
files	; list all files in the buffer list
filetype	; switch file type detection on/off
finally	; part of a try command
find	; find file in 'path' and edit it
finish	; quit sourcing a Vim script
first	; go to the first file in the argument list
fixdel	; set key code of <Del>
fold	; create a fold
foldclose	; close folds
folddoclosed	; execute command on lines in a closed fold
folddoopen	; execute command on lines not in a closed fold
foldopen	; open folds
for	; for loop
function	; define a user function
global	; execute commands for matching lines
goto	; go to byte in the buffer
grep	; run 'grepprg' and jump to first match
grepadd	; like grep, but append to current list
gui	; start the GUI
gvim	; start the GUI
hardcopy	; send text to the printer
help	; open a help window
helpfind	; dialog to open a help window
helpgrep	; like "grep" but searches help files
helptags	; generate help tags for a directory
hide	; hide current buffer for a command
highlight	; specify highlighting methods
history	; print a history list
iabbrev	; like "abbrev" but for Insert mode
iabclear	; like "abclear" but for Insert mode
ijump	; jump to definition of identifier
ilist	; list lines where identifier matches
imap	; like "map" but for Insert mode
imapclear	; like "mapclear" but for Insert mode
imenu	; add menu for Insert mode
inoreabbrev	; like "noreabbrev" but for Insert mode
inoremap	; like "noremap" but for Insert mode
inoremenu	; like "noremenu" but for Insert mode
insert	; insert text
intro	; print the introductory message
isearch	; list one line where identifier matches
isplit	; split window and jump to definition of identifier
iunabbrev	; like "unabbrev" but for Insert mode
iunmap	; like "unmap" but for Insert mode
iunmenu	; remove menu for Insert mode
join	; join lines
jumps	; print the jump list
keepalt	; following command keeps the alternate file
keepjumps	; following command keeps jumplist and marks
keepmarks	; following command keeps marks where they are
lNext	; go to previous entry in location list
lNfile	; go to last entry in previous file
laddbuffer	; add locations from buffer
laddexpr	; add locations from expr
laddfile	; add locations to current location list
language	; set the language (locale)
last	; go to the last file in the argument list
later	; go to newer change, redo
lbuffer	; parse locations and jump to first location
lcd	; change directory locally
lchdir	; change directory locally
lclose	; close location window
lcscope	; like "cscope" but uses location list
left	; left align lines
leftabove	; make split window appear left or above
let	; assign a value to a variable or option
lexpr	; read locations from expr and jump to first
lfile	; read file with locations and jump to first
lfirst	; go to the specified location, default first one
lgetbuffer	; get locations from buffer
lgetexpr	; get locations from expr
lgetfile	; read file with locations
lgrep	; run 'grepprg' and jump to first match
lgrepadd	; like grep, but append to current list
lhelpgrep	; like "helpgrep" but uses location list
list	; print lines
llast	; go to the specified location, default last one
llist	; list all locations
lmake	; execute external command 'makeprg' and parse error messages
lmap	; like "map!" but includes Lang-Arg mode
lmapclear	; like "mapclear!" but includes Lang-Arg mode
lnewer	; go to newer location list
lnext	; go to next location
lnfile	; go to first location in next file
lnoremap	; like "noremap!" but includes Lang-Arg mode
loadkeymap	; load the following keymaps until EOF
loadview	; load view for current window from a file
lockmarks	; following command keeps marks where they are
lockvar	; lock variables
lolder	; go to older location list
lopen	; open location window
lpfile	; go to last location in previous file
lprevious	; go to previous location
lrewind	; go to the specified location, default first one
ltag	; jump to tag and add matching tags to the location list
lua	; execute Lua chunk.
luado	; execute Lua function.
luafile	; execute Lua script in file.
lunmap	; like "unmap!" but includes Lang-Arg mode
lvimgrep	; search for pattern in files
lvimgrepadd	; like vimgrep, but append to current list
lwindow	; open or close location window
make	; execute external command 'makeprg' and parse error messages
map	; show or enter a mapping
mapclear	; clear all mappings for Normal and Visual mode
mark	; set a mark
marks	; list all marks
match	; define a match to highlight
menu	; enter a new menu item
menutranslate	; add a menu translation item
messages	; view previously displayed messages
mkexrc	; write current mappings and settings to a file
mksession	; write session info to a file
mkspell	; produce .spl spell file
mkview	; write view of current window to a file
mkvimrc	; write current mappings and settings to a file
mode	; show or change the screen mode
move	; move lines
mzfile	; execute MzScheme script file
mzscheme	; execute MzScheme command
nbkey	; pass a key to Netbeans
new	; create a new empty window
next	; go to next file in the argument list
nmap	; like "map" but for Normal mode
nmapclear	; clear all mappings for Normal mode
nmenu	; add menu for Normal mode
nnoremap	; like "noremap" but for Normal mode
nnoremenu	; like "noremenu" but for Normal mode
noautocmd	; following command don't trigger autocommands
nohlsearch	; suspend 'hlsearch' highlighting
noreabbrev	; enter an abbreviation that will not be remapped
noremap	; enter a mapping that will not be remapped
noremenu	; enter a menu that will not be remapped
normal	; execute Normal mode commands
number	; print lines with line number
nunmap	; like "unmap" but for Normal mode
nunmenu	; remove menu for Normal mode
oldfiles	; list files that have marks in the viminfo file
omap	; like "map" but for Operator-pending mode
omapclear	; remove all mappings for Operator-pending mode
omenu	; add menu for Operator-pending mode
only	; close all windows except the current one
onoremap	; like "noremap" but for Operator-pending mode
onoremenu	; like "noremenu" but for Operator-pending mode
open	; start open mode (not implemented)
options	; open the options-window
ounmap	; like "unmap" but for Operator-pending mode
ounmenu	; remove menu for Operator-pending mode
ownsyntax	; define Window-local syntax
pclose	; close preview window
pedit	; edit file in the preview window
perl	; execute Perl command
perldo	; execute Perl command for each line
pop	; jump to older entry in tag stack
popup	; popup a menu by name
ppop	; "pop" in preview window
preserve	; write all text to swap file
previous	; go to previous file in argument list
print	; print lines
profdel	; stop profiling a function or script
profile	; profiling functions and scripts
promptfind	; open GUI dialog for searching
promptrepl	; open GUI dialog for search/replace
psearch	; like "ijump" but shows match in preview window
ptNext	; tNext in preview window
ptag	; show tag in preview window
ptfirst	; trewind in preview window
ptjump	; tjump and show tag in preview window
ptlast	; tlast in preview window
ptnext	; tnext in preview window
ptprevious	; tprevious in preview window
ptrewind	; trewind in preview window
ptselect	; tselect and show tag in preview window
put	; insert contents of register in the text
pwd	; print current directory
py3file	; execute Python3 script file
pyfile	; execute Python script file
python	; execute Python command
python3	; execute Python3 command
qall	; quit Vim
quit	; quit current window (when one window quit Vim)
quitall	; quit Vim
read	; read file into the text
recover	; recover a file from a swap file
redir	; redirect messages to a file or register
redo	; redo one undone change
redraw	; force a redraw of the display
redrawstatus	; force a redraw of the status line(s)
registers	; display the contents of registers
resize	; change current window height
retab	; change tab size
return	; return from a user function
rewind	; go to the first file in the argument list
right	; right align text
rightbelow	; make split window appear right or below
ruby	; execute Ruby command
rubydo	; execute Ruby command for each line
rubyfile	; execute Ruby script file
runtime	; source vim scripts in 'runtimepath'
rviminfo	; read from viminfo file
sNext	; split window and go to previous file in argument list
sall	; open a window for each file in argument list
sandbox	; execute a command in the sandbox
sargument	; split window and go to specific file in argument list
saveas	; save file under another name.
sbNext	; split window and go to previous file in the buffer list
sball	; open a window for each file in the buffer list
sbfirst	; split window and go to first file in the buffer list
sblast	; split window and go to last file in buffer list
sbmodified	; split window and go to modified file in the buffer list
sbnext	; split window and go to next file in the buffer list
sbprevious	; split window and go to previous file in the buffer list
sbrewind	; split window and go to first file in the buffer list
sbuffer	; split window and go to specific file in the buffer list
scriptencoding	; encoding used in sourced Vim script
scriptnames	; list names of all sourced Vim scripts
scscope	; split window and execute cscope command
set	; show or set options
setfiletype	; set 'filetype', unless it was set already
setglobal	; show global values of options
setlocal	; show or set options locally
sfind	; split current window and edit file in 'path'
sfirst	; split window and go to first file in the argument list
shell	; escape to a shell
sign	; manipulate signs
silent	; run a command silently
simalt	; Win32 GUI simulate Windows ALT key
slast	; split window and go to last file in the argument list
sleep	; do nothing for a few seconds
smagic	; substitute with 'magic'
smap	; like "map" but for Select mode
smapclear	; remove all mappings for Select mode
smenu	; add menu for Select mode
snext	; split window and go to next file in the argument list
sniff	; send request to sniff
snomagic	; substitute with 'nomagic'
snoremap	; like "noremap" but for Select mode
snoremenu	; like "noremenu" but for Select mode
sort	; sort lines
source	; read Vim or Ex commands from a file
spelldump	; split window and fill with all correct words
spellgood	; add good word for spelling
spellinfo	; show info about loaded spell files
spellrepall	; replace all bad words like last z=
spellundo	; remove good or bad word
spellwrong	; add spelling mistake
split	; split current window
sprevious	; split window and go to previous file in the argument list
srewind	; split window and go to first file in the argument list
stag	; split window and jump to a tag
startgreplace	; start Virtual Replace mode
startinsert	; start Insert mode
startreplace	; start Replace mode
stjump	; do "tjump" and split window
stop	; suspend the editor or escape to a shell
stopinsert	; stop Insert mode
stselect	; do "tselect" and split window
substitute	; find and replace text
sunhide	; same as "unhide"
sunmap	; like "unmap" but for Select mode
sunmenu	; remove menu for Select mode
suspend	; same as "stop"
sview	; split window and edit file read-only
swapname	; show the name of the current swap file
syncbind	; sync scroll binding
syntax	; syntax highlighting
tNext	; jump to previous matching tag
tab	; create new tab when opening new window
tabNext	; go to previous tab page
tabclose	; close current tab page
tabdo	; execute command in each tab page
tabedit	; edit a file in a new tab page
tabfind	; find file in 'path', edit it in a new tab page
tabfirst	; got to first tab page
tablast	; got to last tab page
tabmove	; move tab page to other position
tabnew	; edit a file in a new tab page
tabnext	; go to next tab page
tabonly	; close all tab pages except the current one
tabprevious	; go to previous tab page
tabrewind	; got to first tab page
tabs	; list the tab pages and what they contain
tag	; jump to tag
tags	; show the contents of the tag stack
tcl	; execute Tcl command
tcldo	; execute Tcl command for each line
tclfile	; execute Tcl script file
tearoff	; tear-off a menu
tfirst	; jump to first matching tag
throw	; throw an exception
tjump	; like "tselect", but jump directly when there is only one match
tlast	; jump to last matching tag
tmenu	; define menu tooltip
tnext	; jump to next matching tag
topleft	; make split window appear at top or far left
tprevious	; jump to previous matching tag
trewind	; jump to first matching tag
try	; execute commands, abort on error or exception
tselect	; list matching tags and select one
tunmenu	; remove menu tooltip
unabbreviate	; remove abbreviation
undo	; undo last change(s)
undojoin	; join next change with previous undo block
undolist	; list leafs of the undo tree
unhide	; open a window for each loaded file in the buffer list
unlet	; delete variable
unlockvar	; unlock variables
unmap	; remove mapping
unmenu	; remove menu
unsilent	; run a command not silently
update	; write buffer if modified
verbose	; execute command with 'verbose' set
version	; print version number and other info
vertical	; make following command split vertically
vglobal	; execute commands for not matching lines
view	; edit a file read-only
vimgrep	; search for pattern in files
vimgrepadd	; like vimgrep, but append to current list
visual	; same as "edit", but turns off "Ex" mode
viusage	; overview of Normal mode commands
vmap	; like "map" but for Visual+Select mode
vmapclear	; remove all mappings for Visual+Select mode
vmenu	; add menu for Visual+Select mode
vnew	; create a new empty window, vertically split
vnoremap	; like "noremap" but for Visual+Select mode
vnoremenu	; like "noremenu" but for Visual+Select mode
vsplit	; split current window vertically
vunmap	; like "unmap" but for Visual+Select mode
vunmenu	; remove menu for Visual+Select mode
wNext	; write to a file and go to previous file in argument list
wall	; write all (changed) buffers
while	; execute loop for as long as condition met
wincmd	; execute a Window (CTRL-W) command
windo	; execute command in each window
winpos	; get or set window position
winsize	; get or set window size (obsolete)
wnext	; write to a file and go to next file in argument list
wprevious	; write to a file and go to previous file in argument list
wqall	; write all changed buffers and quit Vim
write	; write to a file
wsverb	; pass the verb to workshop over IPC
wviminfo	; write to viminfo file
xall	; same as "wqall"
xit	; write if buffer changed and quit window or Vim
xmap	; like "map" but for Visual mode
xmapclear	; remove all mappings for Visual mode
xmenu	; add menu for Visual mode
xnoremap	; like "noremap" but for Visual mode
xnoremenu	; like "noremenu" but for Visual mode
xunmap	; like "unmap" but for Visual mode
xunmenu	; remove menu for Visual mode
yank	; yank lines into a register
autoload/neocomplcache/sources/vim_complete/features.dict	[[[1
148
all_builtin_terms ; Compiled with all builtin terminals enabled.
amiga ; Amiga version of Vim.
arabic ; Compiled with Arabic support |Arabic|.
arp ; Compiled with ARP support (Amiga).
autocmd ; Compiled with autocommand support. |autocommand|
balloon_eval ; Compiled with |balloon-eval| support.
balloon_multiline ; GUI supports multiline balloons.
beos ; BeOS version of Vim.
browse ; Compiled with |:browse| support, and browse() will work.
builtin_terms ; Compiled with some builtin terminals.
byte_offset ; Compiled with support for 'o' in 'statusline'
cindent ; Compiled with 'cindent' support.
clientserver ; Compiled with remote invocation support |clientserver|.
clipboard ; Compiled with 'clipboard' support.
cmdline_compl ; Compiled with |cmdline-completion| support.
cmdline_hist ; Compiled with |cmdline-history| support.
cmdline_info ; Compiled with 'showcmd' and 'ruler' support.
comments ; Compiled with |'comments'| support.
cryptv ; Compiled with encryption support |encryption|.
cscope ; Compiled with |cscope| support.
compatible ; Compiled to be very Vi compatible.
debug ; Compiled with "DEBUG" defined.
dialog_con ; Compiled with console dialog support.
dialog_gui ; Compiled with GUI dialog support.
diff ; Compiled with |vimdiff| and 'diff' support.
digraphs ; Compiled with support for digraphs.
dnd ; Compiled with support for the "~ register |quote_~|.
dos32 ; 32 bits DOS (DJGPP) version of Vim.
dos16 ; 16 bits DOS version of Vim.
ebcdic ; Compiled on a machine with ebcdic character set.
emacs_tags ; Compiled with support for Emacs tags.
eval ; Compiled with expression evaluation support. Always true, of course!
ex_extra ; Compiled with extra Ex commands |+ex_extra|.
extra_search ; Compiled with support for |'incsearch'| and |'hlsearch'|
farsi ; Compiled with Farsi support |farsi|.
file_in_path ; Compiled with support for |gf| and |<cfile>|
filterpipe ; When 'shelltemp' is off pipes are used for shell read/write/filter commands
find_in_path ; Compiled with support for include file searches |+find_in_path|.
float ; Compiled with support for |Float|.
fname_case ; Case in file names matters (for Amiga, MS-DOS, and Windows this is not present).
folding ; Compiled with |folding| support.
footer ; Compiled with GUI footer support. |gui-footer|
fork ; Compiled to use fork()/exec() instead of system().
gettext ; Compiled with message translation |multi-lang|
gui ; Compiled with GUI enabled.
gui_athena ; Compiled with Athena GUI.
gui_gtk ; Compiled with GTK+ GUI (any version).
gui_gtk2 ; Compiled with GTK+ 2 GUI (gui_gtk is also defined).
gui_gnome ; Compiled with Gnome support (gui_gtk is also defined).
gui_mac ; Compiled with Macintosh GUI.
gui_motif ; Compiled with Motif GUI.
gui_photon ; Compiled with Photon GUI.
gui_win32 ; Compiled with MS Windows Win32 GUI.
gui_win32s ; idem, and Win32s system being used (Windows 3.1)
gui_running ; Vim is running in the GUI, or it will start soon.
hangul_input ; Compiled with Hangul input support. |hangul|
iconv ; Can use iconv() for conversion.
insert_expand ; Compiled with support for CTRL-X expansion commands in Insert mode.
jumplist ; Compiled with |jumplist| support.
keymap ; Compiled with 'keymap' support.
langmap ; Compiled with 'langmap' support.
libcall ; Compiled with |libcall()| support.
linebreak ; Compiled with 'linebreak', 'breakat' and 'showbreak' support.
lispindent ; Compiled with support for lisp indenting.
listcmds ; Compiled with commands for the buffer list |:files| and the argument list |arglist|.
localmap ; Compiled with local mappings and abbr. |:map-local|
mac ; Macintosh version of Vim.
macunix ; Macintosh version of Vim, using Unix files (OS-X).
menu ; Compiled with support for |:menu|.
mksession ; Compiled with support for |:mksession|.
modify_fname ; Compiled with file name modifiers. |filename-modifiers|
mouse ; Compiled with support mouse.
mouseshape ; Compiled with support for 'mouseshape'.
mouse_dec ; Compiled with support for Dec terminal mouse.
mouse_gpm ; Compiled with support for gpm (Linux console mouse)
mouse_netterm ; Compiled with support for netterm mouse.
mouse_pterm ; Compiled with support for qnx pterm mouse.
mouse_sysmouse ; Compiled with support for sysmouse (*BSD console mouse)
mouse_xterm ; Compiled with support for xterm mouse.
multi_byte ; Compiled with support for 'encoding'
multi_byte_encoding ; 'encoding' is set to a multi-byte encoding.
multi_byte_ime ; Compiled with support for IME input method.
multi_lang ; Compiled with support for multiple languages.
mzscheme ; Compiled with MzScheme interface |mzscheme|.
netbeans_intg ; Compiled with support for |netbeans|.
netbeans_enabled ; Compiled with support for |netbeans| and it's used.
ole ; Compiled with OLE automation support for Win32.
os2 ; OS/2 version of Vim.
osfiletype ; Compiled with support for osfiletypes |+osfiletype|
path_extra ; Compiled with up/downwards search in 'path' and 'tags'
perl ; Compiled with Perl interface.
postscript ; Compiled with PostScript file printing.
printer ; Compiled with |:hardcopy| support.
profile ; Compiled with |:profile| support.
python ; Compiled with Python interface.
qnx ; QNX version of Vim.
quickfix ; Compiled with |quickfix| support.
reltime ; Compiled with |reltime()| support.
rightleft ; Compiled with 'rightleft' support.
ruby ; Compiled with Ruby interface |ruby|.
scrollbind ; Compiled with 'scrollbind' support.
showcmd ; Compiled with 'showcmd' support.
signs ; Compiled with |:sign| support.
smartindent ; Compiled with 'smartindent' support.
sniff ; Compiled with SNiFF interface support.
statusline ; Compiled with |--startuptime| support.
sun_workshop ; Compiled with support for Sun |workshop|.
spell ; Compiled with spell checking support |spell|.
syntax ; Compiled with syntax highlighting support |syntax|.
syntax_items ; There are active syntax highlighting items for the current buffer.
system ; Compiled to use system() instead of fork()/exec().
tag_binary ; Compiled with binary searching in tags files |tag-binary-search|.
tag_old_static ; Compiled with support for old static tags |tag-old-static|.
tag_any_white ; Compiled with support for any white characters in tags files |tag-any-white|.
tcl ; Compiled with Tcl interface.
terminfo ; Compiled with terminfo instead of termcap.
termresponse ; Compiled with support for |t_RV| and |v:termresponse|.
textobjects ; Compiled with support for |text-objects|.
tgetent ; Compiled with tgetent support, able to use a termcap or terminfo file.
title ; Compiled with window title support |'title'|.
toolbar ; Compiled with support for |gui-toolbar|.
unix ; Unix version of Vim.
user_commands ; User-defined commands.
viminfo ; Compiled with viminfo support.
vim_starting ; True while initial source'ing takes place.
vertsplit ; Compiled with vertically split windows |:vsplit|.
virtualedit ; Compiled with 'virtualedit' option.
visual ; Compiled with Visual mode.
visualextra ; Compiled with extra Visual mode commands.
vms ; VMS version of Vim.
vreplace ; Compiled with |gR| and |gr| commands.
wildignore ; Compiled with 'wildignore' option.
wildmenu ; Compiled with 'wildmenu' option.
windows ; Compiled with support for more than one window.
winaltkeys ; Compiled with 'winaltkeys' option.
win16 ; Win16 version of Vim (MS-Windows 3.1).
win32 ; Win32 version of Vim (MS-Windows 95/98/ME/NT/2000/XP).
win64 ; Win64 version of Vim (MS-Windows 64 bit).
win32unix ; Win32 version of Vim, using Unix files (Cygwin)
win95 ; Win32 version for MS-Windows 95/98/ME.
writebackup ; Compiled with 'writebackup' default on.
xfontset ; Compiled with X fontset support |xfontset|.
xim ; Compiled with X input method support |xim|.
xsmp ; Compiled with X session management support.
xsmp_interact ; Compiled with interactive X session management support.
xterm_clipboard ; Compiled with support for xterm clipboard.
xterm_save ; Compiled with support for saving and restoring the xterm screen.
x11 ; Compiled with X11 support.
autoload/neocomplcache/sources/vim_complete/functions.dict	[[[1
252
abs({expr})
acos({expr})
add({list}, {item})
append({lnum}, {list})
append({lnum}, {string})
argc()
argidx()
argv()
argv({nr})
asin({expr})
atan({expr})
atan2({expr1}, {expr2})
browse({save}, {title}, {initdir}, {default})
browsedir({title}, {initdir})
bufexists({expr})
buflisted({expr})
bufloaded({expr})
bufname({expr})
bufnr({expr})
bufwinnr({expr})
byte2line({byte})
byteidx({expr}, {nr})
call({func}, {arglist} [, {dict}])
ceil({expr})
changenr()
char2nr({expr})
cindent({lnum})
clearmatches()
col({expr})
complete({startcol}, {matches})
complete_add({expr})
complete_check()
confirm({msg} [, {choices} [, {default} [, {type}]]])
copy({expr})
cos({expr})
cosh({expr})
count({list}, {expr} [, {start} [, {ic}]])
cscope_connection([{num} , {dbpath} [, {prepend}]])
cursor({list})
cursor({lnum}, {col} [, {coladd}])
deepcopy({expr})
delete({fname})
did_filetype()
diff_filler({lnum})
diff_hlID({lnum}, {col})
empty({expr})
escape({string}, {chars})
eval({string})
eventhandler()
executable({expr})
exists({expr})
exp({expr})
expand({expr} [, {flag}])
extend({expr1}, {expr2} [, {expr3}])
feedkeys({string} [, {mode}])
filereadable({file})
filewritable({file})
filter({expr}, {string})
finddir({name}[, {path}[, {count}]])
findfile({name}[, {path}[, {count}]])
float2nr({expr})
floor({expr})
fmod({expr1}, {expr2})
fnameescape({fname})
fnamemodify({fname}, {mods})
foldclosed({lnum})
foldclosedend({lnum})
foldlevel({lnum})
foldtext()
foldtextresult({lnum})
foreground()
function({name})
garbagecollect([at_exit])
get({dict}, {key} [, {def}])
get({list}, {idx} [, {def}])
getbufline({expr}, {lnum} [, {end}])
getbufvar({expr}, {varname})
getchar([expr])
getcharmod()
getcmdline()
getcmdpos()
getcmdtype()
getcwd()
getfontname([{name}])
getfperm({fname})
getfsize({fname})
getftime({fname})
getftype({fname})
getline({lnum})
getline({lnum}, {end})
getloclist({nr})
getmatches()
getpid()
getpos({expr})
getqflist()
getreg([{regname} [, 1]])
getregtype([{regname}])
gettabvar({tabnr}, {varname})
gettabwinvar({tabnr}, {winnr}, {name})
getwinposx()
getwinposy()
getwinvar({nr}, {varname})
glob({expr} [, {flag}])
globpath({path}, {expr} [, {flag}])
has({feature})
has_key({dict}, {key})
haslocaldir()
hasmapto({what} [, {mode} [, {abbr}]])
histadd({history},{item})
histdel({history} [, {item}])
histget({history} [, {index}])
histnr({history})
hlID({name})
hlexists({name})
hostname()
iconv({expr}, {from}, {to})
indent({lnum})
index({list}, {expr} [, {start} [, {ic}]])
input({prompt} [, {text} [, {completion}]])
inputdialog({p} [, {t} [, {c}]])
inputlist({textlist})
inputrestore()
inputsave()
inputsecret({prompt} [, {text}])
insert({list}, {item} [, {idx}])
isdirectory({directory})
islocked({expr})
items({dict})
join({list} [, {sep}])
keys({dict})
len({expr})
libcall({lib}, {func}, {arg})
libcallnr({lib}, {func}, {arg})
line({expr})
line2byte({lnum})
lispindent({lnum})
localtime()
log({expr})
log10({expr})
map({expr}, {string})
maparg({name}[, {mode} [, {abbr}]])
mapcheck({name}[, {mode} [, {abbr}]])
match({expr}, {pat}[, {start}[, {count}]])
matchadd({group}, {pattern}[, {priority}[, {id}]])
matcharg({nr})
matchdelete({id})
matchend({expr}, {pat}[, {start}[, {count}]])
matchlist({expr}, {pat}[, {start}[, {count}]])
matchstr({expr}, {pat}[, {start}[, {count}]])
max({list})
min({list})
mkdir({name} [, {path} [, {prot}]])
mode([expr])
nextnonblank({lnum})
nr2char({expr})
pathshorten({expr})
pow({x}, {y})
prevnonblank({lnum})
printf({fmt}, {expr1}...)
pumvisible()
range({expr} [, {max} [, {stride}]])
readfile({fname} [, {binary} [, {max}]])
reltime([{start} [, {end}]])
reltimestr({time})
remote_expr({server}, {string} [, {idvar}])
remote_foreground({server})
remote_peek({serverid} [, {retvar}])
remote_read({serverid})
remote_send({server}, {string} [, {idvar}])
remove({dict}, {key})
remove({list}, {idx} [, {end}])
rename({from}, {to})
repeat({expr}, {count})
resolve({filename})
reverse({list})
round({expr})
search({pattern} [, {flags} [, {stopline} [, {timeout}]]])
searchdecl({name} [, {global} [, {thisblock}]])
searchpair({start}, {middle}, {end} [, {flags} [, {skip} [...]]])
searchpairpos({start}, {middle}, {end} [, {flags} [, {skip} [...]]])
searchpos({pattern} [, {flags} [, {stopline} [, {timeout}]]])
server2client({clientid}, {string})
serverlist()
setbufvar({expr}, {varname}, {val})
setcmdpos({pos})
setline({lnum}, {line})
setloclist({nr}, {list}[, {action}])
setmatches({list})
setpos({expr}, {list})
setqflist({list}[, {action}])
setreg({n}, {v}[, {opt}])
settabvar({tabnr}, {varname}, {val})
settabwinvar({tabnr}, {winnr}, {varname}, {val})
setwinvar({nr}, {varname}, {val})
shellescape({string} [, {special}])
simplify({filename})
sin({expr})
sinh({expr})
sort({list} [, {func}])
soundfold({word})
spellbadword()
spellsuggest({word} [, {max} [, {capital}]])
split({expr} [, {pat} [, {keepempty}]])
sqrt({expr})
str2float({expr})
str2nr({expr} [, {base}])
strchars({expr})
strdisplaywidth({expr}[, {col}])
strftime({format}[, {time}])
stridx({haystack}, {needle}[, {start}])
string({expr})
strlen({expr})
strpart({src}, {start}[, {len}])
strridx({haystack}, {needle} [, {start}])
strtrans({expr})
strwidth({expr})
submatch({nr})
substitute({expr}, {pat}, {sub}, {flags})
synID({lnum}, {col}, {trans})
synIDattr({synID}, {what} [, {mode}])
synIDtrans({synID})
synconcealed({lnum}, {col})
synstack({lnum}, {col})
system({expr} [, {input}])
tabpagebuflist([{arg}])
tabpagenr([{arg}])
tabpagewinnr({tabarg}[, {arg}])
tagfiles()
taglist({expr})
tan({expr})
tanh({expr})
tempname()
tolower({expr})
toupper({expr})
tr({src}, {fromstr}, {tostr})
trunc({expr}
type({name})
undofile({name})
undotree()
values({dict})
virtcol({expr})
visualmode([expr])
winbufnr({nr})
wincol()
winheight({nr})
winline()
winnr([{expr}])
winrestcmd()
winrestview({dict})
winsaveview()
winwidth({nr})
writefile({list}, {fname} [, {binary}])
autoload/neocomplcache/sources/vim_complete/helper.vim	[[[1
990
"=============================================================================
" FILE: helper.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 23 Sep 2010
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

if !exists('s:internal_candidates_list')
  let s:internal_candidates_list = {}
  let s:global_candidates_list = { 'dictionary_variables' : {} }
  let s:script_candidates_list = {}
  let s:local_candidates_list = {}
endif

function! neocomplcache#sources#vim_complete#helper#on_filetype()"{{{
  " Caching script candidates.
  let l:bufnumber = 1

  " Check buffer.
  while l:bufnumber <= bufnr('$')
    if getbufvar(l:bufnumber, '&filetype') == 'vim' && bufloaded(l:bufnumber)
          \&& !has_key(s:script_candidates_list, l:bufnumber)
      let s:script_candidates_list[l:bufnumber] = s:get_script_candidates(l:bufnumber)
    endif

    let l:bufnumber += 1
  endwhile

  if neocomplcache#exists_echodoc()
    call echodoc#register('vim_complete', s:doc_dict)
  endif
endfunction"}}}

function! neocomplcache#sources#vim_complete#helper#recaching(bufname)"{{{
  " Caching script candidates.
  let l:bufnumber = a:bufname != '' ? bufnr(a:bufname) : bufnr('%')

  if getbufvar(l:bufnumber, '&filetype') == 'vim' && bufloaded(l:bufnumber)
    let s:script_candidates_list[l:bufnumber] = s:get_script_candidates(l:bufnumber)
  endif
  let s:global_candidates_list = { 'dictionary_variables' : {} }
endfunction"}}}

" For echodoc."{{{
let s:doc_dict = {
      \ 'name' : 'vim_complete',
      \ 'rank' : 10,
      \ 'filetypes' : { 'vim' : 1 },
      \ }
function! s:doc_dict.search(cur_text)"{{{
  let l:cur_text = neocomplcache#sources#vim_complete#get_cur_text()
  
  " Echo prototype.
  let l:script_candidates_list = s:get_cached_script_candidates()

  let l:prototype_name = matchstr(l:cur_text,
        \'\%(<[sS][iI][dD]>\|[sSgGbBwWtTlL]:\)\=\%(\i\|[#.]\|{.\{-1,}}\)*\s*(\ze\%([^(]\|(.\{-})\)*$')
  let l:ret = []
  if l:prototype_name != ''
    if !has_key(s:internal_candidates_list, 'function_prototypes')
      " No cache.
      return []
    endif
    
    " Search function name.
    call add(l:ret, { 'text' : l:prototype_name, 'highlight' : 'Identifier' })
    if has_key(s:internal_candidates_list.function_prototypes, l:prototype_name)
      call add(l:ret, { 'text' : s:internal_candidates_list.function_prototypes[l:prototype_name] })
    elseif has_key(s:global_candidates_list.function_prototypes, l:prototype_name)
      call add(l:ret, { 'text' : s:global_candidates_list.function_prototypes[l:prototype_name] })
    elseif has_key(l:script_candidates_list.function_prototypes, l:prototype_name)
      call add(l:ret, { 'text' : l:script_candidates_list.function_prototypes[l:prototype_name] })
    else
      " No prototypes.
      return []
    endif
  else
    if !has_key(s:internal_candidates_list, 'command_prototypes')
      " No cache.
      return []
    endif
    
    " Search command name.
    " Skip head digits.
    let l:prototype_name = neocomplcache#sources#vim_complete#get_command(l:cur_text)
    call add(l:ret, { 'text' : l:prototype_name, 'highlight' : 'Statement' })
    if has_key(s:internal_candidates_list.command_prototypes, l:prototype_name)
      call add(l:ret, { 'text' : s:internal_candidates_list.command_prototypes[l:prototype_name] })
    elseif has_key(s:global_candidates_list.command_prototypes, l:prototype_name)
      call add(l:ret, { 'text' : s:global_candidates_list.command_prototypes[l:prototype_name] })
    else
      " No prototypes.
      return []
    endif
  endif

  return l:ret
endfunction"}}}
"}}}

function! neocomplcache#sources#vim_complete#helper#get_command_completion(command_name, cur_text, cur_keyword_str)"{{{
  let l:completion_name = neocomplcache#sources#vim_complete#helper#get_completion_name(a:command_name)
  if l:completion_name == ''
    " Not found.
    return []
  endif
  
  let l:args = (l:completion_name ==# 'custom' || l:completion_name ==# 'customlist')?
        \ [a:command_name, a:cur_text, a:cur_keyword_str] : [a:cur_text, a:cur_keyword_str]
  return call('neocomplcache#sources#vim_complete#helper#'.l:completion_name, l:args)
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#get_completion_name(command_name)"{{{
  if !has_key(s:internal_candidates_list, 'command_completions')
    let s:internal_candidates_list.command_completions = s:caching_completion_from_dict('command_completions')
  endif
  if !has_key(s:global_candidates_list, 'command_completions')
    let s:global_candidates_list.commands = s:get_cmdlist()
  endif
  
  if has_key(s:internal_candidates_list.command_completions, a:command_name) 
        \&& exists('*neocomplcache#sources#vim_complete#helper#'.s:internal_candidates_list.command_completions[a:command_name])
    return s:internal_candidates_list.command_completions[a:command_name]
  elseif has_key(s:global_candidates_list.command_completions, a:command_name) 
        \&& exists('*neocomplcache#sources#vim_complete#helper#'.s:global_candidates_list.command_completions[a:command_name])
    return s:global_candidates_list.command_completions[a:command_name]
  else
    return ''
  endif
endfunction"}}}

function! neocomplcache#sources#vim_complete#helper#autocmd_args(cur_text, cur_keyword_str)"{{{
  " Caching.
  if !has_key(s:global_candidates_list, 'augroups')
    let s:global_candidates_list.augroups = s:get_augrouplist()
  endif
  if !has_key(s:internal_candidates_list, 'autocmds')
    let s:internal_candidates_list.autocmds = s:caching_from_dict('autocmds', '')
  endif
  
  return s:internal_candidates_list.autocmds + s:global_candidates_list.augroups
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#augroup(cur_text, cur_keyword_str)"{{{
  " Caching.
  if !has_key(s:global_candidates_list, 'augroups')
    let s:global_candidates_list.augroups = s:get_augrouplist()
  endif
  
  return s:global_candidates_list.augroups
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#buffer(cur_text, cur_keyword_str)"{{{
  return []
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#command(cur_text, cur_keyword_str)"{{{
  " Caching.
  if !has_key(s:global_candidates_list, 'commands')
    let s:global_candidates_list.commands = s:get_cmdlist()
  endif
  if !has_key(s:internal_candidates_list, 'commands')
    let s:internal_candidates_list.commands = s:caching_from_dict('commands', 'c')
    
    let s:internal_candidates_list.command_prototypes = s:caching_prototype_from_dict('command_prototypes')
  endif
  
  let l:list = s:internal_candidates_list.commands + s:global_candidates_list.commands
  if bufname('%') !=# '[Command Line]'
    let l:list = neocomplcache#keyword_filter(l:list, a:cur_keyword_str)
  endif

  if a:cur_keyword_str =~# '^en\%[d]'
    let l:list += s:get_endlist()
  endif

  return l:list
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#command_args(cur_text, cur_keyword_str)"{{{
  " Caching.
  if !has_key(s:internal_candidates_list, 'command_args')
    let s:internal_candidates_list.command_args = s:caching_from_dict('command_args', '')
    let s:internal_candidates_list.command_replaces = s:caching_from_dict('command_replaces', '')
  endif
  
  return s:internal_candidates_list.command_args + s:internal_candidates_list.command_replaces
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#custom(command_name, cur_text, cur_keyword_str)"{{{
  if !has_key(g:neocomplcache_vim_completefuncs, a:command_name)
    return []
  endif

  return s:make_completion_list(split(call(g:neocomplcache_vim_completefuncs[a:command_name],
        \ [a:cur_keyword_str, getline('.'), len(a:cur_text)]), '\n'), '[vim] custom', '')
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#customlist(command_name, cur_text, cur_keyword_str)"{{{
  if !has_key(g:neocomplcache_vim_completefuncs, a:command_name)
    return []
  endif
  
  return s:make_completion_list(call(g:neocomplcache_vim_completefuncs[a:command_name],
        \ [a:cur_keyword_str, getline('.'), len(a:cur_text)]), '[vim] customlist', '')
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#dir(cur_text, cur_keyword_str)"{{{
  " Check dup.
  let l:check = {}
  for keyword in filter(split(substitute(globpath(&cdpath, a:cur_keyword_str . '*'), '\\', '/', 'g'), '\n'), 'isdirectory(v:val)')
    if !has_key(l:check, keyword) && keyword =~ '/'
      let l:check[keyword] = keyword
    endif
  endfor

  let l:ret = []
  let l:paths = map(split(&cdpath, ','), 'substitute(v:val, "\\\\", "/", "g")')
  for keyword in keys(l:check)
    let l:dict = { 'word' : escape(keyword, ' *?[]"={}'), 'abbr' : keyword.'/', 'menu' : '[vim] directory', }
    " Path search.
    for path in l:paths
      if path != '' && neocomplcache#head_match(l:dict.word, path . '/')
        let l:dict.word = l:dict.word[len(path)+1 : ]
        break
      endif
    endfor

    call add(l:ret, l:dict)
  endfor

  return l:ret
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#environment(cur_text, cur_keyword_str)"{{{
  " Caching.
  if !has_key(s:global_candidates_list, 'environments')
    let s:global_candidates_list.environments = s:get_envlist()
  endif
  
  return s:global_candidates_list.environments
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#event(cur_text, cur_keyword_str)"{{{
  return []
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#expression(cur_text, cur_keyword_str)"{{{
  return neocomplcache#sources#vim_complete#helper#function(a:cur_text, a:cur_keyword_str)
        \+ neocomplcache#sources#vim_complete#helper#var(a:cur_text, a:cur_keyword_str)
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#feature(cur_text, cur_keyword_str)"{{{
  if !has_key(s:internal_candidates_list, 'features')
    let s:internal_candidates_list.features = s:caching_from_dict('features', '')
  endif
  return s:internal_candidates_list.features
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#file(cur_text, cur_keyword_str)"{{{
  return []
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#filetype(cur_text, cur_keyword_str)"{{{
  return s:make_completion_list(filter(map(split(globpath(&runtimepath, 'syntax/*.vim'), '\n'), 
        \'fnamemodify(v:val, ":t:r")'), "v:val =~ '^" . neocomplcache#escape_match(a:cur_keyword_str) . "'"), '[vim] filetype', '')
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#function(cur_text, cur_keyword_str)"{{{
  " Caching.
  if !has_key(s:global_candidates_list, 'functions')
    let s:global_candidates_list.functions = s:get_functionlist()
  endif
  if !has_key(s:internal_candidates_list, 'functions')
    let l:dict = {}
    for l:function in s:caching_from_dict('functions', 'f')
      let l:dict[l:function.word] = l:function
    endfor
    let s:internal_candidates_list.functions = l:dict

    let l:function_prototypes = {}
    for function in values(s:internal_candidates_list.functions)
      let l:function_prototypes[function.word] = function.abbr
    endfor
    let s:internal_candidates_list.function_prototypes = s:caching_prototype_from_dict('functions')
  endif
  
  let l:script_candidates_list = s:get_cached_script_candidates()
  if a:cur_keyword_str =~ '^s:'
    let l:list = values(l:script_candidates_list.functions)
  elseif a:cur_keyword_str =~ '^\a:'
    let l:functions = deepcopy(values(l:script_candidates_list.functions))
    for l:keyword in l:functions
      let l:keyword.word = '<SID>' . l:keyword.word[2:]
      let l:keyword.abbr = '<SID>' . l:keyword.abbr[2:]
    endfor
    let l:list = l:functions
  else
    let l:list = values(s:internal_candidates_list.functions) + values(s:global_candidates_list.functions)
  endif

  return l:list
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#help(cur_text, cur_keyword_str)"{{{
  return []
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#highlight(cur_text, cur_keyword_str)"{{{
  return []
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#let(cur_text, cur_keyword_str)"{{{
  if a:cur_text !~ '='
    return neocomplcache#sources#vim_complete#helper#var(a:cur_text, a:cur_keyword_str)
  elseif a:cur_text =~# '\<let\s\+&\%([lg]:\)\?filetype\s*=\s*'
    " FileType.
    return neocomplcache#sources#vim_complete#helper#filetype(a:cur_text, a:cur_keyword_str)
  else
    return neocomplcache#sources#vim_complete#helper#expression(a:cur_text, a:cur_keyword_str)
  endif
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#mapping(cur_text, cur_keyword_str)"{{{
  " Caching.
  if !has_key(s:global_candidates_list, 'mappings')
    let s:global_candidates_list.mappings = s:get_mappinglist()
  endif
  if !has_key(s:internal_candidates_list, 'mappings')
    let s:internal_candidates_list.mappings = s:caching_from_dict('mappings', '')
  endif
  
  return s:internal_candidates_list.mappings + s:global_candidates_list.mappings
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#menu(cur_text, cur_keyword_str)"{{{
  return []
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#option(cur_text, cur_keyword_str)"{{{
  " Caching.
  if !has_key(s:internal_candidates_list, 'options')
    let s:internal_candidates_list.options = s:caching_from_dict('options', 'o')
    
    for l:keyword in deepcopy(s:internal_candidates_list.options)
      let l:keyword.word = 'no' . l:keyword.word
      let l:keyword.abbr = 'no' . l:keyword.abbr
      call add(s:internal_candidates_list.options, l:keyword)
    endfor
  endif
  
  if a:cur_text =~ '\<set\%[local]\s\+\%(filetype\|ft\)='
    return neocomplcache#sources#vim_complete#helper#filetype(a:cur_text, a:cur_keyword_str)
  else
    return s:internal_candidates_list.options
  endif
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#shellcmd(cur_text, cur_keyword_str)"{{{
  return []
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#tag(cur_text, cur_keyword_str)"{{{
  return []
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#tag_listfiles(cur_text, cur_keyword_str)"{{{
  return []
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#var_dictionary(cur_text, cur_keyword_str)"{{{
  let l:var_name = matchstr(a:cur_text, '\%(\a:\)\?\h\w*\ze\.\%(\h\w*\%(()\?\)\?\)\?$')
  if a:cur_text =~ '[btwg]:\h\w*\.\%(\h\w*\%(()\?\)\?\)\?$'
    let l:list = has_key(s:global_candidates_list.dictionary_variables, l:var_name) ?
          \ values(s:global_candidates_list.dictionary_variables[l:var_name]) : []
  elseif a:cur_text =~ 's:\h\w*\.\%(\h\w*\%(()\?\)\?\)\?$'
    let l:list = values(get(s:get_cached_script_candidates().dictionary_variables, l:var_name, {}))
  else
    let l:list = s:get_local_dictionary_variables(l:var_name)
  endif

  return l:list
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#var(cur_text, cur_keyword_str)"{{{
  " Caching.
  if !has_key(s:global_candidates_list, 'variables')
    let l:dict = {}
    for l:var in extend(s:caching_from_dict('variables', ''), s:get_variablelist())
      let l:dict[l:var.word] = l:var
    endfor
    let s:global_candidates_list.variables = l:dict
  endif
  
  if a:cur_keyword_str =~ '^[swtb]:'
    let l:list = values(s:get_cached_script_candidates().variables)
  elseif a:cur_keyword_str =~ '^[vg]:'
    let l:list = values(s:global_candidates_list.variables)
  else
    let l:list = s:get_local_variables()
  endif

  return l:list
endfunction"}}}
function! neocomplcache#sources#vim_complete#helper#expand(cur_text, cur_keyword_str)"{{{
  return s:make_completion_list(
        \ ['<cfile>', '<afile>', '<abuf>', '<amatch>', '<sfile>', '<cword>', '<cWORD>', '<client>'],
        \ '[vim] expand', '')
endfunction"}}}

function! s:get_local_variables()"{{{
  " Get local variable list.

  let l:keyword_dict = {}
  " Search function.
  let l:line_num = line('.') - 1
  let l:end_line = (line('.') > 100) ? line('.') - 100 : 1
  while l:line_num >= l:end_line
    let l:line = getline(l:line_num)
    if l:line =~ '\<endf\%[unction]\>'
      break
    elseif l:line =~ '\<fu\%[nction]!\?\s\+'
      let l:candidates_list = l:line =~ '\<fu\%[nction]!\?\s\+s:' && has_key(s:script_candidates_list, bufnr('%')) ?
            \ s:script_candidates_list[bufnr('%')] : s:global_candidates_list
      if has_key(l:candidates_list, 'functions') && has_key(l:candidates_list, 'function_prototypes')
        call s:analyze_function_line(l:line, l:candidates_list.functions, l:candidates_list.function_prototypes) 
      endif

      " Get function arguments.
      call s:analyze_variable_line(l:line, l:keyword_dict)
      break
    endif

    let l:line_num -= 1
  endwhile
  let l:line_num += 1

  let l:end_line = line('.') - 1
  while l:line_num <= l:end_line
    let l:line = getline(l:line_num)

    if l:line =~ '\<\%(let\|for\)\s\+'
      if l:line =~ '\<\%(let\|for\)\s\+s:' && has_key(s:script_candidates_list, bufnr('%'))
            \ && has_key(s:script_candidates_list[bufnr('%')], 'variables')
        let l:candidates_list = s:script_candidates_list[bufnr('%')].variables
      elseif l:line =~ '\<\%(let\|for\)\s\+[btwg]:'
            \ && has_key(s:global_candidates_list, 'variables')
        let l:candidates_list = s:global_candidates_list.variables
      else
        let l:candidates_list = l:keyword_dict
      endif
      call s:analyze_variable_line(l:line, l:candidates_list)
    endif

    let l:line_num += 1
  endwhile

  return values(l:keyword_dict)
endfunction"}}}
function! s:get_local_dictionary_variables(var_name)"{{{
  " Get local dictionary variable list.

  " Search function.
  let l:line_num = line('.') - 1
  let l:end_line = (line('.') > 100) ? line('.') - 100 : 1
  while l:line_num >= l:end_line
    let l:line = getline(l:line_num)
    if l:line =~ '\<fu\%[nction]\>'
      break
    endif

    let l:line_num -= 1
  endwhile
  let l:line_num += 1

  let l:end_line = line('.') - 1
  let l:keyword_dict = {}
  let l:var_pattern = a:var_name.'\.\h\w*\%(()\?\)\?'
  while l:line_num <= l:end_line
    let l:line = getline(l:line_num)

    if l:line =~ l:var_pattern
      while l:line =~ l:var_pattern
        let l:var_name = matchstr(l:line, '\a:[[:alnum:]_:]*\ze\.\h\w*')
        if l:var_name =~ '^[btwg]:'
          let l:candidates = s:global_candidates_list.dictionary_variables
          if !has_key(l:candidates, l:var_name)
            let l:candidates[l:var_name] = {}
          endif
          let l:candidates_dict = l:candidates[l:var_name]
        elseif l:var_name =~ '^s:' && has_key(s:script_candidates_list, bufnr('%'))
          let l:candidates = s:script_candidates_list[bufnr('%')].dictionary_variables
          if !has_key(l:candidates, l:var_name)
            let l:candidates[l:var_name] = {}
          endif
          let l:candidates_dict = l:candidates[l:var_name]
        else
          let l:candidates_dict = l:keyword_dict
        endif

        call s:analyze_dictionary_variable_line(l:line, l:candidates_dict, l:var_name)

        let l:line = l:line[matchend(l:line, l:var_pattern) :]
      endwhile
    endif

    let l:line_num += 1
  endwhile

  return values(l:keyword_dict)
endfunction"}}}

function! s:get_cached_script_candidates()"{{{
  return has_key(s:script_candidates_list, bufnr('%')) && v:version > 700 ?
        \ s:script_candidates_list[bufnr('%')] : {
        \   'functions' : {}, 'variables' : {}, 'function_prototypes' : {}, 'dictionary_variables' : {} }
endfunction"}}}
function! s:get_script_candidates(bufnumber)"{{{
  " Get script candidate list.

  let l:function_dict = {}
  let l:variable_dict = {}
  let l:dictionary_variable_dict = {}
  let l:function_prototypes = {}
  let l:var_pattern = '\a:[[:alnum:]_:]*\.\h\w*\%(()\?\)\?'

  for l:line in getbufline(a:bufnumber, 1, '$')
    if l:line =~ '\<fu\%[nction]!\?\s\+s:'
      call s:analyze_function_line(l:line, l:function_dict, l:function_prototypes)
    elseif l:line =~ '\<let\s\+'
      " Get script variable.
      call s:analyze_variable_line(l:line, l:variable_dict)
    elseif l:line =~ l:var_pattern
      while l:line =~ l:var_pattern
        let l:var_name = matchstr(l:line, '\a:[[:alnum:]_:]*\ze\.\h\w*')
        if l:var_name =~ '^[btwg]:'
          let l:candidates_dict = s:global_candidates_list.dictionary_variables
        else
          let l:candidates_dict = l:dictionary_variable_dict
        endif
        if !has_key(l:candidates_dict, l:var_name)
          let l:candidates_dict[l:var_name] = {}
        endif

        call s:analyze_dictionary_variable_line(l:line, l:candidates_dict[l:var_name], l:var_name)

        let l:line = l:line[matchend(l:line, l:var_pattern) :]
      endwhile
    endif
  endfor

  return { 'functions' : l:function_dict, 'variables' : l:variable_dict, 
        \'function_prototypes' : l:function_prototypes, 'dictionary_variables' : l:dictionary_variable_dict }
endfunction"}}}

function! s:caching_from_dict(dict_name, kind)"{{{
  let l:dict_files = split(globpath(&runtimepath, 'autoload/neocomplcache/sources/vim_complete/'.a:dict_name.'.dict'), '\n')
  if empty(l:dict_files)
    return []
  endif

  let l:menu_pattern = '[vim] '.a:dict_name[: -2]
  let l:keyword_pattern =
        \'^\%(-\h\w*\%(=\%(\h\w*\|[01*?+%]\)\?\)\?\|<\h[[:alnum:]_-]*>\?\|\h[[:alnum:]_:#\[]*\%([!\]]\+\|()\?\)\?\)'
  let l:keyword_list = []
  for line in readfile(l:dict_files[0])
    call add(l:keyword_list, {
          \ 'word' : substitute(matchstr(line, l:keyword_pattern), '[\[\]]', '', 'g'), 
          \ 'menu' : l:menu_pattern, 'kind' : a:kind, 'abbr' : l:line
          \})
  endfor

  return l:keyword_list
endfunction"}}}
function! s:caching_completion_from_dict(dict_name)"{{{
  let l:dict_files = split(globpath(&runtimepath, 'autoload/neocomplcache/sources/vim_complete/'.a:dict_name.'.dict'), '\n')
  if empty(l:dict_files)
    return {}
  endif

  let l:keyword_dict = {}
  for l:line in readfile(l:dict_files[0])
    let l:word = matchstr(l:line, '^[[:alnum:]_\[\]]\+')
    let l:completion = matchstr(l:line[len(l:word):], '\h\w*')
    if l:completion != ''
      if l:word =~ '\['
        let [l:word_head, l:word_tail] = split(l:word, '\[')
        let l:word_tail = ' ' . substitute(l:word_tail, '\]', '', '')
      else
        let l:word_head = l:word
        let l:word_tail = ' '
      endif

      for i in range(len(l:word_tail))
        let l:keyword_dict[l:word_head . l:word_tail[1:i]] = l:completion
      endfor
    endif
  endfor

  return l:keyword_dict
endfunction"}}}
function! s:caching_prototype_from_dict(dict_name)"{{{
  let l:dict_files = split(globpath(&runtimepath, 'autoload/neocomplcache/sources/vim_complete/'.a:dict_name.'.dict'), '\n')
  if empty(l:dict_files)
    return {}
  endif
  if a:dict_name == 'functions'
    let l:pattern = '^[[:alnum:]_]\+('
  else
    let l:pattern = '^[[:alnum:]_\[\](]\+'
  endif

  let l:keyword_dict = {}
  for l:line in readfile(l:dict_files[0])
    let l:word = matchstr(l:line, l:pattern)
    let l:rest = l:line[len(l:word):]
    if l:word =~ '\['
      let [l:word_head, l:word_tail] = split(l:word, '\[')
      let l:word_tail = ' ' . substitute(l:word_tail, '\]', '', '')
    else
      let l:word_head = l:word
      let l:word_tail = ' '
    endif
    
    for i in range(len(l:word_tail))
      let l:keyword_dict[l:word_head . l:word_tail[1:i]] = l:rest
    endfor
  endfor

  return l:keyword_dict
endfunction"}}}

function! s:get_cmdlist()"{{{
  " Get command list.
  redir => l:redir
  silent! command
  redir END

  let l:keyword_list = []
  let l:completions = [ 'augroup', 'buffer', 'command', 'dir', 'environment', 
        \ 'event', 'expression', 'file', 'shellcmd', 'function', 
        \ 'help', 'highlight', 'mapping', 'menu', 'option', 'tag', 'tag_listfiles', 
        \ 'var', 'custom', 'customlist' ]
  let l:command_prototypes = {}
  let l:command_completions = {}
  let l:menu_pattern = '[vim] command'
  for line in split(l:redir, '\n')[1:]
    let l:word = matchstr(line, '\a\w*')
    
    " Analyze prototype.
    let l:end = matchend(line, '\a\w*')
    let l:args = matchstr(line, '[[:digit:]?+*]', l:end)
    if l:args != '0'
      let l:prototype = matchstr(line, '\a\w*', l:end)
      let l:found = 0
      for l:comp in l:completions
        if l:comp == l:prototype
          let l:command_completions[l:word] = l:prototype
          let l:found = 1
          
          break
        endif
      endfor

      if !l:found
        let l:prototype = 'arg'
      endif
      
      if l:args == '*'
        let l:prototype = '[' . l:prototype . '] ...'
      elseif l:args == '?'
        let l:prototype = '[' . l:prototype . ']'
      elseif l:args == '+'
        let l:prototype = l:prototype . ' ...'
      endif
      
      let l:command_prototypes[l:word] = ' ' . repeat(' ', 16 - len(l:word)) . l:prototype
    else
      let l:command_prototypes[l:word] = ''
    endif
    let l:prototype = l:command_prototypes[l:word]
    
    call add(l:keyword_list, {
          \ 'word' : l:word, 'abbr' : l:word . l:prototype, 'menu' : l:menu_pattern, 'kind' : 'c'
          \})
  endfor
  let s:global_candidates_list.command_prototypes = l:command_prototypes
  let s:global_candidates_list.command_completions = l:command_completions

  return l:keyword_list
endfunction"}}}
function! s:get_variablelist()"{{{
  " Get variable list.
  redir => l:redir
  silent! let
  redir END

  let l:keyword_list = []
  let l:menu_pattern = '[vim] variable'
  let l:kind_dict = ['0', '""', '()', '[]', '{}', '.']
  for line in split(l:redir, '\n')
    let l:word = matchstr(line, '^\a[[:alnum:]_:]*')
    if l:word !~ '^\a:'
      let l:word = 'g:' . l:word
    elseif l:word =~ '[^gv]:'
      continue
    endif
    call add(l:keyword_list, {
          \ 'word' : l:word, 'menu' : l:menu_pattern,
          \ 'kind' : exists(l:word)? l:kind_dict[type(eval(l:word))] : ''
          \})
  endfor
  return l:keyword_list
endfunction"}}}
function! s:get_functionlist()"{{{
  " Get function list.
  redir => l:redir
  silent! function
  redir END

  let l:keyword_dict = {}
  let l:function_prototypes = {}
  let l:menu_pattern = '[vim] function'
  for l:line in split(l:redir, '\n')
    let l:line = l:line[9:]
    if l:line =~ '^<SNR>'
      continue
    endif
    let l:orig_line = l:line
    
    let l:word = matchstr(l:line, '\h[[:alnum:]_:#.]*()\?')
    if l:word != ''
      let l:keyword_dict[l:word] = {
            \ 'word' : l:word, 'abbr' : l:line, 'menu' : l:menu_pattern,
            \}

      let l:function_prototypes[l:word] = l:orig_line[len(l:word):]
    endif
  endfor

  let s:global_candidates_list.function_prototypes = l:function_prototypes

  return l:keyword_dict
endfunction"}}}
function! s:get_augrouplist()"{{{
  " Get function list.
  redir => l:redir
  silent! augroup
  redir END

  let l:keyword_list = []
  let l:menu_pattern = '[vim] augroup'
  for l:group in split(l:redir . ' END', '\s')
    call add(l:keyword_list, { 'word' : l:group, 'menu' : l:menu_pattern})
  endfor
  return l:keyword_list
endfunction"}}}
function! s:get_mappinglist()"{{{
  " Get function list.
  redir => l:redir
  silent! map
  redir END

  let l:keyword_list = []
  let l:menu_pattern = '[vim] mapping'
  for line in split(l:redir, '\n')
    let l:map = matchstr(line, '^\a*\s*\zs\S\+')
    if l:map !~ '^<' || l:map =~ '^<SNR>'
      continue
    endif
    call add(l:keyword_list, { 'word' : l:map, 'menu' : l:menu_pattern })
  endfor
  return l:keyword_list
endfunction"}}}
function! s:get_envlist()"{{{
  " Get environment variable list.

  let l:keyword_list = []
  let l:menu_pattern = '[vim] environment'
  for line in split(system('set'), '\n')
    let l:word = '$' . toupper(matchstr(line, '^\h\w*'))
    call add(l:keyword_list, { 'word' : l:word, 'menu' : l:menu_pattern, 'kind' : 'e' })
  endfor
  return l:keyword_list
endfunction"}}}
function! s:get_endlist()"{{{
  " Get end command list.

  let l:keyword_dict = {}
  let l:menu_pattern = '[vim] end'
  let l:line_num = line('.') - 1
  let l:end_line = (line('.') < 100) ? line('.') - 100 : 1
  let l:cnt = {
        \ 'endfor' : 0, 'endfunction' : 0, 'endtry' : 0, 
        \ 'endwhile' : 0, 'endif' : 0
        \}
  let l:word = ''

  while l:line_num >= l:end_line
    let l:line = getline(l:line_num)

    if l:line =~ '\<endfo\%[r]\>'
      let l:cnt['endfor'] -= 1
    elseif l:line =~ '\<endf\%[nction]\>'
      let l:cnt['endfunction'] -= 1
    elseif l:line =~ '\<endt\%[ry]\>'
      let l:cnt['endtry'] -= 1
    elseif l:line =~ '\<endw\%[hile]\>'
      let l:cnt['endwhile'] -= 1
    elseif l:line =~ '\<en\%[dif]\>'
      let l:cnt['endif'] -= 1

    elseif l:line =~ '\<for\>'
      let l:cnt['endfor'] += 1
      if l:cnt['endfor'] > 0
        let l:word = 'endfor'
        break
      endif
    elseif l:line =~ '\<fu\%[nction]!\?\s\+'
      let l:cnt['endfunction'] += 1
      if l:cnt['endfunction'] > 0
        let l:word = 'endfunction'
      endif
      break
    elseif l:line =~ '\<try\>'
      let l:cnt['endtry'] += 1
      if l:cnt['endtry'] > 0
        let l:word = 'endtry'
        break
      endif
    elseif l:line =~ '\<wh\%[ile]\>'
      let l:cnt['endwhile'] += 1
      if l:cnt['endwhile'] > 0
        let l:word = 'endwhile'
        break
      endif
    elseif l:line =~ '\<if\>'
      let l:cnt['endif'] += 1
      if l:cnt['endif'] > 0
        let l:word = 'endif'
        break
      endif
    endif

    let l:line_num -= 1
  endwhile

  return (l:word == '')? [] : [{'word' : l:word, 'menu' : l:menu_pattern, 'kind' : 'c'}]
endfunction"}}}
function! s:make_completion_list(list, menu_pattern, kind)"{{{
  let l:list = []
  for l:item in a:list
    call add(l:list, { 'word' : l:item, 'menu' : a:menu_pattern, 'kind' : a:kind })
  endfor 

  return l:list
endfunction"}}}
function! s:analyze_function_line(line, keyword_dict, prototype)"{{{
  let l:menu_pattern = '[vim] function'
  
  " Get script function.
  let l:line = substitute(matchstr(a:line, '\<fu\%[nction]!\?\s\+\zs.*)'), '".*$', '', '')
  let l:orig_line = l:line
  let l:word = matchstr(l:line, '^\h[[:alnum:]_:#.]*()\?')
  if l:word != '' && !has_key(a:keyword_dict, l:word) 
    let a:keyword_dict[l:word] = {
          \ 'word' : l:word, 'abbr' : l:line, 'menu' : l:menu_pattern, 'kind' : 'f'
          \}
    let a:prototype[l:word] = l:orig_line[len(l:word):]
  endif
endfunction"}}}
function! s:analyze_variable_line(line, keyword_dict)"{{{
  let l:menu_pattern = '[vim] variable'
  
  if a:line =~ '\<\%(let\|for\)\s\+\a[[:alnum:]_:]*'
    " let var = pattern.
    let l:word = matchstr(a:line, '\<\%(let\|for\)\s\+\zs\a[[:alnum:]_:]*')
    let l:expression = matchstr(a:line, '\<let\s\+\a[[:alnum:]_:]*\s*=\s*\zs.*$')
    if !has_key(a:keyword_dict, l:word) 
      let a:keyword_dict[l:word] = {
            \ 'word' : l:word, 'menu' : l:menu_pattern,
            \ 'kind' : s:get_variable_type(l:expression)
            \}
    elseif l:expression != '' && a:keyword_dict[l:word].kind == ''
      " Update kind.
      let a:keyword_dict[l:word].kind = s:get_variable_type(l:expression)
    endif
  elseif a:line =~ '\<\%(let\|for\)\s\+\[.\{-}\]'
    " let [var1, var2] = pattern.
    let l:words = split(matchstr(a:line, '\<\%(let\|for\)\s\+\[\zs.\{-}\ze\]'), '[,[:space:]]\+')
      let l:expressions = split(matchstr(a:line, '\<let\s\+\[.\{-}\]\s*=\s*\[\zs.\{-}\ze\]$'), '[,[:space:]]\+')

      let i = 0
      while i < len(l:words)
        let l:expression = get(l:expressions, i, '')
        let l:word = l:words[i]

        if !has_key(a:keyword_dict, l:word) 
          let a:keyword_dict[l:word] = {
                \ 'word' : l:word, 'menu' : l:menu_pattern,
                \ 'kind' : s:get_variable_type(l:expression)
                \}
        elseif l:expression != '' && a:keyword_dict[l:word].kind == ''
          " Update kind.
          let a:keyword_dict[l:word].kind = s:get_variable_type(l:expression)
        endif

        let i += 1
      endwhile
    elseif a:line =~ '\<fu\%[nction]!\?\s\+'
      " Get function arguments.
      for l:arg in split(matchstr(a:line, '^[^(]*(\zs[^)]*'), '\s*,\s*')
        let l:word = 'a:' . (l:arg == '...' ?  '000' : l:arg)
        let a:keyword_dict[l:word] = {
              \ 'word' : l:word, 'menu' : l:menu_pattern,
              \ 'kind' : (l:arg == '...' ?  '[]' : '')
              \}

      endfor
      if a:line =~ '\.\.\.)'
        " Extra arguments.
        for l:arg in range(5)
          let l:word = 'a:' . l:arg
          let a:keyword_dict[l:word] = {
                \ 'word' : l:word, 'menu' : l:menu_pattern,
                \ 'kind' : (l:arg == 0 ?  '0' : '')
                \}
        endfor
      endif
    endif
endfunction"}}}
function! s:analyze_dictionary_variable_line(line, keyword_dict, var_name)"{{{
  let l:menu_pattern = '[vim] dictionary'
  let l:var_pattern = a:var_name.'\.\h\w*\%(()\?\)\?'
  let l:let_pattern = '\<let\s\+'.a:var_name.'\.\h\w*'
  let l:call_pattern = '\<call\s\+'.a:var_name.'\.\h\w*()\?'
  
  if a:line =~ l:let_pattern
    let l:word = matchstr(a:line, a:var_name.'\zs\.\h\w*')
    let l:expression = matchstr(a:line, l:let_pattern.'\s*=\zs.*$')
    let l:kind = ''
  elseif a:line =~ l:call_pattern
    let l:word = matchstr(a:line, a:var_name.'\zs\.\h\w*()\?')
    let l:kind = '()'
  else
    let l:word = matchstr(a:line, a:var_name.'\zs.\h\w*\%(()\?\)\?')
    let l:kind = s:get_variable_type(matchstr(a:line, a:var_name.'\.\h\w*\zs.*$'))
  endif

  if !has_key(a:keyword_dict, l:word) 
    let a:keyword_dict[l:word] = { 'word' : l:word, 'menu' : l:menu_pattern,  'kind' : l:kind }
  elseif l:kind != '' && a:keyword_dict[l:word].kind == ''
    " Update kind.
    let a:keyword_dict[l:word].kind = l:kind
  endif
endfunction"}}}

" Initialize return types."{{{
function! s:set_dictionary_helper(variable, keys, value)"{{{
  for key in split(a:keys, ',')
    let a:variable[key] = a:value
  endfor
endfunction"}}}
let s:function_return_types = {}
call neocomplcache#set_dictionary_helper(s:function_return_types,
      \ 'len,match,matchend',
      \ '0')
call neocomplcache#set_dictionary_helper(s:function_return_types,
      \ 'input,matchstr',
      \ '""')
call neocomplcache#set_dictionary_helper(s:function_return_types,
      \ 'expand,filter,sort,split',
      \ '[]')
"}}}
function! s:get_variable_type(expression)"{{{
  " Analyze variable type.
  if a:expression =~ '^\%(\s*+\)\?\s*\d\+\.\d\+'
    return '.'
  elseif a:expression =~ '^\%(\s*+\)\?\s*\d\+'
    return '0'
  elseif a:expression =~ '^\%(\s*\.\)\?\s*["'']'
    return '""'
  elseif a:expression =~ '\<function('
    return '()'
  elseif a:expression =~ '^\%(\s*+\)\?\s*\['
    return '[]'
  elseif a:expression =~ '^\s*{\|^\.\h[[:alnum:]_:]*'
    return '{}'
  elseif a:expression =~ '\<\h\w*('
    " Function.
    let l:func_name = matchstr(a:expression, '\<\zs\h\w*\ze(')
    return has_key(s:function_return_types, l:func_name) ? s:function_return_types[l:func_name] : ''
  else
    return ''
  endif
endfunction"}}}
" vim: foldmethod=marker
autoload/neocomplcache/sources/vim_complete/mappings.dict	[[[1
53
<buffer> ; the mapping will be effective in the current buffer only
<expr> ; the argument is an expression evaluated to obtain the {rhs} that is used
<Leader> ; define a mapping which uses the "mapleader" variable
<LocalLeader> ; just like <Leader>, except that it uses "maplocalleader" instead of "mapleader"
<Plug> ; used for an internal mapping, which is not to be matched with any key sequence
<script> ; the mapping will only remap characters in the {rhs} using mappings that were defined local to a script
<SID> ; unique mapping for the script
<unique> ; the command will fail if the mapping or abbreviation already exists
<silent> ; define a mapping which will not be echoed on the command line
<Nul> ; zero
<BS> ; backspace
<Tab> ; tab
<NL> ; linefeed
<FF> ; formfeed
<CR> ; carriage return
<Return> ; same as <CR>
<Enter> ; same as <CR>
<Esc> ; escape
<Space> ; space
<lt> ; less-than <
<Bslash> ; backslash \
<Bar> ; vertical bar |
<Del> ; delete
<CSI> ; command sequence intro  ALT-Esc
<xCSI> ; CSI when typed in the GUI
<EOL> ; end-of-line (can be <CR>, <LF> or <CR><LF>, depends on system and 'fileformat')
<Up> ; cursor-up
<Down> ; cursor-down
<Left> ; cursor-left
<Right> ; cursor-right
<S-Up> ; shift-cursor-up
<S-Down> ; shift-cursor-down
<S-Left> ; shift-cursor-left
<S-Right> ; shift-cursor-right
<C-Left> ; control-cursor-left
<C-Right> ; control-cursor-right
<Help> ; help key
<Undo> ; undo key
<Insert> ; insert key
<Home> ; home
<End> ; end
<PageUp> ; page-up
<PageDown> ; page-down
<kHome> ; keypad home (upper left)
<kEnd> ; keypad end (lower left)
<kPageUp> ; keypad page-up (upper right)
<kPageDown> ; keypad page-down (lower right)
<kPlus> ; keypad +
<kMinus> ; keypad -
<kMultiply> ; keypad *
<kDivide> ; keypad /
<kEnter> ; keypad Enter
<kPoint> ; keypad Decimal point
autoload/neocomplcache/sources/vim_complete/options.dict	[[[1
354
aleph ; ASCII code of the letter Aleph (Hebrew)
allowrevins ; allow CTRL-_ in Insert and Command-line mode
altkeymap ; for default second language (Farsi/Hebrew)
ambiwidth ; what to do with Unicode chars of ambiguous width
antialias ; Mac OS X: use smooth, antialiased fonts
arabic ; for Arabic as a default second language
arabicshape ; do shaping for Arabic characters
autochdir ; change directory to the file in the current window
autoindent ; take indent for new line from previous line
autoread ; autom. read file when changed outside of Vim
autowrite ; automatically write file if changed
autowriteall ; as 'autowrite', but works with more commands
background ; "dark" or "light", used for highlight colors
backspace ; how backspace works at start of line
backup ; keep backup file after overwriting a file
backupcopy ; make backup as a copy, don't rename the file
backupdir ; list of directories for the backup file
backupext ; extension used for the backup file
backupskip ; no backup for files that match these patterns
balloondelay ; delay in mS before a balloon may pop up
ballooneval ; switch on balloon evaluation
balloonexpr ; expression to show in balloon
binary ; read/write/edit file in binary mode
bioskey ; MS-DOS: use bios calls for input characters
bomb ; prepend a Byte Order Mark to the file
breakat ; characters that may cause a line break
browsedir ; which directory to start browsing in
bufhidden ; what to do when buffer is no longer in window
buflisted ; whether the buffer shows up in the buffer list
buftype ; special type of buffer
casemap ; specifies how case of letters is changed
cdpath ; list of directories searched with ":cd"
cedit ; key used to open the command-line window
charconvert ; expression for character encoding conversion
cindent ; do C program indenting
cinkeys ; keys that trigger indent when 'cindent' is set
cinoptions ; how to do indenting when 'cindent' is set
cinwords ; words where 'si' and 'cin' add an indent
clipboard ; use the clipboard as the unnamed register
cmdheight ; number of lines to use for the command-line
cmdwinheight ; height of the command-line window
colorcolumn ; screen columns that are highlighted with ColorColumn
columns ; number of columns in the display
comments ; patterns that can start a comment line
commentstring ; template for comments; used for fold marker
compatible ; behave Vi-compatible as much as possible
complete ; specify how Insert mode completion works
completefunc ; function to be used for Insert mode completion
completeopt ; options for Insert mode completion
concealcursor ; sets the modes in which text in the cursor line can also be concealed
conceallevel ; how text with the "conceal" syntax attribute
confirm ; ask what to do about unsaved/read-only files
conskey ; get keys directly from console (MS-DOS only)
copyindent ; make 'autoindent' use existing indent structure
cpoptions ; flags for Vi-compatible behavior
cryptmethod ; method used for encryption when the buffer is written to a file
cscopepathcomp ; how many components of the path to show
cscopeprg ; command to execute cscope
cscopequickfix ; use quickfix window for cscope results
cscopetag ; use cscope for tag commands
cscopetagorder ; determines ":cstag" search order
cscopeverbose ; give messages when adding a cscope database
cursorcolumn ; highlight the screen column of the cursor
cursorline ; highlight the screen line of the cursor
debug ; set to "msg" to see all error messages
define ; pattern to be used to find a macro definition
delcombine ; delete combining characters on their own
dictionary ; list of file names used for keyword completion
diff ; use diff mode for the current window
diffexpr ; expression used to obtain a diff file
diffopt ; options for using diff mode
digraph ; enable the entering of digraphs in Insert mode
directory ; list of directory names for the swap file
display ; list of flags for how to display text
eadirection ; in which direction 'equalalways' works
edcompatible ; toggle flags of ":substitute" command
encoding ; encoding used internally
endofline ; write <EOL> for last line in file
equalalways ; windows are automatically made the same size
equalprg ; external program to use for "=" command
errorbells ; ring the bell for error messages
errorfile ; name of the errorfile for the QuickFix mode
errorformat ; description of the lines in the error file
esckeys ; recognize function keys in Insert mode
eventignore ; autocommand events that are ignored
expandtab ; use spaces when <Tab> is inserted
exrc ; read .vimrc and .exrc in the current directory
fileencoding ; file encoding for multi-byte text
fileencodings ; automatically detected character encodings
fileformat ; file format used for file I/O
fileformats ; automatically detected values for 'fileformat'
filetype ; type of file, used for autocommands
fillchars ; characters to use for displaying special items
fkmap ; Farsi keyboard mapping
foldclose ; close a fold when the cursor leaves it
foldcolumn ; width of the column used to indicate folds
foldenable ; set to display all folds open
foldexpr ; expression used when 'foldmethod' is "expr"
foldignore ; ignore lines when 'foldmethod' is "indent"
foldlevel ; close folds with a level higher than this
foldlevelstart ; 'foldlevel' when starting to edit a file
foldmarker ; markers used when 'foldmethod' is "marker"
foldmethod ; folding type
foldminlines ; minimum number of lines for a fold to be closed
foldnestmax ; maximum fold depth
foldopen ; for which commands a fold will be opened
foldtext ; expression used to display for a closed fold
formatexpr ; expression used with "gq" command
formatlistpat ; pattern used to recognize a list header
formatoptions ; how automatic formatting is to be done
formatprg ; name of external program used with "gq" command
fsync ; whether to invoke fsync() after file write
gdefault ; the ":substitute" flag 'g' is default on
grepformat ; format of 'grepprg' output
grepprg ; program to use for ":grep"
guicursor ; GUI: settings for cursor shape and blinking
guifont ; GUI: Name(s) of font(s) to be used
guifontset ; GUI: Names of multi-byte fonts to be used
guifontwide ; list of font names for double-wide characters
guiheadroom ; GUI: pixels room for window decorations
guioptions ; GUI: Which components and options are used
guipty ; GUI: try to use a pseudo-tty for ":!" commands
guitablabel ; GUI: custom label for a tab page
guitabtooltip ; GUI: custom tooltip for a tab page
helpfile ; full path name of the main help file
helpheight ; minimum height of a new help window
helplang ; preferred help languages
hidden ; don't unload buffer when it is abandoned
highlight ; sets highlighting mode for various occasions
history ; number of command-lines that are remembered
hkmap ; Hebrew keyboard mapping
hkmapp ; phonetic Hebrew keyboard mapping
hlsearch ; highlight matches with last search pattern
icon ; let Vim set the text of the window icon
iconstring ; string to use for the Vim icon text
ignorecase ; ignore case in search patterns
imactivatekey ; key that activates the X input method
imcmdline ; use IM when starting to edit a command line
imdisable ; do not use the IM in any mode
iminsert ; use :lmap or IM in Insert mode
imsearch ; use :lmap or IM when typing a search pattern
include ; pattern to be used to find an include file
includeexpr ; expression used to process an include line
incsearch ; highlight match while typing search pattern
indentexpr ; expression used to obtain the indent of a line
indentkeys ; keys that trigger indenting with 'indentexpr'
infercase ; adjust case of match for keyword completion
insertmode ; start the edit of a file in Insert mode
isfname ; characters included in file names and pathnames
isident ; characters included in identifiers
iskeyword ; characters included in keywords
isprint ; printable characters
joinspaces ; two spaces after a period with a join command
key ; encryption key
key ; for encrypting and decrypting the current buffer
keymap ; name of a keyboard mapping
keymodel ; enable starting/stopping selection with keys
keywordprg ; program to use for the "K" command
langmap ; alphabetic characters for other language mode
langmenu ; language to be used for the menus
laststatus ; tells when last window has status lines
lazyredraw ; don't redraw while executing macros
linebreak ; wrap long lines at a blank
lines ; number of lines in the display
linespace ; number of pixel lines to use between characters
lisp ; automatic indenting for Lisp
lispwords ; words that change how lisp indenting works
list ; show <Tab> and <EOL>
listchars ; characters for displaying in list mode
loadplugins ; load plugin scripts when starting up
macatsui ; Mac GUI: use ATSUI text drawing
magic ; changes special characters in search patterns
makeef ; name of the errorfile for ":make"
makeprg ; program to use for the ":make" command
matchpairs ; pairs of characters that "%" can match
matchtime ; tenths of a second to show matching paren
maxcombine ; maximum nr of combining characters displayed
maxfuncdepth ; maximum recursive depth for user functions
maxmapdepth ; maximum recursive depth for mapping
maxmem ; maximum memory (in Kbyte) used for one buffer
maxmempattern ; maximum memory (in Kbyte) used for pattern search
maxmemtot ; maximum memory (in Kbyte) used for all buffers
menuitems ; maximum number of items in a menu
mkspellmem ; memory used before :mkspell compresses the tree
modeline ; recognize modelines at start or end of file
modelines ; number of lines checked for modelines
modifiable ; changes to the text are not possible
modified ; buffer has been modified
more ; pause listings when the whole screen is filled
mouse ; enable the use of mouse clicks
mousefocus ; keyboard focus follows the mouse
mousehide ; hide mouse pointer while typing
mousemodel ; changes meaning of mouse buttons
mouseshape ; shape of the mouse pointer in different modes
mousetime ; max time between mouse double-click
mzquantum ; the interval between polls for MzScheme threads
nrformats ; number formats recognized for CTRL-A command
number ; print the line number in front of each line
numberwidth ; number of columns used for the line number
omnifunc ; function for filetype-specific completion
opendevice ; allow reading/writing devices on MS-Windows
operatorfunc ; function to be called for g@ operator
osfiletype ; operating system-specific filetype information
paragraphs ; nroff macros that separate paragraphs
paste ; allow pasting text
pastetoggle ; key code that causes 'paste' to toggle
patchexpr ; expression used to patch a file
patchmode ; keep the oldest version of a file
path ; list of directories searched with "gf" et.al.
preserveindent ; preserve the indent structure when reindenting
previewheight ; height of the preview window
previewwindow ; identifies the preview window
printdevice ; name of the printer to be used for :hardcopy
printencoding ; encoding to be used for printing
printexpr ; expression used to print PostScript for :hardcopy
printfont ; name of the font to be used for :hardcopy
printheader ; format of the header used for :hardcopy
printmbcharset ; CJK character set to be used for :hardcopy
printmbfont ; font names to be used for CJK output of :hardcopy
printoptions ; controls the format of :hardcopy output
pumheight ; maximum height of the popup menu
quoteescape ; escape characters used in a string
readonly ; disallow writing the buffer
redrawtime ; timeout for 'hlsearch' and :match highlighting
relativenumber ; show the line number relative to the line with the cursor in front of each line
remap ; allow mappings to work recursively
report ; threshold for reporting nr. of lines changed
restorescreen ; Win32: restore screen when exiting
revins ; inserting characters will work backwards
rightleft ; window is right-to-left oriented
rightleftcmd ; commands for which editing works right-to-left
ruler ; show cursor line and column in the status line
rulerformat ; custom format for the ruler
runtimepath ; list of directories used for runtime files
scroll ; lines to scroll with CTRL-U and CTRL-D
scrollbind ; scroll in window as other windows scroll
scrolljump ; minimum number of lines to scroll
scrolloff ; minimum nr. of lines above and below cursor
scrollopt ; how 'scrollbind' should behave
sections ; nroff macros that separate sections
secure ; secure mode for reading .vimrc in current dir
selection ; what type of selection to use
selectmode ; when to use Select mode instead of Visual mode
sessionoptions ; options for :mksession
shell ; name of shell to use for external commands
shellcmdflag ; flag to shell to execute one command
shellpipe ; string to put output of ":make" in error file
shellquote ; quote character(s) for around shell command
shellredir ; string to put output of filter in a temp file
shellslash ; use forward slash for shell file names
shelltemp ; whether to use a temp file for shell commands
shelltype ; Amiga: influences how to use a shell
shellxquote ; like 'shellquote', but include redirection
shiftround ; round indent to multiple of shiftwidth
shiftwidth ; number of spaces to use for (auto)indent step
shortmess ; list of flags, reduce length of messages
shortname ; non-MS-DOS: Filenames assumed to be 8.3 chars
showbreak ; string to use at the start of wrapped lines
showcmd ; show (partial) command in status line
showfulltag ; show full tag pattern when completing tag
showmatch ; briefly jump to matching bracket if insert one
showmode ; message on status line to show current mode
showtabline ; tells when the tab pages line is displayed
sidescroll ; minimum number of columns to scroll horizontal
sidescrolloff ; min. nr. of columns to left and right of cursor
smartcase ; no ignore case when pattern has uppercase
smartindent ; smart autoindenting for C programs
smarttab ; use 'shiftwidth' when inserting <Tab>
softtabstop ; number of spaces that <Tab> uses while editing
spell ; enable spell checking
spellcapcheck ; pattern to locate end of a sentence
spellfile ; files where zg and zw store words
spelllang ; language(s) to do spell checking for
spellsuggest ; method(s) used to suggest spelling corrections
splitbelow ; new window from split is below the current one
splitright ; new window is put right of the current one
startofline ; commands move cursor to first non-blank in line
statusline ; custom format for the status line
suffixes ; suffixes that are ignored with multiple match
suffixesadd ; suffixes added when searching for a file
swapfile ; whether to use a swapfile for a buffer
swapsync ; how to sync the swap file
switchbuf ; sets behavior when switching to another buffer
synmaxcol ; maximum column to find syntax items
syntax ; syntax to be loaded for current buffer
tabline ; custom format for the console tab pages line
tabpagemax ; maximum number of tab pages for -p and "tab all"
tabstop ; number of spaces that <Tab> in file uses
tagbsearch ; use binary searching in tags files
taglength ; number of significant characters for a tag
tagrelative ; file names in tag file are relative
tags ; list of file names used by the tag command
tagstack ; push tags onto the tag stack
term ; name of the terminal
termbidi ; terminal takes care of bi-directionality
termencoding ; character encoding used by the terminal
terse ; shorten some messages
textauto ; obsolete, use 'fileformats'
textmode ; obsolete, use 'fileformat'
textwidth ; maximum width of text that is being inserted
thesaurus ; list of thesaurus files for keyword completion
tildeop ; tilde command "~" behaves like an operator
timeout ; time out on mappings and key codes
timeoutlen ; time out time in milliseconds
title ; let Vim set the title of the window
titlelen ; percentage of 'columns' used for window title
titleold ; old title, restored when exiting
titlestring ; string to use for the Vim window title
toolbar ; GUI: which items to show in the toolbar
toolbariconsize ; size of the toolbar icons (for GTK 2 only)
transparency ; GUI: set transparency percentage (max: 255)
ttimeout ; time out on mappings
ttimeoutlen ; time out time for key codes in milliseconds
ttybuiltin ; use built-in termcap before external termcap
ttyfast ; indicates a fast terminal connection
ttymouse ; type of mouse codes generated
ttyscroll ; maximum number of lines for a scroll
ttytype ; alias for 'term'
undodir ; list of directory names for undo files
undofile ; automatically saves undo history to an undo file
undolevels ; maximum number of changes that can be undone
undoreload ; save the whole buffer for undo when reloading it
updatecount ; after this many characters flush swap file
updatetime ; after this many milliseconds flush swap file
verbose ; give informative messages
verbosefile ; file to write messages in
viewdir ; directory where to store files with :mkview
viewoptions ; specifies what to save for :mkview
viminfo ; use .viminfo file upon startup and exiting
virtualedit ; when to use virtual editing
visualbell ; use visual bell instead of beeping
warn ; warn for shell command when buffer was changed
weirdinvert ; for terminals that have weird inversion method
whichwrap ; allow specified keys to cross line boundaries
wildchar ; command-line character for wildcard expansion
wildcharm ; like 'wildchar' but also works when mapped
wildignore ; files matching these patterns are not completed
wildmenu ; use menu for command line completion
wildmode ; mode for 'wildchar' command-line expansion
wildoptions ; specifies how command line completion is done.
winaltkeys ; when the windows system handles ALT keys
winfixheight ; keep window height when opening/closing windows
winfixwidth ; keep window width when opening/closing windows
winheight ; minimum number of lines for the current window
winminheight ; minimum number of lines for any window
winminwidth ; minimal number of columns for any window
winwidth ; minimal number of columns for current window
wrap ; long lines wrap and continue on the next line
wrapmargin ; chars from the right where wrapping starts
wrapscan ; searches wrap around the end of the file
write ; writing to a file is allowed
writeany ; write to file with no need for "!" override
writebackup ; make a backup before overwriting a file
writedelay ; delay this many msec for each char (for debug)
autoload/neocomplcache/sources/vim_complete/variables.dict	[[[1
54
v:beval_col ; the number of the column, over which the mouse pointer is
v:beval_bufnr ; the number of the buffer, over which the mouse pointer is
v:beval_lnum ; the number of the line, over which the mouse pointer is
v:beval_text ; the text under or after the mouse pointer
v:beval_winnr ; the number of the window, over which the mouse pointer is
v:char ; argument for evaluating 'formatexpr' and used for the typed character when using <expr> in an abbreviation
v:charconvert_from ; the name of the character encoding of a file to be converted
v:charconvert_to ; the name of the character encoding of a file after conversion
v:cmdarg ; the extra arguments given to a file read/write command
v:cmdbang ; when a "!" was used the value is 1, otherwise it is 0
v:count ; the count given for the last Normal mode command
v:count1 ; Just like "v:count", but defaults to one when no count is used
v:ctype ; the current locale setting for characters of the runtime environment
v:dying ; normally zero, when a deadly signal is caught it's set to one
v:errmsg ; last given error message
v:exception ; the value of the exception most recently caught and not finished
v:fcs_reason ; the reason why the FileChangedShell event was triggered.
v:fcs_choice ; what should happen after a FileChangedShell event was triggered
v:fname_in ; the name of the input file
v:fname_out ; the name of the output file
v:fname_new ; the name of the new version of the file
v:fname_diff ; the name of the diff (patch) file
v:folddashes ; dashes representing foldlevel of a closed fold
v:foldlevel ; foldlevel of closed fold
v:foldend ; last line of closed fold
v:foldstart ; first line of closed fold
v:insertmode ; i: Insert mode r: Replace mode v: Virtual Replace mode
v:key ; key of the current item of a Dictionary
v:lang ; the current locale setting for messages of the runtime environment
v:lc_time ; the current locale setting for time messages of the runtime environment
v:lnum ; line number for the 'foldexpr' fold-expr and 'indentexpr' expressions
v:mouse_win ; window number for a mouse click obtained with getchar()
v:mouse_lnum ; line number for a mouse click obtained with getchar()
v:mouse_col ; column number for a mouse click obtained with getchar()
v:oldfiles ; list of file names that is loaded from the viminfo file on startup
v:operator ; the last operator given in Normal mode
v:prevcount ; the count given for the last but one Normal mode command
v:profiling ; normally zero. set to one after using ":profile start"
v:progname ; contains the name (with path removed) with which Vim was invoked
v:register ; the name of the register supplied to the last normal mode command
v:scrollstart ; string describing the script or function that caused the screen to scroll up
v:servername ; the resulting registered x11-clientserver name if any
v:searchforward ; search direction: 1 after a forward search, 0 after a backward search
v:shell_error ; result of the last shell command
v:statusmsg ; last given status message
v:swapname ; name of the swap file found
v:swapchoice ; SwapExists autocommands can set this to the selected choice
v:swapcommand ; normal mode command to be executed after a file has been opened
v:termresponse ; the escape sequence returned by the terminal for the t_RV termcap entry
v:this_session ; full filename of the last loaded or saved session file
v:throwpoint ; the point where the exception most recently caught and not finished was thrown
v:val ; value of the current item of a List or Dictionary
v:version ; version number of Vim: Major version*100+minor version
v:warningmsg ; last given warning message
autoload/neocomplcache/sources/vim_complete.vim	[[[1
185
"=============================================================================
" FILE: vim_complete.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 19 Aug 2010
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:source = {
      \ 'name' : 'vim_complete',
      \ 'kind' : 'ftplugin',
      \ 'filetypes' : { 'vim' : 1, },
      \}

function! s:source.initialize()"{{{
  " Initialize.
  let s:completion_length = has_key(g:neocomplcache_plugin_completion_length, 'vim_complete') ? 
        \ g:neocomplcache_plugin_completion_length['vim_complete'] : g:neocomplcache_auto_completion_start_length

  " Initialize complete function list."{{{
  if !exists('g:neocomplcache_vim_completefuncs')
    let g:neocomplcache_vim_completefuncs = {}
  endif
  "}}}

  " Set rank.
  call neocomplcache#set_dictionary_helper(g:neocomplcache_plugin_rank, 'vim_complete', 100)
  
  " Set completion length.
  call neocomplcache#set_completion_length('vim_complete', 1)
  
  " Call caching event.
  autocmd neocomplcache FileType * call neocomplcache#sources#vim_complete#helper#on_filetype()
  
  " Initialize check.
  call neocomplcache#sources#vim_complete#helper#on_filetype()

  " Add command.
  command! -nargs=? -complete=buffer NeoComplCacheCachingVim call neocomplcache#sources#vim_complete#helper#recaching(<q-args>)
endfunction"}}}

function! s:source.finalize()"{{{
  delcommand NeoComplCacheCachingVim
  
  if neocomplcache#exists_echodoc()
    call echodoc#unregister('vim_complete')
  endif
endfunction"}}}

function! s:source.get_keyword_pos(cur_text)"{{{
  if neocomplcache#within_comment()
    return -1
  endif

  let l:cur_text = neocomplcache#sources#vim_complete#get_cur_text()

  if l:cur_text =~ '^\s*"'
    " Comment.
    return -1
  endif

  let l:pattern = '\.\%(\h\w*\)\?$\|' . neocomplcache#get_keyword_pattern_end('vim')
  if l:cur_text !~ '^[[:digit:],[:space:]$''<>]*\h\w*$'
    let l:command_completion = neocomplcache#sources#vim_complete#helper#get_completion_name(
          \neocomplcache#sources#vim_complete#get_command(l:cur_text))
    if l:command_completion =~ '\%(dir\|file\|shellcmd\)'
      let l:pattern = neocomplcache#get_keyword_pattern_end('filename')
    endif
  endif
  
  let [l:cur_keyword_pos, l:cur_keyword_str] = neocomplcache#match_word(a:cur_text, l:pattern)

  return l:cur_keyword_pos
endfunction"}}}

function! s:source.get_complete_words(cur_keyword_pos, cur_keyword_str)"{{{
  let l:cur_text = neocomplcache#sources#vim_complete#get_cur_text()
  if (neocomplcache#is_auto_complete() && l:cur_text !~ '\h\w*\.\%(\h\w*\)\?$'
        \&& len(a:cur_keyword_str) < s:completion_length)
    return []
  endif

  if l:cur_text =~ '\h\w*\.\%(\h\w*\)\?$'
    " Dictionary.
    let l:cur_keyword_str = matchstr(l:cur_text, '.\%(\h\w*\)\?$')
    let l:list = neocomplcache#sources#vim_complete#helper#var_dictionary(l:cur_text, l:cur_keyword_str)
    return neocomplcache#keyword_filter(l:list, l:cur_keyword_str)
  elseif a:cur_keyword_str =~# '^&\%([gl]:\)\?'
    " Options.
    let l:prefix = matchstr(a:cur_keyword_str, '&\%([gl]:\)\?')
    let l:options = deepcopy(neocomplcache#sources#vim_complete#helper#option(l:cur_text, a:cur_keyword_str))
    for l:keyword in l:options
      let l:keyword.word = l:prefix . l:keyword.word
      let l:keyword.abbr = l:prefix . l:keyword.abbr
    endfor
    let l:list = l:options
  elseif l:cur_text =~# '\<has([''"]\w*$'
    " Features.
    let l:list = neocomplcache#sources#vim_complete#helper#feature(l:cur_text, a:cur_keyword_str)
  elseif l:cur_text =~# '\<expand([''"][<>[:alnum:]]*$'
    " Expand.
    let l:list = neocomplcache#sources#vim_complete#helper#expand(l:cur_text, a:cur_keyword_str)
  elseif a:cur_keyword_str =~ '^\$'
    " Environment.
    let l:list = neocomplcache#sources#vim_complete#helper#environment(l:cur_text, a:cur_keyword_str)
  elseif l:cur_text =~ '`=[^`]*$'
    " Expression.
    let l:list = neocomplcache#sources#vim_complete#helper#expression(l:cur_text, a:cur_keyword_str)
  elseif l:cur_text =~ '^[[:digit:],[:space:]$''<>]*!\s*\f\+$'
    " Shell commands.
    let l:list = neocomplcache#sources#vim_complete#helper#shellcmd(l:cur_text, a:cur_keyword_str)
  elseif l:cur_text =~ '^[[:digit:],[:space:]$''<>]*\h\w*$'
    " Commands.
    let l:list = neocomplcache#sources#vim_complete#helper#command(l:cur_text, a:cur_keyword_str)
    if bufname('%') ==# '[Command Line]'
      let l:ret = []
      " Use ambiguous filter.
      for pat in [
            \ '^'.a:cur_keyword_str,
            \ '\C^' . substitute(toupper(a:cur_keyword_str), '.', '\0\\l*', 'g') . '$',
            \ '\C' . substitute(toupper(a:cur_keyword_str), '.', '\0\\l*', 'g')]
        let l:ret += filter(copy(l:list), 'v:val.word =~? ' . string(pat))
      endfor
      call neocomplcache#used_match_filter()

      return l:ret
    endif
  else
    " Commands args.

    let l:command = neocomplcache#sources#vim_complete#get_command(l:cur_text)
    let l:list = neocomplcache#sources#vim_complete#helper#get_command_completion(l:command, l:cur_text, a:cur_keyword_str)

    if l:cur_text =~ '[[(,{]'
      " Expression.
      let l:list += neocomplcache#sources#vim_complete#helper#expression(l:cur_text, a:cur_keyword_str)
    endif
  endif

  return neocomplcache#keyword_filter(l:list, a:cur_keyword_str)
endfunction"}}}

function! neocomplcache#sources#vim_complete#define()"{{{
  return s:source
endfunction"}}}

function! neocomplcache#sources#vim_complete#get_cur_text()"{{{
  let l:cur_text = neocomplcache#get_cur_text()
  if &filetype == 'vimshell' && exists('*vimshell#get_secondary_prompt')
    return l:cur_text[len(vimshell#get_secondary_prompt()) :]
  endif

  let l:line = line('.')
  let l:cnt = 0
  while l:cur_text =~ '^\s*\\' && l:line > 1 && l:cnt < 5
    let l:cur_text = getline(l:line - 1) . substitute(l:cur_text, '^\s*\\', '', '')
    let l:line -= 1
    let l:cnt += 1
  endwhile

  return split(l:cur_text, '\s\+|\s\+\|<bar>', 1)[-1]
endfunction"}}}
function! neocomplcache#sources#vim_complete#get_command(cur_text)"{{{
  return matchstr(a:cur_text, '\<\%(\d\+\)\?\zs\h\w*\ze!\?\|\<\%([[:digit:],[:space:]$''<>]\+\)\?\zs\h\w*\ze/.*')
endfunction"}}}

" vim: foldmethod=marker
autoload/neocomplcache/util.vim	[[[1
91
"=============================================================================
" FILE: util.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 18 Jun 2010
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

" Original function is from mattn.
" http://github.com/mattn/googlereader-vim/tree/master
function! neocomplcache#util#truncate(str, num)"{{{
  let mx_first = '^\(.\)\(.*\)$'
  let str = a:str
  let ret = ''
  let width = 0
  while 1
    let char = substitute(str, mx_first, '\1', '')
    let ucs = char2nr(char)
    if ucs == 0
      break
    endif
    let cells = s:wcwidth(ucs)
    if width + cells > a:num
      break
    endif
    let width = width + cells
    let ret .= char
    let str = substitute(str, mx_first, '\2', '')
  endwhile
  while width + 1 <= a:num
    let ret .= " "
    let width = width + 1
  endwhile
  return ret
endfunction"}}}

function! neocomplcache#util#wcswidth(str)"{{{
  let mx_first = '^\(.\)'
  let str = a:str
  let width = 0
  while 1
    let ucs = char2nr(substitute(str, mx_first, '\1', ''))
    if ucs == 0
      break
    endif
    let width = width + s:wcwidth(ucs)
    let str = substitute(str, mx_first, '', '')
  endwhile
  return width
endfunction"}}}

function! s:wcwidth(ucs)"{{{
  let ucs = a:ucs
  if (ucs >= 0x1100
   \  && (ucs <= 0x115f
   \  || ucs == 0x2329
   \  || ucs == 0x232a
   \  || (ucs >= 0x2e80 && ucs <= 0xa4cf
   \      && ucs != 0x303f)
   \  || (ucs >= 0xac00 && ucs <= 0xd7a3)
   \  || (ucs >= 0xf900 && ucs <= 0xfaff)
   \  || (ucs >= 0xfe30 && ucs <= 0xfe6f)
   \  || (ucs >= 0xff00 && ucs <= 0xff60)
   \  || (ucs >= 0xffe0 && ucs <= 0xffe6)
   \  || (ucs >= 0x20000 && ucs <= 0x2fffd)
   \  || (ucs >= 0x30000 && ucs <= 0x3fffd)
   \  ))
    return 2
  endif
  return 1
endfunction"}}}

" vim: foldmethod=marker
autoload/neocomplcache.vim	[[[1
1780
"=============================================================================
" FILE: neocomplcache.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 30 Sep 2010
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
" Version: 5.2, for Vim 7.0
"=============================================================================

" Check vimproc.
try
  call vimproc#version()
  let s:exists_vimproc = 1
catch
  let s:exists_vimproc = 0
endtry

let s:is_enabled = 0

function! neocomplcache#enable() "{{{
  augroup neocomplcache "{{{
    autocmd!
    " Auto complete events
    autocmd CursorMovedI * call s:on_moved_i()
    autocmd CursorHoldI * call s:on_hold_i()
    autocmd InsertEnter * call s:on_insert_enter()
    autocmd InsertLeave * call s:on_insert_leave()
  augroup END "}}}
  
  " Disable beep.
  set vb t_vb=

  " Initialize"{{{
  let s:is_enabled = 1
  let s:complfunc_sources = {}
  let s:plugin_sources = {}
  let s:ftplugin_sources = {}
  let s:loaded_ftplugin_sources = {}
  let s:complete_lock = {}
  let s:auto_completion_length = {}
  let s:cur_keyword_pos = -1
  let s:cur_keyword_str = ''
  let s:complete_words = []
  let s:old_cur_keyword_pos = -1
  let s:quick_match_keywordpos = -1
  let s:old_complete_words = []
  let s:update_time_save = &updatetime
  let s:prev_numbered_dict = {}
  let s:cur_text = ''
  let s:old_cur_text = ''
  let s:moved_cur_text = ''
  let s:changedtick = b:changedtick
  let s:used_match_filter = 0
  let s:context_filetype = ''
  let s:is_text_mode = 0
  let s:within_comment = 0
  let s:skip_next_complete = 0
  "}}}

  " Initialize sources table."{{{
  " Search autoload.
  for file in split(globpath(&runtimepath, 'autoload/neocomplcache/sources/*.vim'), '\n')
    let l:source_name = fnamemodify(file, ':t:r')
    if !has_key(s:plugin_sources, l:source_name)
          \ && (!has_key(g:neocomplcache_plugin_disable, l:source_name) || 
          \ g:neocomplcache_plugin_disable[l:source_name] == 0)
      let l:source = call('neocomplcache#sources#' . l:source_name . '#define', [])
      if l:source.kind ==# 'complfunc'
        let s:complfunc_sources[l:source_name] = l:source
      elseif l:source.kind ==# 'ftplugin'
        let s:ftplugin_sources[l:source_name] = l:source

        " Clear loaded flag.
        let s:ftplugin_sources[l:source_name].loaded = 0
      elseif l:source.kind ==# 'plugin'
        let s:plugin_sources[l:source_name] = l:source
      endif
    endif
  endfor
  "}}}

  " Initialize keyword patterns."{{{
  if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
  endif
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'default',
        \'\k\+')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'filename',
  \'\%(\\[^[:alnum:].-]\|\f\)\+')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'lisp,scheme,clojure,int-gosh,int-clisp,int-clj', 
        \'[[:alnum:]+*@$%^&_=<>~.-]\+[!?]\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'ruby,int-irb',
        \'^=\%(b\%[egin]\|e\%[nd]\)\|\%(@@\|[:$@]\)\h\w*\|\h\w*\%(::\w*\)*[!?]\?\%(()\?\|\s\?\%(do\|{\)\s\?\)\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'php',
        \'</\?\%(\h[[:alnum:]_-]*\s*\)\?\%(/\?>\)\?\|\$\h\w*\|\h\w*\%(\%(\\\|::\)\w*\)*\%(()\?\)\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'perl,int-perlsh',
        \'<\h\w*>\?\|[$@%&*]\h\w*\|\h\w*\%(::\w*\)*\%(()\?\)\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'perl6,int-perl6',
        \'<\h\w*>\?\|[$@%&][!.*?]\?\h\w*\|\h\w*\%(::\w*\)*\%(()\?\)\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'pir',
        \'[$@%.=]\?\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'pasm',
        \'[=]\?\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'vim,help',
        \'\[:\%(\h\w*:\]\)\?\|&\h[[:alnum:]_:]*\|\$\h\w*\|-\h\w*=\?\|<\h[[:alnum:]_-]*>\?\|\h[[:alnum:]_:#]*\%(!\|()\?\)\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'tex',
        \'\\\a{\a\{1,2}}\|\\[[:alpha:]@][[:alnum:]@]*\%({\%([[:alnum:]:]\+\*\?}\?\)\?\)\?\|\a[[:alnum:]:]*\*\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'sh,zsh,int-zsh,int-bash,int-sh',
        \'\$\w\+\|[[:alpha:]_.-][[:alnum:]_.-]*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'vimshell',
        \'\$\$\?\w*\|[[:alpha:]_.\\/~-][[:alnum:]_.\\/~-]*\|\d\+\%(\.\d\+\)\+')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'ps1,int-powershell',
        \'\[\h\%([[:alnum:]_.]*\]::\)\?\|[$%@.]\?[[:alpha:]_.:-][[:alnum:]_.:-]*\%(()\?\)\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'c',
        \'^\s*#\s*\h\w*\|\h\w*\%(()\?\)\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'cpp',
        \'^\s*#\s*\h\w*\|\h\w*\%(::\w*\)*\%(()\?\|<>\?\)\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'objc',
        \'^\s*#\s*\h\w*\|\h\w*\%(()\?\|<>\?\|:\)\?\|@\h\w*\%(()\?\)\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'objcpp',
        \'^\s*#\s*\h\w*\|\h\w*\%(::\w*\)*\%(()\?\|<>\?\|:\)\?\|@\h\w*\%(()\?\)\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'objj',
        \'\h\w*\%(()\?\|<>\?\|:\)\?\|@\h\w*\%(()\?\)\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'd',
        \'\h\w*\%(!\?()\?\)\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'python,int-python,int-ipython',
        \'\h\w*\%(()\?\)\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'cs',
        \'\h\w*\%(()\?\|<\)\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'java',
        \'[@]\?\h\w*\%(()\?\|<\)\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'javascript,actionscript,int-js,int-kjs',
        \'\h\w*\%(()\?\)\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'coffee,int-coffee',
        \'@\h\w*\|\h\w*\%(()\?\)\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'awk',
        \'\h\w*\%(()\?\)\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'haskell,int-ghci',
        \'[[:alpha:]_''][[:alnum:]_'']*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'ml,ocaml,int-ocaml,int-sml,int-smlsharp',
        \'[''`#.]\?\h[[:alnum:]_'']*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'erlang,int-erl',
        \'^\s*-\h\w*()?\|\%(\h\w*:\)*\h\w()\?\|\h[[:alnum:]_@]*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'html,xhtml,xml,markdown,eruby',
        \'</\?\%([[:alnum:]_:-]\+\s*\)\?\%(/\?>\)\?\|&\h\%(\w*;\)\?\|\h[[:alnum:]_-]*="\%([^"]*"\?\)\?\|\h[[:alnum:]_:-]*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'css',
        \'[@#.]\?[[:alpha:]_:-][[:alnum:]_:-]*(\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'tags',
        \'^[^!][^/[:blank:]]*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'pic',
        \'^\s*#\h\w*\|\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'arm',
        \'\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'asmh8300',
        \'[[:alpha:]_.][[:alnum:]_.]*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'masm',
        \'\.\h\w*\|[[:alpha:]_@?$][[:alnum:]_@?$]*\|\h\w*:\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'nasm',
        \'^\s*\[\h\w*\|[%.]\?\h\w*\|\%(\.\.@\?\|%[%$!]\)\%(\h\w*\)\?\|\h\w*:\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'asm',
        \'[%$.]\?\h\w*\%(\$\h\w*\)\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'gas',
        \'[$.]\?\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'gdb,int-gdb',
        \'$\h\w*\|[[:alnum:]:._-]\+')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'make',
        \'[[:alpha:]_.-][[:alnum:]_.-]*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'scala,int-scala',
        \'\h\w*\%(()\?\|\[\)\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'int-termtter',
        \'\h[[:alnum:]_/-]*\|\$\a\+\|#\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'dosbatch,int-cmdproxy',
        \'\$\w+\|[[:alpha:]_./-][[:alnum:]_.-]*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'vb',
        \'\a[[:alnum:]]*\%(()\?\)\?\|#\a[[:alnum:]]*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns, 'lua',
        \'\h\w*\%(()\?\)\?')
  "}}}

  " Initialize next keyword patterns."{{{
  if !exists('g:neocomplcache_next_keyword_patterns')
    let g:neocomplcache_next_keyword_patterns = {}
  endif
  call neocomplcache#set_dictionary_helper(g:neocomplcache_next_keyword_patterns, 'perl',
        \'\h\w*>')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_next_keyword_patterns, 'perl6',
        \'\h\w*>')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_next_keyword_patterns, 'vim,help',
        \'\h\w*:\]\|\h\w*=\|[[:alnum:]_-]*>')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_next_keyword_patterns, 'tex',
        \'\h\w*\*\?[*[{}]')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_next_keyword_patterns, 'html,xhtml,xml,mkd',
        \'[[:alnum:]_:-]*>\|[^"]*"')
  "}}}

  " Initialize same file type lists."{{{
  if !exists('g:neocomplcache_same_filetype_lists')
    let g:neocomplcache_same_filetype_lists = {}
  endif
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'c', 'cpp')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'cpp', 'c')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'erb', 'ruby,html,xhtml')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'html,xml', 'xhtml')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'html,xhtml', 'css')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'xhtml', 'html,xml')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'help', 'vim')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'lingr-say', 'lingr-messages,lingr-members')

  " Interactive filetypes.
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'int-irb', 'ruby')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'int-ghci,int-hugs', 'haskell')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'int-python,int-ipython', 'python')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'int-gosh', 'scheme')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'int-clisp', 'lisp')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'int-erl', 'erlang')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'int-zsh', 'zsh')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'int-bash', 'bash')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'int-sh', 'sh')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'int-cmdproxy', 'dosbatch')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'int-powershell', 'powershell')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'int-perlsh', 'perl')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'int-perl6', 'perl6')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'int-ocaml', 'ocaml')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'int-clj', 'clojure')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'int-sml,int-smlsharp', 'sml')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'int-js,int-kjs', 'javascript')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'int-coffee', 'coffee')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'int-gdb', 'gdb')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists, 'int-scala', 'scala')
  "}}}

  " Initialize include filetype lists."{{{
  if !exists('g:neocomplcache_filetype_include_lists')
    let g:neocomplcache_filetype_include_lists = {}
  endif
  call neocomplcache#set_dictionary_helper(g:neocomplcache_filetype_include_lists, 'c,cpp', [
        \ {'filetype' : 'masm', 'start' : '_*asm\s*\%(\n\s*\)\?{', 'end' : '}'},
        \ {'filetype' : 'masm', 'start' : '_*asm\s*\h\w*', 'end' : '$'},
        \ {'filetype' : 'gas', 'start' : '_*asm_*\s*\%(_*volatile_*\s*\)\?(', 'end' : ');'},
        \])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_filetype_include_lists, 'd', [
        \ {'filetype' : 'masm', 'start' : 'asm\s*\%(\n\s*\)\?{', 'end' : '}'},
        \])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_filetype_include_lists, 'perl6', [
        \ {'filetype' : 'pir', 'start' : 'Q:PIR\s*{', 'end' : '}'},
        \])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_filetype_include_lists, 'vimshell', [
        \ {'filetype' : 'vim', 'start' : 'vexe \([''"]\)', 'end' : '\\\@<!\1'},
        \])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_filetype_include_lists, 'eruby', [
        \ {'filetype' : 'ruby', 'start' : '<%[=#]\?', 'end' : '%>'},
        \])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_filetype_include_lists, 'vim', [
        \ {'filetype' : 'python', 'start' : '^\s*python <<\s*\(\h\w*\)', 'end' : '^\1'},
        \ {'filetype' : 'ruby', 'start' : '^\s*ruby <<\s*\(\h\w*\)', 'end' : '^\1'},
        \])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_filetype_include_lists, 'html,xhtml', [
        \ {'filetype' : 'javascript', 'start' : '<script type="text/javascript">', 'end' : '</script>'},
        \ {'filetype' : 'css', 'start' : '<style type="text/css">', 'end' : '</style>'},  
        \])
  "}}}
  
  " Initialize member prefix patterns."{{{
  if !exists('g:neocomplcache_member_prefix_patterns')
    let g:neocomplcache_member_prefix_patterns = {}
  endif
  call neocomplcache#set_dictionary_helper(g:neocomplcache_member_prefix_patterns, 'c,cpp,objc,objcpp', '\.\|->')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_member_prefix_patterns, 'perl,php', '->')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_member_prefix_patterns, 'cs,java,javascript,d,vim,ruby,python,perl6,scala,vb', '\.')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_member_prefix_patterns, 'lua', '\.\|:')
  "}}}

  " Initialize delimiter patterns."{{{
  if !exists('g:neocomplcache_delimiter_patterns')
    let g:neocomplcache_delimiter_patterns = {}
  endif
  call neocomplcache#set_dictionary_helper(g:neocomplcache_delimiter_patterns, 'vim,help',
        \['#'])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_delimiter_patterns, 'erlang,lisp,int-clisp',
        \[':'])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_delimiter_patterns, 'perl,cpp',
        \['::'])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_delimiter_patterns, 'php',
        \['\', '::'])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_delimiter_patterns, 'java,d,javascript,actionscript,ruby,eruby,haskell,coffee',
        \['\.'])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_delimiter_patterns, 'lua',
        \['\.', ':'])
  "}}}
  
  " Initialize ctags arguments."{{{
  if !exists('g:neocomplcache_ctags_arguments_list')
    let g:neocomplcache_ctags_arguments_list = {}
  endif
  call neocomplcache#set_dictionary_helper(g:neocomplcache_ctags_arguments_list, 'default', '')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_ctags_arguments_list, 'vim',
        \"--extra=fq --fields=afmiKlnsStz --regex-vim='/function!? ([a-z#:_0-9A-Z]+)/\\1/function/'")
  if !neocomplcache#is_win() && (has('macunix') || neocomplcache#system('uname') =~? '^darwin')
    call neocomplcache#set_dictionary_helper(g:neocomplcache_ctags_arguments_list, 'c',
          \'--c-kinds=+p --fields=+iaS --extra=+q -I__DARWIN_ALIAS,__DARWIN_ALIAS_C,__DARWIN_ALIAS_I,__DARWIN_INODE64
          \ -I__DARWIN_1050,__DARWIN_1050ALIAS,__DARWIN_1050ALIAS_C,__DARWIN_1050ALIAS_I,__DARWIN_1050INODE64
          \ -I__DARWIN_EXTSN,__DARWIN_EXTSN_C
          \ -I__DARWIN_LDBL_COMPAT,__DARWIN_LDBL_COMPAT2')
  else
    call neocomplcache#set_dictionary_helper(g:neocomplcache_ctags_arguments_list, 'c',
          \'--c-kinds=+p --fields=+iaS --extra=+q -I __wur')
  endif
  call neocomplcache#set_dictionary_helper(g:neocomplcache_ctags_arguments_list, 'cpp',
        \'--c++-kinds=+p --fields=+iaS --extra=+q -I __wur')
  "}}}
  
  " Initialize text mode filetypes."{{{
  if !exists('g:neocomplcache_text_mode_filetypes')
    let g:neocomplcache_text_mode_filetypes = {}
  endif
  call neocomplcache#set_dictionary_helper(g:neocomplcache_text_mode_filetypes, 'text,help,tex,gitcommit,nothing', 1)
  "}}}

  " Initialize quick match patterns."{{{
  if !exists('g:neocomplcache_quick_match_patterns')
    let g:neocomplcache_quick_match_patterns = {}
  endif
  call neocomplcache#set_dictionary_helper(g:neocomplcache_quick_match_patterns, 'default', '-')
  "}}}

  " Initialize tags filter patterns."{{{
  if !exists('g:neocomplcache_tags_filter_patterns')
    let g:neocomplcache_tags_filter_patterns = {}
  endif
  call neocomplcache#set_dictionary_helper(g:neocomplcache_tags_filter_patterns, 'c,cpp', 
        \'v:val.word !~ ''^[~_]''')
  "}}}

  " Add commands."{{{
  command! -nargs=0 NeoComplCacheDisable call neocomplcache#disable()
  command! -nargs=? Neco call s:display_neco(<q-args>)
  command! -nargs=0 NeoComplCacheLock call s:lock()
  command! -nargs=0 NeoComplCacheUnlock call s:unlock()
  command! -nargs=0 NeoComplCacheToggle call s:toggle_lock()
  command! -nargs=1 NeoComplCacheAutoCompletionLength call s:set_auto_completion_length(<args>)
  "}}}

  " Must g:neocomplcache_auto_completion_start_length > 1.
  if g:neocomplcache_auto_completion_start_length < 1
    let g:neocomplcache_auto_completion_start_length = 1
  endif
  " Must g:neocomplcache_min_keyword_length > 1.
  if g:neocomplcache_min_keyword_length < 1
    let g:neocomplcache_min_keyword_length = 1
  endif

  " Save options.
  let s:completefunc_save = &completefunc
  let s:completeopt_save = &completeopt

  " Set completefunc.
  let &completefunc = 'neocomplcache#manual_complete'
  let &l:completefunc = 'neocomplcache#manual_complete'

  " Set options.
  set completeopt-=menu
  if !g:neocomplcache_disable_auto_complete
    set completeopt-=longest
  endif
  set completeopt+=menuone

  " Disable bell.
  set vb t_vb=
  
  " Initialize.
  for l:source in values(neocomplcache#available_complfuncs())
    call l:source.initialize()
  endfor
endfunction"}}}

function! neocomplcache#disable()"{{{
  let s:is_enabled = 0
  
  " Restore options.
  let &completefunc = s:completefunc_save
  let &completeopt = s:completeopt_save

  augroup neocomplcache
    autocmd!
  augroup END

  delcommand NeoComplCacheDisable
  delcommand Neco
  delcommand NeoComplCacheLock
  delcommand NeoComplCacheUnlock
  delcommand NeoComplCacheToggle
  delcommand NeoComplCacheAutoCompletionLength

  for l:source in values(neocomplcache#available_complfuncs())
    call l:source.finalize()
  endfor
  for l:source in values(neocomplcache#available_ftplugins())
    if l:source.loaded
      call l:source.finalize()
    endif
  endfor
endfunction"}}}

function! neocomplcache#manual_complete(findstart, base)"{{{
  if a:findstart
    if !neocomplcache#is_enabled()
      return -1
    endif
    
    let s:old_complete_words = []
    
    " Clear flag.
    let s:used_match_filter = 0
    
    let [l:cur_keyword_pos, l:cur_keyword_str, l:complete_words] = s:integrate_completion(s:get_complete_result(s:get_cur_text()), 1)
    if empty(l:complete_words)
      return -1
    endif
    let s:complete_words = l:complete_words

    return l:cur_keyword_pos
  else
    let s:old_complete_words = s:complete_words
    return s:complete_words
  endif
endfunction"}}}

function! neocomplcache#auto_complete(findstart, base)"{{{
  if a:findstart
    if !neocomplcache#is_enabled()
      return -1
    endif

    " Check text was changed.
    let l:cached_text = s:cur_text
    if s:get_cur_text() != l:cached_text
      " Text was changed.
      
      " Restore options.
      let s:cur_keyword_pos = -1
      let &l:completefunc = 'neocomplcache#manual_complete'
      let s:old_complete_words = s:complete_words
      let s:complete_words = []
      
      return -1
    endif
    
    let s:old_cur_keyword_pos = s:cur_keyword_pos
    let s:cur_keyword_pos = -1
    return s:old_cur_keyword_pos
  else
    " Restore option.
    let &l:completefunc = 'neocomplcache#manual_complete'
    let s:old_complete_words = s:complete_words
    let s:complete_words = []

    return s:old_complete_words
  endif
endfunction"}}}

function! neocomplcache#do_auto_complete(is_moved)"{{{
  if (&buftype !~ 'nofile\|nowrite' && b:changedtick == s:changedtick) || &paste
        \ || g:neocomplcache_disable_auto_complete
        \ || neocomplcache#is_locked()
        \ || (&l:completefunc != 'neocomplcache#manual_complete' && &l:completefunc != 'neocomplcache#auto_complete')
    return
  endif

  " Detect global completefunc.
  if &g:completefunc != 'neocomplcache#manual_complete' && &g:completefunc != 'neocomplcache#auto_complete'
    99verbose set completefunc
    echohl Error | echoerr 'Other plugin Use completefunc! Disabled neocomplcache.' | echohl None
    NeoComplCacheLock
    return
  endif

  " Detect AutoComplPop.
  if exists('g:acp_enableAtStartup') && g:acp_enableAtStartup
    echohl Error | echoerr 'Detected enabled AutoComplPop! Disabled neocomplcache.' | echohl None
    NeoComplCacheLock
    return
  endif

  " Get cursor word.
  let l:cur_text = s:get_cur_text()
  " Prevent infinity loop.
  if l:cur_text == '' || l:cur_text == s:old_cur_text
        \|| (!neocomplcache#is_eskk_enabled() && exists('b:skk_on') && b:skk_on)
    let s:complete_words = []
    let s:old_complete_words = []
    return
  endif

  let l:quick_match_pattern = s:get_quick_match_pattern()
  if g:neocomplcache_enable_quick_match && l:cur_text =~ l:quick_match_pattern.'[a-z0-9;,./]$'
    " Select quick_match list.
    let l:complete_words = s:select_quick_match_list(l:cur_text[-1:])
    let s:prev_numbered_dict = {}

    if !empty(l:complete_words)
      let s:complete_words = l:complete_words
      let s:cur_keyword_pos = s:old_cur_keyword_pos

      " Set function.
      let &l:completefunc = 'neocomplcache#auto_complete'
      if neocomplcache#is_auto_select()
        call feedkeys("\<C-x>\<C-u>\<C-p>\<Down>", 'n')
      else
        call feedkeys("\<C-x>\<C-u>", 'n')
      endif
      let s:old_cur_text = l:cur_text
      return 
    endif
  elseif g:neocomplcache_enable_quick_match 
        \&& !empty(s:old_complete_words)
        \&& l:cur_text =~ l:quick_match_pattern.'$'
        \&& l:cur_text !~ l:quick_match_pattern . l:quick_match_pattern.'$'

    " Print quick_match list.
    let [l:cur_keyword_pos, l:cur_keyword_str] = neocomplcache#match_word(l:cur_text[: -len(matchstr(l:cur_text, l:quick_match_pattern.'$'))-1])
    let s:cur_keyword_pos = l:cur_keyword_pos
    let s:complete_words = s:make_quick_match_list(s:old_complete_words, l:cur_keyword_str) 

    " Set function.
    let &l:completefunc = 'neocomplcache#auto_complete'
    call feedkeys("\<C-x>\<C-u>\<C-p>", 'n')
    let s:old_cur_text = l:cur_text
    return
  elseif a:is_moved && g:neocomplcache_enable_cursor_hold_i
        \&& !s:used_match_filter
    if l:cur_text !=# s:moved_cur_text
      let s:moved_cur_text = l:cur_text
      " Dummy cursor move.
      call feedkeys("a\<BS>", 'n')
      return
    endif
  endif

  let s:old_cur_text = l:cur_text
  if s:skip_next_complete
    let s:skip_next_complete = 0
    return
  endif

  " Clear flag.
  let s:used_match_filter = 0

  let l:is_quick_match_list = 0
  let s:prev_numbered_dict = {}
  let s:complete_words = []
  let s:old_complete_words = []
  let s:changedtick = b:changedtick

  " Set function.
  let &l:completefunc = 'neocomplcache#auto_complete'

  " Get complete result.
  let [l:cur_keyword_pos, l:cur_keyword_str, l:complete_words] = s:integrate_completion(s:get_complete_result(l:cur_text), 1)

  if empty(l:complete_words)
    let &l:completefunc = 'neocomplcache#manual_complete'
    let s:changedtick = b:changedtick
    let s:used_match_filter = 0
    return
  endif

  let [s:cur_keyword_pos, s:cur_keyword_str, s:complete_words] = 
        \[l:cur_keyword_pos, l:cur_keyword_str, l:complete_words]

  " Start auto complete.
  if neocomplcache#is_auto_select()
    call feedkeys("\<C-x>\<C-u>\<C-p>\<Down>", 'n')
  else
    call feedkeys("\<C-x>\<C-u>\<C-p>", 'n')
  endif
  let s:changedtick = b:changedtick
endfunction"}}}

" Plugin helper."{{{
function! neocomplcache#available_complfuncs()"{{{
  return s:complfunc_sources
endfunction"}}}
function! neocomplcache#available_ftplugins()"{{{
  return s:ftplugin_sources
endfunction"}}}
function! neocomplcache#available_loaded_ftplugins()"{{{
  return s:loaded_ftplugin_sources
endfunction"}}}
function! neocomplcache#available_plugins()"{{{
  return s:plugin_sources
endfunction"}}}
function! neocomplcache#available_sources()"{{{
  call s:set_context_filetype()
  return extend(extend(copy(s:complfunc_sources), s:plugin_sources), s:loaded_ftplugin_sources)
endfunction"}}}
function! neocomplcache#keyword_escape(cur_keyword_str)"{{{
  " Escape."{{{
  let l:keyword_escape = escape(a:cur_keyword_str, '~" \.^$[]')
  if g:neocomplcache_enable_wildcard
    let l:keyword_escape = substitute(substitute(l:keyword_escape, '.\zs\*', '.*', 'g'), '\%(^\|\*\)\zs\*', '\\*', 'g')
    if '-' !~ '\k'
      let l:keyword_escape = substitute(l:keyword_escape, '.\zs-', '.\\+', 'g')
    endif
  else
    let l:keyword_escape = escape(a:cur_keyword_str, '*')
  endif"}}}

  " Underbar completion."{{{
  if g:neocomplcache_enable_underbar_completion && l:keyword_escape =~ '_'
    let l:keyword_escape = substitute(l:keyword_escape, '[^_]\zs_', '[^_]*_', 'g')
  endif
  if g:neocomplcache_enable_underbar_completion && '-' =~ '\k' && l:keyword_escape =~ '-'
    let l:keyword_escape = substitute(l:keyword_escape, '[^-]\zs-', '[^-]*-', 'g')
  endif
  "}}}
  " Camel case completion."{{{
  if g:neocomplcache_enable_camel_case_completion && l:keyword_escape =~ '\u'
    let l:keyword_escape = substitute(l:keyword_escape, '\u\?\zs\U*', '\\%(\0\\l*\\|\U\0\E\\u*_\\?\\)', 'g')
  endif
  "}}}

  "echo l:keyword_escape
  return l:keyword_escape
endfunction"}}}
function! neocomplcache#keyword_filter(list, cur_keyword_str)"{{{
  let l:cur_keyword_str = a:cur_keyword_str

  " Delimiter check.
  let l:filetype = neocomplcache#get_context_filetype()
  if has_key(g:neocomplcache_delimiter_patterns, l:filetype)"{{{
    for l:delimiter in g:neocomplcache_delimiter_patterns[l:filetype]
      let l:cur_keyword_str = substitute(l:cur_keyword_str, l:delimiter, '*' . l:delimiter, 'g')
    endfor
  endif"}}}
  
  if l:cur_keyword_str == ''
    return a:list
  elseif neocomplcache#check_match_filter(l:cur_keyword_str)
    let s:used_match_filter = 1
    " Match filter.
    return filter(a:list, printf("v:val.word =~ %s", 
          \string('^' . neocomplcache#keyword_escape(l:cur_keyword_str))))
  else
    " Use fast filter.
    return neocomplcache#head_filter(a:list, l:cur_keyword_str)
  endif
endfunction"}}}
function! neocomplcache#dup_filter(list)"{{{
  let l:dict = {}
  for l:keyword in a:list
    if !has_key(l:dict, l:keyword.word)
      let l:dict[l:keyword.word] = l:keyword
    endif
  endfor

  return values(l:dict)
endfunction"}}}
function! neocomplcache#check_match_filter(cur_keyword_str, ...)"{{{
  return neocomplcache#keyword_escape(
        \empty(a:000)? a:cur_keyword_str : a:cur_keyword_str[ : a:1-1]) =~ '[^\\]\*\|\\+'
endfunction"}}}
function! neocomplcache#head_filter(list, cur_keyword_str)"{{{
  if &ignorecase
    let l:expr = printf('!stridx(tolower(v:val.word), %s)', string(tolower(a:cur_keyword_str)))
  else
    let l:expr = printf('!stridx(v:val.word, %s)', string(a:cur_keyword_str))
  endif

  return filter(a:list, l:expr)
endfunction"}}}
function! neocomplcache#fuzzy_filter(list, cur_keyword_str)"{{{
  let l:ret = []
  
  let l:cur_keyword_str = a:cur_keyword_str[2:]
  let l:max_str2 = len(l:cur_keyword_str)
  let l:len = len(a:cur_keyword_str)
  let m = range(l:max_str2+1)
  for keyword in filter(a:list, 'len(v:val.word) >= '.l:max_str2)
    let l:str1 = keyword.word[2 : l:len-1]
    
    let i = 0
    while i <= l:max_str2+1
      let m[i] = range(l:max_str2+1)
      
      let i += 1
    endwhile
    let i = 0
    while i <= l:max_str2+1
      let m[i][0] = i
      let m[0][i] = i
      
      let i += 1
    endwhile
    
    let i = 1
    let l:max = l:max_str2 + 1
    while i < l:max
      let j = 1
      while j < l:max
        let m[i][j] = min([m[i-1][j]+1, m[i][j-1]+1, m[i-1][j-1]+(l:str1[i-1] != l:cur_keyword_str[j-1])])

        let j += 1
      endwhile

      let i += 1
    endwhile
    if m[-1][-1] <= 2
      call add(l:ret, keyword)
    endif
  endfor

  return ret
endfunction"}}}
function! neocomplcache#dictionary_filter(dictionary, cur_keyword_str, completion_length)"{{{
  if len(a:cur_keyword_str) < a:completion_length ||
        \neocomplcache#check_match_filter(a:cur_keyword_str, a:completion_length)
    return neocomplcache#keyword_filter(neocomplcache#unpack_dictionary(a:dictionary), a:cur_keyword_str)
  else
    let l:key = tolower(a:cur_keyword_str[: a:completion_length-1])

    if !has_key(a:dictionary, l:key)
      return []
    endif

    return (len(a:cur_keyword_str) == a:completion_length && &ignorecase)?
          \ a:dictionary[l:key] : neocomplcache#keyword_filter(copy(a:dictionary[l:key]), a:cur_keyword_str)
  endif
endfunction"}}}
function! neocomplcache#unpack_dictionary(dict)"{{{
  let l:ret = []
  for l in values(a:dict)
    let l:ret += l
  endfor

  return l:ret
endfunction"}}}
function! neocomplcache#unpack_dictionary_dictionary(dict)"{{{
  let l:ret = []
  for l in values(a:dict)
    let l:ret += values(l)
  endfor

  return l:ret
endfunction"}}}
function! neocomplcache#add_dictionaries(dictionaries)"{{{
  if empty(a:dictionaries)
    return {}
  endif

  let l:ret = a:dictionaries[0]
  for l:dict in a:dictionaries[1:]
    for [l:key, l:value] in items(l:dict)
      if has_key(l:ret, l:key)
        let l:ret[l:key] += l:value
      else
        let l:ret[l:key] = l:value
      endif
    endfor
  endfor

  return l:ret
endfunction"}}}
function! neocomplcache#used_match_filter()"{{{
  let s:used_match_filter = 1
endfunction"}}}

" RankOrder."{{{
function! neocomplcache#compare_rank(i1, i2)
  return a:i2.rank - a:i1.rank
endfunction"}}}
" PosOrder."{{{
function! s:compare_pos(i1, i2)
  return a:i1[0] == a:i2[0] ? a:i1[1] - a:i2[1] : a:i1[0] - a:i2[0]
endfunction"}}}

function! neocomplcache#rand(max)"{{{
  let l:time = reltime()[1]
  return (l:time < 0 ? -l:time : l:time)% (a:max + 1)
endfunction"}}}
function! neocomplcache#system(str, ...)"{{{
  let l:command = a:str
  let l:input = a:0 >= 1 ? a:1 : ''
  if &termencoding != '' && &termencoding != &encoding
    let l:command = iconv(l:command, &encoding, &termencoding)
    let l:input = iconv(l:input, &encoding, &termencoding)
  endif
  
  if !s:exists_vimproc
    if a:0 == 0
      let l:output = system(l:command)
    else
      let l:output = system(l:command, l:input)
    endif
  elseif a:0 == 0
    let l:output = vimproc#system(l:command)
  elseif a:0 == 1
    let l:output = vimproc#system(l:command, l:input)
  else
    let l:output = vimproc#system(l:command, l:input, a:2)
  endif
  
  if &termencoding != '' && &termencoding != &encoding
    let l:output = iconv(l:output, &termencoding, &encoding)
  endif
  
  return l:output
endfunction"}}}

function! neocomplcache#get_cur_text(...)"{{{
  " Return cached text.
  return a:0 == 0 ? s:cur_text : s:get_cur_text()
endfunction"}}}
function! neocomplcache#get_completion_length(plugin_name)"{{{
  if neocomplcache#is_auto_complete() && has_key(s:auto_completion_length, bufnr('%'))
    return s:auto_completion_length[bufnr('%')]
  elseif has_key(g:neocomplcache_plugin_completion_length, a:plugin_name)
    return g:neocomplcache_plugin_completion_length[a:plugin_name]
  elseif neocomplcache#is_auto_complete()
    return g:neocomplcache_auto_completion_start_length
  else
    return g:neocomplcache_manual_completion_start_length
  endif
endfunction"}}}
function! neocomplcache#set_completion_length(plugin_name, length)"{{{
  if !has_key(g:neocomplcache_plugin_completion_length, a:plugin_name)
    let g:neocomplcache_plugin_completion_length[a:plugin_name] = a:length
  endif
endfunction"}}}
function! neocomplcache#get_auto_completion_length(plugin_name)"{{{
  if has_key(g:neocomplcache_plugin_completion_length, a:plugin_name)
    return g:neocomplcache_plugin_completion_length[a:plugin_name]
  else
    return g:neocomplcache_auto_completion_start_length
  endif
endfunction"}}}
function! neocomplcache#get_keyword_pattern(...)"{{{
  let l:filetype = a:0 != 0? a:000[0] : neocomplcache#get_context_filetype()

  let l:keyword_patterns = []
  for l:ft in split(l:filetype, '\.')
    call add(l:keyword_patterns, has_key(g:neocomplcache_keyword_patterns, l:ft) ?
          \ g:neocomplcache_keyword_patterns[l:ft] : g:neocomplcache_keyword_patterns['default'])
  endfor

  return join(l:keyword_patterns, '\m\|')
endfunction"}}}
function! neocomplcache#get_next_keyword_pattern(...)"{{{
  let l:filetype = a:0 != 0? a:000[0] : neocomplcache#get_context_filetype()

  if has_key(g:neocomplcache_next_keyword_patterns, l:filetype)
    return g:neocomplcache_next_keyword_patterns[l:filetype] . '\m\|' . neocomplcache#get_keyword_pattern(l:filetype)
  else
    return neocomplcache#get_keyword_pattern(l:filetype)
  endif
endfunction"}}}
function! neocomplcache#get_keyword_pattern_end(...)"{{{
  let l:filetype = a:0 != 0? a:000[0] : neocomplcache#get_context_filetype()

  return '\%('.neocomplcache#get_keyword_pattern(l:filetype).'\m\)$'
endfunction"}}}
function! neocomplcache#get_prev_word(cur_keyword_str)"{{{
  let l:keyword_pattern = neocomplcache#get_keyword_pattern()
  let l:line_part = neocomplcache#get_cur_text()[: -1-len(a:cur_keyword_str)]
  let l:prev_word_end = matchend(l:line_part, l:keyword_pattern)
  if l:prev_word_end > 0
    let l:word_end = matchend(l:line_part, l:keyword_pattern, l:prev_word_end)
    if l:word_end >= 0
      while l:word_end >= 0
        let l:prev_word_end = l:word_end
        let l:word_end = matchend(l:line_part, l:keyword_pattern, l:prev_word_end)
      endwhile
    endif

    let l:prev_word = matchstr(l:line_part[: l:prev_word_end-1], l:keyword_pattern . '$')
  else
    let l:prev_word = '^'
  endif

  return l:prev_word
endfunction"}}}
function! neocomplcache#match_word(cur_text, ...)"{{{
  let l:pattern = a:0 >= 1 ? a:1 : neocomplcache#get_keyword_pattern_end()
  
  " Check wildcard.
  let l:cur_keyword_pos = s:match_wildcard(a:cur_text, l:pattern, match(a:cur_text, l:pattern))
  
  let l:cur_keyword_str = a:cur_text[l:cur_keyword_pos :]
  
  return [l:cur_keyword_pos, l:cur_keyword_str]
endfunction"}}}
function! neocomplcache#is_enabled()"{{{
  return s:is_enabled
endfunction"}}}
function! neocomplcache#is_locked(...)"{{{
  let l:bufnr = a:0 > 0 ? a:1 : bufnr('%')
  return !s:is_enabled 
        \ || (has_key(s:complete_lock, l:bufnr) && s:complete_lock[l:bufnr])
        \ || (g:neocomplcache_lock_buffer_name_pattern != '' && bufname(l:bufnr) =~ g:neocomplcache_lock_buffer_name_pattern)
endfunction"}}}
function! neocomplcache#is_auto_select()"{{{
  return g:neocomplcache_enable_auto_select && !neocomplcache#is_eskk_enabled()
        \ && (g:neocomplcache_disable_auto_select_buffer_name_pattern == ''
        \     || bufname('%') !~ g:neocomplcache_disable_auto_select_buffer_name_pattern)
endfunction"}}}
function! neocomplcache#is_auto_complete()"{{{
  return &l:completefunc == 'neocomplcache#auto_complete'
endfunction"}}}
function! neocomplcache#is_eskk_enabled()"{{{
  return exists('g:loaded_eskk') && (!exists('g:eskk_disable') || !g:eskk_disable) && eskk#is_enabled()
endfunction"}}}
function! neocomplcache#is_text_mode()"{{{
  return s:is_text_mode || s:within_comment
endfunction"}}}
function! neocomplcache#is_win()"{{{
  return has('win32') || has('win64')
endfunction"}}}
function! neocomplcache#exists_echodoc()"{{{
  return exists('g:loaded_echodoc') && g:loaded_echodoc
endfunction"}}}
function! neocomplcache#within_comment()"{{{
  return s:within_comment
endfunction"}}}
function! neocomplcache#print_caching(string)"{{{
  if g:neocomplcache_enable_caching_message
    redraw
    echon a:string
  endif
endfunction"}}}
function! neocomplcache#print_error(string)"{{{
  echohl Error | echomsg a:string | echohl None
endfunction"}}}
function! neocomplcache#print_warning(string)"{{{
  echohl WarningMsg | echomsg a:string | echohl None
endfunction"}}}
function! neocomplcache#trunk_string(string, max)"{{{
  return printf('%.' . a:max-10 . 's..%%s', a:string, a:string[-8:])
endfunction"}}}
function! neocomplcache#head_match(checkstr, headstr)"{{{
  return stridx(a:checkstr, a:headstr) == 0
endfunction"}}}
function! neocomplcache#get_source_filetypes(filetype)"{{{
  let l:filetype = a:filetype == ''? 'nothing' : a:filetype

  let l:filetype_dict = {}

  let l:filetypes = [l:filetype]
  if l:filetype =~ '\.'
    " Set compound filetype.
    let l:filetypes += split(l:filetype, '\.')
  endif

  for l:ft in l:filetypes
    let l:filetype_dict[l:ft] = 1

    " Set same filetype.
    if has_key(g:neocomplcache_same_filetype_lists, l:ft)
      for l:same_ft in split(g:neocomplcache_same_filetype_lists[l:ft], ',')
        let l:filetype_dict[l:same_ft] = 1
      endfor
    endif
  endfor

  return l:filetype_dict
endfunction"}}}
function! neocomplcache#get_sources_list(dictionary, filetype)"{{{
  let l:list = []
  for l:filetype in keys(neocomplcache#get_source_filetypes(a:filetype))
    if has_key(a:dictionary, l:filetype)
      call add(l:list, a:dictionary[l:filetype])
    endif
  endfor

  return l:list
endfunction"}}}
function! neocomplcache#escape_match(str)"{{{
  return escape(a:str, '~"*\.^$[]')
endfunction"}}}
function! neocomplcache#get_context_filetype(...)"{{{
  if a:0 != 0 || s:context_filetype == ''
    call s:set_context_filetype()
  endif
  
  return s:context_filetype
endfunction"}}}
function! neocomplcache#get_plugin_rank(plugin_name)"{{{
  if has_key(g:neocomplcache_plugin_rank, a:plugin_name)
    return g:neocomplcache_plugin_rank[a:plugin_name]
  elseif has_key(s:complfunc_sources, a:plugin_name)
    return 10
  elseif has_key(s:ftplugin_sources, a:plugin_name)
    return 100
  elseif has_key(s:plugin_sources, a:plugin_name)
    return 5
  else
    " unknown.
    return 1
  endif
endfunction"}}}
function! neocomplcache#get_syn_name(is_trans)"{{{
  return synIDattr(synID(line('.'), mode() ==# 'i' ? col('.')-1 : col('.'), a:is_trans), 'name')
endfunction"}}}

" Set pattern helper.
function! neocomplcache#set_dictionary_helper(variable, keys, pattern)"{{{
  for key in split(a:keys, ',')
    if !has_key(a:variable, key) 
      let a:variable[key] = a:pattern
    endif
  endfor
endfunction"}}}

" Complete filetype helper.
function! neocomplcache#filetype_complete(arglead, cmdline, cursorpos)"{{{
  " Dup check.
  let l:ret = {}
  for l:item in map(split(globpath(&runtimepath, 'syntax/*.vim'), '\n'), 'fnamemodify(v:val, ":t:r")')
    if !has_key(l:ret, l:item) && l:item =~ '^'.a:arglead
      let l:ret[l:item] = 1
    endif
  endfor

  return sort(keys(l:ret))
endfunction"}}}
"}}}

" Command functions."{{{
function! s:toggle_lock()"{{{
  if !has_key(s:complete_lock, bufnr('%')) || !s:complete_lock[bufnr('%')]
    call s:lock()
  else
    call s:unlock()
  endif
endfunction"}}}
function! s:lock()"{{{
  let s:complete_lock[bufnr('%')] = 1
endfunction"}}}
function! s:unlock()"{{{
  let s:complete_lock[bufnr('%')] = 0
endfunction"}}}
function! s:display_neco(number)"{{{
  let l:cmdheight_save = &cmdheight
  
  let l:animation = [
    \[
        \[
        \ "   A A", 
        \ "~(-'_'-)"
        \], 
        \[
        \ "      A A", 
        \ "   ~(-'_'-)",
        \],
        \[
        \ "        A A", 
        \ "     ~(-'_'-)",
        \],
        \[
        \ "          A A  ", 
        \ "       ~(-'_'-)",
        \], 
        \[
        \ "             A A", 
        \ "          ~(-^_^-)",
        \], 
    \],
    \[
        \[
        \ "   A A", 
        \ "~(-'_'-)",
        \],
        \[
        \ "      A A", 
        \ "   ~(-'_'-)",
        \],
        \[
        \ "        A A", 
        \ "     ~(-'_'-)",
        \],
        \[
        \ "          A A  ", 
        \ "       ~(-'_'-)",
        \], 
        \[
        \ "             A A", 
        \ "          ~(-'_'-)",
        \],
        \[
        \ "          A A  ", 
        \ "       ~(-'_'-)"
        \],
        \[
        \ "        A A", 
        \ "     ~(-'_'-)"
        \],
        \[
        \ "      A A", 
        \ "   ~(-'_'-)"
        \],
        \[
        \ "   A A", 
        \ "~(-'_'-)"
        \],
    \],
    \[
        \[
        \ "   A A", 
        \ "~(-'_'-)",
        \], 
        \[
        \ "        A A", 
        \ "     ~(-'_'-)",
        \],
        \[
        \ "             A A", 
        \ "          ~(-'_'-)",
        \],
        \[
        \ "                  A A", 
        \ "               ~(-'_'-)",
        \],
        \[
        \ "                       A A", 
        \ "                    ~(-'_'-)",
        \],
        \["                           A A", 
        \ "                        ~(-'_'-)",
        \],
    \],
    \[
        \[
        \ "",
        \ "   A A", 
        \ "~(-'_'-)",
        \], 
        \["      A A", 
        \ "   ~(-'_'-)",
        \ "",
        \], 
        \[
        \ "",
        \ "        A A", 
        \ "     ~(-'_'-)",
        \],
        \[
        \ "          A A  ", 
        \ "       ~(-'_'-)", 
        \ "",
        \], 
        \[
        \ "",
        \ "             A A", 
        \ "          ~(-^_^-)",
        \],
    \],
    \[
        \[
        \ "   A A        A A", 
        \ "~(-'_'-)  -8(*'_'*)"
        \], 
        \[
        \ "     A A        A A", 
        \ "  ~(-'_'-)  -8(*'_'*)"
        \],
        \[
        \ "       A A        A A", 
        \ "    ~(-'_'-)  -8(*'_'*)"
        \],
        \[
        \ "     A A        A A", 
        \ "  ~(-'_'-)  -8(*'_'*)"
        \], 
        \[
        \ "   A A        A A", 
        \ "~(-'_'-)  -8(*'_'*)"
        \], 
    \],
    \[
        \[
        \ "  A\\_A\\",
        \ "(=' .' ) ~笙･",
        \ "(,(\")(\")",
        \], 
    \],
  \]

  let l:anim = get(l:animation, a:number, l:animation[neocomplcache#rand(len(l:animation) - 1)])
  let &cmdheight = len(l:anim[0])

  for l:frame in l:anim
    echo repeat("\n", &cmdheight-2)
    redraw
    echon join(l:frame, "\n")
    sleep 300m
  endfor
  redraw

  let &cmdheight = l:cmdheight_save
endfunction"}}}
function! s:set_auto_completion_length(len)"{{{
  let s:auto_completion_length[bufnr('%')] = a:len
endfunction"}}}
"}}}

" Key mapping functions."{{{
function! neocomplcache#smart_close_popup()"{{{
  return g:neocomplcache_enable_auto_select ? neocomplcache#cancel_popup() : neocomplcache#close_popup()
endfunction
"}}}
function! neocomplcache#close_popup()"{{{
  if !pumvisible()
    return ''
  endif

  let s:skip_next_complete = 1
  let s:cur_keyword_pos = -1
  let s:cur_keyword_str = ''
  let s:complete_words = []
  let s:old_complete_words = []
  let s:prev_numbered_dict = {}
  
  return "\<C-y>"
endfunction
"}}}
function! neocomplcache#cancel_popup()"{{{
  if !pumvisible()
    return ''
  endif

  let s:skip_next_complete = 1
  let s:cur_keyword_pos = -1
  let s:cur_keyword_str = ''
  let s:complete_words = []
  let s:old_complete_words = []
  let s:prev_numbered_dict = {}
  
  return "\<C-e>"
endfunction
"}}}

" Wrapper functions.
function! neocomplcache#manual_filename_complete()"{{{
  return neocomplcache#start_manual_complete('filename_complete')
endfunction"}}}
function! neocomplcache#manual_omni_complete()"{{{
  return neocomplcache#start_manual_complete('omni_complete')
endfunction"}}}
function! neocomplcache#manual_keyword_complete()"{{{
  return neocomplcache#start_manual_complete('keyword_complete')
endfunction"}}}

" Manual complete wrapper.
function! neocomplcache#start_manual_complete(complfunc_name)"{{{
  let l:sources = neocomplcache#available_sources()
  if !has_key(l:sources, a:complfunc_name)
    echoerr printf("Invalid completefunc name %s is given.", a:complfunc_name)
    return ''
  endif
  
  " Clear flag.
  let s:used_match_filter = 0

  " Set function.
  let &l:completefunc = 'neocomplcache#manual_complete'

  " Get complete result.
  let l:dict = {}
  let l:dict[a:complfunc_name] = l:sources[a:complfunc_name]
  let [l:cur_keyword_pos, l:cur_keyword_str, l:complete_words] = 
        \ s:integrate_completion(s:get_complete_result(s:get_cur_text(), l:dict), 0)
  
  " Restore function.
  let &l:completefunc = 'neocomplcache#auto_complete'

  let [s:cur_keyword_pos, s:cur_keyword_str, s:complete_words] = [l:cur_keyword_pos, l:cur_keyword_str, l:complete_words]

  " Start complete.
  return "\<C-x>\<C-u>\<C-p>"
endfunction"}}}
function! neocomplcache#start_manual_complete_list(cur_keyword_pos, cur_keyword_str, complete_words)"{{{
  let [s:cur_keyword_pos, s:cur_keyword_str, s:complete_words] = [a:cur_keyword_pos, a:cur_keyword_str, a:complete_words]

  " Set function.
  let &l:completefunc = 'neocomplcache#auto_complete'

  " Start complete.
  return "\<C-x>\<C-u>\<C-p>"
endfunction"}}}

function! neocomplcache#undo_completion()"{{{
  if !exists(':NeoComplCacheDisable')
    return ''
  endif

  " Get cursor word.
  let [l:cur_keyword_pos, l:cur_keyword_str] = neocomplcache#match_word(s:get_cur_text())
  let l:old_keyword_str = s:cur_keyword_str
  let s:cur_keyword_str = l:cur_keyword_str

  return (pumvisible() ? "\<C-e>" : '')
        \ . repeat("\<BS>", len(l:cur_keyword_str)) . l:old_keyword_str
endfunction"}}}

function! neocomplcache#complete_common_string()"{{{
  if !exists(':NeoComplCacheDisable')
    return ''
  endif

  " Save options.
  let l:ignorecase_save = &ignorecase

  " Get cursor word.
  let [l:cur_keyword_pos, l:cur_keyword_str] = neocomplcache#match_word(s:get_cur_text())
  
  if neocomplcache#is_text_mode()
    let &ignorecase = 1
  elseif g:neocomplcache_enable_smart_case && l:cur_keyword_str =~ '\u'
    let &ignorecase = 0
  else
    let &ignorecase = g:neocomplcache_enable_ignore_case
  endif

  let l:complete_words = neocomplcache#keyword_filter(copy(s:old_complete_words), l:cur_keyword_str)
  
  if empty(l:complete_words)
    let &ignorecase = l:ignorecase_save

    return ''
  endif

  let l:common_str = l:complete_words[0].word
  for keyword in l:complete_words[1:]
    while !neocomplcache#head_match(keyword.word, l:common_str) 
      let l:common_str = l:common_str[: -2]
    endwhile
  endfor
  if &ignorecase
    let l:common_str = tolower(l:common_str)
  endif

  let &ignorecase = l:ignorecase_save

  return (pumvisible() ? "\<C-e>" : '')
        \ . repeat("\<BS>", len(l:cur_keyword_str)) . l:common_str
endfunction"}}}
"}}}

" Event functions."{{{
function! s:on_hold_i()"{{{
  if g:neocomplcache_enable_cursor_hold_i
    call neocomplcache#do_auto_complete(0)
  endif
endfunction"}}}
function! s:on_moved_i()"{{{
  call neocomplcache#do_auto_complete(1)
endfunction"}}}
function! s:get_complete_result(cur_text, ...)"{{{
  " Set context filetype.
  call s:set_context_filetype()
  
  let l:complfuncs = a:0 == 0 ? extend(copy(neocomplcache#available_complfuncs()), neocomplcache#available_loaded_ftplugins()) : a:1
  
  " Try complfuncs completion."{{{
  let l:complete_result = {}
  for [l:complfunc_name, l:complfunc] in items(l:complfuncs)
    if (has_key(g:neocomplcache_plugin_disable, l:complfunc_name) && g:neocomplcache_plugin_disable[l:complfunc_name])
        \ || (neocomplcache#is_eskk_enabled() && l:complfunc_name !=# 'omni_complete')
      " Skip plugin.
      continue
    endif

    try
      let l:cur_keyword_pos = l:complfunc.get_keyword_pos(a:cur_text)
    catch
      call neocomplcache#print_error(v:throwpoint)
      call neocomplcache#print_error(v:exception)
      call neocomplcache#print_error('Error occured in complfunc''s get_keyword_pos()!')
      call neocomplcache#print_error('Plugin name is ' . l:complfunc_name)
      return
    endtry

    if l:cur_keyword_pos >= 0
      let l:cur_keyword_str = a:cur_text[l:cur_keyword_pos :]
      if len(l:cur_keyword_str) < neocomplcache#get_completion_length(l:complfunc_name)
        " Skip.
        continue
      endif

      " Save options.
      let l:ignorecase_save = &ignorecase

      if neocomplcache#is_text_mode()
        let &ignorecase = 1
      elseif g:neocomplcache_enable_smart_case && l:cur_keyword_str =~ '\u'
        let &ignorecase = 0
      else
        let &ignorecase = g:neocomplcache_enable_ignore_case
      endif

      try
        let l:words = l:complfunc.get_complete_words(l:cur_keyword_pos, l:cur_keyword_str)
      catch
        call neocomplcache#print_error(v:throwpoint)
        call neocomplcache#print_error(v:exception)
        call neocomplcache#print_error('Error occured in complfunc''s get_complete_words()!')
        call neocomplcache#print_error('Plugin name is ' . l:complfunc_name)
        return
      endtry

      let &ignorecase = l:ignorecase_save

      if !empty(l:words)
        let l:complete_result[l:complfunc_name] = {
              \ 'complete_words' : l:words, 
              \ 'cur_keyword_pos' : l:cur_keyword_pos, 
              \ 'cur_keyword_str' : l:cur_keyword_str, 
              \}
      endif
    endif
  endfor
  "}}}
  
  return l:complete_result
endfunction"}}}
function! s:integrate_completion(complete_result, is_sort)"{{{
  if empty(a:complete_result)
    if neocomplcache#get_cur_text() =~ '\s\+$'
      " Caching current cache line.
      call neocomplcache#sources#buffer_complete#caching_current_cache_line()
    endif
    
    return [-1, '', []]
  endif

  let l:cur_keyword_pos = col('.')
  for l:result in values(a:complete_result)
    if l:cur_keyword_pos > l:result.cur_keyword_pos
      let l:cur_keyword_pos = l:result.cur_keyword_pos
    endif
  endfor
  let l:cur_text = neocomplcache#get_cur_text()
  let l:cur_keyword_str = l:cur_text[l:cur_keyword_pos :]

  let l:frequencies = neocomplcache#sources#buffer_complete#get_frequencies()

  " Append prefix.
  let l:complete_words = []
  for [l:complfunc_name, l:result] in items(a:complete_result)
    let l:result.complete_words = deepcopy(l:result.complete_words)
    if l:result.cur_keyword_pos > l:cur_keyword_pos
      let l:prefix = l:cur_keyword_str[: l:result.cur_keyword_pos - l:cur_keyword_pos - 1]

      for keyword in l:result.complete_words
        let keyword.word = l:prefix . keyword.word
      endfor
    endif

    let l:base_rank = neocomplcache#get_plugin_rank(l:complfunc_name)

    for l:keyword in l:result.complete_words
      let l:word = l:keyword.word
      if !has_key(l:keyword, 'rank')
        let l:keyword.rank = l:base_rank
      endif
      if has_key(l:frequencies, l:word)
        let l:keyword.rank = l:keyword.rank * l:frequencies[l:word]
      endif
    endfor

    let l:complete_words += s:remove_next_keyword(l:complfunc_name, l:result.complete_words)
  endfor

  " Sort.
  if !neocomplcache#is_eskk_enabled() && a:is_sort
    call sort(l:complete_words, 'neocomplcache#compare_rank')
  endif
  let l:complete_words = l:complete_words[: g:neocomplcache_max_list]
  
  let l:icase = g:neocomplcache_enable_ignore_case && 
        \!(g:neocomplcache_enable_smart_case && l:cur_keyword_str =~ '\u')
  for l:keyword in l:complete_words
    let l:keyword.icase = l:icase
    if !has_key(l:keyword, 'abbr')
      let l:keyword.abbr = l:keyword.word
    endif
  endfor

  " Delimiter check.
  let l:filetype = neocomplcache#get_context_filetype()
  if has_key(g:neocomplcache_delimiter_patterns, l:filetype)"{{{
    for l:delimiter in g:neocomplcache_delimiter_patterns[l:filetype]
      " Count match.
      let l:delim_cnt = 0
      let l:matchend = matchend(l:cur_keyword_str, l:delimiter)
      while l:matchend >= 0
        let l:matchend = matchend(l:cur_keyword_str, l:delimiter, l:matchend)
        let l:delim_cnt += 1
      endwhile

      for l:keyword in l:complete_words
        let l:split_list = split(l:keyword.word, l:delimiter)
        if len(l:split_list) > 1
          let l:delimiter_sub = substitute(l:delimiter, '\\\([.^$]\)', '\1', 'g')
          let l:keyword.word = join(l:split_list[ : l:delim_cnt], l:delimiter_sub)
          let l:keyword.abbr = join(split(l:keyword.abbr, l:delimiter)[ : l:delim_cnt], l:delimiter_sub)

          if len(l:keyword.abbr) > g:neocomplcache_max_keyword_width
            let l:keyword.abbr = substitute(l:keyword.abbr, '\(\h\)\w*'.l:delimiter, '\1'.l:delimiter_sub, 'g')
          endif
          if l:delim_cnt+1 < len(l:split_list)
            let l:keyword.abbr .= l:delimiter_sub . '~'
            let l:keyword.dup = 0

            if g:neocomplcache_enable_auto_delimiter
              let l:keyword.word .= l:delimiter_sub
            endif
          endif
        endif
      endfor
    endfor
  endif"}}}
  
  " Convert words.
  if neocomplcache#is_text_mode()"{{{
    if l:cur_keyword_str =~ '^\l\+$'
      for l:keyword in l:complete_words
        let l:keyword.word = tolower(l:keyword.word)
        let l:keyword.abbr = tolower(l:keyword.abbr)
      endfor
    elseif l:cur_keyword_str =~ '^\u\+$'
      for l:keyword in l:complete_words
        let l:keyword.word = toupper(l:keyword.word)
        let l:keyword.abbr = toupper(l:keyword.abbr)
      endfor
    elseif l:cur_keyword_str =~ '^\u\l\+$'
      for l:keyword in l:complete_words
        let l:keyword.word = toupper(l:keyword.word[0]).tolower(l:keyword.word[1:])
        let l:keyword.abbr = toupper(l:keyword.abbr[0]).tolower(l:keyword.abbr[1:])
      endfor
    endif
  endif"}}}

  " Abbr check.
  let l:abbr_pattern = printf('%%.%ds..%%s', g:neocomplcache_max_keyword_width-15)
  for l:keyword in l:complete_words
    if len(l:keyword.abbr) > g:neocomplcache_max_keyword_width
      if l:keyword.abbr =~ '[^[:print:]]'
        " Multibyte string.
        let l:len = neocomplcache#util#wcswidth(l:keyword.abbr)

        if l:len > g:neocomplcache_max_keyword_width
          let l:keyword.abbr = neocomplcache#util#truncate(l:keyword.abbr, g:neocomplcache_max_keyword_width - 2) . '..'
        endif
      else
        let l:keyword.abbr = printf(l:abbr_pattern, l:keyword.abbr, l:keyword.abbr[-13:])
      endif
    endif
  endfor

  return [l:cur_keyword_pos, l:cur_keyword_str, l:complete_words]
endfunction"}}}
function! s:on_insert_enter()"{{{
  if &updatetime > g:neocomplcache_cursor_hold_i_time
        \&& g:neocomplcache_enable_cursor_hold_i
    let s:update_time_save = &updatetime
    let &updatetime = g:neocomplcache_cursor_hold_i_time
  endif
endfunction"}}}
function! s:on_insert_leave()"{{{
  let s:cur_keyword_pos = -1
  let s:cur_keyword_str = ''
  let s:complete_words = []
  let s:old_complete_words = []
  let s:prev_numbered_dict = {}
  let s:used_match_filter = 0
  let s:context_filetype = ''
  let s:is_text_mode = 0
  let s:skip_next_complete = 0

  if &updatetime < s:update_time_save
        \&& g:neocomplcache_enable_cursor_hold_i
    let &updatetime = s:update_time_save
  endif
endfunction"}}}
function! s:remove_next_keyword(plugin_name, list)"{{{
  let l:list = a:list
  " Remove next keyword."{{{
  if a:plugin_name  == 'filename_complete'
    let l:pattern = '^\%(' . neocomplcache#get_next_keyword_pattern('filename') . '\m\)'
  else
    let l:pattern = '^\%(' . neocomplcache#get_next_keyword_pattern() . '\m\)'
  endif

  let l:next_keyword_str = matchstr('a'.getline('.')[col('.') - 1 :], l:pattern)[1:]
  if l:next_keyword_str != ''
    let l:next_keyword_str = substitute(escape(l:next_keyword_str, '~" \.^$*[]'), "'", "''", 'g').'$'

    " No ignorecase.
    let l:ignorecase_save = &ignorecase
    let &ignorecase = 0

    for r in l:list
      if r.word =~ l:next_keyword_str
        let r.word = r.word[: match(r.word, l:next_keyword_str)-1]
      endif
    endfor

    let &ignorecase = l:ignorecase_save
  endif"}}}

  return l:list
endfunction"}}}
"}}}

" Internal helper functions."{{{
function! s:make_quick_match_list(list, cur_keyword_str)"{{{
  let l:keys = {}
  for [l:key, l:number] in items(g:neocomplcache_quick_match_table)
    let l:keys[l:number] = l:key
  endfor

  " Save options.
  let l:ignorecase_save = &ignorecase

  if neocomplcache#is_text_mode()
    let &ignorecase = 1
  elseif g:neocomplcache_enable_smart_case && a:cur_keyword_str =~ '\u'
    let &ignorecase = 0
  else
    let &ignorecase = g:neocomplcache_enable_ignore_case
  endif

  " Check dup.
  let l:dup_check = {}
  let l:num = 0
  let l:qlist = {}
  for keyword in neocomplcache#keyword_filter(a:list, a:cur_keyword_str)
    if keyword.word != '' && has_key(l:keys, l:num) 
          \&& (!has_key(l:dup_check, keyword.word) || (has_key(keyword, 'dup') && keyword.dup))
      let l:dup_check[keyword.word] = 1
      let l:keyword = deepcopy(l:keyword)
      let keyword.abbr = printf('%s: %s', l:keys[l:num], keyword.abbr)

      let l:qlist[l:num] = keyword
    endif
    
    let l:num += 1
  endfor
  
  let &ignorecase = l:ignorecase_save
  
  " Save numbered dicts.
  let s:prev_numbered_dict = l:qlist

  return values(l:qlist)
endfunction"}}}
function! s:select_quick_match_list(key)"{{{
  if !has_key(g:neocomplcache_quick_match_table, a:key)
    return []
  endif

  return has_key(s:prev_numbered_dict, g:neocomplcache_quick_match_table[a:key]) ?
        \ [ s:prev_numbered_dict[g:neocomplcache_quick_match_table[a:key]] ] : []
endfunction"}}}
function! s:get_quick_match_pattern()"{{{
  let l:filetype = neocomplcache#get_context_filetype()

  let l:pattern = has_key(g:neocomplcache_quick_match_patterns, l:filetype)?  
        \ g:neocomplcache_quick_match_patterns[l:filetype] : g:neocomplcache_quick_match_patterns['default']

  return l:pattern
endfunction"}}}
function! s:get_cur_text()"{{{
  "let s:cur_text = col('.') < l:pos ? '' : matchstr(getline('.'), '.*')[: col('.') - l:pos]
  let s:cur_text = matchstr(getline('.'), '^.*\%' . col('.') . 'c' . (mode() ==# 'i' ? '' : '.'))

  " Save cur_text.
  return s:cur_text
endfunction"}}}
function! s:set_context_filetype()"{{{
  let l:filetype = &filetype
  if l:filetype == ''
    let l:filetype = 'nothing'
  endif
  
  " Default.
  let s:context_filetype = l:filetype
  if neocomplcache#is_eskk_enabled()
    let s:context_filetype = 'eskk'
    let l:filetype = 'eskk'
  elseif has_key(g:neocomplcache_filetype_include_lists, l:filetype)
        \ && !empty(g:neocomplcache_filetype_include_lists[l:filetype])

    let l:pos = [line('.'), col('.')]
    for l:include in g:neocomplcache_filetype_include_lists[l:filetype]
      let l:start_backward = searchpos(l:include.start, 'bnW')

      " Check start <= line <= end.
      if l:start_backward[0] == 0 || s:compare_pos(l:start_backward, l:pos) > 0
        continue
      endif

      let l:end_pattern = l:include.end
      if l:end_pattern =~ '\\1'
        let l:match_list = matchlist(getline(l:start_backward[0]), l:include.start)
        let l:end_pattern = substitute(l:end_pattern, '\\1', '\=l:match_list[1]', 'g')
      endif
      let l:end_forward = searchpos(l:end_pattern, 'nW')

      if l:end_forward[0] == 0 || s:compare_pos(l:pos, l:end_forward) < 0
        let l:end_backward = searchpos(l:end_pattern, 'bnW')

        if l:end_backward[0] == 0 || s:compare_pos(l:start_backward, l:end_backward) > 0
          let s:context_filetype = l:include.filetype
          let l:filetype = l:include.filetype
          break 
        endif
      endif
    endfor
  endif

  " Set text mode or not.
  let l:syn_name = neocomplcache#get_syn_name(1)
  let s:is_text_mode = (has_key(g:neocomplcache_text_mode_filetypes, s:context_filetype) && g:neocomplcache_text_mode_filetypes[s:context_filetype])
        \ || l:syn_name ==# 'Constant'
  let s:within_comment = (l:syn_name ==# 'Comment')

  " Set filetype plugins.
  let s:loaded_ftplugin_sources = {}
  for [l:source_name, l:source] in items(neocomplcache#available_ftplugins())
    if has_key(l:source.filetypes, l:filetype)
      let s:loaded_ftplugin_sources[l:source_name] = l:source

      if !l:source.loaded
        " Initialize.
        call l:source.initialize()
        
        let l:source.loaded = 1
      endif
    endif
  endfor
endfunction"}}}
function! s:match_wildcard(cur_text, pattern, cur_keyword_pos)"{{{
  let l:cur_keyword_pos = a:cur_keyword_pos
  if neocomplcache#is_eskk_enabled() || !g:neocomplcache_enable_wildcard
    return l:cur_keyword_pos
  endif

  while l:cur_keyword_pos > 1 && a:cur_text[l:cur_keyword_pos - 1] == '*'
    let l:left_text = a:cur_text[: l:cur_keyword_pos - 2]
    if l:left_text == '' || l:left_text !~ a:pattern
      break
    endif

    let l:cur_keyword_pos = match(l:left_text, a:pattern)
  endwhile

  return l:cur_keyword_pos
endfunction"}}}
"}}}

" vim: foldmethod=marker

doc/neocomplcache.jax	[[[1
852
*neocomplcache.txt*	究極の自動補完環境

Version: 5.2
Author : Shougo <Shougo.Matsu@gmail.com>
License: MIT license  {{{
    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:
    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}}}

CONTENTS						*neocomplcache-contents*

Introduction		|neocomplcache-introduction|
Install			|neocomplcache-install|
Interface		|neocomplcache-interface|
  Commands		  |neocomplcache-commands|
  Variables		  |neocomplcache-variables|
  Key mappings		  |neocomplcache-key-mappings|
Examples		|neocomplcache-examples|
Plugins			|neocomplcache-plugins|
  User plugins		  |neocomplcache-user-plugins|
Snippet			|neocomplcache-snippet|
Create plugin		|neocomplcache-create-plugin|
Changelog		|neocomplcache-changelog|

==============================================================================
INTRODUCTION						*neocomplcache-introduction*

*neocomplcache* はバッファ中のキーワードをキャッシュすることで、キーワード補
完を行う。 Vim組み込みのキーワード補完とは違い、自前で実装しているため、柔軟
なカスタマイズが可能である。 ただし他のプラグインよりメモリを大量に消費する。

							*neocomplcache-version5*

neocomplcache Ver.5では、かなりの変数名が変更されているため、後方互換性がなくな
っている。移行の際には、thinca氏の作成した次のスクリプトを利用すると良いだろう。
http://gist.github.com/422503

neocomplcacheの導入については、yuitowest氏の作成したこの記事を参考にすると良い
だろう。
http://d.hatena.ne.jp/yuitowest/20100907/1283865197
この記事はVer.5.1対応だが、Ver.5.2でもインストール方法はそれほど変わらない。

==============================================================================
INSTALL							*neocomplcache-install*

1: 配布ファイルを解凍し、Vimスクリプトのディレクトリへインストールする
   (普通は ~/.vim/ またはWindowsの場合、 $HOME/vimfiles)
2: neocomplcacheはデフォルトで無効化されている。有効にするためには、
|:NeoComplCacheEnable|コマンドを実行するか、
let g:neocomplcache_enable_at_startup = 1 を.vimrc内に記述する。

==============================================================================
INTERFACE						*neocomplcache-interface*

------------------------------------------------------------------------------
COMMANDS 						*neocomplcache-commands*

:NeoComplCacheEnable					*:NeoComplCacheEnable*
		neocomplcacheを有効にし、初期化を行う。 これを実行すると、今
		までのキャッシュが消えてしまうので注意。

:NeoComplCacheDisable					*:NeoComplCacheDisable*
		neocomplcacheを無効にし、後始末を行う。

:NeoComplCacheToggle					*:NeoComplCacheToggle*
		neocomplcacheのロック状態を切り替える。
		ロックしている間は自動補完ができなくなる。

:Neco [{anim-number}] 					*:Neco*
		？？？

:NeoComplCacheLock					*:NeoComplCacheLock*
		自動補完にロックをかけ、自動補完しないようにする。 自動補完
		をロックしていたとしても、手動補完は使用できる。 自動補完を
		一時的に無効にしたい場合に有効。 ロック状態はバッファローカ
		ルである。

:NeoComplCacheUnLock					*:NeoComplCacheUnLock*
		自動補完にかけたロックを解除する。

:NeoComplCacheAutoCompletionLength			*:NeoComplCacheAutoCompletionLength*
		自動補完する文字数を一時的に変更する。
		この状態はバッファローカルであり、他の設定より優先される。

:NeoComplCacheCachingBuffer [bufname]			*:NeoComplCacheCachingBuffer*
		[bufname]で示されるバッファを完全にキャッシュする。 大きなバッ
		ファに対しては、かなり時間がかかるので注意。 [bufname]を省略
		すると、カレントバッファを指定したことになる。 [bufname]のバッ
		ファがまだキャッシュされていない場合、簡易キャッシュのみを行
		う。

:NeoComplCacheCachingSyntax [filetype]			*:NeoComplCacheCachingSyntax*
		[filetype]のシンタックスをもう一度キャッシュする。
		[filetype]を省略すると、カレントバッファのファイルタイプを指
		定したことになる。

:NeoComplCacheCachingTags [bufname]			*:NeoComplCacheCachingTags*
		[bufname]のタグをキャッシュする。 [bufname]を省略すると、カ
		レントバッファのファイルタイプを指定したことになる。 これを
		実行しなければ、tags_completeは動作しない。

:NeoComplCacheCachingInclude [bufname]			*:NeoComplCacheCachingInclude*
		[bufname]のインクルードファイルを再キャッシュする。 [bufname]を
		省略すると、カレントバッファのファイルタイプを指定したことにな
		る。

:NeoComplCacheDisableCaching [bufname]			*:NeoComplCacheDisableCaching*
		[bufname]で示されるバッファをキャッシュしないようにする。 バッ
		ファのキャッシュは削除されるので注意。 [bufname]を省略すると、
		カレントバッファを指定したことになる。

:NeoComplCacheEnableCaching [bufname]			*:NeoComplCacheEnableCaching*
		[bufname]で示されるバッファをキャッシュできるようにする。
		[bufname]を省略すると、カレントバッファを指定したことになる。

:NeoComplCachePrintSource [bufname]			*:NeoComplCachePrintSource*
		[bufname]で示されるバッファのキャッシュ情報をカレントバッファ
		に書き出す。 [bufname]を省略すると、カレントバッファを指定し
		たことになる。 主にデバッグ用の機能のため、ユーザーが使うこ
		とはないだろう。

:NeoComplCacheOutputKeyword [bufname]			*:NeoComplCacheOutputKeyword*
		[bufname]で示されるバッファのキャッシュしたキーワードをカレ
		ントバッファに書き出す。 [bufname]を省略すると、カレントバッ
		ファを指定したことになる。 辞書ファイルを自分で作成するとき
		に便利かもしれない。

:NeoComplCacheCreateTags [bufname]			*:NeoComplCacheCreateTags*
		[bufname]で示されるバッファから、タグ情報を生成する。
		[bufname]を省略すると、カレントバッファを指定したことになる。

:NeoComplCacheEditSnippets [filetype]			*:NeoComplCacheEditSnippets*
		[filetype]のスニペット補完ファイルを編集する。 [filetype]を
		省略すると、カレントバッファのファイルタイプを編集する。
		[filetype]のスニペット補完ファイルが存在しない場合、新しく生
		成される。 このコマンドでは、|g:neocomplcache_snippets_dir|に
		あるスニペット補完ファイルを優先的に編集する。 スニペット補
		完ファイルを保存すると、自動的に再キャッシュされる。

:NeoComplCacheEditRuntimeSnippets [filetype]		*:NeoComplCacheEditRuntimeSnippets*
		[filetype]のスニペット補完ファイルを編集する。 [filetype]を
		省略すると、カレントバッファのファイルタイプを編集する。
		[filetype]のスニペット補完ファイルが存在しない場合、新しく生
		成される。 このコマンドでは、neocomplcacheに付属するスニペッ
		ト補完ファイルを編集する。 スニペット補完ファイルを保存する
		と、自動的に再キャッシュされる。

:NeoComplCachePrintSnippets [filetype]			*:NeoComplCachePrintSnippets*
		[filetype]のスニペットをすべて表示する。 [filetype]を省略す
		ると、カレントバッファのファイルタイプを指定したことになる。
		スニペットの名前を忘れてしまったときに便利であろう。

------------------------------------------------------------------------------
VARIABLES 						*neocomplcache-variables*

g:neocomplcache_enable_at_startup			*g:neocomplcache_enable_at_startup*
		Vim起動時にneocomplcacheを有効にするかどうか制御する。 1なら
		ば自動で有効化する。このオプションは.vimrcで設定するべきであ
		る。neocomplcacheは|AutoComplPop|と競合するので、同時に使用
		するべきではない。
		
		初期値は0なので、手動で有効にしない限りneocomplcacheは使用で
		きない。

g:neocomplcache_max_list				*g:neocomplcache_max_list*
		ポップアップメニューで表示される候補の数を制御する。 候補が
		これを超えた場合は切り詰められる。
		
		初期値は100である。

g:neocomplcache_max_keyword_width			*g:neocomplcache_max_keyword_width*
		ポップアップメニューで表示される候補の表示幅を制御する。 こ
		れを超えた場合は適当に切り詰められる。
		
		初期値は50である。

g:neocomplcache_max_filename_width			*g:neocomplcache_max_filename_width*
		ポップアップメニューで表示されるファイル名の表示幅を制御する。
		これを超えた場合は切り詰められる。
		
		初期値は15である。

g:neocomplcache_auto_completion_start_length		*g:neocomplcache_auto_completion_start_length*
		キー入力時にキーワード補完を行う入力数を制御する。
		
		初期値は2である。

g:neocomplcache_manual_completion_start_length		*g:neocomplcache_manual_completion_start_length*
		手動補完時に補完を行う入力数を制御する。 この値を減らすと便
		利だが、ポップアップ表示時 <C-h> や <BS> などで文字を削除し
		たときに重くなる可能性がある。
		
		初期値は2である。

g:neocomplcache_min_keyword_length			*g:neocomplcache_min_keyword_length*
		バッファや辞書ファイル中で、補完の対象となるキーワードの最小長さを制御する。
		
		初期値は4である。

g:neocomplcache_min_syntax_length			*g:neocomplcache_min_syntax_length*
		シンタックスファイル中で、補完の対象となるキーワードの最小長さを制御する。
		
		初期値は4である。

g:neocomplcache_enable_ignore_case			*g:neocomplcache_enable_ignore_case*
		補完候補を探すときに、大文字・小文字を無視するかを制御する。
		1ならば無視する。
		
		初期値は'ignorecase'である。

g:neocomplcache_enable_smart_case			*g:neocomplcache_enable_smart_case*
		入力に大文字が含まれている場合は、大文字・小文字を無視しない
		ようにする。 1ならば有効。
		
		初期値は0である。

g:neocomplcache_disable_auto_complete			*g:neocomplcache_disable_auto_complete*
		自動補完を無効にするかどうかを制御する。 1ならば自動補完が無
		効になるが、 <C-x><C-u> による手動補完は使用できる。
		
		初期値は0なので、自動補完が有効になっている。

g:neocomplcache_enable_wildcard				*g:neocomplcache_enable_wildcard*
		省入力のために、ワイルドカード文字 '*' を容認するかどうかを
		制御する。 1ならばワイルドカードが使用できる。
		
		初期値は1なので、ワイルドカードが有効になっている。

g:neocomplcache_enable_quick_match			*g:neocomplcache_enable_quick_match*
		省入力のために、-を入力すると候補の横に表示される英数字で候
		補を選択できるようにするかを制御する。 1ならば有効になる。
		
		初期値は0なので、無効になっている。

g:neocomplcache_enable_cursor_hold_i			*g:neocomplcache_enable_cursor_hold_i*
		候補の計算を|CursorHoldI|イベント時に行うかどうかを制御する。
		このオプションが設定されなかった場合、|CursorMovedI|イベン
		トを使用する。このオプションでは無理矢理タイマーイベントを模
		倣するので、不具合が生じるかもしれない。加えて、補完時にもた
		つくことがある。
		
		副作用があるので、初期値は0である。

g:neocomplcache_enable_auto_select			*g:neocomplcache_enable_auto_select*
		補完候補を出すときに、自動的に一番上の候補を選択するかどうか
		を制御する。 このオプションを有効化すると、|AutoComplPop|と
		似た補完動作となる。
		
		初期値は0である。

g:neocomplcache_enable_auto_delimiter			*g:neocomplcache_enable_auto_delimiter*
		neocomplcacheが補完時に自動でデリミタを補完するかどうかを制御す
		る。デリミタとは、ファイル名補完での /やVim scriptでの#である。
		
		初期値は0である。

g:neocomplcache_cursor_hold_i_time			*g:neocomplcache_cursor_hold_i_time*
		|g:neocomplcache_enable_cursor_hold_i|が有効になっている場合、
		自動補完を開始するための計算時間を定義する。このオプションは
		'updatetime'の値を書き換える。
		
		初期値は300である。

g:neocomplcache_enable_camel_case_completion		*g:neocomplcache_enable_camel_case_completion*
		大文字を入力したときに、それを単語の区切りとしてあいまい検索
		を行うかどうか制御する。 例えば AE と入力したとき、
		ArgumentsException とマッチするようになる。 1ならば有効にな
		る。
		
		副作用があるので、初期値は0となっている。

g:neocomplcache_enable_underbar_completion		*g:neocomplcache_enable_underbar_completion*
		_を入力したときに、それを単語の区切りとしてあいまい検索を行
		うかどうか制御する。 例えば p_h と入力したとき、 public_html
		とマッチするようになる。 1ならば有効になる。
		
		副作用があるので、初期値は0となっている。

g:neocomplcache_enable_caching_message			*g:neocomplcache_enable_caching_message*
		キャッシュ中に、メッセージをCommand-lineに表示するかを制御
		する。
		
		初期値は1である。

g:neocomplcache_caching_limit_file_size			*g:neocomplcache_caching_limit_file_size*
		ファイルをキャッシュするファイルサイズを設定する。 開いたファ
		イルがこのサイズより大きいと自動キャッシュしない。
		
		初期値は500000となっている。

g:neocomplcache_disable_caching_buffer_name_pattern	*g:neocomplcache_disable_caching_buffer_name_pattern*
		キャッシュしないバッファ名のパターンを正規表現で設定する。空
		文字列だと無視される。
		
		初期値は空となっている。

g:neocomplcache_lock_buffer_name_pattern		*g:neocomplcache_lock_buffer_name_pattern*
		neocomplcacheの自動補完を無効化するバッファ名のパターンを正規表
		現で設定する。空文字列だと無視される。
		
		初期値は空となっている。

g:neocomplcache_force_caching_buffer_name_pattern	*g:neocomplcache_force_caching_buffer_name_pattern*
		neocomplcacheが'readonly'や'nomodifiable'を無視して強制的にキャ
		ッシュするバッファ名のパターンを正規表現で設定する。空文字列だ
		と無視される。
		
		初期値は空となっている。

g:neocomplcache_disable_auto_select_buffer_name_pattern	*g:neocomplcache_disable_auto_select_buffer_name_pattern*
		|g:neocomplcache_enable_auto_select|による候補の自動選択を無効
		化するバッファ名のパターンを正規表現で設定する。空文字列だと無
		視される。
		
		初期値は空となっている。

g:neocomplcache_snippets_dir				*g:neocomplcache_snippets_dir*
		ユーザが定義したスニペット補完ファイルのパスを指定する。 カ
		ンマ区切りで複数のディレクトリを設定可能。 ここで指定したディ
		レクトリが実際に存在しない場合、無視される。 ユーザ定義のス
		ニペット補完ファイルは標準のスニペット補完ファイルを読み込ん
		だ後に読み込まれる。 重複したスニペットは上書きされる。
		
		この変数はユーザが自分で定義しない限り存在しない。

g:neocomplcache_temporary_dir				*g:neocomplcache_temporary_dir*
		neocomplcacheが一時ファイルを書き出すディレクトリを指定する。
		ここで指定したディレクトリが実際に存在しない場合、作成される。
		例えばkeyword_complete.vimはキーワードのキャッシュをこの下の
		'keyword_cache'ディレクトリに保存する。
		
		初期値は'~/.neocon'である。

g:neocomplcache_keyword_patterns			*g:neocomplcache_keyword_patterns*
		補完するためのキーワードパターンを記録する。 これはファイル
		タイプ毎に正規表現で指定されている。
		
		初期値は複雑なので、autoload/neocomplcache.vimのneocomplcache#enable()を参照せよ。
>
		" Examples:
		if !exists('g:neocomplcache_keyword_patterns')
		  let g:neocomplcache_keyword_patterns = {}
		endif
		let g:neocomplcache_keyword_patterns['default'] = '\h\w*'
<
g:neocomplcache_next_keyword_patterns			*g:neocomplcache_next_keyword_patterns*
		カーソルより後のキーワードパターンを認識するための正規表現を記録する。
		|g:neocomplcache_keyword_patterns|と形式は同じである。
		
		初期値は複雑なので、autoload/neocomplcache.vimのneocomplcache#enable()を参照せよ。

g:neocomplcache_omni_patterns				*g:neocomplcache_omni_patterns*
		オムニ補完するためのキーワードパターンを記録する。これはファ
		イルタイプ毎に正規表現で指定されている。これが定義されていない場合、
		自動補完ではオムニ補完がよばれない。Rubyのオムニ補完等は重い
		ので、ほとんどのオムニ補完の呼び出しは無効化されている。
		
		
		初期値は複雑なので、autoload/neocomplcache/sources/omni_complete.vimの
		s:source.initialize()を参照せよ。
>
		" Examples:
		if !exists('g:neocomplcache_omni_patterns')
		let g:neocomplcache_omni_patterns = {}
		endif
		let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
<
g:neocomplcache_tags_filter_patterns			*g:neocomplcache_tags_filter_patterns*
		タグ補完時の候補をフィルタするパターンを記録する。
		例えば、C/C++のファイルタイプ時に_で始まる候補を除外することができる。
		
		初期値は複雑なので、autoload/neocomplcache.vimのneocomplcache#enable()を参照せよ。

g:neocomplcache_same_filetype_lists			*g:neocomplcache_same_filetype_lists*
		ファイルタイプを相互に関連づけるためのディクショナリ。 cと
		cppを相互参照させるときなどに有効である。
		
		初期値は複雑なので、autoload/neocomplcache.vimのneocomplcache#enable()を参照せよ。

g:neocomplcache_dictionary_filetype_lists		*g:neocomplcache_dictionary_filetype_lists*
		ファイルタイプに辞書ファイルを関連づけるためのディクショナリ。
		キーにファイルタイプ、値に辞書ファイルへのパスを指定する。
		','区切りで複数の辞書を指定できる。もしこの変数が空の場合、
		neocomplcacheは'dictionary'を代わりに使用する。
		キーに"text"を指定すると、text mode時の辞書を指定することとなる。
		
		初期値は空である。

g:neocomplcache_filetype_include_lists			*g:neocomplcache_filetype_include_lists*
		ファイルタイプに内包される別のファイルタイプを定義する。
		中身はディクショナリのリストであり、次の内容を持つ。
		"filetype" : 内包されるファイルタイプ名
		"start" : ファイルタイプが初まるパターン
		"end" : ファイルタイプが終わるパターン。startのマッチパター
			ンを参照するために、\1を使うことができる。
>
		" Examples:
		if !exists('g:neocomplcache_filetype_include_lists')
		let g:neocomplcache_filetype_include_lists= {}
		endif
		let g:neocomplcache_filetype_include_lists.perl6 = [{'filetype' : 'pir', 'start' : 'Q:PIR\s*{', 'end' : '}'}]
		let g:neocomplcache_filetype_include_lists.vim = 
		\[{'filetype' : 'python', 'start' : '^\s*python <<\s*\(\h\w*\)', 'end' : '^\1'}]
<
		初期値は複雑なので、autoload/neocomplcache.vimのneocomplcache#enable()を参照せよ。

g:neocomplcache_text_mode_filetypes			*g:neocomplcache_text_mode_filetypes*
		自動的にテキストモードとなるファイルタイプをキーとした
		ディクショナリである。neocomplcacheがテキストモードのとき、
		英語を書き易くするための支援機能が有効となる。
		
		初期値は複雑なので、autoload/neocomplcache.vimのneocomplcache#enable()を参照せよ。

g:neocomplcache_disable_select_mode_mappings		*g:neocomplcache_disable_select_mode_mappings*
		snippets_completeが行うSelect modeのKey-mappingsを無効にする
		かどうかを制御する。 通常は有効にしておいた方がよい。
		
		初期値は1である。

g:neocomplcache_ctags_program				*g:neocomplcache_ctags_program*
		include_completeなどがタグ生成に使用するctagsコマンドへのパスを指定する。
		
		初期値は"ctags"である。

g:neocomplcache_ctags_arguments_list			*g:neocomplcache_ctags_arguments_list*
		include_completeなどがctagsコマンドを使用する際に、コマンドの
		引数として与える値を設定するための、ファイルタイプをキーと
		した文字列の辞書である。
		
		初期値は複雑なので、autoload/neocomplcache.vimのneocomplcache#enable()を参照せよ。

g:neocomplcache_include_paths				*g:neocomplcache_include_paths*
		インクルードファイルのpathをファイルタイプごとに列挙する変数
		である。存在しない場合、&l:pathが使われる。 記述形式は'path'
		を参照せよ。ファイルタイプをキーとした文字列の辞書である。
		
		初期値は複雑なので、autoload/neocomplcache/sources/include_complete.vimの
		neocomplcache#sources#include_complete#initialize()を参照せよ。

g:neocomplcache_include_exprs				*g:neocomplcache_include_exprs*
		インクルードファイル名を取得するために行う行解析の式である。
		存在しない場合、&l:includeexprが使われる。 記述形式は
		'includeexpr'を参照せよ。ファイルタイプをキーとした文字列の
		辞書である。
		
		初期値は複雑なので、autoload/neocomplcache/sources/include_complete.vimの
		s:source.initialize()を参照せよ。

g:neocomplcache_include_patterns			*g:neocomplcache_include_patterns*
		インクルード命令のパターンを指定する。存在しない場合、
		&l:includeが使われる。 記述形式は'include'を参照せよ。ファイ
		ルタイプをキーとした文字列の辞書である。
		
		初期値は複雑なので、autoload/neocomplcache/sources/include_complete.vimの
		s:source.initialize()を参照せよ。
                
g:neocomplcache_member_prefix_patterns			*g:neocomplcache_member_prefix_patterns*
		include_completeやtags_complete,
		buffer_completeがメンバを認識するための
		パターンを記録する。これはファイルタイプ毎に正規表現で指定
		されている。
		
		初期値は複雑なので、autoload/neocomplcache.vimのneocomplcache#enable()を参照せよ。

g:neocomplcache_delimiter_patterns			*g:neocomplcache_delimiter_patterns*
		関数をスマートに補完するための区切り文字パターンを定義する。
		これはファイルタイプ毎に正規表現のリストで指定されている。
>
		" Examples:
		if !exists('g:neocomplcache_delimiter_patterns')
		let g:neocomplcache_delimiter_patterns= {}
		endif
		let g:neocomplcache_delimiter_patterns.vim = ['#']
		let g:neocomplcache_delimiter_patterns.cpp = ['::']
<
		初期値は複雑なので、autoload/neocomplcache.vimのneocomplcache#enable()を参照せよ。

g:neocomplcache_quick_match_patterns			*g:neocomplcache_quick_match_patterns*
		クイックマッチリストを表示する入力パターンを記録する。 これ
		はファイルタイプ毎に入力文字列の末尾にマッチする正規表現で指
		定されている。 defaultを指定すると、通常時の入力パターンを設
		定できる。
		
		初期値は { 'default' : '-' } である。

g:neocomplcache_quick_match_table			*g:neocomplcache_quick_match_table*
		入力文字と対応する、クイックマッチリストの補完候補のテーブルである。
		
		初期値は複雑なので、plugin/neocomplcache.vimを参照せよ。

g:neocomplcache_omni_functions				*g:neocomplcache_omni_functions*
		|&filetype|をキーとしたディクショナリであり、|omni_complete|
		が呼び出すオムニ補完関数を定義する。 |&filetype|に対応する関
		数が定義されていないとき、|omni_complete|は|omnifunc|を呼び
		出す。
		
		初期値は空である。

g:neocomplcache_vim_completefuncs			*g:neocomplcache_vim_completefuncs*
		コマンド名をキーとして、補完関数名を値としたディクショナリ変
		数である。 |vim_complete|において、
		|command-completion-custom|や|command-completion-customlist|
		のコマンド引数を補完するために使用される。
>
		" Examples:
		if !exists('g:neocomplcache_vim_completefuncs')
		  let g:neocomplcache_vim_completefuncs = {}
		endif
		let g:neocomplcache_vim_completefuncs.Ref = 'ref#complete'
<
		
		初期値は空である。

g:neocomplcache_plugin_disable				*g:neocomplcache_plugin_disable*
		プラグインを無効にするかどうかを指定するディクショナリ。プラ
		グイン名をキーにして、値を1にすることで無効になる。
		
		初期値は空である。

g:neocomplcache_plugin_completion_length		*g:neocomplcache_plugin_completion_length*
		プラグインを呼び出す文字数をプラグインごとに指定するディクショ
		ナリ。 重いプラグインは文字数が多いときにのみ呼び出せるよう
		にするなどが考えられる。
		
		初期値は空である。

g:neocomplcache_plugin_rank				*g:neocomplcache_plugin_rank*
		プラグインの優先度を指定するディクショナリ。
		
		初期値はそれぞれのプラグインによってセットされる。

------------------------------------------------------------------------------
KEY MAPPINGS 						*neocomplcache-key-mappings*

<Plug>(neocomplcache_snippets_expand)			*<Plug>(neocomplcache_snippets_expand)*
		カーソル位置にあるスニペットを展開する。スニペットが存在しな
		いとき、次のプレースホルダにジャンプする。 展開したスニペッ
		トはランクが上昇するため、上位に表示されやすくなる。

<Plug>(neocomplcache_snippets_jump)			*<Plug>(neocomplcache_snippets_jump)*
		次のプレースホルダにジャンプする。スニペットの展開は行わない。
		スニペット名を展開したくないときに使う。
                
neocomplcache#manual_filename_complete()		*neocomplcache#manual_filename_complete()*
		inoremap <expr>上で使用する。neocomplcacheのファイル名補完を
		手動で呼び出す。 Vim標準のファイル名補完を置き換えるときに使
		う。
>
		inoremap <expr><C-x><C-f>  neocomplcache#manual_filename_complete()
<
neocomplcache#manual_omni_complete()			*neocomplcache#manual_omni_complete()*
		inoremap <expr>上で使用する。neocomplcacheのオムニ補完を手動
		で呼び出す。 Vim標準のオムニ補完を置き換えるときに使う。
>
		inoremap <expr><C-j>  neocomplcache#manual_filename_complete()
<
neocomplcache#manual_keyword_complete()			*neocomplcache#manual_keyword_complete()*
		inoremap <expr>上で使用する。neocomplcacheのキーワード補完を
		手動で呼び出す。 Vim標準のキーワード補完を置き換えるときに使
		う。
>
		inoremap <expr><C-n>  pumvisible() ? "\<C-n>" : neocomplcache#manual_keyword_complete()
<
neocomplcache#close_popup()				*neocomplcache#close_popup()*
		neocomplcacheの補完を選択し、ポップアップメニューを閉じる。
		<C-y>の代わりに 使うと良いだろう。
>
		inoremap <expr><C-y>  neocomplcache#close_popup()
<
neocomplcache#cancel_popup()				*neocomplcache#cancel_popup()*
		neocomplcacheの補完をキャンセルし、ポップアップメニューを閉
		じる。<C-e>の代わりに 使うと良いだろう。
>
		inoremap <expr><C-e>  neocomplcache#cancel_popup()
<
neocomplcache#smart_close_popup()			*neocomplcache#smart_close_popup()*
		neocomplcacheの補完を選択し、ポップアップメニューを閉じる。
		|neocomplcache#close_popup()|とは違い、
		|g:neocomplcache_enable_auto_select|によって挙動を賢く変化させる。

neocomplcache#undo_completion				*neocomplcache#undo_completion()*
		inoremap <expr>上で使用する。neocomplcacheによって補完した候
		補を元に戻す。 Vimには確定した補完をキャンセルする機構がない
		ため、活用すると便利であろう。
>
		inoremap <expr><C-g>     neocomplcache#undo_completion()
<
neocomplcache#complete_common_string()			*neocomplcache#complete_common_string()*
		inoremap <expr>上で使用する。補完候補の共通文字列を補完する。
		共通文字列が長い場合に便利である。
>
		inoremap <expr><C-l>     neocomplcache#complete_common_string()
<
neocomplcache#sources#snippets_complete#expandable()	*neocomplcache#sources#snippets_complete#expandable()*
		inoremap <expr>上で使用する。カーソル前の文字列がスニペット
		のトリガーかどうか、もしくはプレースホルダーが存在するかどう
		かを調べる。スニペットの展開にキーマッピングを取られたくない
		場合に便利である。
		戻り値：
		0 : 見つからない
		1 : カーソル位置にスニペットのトリガーがある
		2 : カレントバッファにスニペットのプレースホルダーを発見した
>
		imap <expr><C-l>    neocomplcache#snippets_complete#expandable() ? "\<Plug>(neocomplcache_snippets_expand)" : "\<C-n>"
<
==============================================================================
EXAMPLES						*neocomplcache-examples*

doc/neocomplcache.txt(英語ヘルプ)の|neocomplcache-examples|を参照せよ。
これは作者が普段使っている設定を基にしている。

==============================================================================
PLUGINS							*neocomplcache-plugins*

この項では、neocomplcacheに添付されているプラグインの解説を行う。 自分で作成
したプラグインは、autoload/neocomplcache/sourcesに保存することで、
neocomplcacheにより自動的に読み込まれる。

keyword_complete.vim					*keyword_complete*
		バッファやディクショナリからキーワードを収集し、補完に利用す
		るプラグイン。 neocomplcacheの基本機能も提供しているため、こ
		のプラグインを削除すると neocomplcacheは正常に動作しない。

snippets_complete.vim					*snippets_complete*
		スニペット補完ファイルからスニペットを読み込み、補完に利用す
		るプラグイン。 snipMate.vimやsnippetsEmu.vimと似たような機能
		を提供する。 neocomplcacheの機能を使い、スニペットを検索でき
		るため、 スニペットを覚える手間が省けるだろう。 スニペットの
		定義はsnipMate.vimと似ているため、 自分でスニペットを定義し
		たり改造するのも簡単である。

tags_complete.vim					*tags_complete*
		'tags'で定義されているタグファイルを読み込み、補完候補に加え
		るプラグイン。 大きなタグを読み込ませると重いため、巨大なタ
		グファイルが設定されているとき、 |:NeoComplCacheCachingTags|
		を実行しなければキャッシュしない。 現在は、より便利なインク
		ルード補完を使用するべきである。

syntax_complete.vim					*syntax_complete*
		標準で提供されているautoload/syntaxcomplete.vimのように、シン
		タックスファイルを解析し、補完候補に加えるプラグイン。
		autoload/syntaxcomplete.vimよりもたくさんの候補を認識できる。

include_complete.vim					*include_complete*
		開いているバッファを解析し、参照しているファイルを自動的に候補
		に加えるプラグイン。 いちいちタグファイルや辞書ファイルを用意し
		なくて良いので便利である。 ただし、'path'や'include',
		'includeexpr'が適切に設定されている必要がある。
                
vim_complete.vim					*vim_complete*
		文脈を解析し、VimScriptのオムニ補完を行う。
		VimScriptの編集時以外では動作しない。 neocomplcacheからは
		|i_CTRL-X_CTRL-V|が呼び出せないため作られた。 現在、
		ローカル変数やスクリプト変数、関数やコマンドの解析が実装され
		ている。

dictionary_complete.vim					*dictionary_complete*
		'dictionary'または|g:neocomplcache_dictionary_filetype_lists|
		から候補を収集し、補完候補に加えるプラグインである。

filename_complete.vim					*filename_complete*
		このプラグインはファイル名を補完候補に加える。ヘッダーファイル
		の補完などで便利であろう。

omni_complete.vim					*omni_complete*
		このプラグインはカーソルが|g:neocomplcache_omni_patterns|にマッ
		チする場合、'omnifunc'を自動的に呼び出す。
		|g:neocomplcache_omni_function_list|が定義されている場合、そち
		らが優先される。

completefunc_complete.vim				*completefunc_complete*
		任意の補完関数から補完候補を収集するためのプラグインだが、未完
		成である。 現在、補完関数を手動で呼び出すための
		neocomplcache#sources#completefunc_complete#call_completefunc(funcname)
		のみが使用できる。

abbrev_complete.vim					*abbrev_complete*
		abbrevから補完候補を収集するプラグインである。Vimではabbrevがあ
		まり使われないため、ほとんど使用することはないと思われる。

------------------------------------------------------------------------------
USER PLUGINS 						*neocomplcache-user-plugins*

ここではneocomplcacheに添付されていない、非標準のプラグインを紹介する。

ghc_complete.vim					*neocomplcache-plugins-ghc_complete*
		http://github.com/ujihisa/ghc_complete
		eagletmt氏が作成し、ujihisa氏がメンテナンスをしている。
		Haskellのソースファイルを補完できるが、動作には
		ghc-mod <http://www.mew.org/~kazu/proj/ghc-mod/>が必要である。

==============================================================================
SNIPPET							*neocomplcache-snippet-completion*

neocomplcacheではスニペット機能を内蔵している。 スニペットはsnipMate.vim風
に記述できるので、簡単に移植できるだろう。
>
	snippet     if
	abbr        if endif
	prev_word   '^'
	if ${1:condition}
	    ${2}
	endif
<
例えば上記のようなファイルを
'autoload/neocomplcache/snippet_complete/vim.snip' として保存すると、vimファ
イルタイプを開いたときに自動的に読み込まれる。 #を行頭に書くとコメントで、
空行は無視される。 snippet の後には補完するために入力する文字列、先頭に空
白文字があると 補完されるキーワード、abbrはポップアップメニューに表示される
略語（省略可）、prev_wordは優先して補完する文脈を,で区切っ て''で囲んで指定
する（省略可）。ちなみに'^'は文の先頭とい う意味になる。 スニペットファ
イルのシンタックスファイルを作成したので、それぞれの要素が色分けされる。
詳しくは autoload/neocomplcache/snippet_completeにあるスニペット補完ファイ
ルを参照せよ。 最近のsnipMateではシンタックスファイルが付属しているが、
neocomplcacheが使用しているものの方が高機能なので、そちらを利用したほうがよい。

ちなみに、そのsnippet名がすでに定義されていると警告される。
snippetを明示的に上書きしたい場合は、
>
	delete snippets_name
<
すると良い。

snipMateと違って、外部スニペットのインクルードも使える。
	include c
例えばこのように記述すると、そのスニペットファイルにc用のス ニペットを加えて
補完候補とする。 共通部分を補完するのに便利である。 ただし再帰的処理を行っ
ているので、無限ループに陥らないように注意する必要がある。

snipMateのように、``を用いたevalも動作する。
>
	snippet     hoge
	prev_word   '^'
	    `expand("%")`
<
例えばこのように記述すると、現在開いているバッファ名を補完できる。 ただし
補完候補を展開するときに評価を行うため、副作用には十分注意しなければならない。

簡単にスニペットファイルを編集できるように、 |:NeoComplCacheEditSnippets|と
いうコマンドを用意いる。 このコマンドを用いると、filetypeのスニペット
補完ファイルを簡単に編集することができる。 filetypeを省略すると、
&filetypeとなる。保存すると自動的に再キャッシュされるので、さらに便利である。
>
	imap <C-l>    <Plug>(neocomplcache_snippets_expand)
	smap <C-l>    <Plug>(neocomplcache_snippets_expand)
<
のようにplugin keymappingを定義しておけば、<C-l>でスニペットを展開できる。
展開時にインデントもきちんとなされる。

snipMate風のプレースホルダにも対応している。
>
	snippet     if
	abbr        if endif
	prev_word   '^'
	    if ${1:condition}
	        ${2}
	    endif
<
${1}が最初に入力する単語である。スニペットの展開時に自動的に移動する。 もう
一回|<Plug>(neocomplcache_snippets_expand)|を押すと、${2}, ${3}, ...に移動
する。${1:condition}はデフォルトでconditionという単語が選択された状態になる。
スニペットの中でスニペットを補完したりといった複雑な場合も、ある程度直感的
に動作するようになっている。 プレースホルダはソースコード中でも色分けされる。

vnoremapやvmap, mapはselect modeでも有効になるので、変なマッピングをしてい
ると、デフォルト値の選択時に上手く文字が入力できなくなる。 .vimrcにその
ような記述があれば、xnoremapやxmapに修正するべきである。

ユーザが定義するスニペットの保存場所は自由に指定できる。
指定するときは、
	let g:neocomplcache_snippets_dir = $HOME.'/snippets'
のように.vimrcに記述する。
|:NeoComplCacheEditSnippets|では、|g:neocomplcache_snippets_dir|を優先して読
み込む。

展開可能かどうかを判断する関数として、
|neocomplcache#snippets_complete#expandable()|を追加した。 これを使えば、
	imap <expr><C-l>    neocomplcache#snippets_complete#expandable() ? "\<Plug>(neocomplcache_snippets_expand)" : "\<C-n>"
のように設定でき、展開可能でない場合は他の機能にキーバインドを割り当てること
が出来る。

複数回展開が必要なスニペットは表示が変わり、[Snippet]が<Snippet>に変化する。

スニペット名が同じスニペットを定義した場合、上書きされる。
インクルードしたスニペットや標準のスニペットを書き換えるときに便利である。

どのファイルタイプでも読み込まれる、'_.snip'がある。
さらに、snipMate形式のスニペットファイルもそのまま読み込める。

alias hoge hogera hogehoge
のように空白もしくは, で区切って指定すると、スニペットの別名定義ができる。
スニペット名を直接入力するときに、覚えることが簡単になるので便利である。

プレースホルダの同期も実装されている。 ${1}は$1のプレースホルダに同期さ
れる。 snipMateのスニペットとの互換性も高い。 即座に同期され
るsnipMateと違い、次にジャンプするときに同期されるので注意が必要。 同期させる値に
は改行を含ませることはできないことにも注意。 ${0}は最後に展開さ
れるので、最後に入力する部分に指定すると良い。

スニペットの一覧を表示するには|:NeoComplCachePrintSnippets|コマンドを実行する。
スニペットを忘れたときに便利。
>
	snippet ${1:trigger} ${2:description}
	${3}
<
で表される、snipMateのmulti snippetにも対応。
スニペット補完はSame filetypeにも対応している。
>
	snippet div
	<div ${1:id="${2:someid\}"}>${3}</div>${4}
<
プレースホルダの中にプレースホルダを書くことができる。ただ し、}はエスケー
プしなればならない。 \がエスケープ文字になっているので、\を初期値に入れるとき
は\\とする必要がある。
>
	snippet if
		if (${1:/* condition */}) {
			${2:// code...}
		}
<
このように、ハードタブを使ってインデントすると、 indent pluginの設定を使わず
にインデントを復元する。 phpなど、indent pluginが非力な言語を使うときに便
利である。snipMateはハードタブ固定なので、互換性も上がっている。

==============================================================================
CREATE PLUGIN					*neocomplcache-create-plugin*

この項では、neocomplcacheのプラグインを作成する方法について解説する。 プラグ
インを自作することで、neocomplcacheの能力は無限大に広がるだろう。

==============================================================================
CHANGELOG					*neocomplcache-changelog*

doc/neocomplcache.txtを参照せよ。

==============================================================================
vim:tw=78:ts=8:ft=help:norl:noet:fen:fdl=0:fdm=marker:
doc/neocomplcache.txt	[[[1
2584
*neocomplcache.txt*	Ultimate auto completion system for Vim

Version: 5.2
Author : Shougo <Shougo.Matsu@gmail.com>
License: MIT license  {{{
    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:
    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}}}

CONTENTS						*neocomplcache-contents*

Introduction		|neocomplcache-introduction|
Install			|neocomplcache-install|
Interface		|neocomplcache-interface|
  Commands		  |neocomplcache-commands|
  Variables		  |neocomplcache-variables|
  Key mappings		  |neocomplcache-key-mappings|
Examples		|neocomplcache-examples|
Plugins			|neocomplcache-plugins|
  User plugins		  |neocomplcache-user-plugins|
Create plugin		|neocomplcache-create-plugin|
ToDo			|neocomplcache-todo|
Bugs			|neocomplcache-bugs|
Changelog		|neocomplcache-changelog|

==============================================================================
INTRODUCTION						*neocomplcache-introduction*

*neocomplcache* performs keyword completion by making a cache of keyword in
buffer. Because I implemented it by paying own expenses unlike the keyword
completion including the Vim composing type, neocomplcache can be customized
flexibly. Unfortunately neocomplcache may use more memory than other
plugins.

							*neocomplcache-version5*
Because all variable names are changed in neocomplcache Ver.5, there is not
backward compatibility. In the case of the upgrade, you should use the next
script which Mr.thinca made.
http://gist.github.com/422503

==============================================================================
INSTALL							*neocomplcache-install*

1: Extract the file and Put files in your Vim directory
   (usually ~/.vim/ or Program Files/Vim/vimfiles on Windows). 
2: Execute |:NeoComplCacheEnable| command or 
let g:neocomplcache_enable_at_startup = 1
in your .vimrc. 

==============================================================================
INTERFACE						*neocomplcache-interface*

------------------------------------------------------------------------------
COMMANDS 						*neocomplcache-commands*

:NeoComplCacheEnable					*:NeoComplCacheEnable*
		Validate neocomplcache and initialize it.
		Warning: Conventional cache disappears.

:NeoComplCacheDisable					*:NeoComplCacheDisable*
		Invalidate neocomplcache and clean it up.

:NeoComplCacheToggle					*:NeoComplCacheToggle*
		Change a lock state of neocomplcache.
		While locking neocomplcache, automatic completion is not
		possible.

:Neco [{anim-number}] 					*:Neco*
		Secret.

:NeoComplCacheLock					*:NeoComplCacheLock*
		Lock neocomplcache.
		While locking neocomplcache, manual completion is possible.
		The lock status is buffer local.

:NeoComplCacheUnLock					*:NeoComplCacheUnLock*
		Unlock neocomplcache.

:NeoComplCacheAutoCompletionLength			*:NeoComplCacheAutoCompletionLength*
		Change start length of automatic completion.
		This length is buffer local.

:NeoComplCacheCachingBuffer [bufname]			*:NeoComplCacheCachingBuffer*
		Caching [bufname] buffer.  Warning: considerably take time,
		for the big buffer.  Select current buffer when [bufname]
		omitted.  When [bufname] buffer is not cacheed, perform only
		simple cacheing.

:NeoComplCacheCachingSyntax [filetype]			*:NeoComplCacheCachingSyntax*
		Caching [filetype] syntax file.
		Select current buffer filetype when [filetype] omitted.

:NeoComplCacheCachingDictionary [filetype]		*:NeoComplCacheCachingDictionary*
		Caching [filetype] dictionary file.
		Select current buffer filetype when [filetype] omitted.

:NeoComplCacheCachingTags [filetype]			*:NeoComplCacheCachingTags*
		Caching [filetype] tags file.
		Select current buffer filetype when [filetype] omitted.

:NeoComplCacheCachingInclude [filetype]			*:NeoComplCacheCachingInclude*
		Caching [filetype] include file.
		Select current buffer filetype when [filetype] omitted.

:NeoComplCacheCachingDisable [bufname]			*:NeoComplCacheCachingDisable*
		Disable [bufname] buffer's cache.
		The cache will be deleted.
		Select current buffer when [bufname] omitted.

:NeoComplCacheCachingEnable [bufname]			*:NeoComplCacheCachingEnable*
		Enable [bufname] buffer's cache.
		Select current buffer when [bufname] omitted.

:NeoComplCachePrintSource [bufname]			*:NeoComplCachePrintSource*
		Output [bufname] buffer's cache in current buffer.
		This command is for debug.
		Select current buffer when [bufname] omitted.
		For a command for debugging, a user will not need to use it mainly.

:NeoComplCacheOutputKeyword [bufname]			*:NeoComplCacheOutputKeyword*
		Write the keyword which cacheed [bufname] buffer in current
		buffer.  Select current buffer when [bufname] omitted.  When
		you make a dictionary file by yourself, it may be
		convenient.

:NeoComplCacheCreateTags [bufname]			*:NeoComplCacheCreateTags*
		Create tags from [bufname] buffer.
		Select current buffer when [bufname] omitted.

:NeoComplCacheEditSnippets [filetype]			*:NeoComplCacheEditSnippets*
		Edit [filetype] snippets.  Edit current buffer's filetype
		snippets when [filetype] omitted.  When there is not
		[filetype] snippet file, it is generated newly.  This
		command edits a snippet file in g:neocomplcache_snippets_dir
		with precedence.  It is done re-cache automatically when you
		store a snippet file.

:NeoComplCacheEditRuntimeSnippets [filetype]		*:NeoComplCacheEditRuntimeSnippets*
		Edit [filetype] snippets. Edit current buffer's filetype
		snippets when [filetype] omitted. When there is not
		[filetype] snippet file, it is generated newly. This
		command edits a runtime snippet file with snippets_complete.
		It is done re-cache automatically when you store a snippet
		file.

:NeoComplCachePrintSnippets [filetype]			*:NeoComplCachePrintSnippets*
		Print [filetype] snippets.  Print current buffer's filetype
		snippets when [filetype] omitted.

------------------------------------------------------------------------------
VARIABLES 						*neocomplcache-variables*

g:neocomplcache_enable_at_startup			*g:neocomplcache_enable_at_startup*
		This variable controls whether I validate neocomplcache at
		the time of Vim start.  This option should set it in .vimrc.
		
		Because default value is 0, you cannot use neocomplcache
		unless you validate it by manual operation.

g:neocomplcache_max_list				*g:neocomplcache_max_list*
		This variable controls the number of candidates displayed in
		a pop-up menu.  The case beyond this value is cut down a
		candidate.
		
		Default value is 100.

g:neocomplcache_max_keyword_width			*g:neocomplcache_max_keyword_width*
		This variable controls the indication width of a candidate
		displayed in a pop-up menu.  The case beyond this value is
		cut down properly.
		
		Default value is 50.

g:neocomplcache_max_filename_width			*g:neocomplcache_max_filename_width*
		This variable controls the indication width of a file name
		displayed in a pop-up menu.  The case beyond this value is
		cut down.
		
		Default value is 15.

g:neocomplcache_auto_completion_start_length		*g:neocomplcache_auto_completion_start_length*
		This variable controls the number of the input completion
		at the time of key input automatically.
		
		Default value is 2.

g:neocomplcache_manual_completion_start_length		*g:neocomplcache_manual_completion_start_length*
		This variable controls the number of the input completion
		at the time of manual completion.  It is convenient when you
		reduce this value, but may get heavy when you deleted a
		letter in <C-h> or <BS> at popup indication time.
		
		Default value is 2.

g:neocomplcache_min_keyword_length			*g:neocomplcache_min_keyword_length*
		In a buffer or dictionary files, this variable controls
		length of keyword becoming the object of the completion at
		the minimum.
		
		Default value is 4.

g:neocomplcache_min_syntax_length			*g:neocomplcache_min_syntax_length*
		In syntax files, this variable controls length of keyword
		becoming the object of the completion at the minimum.
		
		Default value is 4.

g:neocomplcache_enable_ignore_case			*g:neocomplcache_enable_ignore_case*
		When neocomplcache looks for candidate completion, this
		variable controls whether neocomplcache ignores the upper-
		and lowercase.  If it is 1, neocomplcache ignores case.
		
		Default value is 'ignorecase'.

g:neocomplcache_enable_smart_case			*g:neocomplcache_enable_smart_case*
		When a capital letter is included in input, neocomplcache do
		not ignore the upper- and lowercase.
		
		Default value is 0.

g:neocomplcache_disable_auto_complete			*g:neocomplcache_disable_auto_complete*
		This variable controls whether you invalidate automatic
		completion.  If it is 1, automatic completion becomes
		invalid, but can use the manual completion by <C-x><C-u>.
		
		Default value is 0.

g:neocomplcache_enable_wildcard				*g:neocomplcache_enable_wildcard*
		This variable controls whether neocomplcache accept wild
		card character '*' for input-saving.
		
		Default value is 1.

g:neocomplcache_enable_quick_match			*g:neocomplcache_enable_quick_match*
		For input-saving, this variable controls whether you can
		choose a candidate with a alphabet or number displayed
		beside a candidate after '-'.  When you input 'ho-a',
		neocomplcache will select candidate 'a'.
		
		Default value is 0.

g:neocomplcache_enable_cursor_hold_i			*g:neocomplcache_enable_cursor_hold_i*
		This variable controls whether neocomplcache use |CursorHoldI| event
		when complete candidates.
		
		Default value is 0.

g:neocomplcache_enable_auto_select			*g:neocomplcache_enable_auto_select*
		When neocomplcache displays candidates, this option controls
		whether neocomplcache selects the first candidate
		automatically.  If you enable this option, neocomplcache's
		completion behavior is like |AutoComplPop|.
		
		Default value is 0.

g:neocomplcache_enable_auto_delimiter			*g:neocomplcache_enable_auto_delimiter*
		This option controls whether neocomplcache insert delimiter
		automatically.  For example, /(filename) or #(Vim script).
		
		Default value is 0.

g:neocomplcache_cursor_hold_i_time			*g:neocomplcache_cursor_hold_i_time*
		This variable defines time of automatic completion by a milli second unit.
		
		Default value is 300.

g:neocomplcache_enable_camel_case_completion		*g:neocomplcache_enable_camel_case_completion*
		When you input a capital letter, this variable controls
		whether neocomplcache takes an ambiguous searching as an end
		of the words in it.  For example, neocomplcache come to
		match it with ArgumentsException when you input it with AE.
		
		Default value is 0.

g:neocomplcache_enable_underbar_completion		*g:neocomplcache_enable_underbar_completion*
		When you input _, this variable controls whether
		neocomplcache takes an ambiguous searching as an end of the
		words in it.  For example, neocomplcache come to match it
		with 'public_html' when you input it with 'p_h'.
		
		Default value is 0.

g:neocomplcache_enable_caching_message			*g:neocomplcache_enable_caching_message*
		When make cache, this variable controls whether neocomplcache
		displays the message in Command-line.
		
		Default value is 1.

g:neocomplcache_caching_limit_file_size			*g:neocomplcache_caching_limit_file_size*
		This variable set file size to make a cache of a file.  If
		open file is bigger than this size, neocomplcache do not
		make a cache.
		
		Default value is 500000.

g:neocomplcache_disable_caching_buffer_name_pattern	*g:neocomplcache_disable_caching_buffer_name_pattern*
		This variable set a pattern of the buffer name. If matched it,
		neocomplcache does not make a cache of the buffer. When it is
		an empty character string, neocomplcache will ignore.
		
		Default value is ''.

g:neocomplcache_lock_buffer_name_pattern		*g:neocomplcache_lock_buffer_name_pattern*
		This variable set a pattern of the buffer name. If matched it,
		neocomplcache does not complete automatically. When it is an
		empty character string, neocomplcache will ignore.
		
		Default value is ''.

g:neocomplcache_force_caching_buffer_name_pattern	*g:neocomplcache_force_caching_buffer_name_pattern*
		This variable set a pattern of the buffer name. If matched it,
		neocomplcache will ignore 'readonly' or 'nomodifiable' options
		and make a cache of the buffer. When it is an empty character
		string, neocomplcache will ignore.
		
		Default value is ''.

g:neocomplcache_disable_auto_select_buffer_name_pattern	*g:neocomplcache_auto_select_buffer_name_pattern*
		This variable set a pattern of the buffer name. If matched it,
		neocomplcache disable |g:neocomplcache_enable_auto_select|.
		When it is an empty character string, neocomplcache will
		ignore.
		
		Default value is ''.

g:neocomplcache_snippets_dir				*g:neocomplcache_snippets_dir*
		This variable appoints the pass of the snippet files which
		user defined.  It cuts the directory by plural appointment
		in comma separated value.  When there is not the directory
		which appointed here, neocomplcache will ignore.  User
		defined snippet files are read after having read a normal
		snippet files.  It is overwritten redundant snippet.
		
		There is not this variable unless a user defines it by oneself.

g:neocomplcache_temporary_dir				*g:neocomplcache_temporary_dir*
		This variable appoints the directory that neocomplcache
		begins to write a file at one time.  When there is not the
		directory which appointed here, it is made.  For example,
		keyword_complete.vim stores cache of the keyword in this
		'keyword_cache' sub directory.
		
		Default value is '~/.neocon'.

g:neocomplcache_keyword_patterns			*g:neocomplcache_keyword_patterns*
		This dictionary records regular expression to recognize a
		keyword pattern of the next than a cursor.  The form is the
		same as|g:neocomplcache_keyword_patterns|.
		
		Because it is complicated, refer to neocomplcache#enable() in
		autoload/neocomplcache.vim for the initial value.
>
		" Examples:
		if !exists('g:neocomplcache_keyword_patterns')
		  let g:neocomplcache_keyword_patterns = {}
		endif
		let g:neocomplcache_keyword_patterns['default'] = '\h\w*'
<
g:neocomplcache_next_keyword_patterns			*g:neocomplcache_next_keyword_patterns*
		This dictionary records keyword patterns to completion.
		This is appointed in regular expression every file type.
		
		Because it is complicated, refer to neocomplcache#enable() in
		autoload/neocomplcache.vim for the initial value.

g:neocomplcache_omni_patterns				*g:neocomplcache_omni_patterns*
		This dictionary records keyword patterns to Omni completion.
		This is appointed in regular expression every file type.
		If this pattern is not defined, neocomplcache don't call
		|omnifunc|. For example, ruby omnifunc is disabled, because
		it's too slow.
		
		Because it is complicated, refer to
		s:source.initialize() autoload/neocomplcache/sources/omni_complete.vim
		for the initial value.
>
		" Examples:
<
g:neocomplcache_tags_filter_patterns			*g:neocomplcache_tags_filter_patterns*
		This dictionary records  a pattern to filter a candidate in
		the tag completion.  For example, it can exclude a candidate
		beginning in _ in file type of C/C++.
		
		Because it is complicated, refer to neocomplcache#enable() in
		autoload/neocomplcache.vim for the initial value.

g:neocomplcache_same_filetype_lists			*g:neocomplcache_same_filetype_lists*
		It is a dictionary to connect file type mutually.  It is
		effective at time to let you refer to c and cpp mutually.
		
		Because it is complicated, refer to neocomplcache#enable() in
		autoload/neocomplcache.vim for the initial value.

g:neocomplcache_dictionary_filetype_lists		*g:neocomplcache_dictionary_filetype_lists*
		It is a dictionary to connect a dictionary file with file
		type.  The dictionary's key is filetype and comma-separated
		multiple value is a path to a dictionary file.  If this
		variable is empty, neocomplcache use 'dictionary' option.
		When you set "text" key, you will appoint dictionary files in
		text mode.
		
		Default value is {}.

g:neocomplcache_filetype_include_lists			*g:neocomplcache_filetype_include_lists*
		It is a dictionary to define a filetype which includes another filetype.
		The item is a list of dictionary. The keys and values are below.
		"filetype" : includes filetype.
		"start" : filetype start pattern.
		"end" : filetype end pattern. You can use \1 to refer start's
			matched pattern.
>
		" Examples:
		if !exists('g:neocomplcache_filetype_include_lists')
		let g:neocomplcache_filetype_include_lists= {}
		endif
		let g:neocomplcache_filetype_include_lists.perl6 = [{'filetype' : 'pir', 'start' : 'Q:PIR\s*{', 'end' : '}'}]
		let g:neocomplcache_filetype_include_lists.vim = 
		\[{'filetype' : 'python', 'start' : '^\s*python <<\s*\(\h\w*\)', 'end' : '^\1'}]
<
		
		Because it is complicated, refer to neocomplcache#enable() in
		autoload/neocomplcache.vim for the initial value.

g:neocomplcache_text_mode_filetypes			*g:neocomplcache_text_mode_filetypes*
		It is a dictionary to define text mode filetypes. The
		dictionary's key is filetype and value is number.  If the value
		is non-zero, this filetype is text mode.  In text mode,
		neocomplcache supports writing English.
		
		Because it is complicated, refer to neocomplcache#enable() in
		autoload/neocomplcache.vim for the initial value.

g:neocomplcache_disable_select_mode_mappings		*g:neocomplcache_disable_select_mode_mappings*
		This variable control whether you invalidate Key-mappings of
		Select-mode which snippets_complete performs.  You had
		better usually validate it.
		
		Default value is 1.

g:neocomplcache_ctags_program				*g:neocomplcache_ctags_program*
		It is the path to the ctags command.
		
		Default value is "ctags".

g:neocomplcache_ctags_arguments_list			*g:neocomplcache_ctags_arguments_list*
		It is the dictionary of the character string to set a value
		to give as an argument of the commands when buffer_complete
		and include_complete use a ctags command.  The dictionary's
		key is filetype.
		
		Because it is complicated, refer to neocomplcache#enable() in
		autoload/neocomplcache.vim for the initial value.

g:neocomplcache_include_paths				*g:neocomplcache_include_paths*
		It is the variable to enumerate path of the include file
		every file type.  When there is not it, 'path' is used.
		Refer to 'path' for the description form. It is the
		dictionary of the character string that assumed file type a
		key.
		
		Because it is complicated, refer to s:source.initialize() in
		autoload/neocomplcache/sources/include_complete.vim for the
		initial value.
                
g:neocomplcache_include_exprs				*g:neocomplcache_include_exprs*
		It is the expression string of the line analysis to perform
		to acquire an include file name.  When there is not it,
		'includeexpr' is used.  Refer to 'includeexpr' for the
		description form. It is the dictionary of the character
		string that assumed file type a key.
		
		Because it is complicated, refer to s:source.initialize() in
		autoload/neocomplcache/sources/include_complete.vim for the
		initial value.
                
g:neocomplcache_include_patterns			*g:neocomplcache_include_patterns*
		This variable appoints the pattern of the include command.
		When there is not it, 'include' is used.  Refer to 'include'
		for the description form. It is the dictionary of the
		character string that assumed file type a key.
		
		Because it is complicated, refer to s:source.initialize() in
		autoload/neocomplcache/sources/include_complete.vim for the
		initial value.

g:neocomplcache_member_prefix_patterns			*g:neocomplcache_member_prefix_patterns*
		This variable appoints a keyword pattern to complete a member
		in include_complete and tags_complete and buffer_complete.
		This is appointed in regular expression every file type.
		
		Because it is complicated, refer to neocomplcache#enable() in
		autoload/neocomplcache.vim for the initial value.

g:neocomplcache_delimiter_patterns			*g:neocomplcache_delimiter_patterns*
		This variable appoints a delimiter pattern to smart complete a
		function.  This is appointed in regular expression's string
		list every file type.
>
		" Examples:
		if !exists('g:neocomplcache_delimiter_patterns')
		let g:neocomplcache_delimiter_patterns= {}
		endif
		let g:neocomplcache_delimiter_patterns.vim = ['#']
		let g:neocomplcache_delimiter_patterns.cpp = ['::']
<
		Because it is complicated, refer to neocomplcache#enable() in
		autoload/neocomplcache.vim for the initial value.

g:neocomplcache_quick_match_patterns			*g:neocomplcache_quick_match_patterns*
		This option records an input pattern to display a quick
		match list.  This is appointed in regular expression to
		match the end of the input character string every file type.
		You can set default input patterns when you appoint
		'default'.
		
		Default value is { 'default' : '-' }.

g:neocomplcache_quick_match_table			*g:neocomplcache_quick_match_table*
		It is the table of the candidates of an input letter and quick
		match list.
		
		Because it is complicated, refer to plugin/neocomplcache.vim.

g:neocomplcache_omni_functions				*g:neocomplcache_omni_functions*
		This dictionary which appoints |omni_complete| call
		function.  The key is |&filetype|. If
		g:neocomplcache_omni_function_list[|&filetype|] is
		undefined, |omni_complete| calls |omnifunc|.
		
		Default value is {}.

g:neocomplcache_vim_completefuncs			*g:neocomplcache_vim_completefuncs*
		This dictionary which appoints |vim_complete| call function
		when completes custom and customlist command.  The key is
		command name. The value is function name.
>
		" Examples:
		if !exists('g:neocomplcache_vim_completefuncs')
		  let g:neocomplcache_vim_completefuncs = {}
		endif
		let g:neocomplcache_vim_completefuncs.Ref = 'ref#complete'
<
		
		Default value is {}.
                
g:neocomplcache_plugin_disable				*g:neocomplcache_plugin_disable*
		The dictionary which appoints whether you invalidate a
		plugin. With a plugin name as a key, it becomes invalid by
		making a value 1.
		
		Default value is {}.

g:neocomplcache_plugin_completion_length		*g:neocomplcache_plugin_completion_length*
		It is a dictionary to control each plugin's completion
		length.  For example, you can prolong heavy plugin's
		completion length.
		
		Default value is {}.

g:neocomplcache_plugin_rank				*g:neocomplcache_plugin_rank*
		It is a dictionary to control each plugin's completion
		priority.
		
		Default value is set by each plugins.

------------------------------------------------------------------------------
KEY MAPPINGS 						*neocomplcache-key-mappings*

<Plug>(neocomplcache_snippets_expand)			*<Plug>(neocomplcache_snippets_expand)*
		Expand a snippet of plural lines. When there is not snippet,
		jump to the next placeholder.  The snippet which unfolded is
		easy to become display by the high rank so that a rank
		rises.

<Plug>(neocomplcache_snippets_jump)			*<Plug>(neocomplcache_snippets_jump)*
		Jump to the next place holder. Do not expand snippet.  When
		you do not want to expand a snippet name, use this
		keymapping.

neocomplcache#manual_filename_complete()		*neocomplcache#manual_filename_complete()*
		Use this function on inoremap <expr>.  The keymapping call
		the file name completion of neocomplcache.  When you
		rearrange the file name completion of the Vim standard, you
		use it.
>
		inoremap <expr><C-x><C-f>  neocomplcache#manual_filename_complete()
<
neocomplcache#manual_omni_complete()			*neocomplcache#manual_omni_complete()*
		Use this function on inoremap <expr>.  The keymapping call
		the omni completion of neocomplcache.  When you rearrange
		the omni completion of the Vim standard, you use it.
>
		inoremap <expr><C-j>  neocomplcache#manual_filename_complete()
<
neocomplcache#manual_keyword_complete()			*neocomplcache#manual_keyword_complete()*
		Use this function on inoremap <expr>.  The keymapping call
		keyword completion of neocomplcache.  When you rearrange the
		keyword completion of the Vim standard, you use it.
>
		inoremap <expr><C-n>  pumvisible() ? "\<C-n>" : neocomplcache#manual_keyword_complete()

neocomplcache#close_popup()				*neocomplcache#close_popup()*
		Inset candidate and close popup menu for neocomplcache.
>
		inoremap <expr><C-y>  neocomplcache#close_popup()
<
neocomplcache#cancel_popup()				*neocomplcache#cancel_popup()*
		cancel completion menu for neocomplcache.
>
		inoremap <expr><C-e>  neocomplcache#cancel_popup()
<
neocomplcache#smart_close_popup()			*neocomplcache#smart_close_popup()*
		Inset candidate and close popup menu for neocomplcache.
		Unlike|neocomplcache#close_popup()|, this function changes
		behavior by|g:neocomplcache_enable_auto_select|smart.

neocomplcache#undo_completion()				*neocomplcache#undo_completion()*
		Use this function on inoremap <expr>. Undo inputed
		candidate.  Because there is not mechanism to cancel
		candidate in Vim, it will be convenient when it inflects.
>
		inoremap <expr><C-g>     neocomplcache#undo_completion()
<
neocomplcache#complete_common_string()			*neocomplcache#complete_common_string()*
		Use this function on inoremap <expr>. Complete common
		string in candidates. It will be convenient when candidates
		have long common string.
>
		inoremap <expr><C-l>     neocomplcache#complete_common_string()
		
<
neocomplcache#sources#snippets_complete#expandable()	*neocomplcache#sources#snippets_complete#expandable()*
		Use this function on inoremap <expr>. It check whether
		cursor text is snippets trigger or exists placeholder in
		current buffer. This function is useful when saving
		keymappings.
		Return value is 
		0 : not found
		1 : cursor text is snippets trigger
		2 : exists placeholder in current buffer
>
		imap <expr><C-l>    neocomplcache#snippets_complete#expandable() ? "\<Plug>(neocomplcache_snippets_expand)" : "\<C-n>"
<
==============================================================================
EXAMPLES						*neocomplcache-examples*
>
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
	    \ 'vimshell' : $HOME.'/.vimshell_hist',
	    \ 'scheme' : $HOME.'/.gosh_completions'
	        \ }
		
	" Define keyword.
	if !exists('g:neocomplcache_keyword_patterns')
	    let g:neocomplcache_keyword_patterns = {}
	endif
	let g:neocomplcache_keyword_patterns['default'] = '\h\w*'
	
	" Plugin key-mappings.
	imap <C-k>     <Plug>(neocomplcache_snippets_expand)
	smap <C-k>     <Plug>(neocomplcache_snippets_expand)
	inoremap <expr><C-g>     neocomplcache#undo_completion()
	inoremap <expr><C-l>     neocomplcache#complete_common_string()
	
	" SuperTab like snippets behavior.
	"imap <expr><TAB> neocomplcache#sources#snippets_complete#expandable() ? "\<Plug>(neocomplcache_snippets_expand)" : pumvisible() ? "\<C-n>" : "\<TAB>"
	
	" Recommended key-mappings.
	" <CR>: close popup and save indent.
	inoremap <expr><CR>  neocomplcache#smart_close_popup() . "\<CR>"
	" <TAB>: completion.
	inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
	" <C-h>, <BS>: close popup and delete backword char.
	inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
	inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
	inoremap <expr><C-y>  neocomplcache#close_popup()
	inoremap <expr><C-e>  neocomplcache#cancel_popup()
	
	" AutoComplPop like behavior.
	"let g:neocomplcache_enable_auto_select = 1
	
	" Shell like behavior(not recommended).
	"setlocal completeopt+=longest
	"let g:neocomplcache_enable_auto_select = 1
	"let g:neocomplcache_disable_auto_complete = 1
	"inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<TAB>"
	"inoremap <expr><CR>  neocomplcache#smart_close_popup() . "\<CR>"
	
	" Enable omni completion.
	autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
	autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
	autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
	autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
	autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
	
	" Enable heavy omni completion.
	if !exists('g:neocomplcache_omni_patterns')
		let g:neocomplcache_omni_patterns = {}
	endif
	let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
	"autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
<
==============================================================================
PLUGINS							*neocomplcache-plugins*

Neocomplcache reads automatically the plugin saved in an
autoload/neocomplcache/sources directory.

buffer_complete.vim					*buffer_complete*
		This plugin collects keywords from buffers and
		dictionaries, and to use for completion.  Because the
		plugin offer the basic function of neocomplcache,
		neocomplcache does not work normally when you delete this
		plugin.

snippets_complete.vim					*snippets_complete*
		This plugin analyzes snippet files for completion.  The
		plugin offer a function similar with snipMate.vim and
		snippetsEmu.vim.  Because you can search a snippet with a
		function of neocomplcache, you may omit trouble to learn.

tags_complete.vim					*tags_complete*
		This plugin analyzes a tag file defined in 'tags' for
		completion.  When a huge tag file is set, neocomplcache
		don't make cache if you don't execute
		|:NeoComplCacheCachingTags|command.  Because
		tags_complete is too slow if tags_complete read a big
		tags file.  You should use more convenient include
		completion now.

syntax_complete.vim					*syntax_complete*
		This plugin analyzes a syntax file like
		autoload/syntaxcomplete.vim offered by default, and to
		add to candidate completion.  The plugin can recognize
		candidates a lot more than autoload/syntaxcomplete.vim.

include_complete.vim					*include_complete*
		This plugin will add the file which an opening buffer
		refers to to candidate.  It is convenient, because you do
		not need to prepare a tags file and a dictionary file.
		But it is necessary for 'path' and 'include',
		'includeexpr' to be set adequately.
 
vim_complete.vim					*vim_complete*
		This plugin analyzes context and start Omni completion of
		VimScript.  This plugin does not work other than editing
		time of VimScript.  I created it because neocomplcache
		cannot call |i_CTRL-X_CTRL-V|.  Local variable and a
		script variable, a function and the analysis of the
		command are implemented now.

dictionary_complete.vim					*dictionary_complete*
		This plugin adds candidates from 'dictionary' or
		|g:neocomplcache_dictionary_filetype_lists|.

filename_complete.vim					*filename_complete*
		This plugin collects filename candidates. It is useful
		when you input header file name.

omni_complete.vim					*omni_complete*
		This plugin calls 'omnifunc' automatically when cursor
		text is matched with |g:neocomplcache_omni_patterns|. If
		|g:neocomplcache_omni_function_list|is defined,
		neocomplcache will give priority it.

completefunc_complete.vim				*completefunc_complete*
		This plugin collects candidates from any 'completefunc'.
		But it is incomplete.
		neocomplcache#sources#completefunc_complete#call_completefunc(funcname)
		is only available. This function calls any 'completefunc'
		manually.

abbrev_complete.vim					*abbrev_complete*
		This plugin collects candidates from abbrev.

------------------------------------------------------------------------------
USER PLUGINS 						*neocomplcache-user-plugins*

This section, introduce non default neocomplcache plugin.

ghc_complete.vim					*neocomplcache-plugins-ghc_complete*
		http://github.com/ujihisa/ghc_complete
		This plugin's author is eagletmt, and maintainer is ujihisa.
		It completes source file written Haskell.
		It needs ghc-mod <http://www.mew.org/~kazu/proj/ghc-mod/>.

==============================================================================
TODO							*neocomplcache-todo*

==============================================================================
BUGS							*neocomplcache-bugs*

==============================================================================
CREATE PLUGIN						*neocomplcache-create-plugin*

In this clause, I comment on a method to make plugin of neocomplcache.  The
ability of neocomplcache will spread by creating plugin by yourself.

==============================================================================
CHANGELOG						*neocomplcache-changelog*

2010-09-30
- Deleted member filter.
- Fixed delimiter.
- Supported php namespace.
- Improved c++ completion.
- Improved php delimiter.
- Added :Neco animation.

2010-09-29
- Improved filename_complete.
- Added g:neocomplcache_enable_auto_delimiter option.

2010-09-28
- Fixed filename_complete.

2010-09-27
- Improved filename complete.
- Fixed java snippet warning.

2010-09-26
- Fixed xhtml snippet error.
- Improved delimiter.

2010-09-24
- Added ghc_complete description.

2010-09-23
- Fixed vim_complete kind bug.
- Improved d snippet.
- Detect duplicated snippet name.

2010-09-21
- Added NeoComplCacheCachingInclude description.
- Improved include cache.

2010-09-18
- Fixed filename completion error.

2010-09-16
- Fixed caching bug.
- Added g:neocomplcache_force_caching_buffer_name_pattern option.

2010-09-15
- Implemented escaped ` in snippets_complete.
- Improved snippet syntax.

2010-09-10
- Improved caching algorithm.
- Added g:neocomplcache_disable_auto_select_buffer_name_pattern option.

2010-09-08
- Improved cache timing.
- Revised documentation.
- Fixed for Vim 7.0.
- Added install description.

2010-09-06
- Improved for echodoc.

2010-09-04
- Improved omni_complete default pattern.

2010-09-03
- Fixed snippets analyze.
- Fixed plugin manual.

2010-09-02
- Deleted g:neocomplcache_enable_display_parameter option.
- Added g:neocomplcache_enable_caching_message option.
- Supported Vim7.3 in vim_complete.

2010-09-01
- Fixed :Neco.
- Improved caching message.
- Fixed filtering.

2010-08-31
- Improved :Neco.
- Improved echo.

2010-08-30
- Improved ctags arguments for mac.
- Fixed mac check.

2010-08-29
- Fixed caching timing.
- Added objj support.

2010-08-25
- Improved keyword patterns.
- Improved filename pattern.
- Fixed multibyte check.

2010-08-24
- Improved g:neocomplcache_ctags_arguments_list.
- Fixed include_complete bugs.

2010-08-23
- Improved print caching.

2010-08-22
- Improved get_cur_text().
- Implemented neocomplcache#do_auto_complete().
- Improved print caching.

2010-08-20
- Fixed is_enabled error.
- Implemented member completion in buffer_complete.
- Added shell like behavior settings.

2010-08-19
- Fixed get_cur_text() bug.
- Fixed examples.
- Improved for echodoc.
- Fixed get_cur_text() in snippets_complete.

2010-08-17
- Fixed abbrev_complete redir bug.
- Fixed var_dictionary complete in vim_complete.
- Improved get_cur_text().
- Fixed keyword pattern.
- Fixed echodoc in include_complete.

2010-08-16
- Fixed abbrev_complete.
- Supported lua.

2010-08-15
- Improved plugin error catch.

2010-08-14
- Improved error catch.

2010-08-13
- Improved caching.
- Fixed nasm error.

2010-08-12
- Fixed filter bug.

2010-08-11
- Refactoringed :Neco command.

2010-08-09
- Fixed include_complete error in echodoc.
- Fixed context filetype bug in filetype plugin.

2010-08-08
- Improved lock.
- Supported echodoc in vim_complete.

2010-08-07
- Implemented neocomplcache enabled check.
- Supported echodoc in vim_complete.
- Supported echodoc in snippets_complete.

2010-08-05
- Improved ctags arguments.
- Improved gas syntax.

2010-08-04
- Improved eskk support.
- Improved vim_complete check.
- Fixed vim_complete cur_keyword_str bug.

2010-08-03
- Fixed filename_complete error.

2010-08-02
- Ver.5.2 development started.
- Fixed filename_complete.

ChangeLog NeoComplCache 5.1: {{{
2010-08-02
- Released neocomplcache Ver.5.1
- Fixed css snippet.

2010-07-31
- Supported coffee script.
- Improved neocomplcache#filetype_complete().
- Skip filename completion when too many candidates.
- Added :NeoComplCacheCachingDictionary discription.

2010-07-30
- Fixed documentation.

2010-07-29
- Added omni completion examples.
- Supported inline assembly language.
- Fixed vim_complete commands.dict.
- Added neocomplcache#set_completion_length().

2010-07-28
- Fixed eskk check.
- Improved vim keyword pattern.
- Improved examples.
- Fixed vim_complete error.

2010-07-27
- Fixed autocompletion freeze.
- Fixed omni completion bug.
- Fixed :NeoComplCacheToggle.
- Improved g:neocomplcache_plugin_disable behavior.
- Improved eskk check.

2010-07-26
- Fixed snippets expand error.
- Fixed error when local variable completion.
- Improved haskell keyword pattern.

2010-07-25
- Improved termtter keywords.
- Improved filetype completion.
- Implemented set rank helper.
- Changed vim_complete marker.
- Implemented syntax attr helper.
- Improved startup.
- Improved member filter.
- Implemented filetype plugin.
- Fixed neocomplcache#system().
- Improved local variable analysis.
- Implemented expand completion.
- Refactoringed vim_complete.
- Improved vim_complete.
- Changed neocomplcache#set_dictionary_helper().
- Fixed example.
- Allow blank line in snippet.
- Fixed snippet parse.
- Fixed ftplugin bug.
- Improved context filetype.

2010-07-23
- Fixed environments parse bug.
- Improved include check.

2010-07-22
- Improved detect completefunc.
- Improved interactive termtter pattern.
- Improved caching.
- Fixed analyzing function.

2010-07-21
- Improved autoload plugins.
- Improved g:neocomplcache_omni_patterns description.

2010-07-19
- Improved truncate filename.
- Fixed quick match bug.
- Improved include_complete.
- Supported union.

2010-07-18
- Improved multibyte trunk.
- Improved neocomplcache#snippets_complete#expandable().
- Disabled Ruby omni completion.

2010-07-17
- Fixed neocomplcache#match_word() bug.
- Optimized match.
- Improved print error.

2010-07-16
- Improved neocomplcache#get_auto_completion_length().
- Fixed documentation.
- Improved quickmatch selection.
- Improved check wildcard.
- Fixed quickmatch selection.
- Improved vimshell pattern.
- Improved :NeoComplCacheAutoCompletionLength behavior.
- Improved buffer caching.

2010-07-15
- Fixed error when complete directory.
- Added g:neocomplcache_quick_match_table.
- Added neocomplcache#smart_close_popup().
- Improved tilde substitution.
- Improved neocomplcache#close_popup().

2010-07-13
- Supported gdb keyword.

2010-07-12
- Improved eskk and vimproc check.

2010-07-11
- Supported GetLatestVimScripts.

2010-07-10
- Deleted spell_complete.
- Implemented dictionary plugins.
- Deleted obsolute functions.

2010-07-09
- Improved eskk check.
- Improved javascript support.
- Improved css keyword pattern.
- Fixed quickmatch error.
- Fixed neocomplcache#complete_common_string() bug.

2010-07-08
- Fixed get filetype timing in snippets_complete.

2010-07-07
- Fixed eskk omni completion bug.

2010-07-06
- Fixed for eskk.

2010-07-04
- Disabled keyword_complete when eskk is enabled.

2010-07-01
- Fixed context filetype bug.
- Added tex in text mode filetypes.
- Improved text mode.

2010-06-28
- Ver.5.1 development started.
- Improved integrated completion.
- Improved snippet alias pattern.
- Implemented text mode.
- Added g:neocomplcache_text_mode_filetypes option.
- Added "nothing" in text mode filetype.
}}}
ChangeLog NeoComplCache 5.0: {{{
2010-06-24
- Improved eruby support.
- Improved ruby keyword.

2010-06-23
- Improved keyword pattern.
- Renamed g:neocomplcache_disable_plugin_list as g:neocomplcache_plugin_disable.
- Renamed g:neocomplcache_plugin_completion_length_list as g:neocomplcache_plugin_completion_length.
- Refactoringed keyword_complete.
- Added g:neocomplcache_plugin_rank option.
- Introduced thinca's script.
- Fixed context filetype.
- Fixed rank bug.
- Fixed command line window error.

2010-06-22
- Added eskk omni completion support.
- Improved filter.
- Improved eskk support.
- Fixed presentation file.

2010-06-20
- Improved keyword patterns.

2010-06-19
- Optimized frequencies.
- Improved keyword pattern.
- Improved cur_text.
- Changed g:neocomplcache_omni_function_list as g:neocomplcache_omni_functions.
- Added g:neocomplcache_vim_completefuncs option.
- Implemented customlist completion in vim_complete.

2010-06-18
- Improved clojure support.
- Fixed dup problem in snippets_complete.
- Improved abbr.
- Improved filename_complete.

2010-06-17
- Fixed manual completion freeze bug.
- Refactoringed neocomplcache#start_manual_complete().
- Improved erlang keyword pattern.
- Improved d and java keyword patterns.
- Added g:neocomplcache_delimiter_patterns option.
- Implemented delimiter completion.
- Improved abbr.

2010-06-15
- Fixed examples.
- Optimized memory when loaded cache.
- Fixed g:neocomplcache_enable_cursor_hold_i bug.
- Improved garbage collect and calc rank.
- Improved caching timing.
- Deleted neocomplcache#caching_percent().
- Optimized caching.

2010-06-12
- Improved context filetype.
- Improved syntax_complete.
- Fixed eruby and ruby pattern.
- Added neocomplcache#cancel_popup().

2010-06-11
- Improved caching message.
- Improved expand snippet.

2010-06-10
- Optimized sort.
- Deleted neocomplcache#cancel_popup().
- Reimplemented neocomplcache#close_popup().
- Improved snippets expand.
- Fixed sort bug.
- Fixed context filetype bug.

2010-06-08
- Added objc omni completion support.
- Improved context filetype.
- Improved caching message.
- Improved keyword patterns.
- Improved vim_complete.
- Added pasm and pir support.
- Fixed nested snippet bug.
- Fixed expand a snippet contained blank line bug.
- Improved help.

2010-06-07
- Fixed delete cache bug.
- Refixed help caching bug.
- dictionary_complete use dictionary option.
- Improved masm and nasm keyword pattern.
- Supported H8-300 keyword pattern.
- Added g:neocomplcache_filetype_include_lists option.
- Added g:neocomplcache_omni_function_list option.

2010-06-06
- Optimized cache.
- Fixed vim_complete freeze.

2010-06-05
- Improved cache timing.

2010-06-04
- Fixed abbrev_complete check.
- Fixed icase bug.
- Improved icase.
- Fixed obsolute settings.
- Changed g:neocomplcache_caching_limit_file_size default value.
- Optimized completion.
- Refixed help file caching bug.
- Allow snipMate like snippet.

2010-06-03
- Changed g:neocomplcache_enable_cursor_hold_i_time into g:neocomplcache_cursor_hold_i_time.
- Improved dummy move.
- Improved help.
- Fixed help file caching bug.
- Fixed filename_complete rank.

2010-06-02
- Fixed save cache error.
- Deleted g:neocomplcache_enable_randomize option.
- Deleted g:neocomplcache_enable_alphabetical_order option.
- Deleted g:neocomplcache_caching_percent_in_statusline option.
- Changed g:neocomplcache_enable_quick_match default value.
- Fixed abbrev_complete bug.

2010-06-01
- Improved abbr check.
- Added abbrev_complete plugin.
- Fixed disable AutoComplPop.

2010-05-31
- Ver.5 development started.
- Fixed include_complete error.
- Changed variables name dramatically.
- Fixed multibyte problems.
- Deleted g:neocomplcache_cache_line_count variable.
- Changed g:neocomplcache_alphabetical_order into g:neocomplcache_enable_alphabetical_order.
- Changed g:neocomplcache_plugin_completion_length into g:neocomplcache_plugin_completion_length.
- Changed g:neocomplcache_caching_disable_pattern into g:neocomplcache_disable_caching_buffer_name_pattern.
- Changed g:neocomplcache_lock_buffer_name_pattern into g:neocomplcache_lock_buffer_name_pattern.
- Changed NeoComplCacheCachingDisable into NeoComplCacheDisableCaching.
- Changed NeoComplCacheCachingEnable into NeoComplCacheEnableCaching.
- Check obsolute options.
}}}
ChangeLog NeoComplCache 4.30: {{{
2010-05-31
- Marked as ver.4.30.

2010-05-30
- Improved help file.
- Improved dummy move.

2010-05-29
* Detect text was changed.
- Fixed error when NeoComplCacheDisable.
- Fixed completion length bugs.
- Refactoringed.
- Added AutoComplPop like behavior settings.
- Improved vim_complete.
- Implemented ambiguous command completion.
- Improved dummy move.

2010-05-27
- Caching readonly buffer.
- Fixed menu bug in buffer_complete.
- Improved recaching behavior.
- Improved caching.

2010-05-26
- Improved buffer cache timing.
- Detect AutoComplPop.
- Changed check buflisted() into bufloaded().

2010-05-25
- Revised example settings.

2010-05-23
* Improved filename_complete.
- Implemented ~Username/ completion in filename_complete.
- Use 'path' in filename_complete.
- cd source path when searching include files.
- Improved directory completion in vim_complete.

2010-05-20
- Disabled php omni completion.
- Deleted keyword cache in omni_complete.
- Improved caching timing in buffer_complete.

2010-05-18
- Fixed prototype in vim_complete.
- Fixed custom and customlist error in vim_complete.

2010-05-16
- Improved ocaml keyword pattern.
- Improved wildcard check.
- '#' as wildcard in vim_complete.
- Improved function display in vim_complete.
- Added ml keyword pattern.
- Fixed quickmatch bugs.
- Deleted obsolute functions.
- Deleted obsolute internal variable.

2010-05-15
* Improved vim_complete.

2010-05-14
* Improved disable bell.

2010-05-13
* Fixed quickmatch keyword position bug.
* Fixed html next keyword pattern.
* Revised completion.
* Improved quickmatch.

2010-05-11
* Fixed vim_complete bugs.
* Improved vim_complete analyse.

2010-05-09
* neocomplcache disables bell.
* Improved filename pattern.

2010-05-05
* Disabled C/C++ Omni patterns.
* Improved vimproc#system().
* Improved g:neocomplcache_max_keyword_width.
* Detect conflicted plugin.

2010-05-02
* Implemented dictionary completion in vim_complete.

2010-05-01
* Deleted mapping check.
* Improved vim_complete analyse.

2010-04-30
* If <CR> is mapped, g:neocomplcache_enable_auto_select option does not work to avoid a side effect.
* Improved neocomplcache#close_popup().

2010-04-29
* Use b:changedtick.
* Ignore command line window caching.
* Added g:neocomplcache_enable_auto_select option.

2010-04-26
* Improved vim_complete. Recognize context.

2010-04-25
* Enable spell_complete in manual_complete.
* Fixed quickmatch behavior.
* Improved user commands analsze in vim_complete.

2010-04-20
* Fixed vim completion bug.
* Implemented lazy caching in vim_complete.
* Enable cache in "[Command line]" buffer.

2010-04-17
* Improved print prototype behavior when g:neocomplcache_cursor_hold_i_time.
* Improved redraw.
* Improved for skk.vim.

2010-04-16
* Improved print prototype in vim_complete.

2010-04-15
* Improved vim_complete.
- Supported '<,'>command...
* Fixed g:neocomplcache_enable_ignore_case bug.
- Improved filtering.
* Fixed neocomplcache#complete_common_string() bug.
* Implemented CursorHoldI completion.
* Added g:neocomplcache_enable_cursor_hold_i and g:neocomplcache_cursor_hold_i_time options.
* Deleted g:NeoComplCache_EnableSkipCompletion and g:NeoComplCache_SkipCompletionTime options.
}}}
ChangeLog NeoComplCache 4.20: {{{
2010-04-15
    * Changed default value of g:neocomplcache_enable_ignore_case.

2010-04-13
    * Improved for skk.vim.
    * Use neocomplcache#escape_match().

2010-04-11
    * Improved command completion text.
    * Improved command prototype dictionary in vim_complete.
    * Completed prototype dictionary.
    * Improved command name search.

2010-04-10
    * Improved command completion in vim_complete.
    * Skip head digits in vim_complete.
    * Highlight color when print prototype.

2010-04-09
    * Improved _ snippets.

2010-04-06
    * Improved mappings dictionary.
    * Lazy caching environment variables.
    * Added variables dictionary.

2010-04-01
    * Fixed quickmatch bug.

2010-03-17
    * Fixed quickmatch bug.
    * Improved vim_complete performance.

2010-03-16
    * Deleted obsolute variables.
    * Improved manual complete.
    * Improved keyword_filter.
    * Improved vim_complete.

2010-03-11
    * Fixed quickmatch bug.

2010-03-06
    * Improved frequency garbage collect.
    * Improved buffer caching.

2010-03-05
    * Improved caching print.
    * Incleased omni completion rank.
    * Added snippets_complete help in Japanese.

2010-03-02
    * Caching disable when bufname is '[Command line]'

2010-02-19
    * Fixed snippets expand bug.
    * Fixed interactive filetype.
    * Fixed manual completion bug.

2010-02-18
    * Fixed filename pattern.
}}}
ChangeLog NeoComplCache 4.00-: {{{
   4.10:
    - Fixed interactive Gauche support.
    - Added omni_complete and vim_complete rank.
    - Implemented fuzzy filter(experimental).
    - Improved lingr-vim support.
    - Implemented spell_complete.vim(experimental)
    - Improved skk.vim support.
    - Improved lisp keyword pattern.
    - Added clojure support.
    
   4.09:
    - Improved syntax detect in snippets_complete.
    - Improved NeoComplCachePrintSnippets command.
    - Fixed snippet newline expand in snippets_complete.
    - Improved syntax highlight in snippets_complete.
    - Optimized filename_complete.
    - Added snippet files(Thanks mfumi!).
    - Fixed multibyte input bug.
    - Added interactive termtter keyword.
    - Added keyword pattern of batch file.
    - Improved filtering word.
    - Supported Visual Basic.
    - Supported lingr-vim.
    - Update lines number in buffer_complete.
    - Supported omnifunc name pattern in omni_complete.
    - Fixed complete length bug in omni_complete.
    - Fixed wildcard bug.
    - Fixed indent.
    - Supported interactive ocaml.
    
   4.08:
    - Improved keywords in vim_complete.
    - Deleted g:NeoComplCache_NonBufferFileTypeDetect option.
    - Improved composition filetype keyword support.
    - Fixed neocomplcache#system.
    - Added g:neocomplcache_ctags_program option.
    - Fixed ctags execution bug.
    - Improved quickmatch behavior.
    - Fixed complete length bug in omni_complete.
    - Fixed wildcard freeze in filename_complete.
    
   4.07:
    - Improved filaname pattern.
    - Deleted '...' pattern.
    - Fixed functions_prototype bug in vim_complete.
    - Added same filetype lists for vimshell iexe.
    - Added syntax pattern for vimshell iexe.
    - Fixed filename completion bug.
    - Added vimshell omni completion support.
    - Disabled filename_complete in vimshell.
    - Implemented dictionary_complete.vim.
    - Optimized buffer_complete.
    - Improved tex pattern.
    - Improved same filetype.
    - Improved filetype completion.

   4.06:
    - Improved command completion in snippets_complete.
    - Improved skip directory in filename_complete.
    - Improved head match.
    - Added completefunc_complete.
    - Fixed neocomplcache#get_cur_text() bug.
    - Fixed unpack dictionary bug in tags_complete.
    
   4.05:
    - Improved snippet alias.
    - Improved analyzing extra args in vim_complete.
    - Fixed pattern match error.
    - Fixed analyzing bug in vim_complete.
    - Improved check match filter.
    - Don't fnamemodify in omni_complete.
    - Improved trunk filename in filename_complete.
    - Fixed complete common string bug.
    
   4.04:
    - Implemented common string completion.
    - Added css snippet file.
    - Added quickmatch key.
    - Implemented hash.
    - Use vimproc#system() if available.
    - Supported vimshell interpreters.
    - Fixed manual filename completion bug.
    - Use md5.vim if available.
    - Cache previous results.
    - Skip listed files in include_complete.
    - Implemented fast mode when last completion was skipped.
    - Deleted C/C++ omni completion support.
    - Improved caching tag.
    
   4.03:
    - Don't use abs() for Vim7.
    - Changed display interface in snippets_complete.
    - Implemented no options in vim_complete.
    - Improved compatiblity with snipMate.
    - Fixed typo in neocomplcache.jax.
    
   4.02:
    - Added Python snippet.
    - Added g:neocomplcache_tags_filter_patterns option.
    - Use g:neocomplcache_tags_filter_patterns in omni_complete.
    - Supported nested include file in C/C++ filetype in include_complete.
    - Improved print prototype in vim_complete.
    - Fixed member fileter error.
    - Fixed fatal include_complete error.
    - Fixed haskell and ocaml patterns.
    
   4.01:
    - Added filename pattern.
    - Fixed in TeX behavior in filename_complete.
    - Improved garbage collect.
    - Improved next keyword completion.
    - Supported next keyword completion in filename_complete.
    - Supported mark down filetype.
    - Fixed error when load file in include_complete.
    - Deleted regacy option.
    - Improved complete option in vim_complete.
    - Ignore space in snippets_complete.
    - Added markdown snippet.
    - Improved randomize.
    - Changed g:neocomplcache_CalcRankRandomize option as g:neocomplcache_enable_randomize.
    - Fixed save cache error.
    
   4.00:
    - Fixed manual completion error.
    - Deleted g:NeoComplCache_PreviousKeywordCompletion. It's default.
    - Deleted calc_rank().
    - Improved caching print.
    - Improved calc frequency.
    - Optimized speed.
    - Deleted dup in include_complete.
    - Use caching helper in plugins.
    - Improved option in vim_complete.
    - Delete dup check in buffer_complete.
    - Improved garbage collect in buffer_complete.
    - Deleted prev_rank.
    - Deleted g:NeoComplCache_EnableInfo option.
    - Fixed fatal buffer_complete bug.
    - Improved buffer caching.
    - Added NeoComplCacheCachingDictionary command.
    - Implemented auto cache in tags_complete.
    - Fixed tags_complete caching error.
    - Don't save empty tags file.
    - Fixed output keyword error.
    - Fixed finalize error.
    - Use /dev/stdout in Linux and Mac in include_complete.
    - Deleted caching current buffer in include_complete.
    - Improved tex keyword pattern.
    - Improved analyse in syntax_complete.
    
     }}}
ChangeLog NeoComplCache 3.00-: {{{
   3.22:
    - Fixed manual completion error.
    - Fixed set completeopt bug.
    - Fixed manual completion error in omni_complete.
    - Fixed caching error in tags_complete(Thanks tosik).
    - Caching current buffer in include_complete.
    - Use include_complete's cache in omni_complete.
    - Fixed filetype bug in include_complete.
    - Don't cache huge file in include_complete.
    - Fixed snippet expand bug in snippets_complete.
    - Implemented keyword cache in omni_complete.
    - Implemented skip directory in filename_complete.
    
   3.21:
    - Catch error in omni_complete.
    - Deleted Filename() and g:snips_author in snippets_complete.
    - Catch eval error in snippets_complete.
    - Formatted help files.
    - Fixed set path pattern in Python.
    - Improved load complfuncs.
    - Improved wildcard.
    - Supported wildcard in vim_complete and omni_complete.
    - Improved skip completion.
    - Deleted g:NeoComplCache_SkipInputTime option.

   3.20:
    - Improved html and vim keyword pattern.
    - Improved buffer caching.
    - Improved manual completion.
    - Implemented Filename() and g:snips_author for snipMate.
    - Fixed fatal manual completion bug.
    - Don't expand environment variable in filename_complete.
    - Implemented environment variable completion in vim_complete.

   3.19:
    - Added C/C++ support in omni_complete.
    - Fixed PHP pattern bug in omni_complete.
    - Fixed quickmatch bug in omni_complete.
    - Don't complete within comment in vim_complete.
    - Improved global caching in vim_complete.
    - Improved omni patterns in omni_complete.
    - Deleted caching when BufWritePost in include_complete.
    - Implemented buffer local autocomplete lock.

   3.18:
    - Improved backslash escape in filename_complete.
    - Deleted \v pattern.
    - Fixed error when execute NeoComplCacheDisable.
    - Fixed keyword bug in vim_complete.
    - Implemented intellisense like prototype echo in vim_complete.
    - Added g:neocomplcache_enable_display_parameter option.
    - Implemented the static model recognition in vim_complete.
    - Fixed disable expand when buftype is 'nofile' bug in snippets_complete.
    - Implemented <Plug>(neocomplcache_snippets_jump) in snippets_complete.
    - Implemented hard tab expand in vim_complete.
    - Restore cursor position in omni_complete.

   3.17:
    - Reinforced vim_complete.vim.
    - Improved shortcut filename completion in filename_complete.
    - Implemented pseudo animation.
    - Supported backslash in vim_complete.
    - Supported manual plugin complete.
    - Improved caching speed when FileType in include_complete.
    - Fixed freeze bug in filename_complete.
   3.16:
    - Fixed executable bug in filename_complete.
    - Fixed error; when open the file of the filetype that g:neocomplcache_keyword_patterns does not have in include_complete.
    - Improved get keyword pattern.
    - Supported string and dictionary candidates in omni_complete.
    - Don't set dup when match with next keyword.
    - Implemented vim_complete(testing).
    - Syntax_complete disabled in vim.
    - Fixed quickmatch list bug.
    - Fixed expand snippets bug.

   3.15:
    - Fixed ruby omni_complete bug.
    - Fixed prefix bug.
    - Allow keyword trigger in snippets_complete.
    - Fixed NeoComplCacheEditRuntimeSnippets bug.
    - Refactoringed set pattern.
    - Added g:neocomplcache_quick_match_patterns option.
    - Added same filetype.
    - Revised English help.

   3.14: *Fatal: Fixed fatal buffer and dictionary cache bug. *
    - Fixed disable auto completion bug if bugtype contains 'nofile'.
    - Ignore no suffixes file in include_complete.
    - Fixed snippet merge bug in snippets_complete.
    - Fixed break buffer and dictionary cache bug.

   3.13:
    - Open popup menu when modified.
    - Improved buffer caching timing.
    - Skip completion if too many candidates.
    - Fixed quickmatch dup bug.
    - Fixed auto completion bug in filename_complete.
    - Fixed executable bug in filename_complete.

   3.12:
    - Improved ctags arguments patterns.
    - Allow dup and improved menu in omni_complete.
    - Recognized snippets directory of snipMate automatically.
    - Fixed eval snippet bug.
    - Fixed tags caching bug.
    - Deleted C omni completion support.
    - Fixed menu in buffer_complete.
    - Auto complete when CursorMovedI not CursorHoldI.
    - Reimplemented g:NeoComplCache_SkipInputTime option.
    - Fixed dup check bug in syntax_complete.
    
   3.11:
    - Filtering same word.
    - Implemented member filter.
    - Changed cache file syntax.
    - Print error when cache file is wrong.
    - Improved keyword patterns.
    - Reimplemented quickmatch.
    - Disabled '-' wildcard.
    - Allow dup in include_complete and tags_complete.
    - Improved filename completion.
    - implemented filename wildcard.

   3.10:
    - Optimized keyword_complete.
    - Integrated complfuncs.
    - Complfunc supported g:neocomplcache_plugin_completion_length option.
    - Improved omni completion pattern.
    - Improved html's keyword pattern.
    - Fixed manual completion error.
    - Improved remove next keyword.
    - Implemented complfunc rank.
    - Save error log when analyzing tags.

   3.09:
    - Improved wildcard behavior.
    - Disabled partial match.
    - Added g:neocomplcache_plugin_disable option.
    - Fixed wildcard bug.
    - Implemented fast search.
    - Fixed manual omni_complete error.
    - Improved manual completion.
    - Fixed filtering bug.
    - Print filename when caching.
    
   3.08:
    - Implemented NeoComplCacheCachingTags command.
    - Disable auto caching in tags_complete.
    - Echo filename when caching.
    - Disabled quick match.
    - Fixed wildcard bug when auto completion.
    - Improved caching in tags_complete and include_complete.
    - Split nicely when edit snippets_file.

   3.07:
    - Added snippet indent file.
    - Fixed filter bug in include_complete.
    - Fixed matchstr timing in include_complete.
    - Fixed error when includeexpr is empty in include_complete.
    - Don't caching readonly buffer in include_complete.
    - Implemented CursorHoldI completion.
    - Deleted g:neocomplcache_SkipInputTime and g:neocomplcache_QuickMatchmax_list option.
    - Fixed keyword pattern error in include_complete.
    - Fixed quickmatch.
    - Improved caching timing.
    - Added g:neocomplcache_include_suffixes option. 

   3.06:
    - Fixed disable completion bug.
    - Optimized tags_complete.
    - Implemented cache in tags_complete.
    - Implemented include_complete.
    - Fixed regex escape bug in snippets_complete.
    - Added g:neocomplcache_enable_auto_select option.
    - Deleted g:NeoComplCache_TagsAutoUpdate option.

   3.05:
    - Set completeopt-=longest.
    - Caching buffer when CursorHold.
    - Enable auto-complete in tags_complete.
    - Fixed manual completion bug.
    - Fixed error when omnifunc is empty.
    - Improved quickmatch.
    - Changed g:neocomplcache_max_list and g:neocomplcache_QuickMatchmax_list default value.
    - Fixed skip error.
    - Implemented completion skip if previous completion is empty.
    
   3.04:
    - Expand tilde.
    - Use complete_check().
    - Add '*' to a delimiter in filename_complete.
    - Improved ps1 keyword.
    - Echo error when you use old Vim.
    - set completeopt-=menuone.
    - Deleted cpp omni support.

   3.03:
    - Added scala support.
    - Added ActionScript support in omni_complete.
    - Fixed neocomplcache#plugin#snippets_complete#expandable()'s error.
    - Call multiple complefunc if cur_keyword_pos is equal.
    - Improved snippet menu.
    - Improved keymapping in snippets_complete.

   3.02:
    - Fixed escape bug in filename_complete.
    - Deleted cdpath completion.
    - Improved filename completion.
    - Fixed fatal bug when snippet expand.
    - Fixed marker substitute bug.
    - Fixed fatal caching bug.
    - Fixed error when sh/zsh file opened.
    - Implemented filetype completion.
    - Improved html/xhtml keyword pattern.

   3.01:
    - Added select mode mappings in snippets_complete.
    - Supported same filetype lists in snippets_complete.
    - Expandable a snippet including sign.
    - Added registers snippet.
    - Changed buffer_complete cache directory.
    - Sort alphabetical order in snippets_complete.
    - Improved get cur_text in snippets_complete.
    - Implemented condition in snippets_complete.
    - Added xhtml snippet(Thanks just!).
    - Fixed css error.
    - Implemented optional placeholder.
   
   3.00:
    - Implemented multiple keyword.
    - Improved html keyword completion.
    - Improved command's completion.
    - Fixed error in snippets_complete.
    - Fixed expand cursor bug in snippets_complete.
    - Improved skip completion.
    - Splitted filename completion and omni completion and keyword completion.
    - Improved remove next keyword.
    - Renamed keyword_complete.vim as buffer_complete.vim.
     }}}
ChangeLog NeoComplCache 2.51-: {{{
   2.78:
    - Supported abbr in omni completion.
    - Clear quickmatch cache when auto complete is skipped.
    - Fixed escape bug.
    - Implemented fast filter.

   2.77:
    - Improved caching message.
    - Implemented completion undo.
    - Fixed non-initialize error.
    - Fixed wildcard bug.
    - Improved quickmatch behavior.
    - Added g:neocomplcache_caching_percent_in_statusline option.
    - Fixed completion column bug.

   2.76:
    - Don't select in manual completion.
    - Clear numbered list when close popup.
    - Added snippet indent file.
    - Added NeoComplCachePrintSnippets command.
    - Supported placeholder 0.
    - Implemented sync placeholder.
    - Improved caching.
    - Supported snipMate's multi snippet.
    - Improved no new line snippet expand.
    - Fixed cursor pos bug.
    - Fixed next keyword completion bug.

   2.75:
    - Added css support.
    - Improved vim keyword.
    - Add rank if match next keyword.
    - Improved tex keyword.

   2.74:
    - Added ChangeLog.
    - Improved quick match.
    - Fixed no new line snippet expand bug in snippet completion.
    - Recognize next keyword in omni completion.
    - Optimized filename completion.
    - Ignore japanese syntax message in syntax completion.
    - Improved next keyword completion.

   2.73:
    - Improved manual completion.
    - Fixed error in manual omni completion when omnifunc is empty.
    - Improved filename completion.
    - Improved check candidate.
    - Improved omni completion.
    - Fixed dup bug in snippets_complete.

   2.72:
    - Improved quickmatch behavior.
    - Fixed expand() bug in snippets_complete.
    - Fixed prefix bug in filename completion.
    - Improved filename completion.
    - Substitute $HOME into '~' in filename completion.
    - Dispay 'cdpath' files in filename completion.
    - Dispay 'w:vimshell_directory_stack' files in filename completion.

   2.71:
    - Create g:neocomplcache_temporary_dir directory if not exists.
    - Create g:neocomplcache_snippets_dir directory if not exists.
    - Implemented direct expantion in snippet complete.
    - Implemented snippet alias in snippet complete.
    - Added g:neocomplcache_plugin_completion_length option.
    - Improved get cursour word.
    - Added Objective-C/C++ support.
    - Fixed filename completion bug when environment variable used.
    - Improved skipped behavior.
    - Implemented short filename completion.
    - Check cdpath in filename completion.
    - Fixed expand jump bug in snippets completion.

   2.70:
    - Improved omni completion.
    - Display readonly files.
    - Fixed filename completion bug.
    - No ignorecase in next keyword completion.

   2.69: - Improved quick match.
    - Fixed html omni completion error.
    - Improved html omni completion pattern.
    - Improved g:neocomplcache_ctags_arguments_list in vim filetype.
    - Delete quick match cache when BufWinEnter.
    - Convert string omni completion.

   2.68:
    - Improved quick match in filename completion.
    - Deleted g:NeoComplCache_FilenameCompletionSkipItems option.
    - Search quick match if no keyword match.
    - Fixed manual_complete wildcard bug.
    - Caching from cache in syntax_complete.
    - Added NeoComplCacheCachingSyntax command.

   2.67:
    - Fixed snippet without default value expand bug.
    - Added snippet file snippet.
    - Improved keyword pattern.
    - Insert quickmatched candidate immediately.
    - The quick match input does not make a cache.

   2.66:
    - Improved manual.
    - Fixed snippet expand bugs.
    - Caching snippets when file open.
    - g:neocomplcache_snippets_dir is comma-separated list.
    - Supported escape sequence in filename completion.
    - Improved set complete function timing.

   2.65:
    - Deleted wildcard from filename completion.
    - Fixed ATOK X3 on when snippets expanded.
    - Fixed syntax match timing(Thanks thinca!).
    - Improved vimshell keyword pattern.
    - Added snippet delete.
    - Added English manual.

   2.64:
    - Substitute \ -> / in Windows.
    - Improved NeoComplCacheCachingBuffer command.
    - Added g:neocomplcache_caching_limit_file_size option.
    - Added g:neocomplcache_disable_caching_buffer_name_pattern option.
    - Don't caching readonly file.
    - Improved neocomplcache#keyword_complete#caching_percent.

   2.63:
    - Substitute ... -> ../.. .
    - Changed short filename into ~.
    - Improved filename completion.
    - Callable get_complete_words() and word_caching_current_line() function.
    - Erb is same filetype with ruby.
    - Improved html and erb filetype.
    - Improved erb snippets.
    - Improved css omni completion.
    - Improved vimshell keyword pattern.

   2.62:
    - Added make syntax.
    - Put up the priority of directory in filename completion.
    - Draw executable files in filename completion.
    - Added g:NeoComplCache_FilenameCompletionSkipItems option.
    - Fixed filename completion bug on enable quick match.

   2.61:
    - Fixed ATOK X3 on when snippets expanded.
    - Improved vimshell syntax.
    - Improved skip completion.

   2.60: Improved filename completion.
    - Improved long filename view.
    - Improved filtering.
    - Fixed keyword sort bug.

   2.59: Fixed caching bug.

   2.58: Improved caching timing.
    - Optimized caching.

   2.57: Improved snippets_complete.
    - Fixed feedkeys.
    - Improved skip completion.
    - Changed g:NeoComplCache_PartialCompletionStartLength default value.
    - Improved camel case completion and underbar completion.
    - Fixed add rank bug in snippet completion.
    - Loadable snipMate snippets file in snippet completion.
    - Implemented _ snippets in snippet completion.

   2.56: Implemented filename completion.
    - Don't caching when not buflisted in syntax complete.
    - Implemented neocomplcache#manual_filename_complete().
    - Improved filename toriming.
    - Fixed E220 in tex filetype.
    - Improved edit snippet.

   2.55: Output cache file.
    - Added g:neocomplcache_temporary_dir option.
    - Improved garbage collect.

   2.52: Fixed bugs.
    - Changed g:NeoComplCache_PreviousKeywordCompletion default value.
    - Fixed NeoComplCacheDisable bug.
    - Fixed neocomplcache#keyword_complete#caching_percent() bug.
    - Fixed analyze caching bug.
    - Fixed quick match.
    - Improved wildcard.

   2.51: Optimized dictionary and fixed bug.
    - Deleted g:NeoComplCache_MaxTryKeywordLength options.
    - Deleted NeoComplCacheCachingDictionary command.
    - Improved caching echo.
    - Optimized calc rank.
    - Fixed abbr_save error.
    - Don't caching on BufEnter.
    - Optimized manual_complete behavior.
    - Added g:neocomplcache_manual_completion_start_length option.
    - Fixed next keyword completion bug.
    - Fixed caching initialize bug.
    - Fixed on InsertLeave error.
     }}}
ChangeLog NeoComplCache 2.00-2.50: {{{
   2.50: Caching on editing file.
    - Optimized NeoComplCacheCachingBuffer.
    - Implemented neocomplcache#close_popup() and neocomplcache#cancel_popup().
    - Fixed ignore case behavior.
    - Fixed escape error.
    - Improved caching.
    - Deleted g:NeoComplCache_TryKeywordCompletion and g:NeoComplCache_TryDefaultCompletion options.
    - Deleted g:NeoComplCache_MaxInfoList and g:NeoComplCache_DeleteRank0 option.
    - Don't save info in keyword completion.

   2.44: Improved popup menu in tags completion.
    - Improved popup menu in tags completion.
    - Fixed escape error.
    - Fixed help.

   2.43: Improved wildcard.
    - Improved wildcard.
    - Changed 'abbr_save' into 'abbr'.
    - Fixed :NeoComplCacheCachingBuffer bug.

   2.42:
    - Call completefunc when original completefunc.
    - Added g:NeoComplCache_TryFilenameCompletion option.
    - Fixed g:NeoComplCache_TryKeywordCompletion bug.
    - Fixed menu padding.
    - Fixed caching error.
    - Implemented underbar completion.
    - Added g:neocomplcache_enable_underbar_completion option.

   2.41:
    - Improved empty check.
    - Fixed eval bug in snippet complete.
    - Fixed include bug in snippet complete.

   2.40:
    - Optimized caching in small files.
    - Deleted buffer dictionary.
    - Display cached from buffer.
    - Changed g:NeoComplCache_MaxInfoList default value.
    - Improved calc rank.
    - Improved caching timing.
    - Added NeoComplCacheCachingDisable and g:NeoComplCacheCachingEnable commands.
    - Fixed commentout bug in snippet complete.

   2.39:
    - Fixed syntax highlight.
    - Overwrite snippet if name is same.
    - Caching on InsertLeave.
    - Manual completion add wildcard when input non alphabetical character.
    - Fixed menu error in syntax complete.

   2.38:
    - Fixed typo.
    - Optimized caching.

   2.37:
    - Added g:NeoComplCache_SkipCompletionTime option.
    - Added g:NeoComplCache_SkipInputTime option.
    - Changed g:NeoComplCache_SlowCompleteSkip option into g:NeoComplCache_EnableSkipCompletion.
    - Improved ruby omni pattern.
    - Optimized syntax complete.
    - Delete command abbreviations in vim filetype.

   2.36:
    - Implemented snipMate like snippet.
    - Added syntax file.
    - Detect snippet file.
    - Fixed default value selection bug.
    - Fixed ignorecase.

   2.35:
    - Fixed NeoComplCacheDisable bug.
    - Implemented <Plug>(neocomplcache_keyword_caching) keymapping.
    - Improved operator completion.
    - Added syntax highlight.
    - Implemented g:neocomplcache_snippets_dir.

   2.34:
    - Increment rank when snippet expanded.
    - Use selection.
    - Fixed place holder's default value bug.
    - Added g:neocomplcache_min_syntax_length option.

   2.33:
    - Implemented <Plug>(neocomplcache_snippets_expand) keymapping.
    - Implemented place holder.
    - Improved place holder's default value behavior.
    - Enable filename completion in lisp filetype.

   2.32:
     - Implemented variable cache line.
     - Don't complete '/cygdrive/'.
     - Fixed popup preview window bug if g:NeoComplCache_EnableInfo is 0.

   2.31:
     - Optimized caching.
     - Improved html omni syntax.
     - Changed g:NeoComplCache_MaxInfoList default value.
     - Try empty keyword completion if candidate is empty in manual complete.
     - Delete candidate from source if rank is low.
     - Disable filename completion in tex filetype.

   2.30:
     - Deleted MFU.
     - Optimized match.
     - Fixed cpp keyword bugs.
     - Improved snippets_complete.

   2.29:
     - Improved plugin interface.
     - Refactoring.

   2.28:
     - Improved autocmd.
     - Fixed delete source bug when g:NeoComplCache_EnableMFU is set.
     - Implemented snippets_complete.
     - Optimized abbr.

   2.27:
     - Improved filtering.
     - Supported actionscript.
     - Improved syntax.
     - Added caching percent support.

   2.26:
     - Improved ruby and vim and html syntax.
     - Fixed escape.
     - Supported erlang and eruby and etc.
     - Refactoring autocmd.

   2.25:
     - Optimized syntax caching.
     - Fixed ruby and ocaml syntax.
     - Fixed error when g:neocomplcache_enable_alphabetical_order is set.
     - Improved syntax_complete caching event.

   2.24:
     - Optimized calc rank.
     - Optimized keyword pattern.
     - Implemented operator completion.
     - Don't use include completion.
     - Fixed next keyword bug.

   2.23:
     - Fixed compound keyword pattern.
     - Optimized keyword pattern.
     - Fixed can't quick match bug on g:neocomplcache_enable_camel_case_completion is 1.

   2.22:
     - Improved tex syntax.
     - Improved keyword completion.
     - Fixed sequential caching bug.

   2.21:
     - Fixed haskell and ocaml and perl syntax.
     - Fixed g:neocomplcache_enable_camel_case_completion default value.
     - Extend skip time.
     - Added NeoComplCacheAutoCompletionLength and NeoComplCachePartialCompletionLength command.
     - Fixed extend complete length bug.
     - Improved camel case completion.

   2.20:
     - Improved dictionary check.
     - Fixed manual complete wildcard bug.
     - Fixed assuming filetype bug.
     - Implemented camel case completion.
     - Improved filetype and filename check.

   2.19:
     - Plugin interface changed.
     - Patterns use very magic.
     - Fixed syntax_complete.

   2.18:
     - Implemented tags_complete plugin.
     - Fixed default completion bug.
     - Extend complete length when consecutive skipped.
     - Auto complete on CursorMovedI.
     - Deleted similar match.

   2.17:
     - Loadable autoload/neocomplcache/*.vim plugin.
     - Implemented syntax_complete plugin.

   2.16:
     - Fixed caching initialize bug.
     - Supported vim help file.
     - Created manual.
     - Fixed variables name.
     - Deleted g:neocomplcache_CalcRankmax_lists option.

   2.15:
     - Improved C syntax.
     - Added g:NeoComplCache_MaxTryKeywordLength option.
     - Improved prev rank.
     - Optimized if keyword is empty.

   2.14:
     - Optimized calc rank.

   2.13:
     - Optimized caching.
     - Optimized calc rank.
     - Fixed calc rank bugs.
     - Optimized similar match.
     - Fixed dictionary bug.

   2.12:
     - Added g:NeoComplCache_CachingRandomize option.
     - Changed g:neocomplcache_cache_line_count default value.
     - Optimized caching.
     - Caching current cache line on idle.
     - Fixed key not present error.
     - Fixed caching bug.

   2.11:
     - Implemented prev_rank.
     - Fixed disable auto complete bug.
     - Changed g:neocomplcache_min_keyword_length default value.
     - Changed g:neocomplcache_cache_line_count default value.
     - Fixed MFU.
     - Optimized calc rank.
     - Fixed freeze bug when InsertEnter and InsertLeave.

   2.10:
     - Divided as plugin.
     - NeoComplCacheToggle uses lock() and unlock()
     - Abbreviation indication of the end.
     - Don't load MFU when MFU is empty.
     - Changed g:AltAutoComplPop_EnableAsterisk into g:neocomplcache_enable_wildcard.
     - Added wildcard '-'.
     - Fixed key not present error.

   2.02:
     - Supported compound filetype.
     - Disable partial match when skipped.
     - Fixed wildcard bug.
     - Optimized info.
     - Added g:NeoComplCache_EnableInfo option.
     - Disable try keyword completion when wildcard.

   2.01:
     - Caching on InsertLeave.
     - Changed g:Neocomplcache_cache_line_count default value.
     - Fixed update tags bug.
     - Enable asterisk when cursor_word is (, $, #, @, ...
     - Improved wildcard.

   2.00:
     - Save keyword found line.
     - Changed g:Neocomplcache_cache_line_count default value.
     - Fixed skipped bug.
     - Improved commands.
     - Deleted g:NeoComplCache_DrawWordsRank option.
     }}}
ChangeLog NeoComplCache 1.00-1.60: {{{
   1.60:
     - Improved calc similar algorithm.
   1.59:
     - Improved NeoComplCacheSetBufferDictionary.
     - Fixed MFU bug.
     - Don't try keyword completion when input non word character.
   1.58:
     - Fixed s:SetOmniPattern() and s:SetKeywordPattern() bugs.
     - Changed g:neocomplcache_min_keyword_length default value.
     - Implemented same filetype completion.
   1.57:
     - Deleted g:NeoComplCache_FirstHeadMatching option. 
     - Deleted prev_rank.
     - Implemented 3-gram completion.
     - Fixed MFU bug.
   1.56:
     - Use vim commands completion in vim filetype.
   1.55:
     - Implemented NeoComplCacheCreateTags command.
     - Fixed tags auto update bug.
     - Added g:NeoComplCache_TryKeywordCompletion option.
   1.54:
     - Added tags syntax keyword.
     - Implemented local tags.
     - Implemented local tags auto update.
     - Fixed s:prepre_numbered_list bug.
   1.53:
     - Disable similar completion when auto complete.
     - Calc rank when NeoComplCacheCachingBuffer command.
     - Added NeoComplCacheOutputKeyword command.
   1.52:
     - Fixed syntax keyword bug.
     - Improved syntax keyword.
     - Implemented similar completion.
   1.51:
     - Added g:NeoComplCache_PartialCompletionStartLength option.
     - Fixed syntax keyword bug.
   1.50:
     - Deleted g:NeoComplCache_CompleteFuncLists.
     - Set filetype 'nothing' if filetype is empty.
     - Implemented omni completion.
     - Added debug command.
     - Improved syntax keyword.
   1.49:
     - Fixed g:NeoComplCache_MFUDirectory error.
     - Changed g:neocomplcache_keyword_patterns['default'] value.
   1.48:
     - Implemented NeoComplCacheSetBufferDictionary command.
     - Implemented 2-gram MFU.
     - Improved syntax completion.
     - Fixed "complete from same filetype buffer" bug.
   1.47:
     - Implemented 2-gram completion.
     - Improved ruby keyword.
   1.46:
     - Complete from same filetype buffer.
   1.45:
     - Fixed g:NeoComplCache_MFUDirectory bug.
     - Improved syntax keyword.
     - Deleted g:NeoComplCache_FirstCurrentBufferWords option.
     - Implemented previous keyword completion.
   1.44:
     - Improved most frequently used dictionary.
     - Improved if bufname changed.
     - Restore wildcard substitution '.\+' into '.*'.
     - Fixed next keyword completion bug.
   1.43:
     - Refactoring when caching source.
     - Initialize source if bufname changed.
     - Implemented most frequently used dictionary.
   1.42:
     - Caching when InsertLeave event.
     - Changed g:neocomplcache_cache_line_count value.
     - Changed wildcard substitution '.*' into '.\+'.
     - Allow word's tail '*' if g:NeoComplCache_EnableAsterisk.
     - Allow word's head '*' on lisp.
     - Allow word's head '&' on perl.
     - Optimized global options definition.
   1.41:
     - Added g:neocomplcache_enable_smart_case option.
     - Optimized on completion and caching.
     - Fixed g:NeoComplCache_ManualCompleteFunc bug.
   1.40:
     - Fixed freeze bug when many - inputed.
     - Improved next keyword completion.
     - Improved caching.
     - Fixed next keyword completion bug.
   1.39:
     - Fixed filename completion bug.
     - Fixed dup bug.
     - Implemented next keyword completion.
   1.38:
     - Fixed PHP completion bug.
     - Improved filetype detection.
     - Added space between keyword and file name.
     - Implemented randomize rank calculation.
     - Added g:NeoComplCache_CalcRankRandomize option.
   1.37:
     - Improved file complete.
     - Fixed file complete bug.
   1.36:
     - Added g:NeoComplCache_FirstHeadMatching option.
     - Fixed list order bug.
     - Changed g:neocomplcache_QuickMatchmax_lists default value.
     - Optimized when buffer renamed.
   1.35:
     - Improved syntax complete.
     - Improved NeoComplCacheToggle.
   1.34:
     - Fixed g:NeoComplCache_FirstCurrentBufferWords bug.
     - Fixed quick match bug.
     - Not change lazyredraw.
   1.33:
     - Added g:neocomplcache_QuickMatchmax_lists option.
     - Changed g:NeoComplCache_QuickMatch into g:NeoComplCache_QuickMatchEnable.
     - Implemented two digits quick match.
   1.32:
     - Improved completion cancel.
     - Improved syntax keyword vim, sh, zsh, vimshell.
     - Implemented g:NeoComplCache_NonBufferFileTypeDetect option.
   1.31:
     - Added g:neocomplcache_min_keyword_length option.
     - Caching keyword_pattern.
     - Fixed current buffer filtering bug.
     - Fixed rank calculation bug.
     - Optimized keyword caching.
     - Fixed lazyredraw bug.
   1.30:
     - Added NeoCompleCachingTags, NeoComplCacheDictionary command.
     - Renamed NeoCompleCachingBuffer command.
   1.29:
     - Added NeoComplCacheLock, NeoComplCacheUnlock command.
     - Dup check when quick match.
     - Fixed error when manual complete.
   1.28:
     - Improved filetype detection.
     - Changed g:neocomplcache_max_filename_width default value.
     - Improved list.
   1.27:
     - Improved syntax keyword.
     - Improved calc rank timing.
     - Fixed keyword filtering bug.
   1.26:
     - Ignore if dictionary file doesn't exists.
     - Due to optimize, filtering len(cur_keyword_str) >.
     - Auto complete when InsertEnter.
   1.25:
     - Exclude cur_keyword_str from keyword lists.
   1.24:
     - Due to optimize, filtering len(cur_keyword_str) >=.
     - Fixed buffer dictionary bug.
   1.23:
     - Fixed on lazyredraw bug.
     - Optimized when no dictionary and tags.
     - Not echo calculation time.
   1.22:
     - Optimized source.
   1.21:
     - Fixed overwrite completefunc bug.
   1.20:
     - Implemented buffer dictionary.
   1.10:
     - Implemented customizable complete function.
   1.00:
     - Renamed.
     - Initial version.
     }}}
ChangeLog AltAutoComplPop: {{{
   2.62:
     - Set lazyredraw at auto complete.
     - Added g:AltAutoComplPop_CalcRankMaxLists option.
     - Improved calc rank timing.
     - Improved filetype check.
   2.61:
     - Improved keyword patterns.
     - Changed g:AltAutoComplPop_CacheLineCount default value.
     - Implemented :Neco command.
   2.60:
     - Cleanuped code.
     - Show '[T]' or '[D]' at completing.
     - Implemented tab pages tags completion.
     - Fixed error when tab created.
     - Changed g:AltAutoComplPop_CalcRankCount default value.
   2.50:
     - Implemented filetype dictionary completion.
   2.14:
     - Fixed 'Undefined Variable: s:cur_keyword_pos' bug.
     - Implemented tags completion.
   2.13:
     - Added g:AltAutoComplPop_DictionaryLists option.
     - Implemented dictionary completion.
   2.12:
     - Added g:AltAutoComplPop_CalcRankCount option.
   2.11:
     - Added g:AltAutoComplPop_SlowCompleteSkip option.
     - Removed g:AltAutoComplPop_OptimizeLevel option.
   2.10:
     - Added g:AltAutoComplPop_QuickMatch option.
     - Changed g:AltAutoComplPop_MaxList default value.
     - Don't cache help file.
   2.09:
     - Added g:AltAutoComplPop_EnableAsterisk option.
     - Fixed next cache line cleared bug.
   2.08:
     - Added g:AltAutoComplPop_OptimizeLevel option.
       If list has many keyword, will optimize complete. 
     - Added g:AltAutoComplPop_DisableAutoComplete option.
   2.07:
     - Fixed caching miss when BufRead.
   2.06:
     - Improved and customizable keyword patterns.
   2.05:
     - Added g:AltAutoComplPop_DeleteRank0 option.
     - Implemented lazy caching.
     - Cleanuped code.
   2.04:
     - Fixed caching bug.
   2.03:
     - Fixed rank calculation bug.
   2.02:
     - Fixed GVim problem at ATOK X3
   2.01:
     - Fixed rank calculation bug.
     - Faster at caching.
   2.0:
     - Implemented Updates current buffer cache at InsertEnter.
   1.13:
     - Licence changed.
     - Fix many bugs.
   1.1:
     - Implemented smart completion.
       It works in vim, c, cpp, ruby, ...
     - Implemented file completion.
   1.0:
     - Initial version.
}}}

==============================================================================
vim:tw=78:ts=8:ft=help:norl:noet:fen:fdl=0:fdm=marker:noet:
indent/snippet.vim	[[[1
58
"=============================================================================
" FILE: snippets.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 26 Oct 2009
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal expandtab
setlocal shiftwidth=4
setlocal softtabstop=4
if !exists('b:undo_indent')
    let b:undo_indent = ''
endif

setlocal indentexpr=SnippetsIndent()

function! SnippetsIndent()"{{{
    let l:line = getline('.')
    let l:prev_line = (line('.') == 1)? '' : getline(line('.')-1)

    if l:prev_line =~ '^\s*$'
        return 0
    elseif l:prev_line =~ '^\%(include\|snippet\|abbr\|prev_word\|rank\|delete\|alias\|condition\)'
                \&& l:line !~ '^\s*\%(include\|snippet\|abbr\|prev_word\|rank\|delete\|alias\|condition\)'
        return &shiftwidth
    else
        return match(l:line, '\S')
    endif
endfunction"}}}

let b:undo_indent .= '
    \ | setlocal expandtab< shiftwidth< softtabstop<
    \'
plugin/neocomplcache.vim	[[[1
166
"=============================================================================
" FILE: neocomplcache.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 10 Sep 2010
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
" Version: 5.2, for Vim 7.0
" GetLatestVimScripts: 2620 1 :AutoInstall: neocomplcache
"=============================================================================

if v:version < 700
  echoerr 'neocomplcache does not work this version of Vim (' . v:version . ').'
  finish
elseif exists('g:loaded_neocomplcache')
  finish
elseif !has('reltime')
  echoerr 'neocomplcache needs reltime feature.'
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=0 NeoComplCacheEnable call neocomplcache#enable()

" Obsolute options check."{{{
if exists('g:NeoComplCache_EnableAtStartup')
  echoerr 'g:NeoComplCache_EnableAtStartup option does not work this version of neocomplcache.'
endif
if exists('g:NeoComplCache_KeywordPatterns')
  echoerr 'g:NeoComplCache_KeywordPatterns option does not work this version of neocomplcache.'
endif
if exists('g:NeoComplCache_DictionaryFileTypeLists')
  echoerr 'g:NeoComplCache_DictionaryFileTypeLists option does not work this version of neocomplcache.'
endif
if exists('g:NeoComplCache_KeywordCompletionStartLength')
  echoerr 'g:NeoComplCache_KeywordCompletionStartLength option does not work this version of neocomplcache.'
endif
"}}}
" Global options definition."{{{
if !exists('g:neocomplcache_max_list')
  let g:neocomplcache_max_list = 100
endif
if !exists('g:neocomplcache_max_keyword_width')
  let g:neocomplcache_max_keyword_width = 50
endif
if !exists('g:neocomplcache_max_filename_width')
  let g:neocomplcache_max_filename_width = 15
endif
if !exists('g:neocomplcache_auto_completion_start_length')
  let g:neocomplcache_auto_completion_start_length = 2
endif
if !exists('g:neocomplcache_manual_completion_start_length')
  let g:neocomplcache_manual_completion_start_length = 2
endif
if !exists('g:neocomplcache_min_keyword_length')
  let g:neocomplcache_min_keyword_length = 4
endif
if !exists('g:neocomplcache_enable_ignore_case')
  let g:neocomplcache_enable_ignore_case = &ignorecase
endif
if !exists('g:neocomplcache_enable_smart_case')
  let g:neocomplcache_enable_smart_case = 0
endif
if !exists('g:neocomplcache_disable_auto_complete')
  let g:neocomplcache_disable_auto_complete = 0
endif
if !exists('g:neocomplcache_enable_wildcard')
  let g:neocomplcache_enable_wildcard = 1
endif
if !exists('g:neocomplcache_enable_quick_match')
  let g:neocomplcache_enable_quick_match = 0
endif
if !exists('g:neocomplcache_enable_camel_case_completion')
  let g:neocomplcache_enable_camel_case_completion = 0
endif
if !exists('g:neocomplcache_enable_underbar_completion')
  let g:neocomplcache_enable_underbar_completion = 0
endif
if !exists('g:neocomplcache_enable_caching_message')
  let g:neocomplcache_enable_caching_message = 1
endif
if !exists('g:neocomplcache_enable_cursor_hold_i')
  let g:neocomplcache_enable_cursor_hold_i = 0
endif
if !exists('g:neocomplcache_cursor_hold_i_time')
  let g:neocomplcache_cursor_hold_i_time = 300
endif
if !exists('g:neocomplcache_enable_auto_select')
  let g:neocomplcache_enable_auto_select = 0
endif
if !exists('g:neocomplcache_enable_auto_delimiter')
  let g:neocomplcache_enable_auto_delimiter = 0
endif
if !exists('g:neocomplcache_caching_limit_file_size')
  let g:neocomplcache_caching_limit_file_size = 500000
endif
if !exists('g:neocomplcache_disable_caching_buffer_name_pattern')
  let g:neocomplcache_disable_caching_buffer_name_pattern = ''
endif
if !exists('g:neocomplcache_lock_buffer_name_pattern')
  let g:neocomplcache_lock_buffer_name_pattern = ''
endif
if !exists('g:neocomplcache_force_caching_buffer_name_pattern')
  let g:neocomplcache_force_caching_buffer_name_pattern = ''
endif
if !exists('g:neocomplcache_disable_auto_select_buffer_name_pattern')
  let g:neocomplcache_disable_auto_select_buffer_name_pattern = ''
endif
if !exists('g:neocomplcache_ctags_program')
  let g:neocomplcache_ctags_program = 'ctags'
endif
if !exists('g:neocomplcache_plugin_disable')
  let g:neocomplcache_plugin_disable = {}
endif
if !exists('g:neocomplcache_plugin_completion_length')
  let g:neocomplcache_plugin_completion_length = {}
endif
if !exists('g:neocomplcache_plugin_rank')
  let g:neocomplcache_plugin_rank = {}
endif
if !exists('g:neocomplcache_temporary_dir')
  let g:neocomplcache_temporary_dir = '~/.neocon'
endif
let g:neocomplcache_temporary_dir = expand(g:neocomplcache_temporary_dir)
if !isdirectory(g:neocomplcache_temporary_dir)
  call mkdir(g:neocomplcache_temporary_dir, 'p')
endif
if !exists('g:neocomplcache_quick_match_table')
  let g:neocomplcache_quick_match_table = {
        \'a' : 0, 's' : 1, 'd' : 2, 'f' : 3, 'g' : 4, 'h' : 5, 'j' : 6, 'k' : 7, 'l' : 8, ';' : 9,
        \'q' : 10, 'w' : 11, 'e' : 12, 'r' : 13, 't' : 14, 'y' : 15, 'u' : 16, 'i' : 17, 'o' : 18, 'p' : 19, 
        \}
endif
if exists('g:neocomplcache_enable_at_startup') && g:neocomplcache_enable_at_startup
  augroup neocomplcache
    autocmd!
    " Enable startup.
    autocmd VimEnter * call neocomplcache#enable()
  augroup END
endif"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_neocomplcache = 1

" vim: foldmethod=marker
syntax/snippet.vim	[[[1
71
"=============================================================================
" FILE: syntax/snippet.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 15 Sep 2010
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

if version < 700
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn region  SnippetPrevWord             start=+'+ end=+'+ contained
syn region  SnippetPrevWord             start=+"+ end=+"+ contained
syn region  SnippetEval                 start=+\\\@<!`+ end=+\\\@<!`+ contained
syn match   SnippetWord                 '^\s\+.*$' contains=SnippetEval,SnippetExpand,SnippetEscape
syn match   SnippetExpand               '\${\d\+\%(:.\{-}\)\?\\\@<!}' contained
syn match   SnippetVariable             '\$\d\+' contained
syn match   SnippetComment              '^#.*$'
syn match   SnippetEscape               '\\[`]' contained

syn match   SnippetKeyword              '^\%(include\|snippet\|abbr\|prev_word\|delete\|alias\)' contained
syn match   SnippetPrevWords            '^prev_word\s\+.*$' contains=SnippetPrevWord,SnippetKeyword
syn match   SnippetStatementName        '^snippet\s.*$' contains=SnippetName,SnippetKeyword
syn match   SnippetName                 '\s\+.*$' contained
syn match   SnippetStatementAbbr        '^abbr\s.*$' contains=SnippetAbbr,SnippetKeyword
syn match   SnippetAbbr                 '\s\+.*$' contained
syn match   SnippetStatementRank        '^rank\s.*$' contains=SnippetRank,SnippetKeyword
syn match   SnippetRank                 '\s\+\d\+$' contained
syn match   SnippetStatementInclude     '^include\s.*$' contains=SnippetInclude,SnippetKeyword
syn match   SnippetInclude              '\s\+.*$' contained
syn match   SnippetStatementDelete      '^delete\s.*$' contains=SnippetDelete,SnippetKeyword
syn match   SnippetDelete               '\s\+.*$' contained
syn match   SnippetStatementAlias       '^alias\s.*$' contains=SnippetAlias,SnippetKeyword
syn match   SnippetAlias                '\s\+.*$' contained

hi def link SnippetKeyword Statement
hi def link SnippetPrevWord String
hi def link SnippetName Identifier
hi def link SnippetAbbr Normal
hi def link SnippetEval Type
hi def link SnippetWord String
hi def link SnippetExpand Special
hi def link SnippetVariable Special
hi def link SnippetComment Comment
hi def link SnippetInclude PreProc
hi def link SnippetDelete PreProc
hi def link SnippetAlias Identifier
hi def link SnippetEscape Special

let b:current_syntax = "snippet"
