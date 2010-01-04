" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
browser_launcher.vim	[[[1
521
"--------------------------------------------------------------------------
"
" Vim script to launch/control browsers
"
" Copyright ????-2009 Christian J. Robinson <heptite@gmail.com>
"
" Distributable under the terms of the GNU GPL.
"
" Currently supported browsers:
" Unix:
"  - Firefox  (remote [new window / new tab] / launch)  [1]
"  - Mozilla  (remote [new window / new tab] / launch)  [1]
"  - Netscape (remote [new window] / launch)            [1]
"  - Opera    (remote [new window / new tab] / launch)
"  - Lynx     (Under the current TTY if not running the GUI, or a new xterm
"              window if DISPLAY is set.)
"  - w3m      (Under the current TTY if not running the GUI, or a new xterm
"              window if DISPLAY is set.)
" MacOS:
"  - Firefox  (remote [new window / new tab] / launch)
"  - Opera    (remote [new window / new tab] / launch)
"  - Safari   (remote [new window / new tab] / launch)
"  - Default
"
" Windows:
"  None currently -- the HTML.vim script has mappings that runs system
"  commands directly.
"
" TODO:
"
"  - Support more browsers?
"    + links  (text browser)
"
"    Note: Various browsers such as galeon, nautilus, phoenix, &c use the
"    same HTML rendering engine as mozilla/firefox, so supporting them
"    isn't as important.
"
"  - Defaulting to lynx if the the GUI isn't available on Unix may be
"    undesirable.
"
"  - Support for Windows.
"
" BUGS:
"  * [1] On Unix, the remote control for firefox/mozilla/netscape will
"    probably default to firefox if more than one is running.
"
"  * On Unix, Since the commands to start the browsers are run in the
"    backgorund when possible there's no way to actually get v:shell_error,
"    so execution errors aren't actually seen when not issuing a command to
"    an already running browser.
"
"  * The code is a mess and mostly needs to be rethought.  Oh well.
"
"--------------------------------------------------------------------------

if v:version < 700
	finish
endif

command! -nargs=+ BERROR :echohl ErrorMsg | echomsg <q-args> | echohl None
command! -nargs=+ BMESG :echohl Todo | echo <q-args> | echohl None

function! s:ShellEscape(str) " {{{
	if exists('*shellescape')
		return shellescape(a:str)
	else
		return "'" . substitute(a:str, "'", "'\\\\''", 'g') . "'"
	endif
endfunction " }}}


if has('mac') || has('macunix')  " {{{1

	"BERROR Currently there's no browser control support for Macintosh.
	"BERROR See ":help html-author-notes"


	" The following code is provided by Israel Chauca Fuentes
	" <israelvarios()fastmail!fm>:

	function! s:MacAppExists(app) " {{{
		 silent! call system("/usr/bin/osascript -e 'get id of application \"" .
				\ a:app . "\"' 2>&1 >/dev/null")
		if v:shell_error
			return 0
		endif
		return 1
	endfunction " }}}

	function! s:UseAppleScript() " {{{
		return system("/usr/bin/osascript -e " .
			 \ "'tell application \"System Events\" to set UI_enabled " .
			 \ "to UI elements enabled' 2>/dev/null") ==? "true\n" ? 1 : 0
	endfunction " }}}

	function! OpenInMacApp(app, ...) " {{{
		if (! s:MacAppExists(a:app) && a:app !=? 'default')
			exec 'BERROR ' . a:app . " not found."
			return 0
		endif

		if a:0 >= 1 && a:0 <= 2
			let new = a:1
		else
			let new = 0
		endif

		let file = expand('%:p')

		" Can we open new tabs and windows?
		let use_AS = s:UseAppleScript()

		" Why we can't open new tabs and windows:
		let as_msg = "This feature utilizes the built-in Graphic User " .
				\ "Interface Scripting architecture of Mac OS X which is " .
				\ "currently disabled. You can activate GUI Scripting by " .
				\ "selecting the checkbox \"Enable access for assistive " .
				\ "devices\" in the Universal Access preference pane."

		if (a:app ==? 'safari') " {{{
			if new != 0 && use_AS
				if new == 2
					let torn = 't'
					BMESG Opening file in new Safari tab...
				else
					let torn = 'n'
					BMESG Opening file in new Safari window...
				endif
				let script = '-e "tell application \"safari\"" ' .
				\ '-e "activate" ' .
				\ '-e "tell application \"System Events\"" ' .
				\ '-e "tell process \"safari\"" ' .
				\ '-e "keystroke \"' . torn . '\" using {command down}" ' .
				\ '-e "end tell" ' .
				\ '-e "end tell" ' .
				\ '-e "delay 0.3" ' .
				\ '-e "tell window 1" ' .
				\ '-e ' . s:ShellEscape("set (URL of last tab) to \"" . file . "\"") . ' ' .
				\ '-e "end tell" ' .
				\ '-e "end tell" '

				let command = "/usr/bin/osascript " . script

			else
				if new != 0
					" Let the user know what's going on:
					exec 'BERROR ' . as_msg
				endif
				BMESG Opening file in Safari...
				let command = "/usr/bin/open -a safari " . s:ShellEscape(file)
			endif
		endif "}}}

		if (a:app ==? 'firefox') " {{{
			if new != 0 && use_AS
				if new == 2

					let torn = 't'
					BMESG Opening file in new Firefox tab...
				else

					let torn = 'n'
					BMESG Opening file in new Firefox window...
				endif
				let script = '-e "tell application \"firefox\"" ' .
				\ '-e "activate" ' .
				\ '-e "tell application \"System Events\"" ' .
				\ '-e "tell process \"firefox\"" ' .
				\ '-e "keystroke \"' . torn . '\" using {command down}" ' .
				\ '-e "delay 0.8" ' .
				\ '-e "keystroke \"l\" using {command down}" ' .
				\ '-e "keystroke \"a\" using {command down}" ' .
				\ '-e ' . s:ShellEscape("keystroke \"" . file . "\" & return") . " " .
				\ '-e "end tell" ' .
				\ '-e "end tell" ' .
				\ '-e "end tell" '

				let command = "/usr/bin/osascript " . script

			else
				if new != 0
					" Let the user know wath's going on:
					exec 'BERROR ' . as_msg

				endif
				BMESG Opening file in Firefox...
				let command = "/usr/bin/open -a firefox " . s:ShellEscape(file)
			endif
		endif " }}}

		if (a:app ==? 'opera') " {{{
			if new != 0 && use_AS
				if new == 2

					let torn = 't'
					BMESG Opening file in new Opera tab...
				else

					let torn = 'n'
					BMESG Opening file in new Opera window...
				endif
				let script = '-e "tell application \"Opera\"" ' .
				\ '-e "activate" ' .
				\ '-e "tell application \"System Events\"" ' .
				\ '-e "tell process \"opera\"" ' .
				\ '-e "keystroke \"' . torn . '\" using {command down}" ' .
				\ '-e "end tell" ' .
				\ '-e "end tell" ' .
				\ '-e "delay 0.5" ' .
				\ '-e ' . s:ShellEscape("set URL of front document to \"" . file . "\"") . " " .
				\ '-e "end tell" '

				let command = "/usr/bin/osascript " . script

			else
				if new != 0
					" Let the user know what's going on:
					exec 'BERROR ' . as_msg

				endif
				BMESG Opening file in Opera...
				let command = "/usr/bin/open -a opera " . s:ShellEscape(file)
			endif
		endif " }}}

		if (a:app ==? 'default')

			BMESG Opening file in default browser...
			let command = "/usr/bin/open " . s:ShellEscape(file)
		endif

		if (! exists('command'))

			exe 'BMESG Opening ' . substitute(a:app, '^.', '\U&', '') . '...'
			let command = "open -a " . a:app . " " . s:ShellEscape(file)
		endif

		call system(command . " 2>&1 >/dev/null")
	endfunction " }}}

elseif has('unix') " {{{1

	let s:Browsers = {}
	let s:BrowsersExist = 'fmnolw'

	let s:Browsers['f'] = ['firefox',  0]
	let s:Browsers['m'] = ['mozilla',  0]
	let s:Browsers['n'] = ['netscape', 0]
	let s:Browsers['o'] = ['opera',    0]
	let s:Browsers['l'] = ['lynx',     0]
	let s:Browsers['w'] = ['w3m',      0]

	for s:temp1 in keys(s:Browsers)
		let s:temp2 = system("which " . s:Browsers[s:temp1][0])
		if v:shell_error == 0
			let s:Browsers[s:temp1][1] = substitute(s:temp2, "\n$", '', '')
		else
			let s:BrowsersExist = substitute(s:BrowsersExist, s:temp1, '', 'g')
		endif
	endfor

	unlet s:temp1 s:temp2

	let s:NetscapeRemoteCmd = substitute(system("which mozilla-xremote-client"), "\n$", '', '')
	if v:shell_error != 0
		let s:NetscapeRemoteCmd = substitute(system("which netscape-remote"), "\n$", '', '')
	endif
	if v:shell_error != 0
		if s:Browsers['f'][1] != 0
			let s:NetscapeRemoteCmd = s:Browsers['f'][1]
		elseif s:Browsers['m'][1] != 0
			let s:NetscapeRemoteCmd = s:Browsers['m'][1]
		elseif s:Browsers['n'][1] != 0
			let s:NetscapeRemoteCmd = s:Browsers['n'][1]
		else
			"BERROR Can't set up remote-control preview code.
			"BERROR (netscape-remote/firefox/mozilla/netscape not installed?)
			"finish
			let s:NetscapeRemoteCmd = 'false'
		endif
	endif

elseif has('win32') || has('win64')  " {{{1

	BERROR Currently there's no browser control support for Windows.
	BERROR See ":help html-author-notes"
	
	"let s:Browsers = {}
	"let s:BrowsersExist = ''

	"if filereadable('C:\Program Files\Mozilla Firefox\firefox.exe')
	"	let s:Browsers['f'] = ['firefox', '"C:\Program Files\Mozilla Firefox\firefox.exe"']
	"	let s:BrowsersExist .= 'f'
	"endif

	"if s:Browsers['f'][1] != ''
	"	let s:NetscapeRemoteCmd = s:Browsers['f'][1]
	"endif

endif " }}}1


if exists("*LaunchBrowser") || exists("*OpenInMacApp")
	finish
endif

" LaunchBrowser() {{{1
"
" Usage:
"  :call LaunchBrowser({[nolmf]},{[012]},[url])
"    The first argument is which browser to launch:
"      f - Firefox
"      m - Mozilla
"      n - Netscape
"      o - Opera
"      l - Lynx
"      w - w3m
"
"      default - This launches the first browser that was actually found.
"
"    The second argument is whether to launch a new window:
"      0 - No
"      1 - Yes
"      2 - New Tab (or new window if the browser doesn't provide a way to
"                   open a new tab)
"
"    The optional third argument is an URL to go to instead of loading the
"    current file.
"
" Return value:
"  0 - Failure (No browser was launched/controlled.)
"  1 - Success
"
" A special case of no arguments returns a character list of what browsers
" were found.
function! LaunchBrowser(...)

	let err = 0

	if a:0 == 0
		return s:BrowsersExist
	elseif a:0 >= 2
		let which = a:1
		let new = a:2
	else
		let err = 1
	endif

	let file = 'file://' . expand('%:p')

	if a:0 == 3
		let file = a:3
	elseif a:0 > 3
		let err = 1
	endif

	if err
		exe 'BERROR E119: Wrong number of arguments for function: '
					\ . substitute(expand('<sfile>'), '^function ', '', '')
		return 0
	endif

	if which ==? 'default'
		let which = strpart(s:BrowsersExist, 0, 1)
	endif

	if s:BrowsersExist !~? which
		if exists('s:Browsers[which]')
			exe 'BERROR ' . s:Browsers[which][0] . ' not found'
		else
			exe 'BERROR Unknown browser ID: ' . which
		endif

		return 0
	endif

	if has('unix') && (! strlen($DISPLAY) || which ==? 'l') " {{{
		BMESG Launching lynx...

		if (has("gui_running") || new) && strlen($DISPLAY)
			let command='xterm -T Lynx -e lynx ' . s:ShellEscape(file) . ' &'
		else
			sleep 1
			execute "!lynx " . s:ShellEscape(file)

			if v:shell_error
				BERROR Unable to launch lynx.
				return 0
			endif
		endif
	endif " }}}

	if (which ==? 'w') " {{{
		BMESG Launching w3m...

		if (has("gui_running") || new) && strlen($DISPLAY)
			let command='xterm -T w3m -e w3m ' . s:ShellEscape(file) . ' &'
		else
			sleep 1
			execute "!w3m " . s:ShellEscape(file)

			if v:shell_error
				BERROR Unable to launch w3m.
				return 0
			endif
		endif
	endif " }}}

	if (which ==? 'o') " {{{
		if new == 2
			BMESG Opening new Opera tab...
			let command="sh -c \"trap '' HUP; " . s:Browsers[which][1] . " -remote 'openURL('" . s:ShellEscape(file) . "',new-page)' &\""
		elseif new
			BMESG Opening new Opera window...
			let command="sh -c \"trap '' HUP; " . s:Browsers[which][1] . " -remote 'openURL('" . s:ShellEscape(file) . "',new-window)' &\""
		else
			BMESG Sending remote command to Opera...
			let command="sh -c \"trap '' HUP; " . s:Browsers[which][1] . " " . s:ShellEscape(file) . " &\""
		endif
	endif " }}}

	" Find running instances firefox/mozilla/netscape:  {{{
	if has('unix')
		let FirefoxRunning = 0
		let MozillaRunning = 0
		let NetscapeRunning = 0

		let windows = system("xwininfo -root -children | egrep \"[Ff]irefox|[Nn]etscape|[Mm]ozilla\"; return 0")

		if windows =~? 'firefox'
			let FirefoxRunning = 1
		endif
		if windows =~? 'mozilla'
			let MozillaRunning = 1
		endif
		if windows =~? 'netscape'
			let NetscapeRunning = 1
		endif
	else
		" ... Make some assumptions:
		"let FirefoxRunning = 1
	endif  " }}}

	if (which ==? 'f') " {{{
		if ! FirefoxRunning
			BMESG Launching firefox, please wait...
			let command="sh -c \"trap '' HUP; " . s:Browsers[which][1] . " " . s:ShellEscape(file) . " &\""
		else
			if new == 2
				BMESG Opening new Firefox tab...
				let command=s:NetscapeRemoteCmd . " -remote 'openURL('" . s:ShellEscape(file) . "',new-tab)'"
			elseif new
				BMESG Opening new Firefox window...
				let command=s:NetscapeRemoteCmd . " -remote 'openURL('" . s:ShellEscape(file) . "',new-window)'"
			else
				BMESG Sending remote command to Firefox...
				let command=s:NetscapeRemoteCmd . " -remote 'openURL('" . s:ShellEscape(file) . "')'"
			endif
		endif
	endif " }}}

	if (which ==? 'm') " {{{
		if ! MozillaRunning
			BMESG Launching mozilla, please wait...
			let command="sh -c \"trap '' HUP; " . s:Browsers[which][1] . " " . s:ShellEscape(file) . " &\""
		else
			if new == 2
				BMESG Opening new Mozilla tab...
				let command=s:NetscapeRemoteCmd . " -remote 'openURL('" . s:ShellEscape(file) . "',new-tab)'"
			elseif new
				BMESG Opening new Mozilla window...
				let command=s:NetscapeRemoteCmd . " -remote 'openURL('" . s:ShellEscape(file) . "',new-window)'"
			else
				BMESG Sending remote command to Mozilla...
				let command=s:NetscapeRemoteCmd . " -remote 'openURL('" . s:ShellEscape(file) . "')'"
			endif
		endif
	endif " }}}

	if (which ==? 'n') " {{{
		if ! NetscapeRunning
			BMESG Launching netscape, please wait...
			let command="sh -c \"trap '' HUP; " . s:Browsers[which][1] . " " . s:ShellEscape(file) . " &\""
		else
			if new
				BMESG Opening new Netscape window...
				let command=s:NetscapeRemoteCmd . " -remote 'openURL('" . s:ShellEscape(file) . "',new-window)'"
			else
				BMESG Sending remote command to Netscape...
				let command=s:NetscapeRemoteCmd . " -remote 'openURL('" . s:ShellEscape(file) . "')'"
			endif
		endif
	endif " }}}

	if exists('l:command')

		if command =~ 'mozilla-xremote-client'
			let command = substitute(command, '-remote', '-a ' . s:Browsers[which][0], '')
		endif

		if ! has('unix')
			let command = substitute(command, "sh -c \"trap '' HUP; \\(.\\+\\) &\"", '\1', '')
			let command = substitute(command, '"\(openURL(.\+)\)"', '\1', '')
		endif

		call system(command)

		if has('unix') && v:shell_error
			exe 'BERROR Command failed: ' . command
			return 0
		endif

		return 1
	endif

	" Should never get here...if we do, something went wrong:
	BERROR Something went wrong, shouln't ever get here...
	return 0
endfunction " }}}1

" vim: set ts=2 sw=2 ai nu tw=75 fo=croq2 fdm=marker fdc=4:
bitmaps/Image.xpm	[[[1
35
/* XPM */
static char *Image[] = {
/* width height num_colors chars_per_pixel */
"    20    20        9            1",
/* colors */
". c #00373c",
"# c #008000",
"a c #333366",
"b c #808000",
"c c #808080",
"d c None",
"e c #ff6633",
"f c #ff66cc",
"g c #ffffff",
/* pixels */
"dddddddddddddddddddd",
"dddddddddddddddddddd",
"dddddddddddddddddddd",
"ddaaaaaaaaaaaaaaaadd",
"ddaggggggggggggggadd",
"ddagggggg##ggggggadd",
"ddaggggg###.gggggadd",
"ddaggggg.#.#gggggadd",
"ddagggggg.#gggfggadd",
"ddaggggggggggfcggadd",
"ddaggebebgggfcfggadd",
"ddaggbebeggfcfcggadd",
"ddaggebebgggfcfggadd",
"ddaggbebeggggfcggadd",
"ddagggggggggggfggadd",
"ddaggggggggggggggadd",
"ddaaaaaaaaaaaaaaaadd",
"dddddddddddddddddddd",
"dddddddddddddddddddd",
"dddddddddddddddddddd"};
bitmaps/Template.xpm	[[[1
34
/* XPM */
static char *Template[] = {
/* width height num_colors chars_per_pixel */
"    20    20        8            1",
/* colors */
". c #6666cc",
"# c #808080",
"a c #9999ff",
"b c None",
"c c #ff0000",
"d c #ff6633",
"e c #ffff00",
"f c #ffffff",
/* pixels */
"bbbbbbbbbbbbbbbbbbbb",
"bbbbbbbbbbbbbbbbbbbb",
"bbebbfbfbbebbbbbbbbb",
"bbbebebebebbbbbbbbbb",
"bbbbeedeef......bbbb",
"befeeeceeeefaf.f.bbb",
"bbeddcecd#bafa.ff.bb",
"beffeeceeeefaf....bb",
"bbbbeedeebfafafaf.bb",
"bbbebe.eaeafafafa.bb",
"bbfbbf.afafafafaf.bb",
"bbbbbe.eafafafafa.bb",
"bbbbbb.afafafafaf.bb",
"bbbbbb.fafafafafa.bb",
"bbbbbb.afafafafaf.bb",
"bbbbbb.fafafafafa.bb",
"bbbbbb.afafafafaf.bb",
"bbbbbb............bb",
"bbbbbbbbbbbbbbbbbbbb",
"bbbbbbbbbbbbbbbbbbbb"};
bitmaps/Litem.xpm	[[[1
25
/* XPM */
static char * ListItem_xpm[] = {
"20 20 2 1",
" 	c None",
".	c #000000",
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"    .               ",
"   ...              ",
"  .....  .........  ",
"   ...   .........  ",
"    .               ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    "};
bitmaps/Lynx.xpm	[[[1
46
/* XPM */
static char * Lynx_xpm[] = {
"22 19 24 1",
" 	c None",
".	c #000000",
"+	c #ADADAD",
"@	c #D6D6D6",
"#	c #EAEAEA",
"$	c #999999",
"%	c #FFFFFF",
"&	c #666666",
"*	c #707070",
"=	c #C1C1C1",
"-	c #CCCCCC",
";	c #A3A3A3",
">	c #515151",
",	c #7A7A7A",
"'	c #5B5B5B",
")	c #E0E0E0",
"!	c #F4F4F4",
"~	c #B7B7B7",
"{	c #3D3D3D",
"]	c #333333",
"^	c #848484",
"/	c #141414",
"(	c #282828",
"_	c #8E8E8E",
"               .      ",
"               +      ",
"              .+.     ",
"  ..          .@.     ",
"  .#.        .$@.     ",
"  .%&..  *$*.&=%-     ",
"  .-;>,....%'$>)#.    ",
"  .-!,~-{~%%%#;)#.    ",
"   .#]%#+%%%%%%%).    ",
"   .%#@=%%=$@%%%~.    ",
"   .%#'=%%%#&;!),.&   ",
"   .+#^#%%%*/,({{., ..",
"    .#{,@%@=%#*=%%..  ",
".. *.@)!%@#%%#%%%%. ..",
"  ..'$%@*+%@#+^$_.  * ",
".. .^=%%@$$*%#$+.     ",
"    ({.!##%%%...      ",
"      _..%%..         ",
"         ..           "};
bitmaps/Preview.xpm	[[[1
28
/* XPM */
static char * Preview_xpm[] = {
"24 20 5 1",
" 	c None",
".	c #000000",
"+	c #7B7B7B",
"@	c #BDBDBD",
"#	c #FFFFFF",
"                        ",
"                        ",
"        .......         ",
"      ...........       ",
"     .............      ",
"    .........+++...     ",
"   ......###..@@+...    ",
"  .......###...@@++..   ",
" ...........#...#@@+..  ",
"............#...@#@@+.. ",
"............#...#@#@+...",
"....#.......#...@#@@+.. ",
" ...#......#....#@@+..  ",
"  ...#....#....@@@+..   ",
"   ...####....@@@+..    ",
"    .........@@++..     ",
"     .......+++...      ",
"       ..........       ",
"                        ",
"                        "};
bitmaps/Blist.xpm	[[[1
29
/* XPM */
static char *Blist[] = {
/* width height num_colors chars_per_pixel */
"    20    20        3            1",
/* colors */
". c #000000",
"# c None",
"a c #ffffff",
/* pixels */
"####################",
"####################",
"####################",
"####.###############",
"###.a.##.........###",
"####.###############",
"####################",
"####################",
"####################",
"####.###############",
"###.a.##.........###",
"####.###############",
"####################",
"####################",
"####################",
"####.###############",
"###.a.##.........###",
"####.###############",
"####################",
"####################"};
bitmaps/Link.xpm	[[[1
30
/* XPM */
static char *Link[] = {
/* width height num_colors chars_per_pixel */
"20 20 4 1",
/* colors */
"a	c None",
".	c #333366",
"#	c #6666cc",
"b	c #ffffff",
/* pixels */
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaa..aaaa",
"aaaaaaaaaaaaa.ab.aaa",
"aaaaaaaaa....ab#.aaa",
"aaaaaaaa.ab.ab#.aaaa",
"aaaaaaa.ab.ab#.aaaaa",
"aaaaaa.ab..##..aaaaa",
"aaaaa.ab.aa..a.aaaaa",
"aaaa.ab.aab.ab.aaaaa",
"aaaa.b..ab.ab.aaaaaa",
"aaaa..aa..ab.aaaaaaa",
"aaaa.ab#.ab.aaaaaaaa",
"aaa.ab#.ab.aaaaaaaaa",
"aaa.b#....aaaaaaaaaa",
"aaa...aaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa"};
bitmaps/Browser.xpm	[[[1
28
/* XPM */
static char * Browser_xpm[] = {
"20 20 5 1",
" 	c None",
".	c #FFFFFF",
"+	c #CCFFFF",
"@	c #009933",
"#	c #000000",
"       ######       ",
"     ##@@@@@@##     ",
"   ##.@...@...@##   ",
"  #@@..@@@@@@@.@@#  ",
"  #.@.@@..@@@@@.@#  ",
" #@.@@.@.@.@.@.@.@# ",
" #@@@..@@.@..@..@.# ",
"#@..@.@..@@..@..@@@#",
"#@..@@...@@.@.@.@@.#",
"#@..@@..@..@@@@@.@.#",
"#@.@@.@@...@..@..@.#",
"#@@@...@...@..@..@.#",
"#@@....@@@@@..@..@@#",
" #@@..@...@@@@@@@@# ",
" #..@@@...@...@..@# ",
"  #..@@...@...@..#  ",
"  #..@.@@@@...@@@#  ",
"   ##@...@@@@@@##   ",
"     ##..@...##     ",
"       ######       "};
bitmaps/Nlist.xpm	[[[1
28
/* XPM */
static char *Nlist[] = {
/* width height num_colors chars_per_pixel */
"    20    20        2            1",
/* colors */
". c #000000",
"# c None",
/* pixels */
"####################",
"####################",
"###.################",
"##..################",
"###.#####.........##",
"##...#.#############",
"####################",
"####################",
"##..################",
"####.###############",
"###.#####.........##",
"##...#.#############",
"####################",
"####################",
"##...###############",
"###.################",
"####.####.........##",
"##..##.#############",
"####################",
"####################"};
bitmaps/Italic.xpm	[[[1
28
/* XPM */
static char *Italic[] = {
/* width height num_colors chars_per_pixel */
"    20    20        2            1",
/* colors */
". c #333366",
"# c None",
/* pixels */
"####################",
"####################",
"####################",
"##############.#####",
"#############..#####",
"#############..#####",
"############...#####",
"###########.#..#####",
"##########.##..#####",
"##########.##..#####",
"#########.###..#####",
"########.####..#####",
"########.......#####",
"#######.#####..#####",
"######.######..#####",
"#####.#######..#####",
"###.....###......###",
"####################",
"####################",
"####################"};
bitmaps/w3m.xpm	[[[1
33
/* XPM */
static char * W3m_xpm[] = {
"20 20 10 1",
" 	c None",
".	c #FF0000",
"+	c #00FF00",
"@	c #679900",
"#	c #FB0400",
"$	c #0300FC",
"%	c #0600F9",
"&	c #0000FF",
"*	c #009F60",
"=	c #0005FA",
"         .          ",
"         ..         ",
"        ... ..      ",
"        .. ....     ",
"        .......     ",
" ++++   ....... ..  ",
" ++++++@#.. ......  ",
"    ++++ .  .....   ",
"  ++++++    ....    ",
" ++++        ..     ",
" +++++       $%     ",
"  ++++++    &&&&    ",
"    ++++ &  &&&&&   ",
" ++++++*=&& &&&&&&  ",
" ++++   &&&&&& &&&  ",
"        &&&&&&&     ",
"        && &&&&     ",
"        &&  &&      ",
"         &&         ",
"         &          "};
bitmaps/Break.xpm	[[[1
25
/* XPM */
static char * Break_xpm[] = {
"20 20 2 1",
" 	c None",
".	c #000000",
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"               ..   ",
"               ..   ",
"               ..   ",
"     .         ..   ",
"    ..         ..   ",
"   ..............   ",
"  ...............   ",
"   ..............   ",
"    ..              ",
"     .              ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    "};
bitmaps/Netscape.xpm	[[[1
35
/* XPM */
static char *netscape[] = {
/* width height num_colors chars_per_pixel */
"    20    20        9            1",
/* colors */
". c #ffff00",
"# c #c0c0c0",
"a c #c00000",
"b c #a0a0a4",
"c c #808080",
"d c #800000",
"e c None",
"f c #0000c0",
"g c #000000",
/* pixels */
"eeeeeeeeeeeeeeeeeeee",
"eeeeeeeeeeeeeeeeeeee",
"eefffffffgfffffffgee",
"eeffggfff#fffggfgeee",
"eeff#dggg#gggd#geeee",
"eefff#b..#..b#geeeee",
"eefff#.ag#ga#geeeeee",
"eeffb#a#g#g#a#ceeeee",
"eeff#dgf###gedceeeee",
"ee##...##.#####ccgee",
"eegg#gda###adg#gggee",
"eeff.gf#g#gceg.eeeee",
"eeffd##gg#gec#deeeee",
"eefff.bgd#dgbceeeeee",
"eeff#ba.###.abceeeee",
"eef#bgegc#cgegbceeee",
"eefgceeed#deeeggeeee",
"eegeeeeeegeeeeeeeeee",
"eeeeeeeeeeeeeeeeeeee",
"eeeeeeeeeeeeeeeeeeee"};
bitmaps/Opera.xpm	[[[1
28
/* XPM */
static char * Opera_xpm[] = {
"20 20 5 1",
" 	c None",
".	c #000000",
"+	c #FF0000",
"@	c #7F7F7F",
"#	c #999999",
"                    ",
"                    ",
"                    ",
"            ....    ",
"           .++++.   ",
"          .+.  .+.  ",
"         .++.  .++. ",
"         .+.    .+. ",
"  @#@@@@.++.    .++.",
" @@@   @.++.#   .++.",
"@@@@    .++.#@  .++.",
"@@@@@   .++.@@@#.++.",
" #@@@@  .++.#@@#.++.",
" @#@@@@ .++.@@@@.++.",
"  @@@@@@ .+.  #@.+. ",
"   #@#@@@.++. #.++. ",
"     @@@@@.+.  .+.  ",
"       @@#@.++++.   ",
"          @@....    ",
"                    "};
bitmaps/Mozilla.xpm	[[[1
26
/* XPM */
static char * Mozilla_xpm[] = {
"20 20 3 1",
" 	c None",
".	c #000000",
"+	c #FF0000",
"                    ",
"                    ",
"      .... ...      ",
"    ..++++.....     ",
"   ..++..+..+..     ",
"  ...++.+.++....    ",
" ....+++..++++++..  ",
"  ..++++++++.+++++..",
"....++.++++...++++..",
"  ..++..+++.....+++.",
" ...+++.++++++......",
"  ...+++...+..+++.. ",
"  ...+++++... ...   ",
"   ..+++++..        ",
"   ..++++..         ",
"    ..+++..         ",
"      ....          ",
"                    ",
"                    ",
"                    "};
bitmaps/Underline.xpm	[[[1
29
/* XPM */
static char *Underline[] = {
/* width height num_colors chars_per_pixel */
"    20    20        3            1",
/* colors */
". c #222222",
"# c #333366",
"a c None",
/* pixels */
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaa#aaaaaaaaa",
"aaaaaaaaa###aaaaaaaa",
"aaaaaaaaa###aaaaaaaa",
"aaaaaaaa#####aaaaaaa",
"aaaaaaaa#a###aaaaaaa",
"aaaaaaa##aa###aaaaaa",
"aaaaaaa#aaa###aaaaaa",
"aaaaaa##aaaa###aaaaa",
"aaaaaa#aaaaa###aaaaa",
"aaaaa###########aaaa",
"aaaaa#aaaaaaa###aaaa",
"aaaa##aaaaaaaa###aaa",
"aaa###aaaaaaaa####aa",
"aa#####aaaaa#######a",
"aaaaaaaaaaaaaaaaaaaa",
"aa.................a",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa"};
bitmaps/Target.xpm	[[[1
29
/* XPM */
static char *Target[] = {
/* width height num_colors chars_per_pixel */
"    20    20        3            1",
/* colors */
". c #000080",
"a c None",
"b c #ff0000",
/* pixels */
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaabaaaa...aaaaaaa",
"aaaabbbaba....aaaaaa",
"aaaaabbbbaaa...aaaaa",
"aaaaaabbba.aa...aaaa",
"aaaaabbbbaa.aa..aaaa",
"aaaaaaaaa..a.a..aaaa",
"aaaa..a.a..a.a..aaaa",
"aaaa..aa.aa.aa..aaaa",
"aaaa...aa..aa...aaaa",
"aaaaa...aaaa...aaaaa",
"aaaaaa........aaaaaa",
"aaaaaaa......aaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa"};
bitmaps/Bold.xpm	[[[1
28
/* XPM */
static char *Bold[] = {
/* width height num_colors chars_per_pixel */
"    20    20        2            1",
/* colors */
". c #333366",
"# c None",
/* pixels */
"####################",
"####################",
"####################",
"#########..#########",
"#########..#########",
"########....########",
"########....########",
"#######......#######",
"#######......#######",
"######..##....######",
"######..##....######",
"#####..####....#####",
"#####..####....#####",
"####............####",
"####..######....####",
"###..########....###",
"##...########....###",
"#.....#####........#",
"####################",
"####################"};
bitmaps/Firefox.xpm	[[[1
74
/* XPM */
static char * Firefox_xpm[] = {
"20 20 51 1",
" 	c None",
".	c #111C42",
"+	c #621F36",
"@	c #3A76A2",
"#	c #4E6E7E",
"$	c #F8DD11",
"%	c #657B81",
"&	c #274161",
"*	c #F4B41B",
"=	c #6A163E",
"-	c #6A321E",
";	c #8E8B63",
">	c #1E69A5",
",	c #ACA270",
"'	c #BA300F",
")	c #9E7E38",
"!	c #8E553A",
"~	c #9A9242",
"{	c #C4450F",
"]	c #2D8FCD",
"^	c #DD7319",
"/	c #4E5E75",
"(	c #9A5222",
"_	c #AE8E5A",
":	c #F9D744",
"<	c #860E2A",
"[	c #D1A737",
"}	c #A26A46",
"|	c #E8961C",
"1	c #367AB2",
"2	c #419CD0",
"3	c #CB5317",
"4	c #1D518A",
"5	c #AE8222",
"6	c #2779B4",
"7	c #9B0F1B",
"8	c #EECA6E",
"9	c #FCF258",
"0	c #F0A61F",
"a	c #10366C",
"b	c #E4891C",
"c	c #37A0DC",
"d	c #6E5E48",
"e	c #E1984B",
"f	c #D6641A",
"g	c #DF7F1F",
"h	c #F7DE72",
"i	c #5E3837",
"j	c #B6160D",
"k	c #F8C51E",
"l	c #1D6099",
"                    ",
"      >66]>>#       ",
"    44>6]c]l4%[k    ",
"  gd.&}_1cc@>d[k*   ",
" 3^e[_g/1]6]2l&5k*h ",
" ge0|gfd%2ccc2>450: ",
" e|bbg^fg%ccc]2];0: ",
"0bbbg^ge/6]66>]6~:$ ",
"ebbb^^b[4]]>ll6>~h:*",
"|bb^3ji&46]6l44#[$:*",
"fg^^''!4>61144a;*$k8",
"'^^^'{f5}^b,4aa;kkh ",
" 3^^ff3{{(-...d[k:h ",
" '^^^^f3+....i^kk98 ",
" 7{^^^^^f(ii!^^|99  ",
"  j'fff^^^g^gf^$$[  ",
"   jj''{ffff^g*$[   ",
"    jjjjjj{{fg|g    ",
"     <7jjj''{}      ",
"        ===         "};
bitmaps/Table.xpm	[[[1
31
/* XPM */
static char *Table[] = {
/* width height num_colors chars_per_pixel */
"    20    20        5            1",
/* colors */
"- c None",
". c #333366",
"# c #9999ff",
"a c #c0c0c0",
"b c #ffffff",
/* pixels */
"--------------------",
"--------------------",
"--------------------",
"--bbbbbbbbbbbbbbb.--",
"--baaaaaaaaaaaaaa.--",
"--ba...a...a...aa.--",
"--ba.#ba.#ba.#baa.--",
"--ba.#ba.#ba.#baa.--",
"--ba.#ba.#ba.#baa.--",
"--babbbabbbabbbaa.--",
"--baaaaaaaaaaaaaa.--",
"--ba...a...a...aa.--",
"--ba.#ba.#ba.#baa.--",
"--ba.#ba.#ba.#baa.--",
"--ba.#ba.#ba.#baa.--",
"--babbbabbbabbbaa.--",
"--baaaaaaaaaaaaaa.--",
"--................--",
"--------------------",
"--------------------"};
bitmaps/Hline.xpm	[[[1
30
/* XPM */
static char *Hline[] = {
/* width height num_colors chars_per_pixel */
"    20    20        4            1",
/* colors */
". c #333366",
"# c #6666cc",
"a c None",
"b c #ffffff",
/* pixels */
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"a.................#a",
"a##################a",
"abbbbbbbbbbbbbbbbb#a",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa",
"aaaaaaaaaaaaaaaaaaaa"};
bitmaps/IE.xpm	[[[1
95
/* XPM */
static char * IE_xpm[] = {
"20 20 72 1",
" 	c None",
".	c #000000",
"+	c #808000",
"@	c #000080",
"#	c #008080",
"$	c #C0C0C0",
"%	c #C0DCC0",
"&	c #161616",
"*	c #222222",
"=	c #292929",
"-	c #555555",
";	c #4D4D4D",
">	c #393939",
",	c #EFD6C6",
"'	c #E7E7D6",
")	c #ADA990",
"!	c #000033",
"~	c #333333",
"{	c #666633",
"]	c #999933",
"^	c #000066",
"/	c #003366",
"(	c #333366",
"_	c #336666",
":	c #666666",
"<	c #999966",
"[	c #CC9966",
"}	c #99CC66",
"|	c #CCCC66",
"1	c #FFCC66",
"2	c #000099",
"3	c #333399",
"4	c #006699",
"5	c #336699",
"6	c #669999",
"7	c #CC9999",
"8	c #99CC99",
"9	c #CCCC99",
"0	c #FFCC99",
"a	c #FFFF99",
"b	c #003399",
"c	c #3333CC",
"d	c #0066CC",
"e	c #3366CC",
"f	c #666699",
"g	c #0099CC",
"h	c #3399CC",
"i	c #6699CC",
"j	c #99CCCC",
"k	c #FFFFCC",
"l	c #0033CC",
"m	c #0066FF",
"n	c #3366FF",
"o	c #6666CC",
"p	c #0099FF",
"q	c #3399FF",
"r	c #00CCFF",
"s	c #33CCFF",
"t	c #66CCFF",
"u	c #33FFFF",
"v	c #99FFFF",
"w	c #CCFFFF",
"x	c #66FFFF",
"y	c #5F5F5F",
"z	c #777777",
"A	c #969696",
"B	c #B2B2B2",
"C	c #A0A0A4",
"D	c #808080",
"E	c #FFFF00",
"F	c #0000FF",
"G	c #FFFFFF",
"                    ",
"                    ",
"             FFFF   ",
"        FFFFFF   F  ",
"      @FFFFFFF@  F  ",
"     @FFEFFFFFF@    ",
"    @@+EFF@@FFFF@   ",
"    @+EFFF  .FFF@   ",
"   @+EFFF    .FFF@  ",
"   +EFFFFFFFFFFFF@  ",
"  +E+FFFF@@@@@@@@@  ",
"  + F@FFF           ",
"  ++F@FFF    .FFF@  ",
"  +FF@@FFFDD.FFFF@  ",
"  +F .@@FFFFFFFF@   ",
"  +F  ..@@FFFF@@    ",
"   FF  F......      ",
"    FFF             ",
"                    ",
"                    "};
bitmaps/Paragraph.xpm	[[[1
25
/* XPM */
static char * Paragraph_xpm[] = {
"20 20 2 1",
" 	c None",
".	c #000000",
"                    ",
"                    ",
"                    ",
"       .......      ",
"      ...  .        ",
"     ....  .        ",
"     ....  .        ",
"     ....  .        ",
"      ...  .        ",
"       ..  .        ",
"        .  .        ",
"        .  .        ",
"        .  .        ",
"        .  .        ",
"        .  .        ",
"        .  .        ",
"        .  .        ",
"                    ",
"                    ",
"                    "};
ftplugin/html/HTML.vim	[[[1
3276
" ---- Author & Copyright: ---------------------------------------------- {{{1
"
" Author:      Christian J. Robinson <heptite@gmail.com>
" URL:         http://www.infynity.spodzone.com/vim/HTML/
" Last Change: September 19, 2009
" Version:     0.36.1
" Original Concept: Doug Renze
"
"
" The original Copyright goes to Doug Renze, although nearly all of his
" efforts have been modified in this implementation.  My changes and additions
" are Copyrighted by me, on the dates marked in the ChangeLog.
"
" (Doug Renze has authorized me to place the original "code" under the GPL.)
"
" ----------------------------------------------------------------------------
"
" This program is free software; you can redistribute it and/or modify it
" under the terms of the GNU General Public License as published by the Free
" Software Foundation; either version 2 of the License, or (at your option)
" any later version.
"
" This program is distributed in the hope that it will be useful, but WITHOUT
" ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
" FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
" more details.
"
" ---- Original Author's Notes: ----------------------------------------------
"
" HTML Macros
"        I wrote these HTML macros for my personal use.  They're
"        freely-distributable and freely-modifiable.
"
"        If you do make any major additions or changes, or even just
"        have a suggestion for improvement, feel free to let me
"        know.  I'd appreciate any suggestions.
"
"        Credit must go to Eric Tilton, Carl Steadman and Tyler
"        Jones for their excellent book "Web Weaving" which was
"        my primary source.
"
"        Doug Renze
"
" ---- TODO: ------------------------------------------------------------ {{{1
"
" - Specific browser mappings for Win32 with "start <browser> ..." ?
" - Find a way to make "gv" after executing a visual mapping re-select the
"   right text.  (Currently my extra code that wraps around the visual
"   mappings can tweak the selected area significantly.)
"   + This should probably exclude the newly created tags, so things like
"     visual selection ;ta, then gv and ;tr, then gv and ;td work.
" - Add :HTMLmappingsreload/html/xhtml to the HTML menu?
"
" ---- RCS Information: ------------------------------------------------- {{{1
" $Id: HTML.vim,v 1.210 2009/09/19 19:43:45 infynity Exp $
" ----------------------------------------------------------------------- }}}1

" ---- Initialization: -------------------------------------------------- {{{1

if v:version < 700
  echoerr "HTML.vim no longer supports Vim versions prior to 7."
  sleep 2
  finish
"elseif v:version < 700
"  let s:tmp =
"    \ "The HTML macros support for Vim versions prior to 7\n" .
"    \ "will be abandoned in future versions.\n\n" .
"    \ "You should seriously consider upgrading your version of Vim."
"  call confirm(s:tmp, "&Dismiss", 1, 'Warning')
"  unlet s:tmp
endif

" Save cpoptions and remove some junk that will throw us off (reset at the end
" of the script):
let s:savecpo = &cpoptions
set cpoptions&vim

let s:doing_internal_html_mappings = 1

if ! exists("b:did_html_mappings_init")
let b:did_html_mappings_init = 1

setlocal matchpairs+=<:>

" ---- Init Functions: -------------------------------------------------- {{{2

" s:BoolVar()  {{{3
"
" Given a string, test to see if a variable by that string name exists, and if
" so, whether it's set to 1|true|yes / 0|false|no   (Actually, anything not
" listed here also returns as 1.)
"
" Arguments:
"  1 - String:  The name of the variable to test (not its value!)
" Return Value:
"  1/0
"
" Limitations:
"  This /will not/ work on function-local variable names.
function! s:BoolVar(var)
  if a:var =~ '^[bgstvw]:'
    let var = a:var
  else
    let var = 'g:' . a:var
  endif

  if s:IsSet(var)
    execute "let varval = " . var
    return s:Bool(varval)
  else
    return 0
  endif
endfunction

" s:Bool() {{{3
"
" Helper to s:BoolVar() -- Test the string passed to it and return true/false
" based on that string.
"
" Arguments:
"  1 - String:  1|true|yes / 0|false|no
" Return Value:
"  1/0
function! s:Bool(str)
  return a:str !~? '^no$\|^false$\|^0$\|^$'
endfunction

" SetIfUnset()  {{{3
"
" Set a variable if it's not already set.
"
" Arguments:
"  1       - String:  The variable name
"  2 ... N - String:  The default value to use, "-" for the null string
" Return Value:
"  0  - The variable already existed
"  1  - The variable didn't exist and was set
"  -1 - An error occurred
function! SetIfUnset(var, ...)
  if a:var =~ '^[bgstvw]:'
    let var = a:var
  else
    let var = 'g:' . a:var
  endif

  if a:0 == 0
    echohl ErrorMsg
    echomsg "E119: Not enough arguments for function: SetIfUnset"
    echohl None
    return -1
  else
    let val = join(a:000, ' ')
  endif

  if ! s:IsSet(var)
    if val == "-"
      execute "let " . var . "= \"\""
    else
      execute "let " . var . "= val"
    endif
    return 1
  endif
  return 0
endfunction

" s:IsSet() {{{3
"
" Given a string, test to see if a variable by that string name exists.
"
" Arguments:
"  1 - String:  The variable name
" Return Value:
"  1/0
function! s:IsSet(str)
  execute "let varisset = exists(\"" . a:str . "\")"
  return varisset
endfunction  "}}}3

" ----------------------------------------------------------------------- }}}2

command! -nargs=+ SetIfUnset call SetIfUnset(<f-args>)

SetIfUnset g:html_bgcolor           #FFFFFF
SetIfUnset g:html_textcolor         #000000
SetIfUnset g:html_linkcolor         #0000EE
SetIfUnset g:html_alinkcolor        #FF0000
SetIfUnset g:html_vlinkcolor        #990066
SetIfUnset g:html_tag_case          uppercase
SetIfUnset g:html_map_leader        ;
SetIfUnset g:html_map_entity_leader &
SetIfUnset g:html_default_charset   iso-8859-1
" No way to know sensible defaults here so just make sure the
" variables are set:
SetIfUnset g:html_authorname  -
SetIfUnset g:html_authoremail -

if g:html_map_entity_leader ==# g:html_map_leader
  echohl ErrorMsg
  echomsg 'ERROR! "g:html_map_entity_leader" and "g:html_map_leader" have the same value!'
  echomsg '       Resetting "g:html_map_entity_leader" to "&".'
  echohl None
  sleep 2
  let g:html_map_entity_leader = '&'
endif

if exists('b:html_tag_case')
  let b:html_tag_case_save = b:html_tag_case
endif

" Detect whether to force uppper or lower case:  {{{2
if &filetype ==? "xhtml"
      \ || s:BoolVar('g:do_xhtml_mappings')
      \ || s:BoolVar('b:do_xhtml_mappings')
  let b:do_xhtml_mappings = 1
else
  let b:do_xhtml_mappings = 0

  if s:BoolVar('g:html_tag_case_autodetect')
        \ && (line('$') != 1 || getline(1) != '')

    let s:found_upper = search('\C<\(\s*/\)\?\s*\u\+\_[^<>]*>', 'wn')
    let s:found_lower = search('\C<\(\s*/\)\?\s*\l\+\_[^<>]*>', 'wn')

    if s:found_upper && ! s:found_lower
      let b:html_tag_case = 'uppercase'
    elseif ! s:found_upper && s:found_lower
      let b:html_tag_case = 'lowercase'
    endif

    unlet s:found_upper s:found_lower
  endif
endif

if s:BoolVar('b:do_xhtml_mappings')
  let b:html_tag_case = 'lowercase'
endif
" }}}2

call SetIfUnset('b:html_tag_case', g:html_tag_case)

let s:thisfile = expand("<sfile>:p")
" ----------------------------------------------------------------------------


" ---- Functions: ------------------------------------------------------- {{{1

if ! exists("g:did_html_functions")
let g:did_html_functions = 1

" HTMLencodeString()  {{{2
"
" Encode the characters in a string into their HTML &#...; representations.
"
" Arguments:
"  1 - String:  The string to encode.
"  2 - String:  Optional, whether to decode rather than encode the string:
"                d/decode: Decode the &#...; elements of the provided string
"                anything else: Encode the string (default)
" Return Value:
"  String:  The encoded string.
function! HTMLencodeString(string, ...)
  let out = ''

  if a:0 > 0
    if a:1 =~? '^d\(ecode\)\=$'
      let out = substitute(a:string, '&#\(\d\+\);', '\=nr2char(submatch(1))', 'g')
      let out = substitute(out, '%\(\x\{2}\)', '\=nr2char("0x".submatch(1))', 'g')
      return out
    elseif a:1 == '%'
      let out = substitute(a:string, '\(.\)', '\=printf("%%%02X", char2nr(submatch(1)))', 'g')
      return out
    endif
  endif

  let string = split(a:string, '\zs')
  for c in string
    let out = out . '&#' . char2nr(c) . ';'
  endfor

  return out
endfunction

" HTMLmap()  {{{2
"
" Define the HTML mappings with the appropriate case, plus some extra stuff.
"
" Arguments:
"  1 - String:  Which map command to run.
"  2 - String:  LHS of the map.
"  3 - String:  RHS of the map.
"  4 - Integer: Optional, applies only to visual maps:
"                -1: Don't add any extra special code to the mapping.
"                 0: Mapping enters insert mode.
"               Applies only when filetype indenting is on:
"                 1: re-selects the region, moves down a line, and re-indents.
"                 2: re-selects the region and re-indents.
"                 (Don't use these two arguments for maps that enter insert
"                 mode!)
let s:modes = {
      \ 'n': 'normal',
      \ 'v': 'visual',
      \ 'o': 'operator-pending',
      \ 'i': 'insert',
      \ 'c': 'command-line',
      \ 'l': 'langmap',
    \}
function! HTMLmap(cmd, map, arg, ...)
  let mode = strpart(a:cmd, 0, 1)
  let map = substitute(a:map, '^<lead>\c', escape(g:html_map_leader, '&~\'), '')
  let map = substitute(map, '^<elead>\c', escape(g:html_map_entity_leader, '&~\'), '')

  if exists('s:modes[mode]') && s:MapCheck(map, mode) >= 2
    return
  endif

  let arg = s:ConvertCase(a:arg)
  if ! s:BoolVar('b:do_xhtml_mappings')
    let arg = substitute(arg, ' \?/>', '>', 'g')
  endif

  if mode == 'v'
    " If 'selection' is "exclusive" all the visual mode mappings need to
    " behave slightly differently:
    let arg = substitute(arg, "`>a\\C", "`>i<C-R>=<SID>VI()<CR>", 'g')

    if a:0 >= 1 && a:1 < 0
      execute a:cmd . " <buffer> <silent> " . map . " " . arg
    elseif a:0 >= 1 && a:1 >= 1
      execute a:cmd . " <buffer> <silent> " . map . " <C-C>:call <SID>TO(0)<CR>gv" . arg
        \ . ":call <SID>TO(1)<CR>m':call <SID>ReIndent(line(\"'<\"), line(\"'>\"), " . a:1 . ")<CR>``"
    elseif a:0 >= 1
      execute a:cmd . " <buffer> <silent> " . map . " <C-C>:call <SID>TO(0)<CR>gv" . arg
        \ . "<C-O>:call <SID>TO(1)<CR>"
    else
      execute a:cmd . " <buffer> <silent> " . map . " <C-C>:call <SID>TO(0)<CR>gv" . arg
        \ . ":call <SID>TO(1)<CR>"
    endif
  else
    execute a:cmd . " <buffer> <silent> " . map . " " . arg
  endif

  if exists('s:modes[mode]')
    let b:HTMLclearMappings = b:HTMLclearMappings . ':' . mode . "unmap <buffer> " . map . "\<CR>"
  else
    let b:HTMLclearMappings = b:HTMLclearMappings . ":unmap <buffer> " . map . "\<CR>"
  endif

  call s:ExtraMappingsAdd(':call HTMLmap("' . a:cmd . '", "' . escape(a:map, '"\')
        \ . '", "' . escape(a:arg, '"\') . (a:0 >= 1 ? ('", ' . a:1) : '"' ) . ')')
endfunction

" HTMLmapo()  {{{2
"
" Define a map that takes an operator to its corresponding visual mode
" mapping.
"
" Arguments:
"  1 - String:  The mapping.
"  2 - Boolean: Whether to enter insert mode after the mapping has executed.
"               (A value greater than 1 tells the mapping not to move right one
"               character.)
function! HTMLmapo(map, insert)
  let map = substitute(a:map, "^<lead>", g:html_map_leader, '')

  if s:MapCheck(map, 'o') >= 2
    return
  endif

  execute 'nnoremap <buffer> <silent> ' . map
    \ . " :let b:htmltagaction='" . map . "'<CR>"
    \ . ":let b:htmltaginsert=" . a:insert . "<CR>"
    \ . ':set operatorfunc=<SID>WR<CR>g@'

  let b:HTMLclearMappings = b:HTMLclearMappings . ":nunmap <buffer> " . map . "\<CR>"
  call s:ExtraMappingsAdd(':call HTMLmapo("' . escape(a:map, '"\') . '", ' . a:insert . ')')
endfunction

" s:MapCheck()  {{{2
"
" Check to see if a mapping for a mode already exists.  If there is, and
" overriding hasn't been suppressed, print an error.
"
" Arguments:
"  1 - String:    The map sequence (LHS).
"  2 - Character: The mode for the mapping.
" Return Value:
"  0 - No mapping was found.
"  1 - A mapping was found, but overriding has /not/ been suppressed.
"  2 - A mapping was found and overriding has been suppressed.
"  3 - The mapping to be defined was suppressed by g:no_html_maps.
"
" (Note that suppression only works for the internal mappings.)
function! s:MapCheck(map, mode)
  if exists('s:doing_internal_html_mappings') &&
        \ ( (exists('g:no_html_maps') && a:map =~# g:no_html_maps) ||
        \   (exists('b:no_html_maps') && a:map =~# b:no_html_maps) )
    return 3
  elseif exists('s:modes[a:mode]') && maparg(a:map, a:mode) != ''
    if s:BoolVar('g:no_html_map_override') && exists('s:doing_internal_html_mappings')
      return 2
    else
      echohl WarningMsg
      echomsg "WARNING: A mapping to \"" . a:map . "\" for " . s:modes[a:mode] . " mode has been overridden for this buffer."
      echohl None

      return 1
    endif
  endif

  return 0
endfunction

" s:WR()  {{{2
" Function set in 'operatorfunc' for mappings that take an operator:
function! s:WR(type)
  let sel_save = &selection
  let &selection = "inclusive"

  if a:type == 'line'
    execute "normal `[V`]" . b:htmltagaction
  elseif a:type == 'block'
    execute "normal `[\<C-V>`]" . b:htmltagaction
  else
    execute "normal `[v`]" . b:htmltagaction
  endif

  let &selection = sel_save

  if b:htmltaginsert
    if b:htmltaginsert < 2
      execute "normal \<Right>"
    endif
    startinsert
  endif

  " Leave these set so .-repeating of operator mappings works:
  "unlet b:htmltagaction b:htmltaginsert
endfunction

" s:ExtraMappingsAdd()  {{{2
"
" Add to the b:HTMLextraMappings variable if necessary.
"
" Arguments:
"  1 - String: The command necessary to re-define the mapping.
function! s:ExtraMappingsAdd(arg)
  if ! exists('s:doing_internal_html_mappings') && ! exists('s:doing_extra_html_mappings')
    if ! exists('b:HTMLextraMappings')
      let b:HTMLextraMappings = ''
    endif
    let b:HTMLextraMappings = b:HTMLextraMappings . a:arg . ' |'
  endif
endfunction

" s:TO()  {{{2
"
" Used to make sure the 'showmatch', 'indentexpr', and 'formatoptions' options
" are off temporarily to prevent the visual mappings from causing a
" (visual)bell or inserting improperly.
"
" Arguments:
"  1 - Integer: 0 - Turn options off.
"               1 - Turn options back on, if they were on before.
function! s:TO(s)
  if a:s == 0
    let s:savesm=&l:sm | let &l:sm=0
    let s:saveinde=&l:inde | let &l:inde=''
    let s:savefo=&l:fo | let &l:fo=''

    " A trick to make leading indent on the first line of visual-line
    " selections is handled properly (turn it into a character-wise
    " selection and exclude the leading indent):
    if visualmode() ==# 'V'
      let s:visualmode_save = visualmode()
      exe "normal `<^v`>\<C-C>"
    endif
  else
    let &l:sm=s:savesm | unlet s:savesm
    let &l:inde=s:saveinde | unlet s:saveinde
    let &l:fo=s:savefo | unlet s:savefo

    " Restore the last visual mode if it was changed:
    if exists('s:visualmode_save')
      exe "normal gv" . s:visualmode_save . "\<C-C>"
      unlet s:visualmode_save
    endif
  endif
endfunction

" s:TC()  {{{2
"
" Used to make sure the 'comments' option is off temporarily to prevent
" certain mappings from inserting unwanted comment leaders.
"
" Arguments:
"  1 - Integer: 0 - Turn options off.
"               1 - Turn options back on, if they were on before.
function! s:TC(s)
  if a:s == 0
    let s:savecom=&l:com | let &l:com=''
  else
    let &l:com=s:savecom | unlet s:savecom
  endif
endfunction

" s:VI() {{{2
"
" Used by HTMLmap() to enter insert mode in Visual mappings in the right
" place, depending on what 'selection' is set to.
"
" Arguments:
"   None
" Return Value:
"   The proper movement command based on the value of 'selection'.
function! s:VI()
  if &selection == 'inclusive'
    return "\<right>"
  else
    return "\<C-O>`>"
  endif
endfunction

" s:ConvertCase()  {{{2
"
" Convert special regions in a string to the appropriate case determined by
" b:html_tag_case.
"
" Arguments:
"  1 - String: The string with the regions to convert surrounded by [{...}].
" Return Value:
"  The converted string.
function! s:ConvertCase(str)
  if (! exists('b:html_tag_case')) || b:html_tag_case =~? 'u\(pper\(case\)\?\)\?' || b:html_tag_case == ''
    let str = substitute(a:str, '\[{\(.\{-}\)}\]', '\U\1', 'g')
  elseif b:html_tag_case =~? 'l\(ower\(case\)\?\)\?'
    let str = substitute(a:str, '\[{\(.\{-}\)}\]', '\L\1', 'g')
  else
    echohl WarningMsg
    echomsg "WARNING: b:html_tag_case = '" . b:html_tag_case . "' invalid, overriding to 'upppercase'."
    echohl None
    let b:html_tag_case = 'uppercase'
    let str = s:ConvertCase(a:str)
  endif
  return str
endfunction

" s:ReIndent()  {{{2
"
" Re-indent a region.  (Usually called by HTMLmap.)
"  Nothing happens if filetype indenting isn't enabled or 'indentexpr' is
"  unset.
"
" Arguments:
"  1 - Integer: Start of region.
"  2 - Integer: End of region.
"  3 - Integer: 1: Add an extra line below the region to re-indent.
"               *: Don't add an extra line.
function! s:ReIndent(first, last, extraline)
  " To find out if filetype indenting is enabled:
  let save_register = @x
  redir @x | silent! filetype | redir END
  let filetype_output = @x
  let @x = save_register

  if filetype_output =~ "indent:OFF" && &indentexpr == ''
    return
  endif

  " Make sure the range is in the proper order:
  if a:last >= a:first
    let firstline = a:first
    let lastline = a:last
  else
    let lastline = a:first
    let firstline = a:last
  endif

  " Make sure the full region to be re-indendted is included:
  if a:extraline == 1
    if firstline == lastline
      let lastline = lastline + 2
    else
      let lastline = lastline + 1
    endif
  endif

  execute firstline . ',' . lastline . 'norm =='
endfunction

" s:ByteOffset()  {{{2
"
" Return the byte number of the current position.
"
" Arguments:
"  None
" Return Value:
"  The byte offset
function! s:ByteOffset()
  return line2byte(line('.')) + col('.') - 1
endfunction

" HTMLnextInsertPoint()  {{{2
"
" Position the cursor at the next point in the file that needs data.
"
" Arguments:
"  1 - Character: Optional, the mode the function is being called from. 'n'
"                 for normal, 'i' for insert.  If 'i' is used the function
"                 enables an extra feature where if the cursor is on the start
"                 of a closing tag it places the cursor after the tag.
"                 Default is 'n'.
" Return Value:
"  None.
" Known problems:
"  Due to the necessity of running the search twice (why doesn't Vim support
"  cursor offset positioning in search()?) this function
"    a) won't ever position the cursor on an "empty" tag that starts on the
"       first character of the first line of the buffer
"    b) won't let the cursor "escape" from an "empty" tag that it can match on
"       the first line of the buffer when the cursor is on the first line and
"       tab is successively pressed
function! HTMLnextInsertPoint(...)
  let saveerrmsg  = v:errmsg
  let v:errmsg    = ''
  let saveruler   = &ruler   | let &ruler=0
  let saveshowcmd = &showcmd | let &showcmd=0
  let byteoffset  = s:ByteOffset()

  " Tab in insert mode on the beginning of a closing tag jumps us to
  " after the tag:
  if a:0 >= 1 && a:1 == 'i'
    if strpart(getline(line('.')), col('.') - 1, 2) == '</'
      normal %
      let done = 1
    elseif strpart(getline(line('.')), col('.') - 1, 4) =~ ' *-->'
      normal f>
      let done = 1
    else
      let done = 0
    endif

    if done == 1
      if col('.') == col('$') - 1
        startinsert!
      else
        normal l
      endif

      return
    endif
  endif


  normal 0

  " Running the search twice is inefficient, but it squelches error
  " messages and the second search puts my cursor where it's needed...

  if search('<\([^ <>]\+\)\_[^<>]*>\_s*<\/\1>\|<\_[^<>]*""\_[^<>]*>\|<!--\_s*-->', 'w') == 0
    if byteoffset == -1
      go 1
    else
      execute ':go ' . byteoffset
      if a:0 >= 1 && a:1 == 'i' && col('.') == col('$') - 1
        startinsert!
      endif
    endif
  else
    normal 0
    silent! execute ':go ' . (s:ByteOffset() - 1)
    execute 'silent! normal! /<\([^ <>]\+\)\_[^<>]*>\_s*<\/\1>\|<\_[^<>]*""\_[^<>]*>\|<!--\_s*-->/;/>\_s*<\|""\|<!--\_s*-->/e' . "\<CR>"

    " Handle cursor positioning for comments and/or open+close tags spanning
    " multiple lines:
    if getline('.') =~ '<!-- \+-->'
      execute "normal F\<space>"
    elseif getline('.') =~ '^ *-->' && getline(line('.')-1) =~ '<!-- *$'
      normal 0
      normal t-
    elseif getline('.') =~ '^ *-->' && getline(line('.')-1) =~ '^ *$'
      normal k$
    elseif getline('.') =~ '^ *<\/[^<>]\+>' && getline(line('.')-1) =~ '^ *$'
      normal k$
    endif

    call histdel('search', -1)
    let @/ = histget('search', -1)
  endif

  let v:errmsg = saveerrmsg
  let &ruler   = saveruler
  let &showcmd = saveshowcmd
endfunction

" s:tag()  {{{2
"
" Causes certain tags (such as bold, italic, underline) to be closed then
" opened rather than opened then closed where appropriate, if syntax
" highlighting is on.
"
" Arguments:
"  1 - String: The tag name.
"  2 - Character: The mode:
"                  'i' - Insert mode
"                  'v' - Visual mode
" Return Value:
"  The string to be executed to insert the tag.

" s:smarttags[tag][mode][open/close] = keystrokes  {{{
"  tag        - The literal tag, without the <>'s
"  mode       - i = insert, v = visual
"               (no "o", because o-mappings invoke visual mode)
"  open/close - c = When inside an equivalent tag, close then open it
"               o = When not inside an equivalent tag
"  keystrokes - The mapping keystrokes to execute
let s:smarttags = {}
let s:smarttags['i'] = {
      \ 'i': {
        \ 'o': "<[{I></I}]>\<C-O>F<",
        \ 'c': "<[{/I><I}]>\<C-O>F<",
      \ },
      \ 'v': {
        \ 'o': "`>a</[{I}]>\<C-O>`<<[{I}]>",
        \ 'c': "`>a<[{I}]>\<C-O>`<</[{I}]>",
      \ }
    \ }

let s:smarttags['em'] = {
      \ 'i': {
        \ 'o': "<[{EM></EM}]>\<C-O>F<",
        \ 'c': "<[{/EM><EM}]>\<C-O>F<",
      \ },
      \ 'v': {
        \ 'o': "`>a</[{EM}]>\<C-O>`<<[{EM}]>",
        \ 'c': "`>a<[{EM}]>\<C-O>`<</[{EM}]>",
      \ }
    \ }

let s:smarttags['b'] = {
      \ 'i': {
        \ 'o': "<[{B></B}]>\<C-O>F<",
        \ 'c': "<[{/B><B}]>\<C-O>F<",
      \},
      \ 'v': {
        \ 'o': "`>a</[{B}]>\<C-O>`<<[{B}]>",
        \ 'c': "`>a<[{B}]>\<C-O>`<</[{B}]>",
      \ }
    \ }

let s:smarttags['strong']  = {
      \ 'i': {
        \ 'o': "<[{STRONG></STRONG}]>\<C-O>F<",
        \ 'c': "<[{/STRONG><STRONG}]>\<C-O>F<",
      \},
      \ 'v': {
        \ 'o': "`>a</[{STRONG}]>\<C-O>`<<[{STRONG}]>",
        \ 'c': "`>a<[{STRONG}]>\<C-O>`<</[{STRONG}]>",
      \ }
    \ }

let s:smarttags['u'] = {
      \ 'i': {
        \ 'o': "<[{U></U}]>\<C-O>F<",
        \ 'c': "<[{/U><U}]>\<C-O>F<",
      \},
      \ 'v': {
        \ 'o': "`>a</[{U}]>\<C-O>`<<[{U}]>",
        \ 'c': "`>a<[{U}]>\<C-O>`<</[{U}]>",
      \ }
    \ }

let s:smarttags['comment'] = {
      \ 'i': {
        \ 'o': "<!--  -->\<C-O>F ",
        \ 'c': " --><!-- \<C-O>F<",
      \},
      \ 'v': {
        \ 'o': "`>a -->\<C-O>`<<!-- ",
        \ 'c': "`>a<!-- \<C-O>`< -->",
      \ }
    \ }
" }}}

function! s:tag(tag, mode)
  let attr=synIDattr(synID(line('.'), col('.') - 1, 1), "name")
  if ( a:tag == 'i' && attr =~? 'italic' )
        \ || ( a:tag == 'em' && attr =~? 'italic' )
        \ || ( a:tag == 'b' && attr =~? 'bold' )
        \ || ( a:tag == 'strong' && attr =~? 'bold' )
        \ || ( a:tag == 'u' && attr =~? 'underline' )
        \ || ( a:tag == 'comment' && attr =~? 'comment' )
    let ret=s:ConvertCase(s:smarttags[a:tag][a:mode]['c'])
  else
    let ret=s:ConvertCase(s:smarttags[a:tag][a:mode]['o'])
  endif
  if a:mode == 'v'
    " If 'selection' is "exclusive" all the visual mode mappings need to
    " behave slightly differently:
    let ret = substitute(ret, "`>a\\C", "`>i" . s:VI(), 'g')
  endif
  return ret
endfunction

" s:DetectCharset()  {{{2
"
" Detects the HTTP-EQUIV Content-Type charset based on Vim's current
" encoding/fileencoding.
"
" Arguments:
"  None
" Return Value:
"  The value for the Content-Type charset based on 'fileencoding' or
"  'encoding'.

" TODO: This table needs to be expanded:
let s:charsets = {}
let s:charsets['latin1']    = 'iso-8859-1'
let s:charsets['utf_8']     = 'UTF-8'
let s:charsets['utf_16']    = 'UTF-16'
let s:charsets['shift_jis'] = 'Shift_JIS'
let s:charsets['euc_jp']    = 'EUC-JP'
let s:charsets['cp950']     = 'Big5'
let s:charsets['big5']      = 'Big5'

function! s:DetectCharset()

  if exists("g:html_charset")
    return g:html_charset
  endif

  if &fileencoding != ''
    let enc=tolower(&fileencoding)
  else
    let enc=tolower(&encoding)
  endif

  " The iso-8859-* encodings are valid for the Content-Type charset header:
  if enc =~? '^iso-8859-'
    return enc
  endif

  let enc=substitute(enc, '\W', '_', 'g')

  if s:charsets[enc] != ''
    return s:charsets[enc]
  endif

  return g:html_default_charset
endfunction

" HTMLgenerateTable()  {{{2
"
" Interactively creates a table.
"
" Arguments:
"  None
" Return Value:
"  None
function! HTMLgenerateTable()
  let byteoffset = s:ByteOffset()

  let rows    = inputdialog("Number of rows: ") + 0
  let columns = inputdialog("Number of columns: ") + 0

  if ! (rows > 0 && columns > 0)
    echo "Rows and columns must be integers."
    return
  endif

  let border = inputdialog("Border width of table [none]: ") + 0

  if border
    execute s:ConvertCase("normal o<[{TABLE BORDER}]=" . border . ">\<ESC>")
  else
    execute s:ConvertCase("normal o<[{TABLE}]>\<ESC>")
  endif

  for r in range(rows)
    execute s:ConvertCase("normal o<[{TR}]>\<ESC>")

    for c in range(columns)
      execute s:ConvertCase("normal o<[{TD}]>\<CR></[{TD}]>\<ESC>")
    endfor

    execute s:ConvertCase("normal o</[{TR}]>\<ESC>")
  endfor

  execute s:ConvertCase("normal o</[{TABLE}]>\<ESC>")

  execute ":go " . (byteoffset <= 0 ? 1 : byteoffset)

  normal jjj^

endfunction

" s:MappingsControl()  {{{2
"
" Disable/enable all the mappings defined by HTMLmap()/HTMLmapo().
"
" Arguments:
"  1 - String:  Whether to disable or enable the mappings:
"                d/disable: Clear the mappings
"                e/enable:  Redefine the mappings
"                r/reload:  Completely reload the script
"                h/html:    Reload the mapppings in HTML mode
"                x/xhtml:   Reload the mapppings in XHTML mode
" Return Value:
"  None
silent! function! s:MappingsControl(dowhat)
  if ! exists('b:did_html_mappings_init')
    echohl ErrorMsg
    echomsg "The HTML mappings were not sourced for this buffer."
    echohl None
    return
  endif

  if b:did_html_mappings_init < 0
    unlet b:did_html_mappings_init
  endif

  if a:dowhat =~? '^d\(isable\)\=\|off$'
    if exists('b:did_html_mappings')
      silent execute b:HTMLclearMappings
      unlet b:did_html_mappings
      if exists("g:did_html_menus")
        call s:MenuControl('disable')
      endif
    elseif ! exists('s:quiet_errors')
      echohl ErrorMsg
      echomsg "The HTML mappings are already disabled."
      echohl None
    endif
  elseif a:dowhat =~? '^e\(nable\)\=\|on$'
    if exists('b:did_html_mappings')
      echohl ErrorMsg
      echomsg "The HTML mappings are already enabled."
      echohl None
    else
      execute "source " . s:thisfile
      if exists('b:HTMLextraMappings')
        let s:doing_extra_html_mappings = 1
        silent execute b:HTMLextraMappings
        unlet s:doing_extra_html_mappings
      endif
    endif
  elseif a:dowhat =~? '^r\(eload\|einit\)\=$'
    let s:quiet_errors = 1
    HTMLmappings off
    let b:did_html_mappings_init=-1
    silent! unlet g:did_html_menus g:did_html_toolbar g:did_html_functions
    silent! unmenu HTML
    silent! unmenu! HTML
    HTMLmappings on
    unlet s:quiet_errors
  elseif a:dowhat =~? '^h\(tml\)\=$'
    if exists('b:html_tag_case_save')
      let b:html_tag_case = b:html_tag_case_save
    endif
    let b:do_xhtml_mappings=0
    HTMLmappings off
    let b:did_html_mappings_init=-1
    HTMLmappings on
  elseif a:dowhat =~? '^x\(html\)\=$'
    let b:do_xhtml_mappings=1
    HTMLmappings off
    let b:did_html_mappings_init=-1
    HTMLmappings on
  else
    echohl ErrorMsg
    echomsg "Invalid argument: " . a:dowhat
    echohl None
  endif
endfunction

command! -nargs=1 HTMLmappings call <SID>MappingsControl(<f-args>)


" s:MenuControl()  {{{2
"
" Disable/enable the HTML menu and toolbar.
"
" Arguments:
"  1 - String:  Optional, Whether to disable or enable the mappings:
"                empty: Detect which to do
"                "disable": Disable the menu and toolbar
"                "enable": Enable the menu and toolbar
" Return Value:
"  None
function! s:MenuControl(...)
  if a:0 > 0
    if a:1 !~? '^\(dis\|en\)able$'
      echoerr "Invalid argument: " . a:1
      return
    else
      let bool = a:1
    endif
  else
    let bool = ''
  endif

  if bool == 'disable' || ! exists("b:did_html_mappings")
    amenu disable HTML
    amenu disable HTML.*
    if exists('g:did_html_toolbar')
      amenu disable ToolBar.*
      amenu enable ToolBar.Open
      amenu enable ToolBar.Save
      amenu enable ToolBar.SaveAll
      amenu enable ToolBar.Cut
      amenu enable ToolBar.Copy
      amenu enable ToolBar.Paste
      amenu enable ToolBar.Find
      amenu enable ToolBar.Replace
    endif
    if exists('b:did_html_mappings_init') && ! exists('b:did_html_mappings')
      amenu enable HTML
      amenu disable HTML.Control.*
      amenu enable HTML.Control
      amenu enable HTML.Control.Enable\ Mappings
      amenu enable HTML.Control.Reload\ Mappings
    endif
  elseif bool == 'enable' || exists("b:did_html_mappings_init")
    amenu enable HTML
    if exists("b:did_html_mappings")
      amenu enable HTML.*
      amenu enable HTML.Control.*
      amenu disable HTML.Control.Enable\ Mappings

      if s:BoolVar('b:do_xhtml_mappings')
        amenu disable HTML.Control.Switch\ to\ XHTML\ mode
        amenu enable  HTML.Control.Switch\ to\ HTML\ mode
      else
        amenu enable  HTML.Control.Switch\ to\ XHTML\ mode
        amenu disable HTML.Control.Switch\ to\ HTML\ mode
      endif

      if exists('g:did_html_toolbar')
        amenu enable ToolBar.*
      endif
    else
      amenu enable HTML.Control.Enable\ Mappings
    endif
  endif
endfunction

" s:ShowColors()  {{{2
"
" Create a window to display the HTML colors, highlighted
"
" Arguments:
"  None
" Return Value:
"  None
function! s:ShowColors(...)
  if ! exists('g:did_html_menus')
    echohl ErrorMsg
    echomsg "The HTML menu was not created."
    echohl None
    return
  endif

  if ! exists('b:did_html_mappings_init')
    echohl ErrorMsg
    echomsg "Not in an html buffer."
    echohl None
    return
  endif

  let curbuf = bufnr('%')
  let maxw = 0

  silent new [HTML\ Colors\ Display]
  setlocal buftype=nofile noswapfile bufhidden=wipe

  for key in keys(s:color_list)
    if strlen(key) > maxw
      let maxw = strlen(key)
    endif
  endfor

  let col = 0
  let line = ''
  for key in sort(keys(s:color_list))
    let col+=1

    let line.=repeat(' ', maxw - strlen(key)) . key . ' = ' . s:color_list[key]

    if col >= 2
      call append('$', line)
      let line = ''
      let col = 0
    else
      let line .= '      '
    endif

    let key2 = substitute(key, ' ', '', 'g')

    execute 'syntax match hc_' . key2 . ' /' . s:color_list[key] . '/'
    execute 'highlight hc_' . key2 . ' guibg=' . s:color_list[key]
  endfor

  if line != ''
    call append('$', line)
  endif

  call append(0, [
        \'+++ q = quit  <space> = page down   b = page up           +++',
        \'+++ <tab> = Go to next color                              +++',
        \'+++ <enter> or <double click> = Select color under cursor +++',
      \])
  exe 0
  exe '1,3center ' . ((maxw + 13) * 2)

  setlocal nomodifiable

  syntax match hc_colorsKeys =^\%<4l\s*+++ .\+ +++$=
  highlight link hc_colorsKeys Comment

  wincmd _

  noremap <silent> <buffer> q <C-w>c
  inoremap <silent> <buffer> q <C-o><C-w>c
  noremap <silent> <buffer> <space> <C-f>
  inoremap <silent> <buffer> <space> <C-o><C-f>
  noremap <silent> <buffer> b <C-b>
  inoremap <silent> <buffer> b <C-o><C-b>
  noremap <silent> <buffer> <tab> :call search('[A-Za-z][A-Za-z ]\+ = #\x\{6\}')<CR>
  inoremap <silent> <buffer> <tab> <C-o>:call search('[A-Za-z][A-Za-z ]\+ = #\x\{6\}')<CR>

  if a:0 >= 1
    let ext = ', "' . escape(a:1, '"') . '"'
  else
    let ext = ''
  endif

  execute 'noremap <silent> <buffer> <cr> :call <SID>ColorSelect(' . curbuf . ext . ')<CR>'
  execute 'inoremap <silent> <buffer> <cr> <C-o>:call <SID>ColorSelect(' . curbuf . ext . ')<CR>'
  execute 'noremap <silent> <buffer> <2-leftmouse> :call <SID>ColorSelect(' . curbuf . ext . ')<CR>'
  execute 'inoremap <silent> <buffer> <2-leftmouse> <C-o>:call <SID>ColorSelect(' . curbuf . ext . ')<CR>'
endfunction

function! s:ColorSelect(bufnr, ...)
  let line  = getline('.')
  let col   = col('.')
  let color = substitute(line, '.\{-\}\%<' . (col + 1) . 'c\([A-Za-z][A-Za-z ]\+ = #\x\{6\}\)\%>' . col . 'c.*', '\1', '') 

  if color == line
    return ''
  endif

  let colora = split(color, ' = ')

  close
  if bufwinnr(a:bufnr) == -1
    exe 'buffer ' . a:bufnr
  else
    exe a:bufnr . 'wincmd w'
  endif

  if a:0 >= 1
    let which = a:1
  else
    let which = 'i'
  endif

  exe 'normal ' . which . colora[1]
  stopinsert
  echo color
endfunction

function! s:ShellEscape(str) " {{{2
	if exists('*shellescape')
		return shellescape(a:str)
	else
    if has('unix')
      return "'" . substitute(a:str, "'", "'\\\\''", 'g') . "'"
    else
      " Don't know how to properly escape for 'doze, so don't bother:
      return a:str
    endif
	endif
endfunction

" ---- Template Creation Stuff: {{{2

" HTMLtemplate()  {{{3
"
" Determine whether to insert the HTML template.
"
" Arguments:
"  None
" Return Value:
"  0 - The cursor is not on an insert point.
"  1 - The cursor is on an insert point.
function! HTMLtemplate()
  let ret = 0
  let save_ruler = &ruler
  let save_showcmd = &showcmd
  set noruler noshowcmd
  if line('$') == 1 && getline(1) == ''
    let ret = s:HTMLtemplate2()
  else
    let YesNoOverwrite = confirm("Non-empty file.\nInsert template anyway?", "&Yes\n&No\n&Overwrite", 2, "W")
    if YesNoOverwrite == 1
      let ret = s:HTMLtemplate2()
    elseif YesNoOverwrite == 3
      execute "1,$delete"
      let ret = s:HTMLtemplate2()
    endif
  endif
  let &ruler = save_ruler
  let &showcmd = save_showcmd
  return ret
endfunction  " }}}3

" s:HTMLtemplate2()  {{{3
"
" Actually insert the HTML template.
"
" Arguments:
"  None
" Return Value:
"  0 - The cursor is not on an insert point.
"  1 - The cursor is on an insert point.
function! s:HTMLtemplate2()

  if g:html_authoremail != ''
    let g:html_authoremail_encoded = HTMLencodeString(g:html_authoremail)
  else
    let g:html_authoremail_encoded = ''
  endif

  let template = ''

  if exists('b:html_template') && b:html_template != ''
    let template = b:html_template
  elseif exists('g:html_template') && g:html_template != ''
    let template = g:html_template
  endif

  if template != ''
    if filereadable(expand(template))
      silent execute "0read " . template
    else
      echohl ErrorMsg
      echomsg "Unable to insert template file: " . template
      echomsg "Either it doesn't exist or it isn't readable."
      echohl None
      return 0
    endif
  else
    0put =b:internal_html_template
  endif

  if getline('$') =~ '^\s*$'
    $delete
  endif

  " Replace the various tokens with appropriate values:
  silent! %s/\C%authorname%/\=g:html_authorname/g
  silent! %s/\C%authoremail%/\=g:html_authoremail_encoded/g
  silent! %s/\C%bgcolor%/\=g:html_bgcolor/g
  silent! %s/\C%textcolor%/\=g:html_textcolor/g
  silent! %s/\C%linkcolor%/\=g:html_linkcolor/g
  silent! %s/\C%alinkcolor%/\=g:html_alinkcolor/g
  silent! %s/\C%vlinkcolor%/\=g:html_vlinkcolor/g
  silent! %s/\C%date%/\=strftime('%B %d, %Y')/g
  "silent! %s/\C%date\s*\([^%]\{-}\)\s*%/\=strftime(substitute(submatch(1),'\\\@<!!','%','g'))/g
  silent! %s/\C%date\s*\(\%(\\%\|[^%]\)\{-}\)\s*%/\=strftime(substitute(substitute(submatch(1),'\\%','%%','g'),'\\\@<!!','%','g'))/g
  silent! %s/\C%time%/\=strftime('%r %Z')/g
  silent! %s/\C%time12%/\=strftime('%r %Z')/g
  silent! %s/\C%time24%/\=strftime('%T')/g
  silent! %s/\C%charset%/\=<SID>DetectCharset()/g
  silent! %s/\C%vimversion%/\=strpart(v:version, 0, 1) . '.' . (strpart(v:version, 1, 2) + 0)/g

  go 1

  call HTMLnextInsertPoint('n')
  if getline('.')[col('.') - 2] . getline('.')[col('.') - 1] == '><'
        \ || (getline('.') =~ '^\s*$' && line('.') != 1)
    return 1
  else
    return 0
  endif

endfunction  " }}}3

endif " ! exists("g:did_html_functions")

let s:internal_html_template=
  \" <[{HEAD}]>\n\n" .
  \"  <[{TITLE></TITLE}]>\n\n" .
  \"  <[{META NAME}]=\"Generator\" [{CONTENT}]=\"Vim %vimversion% (Vi IMproved editor; http://www.vim.org/)\" />\n" .
  \"  <[{META NAME}]=\"Author\" [{CONTENT}]=\"%authorname%\" />\n" .
  \"  <[{META NAME}]=\"Copyright\" [{CONTENT}]=\"Copyright (C) %date% %authorname%\" />\n" .
  \"  <[{LINK REV}]=\"made\" [{HREF}]=\"mailto:%authoremail%\" />\n\n" .
  \"  <[{STYLE TYPE}]=\"text/css\">\n" .
  \"   <!--\n" .
  \"   [{BODY}] {background: %bgcolor%; color: %textcolor%;}\n" .
  \"   [{A}]:link {color: %linkcolor%;}\n" .
  \"   [{A}]:visited {color: %vlinkcolor%;}\n" .
  \"   [{A}]:hover, [{A}]:active, [{A}]:focus {color: %alinkcolor%;}\n" .
  \"   -->\n" .
  \"  </[{STYLE}]>\n\n" .
  \" </[{HEAD}]>\n" .
  \" <[{BODY BGCOLOR}]=\"%bgcolor%\"" .
    \" [{TEXT}]=\"%textcolor%\"" .
    \" [{LINK}]=\"%linkcolor%\"" .
    \" [{ALINK}]=\"%alinkcolor%\"" .
    \" [{VLINK}]=\"%vlinkcolor%\">\n\n" .
  \"  <[{H1 ALIGN=\"CENTER\"></H1}]>\n\n" .
  \"  <[{P}]>\n" .
  \"  </[{P}]>\n\n" .
  \"  <[{HR WIDTH}]=\"75%\" />\n\n" .
  \"  <[{P}]>\n" .
  \"  Last Modified: <[{I}]>%date%</[{I}]>\n" .
  \"  </[{P}]>\n\n" .
  \"  <[{ADDRESS}]>\n" .
  \"   <[{A HREF}]=\"mailto:%authoremail%\">%authorname% &lt;%authoremail%&gt;</[{A}]>\n" .
  \"  </[{ADDRESS}]>\n" .
  \" </[{BODY}]>\n" .
  \"</[{HTML}]>"

if s:BoolVar('b:do_xhtml_mappings')
  let b:internal_html_template = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"\n" .
        \ " \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n" .
        \ "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n" .
        \ s:internal_html_template
else
  let b:internal_html_template = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"\n" .
        \ " \"http://www.w3.org/TR/html4/loose.dtd\">\n" .
        \ "<[{HTML}]>\n" .
        \ s:internal_html_template
  let b:internal_html_template = substitute(b:internal_html_template, ' />', '>', 'g')
endif

let b:internal_html_template = s:ConvertCase(b:internal_html_template)

" ----------------------------------------------------------------------------

endif " ! exists("b:did_html_mappings_init")


" ---- Misc. Mappings: -------------------------------------------------- {{{1

if ! exists("b:did_html_mappings")
let b:did_html_mappings = 1

let b:HTMLclearMappings = 'normal '

" Make it easy to use a ; (or whatever the map leader is) as normal:
call HTMLmap("inoremap", '<lead>' . g:html_map_leader, g:html_map_leader)
call HTMLmap("vnoremap", '<lead>' . g:html_map_leader, g:html_map_leader, -1)
call HTMLmap("nnoremap", '<lead>' . g:html_map_leader, g:html_map_leader)
" Make it easy to insert a & (or whatever the entity leader is):
call HTMLmap("inoremap", "<lead>" . g:html_map_entity_leader, g:html_map_entity_leader)

if ! s:BoolVar('g:no_html_tab_mapping')
  " Allow hard tabs to be inserted:
  call HTMLmap("inoremap", "<lead><tab>", "<tab>")
  call HTMLmap("nnoremap", "<lead><tab>", "<tab>")

  " Tab takes us to a (hopefully) reasonable next insert point:
  call HTMLmap("inoremap", "<tab>", "<C-O>:call HTMLnextInsertPoint('i')<CR>")
  call HTMLmap("nnoremap", "<tab>", ":call HTMLnextInsertPoint('n')<CR>")
  call HTMLmap("vnoremap", "<tab>", "<C-C>:call HTMLnextInsertPoint('n')<CR>", -1)
else
  call HTMLmap("inoremap", "<lead><tab>", "<C-O>:call HTMLnextInsertPoint('i')<CR>")
  call HTMLmap("nnoremap", "<lead><tab>", ":call HTMLnextInsertPoint('n')<CR>")
  call HTMLmap("vnoremap", "<lead><tab>", "<C-C>:call HTMLnextInsertPoint('n')<CR>", -1)
endif

" Update an image tag's WIDTH & HEIGHT attributes (experimental!):
runtime! MangleImageTag.vim
if exists("*MangleImageTag")
  call HTMLmap("nnoremap", "<lead>mi", ":call MangleImageTag()<CR>")
  call HTMLmap("inoremap", "<lead>mi", "<C-O>:call MangleImageTag()<CR>")
endif

call HTMLmap("nnoremap", "<lead>html", ":if HTMLtemplate() \\| startinsert \\| endif<CR>")

" ----------------------------------------------------------------------------


" ---- General Markup Tag Mappings: ------------------------------------- {{{1

"       SGML Doctype Command
"call HTMLmap("nnoremap", "<lead>4", "1GO<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\"><ESC>``")

"       SGML Doctype Command
if ! s:BoolVar('b:do_xhtml_mappings')
  " Transitional HTML (Looser):
  call HTMLmap("nnoremap", "<lead>4", ":call append(0, '<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"') \\\| call append(1, ' \"http://www.w3.org/TR/html4/loose.dtd\">')<CR>")
  " Strict HTML:
  call HTMLmap("nnoremap", "<lead>s4", ":call append(0, '<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\"') \\\| call append(1, ' \"http://www.w3.org/TR/html4/strict.dtd\">')<CR>")
else
  " Transitional XHTML (Looser):
  call HTMLmap("nnoremap", "<lead>4", ":call append(0, '<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"') \\\| call append(1, ' \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">')<CR>")
  " Strict XHTML:
  call HTMLmap("nnoremap", "<lead>s4", ":call append(0, '<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"') \\\| call append(1, ' \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">')<CR>")
endif
call HTMLmap("imap", "<lead>4", "<C-O>" . g:html_map_leader . "4")
call HTMLmap("imap", "<lead>s4", "<C-O>" . g:html_map_leader . "s4")

"       Content-Type META tag
call HTMLmap("inoremap", "<lead>ct", "<[{META HTTP-EQUIV}]=\"Content-Type\" [{CONTENT}]=\"text/html; charset=<C-R>=<SID>DetectCharset()<CR>\" />")

"       Comment Tag
call HTMLmap("inoremap", "<lead>cm", "<C-R>=<SID>tag('comment','i')<CR>")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>cm", "<C-C>:execute \"normal \" . <SID>tag('comment','v')<CR>", 2)
" Motion mapping:
call HTMLmapo('<lead>cm', 0)

"       A HREF  Anchor Hyperlink        HTML 2.0
call HTMLmap("inoremap", "<lead>ah", "<[{A HREF=\"\"></A}]><C-O>F\"")
call HTMLmap("inoremap", "<lead>aH", "<[{A HREF=\"<C-R>*\"></A}]><C-O>F<")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>ah", "<ESC>`>a</[{A}]><C-O>`<<[{A HREF}]=\"\"><C-O>F\"", 0)
call HTMLmap("vnoremap", "<lead>aH", "<ESC>`>a\"></[{A}]><C-O>`<<[{A HREF}]=\"<C-O>f<", 0)
" Motion mappings:
call HTMLmapo('<lead>ah', 1)
call HTMLmapo('<lead>aH', 1)

"       A HREF  Anchor Hyperlink, with TARGET=""
call HTMLmap("inoremap", "<lead>at", "<[{A HREF=\"\" TARGET=\"\"></A}]><C-O>3F\"")
call HTMLmap("inoremap", "<lead>aT", "<[{A HREF=\"<C-R>*\" TARGET=\"\"></A}]><C-O>F\"")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>at", "<ESC>`>a</[{A}]><C-O>`<<[{A HREF=\"\" TARGET}]=\"\"><C-O>3F\"", 0)
call HTMLmap("vnoremap", "<lead>aT", "<ESC>`>a\" [{TARGET=\"\"></A}]><C-O>`<<[{A HREF}]=\"<C-O>3f\"", 0)
" Motion mappings:
call HTMLmapo('<lead>at', 1)
call HTMLmapo('<lead>aT', 1)

"       A NAME  Named Anchor            HTML 2.0
call HTMLmap("inoremap", "<lead>an", "<[{A NAME=\"\"></A}]><C-O>F\"")
call HTMLmap("inoremap", "<lead>aN", "<[{A NAME=\"<C-R>*\"></A}]><C-O>F<")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>an", "<ESC>`>a</[{A}]><C-O>`<<[{A NAME}]=\"\"><C-O>F\"", 0)
call HTMLmap("vnoremap", "<lead>aN", "<ESC>`>a\"></[{A}]><C-O>`<<[{A NAME}]=\"<C-O>f<", 0)
" Motion mappings:
call HTMLmapo('<lead>an', 1)
call HTMLmapo('<lead>aN', 1)

"       ABBR  Abbreviation              HTML 4.0
call HTMLmap("inoremap", "<lead>ab", "<[{ABBR TITLE=\"\"></ABBR}]><C-O>F\"")
call HTMLmap("inoremap", "<lead>aB", "<[{ABBR TITLE=\"<C-R>*\"></ABBR}]><C-O>F<")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>ab", "<ESC>`>a</[{ABBR}]><C-O>`<<[{ABBR TITLE}]=\"\"><C-O>F\"", 0)
call HTMLmap("vnoremap", "<lead>aB", "<ESC>`>a\"></[{ABBR}]><C-O>`<<[{ABBR TITLE}]=\"<C-O>f<", 0)
" Motion mappings:
call HTMLmapo('<lead>ab', 1)
call HTMLmapo('<lead>aB', 1)

"       ACRONYM                         HTML 4.0
call HTMLmap("inoremap", "<lead>ac", "<[{ACRONYM TITLE=\"\"></ACRONYM}]><C-O>F\"")
call HTMLmap("inoremap", "<lead>aC", "<[{ACRONYM TITLE=\"<C-R>*\"></ACRONYM}]><C-O>F<")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>ac", "<ESC>`>a</[{ACRONYM}]><C-O>`<<[{ACRONYM TITLE}]=\"\"><C-O>F\"", 0)
call HTMLmap("vnoremap", "<lead>aC", "<ESC>`>a\"></[{ACRONYM}]><C-O>`<<[{ACRONYM TITLE}]=\"<C-O>f<", 0)
" Motion mappings:
call HTMLmapo('<lead>ac', 1)
call HTMLmapo('<lead>aC', 1)

"       ADDRESS                         HTML 2.0
call HTMLmap("inoremap", "<lead>ad", "<[{ADDRESS></ADDRESS}]><C-O>F<")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>ad", "<ESC>`>a</[{ADDRESS}]><C-O>`<<[{ADDRESS}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>ad', 0)

"       B       Boldfaced Text          HTML 2.0
call HTMLmap("inoremap", "<lead>bo", "<C-R>=<SID>tag('b','i')<CR>")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>bo", "<C-C>:execute \"normal \" . <SID>tag('b','v')<CR>", 2)
" Motion mapping:
call HTMLmapo('<lead>bo', 0)

"       BASE                            HTML 2.0        HEADER
call HTMLmap("inoremap", "<lead>bh", "<[{BASE HREF}]=\"\" /><C-O>F\"")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>bh", "<ESC>`>a\" /><C-O>`<<[{BASE HREF}]=\"<ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>bh', 0)

"       BIG                             HTML 3.0
call HTMLmap("inoremap", "<lead>bi", "<[{BIG></BIG}]><C-O>F<")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>bi", "<ESC>`>a</[{BIG}]><C-O>`<<[{BIG}]><ESC>")
" Motion mapping:
call HTMLmapo('<lead>bi', 0)

"       BLOCKQUOTE                      HTML 2.0
call HTMLmap("inoremap", "<lead>bl", "<[{BLOCKQUOTE}]><CR></[{BLOCKQUOTE}]><ESC>O")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>bl", "<ESC>`>a<CR></[{BLOCKQUOTE}]><C-O>`<<[{BLOCKQUOTE}]><CR><ESC>", 1)
" Motion mapping:
call HTMLmapo('<lead>bl', 0)

"       BODY                            HTML 2.0
call HTMLmap("inoremap", "<lead>bd", "<[{BODY}]><CR></[{BODY}]><ESC>O")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>bd", "<ESC>`>a<CR></[{BODY}]><C-O>`<<[{BODY}]><CR><ESC>", 1)
" Motion mapping:
call HTMLmapo('<lead>bd', 0)

"       BR      Line break              HTML 2.0
call HTMLmap("inoremap", "<lead>br", "<[{BR}] />")

"       CENTER                          NETSCAPE
call HTMLmap("inoremap", "<lead>ce", "<[{CENTER></CENTER}]><C-O>F<")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>ce", "<ESC>`>a</[{CENTER}]><C-O>`<<[{CENTER}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>ce', 0)

"       CITE                            HTML 2.0
call HTMLmap("inoremap", "<lead>ci", "<[{CITE></CITE}]><C-O>F<")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>ci", "<ESC>`>a</[{CITE}]><C-O>`<<[{CITE}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>ci', 0)

"       CODE                            HTML 2.0
call HTMLmap("inoremap", "<lead>co", "<[{CODE></CODE}]><C-O>F<")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>co", "<ESC>`>a</[{CODE}]><C-O>`<<[{CODE}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>co', 0)

"       DEFINITION LIST COMPONENTS      HTML 2.0
"               DL      Definition List
"               DT      Definition Term
"               DD      Definition Body
call HTMLmap("inoremap", "<lead>dl", "<[{DL}]><CR></[{DL}]><ESC>O")
call HTMLmap("inoremap", "<lead>dt", "<[{DT}]></[{DT}]><C-O>F<")
call HTMLmap("inoremap", "<lead>dd", "<[{DD}]></[{DD}]><C-O>F<")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>dl", "<ESC>`>a<CR></[{DL}]><C-O>`<<[{DL}]><CR><ESC>", 1)
call HTMLmap("vnoremap", "<lead>dt", "<ESC>`>a</[{DT}]><C-O>`<<[{DT}]><ESC>", 2)
call HTMLmap("vnoremap", "<lead>dd", "<ESC>`>a</[{DD}]><C-O>`<<[{DD}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>dl', 0)
call HTMLmapo('<lead>dt', 0)
call HTMLmapo('<lead>dd', 0)

"       DEL     Deleted Text            HTML 3.0
call HTMLmap("inoremap", "<lead>de", "<lt>[{DEL></DEL}]><C-O>F<")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>de", "<ESC>`>a</[{DEL}]><C-O>`<<lt>[{DEL}]><ESC>")
" Motion mapping:
call HTMLmapo('<lead>de', 0)

"       DFN     Defining Instance       HTML 3.0
call HTMLmap("inoremap", "<lead>df", "<[{DFN></DFN}]><C-O>F<")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>df", "<ESC>`>a</[{DFN}]><C-O>`<<[{DFN}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>df', 0)

"       DIV     Document Division       HTML 3.0
call HTMLmap("inoremap", "<lead>dv", "<[{DIV}]><CR></[{DIV}]><ESC>O")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>dv", "<ESC>`>a<CR></[{DIV}]><C-O>`<<[{DIV}]><CR><ESC>", 1)
" Motion mapping:
call HTMLmapo('<lead>dv', 0)

"       SPAN    Delimit Arbitrary Text  HTML 4.0
call HTMLmap("inoremap", "<lead>sn", "<[{SPAN></SPAN}]><C-O>F<")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>sn", "<ESC>`>a</[{SPAN}]><C-O>`<<[{SPAN}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>sn', 0)

"       EM      Emphasize               HTML 2.0
call HTMLmap("inoremap", "<lead>em", "<C-R>=<SID>tag('em','i')<CR>")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>em", "<C-C>:execute \"normal \" . <SID>tag('em','v')<CR>", 2)
" Motion mapping:
call HTMLmapo('<lead>em', 0)

"       FONT                            NETSCAPE
call HTMLmap("inoremap", "<lead>fo", "<[{FONT SIZE=\"\"></FONT}]><C-O>F\"")
call HTMLmap("inoremap", "<lead>fc", "<[{FONT COLOR=\"\"></FONT}]><C-O>F\"")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>fo", "<ESC>`>a</[{FONT}]><C-O>`<<[{FONT SIZE}]=\"\"><C-O>F\"", 0)
call HTMLmap("vnoremap", "<lead>fc", "<ESC>`>a</[{FONT}]><C-O>`<<[{FONT COLOR}]=\"\"><C-O>F\"", 0)
" Motion mappings:
call HTMLmapo('<lead>fo', 1)
call HTMLmapo('<lead>fc', 1)

"       HEADERS, LEVELS 1-6             HTML 2.0
call HTMLmap("inoremap", "<lead>h1", "<[{H1}]></[{H1}]><C-O>F<")
call HTMLmap("inoremap", "<lead>h2", "<[{H2}]></[{H2}]><C-O>F<")
call HTMLmap("inoremap", "<lead>h3", "<[{H3}]></[{H3}]><C-O>F<")
call HTMLmap("inoremap", "<lead>h4", "<[{H4}]></[{H4}]><C-O>F<")
call HTMLmap("inoremap", "<lead>h5", "<[{H5}]></[{H5}]><C-O>F<")
call HTMLmap("inoremap", "<lead>h6", "<[{H6}]></[{H6}]><C-O>F<")
call HTMLmap("inoremap", "<lead>H1", "<[{H1 ALIGN=\"CENTER}]\"></[{H1}]><C-O>F<")
call HTMLmap("inoremap", "<lead>H2", "<[{H2 ALIGN=\"CENTER}]\"></[{H2}]><C-O>F<")
call HTMLmap("inoremap", "<lead>H3", "<[{H3 ALIGN=\"CENTER}]\"></[{H3}]><C-O>F<")
call HTMLmap("inoremap", "<lead>H4", "<[{H4 ALIGN=\"CENTER}]\"></[{H4}]><C-O>F<")
call HTMLmap("inoremap", "<lead>H5", "<[{H5 ALIGN=\"CENTER}]\"></[{H5}]><C-O>F<")
call HTMLmap("inoremap", "<lead>H6", "<[{H6 ALIGN=\"CENTER}]\"></[{H6}]><C-O>F<")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>h1", "<ESC>`>a</[{H1}]><C-O>`<<[{H1}]><ESC>", 2)
call HTMLmap("vnoremap", "<lead>h2", "<ESC>`>a</[{H2}]><C-O>`<<[{H2}]><ESC>", 2)
call HTMLmap("vnoremap", "<lead>h3", "<ESC>`>a</[{H3}]><C-O>`<<[{H3}]><ESC>", 2)
call HTMLmap("vnoremap", "<lead>h4", "<ESC>`>a</[{H4}]><C-O>`<<[{H4}]><ESC>", 2)
call HTMLmap("vnoremap", "<lead>h5", "<ESC>`>a</[{H5}]><C-O>`<<[{H5}]><ESC>", 2)
call HTMLmap("vnoremap", "<lead>h6", "<ESC>`>a</[{H6}]><C-O>`<<[{H6}]><ESC>", 2)
call HTMLmap("vnoremap", "<lead>H1", "<ESC>`>a</[{H1}]><C-O>`<<[{H1 ALIGN=\"CENTER}]\"><ESC>", 2)
call HTMLmap("vnoremap", "<lead>H2", "<ESC>`>a</[{H2}]><C-O>`<<[{H2 ALIGN=\"CENTER}]\"><ESC>", 2)
call HTMLmap("vnoremap", "<lead>H3", "<ESC>`>a</[{H3}]><C-O>`<<[{H3 ALIGN=\"CENTER}]\"><ESC>", 2)
call HTMLmap("vnoremap", "<lead>H4", "<ESC>`>a</[{H4}]><C-O>`<<[{H4 ALIGN=\"CENTER}]\"><ESC>", 2)
call HTMLmap("vnoremap", "<lead>H5", "<ESC>`>a</[{H5}]><C-O>`<<[{H5 ALIGN=\"CENTER}]\"><ESC>", 2)
call HTMLmap("vnoremap", "<lead>H6", "<ESC>`>a</[{H6}]><C-O>`<<[{H6 ALIGN=\"CENTER}]\"><ESC>", 2)
" Motion mappings:
call HTMLmapo("<lead>h1", 0)
call HTMLmapo("<lead>h2", 0)
call HTMLmapo("<lead>h3", 0)
call HTMLmapo("<lead>h4", 0)
call HTMLmapo("<lead>h5", 0)
call HTMLmapo("<lead>h6", 0)
call HTMLmapo("<lead>H1", 0)
call HTMLmapo("<lead>H2", 0)
call HTMLmapo("<lead>H3", 0)
call HTMLmapo("<lead>H4", 0)
call HTMLmapo("<lead>H5", 0)
call HTMLmapo("<lead>H6", 0)

"       HEAD                            HTML 2.0
call HTMLmap("inoremap", "<lead>he", "<[{HEAD}]><CR></[{HEAD}]><ESC>O")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>he", "<ESC>`>a<CR></[{HEAD}]><C-O>`<<[{HEAD}]><CR><ESC>", 1)
" Motion mapping:
call HTMLmapo('<lead>he', 0)

"       HR      Horizontal Rule         HTML 2.0 W/NETSCAPISM
call HTMLmap("inoremap", "<lead>hr", "<[{HR}] />")
"       HR      Horizontal Rule         HTML 2.0 W/NETSCAPISM
call HTMLmap("inoremap", "<lead>Hr", "<[{HR WIDTH}]=\"75%\" />")

"       HTML
if ! s:BoolVar('b:do_xhtml_mappings')
  call HTMLmap("inoremap", "<lead>ht", "<[{HTML}]><CR></[{HTML}]><ESC>O")
  " Visual mapping:
  call HTMLmap("vnoremap", "<lead>ht", "<ESC>`>a<CR></[{HTML}]><C-O>`<<[{HTML}]><CR><ESC>", 1)
else
  call HTMLmap("inoremap", "<lead>ht", "<html xmlns=\"http://www.w3.org/1999/xhtml\"><CR></html><ESC>O")
  " Visual mapping:
  call HTMLmap("vnoremap", "<lead>ht", "<ESC>`>a<CR></html><C-O>`<<html xmlns=\"http://www.w3.org/1999/xhtml\"><CR><ESC>", 1)
endif
" Motion mapping:
call HTMLmapo('<lead>ht', 0)

"       I       Italicized Text         HTML 2.0
call HTMLmap("inoremap", "<lead>it", "<C-R>=<SID>tag('i','i')<CR>")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>it", "<C-C>:execute \"normal \" . <SID>tag('i','v')<CR>", 2)
" Motion mapping:
call HTMLmapo('<lead>it', 0)

"       IMG     Image                   HTML 2.0
call HTMLmap("inoremap", "<lead>im", "<[{IMG SRC=\"\" ALT}]=\"\" /><C-O>3F\"")
call HTMLmap("inoremap", "<lead>iM", "<[{IMG SRC=\"<C-R>*\" ALT}]=\"\" /><C-O>F\"")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>im", "<ESC>`>a\" /><C-O>`<<[{IMG SRC=\"\" ALT}]=\"<C-O>2F\"", 0)
call HTMLmap("vnoremap", "<lead>iM", "<ESC>`>a\" [{ALT}]=\"\" /><C-O>`<<[{IMG SRC}]=\"<C-O>3f\"", 0)
" Motion mapping:
call HTMLmapo('<lead>im', 1)
call HTMLmapo('<lead>iM', 1)

"       INS     Inserted Text           HTML 3.0
call HTMLmap("inoremap", "<lead>in", "<lt>[{INS></INS}]><C-O>F<")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>in", "<ESC>`>a</[{INS}]><C-O>`<<lt>[{INS}]><ESC>")
" Motion mapping:
call HTMLmapo('<lead>in', 0)

"       ISINDEX Identifies Index        HTML 2.0
call HTMLmap("inoremap", "<lead>ii", "<[{ISINDEX}] />")

"       KBD     Keyboard Text           HTML 2.0
call HTMLmap("inoremap", "<lead>kb", "<[{KBD></KBD}]><C-O>F<")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>kb", "<ESC>`>a</[{KBD}]><C-O>`<<[{KBD}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>kb', 0)

"       LI      List Item               HTML 2.0
call HTMLmap("inoremap", "<lead>li", "<[{LI}]></[{LI}]><C-O>F<")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>li", "<ESC>`>a</[{LI}]><C-O>`<<[{LI}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>li', 0)

"       LINK                            HTML 2.0        HEADER
call HTMLmap("inoremap", "<lead>lk", "<[{LINK HREF}]=\"\" /><C-O>F\"")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>lk", "<ESC>`>a\" /><C-O>`<<[{LINK HREF}]=\"<ESC>")
" Motion mapping:
call HTMLmapo('<lead>lk', 0)

"       META    Meta Information        HTML 2.0        HEADER
call HTMLmap("inoremap", "<lead>me", "<[{META NAME=\"\" CONTENT}]=\"\" /><C-O>3F\"")
call HTMLmap("inoremap", "<lead>mE", "<[{META NAME=\"\" CONTENT}]=\"<C-R>*\" /><C-O>3F\"")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>me", "<ESC>`>a\" [{CONTENT}]=\"\" /><C-O>`<<[{META NAME}]=\"<C-O>3f\"", 0)
call HTMLmap("vnoremap", "<lead>mE", "<ESC>`>a\" /><C-O>`<<[{META NAME=\"\" CONTENT}]=\"<C-O>2F\"", 0)
" Motion mappings:
call HTMLmapo('<lead>me', 1)
call HTMLmapo('<lead>mE', 1)

"       META    Meta http-equiv         HTML 2.0        HEADER
call HTMLmap("inoremap", "<lead>mh", "<[{META HTTP-EQUIV=\"\" CONTENT}]=\"\" /><C-O>3F\"")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>mh", "<ESC>`>a\" /><C-O>`<<[{META HTTP-EQUIV=\"\" CONTENT}]=\"<C-O>2F\"", 0)
" Motion mappings:
call HTMLmapo('<lead>mh', 1)


"       OL      Ordered List            HTML 3.0
call HTMLmap("inoremap", "<lead>ol", "<[{OL}]><CR></[{OL}]><ESC>O")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>ol", "<ESC>`>a<CR></[{OL}]><C-O>`<<[{OL}]><CR><ESC>", 1)
" Motion mapping:
call HTMLmapo('<lead>ol', 0)

"       P       Paragraph               HTML 3.0
call HTMLmap("inoremap", "<lead>pp", "<[{P}]><CR></[{P}]><ESC>O")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>pp", "<ESC>`>a<CR></[{P}]><C-O>`<<[{P}]><CR><ESC>", 1)
" Motion mapping:
call HTMLmapo('<lead>pp', 0)
" A special mapping... If you're between <P> and </P> this will insert the
" close tag and then the open tag in insert mode:
call HTMLmap("inoremap", "<lead>/p", "</[{P}]><CR><CR><[{P}]><CR>")

"       PRE     Preformatted Text       HTML 2.0
call HTMLmap("inoremap", "<lead>pr", "<[{PRE}]><CR></[{PRE}]><ESC>O")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>pr", "<ESC>`>a<CR></[{PRE}]><C-O>`<<[{PRE}]><CR><ESC>", 1)
" Motion mapping:
call HTMLmapo('<lead>pr', 0)

"       Q       Quote                   HTML 3.0
call HTMLmap("inoremap", "<lead>qu", "<[{Q></Q}]><C-O>F<")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>qu", "<ESC>`>a</[{Q}]><C-O>`<<[{Q}]><ESC>")
" Motion mapping:
call HTMLmapo('<lead>qu', 0)

"       S       Strikethrough           HTML 3.0
call HTMLmap("inoremap", "<lead>sk", "<[{STRIKE></STRIKE}]><C-O>F<")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>sk", "<ESC>`>a</[{STRIKE}]><C-O>`<<[{STRIKE}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>sk', 0)

"       SAMP    Sample Text             HTML 2.0
call HTMLmap("inoremap", "<lead>sa", "<[{SAMP></SAMP}]><C-O>F<")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>sa", "<ESC>`>a</[{SAMP}]><C-O>`<<[{SAMP}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>sa', 0)

"       SMALL   Small Text              HTML 3.0
call HTMLmap("inoremap", "<lead>sm", "<[{SMALL></SMALL}]><C-O>F<")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>sm", "<ESC>`>a</[{SMALL}]><C-O>`<<[{SMALL}]><ESC>")
" Motion mapping:
call HTMLmapo('<lead>sm', 0)

"       STRONG                          HTML 2.0
call HTMLmap("inoremap", "<lead>st", "<C-R>=<SID>tag('strong','i')<CR>")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>st", "<C-C>:execute \"normal \" . <SID>tag('strong','v')<CR>", 2)
" Motion mapping:
call HTMLmapo('<lead>st', 0)

"       STYLE                           HTML 4.0        HEADER
call HTMLmap("inoremap", "<lead>cs", "<[{STYLE TYPE}]=\"text/css\"><CR><!--<CR>--><CR></[{STYLE}]><ESC>kO")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>cs", "<ESC>`>a<CR> --><CR></[{STYLE}]><C-O>`<<[{STYLE TYPE}]=\"text/css\"><CR><!--<CR><ESC>", 1)
" Motion mapping:
call HTMLmapo('<lead>cs', 0)

"       Linked CSS stylesheet
call HTMLmap("inoremap", "<lead>ls", "<[{LINK REL}]=\"stylesheet\" [{TYPE}]=\"text/css\" [{HREF}]=\"\"><C-O>F\"")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>ls", "<ESC>`>a\"><C-O>`<<[{LINK REL}]=\"stylesheet\" [{TYPE}]=\"text/css\" [{HREF}]=\"<ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>ls', 0)

"       SUB     Subscript               HTML 3.0
call HTMLmap("inoremap", "<lead>sb", "<[{SUB></SUB}]><C-O>F<")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>sb", "<ESC>`>a</[{SUB}]><C-O>`<<[{SUB}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>sb', 0)

"       SUP     Superscript             HTML 3.0
call HTMLmap("inoremap", "<lead>sp", "<[{SUP></SUP}]><C-O>F<")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>sp", "<ESC>`>a</[{SUP}]><C-O>`<<[{SUP}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>sp', 0)

"       TITLE                           HTML 2.0        HEADER
call HTMLmap("inoremap", "<lead>ti", "<[{TITLE></TITLE}]><C-O>F<")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>ti", "<ESC>`>a</[{TITLE}]><C-O>`<<[{TITLE}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>ti', 0)

"       TT      Teletype Text (monospaced)      HTML 2.0
call HTMLmap("inoremap", "<lead>tt", "<[{TT></TT}]><C-O>F<")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>tt", "<ESC>`>a</[{TT}]><C-O>`<<[{TT}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>tt', 0)

"       U       Underlined Text         HTML 2.0
call HTMLmap("inoremap", "<lead>un", "<C-R>=<SID>tag('u','i')<CR>")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>un", "<C-C>:execute \"normal \" . <SID>tag('u','v')<CR>", 2)
" Motion mapping:
call HTMLmapo('<lead>un', 0)

"       UL      Unordered List          HTML 2.0
call HTMLmap("inoremap", "<lead>ul", "<[{UL}]><CR></[{UL}]><ESC>O")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>ul", "<ESC>`>a<CR></[{UL}]><C-O>`<<[{UL}]><CR><ESC>", 1)
" Motion mapping:
call HTMLmapo('<lead>ul', 0)

"       VAR     Variable                HTML 3.0
call HTMLmap("inoremap", "<lead>va", "<[{VAR></VAR}]><C-O>F<")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>va", "<ESC>`>a</[{VAR}]><C-O>`<<[{VAR}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>va', 0)

"       Embedded JavaScript
call HTMLmap("inoremap", "<lead>js", "<C-O>:call <SID>TC(0)<CR><[{SCRIPT TYPE}]=\"text/javascript\"><CR><!--<CR>// --><CR></[{SCRIPT}]><ESC>:call <SID>TC(1)<CR>kko")

"       Sourced JavaScript
call HTMLmap("inoremap", "<lead>sj", "<[{SCRIPT SRC}]=\"\" [{TYPE}]=\"text/javascript\"></[{SCRIPT}]><C-O>5F\"")

"       EMBED
call HTMLmap("inoremap", "<lead>eb", "<[{EMBED SRC=\"\" WIDTH=\"\" HEIGHT}]=\"\" /><CR><[{NOEMBED></NOEMBED}]><ESC>k$5F\"i")

"       NOSCRIPT
call HTMLmap("inoremap", "<lead>ns", "<[{NOSCRIPT}]><CR></[{NOSCRIP}]T><C-O>O")
call HTMLmap("vnoremap", "<lead>ns", "<ESC>`>a<CR></[{NOSCRIPT}]><C-O>`<<[{NOSCRIPT}]><CR><ESC>", 1)
call HTMLmapo('<lead>ns', 0)

"       OBJECT
call HTMLmap("inoremap", "<lead>ob", "<[{OBJECT DATA=\"\" WIDTH=\"\" HEIGHT}]=\"\"><CR></[{OBJECT}]><ESC>k$5F\"i")
call HTMLmap("vnoremap", "<lead>ob", "<ESC>`>a<CR></[{OBJECT}]><C-O>`<<[{OBJECT DATA=\"\" WIDTH=\"\" HEIGHT}]=\"\"><CR><ESC>k$5F\"", 1)
call HTMLmapo('<lead>ob', 0)

" Table stuff:
call HTMLmap("inoremap", "<lead>ca", "<[{CAPTION></CAPTION}]><C-O>F<")
call HTMLmap("inoremap", "<lead>ta", "<[{TABLE}]><CR></[{TABLE}]><ESC>O")
call HTMLmap("inoremap", "<lead>tH", "<[{THEAD}]><CR></[{THEAD}]><ESC>O")
call HTMLmap("inoremap", "<lead>tb", "<[{TBODY}]><CR></[{TBODY}]><ESC>O")
call HTMLmap("inoremap", "<lead>tf", "<[{TFOOT}]><CR></[{TFOOT}]><ESC>O")
call HTMLmap("inoremap", "<lead>tr", "<[{TR}]><CR></[{TR}]><ESC>O")
call HTMLmap("inoremap", "<lead>td", "<[{TD}]><CR></[{TD}]><ESC>O")
call HTMLmap("inoremap", "<lead>th", "<[{TH></TH}]><C-O>F<")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>ca", "<ESC>`>a<CR></[{CAPTION}]><C-O>`<<[{CAPTION}]><CR><ESC>", 1)
call HTMLmap("vnoremap", "<lead>ta", "<ESC>`>a<CR></[{TABLE}]><C-O>`<<[{TABLE}]><CR><ESC>", 1)
call HTMLmap("vnoremap", "<lead>tH", "<ESC>`>a<CR></[{THEAD}]><C-O>`<<[{THEAD}]><CR><ESC>", 1)
call HTMLmap("vnoremap", "<lead>tb", "<ESC>`>a<CR></[{TBODY}]><C-O>`<<[{TBODY}]><CR><ESC>", 1)
call HTMLmap("vnoremap", "<lead>tf", "<ESC>`>a<CR></[{TFOOT}]><C-O>`<<[{TFOOT}]><CR><ESC>", 1)
call HTMLmap("vnoremap", "<lead>tr", "<ESC>`>a<CR></[{TR}]><C-O>`<<[{TR}]><CR><ESC>", 1)
call HTMLmap("vnoremap", "<lead>td", "<ESC>`>a<CR></[{TD}]><C-O>`<<[{TD}]><CR><ESC>", 1)
call HTMLmap("vnoremap", "<lead>th", "<ESC>`>a</[{TH}]><C-O>`<<[{TH}]><ESC>", 2)
" Motion mappings:
call HTMLmapo("<lead>ca", 0)
call HTMLmapo("<lead>ta", 0)
call HTMLmapo("<lead>tH", 0)
call HTMLmapo("<lead>tb", 0)
call HTMLmapo("<lead>tf", 0)
call HTMLmapo("<lead>tr", 0)
call HTMLmapo("<lead>td", 0)
call HTMLmapo("<lead>th", 0)

" Interactively generate a table of Rows x Columns:
call HTMLmap("nnoremap", "<lead>tA", ":call HTMLgenerateTable()<CR>")

" Frames stuff:
call HTMLmap("inoremap", "<lead>fs", "<[{FRAMESET ROWS=\"\" COLS}]=\"\"><CR></[{FRAMESET}]><ESC>k$3F\"i")
call HTMLmap("inoremap", "<lead>fr", "<[{FRAME SRC}]=\"\" /><C-O>F\"")
call HTMLmap("inoremap", "<lead>nf", "<[{NOFRAMES}]><CR></[{NOFRAMES}]><ESC>O")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>fs", "<ESC>`>a<CR></[{FRAMESET}]><C-O>`<<[{FRAMESET ROWS=\"\" COLS}]=\"\"><CR><ESC>k$3F\"", 1)
call HTMLmap("vnoremap", "<lead>fr", "<ESC>`>a\" /><C-O>`<<[{FRAME SRC}]=\"<ESC>")
call HTMLmap("vnoremap", "<lead>nf", "<ESC>`>a<CR></[{NOFRAMES}]><C-O>`<<[{NOFRAMES}]><CR><ESC>", 1)
" Motion mappings:
call HTMLmapo("<lead>fs", 0)
call HTMLmapo("<lead>fr", 0)
call HTMLmapo("<lead>nf", 0)

"       IFRAME  Inline Frame            HTML 4.0
call HTMLmap("inoremap", "<lead>if", "<[{IFRAME SRC}]=\"\"><CR></[{IFRAME}]><ESC>k$F\"i")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>if", "<ESC>`>a<CR></[{IFRAME}]><C-O>`<<[{IFRAME SRC}]=\"\"><CR><ESC>k$F\"", 1)
" Motion mapping:
call HTMLmapo('<lead>if', 0)

" Forms stuff:
call HTMLmap("inoremap", "<lead>fm", "<[{FORM ACTION}]=\"\"><CR></[{FORM}]><ESC>k$F\"i")
call HTMLmap("inoremap", "<lead>bu", "<[{INPUT TYPE=\"BUTTON\" NAME=\"\" VALUE}]=\"\" /><C-O>3F\"")
call HTMLmap("inoremap", "<lead>ch", "<[{INPUT TYPE=\"CHECKBOX\" NAME=\"\" VALUE}]=\"\" /><C-O>3F\"")
call HTMLmap("inoremap", "<lead>ra", "<[{INPUT TYPE=\"RADIO\" NAME=\"\" VALUE}]=\"\" /><C-O>3F\"")
call HTMLmap("inoremap", "<lead>hi", "<[{INPUT TYPE=\"HIDDEN\" NAME=\"\" VALUE}]=\"\" /><C-O>3F\"")
call HTMLmap("inoremap", "<lead>pa", "<[{INPUT TYPE=\"PASSWORD\" NAME=\"\" VALUE=\"\" SIZE}]=\"20\" /><C-O>5F\"")
call HTMLmap("inoremap", "<lead>te", "<[{INPUT TYPE=\"TEXT\" NAME=\"\" VALUE=\"\" SIZE}]=\"20\" /><C-O>5F\"")
call HTMLmap("inoremap", "<lead>fi", "<[{INPUT TYPE=\"FILE\" NAME=\"\" VALUE=\"\" SIZE}]=\"20\" /><C-O>5F\"")
call HTMLmap("inoremap", "<lead>se", "<[{SELECT NAME}]=\"\"><CR></[{SELECT}]><ESC>O")
call HTMLmap("inoremap", "<lead>ms", "<[{SELECT NAME=\"\" MULTIPLE}]><CR></[{SELECT}]><ESC>O")
call HTMLmap("inoremap", "<lead>op", "<[{OPTION></OPTION}]><C-O>F<")
call HTMLmap("inoremap", "<lead>og", "<[{OPTGROUP LABEL}]=\"\"><CR></[{OPTGROUP}]><ESC>k$F\"i")
call HTMLmap("inoremap", "<lead>tx", "<[{TEXTAREA NAME=\"\" ROWS=\"10\" COLS}]=\"50\"><CR></[{TEXTAREA}]><ESC>k$5F\"i")
call HTMLmap("inoremap", "<lead>su", "<[{INPUT TYPE=\"SUBMIT\" VALUE}]=\"Submit\" />")
call HTMLmap("inoremap", "<lead>re", "<[{INPUT TYPE=\"RESET\" VALUE}]=\"Reset\" />")
call HTMLmap("inoremap", "<lead>la", "<[{LABEL FOR=\"\"></LABEL}]><C-O>F\"")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>fm", "<ESC>`>a<CR></[{FORM}]><C-O>`<<[{FORM ACTION}]=\"\"><CR><ESC>k$F\"", 1)
call HTMLmap("vnoremap", "<lead>bu", "<ESC>`>a\" /><C-O>`<<[{INPUT TYPE=\"BUTTON\" NAME=\"\" VALUE}]=\"<C-O>2F\"", 0)
call HTMLmap("vnoremap", "<lead>ch", "<ESC>`>a\" /><C-O>`<<[{INPUT TYPE=\"CHECKBOX\" NAME=\"\" VALUE}]=\"<C-O>2F\"", 0)
call HTMLmap("vnoremap", "<lead>ra", "<ESC>`>a\" /><C-O>`<<[{INPUT TYPE=\"RADIO\" NAME=\"\" VALUE}]=\"<C-O>2F\"", 0)
call HTMLmap("vnoremap", "<lead>hi", "<ESC>`>a\" /><C-O>`<<[{INPUT TYPE=\"HIDDEN\" NAME=\"\" VALUE}]=\"<C-O>2F\"", 0)
call HTMLmap("vnoremap", "<lead>pa", "<ESC>`>a\" [{SIZE}]=\"20\" /><C-O>`<<[{INPUT TYPE=\"PASSWORD\" NAME=\"\" VALUE}]=\"<C-O>2F\"", 0)
call HTMLmap("vnoremap", "<lead>te", "<ESC>`>a\" [{SIZE}]=\"20\" /><C-O>`<<[{INPUT TYPE=\"TEXT\" NAME=\"\" VALUE}]=\"<C-O>2F\"", 0)
call HTMLmap("vnoremap", "<lead>fi", "<ESC>`>a\" [{SIZE}]=\"20\" /><C-O>`<<[{INPUT TYPE=\"FILE\" NAME=\"\" VALUE}]=\"<C-O>2F\"", 0)
call HTMLmap("vnoremap", "<lead>se", "<ESC>`>a<CR></[{SELECT}]><C-O>`<<[{SELECT NAME}]=\"\"><CR><ESC>k$F\"", 1)
call HTMLmap("vnoremap", "<lead>ms", "<ESC>`>a<CR></[{SELECT}]><C-O>`<<[{SELECT NAME=\"\" MULTIPLE}]><CR><ESC>k$F\"", 1)
call HTMLmap("vnoremap", "<lead>op", "<ESC>`>a</[{OPTION}]><C-O>`<<[{OPTION}]><ESC>", 2)
call HTMLmap("vnoremap", "<lead>og", "<ESC>`>a<CR></[{OPTGROUP}]><C-O>`<<[{OPTGROUP LABEL}]=\"\"><CR><ESC>k$F\"", 1)
call HTMLmap("vnoremap", "<lead>tx", "<ESC>`>a<CR></[{TEXTAREA}]><C-O>`<<[{TEXTAREA NAME=\"\" ROWS=\"10\" COLS}]=\"50\"><CR><ESC>k$5F\"", 1)
call HTMLmap("vnoremap", "<lead>la", "<ESC>`>a</[{LABEL}]><C-O>`<<[{LABEL FOR}]=\"\"><C-O>F\"", 0)
call HTMLmap("vnoremap", "<lead>lA", "<ESC>`>a\"></[{LABEL}]><C-O>`<<[{LABEL FOR}]=\"<C-O>f<", 0)
" Motion mappings:
call HTMLmapo("<lead>fm", 0)
call HTMLmapo("<lead>bu", 1)
call HTMLmapo("<lead>ch", 1)
call HTMLmapo("<lead>ra", 1)
call HTMLmapo("<lead>hi", 1)
call HTMLmapo("<lead>pa", 1)
call HTMLmapo("<lead>te", 1)
call HTMLmapo("<lead>fi", 1)
call HTMLmapo("<lead>se", 0)
call HTMLmapo("<lead>ms", 0)
call HTMLmapo("<lead>op", 0)
call HTMLmapo("<lead>og", 0)
call HTMLmapo("<lead>tx", 0)
call HTMLmapo("<lead>la", 1)
call HTMLmapo("<lead>lA", 1)

" ----------------------------------------------------------------------------


" ---- Special Character (Character Entities) Mappings: ----------------- {{{1

" Convert the character under the cursor or the highlighted string to straight
" HTML entities:
call HTMLmap("vnoremap", "<lead>&", "s<C-R>=HTMLencodeString(@\")<CR><Esc>")
"call HTMLmap("nnoremap", "<lead>&", "s<C-R>=HTMLencodeString(@\")<CR><Esc>")
call HTMLmapo("<lead>&", 0)

" Convert the character under the cursor or the highlighted string to a %XX
" string:
call HTMLmap("vnoremap", "<lead>%", "s<C-R>=HTMLencodeString(@\", '%')<CR><Esc>")
"call HTMLmap("nnoremap", "<lead>%", "s<C-R>=HTMLencodeString(@\", '%')<CR><Esc>")
call HTMLmapo("<lead>%", 0)

" Decode a &#...; or %XX encoded string:
call HTMLmap("vnoremap", "<lead>^", "s<C-R>=HTMLencodeString(@\", 'd')<CR><Esc>")
call HTMLmapo("<lead>^", 0)

call HTMLmap("inoremap", "<elead>&", "&amp;")
call HTMLmap("inoremap", "<elead>cO", "&copy;")
call HTMLmap("inoremap", "<elead>rO", "&reg;")
call HTMLmap("inoremap", "<elead>tm", "&trade;")
call HTMLmap("inoremap", "<elead>'", "&quot;")
call HTMLmap("inoremap", "<elead><", "&lt;")
call HTMLmap("inoremap", "<elead>>", "&gt;")
call HTMLmap("inoremap", "<elead><space>", "&nbsp;")
call HTMLmap("inoremap", "<lead><space>", "&nbsp;")
call HTMLmap("inoremap", "<elead>#", "&pound;")
call HTMLmap("inoremap", "<elead>Y=", "&yen;")
call HTMLmap("inoremap", "<elead>c\\|", "&cent;")
call HTMLmap("inoremap", "<elead>A`", "&Agrave;")
call HTMLmap("inoremap", "<elead>A'", "&Aacute;")
call HTMLmap("inoremap", "<elead>A^", "&Acirc;")
call HTMLmap("inoremap", "<elead>A~", "&Atilde;")
call HTMLmap("inoremap", '<elead>A"', "&Auml;")
call HTMLmap("inoremap", "<elead>Ao", "&Aring;")
call HTMLmap("inoremap", "<elead>AE", "&AElig;")
call HTMLmap("inoremap", "<elead>C,", "&Ccedil;")
call HTMLmap("inoremap", "<elead>E`", "&Egrave;")
call HTMLmap("inoremap", "<elead>E'", "&Eacute;")
call HTMLmap("inoremap", "<elead>E^", "&Ecirc;")
call HTMLmap("inoremap", '<elead>E"', "&Euml;")
call HTMLmap("inoremap", "<elead>I`", "&Igrave;")
call HTMLmap("inoremap", "<elead>I'", "&Iacute;")
call HTMLmap("inoremap", "<elead>I^", "&Icirc;")
call HTMLmap("inoremap", '<elead>I"', "&Iuml;")
call HTMLmap("inoremap", "<elead>N~", "&Ntilde;")
call HTMLmap("inoremap", "<elead>O`", "&Ograve;")
call HTMLmap("inoremap", "<elead>O'", "&Oacute;")
call HTMLmap("inoremap", "<elead>O^", "&Ocirc;")
call HTMLmap("inoremap", "<elead>O~", "&Otilde;")
call HTMLmap("inoremap", '<elead>O"', "&Ouml;")
call HTMLmap("inoremap", "<elead>O/", "&Oslash;")
call HTMLmap("inoremap", "<elead>U`", "&Ugrave;")
call HTMLmap("inoremap", "<elead>U'", "&Uacute;")
call HTMLmap("inoremap", "<elead>U^", "&Ucirc;")
call HTMLmap("inoremap", '<elead>U"', "&Uuml;")
call HTMLmap("inoremap", "<elead>Y'", "&Yacute;")
call HTMLmap("inoremap", "<elead>a`", "&agrave;")
call HTMLmap("inoremap", "<elead>a'", "&aacute;")
call HTMLmap("inoremap", "<elead>a^", "&acirc;")
call HTMLmap("inoremap", "<elead>a~", "&atilde;")
call HTMLmap("inoremap", '<elead>a"', "&auml;")
call HTMLmap("inoremap", "<elead>ao", "&aring;")
call HTMLmap("inoremap", "<elead>ae", "&aelig;")
call HTMLmap("inoremap", "<elead>c,", "&ccedil;")
call HTMLmap("inoremap", "<elead>e`", "&egrave;")
call HTMLmap("inoremap", "<elead>e'", "&eacute;")
call HTMLmap("inoremap", "<elead>e^", "&ecirc;")
call HTMLmap("inoremap", '<elead>e"', "&euml;")
call HTMLmap("inoremap", "<elead>i`", "&igrave;")
call HTMLmap("inoremap", "<elead>i'", "&iacute;")
call HTMLmap("inoremap", "<elead>i^", "&icirc;")
call HTMLmap("inoremap", '<elead>i"', "&iuml;")
call HTMLmap("inoremap", "<elead>n~", "&ntilde;")
call HTMLmap("inoremap", "<elead>o`", "&ograve;")
call HTMLmap("inoremap", "<elead>o'", "&oacute;")
call HTMLmap("inoremap", "<elead>o^", "&ocirc;")
call HTMLmap("inoremap", "<elead>o~", "&otilde;")
call HTMLmap("inoremap", '<elead>o"', "&ouml;")
call HTMLmap("inoremap", "<elead>x", "&times;")
call HTMLmap("inoremap", "<elead>u`", "&ugrave;")
call HTMLmap("inoremap", "<elead>u'", "&uacute;")
call HTMLmap("inoremap", "<elead>u^", "&ucirc;")
call HTMLmap("inoremap", '<elead>u"', "&uuml;")
call HTMLmap("inoremap", "<elead>y'", "&yacute;")
call HTMLmap("inoremap", '<elead>y"', "&yuml;")
call HTMLmap("inoremap", "<elead>2<", "&laquo;")
call HTMLmap("inoremap", "<elead>2>", "&raquo;")
call HTMLmap("inoremap", '<elead>"', "&uml;")
call HTMLmap("inoremap", "<elead>/", "&divide;")
call HTMLmap("inoremap", "<elead>o/", "&oslash;")
call HTMLmap("inoremap", "<elead>sz", "&szlig;")
call HTMLmap("inoremap", "<elead>!", "&iexcl;")
call HTMLmap("inoremap", "<elead>?", "&iquest;")
call HTMLmap("inoremap", "<elead>dg", "&deg;")
call HTMLmap("inoremap", "<elead>mi", "&micro;")
call HTMLmap("inoremap", "<elead>pa", "&para;")
call HTMLmap("inoremap", "<elead>.", "&middot;")
call HTMLmap("inoremap", "<elead>14", "&frac14;")
call HTMLmap("inoremap", "<elead>12", "&frac12;")
call HTMLmap("inoremap", "<elead>34", "&frac34;")
call HTMLmap("inoremap", "<elead>n-", "&ndash;")  " Math symbol
call HTMLmap("inoremap", "<elead>2-", "&ndash;")  " ...
call HTMLmap("inoremap", "<elead>m-", "&mdash;")  " Sentence break
call HTMLmap("inoremap", "<elead>3-", "&mdash;")  " ...
call HTMLmap("inoremap", "<elead>--", "&mdash;")  " ...
call HTMLmap("inoremap", "<elead>3.", "&hellip;")
" Greek letters:
"   ... Capital:
call HTMLmap("inoremap", "<elead>Al", "&Alpha;")
call HTMLmap("inoremap", "<elead>Be", "&Beta;")
call HTMLmap("inoremap", "<elead>Ga", "&Gamma;")
call HTMLmap("inoremap", "<elead>De", "&Delta;")
call HTMLmap("inoremap", "<elead>Ep", "&Epsilon;")
call HTMLmap("inoremap", "<elead>Ze", "&Zeta;")
call HTMLmap("inoremap", "<elead>Et", "&Eta;")
call HTMLmap("inoremap", "<elead>Th", "&Theta;")
call HTMLmap("inoremap", "<elead>Io", "&Iota;")
call HTMLmap("inoremap", "<elead>Ka", "&Kappa;")
call HTMLmap("inoremap", "<elead>Lm", "&Lambda;")
call HTMLmap("inoremap", "<elead>Mu", "&Mu;")
call HTMLmap("inoremap", "<elead>Nu", "&Nu;")
call HTMLmap("inoremap", "<elead>Xi", "&Xi;")
call HTMLmap("inoremap", "<elead>Oc", "&Omicron;")
call HTMLmap("inoremap", "<elead>Pi", "&Pi;")
call HTMLmap("inoremap", "<elead>Rh", "&Rho;")
call HTMLmap("inoremap", "<elead>Si", "&Sigma;")
call HTMLmap("inoremap", "<elead>Ta", "&Tau;")
call HTMLmap("inoremap", "<elead>Up", "&Upsilon;")
call HTMLmap("inoremap", "<elead>Ph", "&Phi;")
call HTMLmap("inoremap", "<elead>Ch", "&Chi;")
call HTMLmap("inoremap", "<elead>Ps", "&Psi;")
"   ... Lowercase/small:
call HTMLmap("inoremap", "<elead>al", "&alpha;")
call HTMLmap("inoremap", "<elead>be", "&beta;")
call HTMLmap("inoremap", "<elead>ga", "&gamma;")
call HTMLmap("inoremap", "<elead>de", "&delta;")
call HTMLmap("inoremap", "<elead>ep", "&epsilon;")
call HTMLmap("inoremap", "<elead>ze", "&zeta;")
call HTMLmap("inoremap", "<elead>et", "&eta;")
call HTMLmap("inoremap", "<elead>th", "&theta;")
call HTMLmap("inoremap", "<elead>io", "&iota;")
call HTMLmap("inoremap", "<elead>ka", "&kappa;")
call HTMLmap("inoremap", "<elead>lm", "&lambda;")
call HTMLmap("inoremap", "<elead>mu", "&mu;")
call HTMLmap("inoremap", "<elead>nu", "&nu;")
call HTMLmap("inoremap", "<elead>xi", "&xi;")
call HTMLmap("inoremap", "<elead>oc", "&omicron;")
call HTMLmap("inoremap", "<elead>pi", "&pi;")
call HTMLmap("inoremap", "<elead>rh", "&rho;")
call HTMLmap("inoremap", "<elead>si", "&sigma;")
call HTMLmap("inoremap", "<elead>sf", "&sigmaf;")
call HTMLmap("inoremap", "<elead>ta", "&tau;")
call HTMLmap("inoremap", "<elead>up", "&upsilon;")
call HTMLmap("inoremap", "<elead>ph", "&phi;")
call HTMLmap("inoremap", "<elead>ch", "&chi;")
call HTMLmap("inoremap", "<elead>ps", "&psi;")
call HTMLmap("inoremap", "<elead>og", "&omega;")
call HTMLmap("inoremap", "<elead>ts", "&thetasym;")
call HTMLmap("inoremap", "<elead>uh", "&upsih;")
call HTMLmap("inoremap", "<elead>pv", "&piv;")
" single-line arrows:
call HTMLmap("inoremap", "<elead>la", "&larr;")
call HTMLmap("inoremap", "<elead>ua", "&uarr;")
call HTMLmap("inoremap", "<elead>ra", "&rarr;")
call HTMLmap("inoremap", "<elead>da", "&darr;")
call HTMLmap("inoremap", "<elead>ha", "&harr;")
"call HTMLmap("inoremap", "<elead>ca", "&crarr;")
" double-line arrows:
call HTMLmap("inoremap", "<elead>lA", "&lArr;")
call HTMLmap("inoremap", "<elead>uA", "&uArr;")
call HTMLmap("inoremap", "<elead>rA", "&rArr;")
call HTMLmap("inoremap", "<elead>dA", "&dArr;")
call HTMLmap("inoremap", "<elead>hA", "&hArr;")

" ----------------------------------------------------------------------------


" ---- Browser Remote Controls: ----------------------------------------- {{{1
if has('mac') || has('macunix')
  runtime! browser_launcher.vim

  " Run the default Mac browser:
  call HTMLmap("nnoremap", "<lead>db", ":call OpenInMacApp('default')<CR>")

  " Firefox: View current file, starting Firefox if it's not running:
  call HTMLmap("nnoremap", "<lead>ff", ":call OpenInMacApp('firefox',0)<CR>")
  " Firefox: Open a new window, and view the current file:
  call HTMLmap("nnoremap", "<lead>nff", ":call OpenInMacApp('firefox',1)<CR>")
  " Firefox: Open a new tab, and view the current file:
  call HTMLmap("nnoremap", "<lead>tff", ":call OpenInMacApp('firefox',2)<CR>")

  " Opera: View current file, starting Opera if it's not running:
  call HTMLmap("nnoremap", "<lead>oa", ":call OpenInMacApp('opera',0)<CR>")
  " Opera: View current file in a new window, starting Opera if it's not running:
  call HTMLmap("nnoremap", "<lead>noa", ":call OpenInMacApp('opera',1)<CR>")
  " Opera: Open a new tab, and view the current file:
  call HTMLmap("nnoremap", "<lead>toa", ":call OpenInMacApp('opera',2)<CR>")

  " Safari: View current file, starting Safari if it's not running:
  call HTMLmap("nnoremap", "<lead>sf", ":call OpenInMacApp('safari')<CR>")
  " Safari: Open a new window, and view the current file:
  call HTMLmap("nnoremap", "<lead>nsf", ":call OpenInMacApp('safari',1)<CR>")
  " Safari: Open a new tab, and view the current file:
  call HTMLmap("nnoremap", "<lead>tsf", ":call OpenInMacApp('safari',2)<CR>")

elseif has("unix")
  runtime! browser_launcher.vim

  if exists("*LaunchBrowser")
    " Firefox: View current file, starting Firefox if it's not running:
    call HTMLmap("nnoremap", "<lead>ff", ":call LaunchBrowser('f',0)<CR>")
    " Firefox: Open a new window, and view the current file:
    call HTMLmap("nnoremap", "<lead>nff", ":call LaunchBrowser('f',1)<CR>")
    " Firefox: Open a new tab, and view the current file:
    call HTMLmap("nnoremap", "<lead>tff", ":call LaunchBrowser('f',2)<CR>")

    " Mozilla: View current file, starting Mozilla if it's not running:
    call HTMLmap("nnoremap", "<lead>mo", ":call LaunchBrowser('m',0)<CR>")
    " Mozilla: Open a new window, and view the current file:
    call HTMLmap("nnoremap", "<lead>nmo", ":call LaunchBrowser('m',1)<CR>")
    " Mozilla: Open a new tab, and view the current file:
    call HTMLmap("nnoremap", "<lead>tmo", ":call LaunchBrowser('m',2)<CR>")

    " Netscape: View current file, starting Netscape if it's not running:
    call HTMLmap("nnoremap", "<lead>ne", ":call LaunchBrowser('n',0)<CR>")
    " Netscape: Open a new window, and view the current file:
    call HTMLmap("nnoremap", "<lead>nne", ":call LaunchBrowser('n',1)<CR>")

    " Opera: View current file, starting Opera if it's not running:
    call HTMLmap("nnoremap", "<lead>oa", ":call LaunchBrowser('o',0)<CR>")
    " Opera: View current file in a new window, starting Opera if it's not running:
    call HTMLmap("nnoremap", "<lead>noa", ":call LaunchBrowser('o',1)<CR>")
    " Opera: Open a new tab, and view the current file:
    call HTMLmap("nnoremap", "<lead>toa", ":call LaunchBrowser('o',2)<CR>")

    " Lynx:  (This happens anyway if there's no DISPLAY environmental variable.)
    call HTMLmap("nnoremap","<lead>ly",":call LaunchBrowser('l',0)<CR>")
    " Lynx in an xterm:  (This happens regardless in the Vim GUI.)
    call HTMLmap("nnoremap", "<lead>nly", ":call LaunchBrowser('l',1)<CR>")

    " w3m:
    call HTMLmap("nnoremap","<lead>w3",":call LaunchBrowser('w',0)<CR>")
    " w3m in an xterm:  (This happens regardless in the Vim GUI.)
    call HTMLmap("nnoremap", "<lead>nw3", ":call LaunchBrowser('w',1)<CR>")
  endif
elseif has("win32") || has('win64')
  " Run the default Windows browser:
   call HTMLmap("nnoremap", "<lead>db", ":exe '!start RunDll32.exe shell32.dll,ShellExec_RunDLL ' . <SID>ShellEscape(expand('%:p'))<CR>")

  " This assumes that IE is installed and the file explorer will become IE
  " when given an URL to open:
  call HTMLmap("nnoremap", "<lead>ie", ":exe '!start explorer ' . <SID>ShellEscape(expand('%:p'))<CR>")
endif

" ----------------------------------------------------------------------------

endif " ! exists("b:did_html_mappings")


" ---- ToolBar Buttons: ------------------------------------------------- {{{1
if ! has("gui_running") && ! s:BoolVar('g:force_html_menu')
  augroup HTMLplugin
  au!
  execute 'autocmd GUIEnter * source ' . s:thisfile . ' | autocmd! HTMLplugin GUIEnter *'
  augroup END
elseif exists("g:did_html_menus")
  call s:MenuControl()
elseif ! s:BoolVar('g:no_html_menu')

command! -nargs=+ HTMLmenu call s:LeadMenu(<f-args>)
function! s:LeadMenu(type, level, name, item, ...)
  if a:0 == 1
    let pre = a:1
  else
    let pre = ''
  endif

  if a:level == '-'
    let level = ''
  else
    let level = a:level
  endif

  let name = escape(a:name, ' ')

  execute a:type . ' ' . level . ' ' . name . '<tab>' . g:html_map_leader . a:item
    \ . ' ' . pre . g:html_map_leader . a:item
endfunction

if ! s:BoolVar('g:no_html_toolbar') && has("toolbar")

  if ((has("win32") || has('win64')) && globpath(&rtp, 'bitmaps/Browser.bmp') == '')
      \ || globpath(&rtp, 'bitmaps/Browser.xpm') == ''
    let s:tmp = "Warning:\nYou need to install the Toolbar Bitmaps for the "
          \ . fnamemodify(s:thisfile, ':t') . " plugin. "
          \ . "See: http://www.infynity.spodzone.com/vim/HTML/#files\n"
          \ . 'Or see ":help g:no_html_toolbar".'
    if has('win32') || has('win64') || has('unix')
      let s:tmp = confirm(s:tmp, "&Dismiss\nView &Help\nGet &Bitmaps", 1, 'Warning')
    else
      let s:tmp = confirm(s:tmp, "&Dismiss\nView &Help", 1, 'Warning')
    endif

    if s:tmp == 2
      help g:no_html_toolbar
      " Go to the previous window or everything gets messy:
      wincmd p
    elseif s:tmp == 3
      if has('win32') || has('win64')
        execute '!start RunDll32.exe shell32.dll,ShellExec_RunDLL http://www.infynity.spodzone.com/vim/HTML/\#files'
      else
        call LaunchBrowser('default', 2, 'http://www.infynity.spodzone.com/vim/HTML/#files')
      endif
    endif

    unlet s:tmp
  endif

  set guioptions+=T

  "tunmenu ToolBar
  silent! unmenu ToolBar
  silent! unmenu! ToolBar

  tmenu 1.10      ToolBar.Open      Open file
  amenu 1.10      ToolBar.Open      :browse e<CR>
  tmenu 1.20      ToolBar.Save      Save current file
  amenu 1.20      ToolBar.Save      :w<CR>
  tmenu 1.30      ToolBar.SaveAll   Save all files
  amenu 1.30      ToolBar.SaveAll   :wa<CR>

   menu 1.50      ToolBar.-sep1-    <nul>

  tmenu           1.60  ToolBar.Template   Create Template
  HTMLmenu amenu  1.60  ToolBar.Template   html

   menu           1.65  ToolBar.-sep2-     <nul>

  tmenu           1.70  ToolBar.Paragraph  Create Paragraph
  HTMLmenu imenu  1.70  ToolBar.Paragraph  pp
  HTMLmenu vmenu  1.70  ToolBar.Paragraph  pp
  HTMLmenu nmenu  1.70  ToolBar.Paragraph  pp i
  tmenu           1.80  ToolBar.Break      Line Break
  HTMLmenu imenu  1.80  ToolBar.Break      br
  HTMLmenu vmenu  1.80  ToolBar.Break      br
  HTMLmenu nmenu  1.80  ToolBar.Break      br i

   menu           1.85  ToolBar.-sep3-     <nul>

  tmenu           1.90  ToolBar.Link       Create Hyperlink
  HTMLmenu imenu  1.90  ToolBar.Link       ah
  HTMLmenu vmenu  1.90  ToolBar.Link       ah
  HTMLmenu nmenu  1.90  ToolBar.Link       ah i
  tmenu           1.100 ToolBar.Target     Create Target (Named Anchor)
  HTMLmenu imenu  1.100 ToolBar.Target     an
  HTMLmenu vmenu  1.100 ToolBar.Target     an
  HTMLmenu nmenu  1.100 ToolBar.Target     an i
  tmenu           1.110 ToolBar.Image      Insert Image
  HTMLmenu imenu  1.110 ToolBar.Image      im
  HTMLmenu vmenu  1.110 ToolBar.Image      im
  HTMLmenu nmenu  1.110 ToolBar.Image      im i

   menu           1.115 ToolBar.-sep4-     <nul>

  tmenu           1.120 ToolBar.Hline      Create Horizontal Rule
  HTMLmenu imenu  1.120 ToolBar.Hline      hr
  HTMLmenu nmenu  1.120 ToolBar.Hline      hr i

   menu           1.125 ToolBar.-sep5-     <nul>

  tmenu           1.130 ToolBar.Table      Create Table
  HTMLmenu imenu  1.130 ToolBar.Table     tA <ESC>
  HTMLmenu nmenu  1.130 ToolBar.Table     tA

   menu           1.135 ToolBar.-sep6-     <nul>

  tmenu           1.140 ToolBar.Blist      Create Bullet List
  exe 'imenu      1.140 ToolBar.Blist'     g:html_map_leader . 'ul' . g:html_map_leader . 'li'
  exe 'vmenu      1.140 ToolBar.Blist'     g:html_map_leader . 'uli' . g:html_map_leader . 'li<ESC>'
  exe 'nmenu      1.140 ToolBar.Blist'     'i' . g:html_map_leader . 'ul' . g:html_map_leader . 'li'
  tmenu           1.150 ToolBar.Nlist      Create Numbered List
  exe 'imenu      1.150 ToolBar.Nlist'     g:html_map_leader . 'ol' . g:html_map_leader . 'li'
  exe 'vmenu      1.150 ToolBar.Nlist'     g:html_map_leader . 'oli' . g:html_map_leader . 'li<ESC>'
  exe 'nmenu      1.150 ToolBar.Nlist'     'i' . g:html_map_leader . 'ol' . g:html_map_leader . 'li'
  tmenu           1.160 ToolBar.Litem      Add List Item
  HTMLmenu imenu  1.160 ToolBar.Litem      li
  HTMLmenu nmenu  1.160 ToolBar.Litem      li i

   menu           1.165 ToolBar.-sep7-     <nul>

  tmenu           1.170 ToolBar.Bold       Bold
  HTMLmenu imenu  1.170 ToolBar.Bold       bo
  HTMLmenu vmenu  1.170 ToolBar.Bold       bo
  HTMLmenu nmenu  1.170 ToolBar.Bold       bo i
  tmenu           1.180 ToolBar.Italic     Italic
  HTMLmenu imenu  1.180 ToolBar.Italic     it
  HTMLmenu vmenu  1.180 ToolBar.Italic     it
  HTMLmenu nmenu  1.180 ToolBar.Italic     it i
  tmenu           1.190 ToolBar.Underline  Underline
  HTMLmenu imenu  1.190 ToolBar.Underline  un
  HTMLmenu vmenu  1.190 ToolBar.Underline  un
  HTMLmenu nmenu  1.190 ToolBar.Underline  un i

   menu           1.195 ToolBar.-sep8-    <nul>

  tmenu           1.200 ToolBar.Cut       Cut to clipboard
  vmenu           1.200 ToolBar.Cut       "*x
  tmenu           1.210 ToolBar.Copy      Copy to clipboard
  vmenu           1.210 ToolBar.Copy      "*y
  tmenu           1.220 ToolBar.Paste     Paste from Clipboard
  nmenu           1.220 ToolBar.Paste     i<C-R>*<Esc>
  vmenu           1.220 ToolBar.Paste     "-xi<C-R>*<Esc>
  menu!           1.220 ToolBar.Paste     <C-R>*

   menu           1.225 ToolBar.-sep9-    <nul>

  tmenu           1.230 ToolBar.Find      Find...
  tmenu           1.240 ToolBar.Replace   Find & Replace

  if has("win32") || has('win64') || has("win16") || has("gui_gtk") || has("gui_motif")
    amenu 1.250 ToolBar.Find    :promptfind<CR>
    vunmenu     ToolBar.Find
    vmenu       ToolBar.Find    y:promptfind <C-R>"<CR>
    amenu 1.260 ToolBar.Replace :promptrepl<CR>
    vunmenu     ToolBar.Replace
    vmenu       ToolBar.Replace y:promptrepl <C-R>"<CR>
  else
    amenu 1.250 ToolBar.Find    /
    amenu 1.260 ToolBar.Replace :%s/
    vunmenu     ToolBar.Replace
    vmenu       ToolBar.Replace :s/
  endif


  if exists("*LaunchBrowser")
    amenu 1.500 ToolBar.-sep50- <nul>

    let s:browsers = LaunchBrowser()

    if s:browsers =~ 'f'
      tmenu           1.510 ToolBar.Firefox   Launch Firefox on Current File
      HTMLmenu amenu  1.510 ToolBar.Firefox   ff
    elseif s:browsers =~ 'm'
      tmenu           1.510 ToolBar.Mozilla   Launch Mozilla on Current File
      HTMLmenu amenu  1.510 ToolBar.Mozilla   mo
    elseif s:browsers =~ 'n'
      tmenu           1.510 ToolBar.Netscape  Launch Netscape on Current File
      HTMLmenu amenu  1.510 ToolBar.Netscape  ne
    endif

    if s:browsers =~ 'o'
      tmenu           1.520 ToolBar.Opera     Launch Opera on Current File
      HTMLmenu amenu  1.520 ToolBar.Opera     oa
    endif

    if s:browsers =~ 'w'
      tmenu           1.530 ToolBar.w3m       Launch w3m on Current File
      HTMLmenu amenu  1.530 ToolBar.w3m       w3
    elseif s:browsers =~ 'l'
      tmenu           1.530 ToolBar.Lynx      Launch Lynx on Current File
      HTMLmenu amenu  1.530 ToolBar.Lynx      ly
    endif

  elseif maparg(g:html_map_leader . 'db', 'n') != ''
    amenu 1.500 ToolBar.-sep50- <nul>

    tmenu          1.510 ToolBar.Browser Launch Default Browser on Current File
    HTMLmenu amenu 1.510 ToolBar.Browser db
  endif

  amenu 1.998 ToolBar.-sep99- <nul>
  tmenu 1.999 ToolBar.Help    HTML Help
  amenu 1.999 ToolBar.Help    :help HTML<CR>

  let did_html_toolbar = 1
endif  " ! s:BoolVar('g:no_html_toolbar') && has("toolbar")
" ----------------------------------------------------------------------------


" ---- Menu Items: ------------------------------------------------------ {{{1

" Add to the PopUp menu:   {{{2
nnoremenu 1.91 PopUp.Select\ Ta&g vat
onoremenu 1.91 PopUp.Select\ Ta&g at
vnoremenu 1.91 PopUp.Select\ Ta&g <C-C>vat
inoremenu 1.91 PopUp.Select\ Ta&g <C-O>vat
cnoremenu 1.91 PopUp.Select\ Ta&g <C-C>vat

nnoremenu 1.92 PopUp.Select\ &Inner\ Ta&g vit
onoremenu 1.92 PopUp.Select\ &Inner\ Ta&g it
vnoremenu 1.92 PopUp.Select\ &Inner\ Ta&g <C-C>vit
inoremenu 1.92 PopUp.Select\ &Inner\ Ta&g <C-O>vit
cnoremenu 1.92 PopUp.Select\ &Inner\ Ta&g <C-C>vit
" }}}2

augroup HTMLmenu
au!
"autocmd BufLeave * call s:MenuControl()
autocmd BufEnter,WinEnter * call s:MenuControl()
augroup END

amenu HTM&L.HTML\ Help<TAB>:help\ HTML\.txt :help HTML.txt<CR>
 menu HTML.-sep1- <nul>

amenu HTML.Co&ntrol.&Disable\ Mappings<tab>:HTML\ disable     :HTMLmappings disable<CR>
amenu HTML.Co&ntrol.&Enable\ Mappings<tab>:HTML\ enable       :HTMLmappings enable<CR>
amenu disable HTML.Control.Enable\ Mappings
 menu HTML.Control.-sep1- <nul>
amenu HTML.Co&ntrol.Switch\ to\ &HTML\ mode<tab>:HTML\ html   :HTMLmappings html<CR>
amenu HTML.Co&ntrol.Switch\ to\ &XHTML\ mode<tab>:HTML\ xhtml :HTMLmappings xhtml<CR>
 menu HTML.Control.-sep2- <nul>
amenu HTML.Co&ntrol.&Reload\ Mappings<tab>:HTML\ reload       :HTMLmappings reload<CR>

if s:BoolVar('b:do_xhtml_mappings')
  amenu disable HTML.Control.Switch\ to\ XHTML\ mode
else
  amenu disable HTML.Control.Switch\ to\ HTML\ mode
endif

 "menu HTML.-sep2- <nul>

if exists("*LaunchBrowser")
  let s:browsers = LaunchBrowser()

  if s:browsers =~ 'f'
    HTMLmenu amenu - HTML.&Preview.&Firefox                ff
    HTMLmenu amenu - HTML.&Preview.Firefox\ (New\ Window)  nff
    HTMLmenu amenu - HTML.&Preview.Firefox\ (New\ Tab)     tff
    amenu HTML.Preview.-sep1-                              <nop>
  endif
  if s:browsers =~ 'm'
    HTMLmenu amenu - HTML.&Preview.&Mozilla                mo
    HTMLmenu amenu - HTML.&Preview.Mozilla\ (New\ Window)  nmo
    HTMLmenu amenu - HTML.&Preview.Mozilla\ (New\ Tab)     tmo
    amenu HTML.Preview.-sep2-                              <nop>
  endif
  if s:browsers =~ 'n'
    HTMLmenu amenu - HTML.&Preview.&Netscape               ne
    HTMLmenu amenu - HTML.&Preview.Netscape\ (New\ Window) nne
    amenu HTML.Preview.-sep3-                              <nop>
  endif
  if s:browsers =~ 'o'
    HTMLmenu amenu - HTML.&Preview.&Opera                  oa
    HTMLmenu amenu - HTML.&Preview.Opera\ (New\ Window)    noa
    HTMLmenu amenu - HTML.&Preview.Opera\ (New\ Tab)       toa
    amenu HTML.Preview.-sep4-                              <nop>
  endif
  if s:browsers =~ 'l'
    HTMLmenu amenu - HTML.&Preview.&Lynx                   ly
  endif
  if s:browsers =~ 'w'
    HTMLmenu amenu - HTML.&Preview.&w3m                    w3
  endif
elseif exists("*OpenInMacApp")
  HTMLmenu amenu - HTML.&Preview.&Firefox                ff
  HTMLmenu amenu - HTML.&Preview.Firefox\ (New\ Window)  nff
  HTMLmenu amenu - HTML.&Preview.Firefox\ (New\ Tab)     tff
  amenu HTML.Preview.-sep1-                              <nop>

  HTMLmenu amenu - HTML.&Preview.&Opera                  oa
  HTMLmenu amenu - HTML.&Preview.Opera\ (New\ Window)    noa
  HTMLmenu amenu - HTML.&Preview.Opera\ (New\ Tab)       toa
  amenu HTML.Preview.-sep2-                              <nop>

  HTMLmenu amenu - HTML.&Preview.&Safari                 sf
  HTMLmenu amenu - HTML.&Preview.Safari\ (New\ Window)   nsf
  HTMLmenu amenu - HTML.&Preview.Safari\ (New\ Tab)      tsf
  amenu HTML.Preview.-sep3-                              <nop>

  HTMLmenu amenu - HTML.&Preview.&Default\ Browser    db
elseif maparg(g:html_map_leader . 'db', 'n') != ''
  HTMLmenu amenu - HTML.&Preview.&Default\ Browser    db
  HTMLmenu amenu - HTML.&Preview.&Internet\ Explorer  ie
endif

 menu HTML.-sep4- <nul>

HTMLmenu amenu - HTML.Template html

 menu HTML.-sep5- <nul>

" Character Entities menu:   {{{2

"let b:save_encoding=&encoding
"let &encoding='latin1'
scriptencoding latin1

command! -nargs=+ HTMLemenu call s:EntityMenu(<f-args>)
function! s:EntityMenu(name, item, ...)
  if a:0 >= 1 && a:1 != '-'
    if a:1 == '\-'
      let symb = ' (-)'
    else
      let symb = ' (' . a:1 . ')'
    endif
  else
    let symb = ''
  endif

  if a:0 >= 2
    let pre = a:2
  else
    let pre = ''
  endif

  let name = escape(a:name, ' ')

  execute 'imenu ' . name . escape(symb, ' &<.|') . '<tab>'
        \ . escape(g:html_map_entity_leader, '&\')
        \ . escape(a:item, '&<') . ' ' . pre
        \ . g:html_map_entity_leader . a:item
  execute 'nmenu ' . name . escape(symb, ' &<.|') . '<tab>'
        \ . escape(g:html_map_entity_leader, '&\')
        \ . escape(a:item, '&<') . ' ' . pre . 'i'
        \ . g:html_map_entity_leader . a:item . '<esc>'
endfunction


HTMLmenu vmenu - HTML.Character\ &Entities.Convert\ to\ Entity                &
"HTMLmenu nmenu - HTML.Character\ &Entities.Convert\ to\ Entity                &l
HTMLmenu vmenu - HTML.Character\ &Entities.Convert\ to\ %XX\ (URI\ Encode\)   %
"HTMLmenu nmenu - HTML.Character\ &Entities.Convert\ to\ %XX\ (URI\ Encode\)   %l
HTMLmenu vmenu - HTML.Character\ &Entities.Convert\ from\ Entities/%XX        ^

 menu HTML.Character\ Entities.-sep0- <nul>
HTMLemenu HTML.Character\ Entities.Ampersand            &
HTMLemenu HTML.Character\ Entities.Greaterthan          >        >
HTMLemenu HTML.Character\ Entities.Lessthan             <        <
HTMLemenu HTML.Character\ Entities.Space                <space>  nonbreaking
HTMLemenu HTML.Character\ Entities.Quotation\ mark      '        "
 menu HTML.Character\ Entities.-sep1- <nul>
HTMLemenu HTML.Character\ Entities.Cent                 c\|      ¢
HTMLemenu HTML.Character\ Entities.Pound                #        £
HTMLemenu HTML.Character\ Entities.Yen                  Y=       ¥
HTMLemenu HTML.Character\ Entities.Left\ Angle\ Quote   2<       «
HTMLemenu HTML.Character\ Entities.Right\ Angle\ Quote  2>       »
HTMLemenu HTML.Character\ Entities.Copyright            cO       ©
HTMLemenu HTML.Character\ Entities.Registered           rO       ®
HTMLemenu HTML.Character\ Entities.Trademark            tm       TM
HTMLemenu HTML.Character\ Entities.Multiply             x        ×
HTMLemenu HTML.Character\ Entities.Divide / ÷
HTMLemenu HTML.Character\ Entities.Inverted\ Exlamation !        ¡
HTMLemenu HTML.Character\ Entities.Inverted\ Question   ?        ¿
HTMLemenu HTML.Character\ Entities.Degree               dg       °
HTMLemenu HTML.Character\ Entities.Micro                mi       µ
HTMLemenu HTML.Character\ Entities.Paragraph            pa       ¶
HTMLemenu HTML.Character\ Entities.Middle\ Dot          .        ·
HTMLemenu HTML.Character\ Entities.One\ Quarter         14       ¼
HTMLemenu HTML.Character\ Entities.One\ Half            12       ½
HTMLemenu HTML.Character\ Entities.Three\ Quarters      34       ¾
HTMLemenu HTML.Character\ Entities.En\ dash             n-       \-
HTMLemenu HTML.Character\ Entities.Em\ dash             m-       --
HTMLemenu HTML.Character\ Entities.Ellipsis             3.       ...
 menu HTML.Character\ Entities.-sep2- <nul>
HTMLemenu HTML.Character\ Entities.&Graves.A-grave A` À
HTMLemenu HTML.Character\ Entities.&Graves.a-grave a` à
HTMLemenu HTML.Character\ Entities.&Graves.E-grave E` È
HTMLemenu HTML.Character\ Entities.&Graves.e-grave e` è
HTMLemenu HTML.Character\ Entities.&Graves.I-grave I` Ì
HTMLemenu HTML.Character\ Entities.&Graves.i-grave i` ì
HTMLemenu HTML.Character\ Entities.&Graves.O-grave O` Ò
HTMLemenu HTML.Character\ Entities.&Graves.o-grave o` ò
HTMLemenu HTML.Character\ Entities.&Graves.U-grave U` Ù
HTMLemenu HTML.Character\ Entities.&Graves.u-grave u` ù
HTMLemenu HTML.Character\ Entities.&Acutes.A-acute A' Á
HTMLemenu HTML.Character\ Entities.&Acutes.a-acute a' á
HTMLemenu HTML.Character\ Entities.&Acutes.E-acute E' É
HTMLemenu HTML.Character\ Entities.&Acutes.e-acute e' é
HTMLemenu HTML.Character\ Entities.&Acutes.I-acute I' Í
HTMLemenu HTML.Character\ Entities.&Acutes.i-acute i' í
HTMLemenu HTML.Character\ Entities.&Acutes.O-acute O' Ó
HTMLemenu HTML.Character\ Entities.&Acutes.o-acute o' ó
HTMLemenu HTML.Character\ Entities.&Acutes.U-acute U' Ú
HTMLemenu HTML.Character\ Entities.&Acutes.u-acute u' ú
HTMLemenu HTML.Character\ Entities.&Acutes.Y-acute Y' Ý
HTMLemenu HTML.Character\ Entities.&Acutes.y-acute y' ý
HTMLemenu HTML.Character\ Entities.&Tildes.A-tilde A~ Ã
HTMLemenu HTML.Character\ Entities.&Tildes.a-tilde a~ ã
HTMLemenu HTML.Character\ Entities.&Tildes.N-tilde N~ Ñ
HTMLemenu HTML.Character\ Entities.&Tildes.n-tilde n~ ñ
HTMLemenu HTML.Character\ Entities.&Tildes.O-tilde O~ Õ
HTMLemenu HTML.Character\ Entities.&Tildes.o-tilde o~ õ
HTMLemenu HTML.Character\ Entities.&Circumflexes.A-circumflex A^ Â
HTMLemenu HTML.Character\ Entities.&Circumflexes.a-circumflex a^ â
HTMLemenu HTML.Character\ Entities.&Circumflexes.E-circumflex E^ Ê
HTMLemenu HTML.Character\ Entities.&Circumflexes.e-circumflex e^ ê
HTMLemenu HTML.Character\ Entities.&Circumflexes.I-circumflex I^ Î
HTMLemenu HTML.Character\ Entities.&Circumflexes.i-circumflex i^ î
HTMLemenu HTML.Character\ Entities.&Circumflexes.O-circumflex O^ Ô
HTMLemenu HTML.Character\ Entities.&Circumflexes.o-circumflex o^ ô
HTMLemenu HTML.Character\ Entities.&Circumflexes.U-circumflex U^ Û
HTMLemenu HTML.Character\ Entities.&Circumflexes.u-circumflex u^ û
HTMLemenu HTML.Character\ Entities.&Umlauts.A-umlaut A" Ä
HTMLemenu HTML.Character\ Entities.&Umlauts.a-umlaut a" ä
HTMLemenu HTML.Character\ Entities.&Umlauts.E-umlaut E" Ë
HTMLemenu HTML.Character\ Entities.&Umlauts.e-umlaut e" ë
HTMLemenu HTML.Character\ Entities.&Umlauts.I-umlaut I" Ï
HTMLemenu HTML.Character\ Entities.&Umlauts.i-umlaut i" ï
HTMLemenu HTML.Character\ Entities.&Umlauts.O-umlaut O" Ö
HTMLemenu HTML.Character\ Entities.&Umlauts.o-umlaut o" ö
HTMLemenu HTML.Character\ Entities.&Umlauts.U-umlaut U" Ü
HTMLemenu HTML.Character\ Entities.&Umlauts.u-umlaut u" ü
HTMLemenu HTML.Character\ Entities.&Umlauts.y-umlaut y" ÿ
HTMLemenu HTML.Character\ Entities.&Umlauts.Umlaut   "  ¨
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Uppercase.Alpha    Al
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Uppercase.Beta     Be
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Uppercase.Gamma    Ga
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Uppercase.Delta    De
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Uppercase.Epsilon  Ep
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Uppercase.Zeta     Ze
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Uppercase.Eta      Et
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Uppercase.Theta    Th
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Uppercase.Iota     Io
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Uppercase.Kappa    Ka
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Uppercase.Lambda   Lm
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Uppercase.Mu       Mu
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Uppercase.Nu       Nu
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Uppercase.Xi       Xi
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Uppercase.Omicron  Oc
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Uppercase.Pi       Pi
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Uppercase.Rho      Rh
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Uppercase.Sigma    Si
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Uppercase.Tau      Ta
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Uppercase.Upsilon  Up
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Uppercase.Phi      Ph
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Uppercase.Chi      Ch
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Uppercase.Psi      Ps
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.alpha    al
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.beta     be
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.gamma    ga
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.delta    de
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.epsilon  ep
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.zeta     ze
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.eta      et
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.theta    th
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.iota     io
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.kappa    ka
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.lambda   lm
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.mu       mu
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.nu       nu
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.xi       xi
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.omicron  oc
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.pi       pi
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.rho      rh
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.sigma    si
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.sigmaf   sf
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.tau      ta
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.upsilon  up
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.phi      ph
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.chi      ch
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.psi      ps
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.omega    og
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.thetasym ts
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.upsih    uh
HTMLemenu HTML.Character\ Entities.Greek\ &Letters.&Lowercase.piv      pv
HTMLemenu HTML.Character\ Entities.A&rrows.Left\ single\ arrow        la
HTMLemenu HTML.Character\ Entities.A&rrows.Right\ single\ arrow       ra
HTMLemenu HTML.Character\ Entities.A&rrows.Up\ single\ arrow          ua
HTMLemenu HTML.Character\ Entities.A&rrows.Down\ single\ arrow        da
HTMLemenu HTML.Character\ Entities.A&rrows.Left-right\ single\ arrow  ha
imenu HTML.Character\ Entities.Arrows.-sep1-                             <nul>
HTMLemenu HTML.Character\ Entities.A&rrows.Left\ double\ arrow        lA
HTMLemenu HTML.Character\ Entities.A&rrows.Right\ double\ arrow       rA
HTMLemenu HTML.Character\ Entities.A&rrows.Up\ double\ arrow          uA
HTMLemenu HTML.Character\ Entities.A&rrows.Down\ double\ arrow        dA
HTMLemenu HTML.Character\ Entities.A&rrows.Left-right\ double\ arrow  hA
HTMLemenu HTML.Character\ Entities.\ \ \ \ \ \ \ &etc\.\.\..A-ring      Ao Å
HTMLemenu HTML.Character\ Entities.\ \ \ \ \ \ \ &etc\.\.\..a-ring      ao å
HTMLemenu HTML.Character\ Entities.\ \ \ \ \ \ \ &etc\.\.\..AE-ligature AE Æ
HTMLemenu HTML.Character\ Entities.\ \ \ \ \ \ \ &etc\.\.\..ae-ligature ae æ
HTMLemenu HTML.Character\ Entities.\ \ \ \ \ \ \ &etc\.\.\..C-cedilla   C, Ç
HTMLemenu HTML.Character\ Entities.\ \ \ \ \ \ \ &etc\.\.\..c-cedilla   c, ç
HTMLemenu HTML.Character\ Entities.\ \ \ \ \ \ \ &etc\.\.\..O-slash     O/ Ø
HTMLemenu HTML.Character\ Entities.\ \ \ \ \ \ \ &etc\.\.\..o-slash     o/ ø

"let &encoding=b:save_encoding
"unlet b:save_encoding
scriptencoding

" Colors menu:   {{{2

command! -nargs=+ HTMLcmenu call s:ColorsMenu(<f-args>)
let s:colors_sort = {
      \ 'A': 'A',   'B': 'B',   'C': 'C',
      \ 'D': 'D',   'E': 'E-G', 'F': 'E-G',
      \ 'G': 'E-G', 'H': 'H-K', 'I': 'H-K',
      \ 'J': 'H-K', 'K': 'H-K', 'L': 'L',
      \ 'M': 'M',   'N': 'N-O', 'O': 'N-O',
      \ 'P': 'P',   'Q': 'Q-R', 'R': 'Q-R',
      \ 'S': 'S',   'T': 'T-Z', 'U': 'T-Z',
      \ 'V': 'T-Z', 'W': 'T-Z', 'X': 'T-Z',
      \ 'Y': 'T-Z', 'Z': 'T-Z',
    \}
let s:color_list = {}
function! s:ColorsMenu(name, color)
  let c = toupper(strpart(a:name, 0, 1))
  let name = substitute(a:name, '\C\([a-z]\)\([A-Z]\)', '\1\ \2', 'g')
  execute 'imenu HTML.&Colors.&' . s:colors_sort[c] . '.' . escape(name, ' ')
        \ . '<tab>(' . a:color . ') ' . a:color
  execute 'nmenu HTML.&Colors.&' . s:colors_sort[c] . '.' . escape(name, ' ')
        \ . '<tab>(' . a:color . ') i' . a:color . '<esc>'
  call extend(s:color_list, {name : a:color})
endfunction

if has('gui_running')
  command! -nargs=? ColorSelect call s:ShowColors(<f-args>)
  
  call HTMLmap("nnoremap", "<lead>#", ":ColorSelect<CR>")
  call HTMLmap("inoremap", "<lead>#", "<C-O>:ColorSelect<CR>")

  HTMLmenu amenu - HTML.&Colors.Display\ All\ &&\ Select #
  amenu HTML.Colors.-sep1- <nul>
endif

HTMLcmenu AliceBlue            #F0F8FF
HTMLcmenu AntiqueWhite         #FAEBD7
HTMLcmenu Aqua                 #00FFFF
HTMLcmenu Aquamarine           #7FFFD4
HTMLcmenu Azure                #F0FFFF

HTMLcmenu Beige                #F5F5DC
HTMLcmenu Bisque               #FFE4C4
HTMLcmenu Black                #000000
HTMLcmenu BlanchedAlmond       #FFEBCD
HTMLcmenu Blue                 #0000FF
HTMLcmenu BlueViolet           #8A2BE2
HTMLcmenu Brown                #A52A2A
HTMLcmenu Burlywood            #DEB887

HTMLcmenu CadetBlue            #5F9EA0
HTMLcmenu Chartreuse           #7FFF00
HTMLcmenu Chocolate            #D2691E
HTMLcmenu Coral                #FF7F50
HTMLcmenu CornflowerBlue       #6495ED
HTMLcmenu Cornsilk             #FFF8DC
HTMLcmenu Crimson              #DC143C
HTMLcmenu Cyan                 #00FFFF

HTMLcmenu DarkBlue             #00008B
HTMLcmenu DarkCyan             #008B8B
HTMLcmenu DarkGoldenrod        #B8860B
HTMLcmenu DarkGray             #A9A9A9
HTMLcmenu DarkGreen            #006400
HTMLcmenu DarkKhaki            #BDB76B
HTMLcmenu DarkMagenta          #8B008B
HTMLcmenu DarkOliveGreen       #556B2F
HTMLcmenu DarkOrange           #FF8C00
HTMLcmenu DarkOrchid           #9932CC
HTMLcmenu DarkRed              #8B0000
HTMLcmenu DarkSalmon           #E9967A
HTMLcmenu DarkSeagreen         #8FBC8F
HTMLcmenu DarkSlateBlue        #483D8B
HTMLcmenu DarkSlateGray        #2F4F4F
HTMLcmenu DarkTurquoise        #00CED1
HTMLcmenu DarkViolet           #9400D3
HTMLcmenu DeepPink             #FF1493
HTMLcmenu DeepSkyblue          #00BFFF
HTMLcmenu DimGray              #696969
HTMLcmenu DodgerBlue           #1E90FF

HTMLcmenu Firebrick            #B22222
HTMLcmenu FloralWhite          #FFFAF0
HTMLcmenu ForestGreen          #228B22
HTMLcmenu Fuchsia              #FF00FF
HTMLcmenu Gainsboro            #DCDCDC
HTMLcmenu GhostWhite           #F8F8FF
HTMLcmenu Gold                 #FFD700
HTMLcmenu Goldenrod            #DAA520
HTMLcmenu Gray                 #808080
HTMLcmenu Green                #008000
HTMLcmenu GreenYellow          #ADFF2F

HTMLcmenu Honeydew             #F0FFF0
HTMLcmenu HotPink              #FF69B4
HTMLcmenu IndianRed            #CD5C5C
HTMLcmenu Indigo               #4B0082
HTMLcmenu Ivory                #FFFFF0
HTMLcmenu Khaki                #F0E68C

HTMLcmenu Lavender             #E6E6FA
HTMLcmenu LavenderBlush        #FFF0F5
HTMLcmenu LawnGreen            #7CFC00
HTMLcmenu LemonChiffon         #FFFACD
HTMLcmenu LightBlue            #ADD8E6
HTMLcmenu LightCoral           #F08080
HTMLcmenu LightCyan            #E0FFFF
HTMLcmenu LightGoldenrodYellow #FAFAD2
HTMLcmenu LightGreen           #90EE90
HTMLcmenu LightGrey            #D3D3D3
HTMLcmenu LightPink            #FFB6C1
HTMLcmenu LightSalmon          #FFA07A
HTMLcmenu LightSeaGreen        #20B2AA
HTMLcmenu LightSkyBlue         #87CEFA
HTMLcmenu LightSlaTegray       #778899
HTMLcmenu LightSteelBlue       #B0C4DE
HTMLcmenu LightYellow          #FFFFE0
HTMLcmenu Lime                 #00FF00
HTMLcmenu LimeGreen            #32CD32
HTMLcmenu Linen                #FAF0E6

HTMLcmenu Magenta              #FF00FF
HTMLcmenu Maroon               #800000
HTMLcmenu MediumAquamarine     #66CDAA
HTMLcmenu MediumBlue           #0000CD
HTMLcmenu MediumOrchid         #BA55D3
HTMLcmenu MediumPurple         #9370DB
HTMLcmenu MediumSeaGreen       #3CB371
HTMLcmenu MediumSlateBlue      #7B68EE
HTMLcmenu MediumSpringGreen    #00FA9A
HTMLcmenu MediumTurquoise      #48D1CC
HTMLcmenu MediumVioletRed      #C71585
HTMLcmenu MidnightBlue         #191970
HTMLcmenu Mintcream            #F5FFFA
HTMLcmenu Mistyrose            #FFE4E1
HTMLcmenu Moccasin             #FFE4B5

HTMLcmenu NavajoWhite          #FFDEAD
HTMLcmenu Navy                 #000080
HTMLcmenu OldLace              #FDF5E6
HTMLcmenu Olive                #808000
HTMLcmenu OliveDrab            #6B8E23
HTMLcmenu Orange               #FFA500
HTMLcmenu OrangeRed            #FF4500
HTMLcmenu Orchid               #DA70D6

HTMLcmenu PaleGoldenrod        #EEE8AA
HTMLcmenu PaleGreen            #98FB98
HTMLcmenu PaleTurquoise        #AFEEEE
HTMLcmenu PaleVioletred        #DB7093
HTMLcmenu Papayawhip           #FFEFD5
HTMLcmenu Peachpuff            #FFDAB9
HTMLcmenu Peru                 #CD853F
HTMLcmenu Pink                 #FFC0CB
HTMLcmenu Plum                 #DDA0DD
HTMLcmenu PowderBlue           #B0E0E6
HTMLcmenu Purple               #800080

HTMLcmenu Red                  #FF0000
HTMLcmenu RosyBrown            #BC8F8F
HTMLcmenu RoyalBlue            #4169E1

HTMLcmenu SaddleBrown          #8B4513
HTMLcmenu Salmon               #FA8072
HTMLcmenu SandyBrown           #F4A460
HTMLcmenu SeaGreen             #2E8B57
HTMLcmenu Seashell             #FFF5EE
HTMLcmenu Sienna               #A0522D
HTMLcmenu Silver               #C0C0C0
HTMLcmenu SkyBlue              #87CEEB
HTMLcmenu SlateBlue            #6A5ACD
HTMLcmenu SlateGray            #708090
HTMLcmenu Snow                 #FFFAFA
HTMLcmenu SpringGreen          #00FF7F
HTMLcmenu SteelBlue            #4682B4

HTMLcmenu Tan                  #D2B48C
HTMLcmenu Teal                 #008080
HTMLcmenu Thistle              #D8BFD8
HTMLcmenu Tomato               #FF6347
HTMLcmenu Turquoise            #40E0D0
HTMLcmenu Violet               #EE82EE

" Font Styles menu:   {{{2

HTMLmenu imenu - HTML.Font\ &Styles.Bold      bo
HTMLmenu vmenu - HTML.Font\ &Styles.Bold      bo
HTMLmenu nmenu - HTML.Font\ &Styles.Bold      bo i
HTMLmenu imenu - HTML.Font\ &Styles.Strong    st
HTMLmenu vmenu - HTML.Font\ &Styles.Strong    st
HTMLmenu nmenu - HTML.Font\ &Styles.Strong    st i
HTMLmenu imenu - HTML.Font\ &Styles.Italics   it
HTMLmenu vmenu - HTML.Font\ &Styles.Italics   it
HTMLmenu nmenu - HTML.Font\ &Styles.Italics   it i
HTMLmenu imenu - HTML.Font\ &Styles.Emphasis  em
HTMLmenu vmenu - HTML.Font\ &Styles.Emphasis  em
HTMLmenu nmenu - HTML.Font\ &Styles.Emphasis  em i
HTMLmenu imenu - HTML.Font\ &Styles.Underline un
HTMLmenu vmenu - HTML.Font\ &Styles.Underline un
HTMLmenu nmenu - HTML.Font\ &Styles.Underline un i
HTMLmenu imenu - HTML.Font\ &Styles.Big       bi
HTMLmenu vmenu - HTML.Font\ &Styles.Big       bi
HTMLmenu nmenu - HTML.Font\ &Styles.Big       bi i
HTMLmenu imenu - HTML.Font\ &Styles.Small     sm
HTMLmenu vmenu - HTML.Font\ &Styles.Small     sm
HTMLmenu nmenu - HTML.Font\ &Styles.Small     sm i
 menu HTML.Font\ Styles.-sep1- <nul>
HTMLmenu imenu - HTML.Font\ &Styles.Font\ Size  fo
HTMLmenu vmenu - HTML.Font\ &Styles.Font\ Size  fo
HTMLmenu nmenu - HTML.Font\ &Styles.Font\ Size  fo i
HTMLmenu imenu - HTML.Font\ &Styles.Font\ Color fc
HTMLmenu vmenu - HTML.Font\ &Styles.Font\ Color fc
HTMLmenu nmenu - HTML.Font\ &Styles.Font\ Color fc i
 menu HTML.Font\ Styles.-sep2- <nul>
HTMLmenu imenu - HTML.Font\ &Styles.CITE           ci 
HTMLmenu vmenu - HTML.Font\ &Styles.CITE           ci 
HTMLmenu nmenu - HTML.Font\ &Styles.CITE           ci i
HTMLmenu imenu - HTML.Font\ &Styles.CODE           co 
HTMLmenu vmenu - HTML.Font\ &Styles.CODE           co 
HTMLmenu nmenu - HTML.Font\ &Styles.CODE           co i
HTMLmenu imenu - HTML.Font\ &Styles.Inserted\ Text in 
HTMLmenu vmenu - HTML.Font\ &Styles.Inserted\ Text in 
HTMLmenu nmenu - HTML.Font\ &Styles.Inserted\ Text in i
HTMLmenu imenu - HTML.Font\ &Styles.Deleted\ Text  de 
HTMLmenu vmenu - HTML.Font\ &Styles.Deleted\ Text  de 
HTMLmenu nmenu - HTML.Font\ &Styles.Deleted\ Text  de i
HTMLmenu imenu - HTML.Font\ &Styles.Emphasize      em 
HTMLmenu vmenu - HTML.Font\ &Styles.Emphasize      em 
HTMLmenu nmenu - HTML.Font\ &Styles.Emphasize      em i
HTMLmenu imenu - HTML.Font\ &Styles.Keyboard\ Text kb 
HTMLmenu vmenu - HTML.Font\ &Styles.Keyboard\ Text kb 
HTMLmenu nmenu - HTML.Font\ &Styles.Keyboard\ Text kb i
HTMLmenu imenu - HTML.Font\ &Styles.Sample\ Text   sa 
HTMLmenu vmenu - HTML.Font\ &Styles.Sample\ Text   sa 
HTMLmenu nmenu - HTML.Font\ &Styles.Sample\ Text   sa i
HTMLmenu imenu - HTML.Font\ &Styles.Strikethrough  sk 
HTMLmenu vmenu - HTML.Font\ &Styles.Strikethrough  sk 
HTMLmenu nmenu - HTML.Font\ &Styles.Strikethrough  sk i
HTMLmenu imenu - HTML.Font\ &Styles.STRONG         st 
HTMLmenu vmenu - HTML.Font\ &Styles.STRONG         st 
HTMLmenu nmenu - HTML.Font\ &Styles.STRONG         st i
HTMLmenu imenu - HTML.Font\ &Styles.Subscript      sb 
HTMLmenu vmenu - HTML.Font\ &Styles.Subscript      sb 
HTMLmenu nmenu - HTML.Font\ &Styles.Subscript      sb i
HTMLmenu imenu - HTML.Font\ &Styles.Superscript    sp 
HTMLmenu vmenu - HTML.Font\ &Styles.Superscript    sp 
HTMLmenu nmenu - HTML.Font\ &Styles.Superscript    sp i
HTMLmenu imenu - HTML.Font\ &Styles.Teletype\ Text tt 
HTMLmenu vmenu - HTML.Font\ &Styles.Teletype\ Text tt 
HTMLmenu nmenu - HTML.Font\ &Styles.Teletype\ Text tt i
HTMLmenu imenu - HTML.Font\ &Styles.Variable       va 
HTMLmenu vmenu - HTML.Font\ &Styles.Variable       va 
HTMLmenu nmenu - HTML.Font\ &Styles.Variable       va i


" Frames menu:   {{{2

HTMLmenu imenu - HTML.&Frames.FRAMESET fs
HTMLmenu vmenu - HTML.&Frames.FRAMESET fs
HTMLmenu nmenu - HTML.&Frames.FRAMESET fs i
HTMLmenu imenu - HTML.&Frames.FRAME    fr
HTMLmenu vmenu - HTML.&Frames.FRAME    fr
HTMLmenu nmenu - HTML.&Frames.FRAME    fr i
HTMLmenu imenu - HTML.&Frames.NOFRAMES nf
HTMLmenu vmenu - HTML.&Frames.NOFRAMES nf
HTMLmenu nmenu - HTML.&Frames.NOFRAMES nf i
HTMLmenu imenu - HTML.&Frames.IFRAME   if
HTMLmenu vmenu - HTML.&Frames.IFRAME   if
HTMLmenu nmenu - HTML.&Frames.IFRAME   if i


" Headers menu:   {{{2

HTMLmenu imenu - HTML.&Headers.Header\ Level\ 1 h1 
HTMLmenu imenu - HTML.&Headers.Header\ Level\ 2 h2 
HTMLmenu imenu - HTML.&Headers.Header\ Level\ 3 h3 
HTMLmenu imenu - HTML.&Headers.Header\ Level\ 4 h4 
HTMLmenu imenu - HTML.&Headers.Header\ Level\ 5 h5 
HTMLmenu imenu - HTML.&Headers.Header\ Level\ 6 h6 
HTMLmenu vmenu - HTML.&Headers.Header\ Level\ 1 h1 
HTMLmenu vmenu - HTML.&Headers.Header\ Level\ 2 h2 
HTMLmenu vmenu - HTML.&Headers.Header\ Level\ 3 h3 
HTMLmenu vmenu - HTML.&Headers.Header\ Level\ 4 h4 
HTMLmenu vmenu - HTML.&Headers.Header\ Level\ 5 h5 
HTMLmenu vmenu - HTML.&Headers.Header\ Level\ 6 h6 
HTMLmenu nmenu - HTML.&Headers.Header\ Level\ 1 h1 i
HTMLmenu nmenu - HTML.&Headers.Header\ Level\ 2 h2 i
HTMLmenu nmenu - HTML.&Headers.Header\ Level\ 3 h3 i
HTMLmenu nmenu - HTML.&Headers.Header\ Level\ 4 h4 i
HTMLmenu nmenu - HTML.&Headers.Header\ Level\ 5 h5 i
HTMLmenu nmenu - HTML.&Headers.Header\ Level\ 6 h6 i


" Lists menu:   {{{2

HTMLmenu imenu - HTML.&Lists.Ordered\ List    ol 
HTMLmenu vmenu - HTML.&Lists.Ordered\ List    ol 
HTMLmenu nmenu - HTML.&Lists.Ordered\ List    ol i
HTMLmenu imenu - HTML.&Lists.Unordered\ List  ul 
HTMLmenu vmenu - HTML.&Lists.Unordered\ List  ul 
HTMLmenu nmenu - HTML.&Lists.Unordered\ List  ul i
HTMLmenu imenu - HTML.&Lists.List\ Item       li 
HTMLmenu vmenu - HTML.&Lists.List\ Item       li 
HTMLmenu nmenu - HTML.&Lists.List\ Item       li i
 menu HTML.Lists.-sep1- <nul>
HTMLmenu imenu - HTML.&Lists.Definition\ List dl 
HTMLmenu vmenu - HTML.&Lists.Definition\ List dl 
HTMLmenu nmenu - HTML.&Lists.Definition\ List dl i
HTMLmenu imenu - HTML.&Lists.Definition\ Term dt 
HTMLmenu vmenu - HTML.&Lists.Definition\ Term dt
HTMLmenu nmenu - HTML.&Lists.Definition\ Term dt i
HTMLmenu imenu - HTML.&Lists.Definition\ Body dd 
HTMLmenu vmenu - HTML.&Lists.Definition\ Body dd
HTMLmenu nmenu - HTML.&Lists.Definition\ Body dd i


" Tables menu:   {{{2

HTMLmenu nmenu - HTML.&Tables.Interactive\ Table      tA 
HTMLmenu imenu - HTML.&Tables.TABLE                   ta 
HTMLmenu vmenu - HTML.&Tables.TABLE                   ta 
HTMLmenu nmenu - HTML.&Tables.TABLE                   ta i
HTMLmenu imenu - HTML.&Tables.Header\ Row             tH 
HTMLmenu vmenu - HTML.&Tables.Header\ Row             tH 
HTMLmenu nmenu - HTML.&Tables.Header\ Row             tH i
HTMLmenu imenu - HTML.&Tables.Row                     tr 
HTMLmenu vmenu - HTML.&Tables.Row                     tr 
HTMLmenu nmenu - HTML.&Tables.Row                     tr i
HTMLmenu imenu - HTML.&Tables.Footer\ Row             tf 
HTMLmenu vmenu - HTML.&Tables.Footer\ Row             tf 
HTMLmenu nmenu - HTML.&Tables.Footer\ Row             tf i
HTMLmenu imenu - HTML.&Tables.Column\ Header          th 
HTMLmenu vmenu - HTML.&Tables.Column\ Header          th 
HTMLmenu nmenu - HTML.&Tables.Column\ Header          th i
HTMLmenu imenu - HTML.&Tables.Data\ (Column\ Element) td 
HTMLmenu vmenu - HTML.&Tables.Data\ (Column\ Element) td 
HTMLmenu nmenu - HTML.&Tables.Data\ (Column\ Element) td i
HTMLmenu imenu - HTML.&Tables.CAPTION                 ca 
HTMLmenu vmenu - HTML.&Tables.CAPTION                 ca 
HTMLmenu nmenu - HTML.&Tables.CAPTION                 ca i


" Forms menu:   {{{2

HTMLmenu imenu - HTML.F&orms.FORM             fm
HTMLmenu vmenu - HTML.F&orms.FORM             fm
HTMLmenu nmenu - HTML.F&orms.FORM             fm i
HTMLmenu imenu - HTML.F&orms.BUTTON           bu
HTMLmenu vmenu - HTML.F&orms.BUTTON           bu
HTMLmenu nmenu - HTML.F&orms.BUTTON           bu i
HTMLmenu imenu - HTML.F&orms.CHECKBOX         ch
HTMLmenu vmenu - HTML.F&orms.CHECKBOX         ch
HTMLmenu nmenu - HTML.F&orms.CHECKBOX         ch i
HTMLmenu imenu - HTML.F&orms.RADIO            ra
HTMLmenu vmenu - HTML.F&orms.RADIO            ra
HTMLmenu nmenu - HTML.F&orms.RADIO            ra i
HTMLmenu imenu - HTML.F&orms.HIDDEN           hi
HTMLmenu vmenu - HTML.F&orms.HIDDEN           hi
HTMLmenu nmenu - HTML.F&orms.HIDDEN           hi i
HTMLmenu imenu - HTML.F&orms.PASSWORD         pa
HTMLmenu vmenu - HTML.F&orms.PASSWORD         pa
HTMLmenu nmenu - HTML.F&orms.PASSWORD         pa i
HTMLmenu imenu - HTML.F&orms.TEXT             te
HTMLmenu vmenu - HTML.F&orms.TEXT             te
HTMLmenu nmenu - HTML.F&orms.TEXT             te i
HTMLmenu imenu - HTML.F&orms.FILE             fi
HTMLmenu vmenu - HTML.F&orms.FILE             fi
HTMLmenu nmenu - HTML.F&orms.FILE             fi i
HTMLmenu imenu - HTML.F&orms.SELECT           se
HTMLmenu vmenu - HTML.F&orms.SELECT           se
HTMLmenu nmenu - HTML.F&orms.SELECT           se i
HTMLmenu imenu - HTML.F&orms.SELECT\ MULTIPLE ms 
HTMLmenu vmenu - HTML.F&orms.SELECT\ MULTIPLE ms 
HTMLmenu nmenu - HTML.F&orms.SELECT\ MULTIPLE ms i
HTMLmenu imenu - HTML.F&orms.OPTION           op
HTMLmenu vmenu - HTML.F&orms.OPTION           op
HTMLmenu nmenu - HTML.F&orms.OPTION           op i
HTMLmenu imenu - HTML.F&orms.OPTGROUP         og
HTMLmenu vmenu - HTML.F&orms.OPTGROUP         og
HTMLmenu nmenu - HTML.F&orms.OPTGROUP         og i
HTMLmenu imenu - HTML.F&orms.TEXTAREA         tx
HTMLmenu vmenu - HTML.F&orms.TEXTAREA         tx
HTMLmenu nmenu - HTML.F&orms.TEXTAREA         tx i
HTMLmenu imenu - HTML.F&orms.SUBMIT           su
HTMLmenu nmenu - HTML.F&orms.SUBMIT           su i
HTMLmenu imenu - HTML.F&orms.RESET            re
HTMLmenu nmenu - HTML.F&orms.RESET            re i
HTMLmenu imenu - HTML.F&orms.LABEL            la
HTMLmenu vmenu - HTML.F&orms.LABEL            la
HTMLmenu nmenu - HTML.F&orms.LABEL            la i

" }}}2

 menu HTML.-sep6- <nul>

HTMLmenu nmenu - HTML.Doctype\ (transitional) 4 
HTMLmenu nmenu - HTML.Doctype\ (strict)       s4 
HTMLmenu imenu - HTML.Content-Type            ct 
HTMLmenu nmenu - HTML.Content-Type            ct i

 menu HTML.-sep7- <nul>

HTMLmenu imenu - HTML.BODY             bd
HTMLmenu vmenu - HTML.BODY             bd
HTMLmenu nmenu - HTML.BODY             bd i
HTMLmenu imenu - HTML.CENTER           ce
HTMLmenu vmenu - HTML.CENTER           ce
HTMLmenu nmenu - HTML.CENTER           ce i
HTMLmenu imenu - HTML.Comment          cm
HTMLmenu vmenu - HTML.Comment          cm
HTMLmenu nmenu - HTML.Comment          cm i
HTMLmenu imenu - HTML.HEAD             he
HTMLmenu vmenu - HTML.HEAD             he
HTMLmenu nmenu - HTML.HEAD             he i
HTMLmenu imenu - HTML.Horizontal\ Rule hr
HTMLmenu nmenu - HTML.Horizontal\ Rule hr i
HTMLmenu imenu - HTML.HTML             ht
HTMLmenu vmenu - HTML.HTML             ht
HTMLmenu nmenu - HTML.HTML             ht i
HTMLmenu imenu - HTML.Hyperlink        ah
HTMLmenu vmenu - HTML.Hyperlink        ah
HTMLmenu nmenu - HTML.Hyperlink        ah i
HTMLmenu imenu - HTML.Inline\ Image    im 
HTMLmenu vmenu - HTML.Inline\ Image    im 
HTMLmenu nmenu - HTML.Inline\ Image    im i
if exists("*MangleImageTag")
  HTMLmenu imenu - HTML.Update\ Image\ Size\ Attributes mi 
  HTMLmenu vmenu - HTML.Update\ Image\ Size\ Attributes mi <ESC>
  HTMLmenu nmenu - HTML.Update\ Image\ Size\ Attributes mi 
endif
HTMLmenu imenu - HTML.Line\ Break        br 
HTMLmenu nmenu - HTML.Line\ Break        br i
HTMLmenu imenu - HTML.Named\ Anchor      an 
HTMLmenu vmenu - HTML.Named\ Anchor      an 
HTMLmenu nmenu - HTML.Named\ Anchor      an i
HTMLmenu imenu - HTML.Paragraph          pp 
HTMLmenu vmenu - HTML.Paragraph          pp 
HTMLmenu nmenu - HTML.Paragraph          pp i
HTMLmenu imenu - HTML.Preformatted\ Text pr 
HTMLmenu vmenu - HTML.Preformatted\ Text pr 
HTMLmenu nmenu - HTML.Preformatted\ Text pr i
HTMLmenu imenu - HTML.TITLE              ti 
HTMLmenu vmenu - HTML.TITLE              ti 
HTMLmenu nmenu - HTML.TITLE              ti i

HTMLmenu imenu - HTML.&More\.\.\..ADDRESS                   ad 
HTMLmenu vmenu - HTML.&More\.\.\..ADDRESS                   ad 
HTMLmenu nmenu - HTML.&More\.\.\..ADDRESS                   ad i
HTMLmenu imenu - HTML.&More\.\.\..BASE\ HREF                bh 
HTMLmenu vmenu - HTML.&More\.\.\..BASE\ HREF                bh 
HTMLmenu nmenu - HTML.&More\.\.\..BASE\ HREF                bh i
HTMLmenu imenu - HTML.&More\.\.\..BLOCKQUTE                 bl 
HTMLmenu vmenu - HTML.&More\.\.\..BLOCKQUTE                 bl 
HTMLmenu nmenu - HTML.&More\.\.\..BLOCKQUTE                 bl i
HTMLmenu imenu - HTML.&More\.\.\..Defining\ Instance        df 
HTMLmenu vmenu - HTML.&More\.\.\..Defining\ Instance        df 
HTMLmenu nmenu - HTML.&More\.\.\..Defining\ Instance        df i
HTMLmenu imenu - HTML.&More\.\.\..Document\ Division        dv 
HTMLmenu vmenu - HTML.&More\.\.\..Document\ Division        dv 
HTMLmenu nmenu - HTML.&More\.\.\..Document\ Division        dv i
HTMLmenu imenu - HTML.&More\.\.\..EMBED                     eb
HTMLmenu nmenu - HTML.&More\.\.\..EMBED                     eb i
HTMLmenu imenu - HTML.&More\.\.\..ISINDEX                   ii
HTMLmenu nmenu - HTML.&More\.\.\..ISINDEX                   ii i
HTMLmenu imenu - HTML.&More\.\.\..JavaScript                js
HTMLmenu nmenu - HTML.&More\.\.\..JavaScript                js i
HTMLmenu imenu - HTML.&More\.\.\..Sourced\ JavaScript       sj 
HTMLmenu nmenu - HTML.&More\.\.\..Sourced\ JavaScript       sj i
HTMLmenu imenu - HTML.&More\.\.\..LINK\ HREF                lk 
HTMLmenu vmenu - HTML.&More\.\.\..LINK\ HREF                lk 
HTMLmenu nmenu - HTML.&More\.\.\..LINK\ HREF                lk i
HTMLmenu imenu - HTML.&More\.\.\..META                      me 
HTMLmenu vmenu - HTML.&More\.\.\..META                      me 
HTMLmenu nmenu - HTML.&More\.\.\..META                      me i
HTMLmenu imenu - HTML.&More\.\.\..META\ HTTP-EQUIV          mh 
HTMLmenu vmenu - HTML.&More\.\.\..META\ HTTP-EQUIV          mh 
HTMLmenu nmenu - HTML.&More\.\.\..META\ HTTP-EQUIV          mh i
HTMLmenu imenu - HTML.&More\.\.\..NOSCRIPT                  nj 
HTMLmenu vmenu - HTML.&More\.\.\..NOSCRIPT                  nj 
HTMLmenu nmenu - HTML.&More\.\.\..NOSCRIPT                  nj i
HTMLmenu imenu - HTML.&More\.\.\..Generic\ Embedded\ Object ob 
HTMLmenu vmenu - HTML.&More\.\.\..Generic\ Embedded\ Object ob 
HTMLmenu nmenu - HTML.&More\.\.\..Generic\ Embedded\ Object ob i
HTMLmenu imenu - HTML.&More\.\.\..Quoted\ Text              qu 
HTMLmenu vmenu - HTML.&More\.\.\..Quoted\ Text              qu 
HTMLmenu nmenu - HTML.&More\.\.\..Quoted\ Text              qu i
HTMLmenu imenu - HTML.&More\.\.\..SPAN                      sn 
HTMLmenu vmenu - HTML.&More\.\.\..SPAN                      sn 
HTMLmenu nmenu - HTML.&More\.\.\..SPAN                      sn i
HTMLmenu imenu - HTML.&More\.\.\..STYLE\ (Inline\ CSS\)     cs 
HTMLmenu vmenu - HTML.&More\.\.\..STYLE\ (Inline\ CSS\)     cs 
HTMLmenu nmenu - HTML.&More\.\.\..STYLE\ (Inline\ CSS\)     cs i
HTMLmenu imenu - HTML.&More\.\.\..Linked\ CSS               ls 
HTMLmenu vmenu - HTML.&More\.\.\..Linked\ CSS               ls 
HTMLmenu nmenu - HTML.&More\.\.\..Linked\ CSS               ls i

let g:did_html_menus = 1
endif
" ---------------------------------------------------------------------------


" ---- Clean Up: -------------------------------------------------------- {{{1

silent! unlet s:browsers

if exists(':HTMLmenu')
  delcommand HTMLmenu
  delfunction s:LeadMenu
endif

if exists(':HTMLemenu')
  delcommand HTMLemenu
  delfunction s:EntityMenu
endif

if exists(':HTMLcmenu')
  delcommand HTMLcmenu
  delfunction s:ColorsMenu
  unlet s:colors_sort
endif

let &cpoptions = s:savecpo
unlet s:savecpo

unlet s:doing_internal_html_mappings

" vim:ts=2:sw=2:expandtab:tw=78:fo=croq2:comments=b\:\":
" vim600:fdm=marker:fdc=4:cms=\ "\ %s:
doc/HTML.txt	[[[1
1077
*HTML.txt*	Set of HTML/XHTML macros, menus and toolbar buttons.
		Last change: 2009 Sep 21
		Author: Christian J. Robinson

						*HTML.vim* *HTML-macros*
						*XHTML-macros*

This is a set of HTML/XHTML macros, menus, and toolbar buttons to make editing
HTML files easier.  The original Copyright goes to Doug Renze, although nearly
all of his efforts have been modified in this implementation.  All the changes
are Copyright Christian J. Robinson.  These macros and the supporting scripts
are distributable under the terms of the GNU GPL version 2 or later.

------------------------------------------------------------------------------

1. Introduction				|html-intro|
2. Customization Variables		|html-variables|
3. Commands				|html-commands|
4. Mappings for Normal <> Tags		|html-tags|
5. Mappings for &...; Codes, such as &lt; &gt; &amp; and so on
					|character-codes|
6. How to Use Browser Mappings		|browser-control|
7. Miscellaneous Extras			|html-misc|

==============================================================================
1. Introduction						*html-intro*

To start, you should familiarize yourself with Vim enough to know the
terminology, and you should know HTML to some degree.

The mappings are local to the buffer the script was sourced from, and the menu
and toolbar are active only for buffers the script was sourced from.

This help file follows the Vim help file standards.  To see what modes a
mapping works in see the tags between the **'s.  For example, the |;;| mapping
below works in normal, insert mode and visual mode.

In the descriptions of the mappings I often use <CR> to mean a literal
newline.

							*html-smart-tag*
Noted tags are "smart"--if syntax highlighting is enabled it can be used to
detect whether to close then open a tag instead of open then close the tag.
For example, if the cursor is in italicized text and you type ;it, it will
insert </I><I> instead of <I></I>.

This can not be done on most tags due to its dependence on the syntax
highlighting.

NOTE: Some tags are synonyms and Vim can't distinguish between them.  For
example, if you're within <I></I> and type |;em| it will assume you want
</EM><EM> rather than <EM></EM>, which you should not be doing anyway.

							*n_;;* *i_;;* *v_;;*
;;	Most of the mappings start with ; so ;; is mapped to insert a single
	; character in insert mode, behave like a single ; in normal mode,
	etc.  (The semicolons in this mapping are changed to whatever
	|g:html_map_leader| is set to.)

							*i_;&*
;&	The HTML |character-entities| insert mode mappings start with &, so
	typing ;& in insert mode will insert a literal & character.
	(In actuality this mapping is defined as |g:html_map_leader| +
	|g:html_map_entity_leader| to insert whatever is in
	|g:html_map_entity_leader|.) (See also |n_;&|)

				*html-<Tab>* *html-tab* *html-CTRL-I*
				*i_html-<Tab>* *i_html-tab* *i_html-CTRL-I*
				*v_html-<Tab>* *v_html-tab* *v_html-CTRL-I*
<Tab>	If the cursor is on a closing tag the tab key jumps the cursor after
	the tag.  Otherwise the tab key will jump the cursor to an unfilled
	tag somewhere in the file.  For example, if you had the tag:
>
	 <A HREF=""></A>
<
	And you hit tab, your cursor would be placed on the second " so you
	could insert text easily.  Next time you hit tab it would be placed on
	the < character of </A>.  And the third time you hit tab the cursor
	would be placed on the > of </A>, and so on.  This works for tags
	split across lines, such as:
>
	 <TABLE>
	 </TABLE>
<
	Currently using this mapping in visual mode clears the visual
	selection.

	See |g:no_html_tab_mapping| if you do not want these mappings to be
	defined, in which case ;<Tab> will be used for the mappings instead.

	[I think the use of tab is acceptable because I do not like the idea
	of hard tabs or indentation greater than one or two spaces in HTML.]

					*i_;<Tab>* *i_;tab* *i_;CTRL-I*
					*n_;<Tab>* *n_;tab* *n_;CTRL-I*
;<Tab>	To insert a hard tab (; then the tab key).  If |g:no_html_tab_mapping|
	is set this mapping replaces the normal |html-tab| mapping instead.
	(See |g:html_map_leader|)

								*n_;html*
;html	This macro inserts a basic template at the top of the file.  If the
	buffer already contains some text you are asked if you want to replace
	it or add the template anyway.  (See |g:html_map_leader|)

	See |g:html_template| for information on how to customize the
	template.


	*disable-HTML-macros*	*HTML-macros-disable*	*HTML-disable-macros*
	*disable-HTML-mappings*	*HTML-mappings-disable*	*HTML-disable-mappings*
							*:HTMLmappings*
:HTML[mappings] {disable/off/enable/on}
	This command allows the HTML macros to be disabled and re-enabled.
	This is useful for editing inline PHP, JavaScript, etc. where you
	would want to be able to type literal ";", "&" and tab characters
	without interference.  (Also see |;;|, |;&| and |;<Tab>|)

	Note that all of the mappings defined by calling |HTMLmap()| or
	|HTMLmapo()|--including all of the mappings defined by this
	script--are disabled/enabled when this command is used, regardless of
	what |g:html_map_leader| is set to.

==============================================================================
2. Customization Variables		*html-variables* *html-configuration*
					*html-customization*

You can set the following global Vim variables to control the behavior of the
macros.  It is recommended you set these variables in your .vimrc--some of
them are only effective if they are set before HTML.vim is sourced.

Note that "nonzero" means anything besides "no", "false", 0, or "" (empty
value)--case insensitive.

*g:do_xhtml_mappings* *b:do_xhtml_mappings*
Set this variable to a nonzero value if you prefer XHTML compatible tags to be
defined.  Setting this forces |b:html_tag_case| to "lowercase".  This is
automatic if you are already editing a file that Vim detects as XHTML.  This
variable must be set before HTML.vim is sourced for the current buffer.  You
can also set this on a per-buffer basis by using b:do_xhtml_mappings instead.
e.g.: >
	:let g:do_xhtml_mappings = 'yes'

*g:html_tag_case* *b:html_tag_case*
This variable can be set to "l" / "lower" / "lowercase" or "u" / "upper" /
"uppercase" to determine the case of the text in the HTML tags.  This variable
must be set before HTML.vim is sourced for the current buffer.  The default is
"uppercase".  You can also set this on a per-buffer basis by using
b:html_tag_case instead.  This variable is ignored when editing XHTML files
(see |g:do_xhtml_mappings|).  e.g: >
	:let g:html_tag_case = 'lowercase'

*g:html_tag_case_autodetect*
Set this variable to a nonzero value if you want to automatically detect what
the value of |b:html_tag_case| should be.  This is done by examining the file
for both upper and lower case tags (tag attributes are not examined).  If only
one type is found the tag case for the buffer is set to that value.  This
variable is ignored if you have set |g:do_xhtml_mappings|.  e.g.: >
	:let g:html_tag_case_autodetect = 'yes'

*g:html_map_leader*
This variable can be set to the character you want for the leader of the
mappings defined under |html-tags|, the default being ';'.  This variable must
be set before HTML.vim is sourced.  You can set this to your |mapleader| or
|maplocalleader|.  e.g.: >
	:let g:html_map_leader = g:maplocalleader

*g:html_map_entity_leader*
This variable can be set to the character you want for the leader of the
character entity insert mode mappings defined under |character-entities|, the
default being '&'.  This variable must be set before HTML.vim is sourced.  If
you attempt to set this to the same value as |g:html_map_leader| you will get
an error.  e.g.: >
	:let g:html_map_entity_leader = '\'

*g:no_html_map_override*
Set this variable to a nonzero value if you do not want this plugin to
override mappings that already exist.  When this variable is not set you will
get a warning message when this plugin overrides a mapping.  This variable
must be set before HTML.vim is sourced.  e.g.: >
	:let g:no_html_map_override = 'yes'

This only applies to the mappings defined internally to the plugin.  If you
call the |HTMLmap()| function elsewhere you will still get a warning message
when there's an already existing mapping and the mapping will still be
overridden.

*g:no_html_maps* *b:no_html_maps*
Set this variable a regular expression to match against mappings.  If a
mapping to be defined matches this regular expression it will not be defined.
You can also set this on a per-buffer basis by using b:no_html_maps instead.
The patterns are case sensitive, will not undergo |g:html_map_leader| and
|g:html_map_entity_leader| substitution, and must be set before HTML.vim is
sourced.  e.g., to suppress the <A HREF>, <IMG SRC> and the centered headers
tags: >
	:let g:no_html_maps = '^\(;ah\|;im\|;H\d\)$'

This only applies to the mappings defined internally to the plugin.  If you
call the |HTMLmap()| function elsewhere the mapping will be defined even if it
matches this regular expression.  This is useful if you wish to define custom
variants of some of the plugin's mappings without getting warning messages.

*g:no_html_tab_mapping*
Set this variable to a nonzero value if you do not want the tab key to be
mapped in normal, visual and insert mode.  ;<Tab> will be used instead.  See
|html-tab| and |i_;tab|.  This variable must be set before HTML.vim is sourced
for the current buffer.  e.g.: >
	:let g:no_html_tab_mapping = 'yes'

Note that you can suppress the defining of both <Tab> and ;<Tab> as a mapping
by adding "\t" to |g:no_html_maps| instead.

*g:no_html_toolbar*
Set this variable to a nonzero value if you do not want this plugin to modify
the Vim toolbar and add "T" to 'guioptions'.  This variable must be set before
HTML.vim is sourced.  e.g.: >
	:let g:no_html_toolbar = 'yes'

*g:no_html_menu*
Set this variable to a nonzero value if you don't want the menu items to be
defined at all.  This implies that |g:no_html_toolbar| is set as well.  This
variable must be set before HTML.vim is sourced.  e.g.: >
	:let g:no_html_menu = 'yes'

*g:force_html_menu*
Set this variable to a nonzero value if you want the menu items to be defined
even if you're not in the GUI.  This is useful if you want to use the menus in
the console (see |console-menus|).  This variable is ignored if
|g:no_html_menu| is set.  This variable must be set before HTML.vim is
sourced.  e.g.: >
	:let g:force_html_menu = 'yes'

*g:html_template* *b:html_template*
Set this variable to the location of your template file to be used by the
|;html| mapping.  You can also set this on a per-buffer basis by using
b:html_template instead.  If unset, a basic internal template will be used.

See |html-template-tokens| for special tokens you can use within the template.

*g:html_authorname* *g:html_authoremail*
Within the internal template, html_authorname is inserted inside
<META NAME="Author" CONTENT="...">
g:html_authoremail is converted to |g:html_authoremail_encoded| and inserted
inside <LINK REV="made" HREF="mailto:...">  e.g.: >
	:let g:html_authorname  = 'John Smith'
	:let g:html_authoremail = 'jsmith@example.com'

These two variables are also used for the <ADDRESS></ADDRESS> section of the
internal template.

The default for these variables are empty strings.

*g:html_authoremail_encoded*
This variable will be set using |HTMLencodeString()| if your
|g:html_authoremail| variable is set.  (Do not set this variable yourself, it
will be overwritten when the template macro is used.)

*g:html_bgcolor* *g:html_textcolor* *g:html_linkcolor*
*g:html_alinkcolor* *g:html_vlinkcolor*
These control the <BODY> tag in the internal template and can also be used as
|html-tokens| in the user defined template.  They default to: >
	:let g:html_bgcolor     = '#FFFFFF'
	:let g:html_textcolor   = '#000000'
	:let g:html_linkcolor   = '#0000EE'
	:let g:html_alinkcolor  = '#FF0000'
	:let g:html_vlinkcolor  = '#990066'

*g:html_default_charset*
This defaults to "iso-8859-1" and is the value used if a character set can not
be detected by the 'fileencoding' or 'encoding' options.  See |;ct| and
|html-tokens| for how this is used.  (Also see |html-author-notes|)

*g:html_charset*
If this variable is set it completely overrides the Content-Type charset
detection for the |;ct| mapping and in the |html-tokens|.  Normally this
should be left unset.

------------------------------------------------------------------------------
					*html-template-tokens* *html-tokens*

When you define a template file with the |g:html_template| variable, special
tokens within the template will automatically replaced with their
corresponding variable value:

Token:			 Variable: ~
%authorname%		|g:html_authorname|
%authoremail%		|g:html_authoremail_encoded|
%bgcolor%		|g:html_bgcolor|
%textcolor%		|g:html_textcolor|
%linkcolor%		|g:html_linkcolor|
%alinkcolor%		|g:html_alinkcolor|
%vlinkcolor%		|g:html_vlinkcolor|

Special tokens: ~
%date%						*%date%*
This is replaced with the output of strftime("%B %d, %Y")  (e.g.: March 16,
2004).  You can send custom fields to the |strftime()| call by embedding !...
(rather than %...) notation before the second "%" in the token. e.g.: >
 %date!m/!d/!Y !l:!M !p !Z%
Would produce something like: >
 03/08/2007  5:59 PM MST
Note that spaces before and after the format string are ignored, and you can
get literal "%" and "!" characters inside the custom format by preceding them
with backslashes. e.g.: >
 (%date  \%!r\!  %)
Would produce something like: >
 (%05:59:34 PM!)

%time% or %time12%				*%time%* *%time12%*
This is replaced with the output of strftime("%r %Z") (e.g.: 05:59:34 PM MST)

%time24%					*%time24%*
This is replaced with the output of strftime("%T %Z") (e.g.: 17:59:34 MST)

%charset%					*%charset%*
This is replaced by a string that is automatically detected based on the
'fileencoding' or 'encoding' option.  This can be overridden, see
|g:html_default_charset| and |g:html_charset|.  (Also see |html-author-notes|)

%vimversion%					*%vimversion%*
The current version of Vim, based on |v:version|.  For example, if v:version
was "700" the %vimversion% token would contain "7.0".

So if you had the template: >
 <HTML>
  <HEAD>
   <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=%charset%">
   <META NAME="Author" CONTENT="%authorname%">
   <META NAME="Copyright" CONTENT="Copyright (C) %date% %authorname%">
   <LINK REV="made" HREF="mailto:%authoremail%">
  <BODY BGCOLOR="%bgcolor%" TEXT="%textcolor%" LINK="%linkcolor%" ALINK="%alinkcolor%" VLINK="%vlinkcolor%">
  </BODY>
 </HTML>
<
You would get something like: >
 <HTML>
  <HEAD>
   <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
   <META NAME="Author" CONTENT="John Smith">
   <META NAME="Copyright" CONTENT="Copyright (C) March 16, 2004 John Smith">
   <LINK REV="made" HREF="mailto:jsmith@example.com">
  <BODY BGCOLOR="#FFFFFF" TEXT="#000000" LINK="#0000EE" ALINK="#FF0000" VLINK="#990066">
  </BODY>
 </HTML>
<
==============================================================================
3. Commands						 *html-commands*

	*reload-HTML-macros*	*HTML-macros-reload*	*HTML-reload-macros*
	*reload-HTML-mappings*	*HTML-mappings-reload*	*HTML-reload-mappings*
:HTML[mappings] {reload/html/xhtml}
	You can also use the :HTMLmappings command to reload the entire HTML
	macros script, or force the HTML macros into HTML or XHTML mode.

							*:ColorSelect*
:ColorSelect
	Open a window with all the colors that are defined in the HTML.Colors
	menu displayed and highlighted with their respective color.  From this
	window you can slect a color to be inserted in the buffer from which
	the window was opened.  This command fails if you're not in an HTML
	buffer or the colors menu wasn't defined.  {only in the GUI}

							*n_;#* *i_;#*
;#	A shortcut mapping to call |:ColorSelect|.  {only in the GUI}

==============================================================================
4. Mappings for Normal <> Tags				*html-tags*

Most of these mappings are insert or visual mappings.  In insert mode the tag
is inserted and the cursor placed where you would likely want to insert text.
In visual mode, the tag is wrapped around the visually selected text in a
hopefully logical manner.  (See |i_;ah|, |v_;aH| and |i_;ab| for explicit
examples--the rest of the mappings that work in visual mode are similar.)

						*html-operator-mappings*
						*html-motion-mappings* *n_;*
If you run Vim 7 or later the following noted normal mode ;-mappings take a
{motion} operator.  These mappings function as if you had visually highlighted
the text covered by the motion and invoked the corresponding visual mapping.
(There is no reasonable way to get this functionality in versions prior to Vim
7, in which case the operator mappings will not be defined.)

If you are editing an XHTML file (see |g:do_xhtml_mappings|) the tags will be
compatible with XHTML.

Note that you can change the leader character for these mappings from ';' to
another character of your preference.  See |g:html_map_leader|.


							*n_;4* *i_;4*
;4	Inserts >
	<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
	 "http://www.w3.org/TR/html4/loose.dtd">
<	at the top of the file.  If the current buffer is XHTML, it will be >
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<	(See |g:do_xhtml_mappings|)
							*n_;s4* *i_;s4*
;s4	Does the same as |;4|, but the document type is strict rather than
	transitional.  (Note that these macros are meant for a transitional
	document type, so be careful.)
							*i_;ct*
;ct	Insert <META HTTP-EQUIV="Content-Type" CONTENT="text/html;
	charset=iso-8859-1"> at the current cursor position.

	The actual value of the charset is automatically detected based on the
	'fileencoding' or 'encoding' option.  This can be overridden--see
	|g:html_default_charset| and |g:html_charset|.
	(See |html-author-notes|)
							*i_;cm* *v_;cm* *n_;cm*
;cm	Comment tag (<!-- -->). (|html-smart-tag|) (|n_;|)
							*i_;ah* *v_;ah* *n_;ah*
;ah	Anchor hyper link (<A HREF=""></A>).  Visual mode puts the visually
	selected text <A HREF="">here</A> and positions the cursor on the
	second ". (|n_;|)
							*i_;aH* *v_;aH* *n_;aH*
;aH	Same as |;ah|, but puts the visually selected text <A HREF="here"> and
	places the cursor on the < of </A>.  If this is used in insert mode
	rather than visual mode, the contents of the |clipboard| are placed
	between the quotes. (|n_;|)
							*i_;at* *v_;at* *n_;at*
;at	Like |;ah| but include TARGET="" in the tag. (|n_;|)
							*i_;aT* *v_;aT* *n_;aT*
;aT	Like |;aH| but include TARGET="" in the tag. (|n_;|)
							*i_;an* *v_;an* *n_;an*
							*i_;aN* *v_;aN* *n_;aN*
;an and ;aN
	Same as the |;ah| and |;aH| mappings, but uses NAME instead of HREF.
	(|n_;|)
							*i_;ab* *v_;ab* *n_;ab*
;ab	Abbreviation  (<ABBR TITLE=""></ABBR>).  Visual mode puts the visually
	selected text <ABBR TITLE="">here</ABBR> and positions the cursor on
	the second ". (|n_;|)
							*i_;aB* *v_;aB* *n_;aB*
;aB	Same as |;ab|, but puts the visually selected text <ABBR TITLE="here">
	and places the cursor on the < of </ABBREV>.  If this is used in
	insert mode rather than visual mode, the contents of the |clipboard| are
	placed between the quotes. (|n_;|)
							*i_;ac* *v_;ac* *n_;ac*
							*i_;aC* *v_;aC* *n_;aC*
;ac and ;aC
	Acronym (<ACRONYM TITLE=""></ACRONYM>).  Similar to the |;ab| and
	|;aB| mappings, but uses ACRONYM instead of ABBR. (|n_;|)
							*i_;ad* *v_;ad* *n_;ad*
;ad	Address (<ADDRESS></ADDRESS>). (|n_;|)
							*i_;bo* *v_;bo* *n_;bo*
;bo	Boldfaced Text (<B></B>). (|html-smart-tag|) (|n_;|)
							*i_;bh* *v_;bh* *n_;bh*
;bh	Base URL (<BASE HREF="">). (|n_;|)
							*i_;bi* *v_;bi* *n_;bi*
;bi	Bigger text (<BIG></BIG>). (|n_;|)
							*i_;bl* *v_;bl* *n_;bl*
;bl	Block quote (<BLOCKQUOTE><CR></BLOCKQUOTE>). (|n_;|)
							*i_;bd* *v_;bd* *n_;bd*
;bd	Body (<BODY><CR></BODY>). (|n_;|)
							*i_;br*
;br	Line break (<BR>).
							*i_;ce* *v_;ce* *n_;ce*
;ce	Center (<CENTER></CENTER>). (|n_;|)
							*i_;ci* *v_;ci* *n_;ci*
;ci	Cite (<CITE></CITE>). (|n_;|)
							*i_;co* *v_;co* *n_;co*
;co	Code (<CODE></CODE>). (|n_;|)

						*html-definition-lists*
							*i_;dl* *v_;dl* *n_;dl*
;dl	Definition list (<DL><CR></DL>). (|n_;|)
							*i_;dt* *v_;dt* *n_;dt*
;dt	Definition term (<DT></DT>). (|n_;|)
							*i_;dd* *v_;dd* *n_;dd*
;dd	Definition body (<DD></DD>). (|n_;|)
							*i_;de* *v_;de* *n_;de*
;de	Deleted text (<DEL></DEL>). (|n_;|)
							*i_;df* *v_;df* *n_;df*
;df	Defining instance (<DFN></DFN>). (|n_;|)
							*i_;dv* *v_;dv* *n_;dv*
;dv	Document Division (<DIV><CR></DIV>). (|n_;|)
							*i_;eb*
;eb	Embedded element, plus NOEMBED. (<EMBED SRC="" WIDTH="" HEIGHT=""><CR>
	<NOEMBED></NOEMBED>)
							*i_;ob* *v_;ob* *n_;ob*
;ob	Generic embedded object
	(<OBJECT DATA="" WIDTH="" HEIGHT=""><CR></OBJECT>).  Visual mode puts
	the selected text
	<OBJECT DATA="" WIDTH="" HEIGHT=""><CR>here<CR></OBJECT>. (|n_;|)
							*i_;em* *v_;em* *n_;em*
;em	Emphasize (<EM></EM>). (|html-smart-tag|) (|n_;|)
							*i_;fo* *v_;fo* *n_;fo*
;fo	Font size (<FONT SIZE=""></FONT>). (|n_;|)
							*i_;fc* *v_;fc* *n_;fc*
;fc	Font color (<FONT COLOR=""></FONT>). (|n_;|)

							*html-headers*
							*i_;h1* *v_;h1* *n_;h1*
							*i_;h2* *v_;h2* *n_;h2*
							*i_;h3* *v_;h3* *n_;h3*
							*i_;h4* *v_;h4* *n_;h4*
							*i_;h5* *v_;h5* *n_;h5*
							*i_;h6* *v_;h6* *n_;h6*
;h1 through ;h6
	Headers, levels 1-6 (<H_></H_>). (|n_;|)
							*i_;H1* *v_;H1* *n_;H1*
							*i_;H2* *v_;H2* *n_;H2*
							*i_;H3* *v_;H3* *n_;H3*
							*i_;H4* *v_;H4* *n_;H4*
							*i_;H5* *v_;H5* *n_;H5*
							*i_;H6* *v_;H6* *n_;H6*
;H1 through ;H6
	Headers, levels 1-6, centered (<H_ ALIGN="CENTER"></H_>). (|n_;|)
							*i_;he* *v_;he* *n_;he*
;he	Head (<HEAD><CR></HEAD>). (|n_;|)
							*i_;hr*
;hr	Horizontal rule (<HR>).
							*i_;Hr*
;Hr	Horizontal rule (<HR WIDTH="75%">).
							*i_;ht* *v_;ht* *n_;ht*
;ht	HTML document (<HTML><CR></HTML>). (|n_;|)
							*i_;ii*
;ii	Identifies index (<ISINDEX>).
							*i_;it* *v_;it* *n_;it*
;it	Italicized text (<I></I>). (|html-smart-tag|) (|n_;|)
							*i_;im* *v_;im* *n_;im*
;im	Image (<IMG SRC="" ALT="").  Places the cursor on the second " of the
	SRC="".  In visual mode it puts the visually selected text <IMG SRC=""
	ALT="here"> and places the cursor on the second " of the SRC="".
	(|n_;|)
							*i_;iM* *v_;iM* *n_;iM*
;iM	Same as |;im|, but puts the visually selected text <IMG SRC
	NAME="HERE" ALT=""> and places the cursor on the second " of ALT="".
	If this is used in insert mode rather than visual mode, the contents
	of the |clipboard| are placed between the quotes.   (|n_;|)
							*i_;in* *v_;in* *n_;in*
;in	Inserted text (<INS></INS>). (|n_;|)
							*i_;js*
;js	<SCRIPT TYPE="text/javascript" LANGUAGE="javascript">
	 <!--

	 // -->
	</SCRIPT>
							*i_;sj*
;sj	<SCRIPT SRC="" TYPE="text/javascript" LANGUAGE="javascript"></SCRIPT>
							*i_;ns* *v_;ns* *n_;ns*
;ns	Alternate content for browsers with script handling turned off
	(<NOSCRIPT><CR></NOSCRIPT>). (|n_;|)
							*i_;li* *v_;li* *n_;li*
;li	List item (<LI></LI>) inside <UL> or <OL>. (|n_;|)
							*i_;lk* *v_;lk* *n_;lk*
;lk	Link, inside the header (<LINK HREF="">). (|n_;|)
							*i_;me* *v_;me* *n_;me*
;me	Meta information (<META NAME="" CONTENT="").  Places the cursor on the
	second " of NAME="".  Visual mode puts the visually selected text
	<META NAME="here" CONTENT=""> and places the cursor on the second " of
	CONTENT="". (|n_;|)
							*i_;mE* *v_;mE* *n_;mE*
;mE	Same as |;me|, but puts the visually selected text <META NAME=""
	CONTENT="here"> and places the cursor on the second " of NAME="".  If
	this is used in insert mode rather than visual mode, the contents of
	the |clipboard| are placed between the quotes. (|n_;|)
							*i_;mh* *v_;mh* *n_;mh*
;mh	Meta http-equiv (<META HTTP-EQUIV="" CONTENT="").  Places the cursor
	on the second " of HTTP-EQUIV="".  Visual mode puts the visually
	selected text <META HTTP-EQUIV="" CONTENT="here">. (|n_;|)
							*n_;mi* *i_;mi*
;mi	Automatically add or update the WIDTH and HEIGHT attributes of an
	<IMG> tag.  If the <IMG> tag spans multiple lines the cursor must be
	on the first line of the tag.

	This mapping is only defined if MangleImageTag.vim is installed,
	available with installation instructions here:
	http://www.infynity.spodzone.com/vim/HTML/
							*i_;ol* *v_;ol* *n_;ol*
;ol	Ordered (numbered) list (<OL><CR></OL>). (|n_;|)
							*i_;pp* *v_;pp* *n_;pp*
;pp	Paragraph (<P><CR></P>). (|n_;|)
							*i_;/p*
;/p	Like above, but inserts </P><CR><CR><P><CR>.  This is intended to be
	used when the cursor is between <P> and </P> in insert mode and you
	want to start a new paragraph without having to move the cursor.
							*i_;pr* *v_;pr* *n_;pr*
;pr	Preformatted text (<PRE><CR></PRE>). (|n_;|)
							*i_;qu* *v_;qu* *n_;qu*
;qu	Quoted text (<Q></Q>). (|n_;|)
							*i_;sk* *v_;sk* *n_;sk*
;sk	Strike-through (<STRIKE></STRIKE>). (|n_;|)
							*i_;sm* *v_;sm* *n_;sm*
;sm	Small text (<SMALL></SMALL>). (|n_;|)
							*i_;sn* *v_;sn* *n_;sn*
;sn	Span (<SPAN></SPAN>). (|n_;|)
							*i_;sa* *v_;sa* *n_;sa*
;sa	Sample text (<SAMP></SAMP>). (|n_;|)
							*i_;st* *v_;st* *n_;st*
;st	Strong text (<STRONG></STRONG>). (|html-smart-tag|) (|n_;|)
							*i_;cs* *v_;cs* *n_;cs*
;cs	CSS Style (<STYLE TYPE="text/css"><CR><!--<CR><CR>--><CR></STYLE>).
	(|n_;|)
							*i_;ls* *v_;ls* *n_;ls*
;ls	Linked CSS style sheet (<LINK REL="stylesheet" TYPE="text/css"
	HREF="">). (|n_;|)
							*i_;sb* *v_;sb* *n_;sb*
;sb	Subscript (<SUB></SUB>). (|n_;|)
							*i_;sp* *v_;sp* *n_;sp*
;sp	Superscript (<SUP></SUP>). (|n_;|)
							*i_;ti* *v_;ti* *n_;ti*
;ti	Title (<TITLE></TITLE>). (|n_;|)
							*i_;tt* *v_;tt* *n_;tt*
;tt	Teletype Text (monospaced) (<TT></TT>). (|n_;|)
							*i_;un* *v_;un* *n_;un*
;un	Underlined text (<U></U>). (|html-smart-tag|) (|n_;|)
							*i_;ul* *v_;ul* *n_;ul*
;ul	Unordered list (<UL><CR></UL>). (|n_;|)

							*html-tables*
							*i_;ta* *v_;ta* *n_;ta*
;ta	Table (<TABLE><CR></TABLE>). (|n_;|)
							*n_;tA*
;tA	Interactive table; you will be interactively prompted for the table
	rows, columns, and border width.
							*i_;tH* *v_;tH* *n_;tH*
;tH	Table header row (<THEAD></THEAD>). (|n_;|)
							*i_;tb* *v_;tb* *n_;tb*
;tb	Table body (<TBODY></TBODY>). (|n_;|)
							*i_;tf* *v_;tf* *n_;tf*
;tf	Table footer row (<TFOOT></TFOOT>). (|n_;|)
							*i_;ca* *v_;ca* *n_;ca*
;ca	Table caption (<CAPTION></CAPTION>). (|n_;|)
							*i_;tr* *v_;tr* *n_;tr*
;tr	Table row (<TR><CR></TR>). (|n_;|)
							*i_;td* *v_;td* *n_;td*
;td	Table data (column element) (<TD><CR></TD>). (|n_;|)
							*i_;th* *v_;th* *n_;th*
;th	Table column header (<TH></TH>). (|n_;|)

							*html-frames*
							*i_;fs* *v_;fs* *n_;fs*
;fs	Frame layout (<FRAMESET ROWS="" COLS=""><CR></FRAMESET>). (|n_;|)
							*i_;fr* *v_;fr* *n_;fr*
;fr	Frame source (<FRAME SRC="">). (|n_;|)
							*i_;nf* *v_;nf* *n_;nf*
;nf	Text to display if for a browser that can not display frames
	(<NOFRAMES><CR></NOFRAMES>). (|n_;|)
							*i_;if* *v_;if* *n_;if*
;if	Inline frame (<IFRAME SRC=""><CR></IFRAME>). (|n_;|)

							*html-forms*
							*i_;fm* *v_;fm* *n_;fm*
;fm	Form (<FORM ACTION=""><CR></FORM>). (|n_;|)
							*i_;bu* *v_;bu* *n_;bu*
;bu	Form button (<INPUT TYPE="BUTTON" NAME="" VALUE="">).  Visual mode puts
	the selected text VALUE="here". (|n_;|)
							*i_;ch* *v_;ch* *n_;ch*
;ch	Form check box (<INPUT TYPE="CHECKBOX" NAME="" VALUE="">).  Visual
	mode puts the selected text VALUE="here". (|n_;|)
							*i_;ra* *v_;ra* *n_;ra*
;ra	Form radio button (<INPUT TYPE="RADIO" NAME="" VALUE="">).  Visual mode
	puts the selected text VALUE="here". (|n_;|)
							*i_;hi* *v_;hi* *n_;hi*
;hi	Hidden form data (<INPUT TYPE="HIDDEN" NAME="" VALUE="">).  Visual mode
	puts the selected text VALUE="here". (|n_;|)
							*i_;pa* *v_;pa* *n_;pa*
;pa	Form password input field (<INPUT TYPE="PASSWORD" NAME="" VALUE=""
	SIZE="20">).  Visual mode puts the selected text VALUE="here". (|n_;|)
							*i_;te* *v_;te* *n_;te*
;te	Form text input field (<INPUT TYPE="TEXT" NAME="" VALUE="" SIZE="20">).
	Visual mode puts the selected text VALUE="here". (|n_;|)
							*i_;fi* *v_;fi* *n_;fi*
;fi	Form file input field (<INPUT TYPE="FILE" NAME="" VALUE="" SIZE="20">).
	Visual mode puts the selected text VALUE="here". (|n_;|)
							*i_;se* *v_;se* *n_;se*
;se	Form selection box (<SELECT NAME=""><CR></SELECT>).  Visual mode puts
	the selected text <SELECT NAME=""><CR>here<CR></SELECT>. (|n_;|)
							*i_;ms* *v_;ms* *n_;ms*
;ms	Form multiple selection box (<SELECT NAME="" MULTIPLE><CR></SELECT>).
	Visual mode puts the selected text
	<SELECT NAME="" MULTIPLE><CR>here<CR></SELECT>. (|n_;|)
							*i_;op* *v_;op* *n_;op*
;op	Form selection option (<OPTION></OPTION>). (|n_;|)
							*i_;og* *v_;og* *n_;og*
;og	Form option group (<OPTGROUP LABEL=""><CR></OPTGROUP>).  Visual mode
	puts the selected text <OPTGROUP LABEL=""><CR>here<CR></OPTGROUP>.
	(|n_;|)
							*i_;tx* *v_;tx* *n_;tx*
;tx	Form text input area (<TEXTAREA NAME="" ROWS="10"
	COLS="50"><CR></TEXTAREA>).  Visual mode puts the selected text
	<TEXTAREA NAME="" ROWS="10" COLS="50"><CR>here<CR></TEXTAREA>. (|n_;|)
							*i_;su*
;su	Form submit button (<INPUT TYPE="SUBMIT">).
							*i_;re*
;re	Form reset button (<INPUT TYPE="RESET">).
							*i_;la* *v_;la* *n_;la*
;la	Form element label (<LABEL FOR=""></LABEL>).  Visual mode puts the
	visually selected text <LABEL FOR="">here</LABEL> and positions the
	cursor on the second ". (|n_;|)
							*v_;lA* *n_;lA*
;lA	The same as |;la| but puts the cursor <LABEL FOR="here"></LABEL> and
	places the cursor on the < of </LABEL>. (|n_;|)

==============================================================================
5. Mappings for &...; Codes		*character-codes* *character-entities*

A number of mappings have been defined to allow insertion of special
characters into the HTML buffer.  These are known as characters entities.

							*n_;&* *v_;&*
;&	This mapping converts the motion or visually selected characters to
	their &#...; entities, where "..." is equivalent to the ASCII decimal
	representation.  For example, "foo bar" would become
	"&#102;&#111;&#111;&#32;&#98;&#97;&#114;". (See |i_;&|) (|n_;|)

	(Note that the "&" in this mapping is not translated to whatever
	|g:html_map_entity_leader| is set to.)
							*n_;%* *v_;%*
;%	This mapping converts the motion or visually selected characters to
	their %XX hexadecimal string for URIs.  For example, "foo bar" would
	become "%66%6F%6F%20%62%61%72". (|n_;|)

Note: Previously the ;& and ;% normal mode mappings didn't require a motion
and operated on the character "under" the cursor.  This was changed for
multiple reasons.  Use ;&l or ;%l to emulate the old behavior.

							*n_;^* *v_;^*
;^	This mapping will decode the &#...; and %XX elements of the motion or
	visually selected characters their actual characters. (|n_;|)


The following mappings work in insert mode only.

Note that you can change the leader character for these mappings from '&' to
another character of your preference.  See |g:html_map_entity_leader|.

Name:			HTML:		Macro:
--------------------------------------------------------------------
Ampersand (&)		&amp;		&&		*i_&&*
Greater than (>)	&gt;		&>		*i_&>*
Less than (<)		&lt;		&<		*i_&<*
					*i_&<space>* *i_&space* *i_;<space>*
Space (non-breaking)	&nbsp;		&<space>/;<space>	*i_;space*
Quotation mark (")	&quot;		&'		*i_&'*
Cent			&cent;		&c|		*i_&cbar*
Pound			&pound;		&#		*i_&#*
Yen			&yen;		&Y=		*i_&Y=*
Left Angle Quote	&laquo;		&2<		*i_&2<*
Right Angle Quote	&raquo;		&2>		*i_&2>*
Copyright		&copy;		&cO		*i_&cO*
Registered		&reg;		&rO		*i_&rO*
Trademark		&trade;		&tm		*i_&tm*
Multiply		&times;		&x		*i_&x*
Divide			&divide;	&/		*i_&/*
Inverted Exclamation	&iexcl;		&!		*i_&!*
Inverted Question	&iquest;	&?		*i_&?*
Degree			&deg;		&dg		*i_&dg*
Micro			&micro;		&mi		*i_&mi*
Paragraph		&para;		&pa		*i_&pa*
Middle Dot		&middot;	&.		*i_&.*
One Quarter		&frac14;	&14		*i_&14*
One Half		&frac12;	&12		*i_&12*
Three Quarters		&frac34;	&34		*i_&34*
En dash			&ndash;		&n-/&2-		*i_&n-* *i_&2-*
Em dash			&mdash;		&m-/&--/&3-	*i_&m-* *i_&--* *i_3-*
Ellipsis		&hellip;	&3.		*i_&3.*
A-grave			&Agrave;	&A`		*i_&A`*
a-grave			&agrave;	&a`		*i_&a`*
E-grave			&Egrave;	&E`		*i_&E`*
e-grave			&egrave;	&e`		*i_&e`*
I-grave			&Igrave;	&I`		*i_&I`*
i-grave			&igrave;	&i`		*i_&i`*
O-grave			&Ograve;	&O`		*i_&O`*
o-grave			&ograve;	&o`		*i_&o`*
U-grave			&Ugrave;	&U`		*i_&U`*
u-grave			&ugrave;	&u`		*i_&u`*
A-acute			&Aacute;	&A'		*i_&A'*
a-acute			&aacute;	&a'		*i_&a'*
E-acute			&Eacute;	&E'		*i_&E'*
e-acute			&eacute;	&e'		*i_&e'*
I-acute			&Iacute;	&I'		*i_&I'*
i-acute			&iacute;	&i'		*i_&i'*
O-acute			&Oacute;	&O'		*i_&O'*
o-acute			&oacute;	&o'		*i_&o'*
U-acute			&Uacute;	&U'		*i_&U'*
u-acute			&uacute;	&u'		*i_&u'*
Y-acute			&Yacute;	&Y'		*i_&Y'*
y-acute			&yacute;	&y'		*i_&y'*
A-tilde			&Atilde;	&A~		*i_&A~*
a-tilde			&atilde;	&a~		*i_&a~*
N-tilde			&Ntilde;	&N~		*i_&N~*
n-tilde			&ntilde;	&n~		*i_&n~*
O-tilde			&Otilde;	&O~		*i_&O~*
o-tilde			&otilde;	&o~		*i_&o~*
A-circumflex		&Acirc;		&A^		*i_&A^*
a-circumflex		&acirc;		&a^		*i_&a^*
E-circumflex		&Ecirc;		&E^		*i_&E^*
e-circumflex		&ecirc;		&e^		*i_&e^*
I-circumflex		&Icirc;		&I^		*i_&I^*
i-circumflex		&icirc;		&i^		*i_&i^*
O-circumflex		&Ocirc;		&O^		*i_&O^*
o-circumflex		&ocirc;		&o^		*i_&o^*
U-circumflex		&Ucirc;		&U^		*i_&U^*
u-circumflex		&ucirc;		&u^		*i_&u^*
A-umlaut		&Auml;		&A"		*i_&Aquote*
a-umlaut		&auml;		&a"		*i_&aquote*
E-umlaut		&Euml;		&E"		*i_&Equote*
e-umlaut		&euml;		&e"		*i_&equote*
I-umlaut		&Iuml;		&I"		*i_&Iquote*
i-umlaut		&iuml;		&i"		*i_&iquote*
O-umlaut		&Ouml;		&O"		*i_&Oquote*
o-umlaut		&ouml;		&o"		*i_&oquote*
U-umlaut		&Uuml;		&U"		*i_&Uquote*
u-umlaut		&uuml;		&u"		*i_&uquote*
y-umlaut		&yuml;		&y"		*i_&yquote*
Umlaut			&uml;		&"		*i_&quote*
A-ring			&Aring;		&Ao		*i_&Ao*
a-ring			&aring;		&ao		*i_&ao*
AE-ligature		&AElig;		&AE		*i_&AE*
ae-ligature		&aelig;		&ae		*i_&ae*
C-cedilla		&Ccedil;	&C,		*i_&C,*
c-cedilla		&ccedil;	&c,		*i_&c,*
O-slash			&Oslash;	&O/		*i_&O/*
o-slash			&oslash;	&o/		*i_&o/*
Szlig			&szlig;		&sz		*i_&sz*
Left single arrow	&larr;		&la		*i_&la*
Right single arrow	&rarr;		&ra		*i_&ra*
Up single arrow		&uarr;		&ua		*i_&ua*
Down single arrow	&darr;		&da		*i_&da*
Left-right single arrow	&harr;		&ha		*i_&ha*
Left double arrow	&lArr;		&lA		*i_&lA*
Right double arrow	&rArr;		&rA		*i_&rA*
Up double arrow		&uArr;		&uA		*i_&uA*
Down double arrow	&dArr;		&dA		*i_&dA*
Left-right double arrow	&hArr;		&hA		*i_&hA*


The greek alphabet:

Name:			HTML:		Macro:
--------------------------------------------------------------------
Upper Alpha		&Alpha;		&Al		*i_&Al*
Upper Beta		&Beta;		&Be		*i_&Be*
Upper Gamma		&Gamma;		&Ga		*i_&Ga*
Upper Delta		&Delta;		&De		*i_&De*
Upper Epsilon		&Epsilon;	&Ep		*i_&Ep*
Upper Zeta		&Zeta;		&Ze		*i_&Ze*
Upper Eta		&Eta;		&Et		*i_&Et*
Upper Theta		&Theta;		&Th		*i_&Th*
Upper Iota		&Iota;		&Io		*i_&Io*
Upper Kappa		&Kappa;		&Ka		*i_&Ka*
Upper Lambda		&Lambda;	&Lm		*i_&Lm*
Upper Mu		&Mu;		&Mu		*i_&Mu*
Upper Nu		&Nu;		&Nu		*i_&Nu*
Upper Xi		&Xi;		&Xi		*i_&Xi*
Upper Omicron		&Omicron;	&Oc		*i_&Oc*
Upper Pi		&Pi;		&Pi		*i_&Pi*
Upper Rho		&Rho;		&Rh		*i_&Rh*
Upper Sigma		&Sigma;		&Si		*i_&Si*
Upper Tau		&Tau;		&Ta		*i_&Ta*
Upper Upsilon		&Upsilon;	&Up		*i_&Up*
Upper Phi		&Phi;		&Ph		*i_&Ph*
Upper Chi		&Chi;		&Ch		*i_&Ch*
Upper Psi		&Psi;		&Ps		*i_&Ps*
Lower alpha		&alpha;		&al		*i_&al*
Lower beta		&beta;		&be		*i_&be*
Lower gamma		&gamma;		&ga		*i_&ga*
Lower delta		&delta;		&de		*i_&de*
Lower epsilon		&epsilon;	&ep		*i_&ep*
Lower zeta		&zeta;		&ze		*i_&ze*
Lower eta		&eta;		&et		*i_&et*
Lower theta		&theta;		&th		*i_&th*
Lower iota		&iota;		&io		*i_&io*
Lower kappa		&kappa;		&ka		*i_&ka*
Lower lambda		&lambda;	&lm		*i_&lm*
Lower mu		&mu;		&mu		*i_&mu*
Lower nu		&nu;		&nu		*i_&nu*
Lower xi		&xi;		&xi		*i_&xi*
Lower omicron		&omicron;	&oc		*i_&oc*
Lower pi		&pi;		&pi		*i_&pi*
Lower rho		&rho;		&rh		*i_&rh*
Lower sigma		&sigma;		&si		*i_&si*
Lower sigmaf		&sigmaf;	&sf		*i_&sf*
Lower tau		&tau;		&ta		*i_&ta*
Lower upsilon		&upsilon;	&up		*i_&up*
Lower phi		&phi;		&ph		*i_&ph*
Lower chi		&chi;		&ch		*i_&ch*
Lower psi		&psi;		&ps		*i_&ps*
Lower omega		&omega;		&og		*i_&og*
Lower thetasym		&thetasym;	&ts		*i_&ts*
Lower upsih		&upsih;		&uh		*i_&uh*
Lower piv		&piv;		&pv		*i_&pv*

==============================================================================
6. How to Use Browser Mappings				*browser-control*

You can use a browser to preview your current HTML document.  (See
|html-author-notes|)



For Windows:				*browser-control-windows*
								*n_;db*
;db	Call the default browser on the current file.
								*n_;ie*
;ie	Call Explorer on the current file.


For Mac OS X:				*browser-control-macos*

The following mappings are only defined if you have properly installed the
browser_launcher.vim script, available with installation instructions here:
http://www.infynity.spodzone.com/vim/HTML/

Opening new tabs and windows depends on the built-in Graphic User Interface
Scripting architecture of Mac OS X which comes disabled by default. You can
activate GUI Scripting by selecting the checkbox "Enable access for assistive
devices" in the Universal Access preference pane.
								*n_;db*
;db	Call the default browser on the current file.
								*n_;ff*
;ff	Make Firefox view the current file, starting Firefox if it is not
	running.
								*n_;nff*
;nff	Same as |;ff|, but start a new browser window.
								*n_;tff*
;tff	Same as |;nff|, but open a new tab.
								*n_;oa*
;oa	Make Opera view the current file, starting Opera if it is not running.
								*n_;noa*
;noa	Same as |;oa|, but start a new browser window.
								*n_;toa*
;toa	Same as |;noa|, but open a new tab.
								*n_;sf*
;sf	Make Safari view the current file, starting Safari if it is not running.
								*n_;nsf*
;nsf	Same as |;sf|, but start a new browser window.
								*n_;tsf*
;tsf	Same as |;nsf|, but open a new tab.


For Unix:				*browser-control-unix*

The following mappings are only defined if you have properly installed the
browser_launcher.vim script, available with installation instructions here:
http://www.infynity.spodzone.com/vim/HTML/
								*n_;ff*
;ff	Make Firefox view the current file, starting Firefox if it is not
	running.
								*n_;nff*
;nff	Same as |;ff|, but start a new browser window.
								*n_;tff*
;tff	Same as |;nff|, but open a new tab.
								*n_;mo*
;mo	Make Mozilla view the current file, starting Mozilla if it is not
	running.
								*n_;nmo*
;nmo	Same as |;mo|, but start a new browser window.
								*n_;tmo*
;tmo	Same as |;nmo|, but open a new tab.
								*n_;ne*
;ne	Make Netscape view the current file, starting Netscape if it is not
	running.
								*n_;nne*
;nne	Same as |;ne|, but start a new browser window.

Note: If Firefox and/or Mozilla and/or Netscape are running, these mappings
may behave somewhat unexpectedly, due to the fact that Firefox, Mozilla and
Netscape use the same remote protocol IDs.
								*n_;oa*
;oa	Make Opera view the current file, starting Opera if it is not running.
								*n_;noa*
;noa	Same as |;oa|, but start a new browser window.
								*n_;toa*
;toa	Same as |;noa|, but open a new tab.
								*n_;ly*
;ly	Use lynx to view the current file.  This behaves like |;nly| if the Vim
	GUI is running.
								*n_;nly*
;nly	Same as |;ly|, but in a new xterm.  This behaves like |;ly| if there
	is no DISPLAY environmental variable.
								*n_;w3*
;w3	Use w3m to view the current file.  This behaves like |;nw3| if the Vim
	GUI is running.
								*n_;nw3*
;nw3	Same as |;w3|, but in a new xterm.  This behaves like |;w3| if there
	is no DISPLAY environmental variable.

==============================================================================
7. Miscellaneous Extras					*html-misc*


:SetIfUnset {variable} {value}				*:SetIfUnset*
This calls |SetIfUnset()|.


Functions used by the HTML mappings:			*html-functions*
------------------------------------

HTMLencodeString({string} [, {...}])			*HTMLencodeString()*
	Returns {string} encoded into HTML entities.

	If the second argument is "%" the string is encoded into %XX
	hexadecimal string instead.

	If the second argument is "d" or "decode" the &#...; and %XX elements
	of the provided string will be decoded into their actual characters.

	See |n_;&| and |n_;%| for examples.

	Note that Unicode characters can not be safely converted to %XX hex
	strings for URIs do to a limit in the specification.

HTMLgenerateTable()					*HTMLgenerateTable()*
	This is normally called by the normal mapping |;ta|, but it works the
	same if called any other way.

HTMLmap({maptype}, {lhs}, {rhs} [, {re-indent}])	*HTMLmap()*
	This function defines a mapping, local to the buffer and silent.
	{maptype} is any map command.  {lhs} and {rhs} are equivalent to :map
	arguments, see |map.txt|.  This is useful for autocommands and HTML
	filetype plugins.

	If {lhs} starts with "<lead>" that string will replaced with the
	contents of |g:html_map_leader|.

	If {lhs} starts with "<elead>" that string will replaced with the
	contents of |g:html_map_entity_leader|.

	Any text in {rhs} that is enclosed by [{}] will be converted to
	uppercase/lowercase according to the |g:html_tag_case| variable, and
	the [{}] markers will be removed.

	{re-indent} is optional, applies only to visual maps when filetype
	indenting is enabled, and should not be used for maps that enter
	insert mode.  If the value is 1, the visually selected area is
	re-selected, plus one line below, and re-indented.  A value of 2 does
	the same without moving down a line.

	The special cases of 0 means the visual mapping enters visual mode,
	and -1 tells the function not to add any special extra code to the
	visual mapping.

	Note that more "magic" than what's documented here gets applied to the
	mappings depending on their mode, the value of {re-indent} and so on.

HTMLmapo({map}, {insert})					*HTMLmapo()*
	Creates an operator-pending mapping wrapper for {map} that calls the
	visual mapping by the same name.  {insert} is a boolean value (0 or 1)
	that indicates whether to end in insert mode.

HTMLnextInsertPoint([{mode}])				*HTMLnextInsertPoint()*
	This is normally called by the |;<Tab>| mapping, but it works the same
	if called any other way.  The {mode} argument is either 'i' or 'n'
	(default) which means |Insert| or |Normal|.  In insert mode, if the
	cursor is on the start of a closing tag it places the cursor after the
	tag.

HTMLtemplate()						*HTMLtemplate()*
	This is normally called by the normal mapping |;html|, but it works
	the same if called any other way.

SetIfUnset({variable}, {value})				*SetIfUnset()*
	This function sets {variable} to {value} if the variable is not
	already set.  A {value} of "-" makes sure the variable is set with an
	empty string.  This function will not work for function-local
	variables. (|l:var|)


Author's notes:						*html-author-notes*
---------------
The Content-Type charset automatic detection value based on the 'fileencoding'
/ 'encoding' option has a very incomplete translation table from the possible
values that Vim uses--I could use help with this.

I want to finally release a 1.0 version, but I am not willing to until I have
browser control mappings for operating systems other than *nix.  Unfortunately
I need substantial help to create them for Windows and MacOS since I do not
have access to either OS.

I will never include mappings for certain tags, such as <BLINK></BLINK> and
<MARQUEE></MARQUEE>.  As far as I am concerned these tags should never have
existed.  (I disable these "features" completely in my browser.)

 vim:tw=78:ts=8:sw=8:ft=help:fo=tcq2:ai:
MangleImageTag.vim	[[[1
299
" MangleImageTag() - updates an <IMG>'s width and height tags.
"
" Requirements:
"       VIM 7 or later
"
" Copyright (C) 2004-2008 Christian J. Robinson <heptite@gmail.com>
"
" Based on "mangleImageTag" by Devin Weaver <ktohg@tritarget.com>
"
" This program is free software; you can  redistribute  it  and/or  modify  it
" under the terms of the GNU General Public License as published by  the  Free
" Software Foundation; either version 2 of the License, or  (at  your  option)
" any later version.
"
" This program is distributed in the hope that it will be useful, but  WITHOUT
" ANY WARRANTY; without  even  the  implied  warranty  of  MERCHANTABILITY  or
" FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General  Public  License  for
" more details.
"
" You should have received a copy of the GNU General Public License along with
" this program; if not, write to the Free Software Foundation, Inc., 59 Temple
" Place - Suite 330, Boston, MA 02111-1307, USA.
"
" RCS info: -------------------------------------------------------------- {{{
" $Id: MangleImageTag.vim,v 1.13 2009/06/23 14:04:35 infynity Exp $
" $Log: MangleImageTag.vim,v $
" Revision 1.13  2009/06/23 14:04:35  infynity
" *** empty log message ***
"
" Revision 1.12  2008/05/30 00:53:28  infynity
" - Clarify an error message
" - Don't move the cursor when updating the tag
"
" Revision 1.11  2008/05/26 01:11:25  infynity
" *** empty log message ***
"
" Revision 1.10  2008/05/01 05:01:02  infynity
" Code changed for Vim 7:
"  - Computed sizes should always be correct now
"  - Code is a bit cleaner, but unfortunately slower
"
" Revision 1.9  2007/05/04 02:03:42  infynity
" Computed sizes were very wrong when 'encoding' was set to UTF8 or similar
"
" Revision 1.8  2007/05/04 01:32:27  infynity
" Missing quotes
"
" Revision 1.7  2007/01/04 04:29:55  infynity
" Enclose the values of the width/height in quotes by default
"
" Revision 1.6  2006/09/22 06:25:14  infynity
" Search for the image file in the current directory and the buffer's directory.
"
" Revision 1.5  2006/06/09 07:56:08  infynity
" Was resetting 'autoindent' globally, switch it to locally.
"
" Revision 1.4  2006/06/08 04:16:17  infynity
" Temporarily reset 'autoindent' (required for Vim7)
"
" Revision 1.3  2005/05/19 18:31:31  infynity
" SizeGif was returning width as height and vice-versa.
"
" Revision 1.2  2004/03/22 10:04:24  infynity
" Update the right tag if more than one IMG tag appears on the line.
"
" Revision 1.1  2004/03/22 05:58:34  infynity
" Initial revision
" ------------------------------------------------------------------------ }}}

if v:version < 700 || exists("*MangleImageTag")
	finish
endif

function! MangleImageTag() "{{{1
	let start_linenr = line('.')
	let end_linenr = start_linenr
	let col = col('.') - 1
	let line = getline(start_linenr)

	if line !~? '<img'
		echohl ErrorMsg
		echomsg "The current line does not contain an image tag (see :help ;mi)."
		echohl None

		return
	endif

	" Get the rest of the tag if we have a partial tag:
	while line =~? '<img\_[^>]*$'
		let end_linenr = end_linenr + 1
		let line = line . "\n" . getline(end_linenr)
	endwhile

	" Make sure we modify the right tag if more than one is on the line:
	if line[col] != '<'
		let tmp = strpart(line, 0, col)
		let tagstart = strridx(tmp, '<')
	else
		let tagstart = col
	endif
	let savestart = strpart(line, 0, tagstart)
	let tag = strpart(line, tagstart)
	let tagend = stridx(tag, '>') + 1
	let saveend = strpart(tag, tagend)
	let tag = strpart(tag, 0, tagend)

	if tag[0] != '<' || col > strlen(savestart . tag) - 1
		echohl ErrorMsg
		echomsg "Cursor isn't on an IMG tag."
		echohl None

		return
	endif

	if tag =~? "src=\\(\".\\{-}\"\\|'.\\{-}\'\\)"
		let src = substitute(tag, ".\\{-}src=\\([\"']\\)\\(.\\{-}\\)\\1.*", '\2', '')
		if tag =~# 'src'
			let case = 0
		else
			let case = 1
		endif
	else
		echohl ErrorMsg
		echomsg "Image src not specified in the tag."
		echohl None

		return
	endif

	if ! filereadable(src)
		if filereadable(expand("%:p:h") . '/' . src)
			let src = expand("%:p:h") . '/' . src
		else
			echohl ErrorMsg
			echomsg "Can't find image file: " . src
			echohl None

			return
		endif
	endif

	let size = s:ImageSize(src)
	if len(size) != 2
		return
	endif

	if tag =~? "height=\\(\"\\d\\+\"\\|'\\d\\+\'\\|\\d\\+\\)"
		let tag = substitute(tag,
			\ "\\c\\(height=\\)\\([\"']\\=\\)\\(\\d\\+\\)\\(\\2\\)",
			\ '\1\2' . size[1] . '\4', '')
	else
		let tag = substitute(tag,
			\ "\\csrc=\\([\"']\\)\\(.\\{-}\\|.\\{-}\\)\\1",
			\ '\0 ' . (case ? 'HEIGHT' : 'height') . '="' . size[1] . '"', '')
	endif

	if tag =~? "width=\\(\"\\d\\+\"\\|'\\d\\+\'\\|\\d\\+\\)"
		let tag = substitute(tag,
			\ "\\c\\(width=\\)\\([\"']\\=\\)\\(\\d\\+\\)\\(\\2\\)",
			\ '\1\2' . size[0] . '\4', '')
	else
		let tag = substitute(tag,
			\ "\\csrc=\\([\"']\\)\\(.\\{-}\\|.\\{-}\\)\\1",
			\ '\0 ' . (case ? 'WIDTH' : 'width') . '="' . size[0] . '"', '')
	endif

	let line = savestart . tag . saveend

	let saveautoindent=&autoindent
	let &l:autoindent=0

	call setline(start_linenr, split(line, "\n"))

	let &l:autoindent=saveautoindent
endfunction

function! s:ImageSize(image) "{{{1
	let ext = fnamemodify(a:image, ':e')

	if ext !~? 'png\|gif\|jpe\?g'
		echohl ErrorMsg
		echomsg "Image type not recognized: " . tolower(ext)
		echohl None

		return
	endif

	if filereadable(a:image)
		let ldsave=&lazyredraw
		set lazyredraw

		let buf=readfile(a:image, 'b', 1024)
		let buf2=[]

		let i=0
		for l in buf
			let string = split(l, '\zs')
			for c in string
				let char = char2nr(c)
				call add(buf2, (char == 10 ? '0' : char))

				" Keep the script from being too slow, but could cause a JPG
				" (and GIF/PNG?) to return as "malformed":
				let i+=1
				if i > 1024 * 4
					break
				endif
			endfor
			call add(buf2, '10')
		endfor

		if ext ==? 'png'
			let size = s:SizePng(buf2)
		elseif ext ==? 'gif'
			let size = s:SizeGif(buf2)
		elseif ext ==? 'jpg' || ext ==? 'jpeg'
			let size = s:SizeJpg(buf2)
		endif
	else
		echohl ErrorMsg
		echomsg "Can't read file: " . a:image
		echohl None

		return
	endif

	return size
endfunction

function! s:SizeGif(lines) "{{{1
	let i=0
	let len=len(a:lines)
	while i <= len
		if join(a:lines[i : i+9], ' ') =~ '^71 73 70\( \d\+\)\{7}'
			let width=s:Vec(reverse(a:lines[i+6 : i+7]))
			let height=s:Vec(reverse(a:lines[i+8 : i+9]))

			return [width, height]
		endif
		let i+=1
	endwhile

	echohl ErrorMsg
	echomsg "Malformed GIF file."
	echohl None

	return
endfunction

function! s:SizeJpg(lines) "{{{1
	let i=0
	let len=len(a:lines)
	while i <= len
		if join(a:lines[i : i+8], ' ') =~ '^255 192\( \d\+\)\{7}'
			let height = s:Vec(a:lines[i+5 : i+6])
			let width = s:Vec(a:lines[i+7 : i+8])

			return [width, height]
		endif
		let i+=1
	endwhile

	echohl ErrorMsg
	echomsg "Malformed JPEG file."
	echohl None

	return
endfunction

function! s:SizePng(lines) "{{{1
	let i=0
	let len=len(a:lines)
	while i <= len
		if join(a:lines[i : i+11], ' ') =~ '^73 72 68 82\( \d\+\)\{8}'
			let width = s:Vec(a:lines[i+4 : i+7])
			let height = s:Vec(a:lines[i+8 : i+11])

			return [width, height]
		endif
		let i+=1
	endwhile

	echohl ErrorMsg
	echomsg "Malformed PNG file."
	echohl None

	return
endfunction

function! s:Vec(nums) "{{{1
	let n = 0
	for i in a:nums
		let n = n * 256 + i
	endfor
	return n
endfunction

" vim:ts=4:sw=4:
" vim600:fdm=marker:fdc=2:cms=\ \"%s:
