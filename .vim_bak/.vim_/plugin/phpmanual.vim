" v:set ts=8 sts=2 sw=2 tw=0:
"
" phpmanual.vim - PHP Manual Viewer

scriptencoding euc-jp

" Version:     1.3
" Last Change: 2005-02-13.

let s:version = '1.3'

" Description:
"   Vim のウインドウを分割して、PHP マニュアルを開きます。
"   または、指定した外部のブラウザで PHP のマニュアルを開きます。
"
"   以下のコマンドを使用します。必要に応じてオプションによる変更も
"   可能です。
"
"   wget  : Web サイトから PHP マニュアルを取得するのに必要です。
"           ローカルの PHP マニュアルを使用する場合は不要です。
"
"   iconv : PHP マニュアルは、UTF-8 で書かれているため、EUC-JP に
"           変換する際に使用します。オプションによって、別のコマンド
"           ( 例えば UTF-8 の変換に対応した nkf )に変更すること
"           も可能です。
"
"   w3m   : 取得した PHP マニュアルのテキスト整形に w3m を使用して
"           います。オプションによって、別のコマンドに変更すること
"           も可能です。ただし、標準入力からテキストに変換することが
"           できる必要があります。
"
" Usage:
"  キーマップ設定(変更可)
"
"      <Leader>P - カーソルにある PHP の関数に対してマニュアルを開きます。
"
"      <Leader>E - 設定した外部ブラウザでカーソルにある PHP 関数の
"                  マニュアルを開きます。
"
"      <Leader> は、通常、\ (バックスラッシュ) に割り当てられています。
"      <Leader>P は、\ を押してから、P を押します。
"
"      Note: <Leader>E は、外部ブラウザの設定をしたときのみ使用可能です。
"           外部ブラウザを使用するには、let phpmanual_use_ext_browser を 1 に
"           してください。デフォルトでは外部ブラウザは使用しない設定に
"           なっています。
"
" または、以下のコマンドからの呼び出しでも可能です。コマンド名も変更可能です。
"
"     Vim ウインドウ内にマニュアルを開きます。以下のオプションがあります。
"
"       :PHPManual <関数名>      : <関数名>で指定した関数のマニュアルを表示します。
"       :PHPManual func <関数名> : <関数名>で指定した関数のマニュアルを表示します。
"                                  func は省略可能で、機能は同じです。
"       :PHPManual funclist      : 関数一覧ページを表示します。
"       :PHPManual ref <識別名>  : 関数リファレンスの説明ページを表示します。
"                                  <識別名>は :PHPManual reflist で確認してください。
"       :PHPManual reflist       : 関数リファレンスの説明ページを呼び出すための
"                                  識別名一覧を表示します。
"       :PHPManual help          : 使い方の説明を表示します。
"
"     外部ブラウザで関数名に対するマニュアルを開きます。
"
"       :PHPManualExtBrowser <関数名>
"
" Option:
"  .vimrc で設定可能なオプション:
"
"      let phpmanual_command         = 'PHPManual'
"          プラグイン呼び出しの Vim コマンド名 (デフォルト: PHPManual)
"
"      let phpmanual_mapname         = '<Leader>P'
"          カーソルの下にある関数を引数にしてコマンドを呼び出すための
"          キーマップ ( デフォルト: \P )
"
"      let phpmanual_use_ext_browser = 0
"          0: 外部ブラウザは使用しません。(デフォルト)
"          1: 外部ブラウザを使用します。
"
"      let phpmanual_ext_command     = 'PHPManualExtBrowser'
"          外部ブラウザを呼び出すときの Vim コマンド名
"          ( デフォルト : PHPManualExtBrowser )
"
"      let phpmanual_mapname         = '<Leader>E'
"          カーソルの下にある関数を引数にして外部ブラウザを呼び出すための
"          キーマップ ( デフォルト: \E )
"
"      let phpmanual_ext_browser_cmd = 'mozilla'
"          外部ブラウザの実行コマンド ( デフォルト: mozilla )
"
"      let phpmanual_man_site        = 'http://jp.php.net/'
"          外部ブラウザから呼び出すサイト。
"          ( デフォルト: http://jp.php.net/ )
"
"        Note: 外部ブラウザからの呼び出しは、PHP の WEB サーバのトップに
"              関数名を付けて呼び出す機能を使用しているため、
"              PHP のミラーサーバ以外ではうまく表示されません。
"
"      let phpmanual_dir             = 'http://jp.php.net/manual/ja/print/'
"          Vim のウインドウ分割から呼び出されるサイトです。
"          またはローカルディレクトリも指定できます。
"          ( デフォルト: http://jp.php.net/manual/ja/print/ )
"
"        Note: 外部からマニュアルを取得するため、サイトの接続に時間が
"              かかると、しばらく操作ができなくなりますので、ローカルに
"              PHP マニュアルをダウンロードして、そのディレクトリを
"              設定した方が良いです。
"
"      let phpmanual_file_ext        = 'php'
"          取得するファイルの拡張子。PHP サーバにある PHP マニュアルは
"          拡張子が php ですが、ダウンロードしたマニュアルは拡張子が
"          html ですので、必要に応じて変更してください。
"
"          php  : PHP マニュアルの拡張子が php (デフォルト)
"          html : PHP マニュアルの拡張子が html
"
"      let phpmanual_convfilter      = 'iconv -c -f utf-8 -t euc-jp'
"          PHP マニュアルの文字コードは UTF-8 ですので、それを EUC に変換
"          する必要があります。iconv の方がインストールされている可能性が
"          高いので、デフォルトでは iconv にしました。
"
"      let phpmanual_htmlviewer      = 'w3m -T text/html'
"          HTML をテキストに変換するツールとして w3m を使用します。
"          標準入力から整形ができるように -T オプションを使用しています。
"
"      let phpmanual_color           = 1
"          PHP マニュアルでカラー表示を行います。
"          カラー表示が必要ない場合は 0 に設定してください。
"
"  設定例:
"      let phpmanual_dir             = '/home/manual/php_manual/'
"          ローカルの /home/manual/php_manual/ にある PHP マニュアルを使用
"          するように設定します。
"
"      let phpmanual_file_ext        = 'html'
"          ローカルにある PHP マニュアルの拡張子は html であることを指定
"          します。
"
"      let phpmanual_use_ext_browser = 1
"          外部のブラウザを使用するように設定します。
"
"      let phpmanual_ext_browser_cmd = '~/bin/mozilla.sh'
"          外部ブラウザの呼び出しでは mozilla のラッパースクリプトを呼び出す
"          ように指定します。
"
"      let phpmanual_convfilter      = '/usr/local/bin/nkf -e'
"          文字コード変換に UTF-8 対応の nkf を使用するように設定します。
"
" ChangeLog:
"     1.0   : 公開 (2003-07-13)
"
"     1.0.1 : メールで指摘を受けましたので、いくつか修正を行いました。
"             森さん、指摘をどうもありがとうございました。(2003-12-10)
"
"             - GNU libiconv で文字コード変換に失敗していたのを修正しました。
"             - 関数名の最初が大文字だった場合、不正な関数名になってしまっていた
"               問題を修正しました。
"
"     1.1   : 機能を追加しました(2003-12-14)
"
"             - 誤字、脱字の修正を行いました。
"             - ヘルプを作成しました。
"               :PHPManual help
"             - 関数リファレンスの説明ページを表示できるようにしました。
"               :PHPManual ref <識別名>
"             - 関数一覧、関数リファレンスの一覧を表示できるようにしました。
"               :PHPManual reflist
"               :PHPManual funclist
"
"     1.2   : いろいろと細かい修正
"
"             - 誤字、脱字の修正を行いました。
"             - :PHPManual reflist を実行した時に、リファレンス一覧取得を
"               PHP マニュアルの funcref.(html|php) ファイルから取得するように
"               変更し、ウインドウ内に表示するようにしました。
"
"     1.3   : マニュアルのカラー表示機能を追加しました (2005-02-15)
"
"             - デフォルトではカラー表示を行います。
"             - この機能が必要ない場合は phpmanual_color = 0 を設定してください。

" 2重読み込み防止処理
if exists("loaded_phpManualViewer")
  finish
endif
let loaded_phpManualViewer = 1

" コマンド名(デフォルト値: PHPManual)
if !exists("g:phpmanual_command")
  let g:phpmanual_command = "PHPManual"
endif

" キーマップ(デフォルト値: \P)
if !exists("g:phpmanual_mapname")
  let g:phpmanual_mapname = "<Leader>P"
endif

" Syntax 設定
if !exists("g:phpmanual_color")
  let g:phpmanual_color = 1
endif

" Vim のウインドウに表示させる時のコマンドとキーマップの登録
exec 'command! -nargs=+ ' . g:phpmanual_command . ' :call <SID>loadManual(<f-args>)'
exec 'nnoremap '          . g:phpmanual_mapname . ' :call <SID>getFunctionWord("vim")<CR>'

"
" 外部ブラウザを使用する設定になっている場合はブラウザとサイトの設定
"
if exists("g:phpmanual_use_ext_browser") && g:phpmanual_use_ext_browser == 1

  " 外部ブラウザ使用の場合のコマンド名(デフォルト値: PHPManualExtBrowser)
  if !exists("g:phpmanual_ext_command")
    let g:phpmanual_ext_command = "PHPManualExtBrowser"
  endif
  
  " 外部ブラウザ使用の場合のキーマップ(デフォルト値: \E)
  if !exists("g:phpmanual_ext_mapname")
    let g:phpmanual_ext_mapname = "<Leader>E"
  endif

  " 外部ブラウザコマンド
  if !exists('g:phpmanual_ext_browser_cmd')
    let g:phpmanual_ext_browser_cmd = "mozilla"
  endif

  " 外部ブラウザ用
  if !exists('g:phpmanual_man_site')
    let g:phpmanual_man_site = "http://jp.php.net/"
  endif

  " コマンド名とキーマップの登録
  exec 'command! -nargs=1 ' . g:phpmanual_ext_command . ' :call <SID>loadManualExtBrowser(<f-args>)'
  exec 'nnoremap '          . g:phpmanual_ext_mapname . ' :call <SID>getFunctionWord("ext")<CR>'

endif

"
" マニュアルのディレクトリ設定と拡張子設定
"
if !exists('g:phpmanual_dir')
  " 通常印刷用マニュアル(外部から取得)
  let g:phpmanual_dir      = "http://jp.php.net/manual/ja/print/"
  let g:phpmanual_file_ext = "php"

  " ローカルに PHP マニュアルがある場合の指定(例)
  "let g:phpmanual_dir      = "/home/manual/php_manual/"
  "let g:phpmanual_file_ext = "html"

  " ユーザノート付き印刷用マニュアル(外部から取得)
  "let g:phpmanual_dir      = "http://jp.php.net/manual/ja/printwn/"
  "let g:phpmanual_file_ext = "php"
endif

"
" UTF-8 -> EUC 変換フィルタ
"
if !exists('g:phpmanual_convfilter')
  " iconv を使用
  let g:phpmanual_convfilter = "iconv -c -f utf-8 -t euc-jp"

  " UTF-8 対応 nkf を使用する場合
  "let g:phpmanual_convfilter = "nkf -e"
endif

"
" HTML 表示ビューア(標準入力からの読み込み)
"
if !exists('g:phpmanual_htmlviewer')
  " w3m を使用
  let g:phpmanual_htmlviewer = "w3m -T text/html"
endif

"
" 拡張子の設定がない場合は空白 -> エラーが発生するため使用不可
"
if !exists("g:phpmanual_file_ext") 
  let g:phpmanual_file_ext = ""
endif

"
" マニュアル読み込み関数
"
function! s:loadManual(command, ...)

  if a:command ==# 'help'
    let result = s:dispHelp()
    return
  elseif a:command ==# 'reflist'
    let command = 'reflist'
    let word    = 'funcref'
  elseif a:command ==# 'funclist'
    let command = 'func'
    let word    = 'funclist'
  elseif a:0 == 0
    let command = ''
    let word    = a:command
  elseif a:command =~ '^\(ref\|func\)$'
    let command = a:command
    let word    = a:1
  else
    let command = 'func'
    let word    = a:command
  endif

  " 拡張子のチェック
  if g:phpmanual_file_ext !~ '^\(php\|html\)$'
    echo "拡張子の設定が不正です。拡張子 (" . g:phpmanual_file_ext . ") は使用できません。"
    return
  endif

  " 関数名を小文字に変換
  let word     = tolower(word)

  " 関数名チェック
  if s:checkFunctionName(word) == 0
    echo "不正な関数名です(" . word . ")。"
    return
  endif

  " 引数処理(PHP マニュアルのファイル名は、 _ は - に置き換えられる)を行い、
  " 関数名からファイル名の接頭語を取得
  let filename = s:getFilePrefix(command, substitute(word, "_", "-", "g"))
  let resource = g:phpmanual_dir . filename . "." . g:phpmanual_file_ext

  " resource がローカルディレクトリの場合
  if resource !~ "^http://"
    " ローカルにある PHP マニュアルファイルの存在確認
    if !filereadable(resource)
      echo word . " のマニュアルが見つかりません。"
      return
    endif
  else
    " 外部から HTML を取得
    let tmpfile = tempname()
    let result  = system("wget -nv -O " . tmpfile . " " . resource)
    if filereadable(tmpfile) && getfsize(tmpfile) > 0
      let resource = tmpfile
    else
      echo "ファイルの取得に失敗しました。"
      return
    endif
  endif

  let result = s:display(command, resource, g:phpmanual_convfilter, g:phpmanual_htmlviewer)

  " テンポラリファイルがある場合は削除
  if exists("tmpfile") && filereadable(tmpfile)
    call delete(tmpfile)
  endif

endfunction  

function! s:display(command, resource, filter, viewer)
  " 既に PHP マニュアルを表示しているウインドウがあれば再利用
  let thiswin = winnr()
  exec "norm! \<C-W>b"

  if &filetype != "php_manual"
    let thiswin = winnr()
    exec "norm! \<C-W>b"
    if winnr() == 1
      new
    else
      exec "norm! " . thiswin . "\<C-W>w"
      while 1
        if &filetype == "php_manual"
          break
        endif
        exec "norm! \<C-W>w"
        if thiswin == winnr()
          new
          break
        endif
      endwhile
    endif
  endif

  " スワップファイルを作成しない
  set buftype=nofile noswapfile

  " マーク設定
  set ma

  " 現在表示中のバッファを削除
  silent exec "norm 1GdG"

  " 表示
  if a:command ==# "reflist"
    silent exec 'r ' . a:resource
    silent exec 'g/^HREF/norm gJ'
    silent exec 'g!/^HREF="ref\.[a-z]*\.' . g:phpmanual_file_ext . '">[^<]/d'
    silent exec '%s/^HREF="ref\.\([a-z]*\)\.' . g:phpmanual_file_ext . '">\(.*\)<\/A$/\1\t\t: \2/'
    setlocal tabstop=20
    silent exec "norm ggO"
    silent exec 'r! ++enc=euc-jp echo "使い方 :PHPManual ref <識別名>" && echo ""'
    silent exec 'r! ++enc=euc-jp echo "例: 以下を実行すると、関数リファレンスの Apache 用関数のページが表示されます。"'
    silent exec 'r! echo "" && echo "  :PHPManual ref apache" && echo ""'
    silent exec 'r! ++enc=euc-jp echo "識別名は以下の通りです。" && echo "--"'
    silent exec "norm ggdd"
  else
    silent exec "r! ++enc=euc-jp " . a:filter. " " . a:resource . " | " . a:viewer
  endif

  " 一番上に移動
  silent exec "norm gg"

  " 表示後、変更を不可、バッファには表示しないように設定する
  setlocal filetype=php_manual nomod
  setlocal bufhidden=hide
  setlocal nobuflisted

  " Syntax の設定
  if has('syntax') && g:phpmanual_color == 1
     setlocal syntax=php
	 let dtd_ignore_case=0
     syntax match Ignore /\(^\| \)\(<\|>\)\(,\| \|$\)\|=>\|<=\|>=\|->\|<>/
     syntax match Function /^[a-z][0-9a-z_]*\( -- .*\|$\)/
     syntax match Tag /[a-z][0-9a-z_]*()/
     syntax match Underlined /^\<\(Description\|Example\|Table\|例\|説明\)\>.*$/
     syntax match Type /\<\(int\|bool\|void\|string\|double\|float\|array\|resource\|static\|mixed\)\>/
     syntax match Keyword /\<Note:\>\|\<注意:\>/
     syntax match Error /\<Warning\>\|\<警告\>/
  endif

  return 1
endfunction

"
" カーソルにある関数名を取得
"
function! s:getFunctionWord(browser)
  let str  = expand("<cword>")
  let word = substitute(str, '(*\(\k\+\).*', '\1', '')

  " マニュアル呼び出し
  if a:browser ==# 'vim'
    call s:loadManual(word)
  elseif a:browser ==# 'ext'
    call s:loadManualExtBrowser(word)
  else
    echo word
  endif
  return
endfunction

"
" 外部ブラウザ使用時の処理
"
function! s:loadManualExtBrowser(word)
  if s:checkFunctionName(a:word) == 0
    echo "不正な関数名です。"
    return
  endif

  " 外部ブラウザの設定があれば、指定の URI を開く
  if exists("g:phpmanual_ext_browser_cmd")
    " man_site が外部の URI の場合、PHP サーバへの問い合わせ文字列を作成
    let resource = g:phpmanual_man_site . a:word
    let result   = system(g:phpmanual_ext_browser_cmd . " " . resource)
  else
    echo "外部ブラウザの設定が正しくありません。"
  endif
  return
endfunction

"
" PHP 関数名チェック
"
function! s:checkFunctionName(word)
  if a:word !~ '^[a-z][_a-z0-9]*$'
    return 0
  endif
  return 1
endfunction

"
" 関数名からファイルの接頭語を取得
"
function! s:getFilePrefix(command, word)
  " 関数説明を表示
  if a:command ==# "ref"
    let prefix = "ref." . a:word

  " リファレンス一覧表示
  elseif a:command ==# "reflist"
    let prefix = "funcref"

  " 関数一覧表示
  elseif a:word ==# "funclist"
    let prefix = "index.functions"

  " 制御構造のマニュアル
  elseif a:word =~ '^\(alternative-syntax\|break\|continue\|declare\|do\|else\|elseif\|for\|foreach\|switch\|while\)$'
    " do.while のマニュアルは do を指定したときに表示
    if a:word ==# "do"
      let prefix = "control-structures.do.while"
    else
      let prefix = "control-structures." . a:word
    endif

  " リファレンスのトップページ
  elseif a:word =~ '^\(apache\|array\|aspell\|bc\|bzip2\|calendar\|ccvs\|classobj\|com\|cpdf\|crack\|ctype\|curl\|cybercash\|cyrus\|datetime\|dba\|dbase\|dbm\|dbplus\|dbx\|dio\|dir\|dom\|domxml\|dotnet\|errorfunc\|exec\|fam\|fbsql\|fdf\|filepro\|filesystem\|fribidi\|ftp\|funchand\|gettext\|gmp\|http\|hw\|hwapi\|ibase\|iconv\|id3\|ifx\|image\|imap\|info\|ingres\|ircg\|java\|ldap\|lzf\|mail\|mailparse\|math\|mbstring\|mcal\|mcrypt\|mcve\|memcache\|mhash\|mime-magic\|ming\|misc\|mnogosearch\|msession\|msql\|mssql\|muscat\|mysql\|mysqli\|ncurses\|network\|nis\|notes\|nsapi\|objaggregation\|oci8\|openssl\|oracle\|outcontrol\|overload\|ovrimos\|pcntl\|pcre\|pdf\|pfpro\|pgsql\|posix\|printer\|pspell\|qtdom\|readline\|recode\|regex\|sem\|sesam\|session\|shmop\|simplexml\|snmp\|soap\|sockets\|spl\|sqlite\|stream\|strings\|swf\|sybase\|tcpwrap\|tidy\|tokenizer\|uodbc\|url\|var\|vpopmail\|w32api\|wddx\|xdiff\|xml\|xmlrpc\|xsl\|xslt\|yaz\|zip\|zlib\)$'
    " array, exec, filepro, gettext, iconv, mail, mhash, msql, overolad, readline, recode については、
    " 関数名と重複するため、関数説明のマニュアルを優先
    if a:word =~ '^\(array\|exec\|filepro\|gettext\|iconv\|mail\|mhash\|msql\|overolad\|readline\|recode\)$'
      let prefix = "function." . a:word
    else
      let prefix = "ref." . a:word
    endif

  " 関数説明のマニュアル
  else
    let prefix = "function." . a:word
  endif

  return prefix
endfunction

"
" ヘルプ表示
"
function! s:dispHelp()
  echo '使い方'
  echo ' '
  echo ':PHPManual (ref|reflist|func|funclist|help) <識別名(関数名)>'
  echo ' '
  echo 'オプションは省略可能です。その場合は、見つかった関数名のマニュアルを表示します。'
  echo ' '
  echo 'カーソルが関数の上にある時に、\P (デフォルト) を押すと、対応するマニュアルを Vim の運動を分割して表示します。'
  echo '外部ブラウザの設定を行っている場合は \E (デフォルト) を押すと、指定したブラウザでマニュアルを表示します。'
  echo ' '
  echo '例:'
  echo ' '
  echo ':PHPManual <関数名>      : 関数名で指定した関数のマニュアルを表示します。'
  echo ':PHPManual func <関数名> : 関数名で指定した関数のマニュアルを表示します。func は省略可能で機能は同じです。'
  echo ':PHPManual funclist      : 関数一覧ページを表示します。'
  echo ':PHPManual ref <識別名>  : 関数リファレンスの説明ページを表示します。識別名は :PHPManual reflist で確認してください。'
  echo ':PHPManual reflist       : 関数リファレンスの説明ページを呼び出すための識別名一覧を表示します。'
  echo ':PHPManual help          : 使い方の説明を表示します。'
  echo ' '
  echo ':PHPManualExtBrowser <関数名> : 設定した外部ブラウザで関数名のマニュアルを開きます。'
  return
endfunction
