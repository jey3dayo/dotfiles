" dsfcg.vim -- Doxygen style function comment generator
" 
" version : 0.1.6
" author : ampmmn(htmnymgw <delete>@<delete> gmail.com)
" url    : http://d.hatena.ne.jp/ampmmn
"
" ----
" history
"	 0.1.6		2008-10-29	Bugfix for alignment output.
"	 0.1.5		2008-09-24	Bugfix for keymapping.
"	 0.1.4		2008-09-05	support PHP,Python,Perl,Ruby,JavaScript
"	 0.1.3		2008-09-02	Add brief comment input. New support K&R style.
"	 0.1.2		2008-08-31	Implement argument indent alignment.
"	 0.1.1		2008-08-29	1st release.
" ----
"
if exists('loaded_dsfcg') || &cp
  finish
endif
let loaded_dsfcg=1

if !has('python')
	echo "Error: Required Vim compiled with +python"
	finish
endif

" 変数が定義されていない場合は定義する
function! s:declareValue(name, value)
	if !exists('g:dsfcg_'. a:name)
		exe 'let g:dsfcg_'.a:name.'=a:value'
	endif
endfunction

" Global options.

""""""" 各ファイルタイプのデフォルト設定
""""""" (ファイルタイプ用の設定値が指定されていない場合、この設定が使用されます)

" 関数コメント先頭部の書式
call s:declareValue('format_header', '/**')
" 関数コメント末尾部の書式
call s:declareValue('format_footer', '**/')
" コメント開始、終了を表すキーワード(リストで記述)
call s:declareValue('comment_words', [ ['/*', '*/'], ['//', '\n'] ])

" 関数コメント内での出力順序
" たとえば、"DRA"と記述した場合は、関数説明,戻り値,引数リスト という順序で
" コメントを生成します。
" コメント新規生成時、"D"行は、g:dsfcg_default_descriptionN(1〜)の設定値を
" 出力します。
" 関数説明行を複数行出力する場合には、"DDRA"のように出力する行数だけ'D'を記述
" し、g:dsfcg_default_description1="...",g:dsfcg_default_description2="..."の
" ように出力行数分だけ、定型文を設定します。
"
" D: Description R: Return value A: Argument
call s:declareValue('element_order', 'DRA')
" 関数を整形出力するか?
" (C/C++以外はちゃんと機能しないので、無効化)
call s:declareValue('is_alignment', 0)
call s:declareValue('is_alignment_cpp', 1)
call s:declareValue('is_alignment_c', 1)

" ユーザ定義キーワード
" defaultmsgはコメント新規作成時のメッセージです。"
call s:declareValue('user_keywords', { 
		\ 'defaultmsg' : "\tEnter description here.",
		\ 'date' : strftime("%Y-%m-%d"),
		\ })

" 関数コメント新規作成時の関数説明記述部の定型文
call s:declareValue('default_description1', "%defaultmsg")

" 引数の入出力タイプを表すワード
call s:declareValue('inout_types', [ "[in]", "[out]", "[in,out]" ])
" 引数の入出力タイプを表すワード
call s:declareValue('permission_tags', [ "@public", "@protected", "@private" ])

" 関数コメント新規作成時の、引数説明行の出力書式
" %inout:入出力タイプ %name:引数名 %description:説明文
call s:declareValue('template_argument', "\t@param%inout %name %description")
" 既存の関数コメントを解析する際の、引数説明行を識別するための正規表現パターン
call s:declareValue('regexp_argument', '.*?[\\@]param(.+?)\s+(.+?)\s+(.*)$')
" g:dsfcg_regexp_argumentでの正規表現マッチングを行った結果、
" どのグループが、どの要素に対応するか(,区切りで指定)
call s:declareValue('escapetext_argument', "%inout,%name,%description")

" 関数コメント新規作成時の、戻り値説明行の出力書式
" %description:説明文
call s:declareValue('template_return', "\t@return %description")

" 既存の関数コメントを解析する際の、戻り値説明行を識別するための正規表現パターン
call s:declareValue('regexp_return', '.*?[\\@]return\s*(.*)$')
" g:dsfcg_regexp_returnでの正規表現マッチングを行った結果、
" どのグループが、どの要素に対応するか(,区切りで指定)
call s:declareValue('escapetext_return', "%description")

""""""" PHP用の設定
call s:declareValue('element_order_php', 'DPRA')
	" D: Description R: Return value A: Argument P:Permission
call s:declareValue('template_permission_php', "\t%permission")

""""""" JavaScript用の設定(てきとう)
call s:declareValue('format_header_javascript', '/**')
call s:declareValue('format_footer_javascript', '*/')
call s:declareValue('template_argument_javascript', "\t@param {%type} %name %description")
call s:declareValue('regexp_argument_javascript', '.*?[\\@]param\s*?\{(\w*)\}\s*(.+?)(\s+(.*))?$')
call s:declareValue('escapetext_argument_javascript', "%type,%name,,%description")
call s:declareValue('template_return_javascript', "\t@return %description")
call s:declareValue('regexp_return_javascript', '.*?[\\@]return\s*(.*)$')


""""""" Perl用の設定
call s:declareValue('format_header_perl','')
call s:declareValue('format_footer_perl','')
call s:declareValue('comment_words_perl', [ ['#', '\n'] ])
call s:declareValue('template_argument_perl', "# @param %name %description")
call s:declareValue('regexp_argument_perl','.*?[\\@]param\s*?(.+?)(\s+(.*))?$')
call s:declareValue('escapetext_argument_perl',"%name,,%description")
call s:declareValue('template_return_perl', "# @return %description")
call s:declareValue('regexp_return_perl','.*?[\\@]return\s*(.*)$')
call s:declareValue('element_order_perl','DRA')
call s:declareValue('default_description1_perl', "## %defaultmsg")

""""""" Ruby用の設定
call s:declareValue('format_header_ruby','')
call s:declareValue('format_footer_ruby','')
call s:declareValue('comment_words_ruby', [ ['#', '\n'] ])
call s:declareValue('template_argument_ruby', "# @param %name %description")
call s:declareValue('regexp_argument_ruby','.*?[\\@]param\s*?(.+?)(\s+(.*))?$')
call s:declareValue('escapetext_argument_ruby',"%name,,%description")
call s:declareValue('template_return_ruby', "# @return %description")
call s:declareValue('regexp_return_ruby','.*?[\\@]return\s*(.*)$')
call s:declareValue('element_order_ruby','DRA')
call s:declareValue('default_description1_ruby', "## %defaultmsg")

""""""" Python用の設定
call s:declareValue('format_header_python','')
call s:declareValue('format_footer_python','')
call s:declareValue('comment_words_python', [ ['#', '\n'] ])
call s:declareValue('template_argument_python', "# @param %name %description")
call s:declareValue('regexp_argument_python','.*?[\\@]param\s*(\w+?)(\s+(.*))?$')
call s:declareValue('escapetext_argument_python',"%name,,%description")
call s:declareValue('template_return_python', "# @return %description")
call s:declareValue('regexp_return_python','.*?[\\@]return\s*(.*)$')
call s:declareValue('element_order_python','DRA')
call s:declareValue('default_description1_python', "## %defaultmsg")

" 'vmap m :<c-u>call DSMakeFunctionComment()<cr>'という
" デフォルトのキーマッピングを有効にするか
call s:declareValue('enable_mapping', 1)

" Functions.

function! s:makeComment()
	" 選択テキストを取得(グローバル変数経由でPythonコード側に渡す)
	let g:dsfcg_select=x:selected_text()
python << END_OF_PYTHON
################################################################################
import vim
import re

typeArg = 1
typeReturn = 2
typeOther = 3

typePublic = 0
typeProtected = 1
typePrivate = 2

typeInput  = 0
typeOutput = 1
typeInOut  = 2

# vim側で定義された変数を取得
# @return 取得した値(see :h python-eval)
# @param name     変数名
# @param defValue デフォルト値
def getvim(name, defValue=''):
	ft = vim.eval('&ft')
	if ft != '' and vim.eval('exists("g:dsfcg_'+name+'_'+ft+'")') != '0':
		return vim.eval('g:dsfcg_' + name+'_'+ft)
	if vim.eval('exists("g:dsfcg_'+name+'")') != '0':
		return vim.eval('g:dsfcg_' + name)
	return defValue
# vim側に変数を設定
# @param values (name,value)のtuple
def setvim(*values):
	for (key, value) in values:
		if isinstance(value, int): value=str(value)
		elif isinstance(value, str): value="'"+value+"'"
		vim.command('let g:dsfcg_' + key + '=' + value)

# 複数のreplaceを実行
# @return 変換後文字列
# @param data         変換対象テキスト
# @param beforeAfters (before,after)のtuple
def replacem(data, *beforeAfters):
	for (before,after) in beforeAfters:
		data = data.replace(before,after)
	return data

# 入れ物クラス
class StyleInfo:
	# lineは引数指定行か?
	# @param line テキスト(1行)
	def isArgumentLine(self, line):
		if hasattr(self, "_regpatArgument") == False:
			regexp = getvim('regexp_argument')
			if regexp == None: return False
			self._regpatArgument = re.compile(regexp)
		return self._regpatArgument.match(line) != None
	# lineは戻り値指定行か?
	def isReturnLine(self, line):
		if hasattr(self, "_regpatReturn") == False:
			regexp = getvim('regexp_return')
			if regexp == None: return False
			self._regpatReturn = re.compile(regexp)
		return self._regpatReturn.match(line) != None
	# 引数行記述の解析
	# 戻り値は_regpatArgumentが指す正規表現で分解した結果のtuple、またはNone
	def parseArgument(self, line):
		if hasattr(self, "_regpatArgument") == False: return None
		try:    return self._regpatArgument.match(line).groups()
		except: return None
	# 戻り値解析行の解析
	# 戻り値は_regpatReturnが指す正規表現で分解した結果のtuple、またはNone
	def parseReturn(self, line):
		if hasattr(self, "_regpatReturn") == False: return None
		try:    return self._regpatReturn.match(line).groups()
		except: return None
	# 新規コメント生成時の要素出力順序を取得(A or R or D)
	def getElementOrder(self):
		return getvim('element_order')
	## 関数説明文のテンプレート文字列を取得
	# @param index 行数インデックス(0〜)
	###
	def getDescriptionTemplate(self,index):
		return getvim('default_description'+str(index))
	# 型名から、引数タイプを取得(in|out|in,out)
	def getInOutType(self, typeName):
		types = getvim('inout_types')
		if 'const' in typeName: return types[typeInput]
		if '*' in typeName or '&' in typeName:
			return types[typeInOut]
		return types[typeInput]

	# 戻り値のテンプレートを取得
	def getOutputReturnTemplate(self): return getvim('template_return')
	def getReturnEscapeText(self,index):
		try:    return getvim('escapetext_return').split(',')[index]
		except: return ''
	def getPermissionTemplate(self): return getvim('template_permission')
	# 既存のコメント情報から、名前が一致する引数に関する情報を取得
	# @param commentInfo コメント情報
	# @param valName     引数名
	def getArgumentInfo(self, commentInfo, valName):
		for item in commentInfo:
			elemType, elemData = item[0], item[1]
			if elemType != typeArg: continue
			n = self.getArgumentGroupIndex('%name')
			if n == -1: continue
			if valName != elemData[n]: continue
			n = self.getArgumentGroupIndex('%description')
			(description,typeName,inout) = ('', '', '')
			
			if n != -1 and elemData[n] != None:
				description = elemData[n]
			n = self.getArgumentGroupIndex('%type')
			if n != -1 and elemData[n] != None:
				typeName = elemData[n]
			n = self.getArgumentGroupIndex('%inout')
			if n != -1 and elemData[n] != None:
				inout = elemData[n]
			elif typeName != '':
				inout = self.getInOutType(typeName)
			return (inout, typeName, description)
		else:
			return '', '', ''
	
	def getOutputArgumentTemplate(self): return getvim('template_argument')
	def getFormatHeader(self): return getvim('format_header')
	def getFormatFooter(self): return getvim('format_footer')
	# 整形出力するか?
	def isAlignment(self):
		try:    return int(getvim('is_alignment')) != 0
		except: return False
	# 関数定義位置のインデント文字列を取得
	def getArgumentGroupIndex(self, text):
		try:    return getvim('escapetext_argument').split(',').index(text)
		except: return -1

# K&Rスタイルの記述か?
# @return True: K&Rスタイル False:そうではない
# @param text 判定対象テキスト
def isK_and_RStyle(text):
	# 閉じ括弧から{まで(あるいは末尾)の間に、;があればK&R記述と見なす
	# (ちょうてぬき)
	rb = text.find(')')
	if rb == -1: return False
	e = text.find('{', rb+1)
	return ';' in text[rb:e]

## 	startCharからendCharまでの間の文字列のコピーを返す。
##  includeがTrueの場合は、startChar,endCharも含める。
# @return 
# @param text      処理対象テキスト
# @param startChar 開始文字列
# @param endChar   終了文字列
# @param include   startChar,endCharを含めるか?
def substrFindChar(text, startChar, endChar,include = False):
	assert(isinstance(startChar, str))
	assert(isinstance(endChar, str))
	(loff,roff) = (0,len(endChar)) if include else (len(startChar), 0)
	lb = text.find(startChar)
	if lb == -1:
		raise Exception()
	rb = text.find(endChar, lb+len(startChar))
	if rb == -1:
		raise Exception()
	return text[lb+loff:rb+roff], (lb,rb)

# 引数部から引数リストを抽出
# @return 引数リストと括弧開始位置のペア
# @param text      処理対象テキスト
# @param startChar 開始文字
# @param endChar   終了文字
# @param sepeartor 区切り文字
def splitArgumentPart(text, startChar='(', endChar=')',separator=','):
	assert(isinstance(separator, str))
	try:
		args = []
		part,(lb,rb) = substrFindChar(text, startChar, endChar)
		for item in (x.strip() for x in part.split(separator)):
			if len(item) > 0: args.append(item)
		return args, (lb,rb)
	except:
		return None,(-1,-1)

## textからseparatorsの各要素を検索し、
## 一致するものがあったら、それ以降を削除します。
# @return 処理後の文字列
# @param text       処理対象テキスト
# @param separators 削除文字群
def stripCharsAfter(text, *separators):
	for separator in separators:
		eq = text.find(separator)
		if eq != -1: text = text[:eq]
	return text

def splitChars(text, *separators):
	for separator in separators:
		eq = text.find(separator)
		if eq != -1: return text[:eq], text[eq:]
	return text, ''

def rsplitChars(text, *separators):
	for separator in separators:
		eq = text.rfind(separator)
		if eq != -1: return text[:eq], text[eq:]
	return text, ''

## C/C++用の解析処理
# @return TypeInfoオブジェクト
# @param selectText 選択テキスト
# 
# @note 今のやり方だと型名と変数名の間の*,&の前後に空白がない場合に
# 整形出力が正しく動作しない。が、自分はそういう書き方をしないので実用上問題ない。
def parseFunctionCpp(selectText):
	obj = TypeInfo(selectText)
	obj.k_and_r = isK_and_RStyle(selectText)
	
	# 改行を除去
	selectText = replacem(selectText, ('\n', ' '), ('\t', ' '))
	args, (lb,rb) = splitArgumentPart(selectText)
	if args == None: return None
	sep1 = selectText.rfind(' ', 0, lb)
	if sep1 != -1:
		for item in selectText[0:sep1].split():
			word = item.strip()
			if word == '': continue
			obj.returns.append(word)
	
	obj.funcName = selectText[sep1+1:lb]
	# デフォルト値指定(=)前後の空白と、配列前の空白の除去
	m_eq = re.compile(r'\s*=\s*')
	m_ar = re.compile(r'\s*\[')
	for item in args:
		item = m_eq.sub('=', item)
		item = m_ar.sub('[', item)
		valType, valName = rsplitChars(item, ' ', '\t', '*', '&')
		if valName ==  '':
			# トークンが一つしかない場合、
			# ファイルタイプがC++の場合は型名であるものと見なし、
			# Cの場合は変数名であるものとみなす
			# (Cでは変数名省略が許可されず、C++では型名省略が許可されないため)
			if vim.eval('&ft') == 'c':
				valName = valType
				valType = ''
		valName = valName.lstrip(' \t*&')
		# デフォルト値、配列表記は削除
		valName, valNamePrefix = splitChars(valName,'=','[')
		obj.arguments.append([valType, valName, valNamePrefix])
	def findargument(name):
		for argpair in obj.arguments:
			if name != argpair[1]: continue
			return argpair
		else: None
	# K&Rスタイルだった場合の特殊な処理(とっても場当たりなので汚い)
	if obj.k_and_r:
		# ')'〜'{'までの文字列を抜き出し
		e = selectText.find('{', rb+1)
		ms = re.compile(r'\s*,\s*')
		mp = re.compile(r'\s*\*')
		# 「;」を区切り文字として分割
		for arg in selectText[rb+1:e].split(';'):
			# pointer(*)の直前にある空白と、「,」前後の空白を除去
			arg = arg.strip()
			arg = ms.sub(',', arg)
			arg = mp.sub('*', arg)
			# ' 'or'\t'or'*'を境目として、型名と変数名に分割
			sep = arg.rfind(' ')
			if sep==-1: sep=arg.rfind('\t')
			if sep!=-1:
				valType = arg[:sep]
				names = arg[sep+1:]
			elif '*' in arg:
				sep = arg.rfind('*')
				valType = arg[:sep+1]
				names = arg[sep+1:]
			else:
				valType = 'int'
				names = arg
			# 前工程で構築した引数リストと、変数名でマッチングをとり
			# 一致する引数の型名を設定する。
			for valName in names.split(','):
				try: findargument(valName)[0] = valType
				except: pass
	# 
	obj.parseOK = True
	return obj

# PHP用の解析処理
# @return 型情報オブジェクト
# @param selectText 選択テキスト
def parseFunctionPHP(selectText):
	obj = TypeInfo(selectText)
	# 改行を除去
	selectText = replacem(selectText,('\t', ' '), ('\n', ' '))
	args, (lb, rb) = splitArgumentPart(selectText)
	if args == None: return None
	sep1 = selectText.rfind('&', 0, lb)
	if sep1 == -1: sep1 = selectText.rfind(' ', 0, lb)
	obj.accessable = typePublic
	obj.returns.append('function') # dummy
	if sep1 != -1:
		for item in selectText[0:sep1].split():
			word = item.strip()
			if word == '' or word == '&' or word == 'function': continue
			if word == 'public': obj.accessable = typePublic
			elif word == 'protected': obj.accessable = typeProtected
			elif word  == 'private': obj.accessable = typePrivate
	
	obj.funcName = selectText[sep1+1:lb]
	types = lambda x: '&' if '&' in x else ''
	for x in args:
		valName, valNamePrefix = splitChars(x, '=')
		valName = valName.lstrip('&$') # 変数名先頭の&$は除去
		obj.arguments.append([types(x), valName, valNamePrefix])
	obj.parseOK = True
	return obj

# Python用の解析処理
# @return 型情報オブジェクト
# @param selectText 選択テキスト
def parseFunctionPython(selectText):
	obj = TypeInfo(selectText)
	# 改行を除去
	selectText = replacem(selectText,('\t', ' '), ('\n', ' '))
	args, (lb, rb) = splitArgumentPart(selectText)
	if args == None: return None
	sep1 = selectText.rfind('&', 0, lb)
	if sep1 == -1: sep1 = selectText.rfind(' ', 0, lb)
	obj.returns.append('function') # dummy
	obj.funcName = selectText[sep1+1:lb]
	obj.accessable = typePrivate if obj.funcName.startswith('__') else \
	                 typePublic
	for x in args:
		valName, valNamePrefix = splitChars(x, '=')
		valName = valName.lstrip('*')
		obj.arguments.append(['', valName, valNamePrefix])

	# 先頭要素がselfの場合、除外
	if len(obj.arguments) > 0 and obj.arguments[0][1] == 'self':
		obj.arguments.pop(0)
	obj.parseOK = True
	return obj

# JavaScript用の解析処理
# @return 型情報オブジェクト
# @param selectText 選択テキスト
def parseFunctionJS(selectText):
	obj = TypeInfo(selectText)
	# 改行を除去
	selectText = replacem(selectText, ('\t', ' '),('\n', ' '))
	args, (lb, rb) = splitArgumentPart(selectText)
	if args == None: return None
	sep1 = selectText.rfind(' ', 0, lb)
	obj.returns.append('function') # dummy
	obj.funcName = selectText[sep1+1:lb]
	for x in args:
		valName, valNamePrefix = splitChars(x, '=')
		obj.arguments.append(['', valName, valNamePrefix])
	obj.parseOK = True
	return obj

# Perl用の解析処理
# @return 型情報オブジェクト
# @param selectText 選択テキスト
def parseFunctionPerl(selectText):
	obj = TypeInfo(selectText)
	
	patName = re.compile(r'\s*sub\s+(\w+)')
	pat1 = re.compile(r'(?=.+@_).*\((.+?)\)')
	pat2 = re.compile(r'(?=.+=\s*shift)\s*(my)?\s*(.+?)\s*?=')
	
	args = ''
	for line in selectText.replace(';','\n').splitlines():
		mf = patName.match(line)
		if mf: obj.funcName = mf.group(1)
		m1 = pat1.match(line)
		if m1: args += m1.group(1)
		m2 = pat2.match(line)
		if m2: args += m2.group(2)
	
	for arg in args.replace('$',',').split(','):
		arg = arg.strip()
		if len(arg) == 0: continue
		obj.arguments.append(['', arg, ''])
	# 先頭要素がselfの場合、除外
	if len(obj.arguments) > 0 and obj.arguments[0][1] =='self':
		obj.arguments.pop(0)
	
	obj.parseOK = len(obj.funcName) > 0
	return obj

# 型に応じて処理を振り分ける
# @return 型情報オブジェクト
# @param selectText 選択テキスト
def parseFunction(selectText):
	ft = vim.eval('&ft')
	if ft == 'c' or ft == 'cpp': return parseFunctionCpp(selectText)
	elif ft == 'php':            return parseFunctionPHP(selectText)
	elif ft == 'javascript':     return parseFunctionJS(selectText)
	elif ft == 'perl':           return parseFunctionPerl(selectText)
	elif ft == 'python':         return parseFunctionPython(selectText)
	elif ft == 'ruby':           return parseFunctionPHP(selectText) # 気休め
	else:
		# なんだかわからない時はとりあえずC/C++として処理
		# (設定できた方がいいかもしれんけど・・)
		return parseFunctionCpp(selectText)

# 型情報クラス
class TypeInfo:
	originalText = ''
	parseOK = False
	funcName = ''
	returns = []
	arguments = []
	k_and_r = False
	
	def __init__(self, text):
		self.originalText = text
	
	## 	型情報生成処理は成功したか?
	# @return True:成功 False:失敗
	def isParseOK(self):
		return self.parseOK
	
	## 	戻り値に関する情報はあるか?
	# @return True:ある False:ない、または出力しない
	def hasReturnValue(self):
		if hasattr(self, "returns") == False: return False
		# void型だったら出力しない
		return len(self.returns) >= 1 and self.returns[0] != 'void'
	# インデントを取得
	# @return インデント文字列
	def getIndent(self):
		if hasattr(self, "originalText") == False: return ''
		if hasattr(self, "indentText") == True: return self.indentText
		
		self.indentText = ''
		for i in self.originalText:
			# if i == '\n': continue
			if i not in " \t": break
			self.indentText += i
		return self.indentText
	## 	引数リストの取得
	# @return 引数リスト
	def getArguments(self): return getattr(self, "arguments", [])
	## 	戻り値情報を取得
	# @return 戻り値情報
	def getReturns(self): return getattr(self, "returns", [])
	## 	関数名を取得
	# @return 関数名を表す文字列
	def getFunctionName(self): return getattr(self, "funcName", '')
	## 	引数リストのうち、最長の引数名の長さを取得
	# @return 文字列長(int)
	def getLongestNameLen(self):
		try:
			return max([len(i[1]) for i in self.getArguments()])
		except:
			return 0
	## 	引数リストのうち、最長の入出力タイプ([in],[out],[in,out])の長さを取得
	# @return 入出力タイプのうち、最長の長さ
	# @param styles 出力形式情報
	def getLongestTypeLen(self, styles):
		try:
			return max([ len(styles.getInOutType(i[0])) for i in self.getArguments()])
		except:
			return 0
	## 	整形出力する際の")"より後ろの部分のテキストを取得
	# @note 整形出力はC/C++専用
	# @return ")"より後ろの部分のテキスト
	def getTail(self):
		rb = self.originalText.find(')')
		return self.originalText[rb+1:]

# 既存のコメントに関する情報
class CommentInfo:
	# コメント解析処理によって得られた情報
	lines = []
	# 既存のコメントが書式に沿ったものでなかった場合のコメント文字列
	briefs = []
	# dsfcgによって生成されたコメントは存在するか?
	# @return コメントの有無
	###
	def hasGeneratedComments(self): return len(self.lines) > 0
	def append(self, item): self.lines.append(item)
	def appendBrief(self, line): self.briefs.append(line)

# コメントがbrief記述のみであるものとして解析
# @return コメント情報
# @param selectText 処理対象テキスト
# @param styles     書式情報
def parseBrief(selectText, styles):
	lines = selectText.splitlines(True)
	comments = CommentInfo()
	for line in lines:
		line,isComment = stripCommentChar(line)
		if isComment == False: continue
		if len(line) == 0: 
			comments.appendBrief('')
			continue
		if line[0] in ('!','/', '*'):
			line = line.lstrip(line[0])
		comments.appendBrief(line)
	return comments

## 	コメント文字列部分のみを抽出
# @return コメント文字列からなる行のリスト
# @param text テキスト
def extractCommentPart(text):
	output = []
	commentTypes = getCommentWords()
	while True:
		for item in commentTypes:
			try:
				line,(lb,rb) = substrFindChar(text, item[0], item[1], True)
				output.append(line.rstrip('\n'))
				text = text.replace(text[lb:rb],'')
				break
			except: pass
		else:
			break
	return output

# コメント部を解析し、コメント情報を生成
# Enter description here.
# @return コメント情報
# @param selectText vim側で選択されたテキスト
# @param styles     出力形式に関する設定情報
###
def parseComments(selectText, styles):
	def stripLine(lines, settingName):
		data = getvim(settingName).strip()
		if len(data) == 0: return lines
		i = 0
		for line in lines:
			if line.strip() == data: return lines[i+1:]
			i+=1
		else: return []
	
	# ヘッダ・フッタの書式が定義されていたら、その間のコメントのみを
	# 解析対象とする。書式が定義されていなかったら、
	# 選択文字列からコメント部を抽出し、解析対象とする
	if getvim('format_header')+getvim('format_footer') != '':
		lines = selectText.splitlines()
		# コメントヘッダ部と同一の書式の行があるかを検索し、除去
		lines = stripLine(lines, 'format_header')
		# コメントフッタ部と同一の書式があるかを検索し、除去
		lines.reverse()
		lines = stripLine(lines, 'format_footer')
		lines.reverse()
	else:
		lines = extractCommentPart(selectText)
	
	# 関数コメント内部を解析し、情報をためておく
	isBriefOnly = True
	comments = CommentInfo()
	for line in lines:
		# 引数行か?
		if styles.isArgumentLine(line):
			comments.append((typeArg, styles.parseArgument(line)))
			isBriefOnly = False
		# 戻り値行か?
		elif styles.isReturnLine(line):
			comments.append((typeReturn, styles.parseReturn(line)))
			isBriefOnly = False # その他の記述
		else:
			comments.append((typeOther, line))
	# もし既存のコメントがなかったら、briaf記述だけのコメントとしての
	# 解析を試みる
	if isBriefOnly: return parseBrief(selectText, styles)
	else:			return comments

def escapeChar(text):
	return replacem(text, 
		(r'\n', '\n'), (r'\r', '\r'),(r'\t', '\t'))
def escapeChars(comment):
	return [ escapeChar(x) for x in comment ]

def getCommentWords():
	commentTypes = []
	try:
		comments = getvim('comment_words')
		for comment in comments:
			if isinstance(comment, list) == False: continue
			if len(comment) < 2: continue
			commentTypes.append(escapeChars(comment))
	except: pass
	return commentTypes

# コメント行か?
def stripCommentChar(line):
	# 行単位コメントの先頭のインデントを除去
	commentTypes = getCommentWords()
	for item in commentTypes:
		s = line.find(item[0])
		if s == -1: continue
		line = line.lstrip(' \t')
		break
	
	while True:
		striped = False
		for item in commentTypes:
			try:
				line,(lb,rb) = substrFindChar(line, item[0], item[1])
				striped = True
			except: pass
		else:
			return line, striped

# コメント除去
def stripComment(selectText):
	commentTypes = getCommentWords()
	lines = []
	for line in selectText.splitlines():
		for item in commentTypes:
			n = line.find(item[0])
			if n == -1: continue
			lines.append(line.lstrip('\t '))
			break
		else: lines.append(line)
	
	isAddCR = selectText[-1] == '\n'
	
	selectText = "\n".join(lines)
	# もし末尾が改行の場合、splitlinesで最後の改行は失われるので、補完する
	if isAddCR: selectText = selectText + '\n'
	
	while True:
		for item in commentTypes:
			n = selectText.find(item[0])
			if n == -1: continue
			
			endPos = selectText.find(item[1], n+len(item[0]))
			if endPos == -1: continue
			
			selectText = selectText.replace(selectText[n:endPos+len(item[1])], '')
			break
		else:
			# 最初の改行は不要
			selectText = selectText.lstrip('\n')
			return selectText

def getArgumentNames(commentInfo, styles):
	nameIndex = styles.getArgumentGroupIndex('%name')
	if nameIndex == -1: return [""]
	names = []
	for item in commentInfo:
		elemType, elemData = item[0], item[1]
		if elemType != typeArg: continue
		names.append(elemData[nameIndex])
	else: return [""]
	return names
def getInOutTypes(commentInfo, styles):
	inoutIndex = styles.getArgumentGroupIndex('%inout')
	if inoutIndex == -1: return [""]
	inouts = [""]
	for item in commentInfo:
		elemType, elemData = item[0], item[1]
		if elemType != typeArg: continue
		inouts.append(elemData[inoutIndex])
	else: return [""]
	return inouts

# ユーザキーワードをエスケープする
def escapeUserKeywords(text, commentInfo):
	keywords = getvim('user_keywords')
	if isinstance(keywords, dict) == False: return text
	
	for keyword in keywords:
		if text.find('%'+keyword) == -1: continue
		data = keywords[keyword]
		if keyword == 'defaultmsg' and len(commentInfo.briefs)>0:
			i = 0
			line = text
			text = ''
			for brief in commentInfo.briefs:
				if i>0: text += '\n'
				text += line.replace('%'+keyword, brief)
				i += 1
		else:
			text = text.replace('%'+keyword, data)
	return text

def getPermissionText(typeInfo):
	texts = getvim('permission_tags')
	if hasattr(typeInfo,'accessable') == False:
		return texts[typePublic]
	a = typeInfo.accessable
	if a == typePublic: return texts[typePublic]
	elif a == typeProtected: return texts[typeProtected]
	else: return texts[typePrivate]

def makeReturnPart(typeInfo, styles, default = None):
	if typeInfo.hasReturnValue() == False: return default
	funcName = getattr(typeInfo, "funcName", '')
	work = styles.getOutputReturnTemplate()
	return replacem(work,
		('%description', ''), ('%function', funcName))
	
# 新規出力
def makeNewComment(typeInfo, styles, commentInfo):
	# 最も名前が長い引数名にあわせてインデントするために最長の名前を調べる
	longestNameLen = typeInfo.getLongestNameLen()
	longestTypeLen = typeInfo.getLongestTypeLen(styles)

	funcName = getattr(typeInfo, "funcName", '')
	#
	output = ''
	isOutA, isOutR = False, False
	descIndex = 1
	for item in styles.getElementOrder():
		if item == 'D':
			msg = styles.getDescriptionTemplate(descIndex)
			msg = escapeUserKeywords(msg, commentInfo)
			msg = msg.replace('%function', funcName)
			output += escapeChar(msg) + '\n'
			descIndex+=1
		elif item == 'A' and isOutA == False:
			isOutA = True
			arguments = typeInfo.getArguments()
			for item in arguments:
				outputArg = styles.getOutputArgumentTemplate()
				valType, valName = item[0], item[1]
				
				# void,または...は対象外
				if valType == "void" or valType == "...": continue
				
				# インデントをあわせる
				if longestNameLen > 0:
					valName = valName.ljust(longestNameLen)
				ioType = styles.getInOutType(valType)
				if longestTypeLen > 0:
					ioType = ioType.ljust(longestTypeLen)
				
				outputArg = replacem(outputArg,
					('%type', valType), ('%name', valName),
					('%inout', ioType), ('%description', ''),
					('%function', funcName))
				output += outputArg + '\n'
		elif item == 'R' and isOutR == False:
			isOutR = True
			work = makeReturnPart(typeInfo, styles)
			if work: output += work + '\n'
		elif item == 'P' and typeInfo and hasattr(typeInfo, 'accessable'):
			isOutP = True
			work = styles.getPermissionTemplate()
			work = replacem(work,
				('%permission', getPermissionText(typeInfo)), ('%function', funcName))
			output += work + '\n'
	return output

# マージ出力
# @return コメント部のテキスト
# @param typeInfo    型情報
# @param styles      書式情報
# @param commentInfo 既存のコメント情報
def makeMergeComment(typeInfo, styles, commentInfo):
	lines = []
	argIndex = 0
	# 既存のコメントから収集した情報のうち、
	# 関数説明部と戻り値部のみを出力
	isOutR = False
	comments = commentInfo.lines
	for item in comments:
		elemType, elemData = item[0], item[1]
		if elemType == typeOther:
			lines.append(elemData)
		elif elemType == typeArg:
			lines.append(argIndex)
			argIndex+=1
		elif elemType == typeReturn:
			# 戻り値がvoidだったりしたら、出力しない
			if typeInfo == None: continue
			if typeInfo.hasReturnValue() == False: continue
			work = styles.getOutputReturnTemplate()
			for i in xrange(0, len(elemData)):
				escapeText = styles.getReturnEscapeText(i)
				if escapeText == '': continue
				work = work.replace(escapeText, elemData[i])
			lines.append(work)
			isOutR = True
	# 設定上、戻り値と引数のどちらが先に出力されるか?
	def isReturnBeforeArg():
		for item in styles.getElementOrder():
			if item == 'A': return False
			elif item == 'R': return True
		else: return True
	# 既存の戻り値行が存在しない場合は、新規に挿入を行う。
	work  = makeReturnPart(typeInfo, styles)
	if isOutR == False and work:
		try:
			# 引数より戻り値を先に出力する場合は引数行の直前、そうでない場合は引数行の直後にする
			insertPos = lines.index(0) if isReturnBeforeArg() else \
						lines.index(argIndex-1)+1
			lines.insert(insertPos, work)
		except: lines.append(work)
	
	# 最も名前が長い引数名にあわせてインデントするために最長の名前を調べる
	longestNameLen = max(
		[typeInfo.getLongestNameLen(),
		 max([ len(x) for x in getArgumentNames(comments, styles)])]
	)
	longestTypeLen = max(
		[typeInfo.getLongestTypeLen(styles),
		 max([ len(x) for x in getInOutTypes(comments, styles)])]
	)
	# 関数記述部から生成した引数情報を順に出力
	lastindex = None
	arguments = typeInfo.getArguments()
	for i in xrange(0, len(arguments)):
		item = arguments[i]
		valType, valName = item[0], item[1]
		
		# void,または...は対象外
		if valType in ("void", "..."): continue
		
		# 既存のコメント情報から、名前が一致する変数に関する情報を取得
		(ioType, typeName, desc) = styles.getArgumentInfo(comments, valName)
		if ioType == '': ioType = styles.getInOutType(valType)
		if typeName != '': valType = typeName
		
		if longestNameLen > 0: valName = valName.ljust(longestNameLen)
		if longestTypeLen > 0: ioType = ioType.ljust(longestTypeLen)
		
		outputArg = styles.getOutputArgumentTemplate()
		outputArg = replacem(outputArg,
			('%type', valType), ('%name', valName),
			('%inout', ioType), ('%description', desc))
		try:
			n = lines.index(i)
			lines[n] = outputArg
			lastindex = n
		except:
			if lastindex == None:
				lines.append(outputArg)
			else:
				lines.insert(lastindex+1, outputArg)
				lastindex+=1
	
	# lines内の要素がinteger型のままになっているものを除去
	while True:
		for item in lines:
			if isinstance(item, int):
				lines.remove(item)
				break
		else: break
	
	return "\n".join(lines) + "\n"

##  関数部の出力
# @return 
# @param typeInfo 型情報
# @param styles   出力形式情報
def makeFunctionPart(typeInfo, styles):
	if isAlignment(typeInfo, styles) == False:
		return typeInfo.originalText.lstrip('\n')
	output = ''
	# 戻り値の出力
	for item in typeInfo.getReturns():
		output += item + " "
	# 関数名の出力
	funcName = typeInfo.getFunctionName()
	output += typeInfo.funcName + '('
	arguments = typeInfo.getArguments()
	if len(arguments) > 0:
		output += '\n'
	
	last = len(arguments) - 1
	# 引数の出力
	for i, item in enumerate(arguments):
		argType, argName, argPrefix = item[0], item[1], item[2]
		output += '\t' + argType + ' ' + argName + argPrefix
		if i != last: output += ',\n'
		else:         output += '\n'
	output += ')'
	# 残りの部分をくっつける
	tails = typeInfo.getTail().splitlines(True)
	# 閉じ括弧の後が{だった場合、間に改行を入れる
	if len(tails) > 0 and '{' in tails[0]:
		tails[0] = tails[0].replace('{', '\n{')
	
	output += "".join(tails)
	return output

## 整形出力するかどうかを判定します
# @return True:する False:しない
# @param typeInfo 型情報
# @param styles   書式情報
def isAlignment(typeInfo, styles):
	# パースに失敗したら、整形出力はしない。オリジナルのをそのまま出力
	return typeInfo.isParseOK()  and styles.isAlignment()  and \
	   typeInfo.k_and_r == False

## textの各行に対してインデントを設定します。
# @return インデント挿入後のテキスト
# @param text     処理対象テキスト
# @param typeInfo 関数部解析結果データ
def alignmentIndent(text, typeInfo):
	assert(typeInfo)
	output = ''
	for line in text.splitlines(True):
		output += typeInfo.getIndent() + line
	return output

##  コメント部の生成
# @return 生成されたコメント部のテキスト文字列
# @param typeInfo    型情報
# @param styles      出力形式情報
# @param commentInfo コメント情報
def makeCommentPart(typeInfo, styles, commentInfo):
	commentPart = ''
	header = styles.getFormatHeader()
	if len(header) > 0: commentPart += header + '\n'
	if commentInfo.hasGeneratedComments() == False:
		commentPart += makeNewComment(typeInfo, styles, commentInfo)
	else:
		commentPart += makeMergeComment(typeInfo, styles, commentInfo)
	footer = styles.getFormatFooter()
	if len(footer) > 0: commentPart += footer + '\n'
	return commentPart

## 型情報とコメント情報を元に関数定義記述を生成
# @param typeInfo    関数部解析結果データ
# @param styles      スタイル情報
# @param commentInfo コメント情報
def makeFuncDescription(typeInfo, styles, commentInfo):
	if typeInfo == None: return None
	if commentInfo == None: return None
	
	commentPart = makeCommentPart(typeInfo, styles, commentInfo)
	funcPart = makeFunctionPart(typeInfo, styles)
	
	# 整形出力しない場合、関数部は元のまま出力するので
	# コメント部に対してのみインデントを行います。
	if isAlignment(typeInfo, styles):
		return alignmentIndent(commentPart+funcPart, typeInfo)
	else:
		return alignmentIndent(commentPart, typeInfo) + funcPart

###################################
###################################
setvim(('result_ok', 0), ('result', ''))

styles = StyleInfo()

# vim側で選択されたテキストを取得
text = getvim('select')

# コメント部を解析し、既存のコメント情報を生成する
commentInfo = parseComments(text, styles)
# 関数定義部を解析し、型情報を生成する
typeInfo = parseFunction(stripComment(text))

# コメント情報と型情報を元に、関数コメントを含めた関数定義記述を生成
output = makeFuncDescription(typeInfo, styles, commentInfo)

# 結果をvim側に返す
if output != None:
	setvim(('result_ok', 1),('result', output))
################################################################################

END_OF_PYTHON
	unlet g:dsfcg_select
" Pythonコード側で生成された結果を受け取り、返す
	let result = g:dsfcg_result
	let ok = g:dsfcg_result_ok
	unlet g:dsfcg_result
	unlet g:dsfcg_result_ok
	return [result, ok]
endfunction

" 関数コメントの生成
function! DSMakeFunctionComment()
	" 一時的に使用するaレジスタの退避
	let a_value = getreg('a', 1)
	let a_mode  = getregtype('a')
	" コメントを生成し、貼り付け
	let [@a,ok] = s:makeComment()
	if ok != 0
		execute "normal! gv\"_d0\"aP"
	endif
	" aレジスタの復元
	call setreg('a', a_value, a_mode)
endfunction

" get select text.
" http://vim.g.hatena.ne.jp/keyword/%e9%81%b8%e6%8a%9e%e3%81%95%e3%82%8c%e3%81%9f%e3%83%86%e3%82%ad%e3%82%b9%e3%83%88%e3%81%ae%e5%8f%96%e5%be%97
function! x:selected_text(...)
  let [visual_p, pos] = [mode() =~# "[vV\<C-v>]", getpos('.')]
  let [r_, r_t] = [@@, getregtype('"')]
  let [r0, r0t] = [@0, getregtype('0')]
  if &cb == "unnamed"
	  let [rast, rastt] = [@*, getregtype('*')]
  endif


  if visual_p
    execute "normal! \<Esc>"
  endif
  silent normal! gvy
  let [_, _t] = [@@, getregtype('"')]

  call setreg('"', r_, r_t)
  call setreg('0', r0, r0t)
  " set cb=unnamedな環境だと、yank,pasteに"*レジスタが使われるのでこれも復元できるように
  " (他の特定のレジスタを使うように設定されていた場合については放置)
  if &cb == "unnamed"
	  call setreg('*', rast, rastt)
  endif
  if visual_p
    normal! gv
  else
    call setpos('.', pos)
  endif
  return a:0 && a:1 ? [_, _t] : _
endfunction

if !exists('g:dsfcg_enable_mapping') || g:dsfcg_enable_mapping != 0
	vnoremap m :<c-u>call DSMakeFunctionComment()<cr>
endif

