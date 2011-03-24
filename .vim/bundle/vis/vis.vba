" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
plugin/vis.vim
306
" vis.vim:
" Function:	Perform an Ex command on a visual highlighted block (CTRL-V).
" Version:	19
" Date:		Jun 20, 2006
" GetLatestVimScripts: 1066 1 cecutil.vim
" GetLatestVimScripts: 1195 1 :AutoInstall: vis.vim
" Verse: For am I now seeking the favor of men, or of God? Or am I striving
" to please men? For if I were still pleasing men, I wouldn't be a servant
" of Christ. (Gal 1:10, WEB)

" ---------------------------------------------------------------------
"  Details: {{{1
" Requires: Requires 6.0 or later  (this script is a plugin)
"           Requires <cecutil.vim> (see :he vis-required)
"
" Usage:    Mark visual block (CTRL-V) or visual character (v),
"           press ':B ' and enter an Ex command [cmd].
"
"           ex. Use ctrl-v to visually mark the block then use
"                 :B cmd     (will appear as   :'<,'>B cmd )
"
"           ex. Use v to visually mark the block then use
"                 :B cmd     (will appear as   :'<,'>B cmd )
"
"           Command-line completion is supported for Ex commands.
"
" Note:     There must be a space before the '!' when invoking external shell
"           commands, eg. ':B !sort'. Otherwise an error is reported.
"
" Author:   Charles E. Campbell <NdrchipO@ScampbellPfamily.AbizM> - NOSPAM
"           Based on idea of Stefan Roemer <roemer@informatik.tu-muenchen.de>
"
" ------------------------------------------------------------------------------
" Initialization: {{{1
" Exit quickly when <Vis.vim> has already been loaded or
" when 'compatible' is set
if &cp || exists("g:loaded_vis")
  finish
endif
let s:keepcpo    = &cpo
let g:loaded_vis = "v19"
set cpo&vim

" ------------------------------------------------------------------------------
" Public Interface: {{{1
"  -range       : VisBlockCmd operates on the range itself
"  -com=command : Ex command and arguments
"  -nargs=+     : arguments may be supplied, up to any quantity
com! -range -nargs=+ -com=command    B  silent <line1>,<line2>call s:VisBlockCmd(<q-args>)
com! -range -nargs=* -com=expression S  silent <line1>,<line2>call s:VisBlockSearch(<q-args>)

" Suggested by Hari --
vn // <esc>/<c-r>=<SID>VisBlockSearch()<cr>
vn ?? <esc>?<c-r>=<SID>VisBlockSearch()<cr>

" ---------------------------------------------------------------------
"  Support Functions: {{{1
" ------------------------------------------------------------------------------
" VisBlockCmd: {{{2
fun! <SID>VisBlockCmd(cmd) range
"  call Dfunc("VisBlockCmd(cmd<".a:cmd.">")

  " retain and re-use same visual mode
  norm `<
  let curposn = SaveWinPosn(0)
  let vmode   = visualmode()
"  call Decho("vmode<".vmode.">")

  " save options which otherwise may interfere
  let keep_lz    = &lz
  let keep_fen   = &fen
  let keep_fo    = &fo
  let keep_ic    = &ic
  let keep_magic = &magic
  let keep_sol   = &sol
  let keep_ve    = &ve
  let keep_ww    = &ww
  set lz
  set magic
  set nofen
  set noic
  set nosol
  set ve=
  set ww=
  set fo=nroql2

  " Save any contents in register a
  let rega= @a

  if vmode == 'V'
"   call Decho("cmd<".a:cmd.">")
   exe "'<,'>".a:cmd
  else

   " Initialize so begcol<endcol for non-v modes
   let begcol   = s:VirtcolM1("<")
   let endcol   = s:VirtcolM1(">")
   if vmode != 'v'
    if begcol > endcol
     let begcol  = s:VirtcolM1(">")
     let endcol  = s:VirtcolM1("<")
    endif
   endif

   " Initialize so that begline<endline
   let begline  = a:firstline
   let endline  = a:lastline
   if begline > endline
    let begline = a:lastline
    let endline = a:firstline
   endif
"   call Decho('beg['.begline.','.begcol.'] end['.endline.','.endcol.']')

   " =======================
   " Modify Selected Region:
   " =======================
   " 1. delete selected region into register "a
"   call Decho("delete selected region into register a")
   norm! gv"ad

   " 2. put cut-out text at end-of-file
"   call Decho("put cut-out text at end-of-file")
   $
   pu_
   let lastline= line("$")
   silent norm! "ap
"   call Decho("reg-A<".@a.">")

   " 3. apply command to those lines
   let curline = line(".")
   ka
   $
"   call Decho("apply command<".a:cmd."> to those lines (curline=".line(".").")")
   exe curline.',$'.a:cmd

   " 4. visual-block select the modified text in those lines
"   call Decho("visual-block select modified text at end-of-file")
   exe lastline
   exe "norm! 0".vmode."G$\"ad"

   " 5. delete excess lines
"   call Decho("delete excess lines")
   silent exe lastline.',$d'

   " 6. put modified text back into file
"   call Decho("put modifed text back into file (beginning=".begline.".".begcol.")")
   exe begline
   if begcol > 1
	exe 'norm! '.begcol."\<bar>\"ap"
   elseif begcol == 1
	norm! 0"ap
   else
	norm! 0"aP
   endif

   " 7. attempt to restore gv -- this is limited, it will
   " select the same size region in the same place as before,
   " not necessarily the changed region
   let begcol= begcol+1
   let endcol= endcol+1
   silent exe begline
   silent exe 'norm! '.begcol."\<bar>".vmode
   silent exe endline
   silent exe 'norm! '.endcol."\<bar>\<esc>"
   silent exe begline
   silent exe 'norm! '.begcol."\<bar>"
  endif

  " restore register a and options
"  call Decho("restore register a, options, and window pos'n")
  let @a  = rega
  let &lz = keep_lz
  let &fen= keep_fen
  let &fo = keep_fo
  let &ic = keep_ic
  let &sol= keep_sol
  let &ve = keep_ve
  let &ww = keep_ww
  call RestoreWinPosn(curposn)

"  call Dret("VisBlockCmd")
endfun

" ------------------------------------------------------------------------------
" VisBlockSearch: {{{2
fun! <SID>VisBlockSearch(...) range
"  call Dfunc("VisBlockSearch() a:0=".a:0." lines[".a:firstline.",".a:lastline."]")
  let keepic= &ic
  set noic

  if a:0 >= 1 && strlen(a:1) > 0
   let pattern   = a:1
   let s:pattern = pattern
"   call Decho("a:0=".a:0.": pattern<".pattern.">")
  elseif exists("s:pattern")
   let pattern= s:pattern
  else
   let pattern   = @/
   let s:pattern = pattern
  endif
  let vmode= visualmode()

  " collect search restrictions
  let firstline  = line("'<")
  let lastline   = line("'>")
  let firstcolm1 = s:VirtcolM1("<")
  let lastcolm1  = s:VirtcolM1(">")
"  call Decho("1: firstline=".firstline." lastline=".lastline." firstcolm1=".firstcolm1." lastcolm1=".lastcolm1)

  if(firstline > lastline)
   let firstline = line("'>")
   let lastline  = line("'<")
   if a:0 >= 1
    norm! `>
   endif
  else
   if a:0 >= 1
    norm! `<
   endif
  endif
"  call Decho("2: firstline=".firstline." lastline=".lastline." firstcolm1=".firstcolm1." lastcolm1=".lastcolm1)

  if vmode != 'v'
   if firstcolm1 > lastcolm1
   	let tmp        = firstcolm1
   	let firstcolm1 = lastcolm1
   	let lastcolm1  = tmp
   endif
  endif
"  call Decho("3: firstline=".firstline." lastline=".lastline." firstcolm1=".firstcolm1." lastcolm1=".lastcolm1)

  let firstlinem1 = firstline  - 1
  let lastlinep1  = lastline   + 1
  let firstcol    = firstcolm1 + 1
  let lastcol     = lastcolm1  + 1
  let lastcolp1   = lastcol    + 1
"  call Decho("4: firstline=".firstline." lastline=".lastline." firstcolm1=".firstcolm1." lastcolp1=".lastcolp1)

  " construct search string
  if vmode == 'V'
   let srch= '\%(\%>'.firstlinem1.'l\%<'.lastlinep1.'l\)\&'
"   call Decho("V  srch: ".srch)
  elseif vmode == 'v'
   if firstline == lastline || firstline == lastlinep1
   	let srch= '\%(\%'.firstline.'l\%>'.firstcolm1.'v\%<'.lastcolp1.'v\)\&'
   else
    let srch= '\%(\%(\%'.firstline.'l\%>'.firstcolm1.'v\)\|\%(\%'.lastline.'l\%<'.lastcolp1.'v\)\|\%(\%>'.firstline.'l\%<'.lastline.'l\)\)\&'
   endif
"   call Decho("v  srch: ".srch)
  else
   let srch= '\%(\%>'.firstlinem1.'l\%>'.firstcolm1.'v\%<'.lastlinep1.'l\%<'.lastcolp1.'v\)\&'
"   call Decho("^v srch: ".srch)
  endif

  " perform search
  if a:0 <= 1
"   call Decho("Search forward: <".srch.pattern.">")
   call search(srch.pattern)
   let @/= srch.pattern

  elseif a:0 == 2
"   call Decho("Search backward: <".srch.pattern.">")
   call search(srch.pattern,a:2)
   let @/= srch.pattern
  endif

  " restore ignorecase
  let &ic= keepic

"  call Dret("VisBlockSearch <".srch.">")
  return srch
endfun

" ------------------------------------------------------------------------------
" VirtcolM1: usually a virtcol(mark)-1, but due to tabs this can be different {{{2
fun! s:VirtcolM1(mark)
"  call Dfunc("VirtcolM1(mark ".a:mark.")")
  let mark   = "'".a:mark

  if virtcol(mark) <= 1
"   call Dret("VirtcolM1 0")
   return 0
  endif

  if &ve == "block"
   " works around a ve=all vs ve=block difference with virtcol()
   set ve=all
"   call Decho("temporarily setting ve=all")
  endif

"  call Decho("exe norm! `".a:mark."h")
  exe "norm! `".a:mark."h"

  let vekeep = &ve
  let vc  = virtcol(".")
  let &ve = vekeep

"  call Dret("VirtcolM1 ".vc)
  return vc
endfun

let &cpo= s:keepcpo
unlet s:keepcpo
" ------------------------------------------------------------------------------
"  Modelines: {{{1
" vim: fdm=marker
plugin/cecutil.vim
464
" cecutil.vim : save/restore window position
"               save/restore mark position
"               save/restore selected user maps
"  Author:	Charles E. Campbell, Jr.
"  Version:	15e	ASTRO-ONLY
"  Date:	Apr 10, 2006
"
"  Saving Restoring Destroying Marks: {{{1
"       call SaveMark(markname)       let savemark= SaveMark(markname)
"       call RestoreMark(markname)    call RestoreMark(savemark)
"       call DestroyMark(markname)
"       commands: SM RM DM
"
"  Saving Restoring Destroying Window Position: {{{1
"       call SaveWinPosn()        let winposn= SaveWinPosn()
"       call RestoreWinPosn()     call RestoreWinPosn(winposn)
"		\swp : save current window/buffer's position
"		\rwp : restore current window/buffer's previous position
"       commands: SWP RWP
"
" GetLatestVimScripts: 1066 1 :AutoInstall: cecutil.vim
"
" You believe that God is one. You do well. The demons also {{{1
" believe, and shudder. But do you want to know, vain man, that
" faith apart from works is dead?  (James 2:19,20 WEB)

" Load Once: {{{1
if &cp || exists("g:loaded_cecutil")
 finish
endif
let g:loaded_cecutil = "v15e"
let s:keepcpo        = &cpo
set cpo&vim
"DechoVarOn

" -----------------------
"  Public Interface: {{{1
" -----------------------

"  Map Interface: {{{2
if !hasmapto('<Plug>SaveWinPosn')
 map <unique> <Leader>swp <Plug>SaveWinPosn
endif
if !hasmapto('<Plug>RestoreWinPosn')
 map <unique> <Leader>rwp <Plug>RestoreWinPosn
endif
nmap <silent> <Plug>SaveWinPosn		:call SaveWinPosn()<CR>
nmap <silent> <Plug>RestoreWinPosn	:call RestoreWinPosn()<CR>

" Command Interface: {{{2
com -bar -nargs=0 SWP	call SaveWinPosn()
com -bar -nargs=0 RWP	call RestoreWinPosn()
com -bar -nargs=1 SM	call SaveMark(<q-args>)
com -bar -nargs=1 RM	call RestoreMark(<q-args>)
com -bar -nargs=1 DM	call DestroyMark(<q-args>)

if v:version < 630
 let s:modifier= "sil "
else
 let s:modifier= "sil keepj "
endif

" ---------------------------------------------------------------------
" SaveWinPosn: {{{1
"    let winposn= SaveWinPosn()  will save window position in winposn variable
"    call SaveWinPosn()          will save window position in b:cecutil_winposn{b:cecutil_iwinposn}
"    let winposn= SaveWinPosn(0) will *only* save window position in winposn variable (no stacking done)
fun! SaveWinPosn(...)
"  call Dfunc("SaveWinPosn() a:0=".a:0)
  if line(".") == 1 && getline(1) == ""
"   call Dfunc("SaveWinPosn : empty buffer")
   return ""
  endif
  let so_keep   = &so
  let siso_keep = &siso
  let ss_keep   = &ss
  set so=0 siso=0 ss=0

  let swline    = line(".")
  let swcol     = col(".")
  let swwline   = winline() - 1
  let swwcol    = virtcol(".") - wincol()
  let savedposn = "call GoWinbufnr(".winbufnr(0).")|silent ".swline
  let savedposn = savedposn."|".s:modifier."norm! 0z\<cr>"
  if swwline > 0
   let savedposn= savedposn.":".s:modifier."norm! ".swwline."\<c-y>\<cr>"
  endif
  if swwcol > 0
   let savedposn= savedposn.":".s:modifier."norm! 0".swwcol."zl\<cr>"
  endif
  let savedposn = savedposn.":".s:modifier."call cursor(".swline.",".swcol.")\<cr>"

  " save window position in
  " b:cecutil_winposn_{iwinposn} (stack)
  " only when SaveWinPosn() is used
  if a:0 == 0
   if !exists("b:cecutil_iwinposn")
   	let b:cecutil_iwinposn= 1
   else
   	let b:cecutil_iwinposn= b:cecutil_iwinposn + 1
   endif
"   call Decho("saving posn to SWP stack")
   let b:cecutil_winposn{b:cecutil_iwinposn}= savedposn
  endif

  let &so   = so_keep
  let &siso = siso_keep
  let &ss   = ss_keep

"  if exists("b:cecutil_iwinposn")	 " Decho
"   call Decho("b:cecutil_winpos{".b:cecutil_iwinposn."}[".b:cecutil_winposn{b:cecutil_iwinposn}."]")
"  else                      " Decho
"   call Decho("b:cecutil_iwinposn doesn't exist")
"  endif                     " Decho
"  call Dret("SaveWinPosn [".savedposn."]")
  return savedposn
endfun

" ---------------------------------------------------------------------
" RestoreWinPosn: {{{1
fun! RestoreWinPosn(...)
"  call Dfunc("RestoreWinPosn() a:0=".a:0)
"  call Decho("getline(1)<".getline(1).">")
"  call Decho("line(.)=".line("."))
  if line(".") == 1 && getline(1) == ""
"   call Dfunc("RestoreWinPosn : empty buffer")
   return ""
  endif
  let so_keep   = &so
  let siso_keep = &siso
  let ss_keep   = &ss
  set so=0 siso=0 ss=0

  if a:0 == 0 || a:1 == ""
   " use saved window position in b:cecutil_winposn{b:cecutil_iwinposn} if it exists
   if exists("b:cecutil_iwinposn") && exists("b:cecutil_winposn{b:cecutil_iwinposn}")
"   	call Decho("using stack b:cecutil_winposn{".b:cecutil_iwinposn."}<".b:cecutil_winposn{b:cecutil_iwinposn}.">")
	try
     exe "silent! ".b:cecutil_winposn{b:cecutil_iwinposn}
	catch /^Vim\%((\a\+)\)\=:E749/
	 " ignore empty buffer error messages
	endtry
    " normally drop top-of-stack by one
    " but while new top-of-stack doesn't exist
    " drop top-of-stack index by one again
	if b:cecutil_iwinposn >= 1
	 unlet b:cecutil_winposn{b:cecutil_iwinposn}
	 let b:cecutil_iwinposn= b:cecutil_iwinposn - 1
	 while b:cecutil_iwinposn >= 1 && !exists("b:cecutil_winposn{b:cecutil_iwinposn}")
	  let b:cecutil_iwinposn= b:cecutil_iwinposn - 1
	 endwhile
	 if b:cecutil_iwinposn < 1
	  unlet b:cecutil_iwinposn
	 endif
	endif
   else
   	echohl WarningMsg
	echomsg "***warning*** need to SaveWinPosn first!"
	echohl None
   endif

  else	 " handle input argument
"   call Decho("using input a:1<".a:1.">")
   " use window position passed to this function
   exe "silent ".a:1
   " remove a:1 pattern from b:cecutil_winposn{b:cecutil_iwinposn} stack
   if exists("b:cecutil_iwinposn")
    let jwinposn= b:cecutil_iwinposn
    while jwinposn >= 1                     " search for a:1 in iwinposn..1
        if exists("b:cecutil_winposn{jwinposn}")    " if it exists
         if a:1 == b:cecutil_winposn{jwinposn}      " and the pattern matches
       unlet b:cecutil_winposn{jwinposn}            " unlet it
       if jwinposn == b:cecutil_iwinposn            " if at top-of-stack
        let b:cecutil_iwinposn= b:cecutil_iwinposn - 1      " drop stacktop by one
       endif
      endif
     endif
     let jwinposn= jwinposn - 1
    endwhile
   endif
  endif

  " seems to be something odd: vertical motions after RWP
  " cause jump to first column.  Following fixes that
  if wincol() > 1
   silent norm! hl
  elseif virtcol(".") < virtcol("$")
   silent norm! lh
  endif

  let &so   = so_keep
  let &siso = siso_keep
  let &ss   = ss_keep

"  call Dret("RestoreWinPosn")
endfun

" ---------------------------------------------------------------------
" GoWinbufnr: go to window holding given buffer (by number) {{{1
"   Prefers current window; if its buffer number doesn't match,
"   then will try from topleft to bottom right
fun! GoWinbufnr(bufnum)
"  call Dfunc("GoWinbufnr(".a:bufnum.")")
  if winbufnr(0) == a:bufnum
"   call Dret("GoWinbufnr : winbufnr(0)==a:bufnum")
   return
  endif
  winc t
  let first=1
  while winbufnr(0) != a:bufnum && (first || winnr() != 1)
  	winc w
	let first= 0
   endwhile
"  call Dret("GoWinbufnr")
endfun

" ---------------------------------------------------------------------
" SaveMark: sets up a string saving a mark position. {{{1
"           For example, SaveMark("a")
"           Also sets up a global variable, g:savemark_{markname}
fun! SaveMark(markname)
"  call Dfunc("SaveMark(markname<".a:markname.">)")
  let markname= a:markname
  if strpart(markname,0,1) !~ '\a'
   let markname= strpart(markname,1,1)
  endif
"  call Decho("markname=".markname)

  let lzkeep  = &lz
  set lz

  if 1 <= line("'".markname) && line("'".markname) <= line("$")
   let winposn               = SaveWinPosn(0)
   exe s:modifier."norm! `".markname
   let savemark              = SaveWinPosn(0)
   let g:savemark_{markname} = savemark
   let savemark              = markname.savemark
   call RestoreWinPosn(winposn)
  else
   let g:savemark_{markname} = ""
   let savemark              = ""
  endif

  let &lz= lzkeep

"  call Dret("SaveMark : savemark<".savemark.">")
  return savemark
endfun

" ---------------------------------------------------------------------
" RestoreMark: {{{1
"   call RestoreMark("a")  -or- call RestoreMark(savemark)
fun! RestoreMark(markname)
"  call Dfunc("RestoreMark(markname<".a:markname.">)")

  if strlen(a:markname) <= 0
"   call Dret("RestoreMark : no such mark")
   return
  endif
  let markname= strpart(a:markname,0,1)
  if markname !~ '\a'
   " handles 'a -> a styles
   let markname= strpart(a:markname,1,1)
  endif
"  call Decho("markname=".markname." strlen(a:markname)=".strlen(a:markname))

  let lzkeep  = &lz
  set lz
  let winposn = SaveWinPosn(0)

  if strlen(a:markname) <= 2
   if exists("g:savemark_{markname}") && strlen(g:savemark_{markname}) != 0
	" use global variable g:savemark_{markname}
"	call Decho("use savemark list")
	call RestoreWinPosn(g:savemark_{markname})
	exe "norm! m".markname
   endif
  else
   " markname is a savemark command (string)
"	call Decho("use savemark command")
   let markcmd= strpart(a:markname,1)
   call RestoreWinPosn(markcmd)
   exe "norm! m".markname
  endif

  call RestoreWinPosn(winposn)
  let &lz       = lzkeep

"  call Dret("RestoreMark")
endfun

" ---------------------------------------------------------------------
" DestroyMark: {{{1
"   call DestroyMark("a")  -- destroys mark
fun! DestroyMark(markname)
"  call Dfunc("DestroyMark(markname<".a:markname.">)")

  " save options and set to standard values
  let reportkeep= &report
  let lzkeep    = &lz
  set lz report=10000

  let markname= strpart(a:markname,0,1)
  if markname !~ '\a'
   " handles 'a -> a styles
   let markname= strpart(a:markname,1,1)
  endif
"  call Decho("markname=".markname)

  let curmod  = &mod
  let winposn = SaveWinPosn(0)
  1
  let lineone = getline(".")
  exe "k".markname
  d
  put! =lineone
  let &mod    = curmod
  call RestoreWinPosn(winposn)

  " restore options to user settings
  let &report = reportkeep
  let &lz     = lzkeep

"  call Dret("DestroyMark")
endfun

" ---------------------------------------------------------------------
" ListWinPosn:
"fun! ListWinPosn()                                                        " Decho 
"  if !exists("b:cecutil_iwinposn") || b:cecutil_iwinposn == 0             " Decho 
"   call Decho("nothing on SWP stack")                                     " Decho
"  else                                                                    " Decho
"   let jwinposn= b:cecutil_iwinposn                                       " Decho 
"   while jwinposn >= 1                                                    " Decho 
"    if exists("b:cecutil_winposn{jwinposn}")                              " Decho 
"     call Decho("winposn{".jwinposn."}<".b:cecutil_winposn{jwinposn}.">") " Decho 
"    else                                                                  " Decho 
"     call Decho("winposn{".jwinposn."} -- doesn't exist")                 " Decho 
"    endif                                                                 " Decho 
"    let jwinposn= jwinposn - 1                                            " Decho 
"   endwhile                                                               " Decho 
"  endif                                                                   " Decho
"endfun                                                                    " Decho 
"com! -nargs=0 LWP	call ListWinPosn()                                    " Decho 

" ---------------------------------------------------------------------
" SaveUserMaps: this function sets up a script-variable (s:restoremap) {{{1
"          which can be used to restore user maps later with
"          call RestoreUserMaps()
"
"          mapmode - see :help maparg for its list
"                    ex. "n" = Normal
"                    If the first letter is u, then unmapping will be done
"                    ex. "un" = Normal + unmapping
"          mapchx  - "<something>" handled as a single map item.
"                    ex. "<left>"
"                  - "string" a string of single letters which are actually
"                    multiple two-letter maps (using the maplead:
"                    maplead . each_character_in_string)
"                    ex. maplead="\" and mapchx="abc" saves mappings for
"                        \a, \b, and \c
"                    Of course, if maplead is "", then for mapchx="abc",
"                    mappings for a, b, and c are saved.
"                  - :something  handled as a single map item, w/o the ":"
"                    ex.  mapchx= ":abc" will save a mapping for "abc"
"          suffix  - a string unique to your plugin
"                    ex.  suffix= "DrawIt"
fun! SaveUserMaps(mapmode,maplead,mapchx,suffix)
"  call Dfunc("SaveUserMaps(mapmode<".a:mapmode."> maplead<".a:maplead."> mapchx<".a:mapchx."> suffix<".a:suffix.">)")

  if !exists("s:restoremap_{a:suffix}")
   " initialize restoremap_suffix to null string
   let s:restoremap_{a:suffix}= ""
  endif

  " set up dounmap: if 1, then save and unmap  (a:mapmode leads with a "u")
  "                 if 0, save only
  if a:mapmode =~ '^u'
   let dounmap= 1
   let mapmode= strpart(a:mapmode,1)
  else
   let dounmap= 0
   let mapmode= a:mapmode
  endif
 
  " save single map :...something...
  if strpart(a:mapchx,0,1) == ':'
   let amap= strpart(a:mapchx,1)
   if amap == "|" || amap == "\<c-v>"
    let amap= "\<c-v>".amap
   endif
   let s:restoremap_{a:suffix} = s:restoremap_{a:suffix}."|:silent! ".mapmode."unmap ".amap
   if maparg(amap,mapmode) != ""
    let maprhs= substitute(maparg(amap,mapmode),'|','<bar>','ge')
"	let maprhs= substitute(maprhs,'"<CR>',"\<cr>",'ge')
   	let s:restoremap_{a:suffix} = s:restoremap_{a:suffix}."|:".mapmode."map ".amap." ".maprhs
   endif
   if dounmap
    exe "silent! ".mapmode."unmap ".amap
   endif
 
  " save single map <something>
  elseif strpart(a:mapchx,0,1) == '<'
   let amap       = a:mapchx
   if amap == "|" || amap == "\<c-v>"
    let amap= "\<c-v>".amap
   endif
   let s:restoremap_{a:suffix} = s:restoremap_{a:suffix}."|silent! ".mapmode."unmap ".amap
   if maparg(a:mapchx,mapmode) != ""
    let maprhs= substitute(maparg(amap,mapmode),'|','<bar>','ge')
"	let maprhs= substitute(maprhs,'"<CR>',"\<cr>",'ge')
   	let s:restoremap_{a:suffix} = s:restoremap_{a:suffix}."|".mapmode."map ".amap." ".maprhs
   endif
   if dounmap
    exe "silent! ".mapmode."unmap ".amap
   endif
 
  " save multiple maps
  else
   let i= 1
   while i <= strlen(a:mapchx)
    let amap= a:maplead.strpart(a:mapchx,i-1,1)
	if amap == "|" || amap == "\<c-v>"
	 let amap= "\<c-v>".amap
	endif
    let s:restoremap_{a:suffix} = s:restoremap_{a:suffix}."|silent! ".mapmode."unmap ".amap
    if maparg(amap,mapmode) != ""
     let maprhs= substitute(maparg(amap,mapmode),'|','<bar>','ge')
"	 let maprhs= substitute(maprhs,'"<CR>',"\<cr>",'ge')
   	 let s:restoremap_{a:suffix} = s:restoremap_{a:suffix}."|".mapmode."map ".amap." ".maprhs
    endif
	if dounmap
     exe "silent! ".mapmode."unmap ".amap
	endif
    let i= i + 1
   endwhile
  endif
"  call Dret("SaveUserMaps : restoremap_".a:suffix.": ".s:restoremap_{a:suffix})
endfun

" ---------------------------------------------------------------------
" RestoreUserMaps: {{{1
"   Used to restore user maps saved by SaveUserMaps()
fun! RestoreUserMaps(suffix)
"  call Dfunc("RestoreUserMaps(suffix<".a:suffix.">)")
  if exists("s:restoremap_{a:suffix}")
   let s:restoremap_{a:suffix}= substitute(s:restoremap_{a:suffix},'|\s*$','','e')
   if s:restoremap_{a:suffix} != ""
"   	call Decho("exe ".s:restoremap_{a:suffix})
    exe "silent! ".s:restoremap_{a:suffix}
   endif
   unlet s:restoremap_{a:suffix}
  endif
"  call Dret("RestoreUserMaps")
endfun

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo

" ---------------------------------------------------------------------
"  Modelines: {{{1
" vim: ts=4 fdm=marker
doc/vis.txt
205
*vis.txt*	The Visual Block Tool				Jun 20, 2006

Author:  Charles E. Campbell, Jr.  <NdrchipO@ScampbellPfamily.AbizM>
	  (remove NOSPAM from Campbell's email first)
Copyright: (c) 2004-2006 by Charles E. Campbell, Jr.	*vis-copyright*
           The VIM LICENSE applies to vis.vim and vis.txt
           (see |copyright|) except use "vis" instead of "Vim"
	   No warranty, express or implied.  Use At-Your-Own-Risk.


==============================================================================
1. Contents					*vis* *vis-contents* *vis.vim*

	1. Contents......................: |vis-contents|
	2. Visual Block Manual...........: |vis-manual|
	3. Visual Block Search...........: |vis-srch|
	4. Required......................: |vis-required|
	5. Sorting Examples..............: |vis-sort|
	6. History.......................: |vis-history|


==============================================================================
2. Visual Block Manual			*visman* *vismanual* *vis-manual* *v_:B*

	Performs an arbitrary Ex command on a visual highlighted block.

	Mark visual block (CTRL-V) or visual character (v),
		press ':B ' and enter an Ex command [cmd].

		ex. Use ctrl-v to visually mark the block then use
			:B cmd     (will appear as   :'<,'>B cmd )

		ex. Use v to visually mark the block then use
			:B cmd     (will appear as   :'<,'>B cmd )

	Command-line completion is supported for Ex commands.

	There must be a space before the '!' when invoking external shell
	commands, eg. ':B !sort'. Otherwise an error is reported.

	Doesn't work as one might expect with Vim's ve option.  That's
	because ve=all ended up leaving unwanted blank columns, so the
	solution chosen was to have the vis function turn ve off temporarily.

	The script works by deleting the selected region into register "a.
	The register "a itself is first saved and later restored.  The text is
	then put at the end-of-file, modified by the user command, and then
	deleted back into register "a.  Any excess lines are removed, and the
	modified text is then put back into the text at its original
	location.

	Based on idea of Stefan Roemer <roemer@informatik.tu-muenchen.de>;
	the implementation and method has completely changed since the
	original.


==============================================================================
3. Visual Block Search				*vis-search* *vis-srch* *vis-S*

	Visual block search provides two ways to get visual-selection
	based searches.  Both these methods work well with :set hls
	and searching may be repeated with the n or N commands.
	
	Using // and ?? after a visual selection:
>
		ex. select region via V, v, or ctrl-v
		    //pattern
<
	    You'll actually get a long leader string of commands to restrict
	    searches to the requested visual block first.  You may then enter
	    the pattern afterwards.  For example, using "v" to select this
	    paragraph, you'll see something like: >

		/\%(\%(\%63l\%>12c\)\|\%(\%66l\%<51c\)\|\%(\%>63l\%<66l\)\)\&
<
	    You may enter whatever pattern you want after the \&, and the
	    pattern search will be restricted to the requested region.
	
	The "S" command in visual mode:
>
		ex. select region via V, v, or ctrl-v
		    :S pattern
<
	    The ":S pattern" will appear as ":'<,'>S pattern".  This
	    command will move the cursor to the next instance of the
	    pattern, restricted to the visually selected block.
	
	An "R" command was contemplated, but I currently see no way to
	get it to continue to search backwards with n and N commands.


==============================================================================
4. Required							*vis-required*

	Since the <vis.vim> function is a plugin, it uses several 6.0 (or
	later) features.  Please use a 6.0 or later version of vim.

	Starting with version 11, <vis.vim> required <cecutil.vim>.  It uses
	the SaveWinPosn() and RestoreWinPosn() functions therein.  You may get
	<cecutil.vim> from

		http://mysite.verizon.net/astronaut/vim/index.html#VimFuncs
		as "DrC's Utilities".


==============================================================================
5. Sorting Examples						*vis-sort*

	Assume we start with the following three lines: >

    	    one   two   three
    	    four  five  six
    	    seven eight nine
<
	Example 1: Use visual-block mode to select the center three
	words: ctrl-v select two/five/eight, then :'<,'>sort: >

    	    four  five  six
    	    one   two   three
    	    seven eight nine
<
	Note that the visual-block is ignored, other than as a way to
	select the three lines.  The resulting sorting is done on the
	three words "one/four/seven".

	(this example presumed that you're using vim 7.0; if you're using
	an earlier version vim, try  :'<,\> !sort  instead)

	Example 2: Using vis.vim's B command:
	Again, use visual-block mode to select the center
	three words: ctrl-v select two/five/eight, then :'<,'>B sort: >

    	    one   eight three
    	    four  five  six
    	    seven two   nine
<
	This operation sorts the selected three words (two/five/eight),
	leaving all characters outside the visual block alone.

	(this example presumed that you're using vim 7.0; if you're using
	an earlier version vim, try  :'<,\> !sort  instead)

	Example 3: Using vissort.vim's Vissort() function
	Use visual block mode to select the center three words;
	ctrl-v select two/five/eight, then :'<,'>Vissort: >

    	    seven eight nine
    	    four  five  six
    	    one   two   three
<
	This time, the entire lines are sorted, but the sorting is done
	based on the visual-block selected region (ie. two/five/eight).


==============================================================================
6. History						*vis-history* {{{1

    v19 : Jan 06, 2006  - small modification included to allow AlignMaps
                          maps to work (visual select, :B norm \somemap)
			- cecutil updated to use keepjumps
	  Jan 24, 2006  - works around formatoption setting
	  Jan 25, 2006  - uses SaveWinPosn(0) to avoid SWP stack use
    v18 : Jul 11, 2005  - vis.vim now works around a virtcol() behavior
                          difference between ve=all vs ve=block
    v17 : Apr 25, 2005  - vis.vim now uses cecutil (SaveWinPosn, etc) so the
                          tarball now includes a copy of cecutil.vim
    v16 : Feb 02, 2005  - fixed a bug with visual-block + S ; the first line
			  was being omitted in the search
	  Mar 01, 2005  - <q-args> used instead of '<args>'
	  Apr 13, 2005  - :'<,'>S plus v had a bug with one or two line
	                  selections (tnx to Vigil for pointing this out)
	  Apr 14, 2005  - set ignorecase caused visual-block searching
	                  to confuse visual modes "v" and "V"
    v15 : Feb 01, 2005  - includes some additions to the help
    v14 : Sep 28, 2004	- visual-block based searching now supported.  One
			  do this either with :'<,'>S pattern or with a / or ?
	  Jan 31, 2005  - fixed help file
    v13 : Jul 16, 2004	- folding commands added to source
			- GetLatestVimScript hook added for automatic updating
    v12 : Jun 14, 2004	- bugfix (folding interfered)
    v11 : May 18, 2004	- Included calls to SaveWinPosn() and RestoreWinPosn()
			  to prevent unwanted movement of the cursor and window.
			  As a result, <vis.vim> now requires <cecutil.vim>
			  (see |vis-required|).
    v10 : Feb 11, 2003	- bugfix (ignorecase option interfered with v)
     v9 : Sep 10, 2002	- bugfix (left Decho on, now commented out)
     v8 : Sep 09, 2002	- bugfix (first column problem)
     v7 : Sep 05, 2002	- bugfix (was forcing begcol<endcol for "v" mode)
     v6 : Jun 25, 2002	- bugfix (VirtcolM1 instead of virtcol()-1)
     v5 : Jun 21, 2002	- now supports character-visual mode (v) and
			  linewise-visual mode (V)
     v4 : Jun 20, 2002	- saves sol, sets nosol, restores sol
			- bugfix: 0 inserted: 0\<c-v>G$\"ad
			- Fixed double-loading (was commented
			  out for debugging purposes)
     v3 : Jun 20, 2002	- saves ve, unsets ve, restores ve
     v2 : Jun 19, 2002	- Charles Campbell's <vis.vim>
     v?   June 19, 2002	  Complete rewrite - <vis.vim> is now immune to
			  the presence of tabs and is considerably faster.
     v1 Epoch		- Stefan Roemer <roemer@informatik.tu-muenchen.de>
			  wrote the original <vis.vim>.

==============================================================================
Modelines: {{{1
vim:tw=78:ts=8:ft=help:fdm=marker
