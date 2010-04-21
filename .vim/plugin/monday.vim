" Vim plugin file
"
" Maintainer:   Stefan Karlsson <stefan.74@comhem.se>
" Last Change:  6 May 2005
"
" Purpose:      To make <ctrl-a> and <ctrl-x> operate on the names of weekdays
"               and months. Also to make them operate on text such as 1st, 2nd,
"               3rd, and so on.
"
" TODO:         Although it is possible to add any words you like as
"               increase/decrease pairs, problems will arise when one word has
"               two or more possible successors (or predecessors). For instance,
"               the 4th month is named "April" in both English and Swedish, but
"               its successor is called "May" and "Maj", respectively.
"
"               So, in order for the script to be generally applicable, I must
"               find a way to toggle between all possible increments/decrements
"               of a word.


if exists('loaded_monday') || &compatible
  finish
endif
let loaded_monday = 1

let s:words   = ''
let s:numbers = ''

function s:Add_word_pair(word1, word2)
  let w10 = tolower(a:word1)
  let w11 = toupper(matchstr(a:word1, '.')) . matchstr(w10, '.*', 1) 
  let w12 = toupper(a:word2)

  let w20 = tolower(a:word2)
  let w21 = toupper(matchstr(a:word2, '.')) . matchstr(w20, '.*', 1) 
  let w22 = toupper(a:word2)

  let s:words = s:words . w10 . ':' . w20 . ','
  let s:words = s:words . w11 . ':' . w21 . ','
  let s:words = s:words . w12 . ':' . w22 . ','
endfunction

function s:Add_number_suffix(number, suffix)
  let s0 = tolower(a:suffix)
  let s1 = toupper(a:suffix)

  let s:numbers = s:numbers . 's' . a:number . s0 . ','
  let s:numbers = s:numbers . 'l' . a:number . s1 . ','
endfunction

call <SID>Add_word_pair('monday',    'tuesday')
call <SID>Add_word_pair('tuesday',   'wednesday')
call <SID>Add_word_pair('wednesday', 'thursday')
call <SID>Add_word_pair('thursday',  'friday')
call <SID>Add_word_pair('friday',    'saturday')
call <SID>Add_word_pair('saturday',  'sunday')
call <SID>Add_word_pair('sunday',    'monday')

call <SID>Add_word_pair('january',   'february')
call <SID>Add_word_pair('february',  'march')
call <SID>Add_word_pair('march',     'april')
call <SID>Add_word_pair('april',     'may')
call <SID>Add_word_pair('may',       'june')
call <SID>Add_word_pair('june',      'july')
call <SID>Add_word_pair('july',      'august')
call <SID>Add_word_pair('august',    'september')
call <SID>Add_word_pair('september', 'october')
call <SID>Add_word_pair('october',   'november')
call <SID>Add_word_pair('november',  'december')
call <SID>Add_word_pair('december',  'january')

call <SID>Add_number_suffix('11', 'th')
call <SID>Add_number_suffix('12', 'th')
call <SID>Add_number_suffix('13', 'th')

call <SID>Add_number_suffix( '0', 'th')
call <SID>Add_number_suffix( '1', 'st')
call <SID>Add_number_suffix( '2', 'nd')
call <SID>Add_number_suffix( '3', 'rd')
call <SID>Add_number_suffix( '4', 'th')
call <SID>Add_number_suffix( '5', 'th')
call <SID>Add_number_suffix( '6', 'th')
call <SID>Add_number_suffix( '7', 'th')
call <SID>Add_number_suffix( '8', 'th')
call <SID>Add_number_suffix( '9', 'th')

function s:Find_nr_suffix(w, nr)
  let n1 = matchstr(a:nr, '\d\>')
  let n2 = matchstr(a:nr, '\d\d\>')

  let m = matchstr(a:w, '\D\+', 1)
  let m = matchstr(s:numbers, '[sl]\d\+' . m)
  let m = matchstr(m, '.')

  let c1 = (n1 != "") ? match(s:numbers, m . n1 . '\D\+') : -1
  let c2 = (n2 != "") ? match(s:numbers, m . n2 . '\D\+') : -1

  if c2 >= 0
    return matchstr(s:numbers, '\D\+\>', c2)
  else
    return matchstr(s:numbers, '\D\+\>', c1)
  endif
endfunction

function s:Goto_first_nonblank()
  call cursor(0, col('.') - 1)
  call search('\S')
endfunction

function s:Increase()
  let N = (v:count < 1) ? 1 : v:count
  let i = 0
  while i < N
    let w = expand('<cWORD>')
    if s:words =~# '\<' . w . ':'
      let n = match(s:words, w . ':\i\+\C')
      let n = match(s:words, ':', n)
      let a = matchstr(s:words, '\i\+', n)
      call <SID>Goto_first_nonblank()
      execute "normal! ciw" . a
    elseif w =~# '\<-\?\d\+\D\+\>' && s:numbers =~# '\d\+' . matchstr(w, '\D\+', 1) . ','
      let a = matchstr(w, '-\?\d\+')
      let a = a + 1
      let s = <SID>Find_nr_suffix(w, a)
      call <SID>Goto_first_nonblank()
      execute "normal! ciW" . a . s
    else
      execute "normal! \<c-a>"
    endif
    let i = i + 1
  endwhile
endfunction

function s:Decrease()
  let N = (v:count < 1) ? 1 : v:count
  let i = 0
  while i < N
    let w = expand('<cWORD>')
    if s:words =~# ':' . w . '\>'
      let n = match(s:words, '\i\+\C:' . w)
      let a = matchstr(s:words, '\i\+', n)
      call <SID>Goto_first_nonblank()
      execute "normal! ciw" . a
    elseif w =~# '\<-\?\d\+\D\+\>' && s:numbers =~# '\d\+' . matchstr(w, '\D\+', 1) . ','
      let a = matchstr(w, '-\?\d\+')
      let a = a - 1
      let s = <SID>Find_nr_suffix(w, a)
      call <SID>Goto_first_nonblank()
      execute "normal! ciW" . a . s
    else
      execute "normal! \<c-x>"
    endif
    let i = i + 1
  endwhile
endfunction

nmap <silent> <c-a> :<c-u>call <SID>Increase()<cr>
nmap <silent> <c-x> :<c-u>call <SID>Decrease()<cr>
