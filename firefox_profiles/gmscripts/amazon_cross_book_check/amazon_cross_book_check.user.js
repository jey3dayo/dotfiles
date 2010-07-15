// ==UserScript==
// @name           Amazon Cross Book Check
// @namespace      http://d.hatena.ne.jp/adda/
// @include        http://www.amazon.co.jp/*
// @include        http://amazon.co.jp/*
// ==/UserScript==
//
// version: 2009.01.16

var DEFAULT_AUTO_START = false;
var INTERVAL = 1000;
var TIMEOUT = 15000;

var SITEINFO = [
	{
		label: 'BOOKOFF Online',
		url: 'http://www.bookoffonline.co.jp/display/L001,st=u,q=',
		regexp: /\u4E2D\u53E4\u8CA9\u58F2\u4FA1\u683C<\/th><td class="tab01">\uFFE5([\d,]+)/,
		isbn13: true,
		disabled: false
	},
	{
		label: 'livedoor BOOKS',
		url: 'http://books.livedoor.com/search/?v=2&word=',
		afterISBN: '&type=isbn',
		regexp: /\u4E2D\u53E4\u4FA1\u683C\uFF1A<span class="price">([\d,]+)/,
		disabled: false
	},
	{
		label: '\u53E4\u672C\u5E02\u5834', //古本市場
		url: 'http://www.search.ubook.co.jp/search/search.php?category1=all&shousai_r=1&isbn=',
		regexp: /span class="biggerlink">([\d,]+)[\s\S]*?<input type="checkbox"/,
		disabled: false
	},
	{
		label: 'eBOOKOFF',
		url: 'http://www.ebookoff.co.jp/cmdtysearch?Ctgry=1002&hdnSearchFlg=1&chkOld=1&txtISBNCode=',
		regexp: /<span class="uam texttype01">([\d,]+)/,
		isbn13: true,
		disabled: false
	},
	/* template
	{
		label: '',
		url: '',
		afterISBN: '',
		regexp: //,
		isbn13: ,
		bothISBN: ,
		disabled: ,
	},
	*/
]

var PAGEINFO = [
	{	
		type: 'wishlist',
		urlExp: 'wishlist',
		insertAfter: '//tbody[@name]/descendant::tbody[1]/tr[last()]',
		asinLink: '//td[@class="small"]/strong/a',
		autoStart: true
	},
	{
		type: 'search',
		urlExp: 'keywords=',
		insertAfter: '//div[@class="productData"]/*[last()]',
		asinLink: '//div[@class="productData"]/div[1]/a',
		autoStart: true
	},
	{
		type: 'bestsell',
		urlExp: '/bestsellers/',
		insertAfter: '//table[@class="priceBox"]/tbody/tr[last()]',
		asinLink: '//strong[@class="sans"]/a',
		autoStart: true
	},
	{
		type: 'recommend',
		urlExp: '/yourstore/',
		insertAfter: '//table[@class="priceBox"]/tbody/tr[last()]',
		asinLink: '//td[@width="100%"]/a',
		autoStart: true
	},
	{
		type: 'listmania',
		urlExp: '/lm/',
		insertAfter: '//td[@class="listItem"]/table/*[last()]',
		asinLink: '//td[@class="listItem"]/a',
		autoStart: true
	},
	{
		type: 'history',
		urlExp: '/history/',
		insertAfter: '//table[@class="priceBox"]/tbody/tr[last()]',
		asinLink: '//td[@width="100%"]/a',
		autoStart: true
    }
]

var STYLE = <><![CDATA[
	table.ACBC {
		font-size: 13px;
		margin-top: 3px;
	}
	table.ACBC td.label {
		padding-right:1em;
	}
	table.ACBC span.loading {
		color: #39c;
	}
	table.ACBC a.notfound {
		color: #666 !important;
		text-decoration: none;
		font-family: arial,verdana,helvetica,sans-serif;
	}
	table.ACBC a.found {
		color: #900 !important;
		font-weight: bold;
		text-decoration: underline !important;
	}
]]></>

function Checker(pageType) {
	this.pageType = pageType;
	this.index = 0;
}

Checker.prototype.run = function() {
	GM_addStyle(STYLE);
	SITEINFO = SITEINFO.filter(function(i){ return !(i.disabled) });
	if (this.pageType == 'detail') {
        var t = document.getElementById('handleBuy');
        if (!t) return;
        var target = t.lastChild.previousSibling.lastChild.lastChild;
        var isbn = getISBN(document.location.href);
		var item = new Item(isbn, target);
		item.load();
	} else {
	    this.setIteration(this.pageType);
	}
}

Checker.prototype.setIteration = function(pinfo) {
	if (DEFAULT_AUTO_START && pinfo.autoStart) {
		this.iterate(pinfo);
	} else {
		var self = this;
		GM_registerMenuCommand('ACBC - start', function() {
			self.iterate(pinfo);
		});
	}
}

Checker.prototype.iterate = function(pinfo) {
	var self = this;
	var f = function() {
		var targets = getElementsByXPath(pinfo.insertAfter, document);
		var links = getElementsByXPath(pinfo.asinLink, document);
		var i = self.index, len = targets.length;
		(function g(){
			if (!(i < len)) return;
			var isbn = getISBN(links[i].href);
			if (isbn) {
				var item = new Item(isbn, targets[i]);
				item.load();
			};
			i++;
			setTimeout(g, INTERVAL);
		})();
		self.index = len;
	};
	f();
	if (window.AutoPagerize) window.AutoPagerize.addFilter(f);
}

function Item(isbn, target) {
	this.isbn = isbn;
	this.target = target;
	this.timers = [];
}

Item.prototype.load = function() {
	this.insertTable();
	var f = function(n) {
		var info = SITEINFO[n];
		var url = self.buildURL(info);
		self.timers[n] = setTimeout(function(){ 
			self.insertContent(n, "<a href='" + url + "' target='_blank' class='notfound'>Timeout</a>") 
		}, TIMEOUT);
		GM_xmlhttpRequest({
	        method: 'get',
	        url: url,
	        onload: function(res) {
	        	clearTimeout(self.timers[n]);
	            self.insertContent(n, self.getContent(res, info, url));
	        }
		})
	}
	for (var i = 0, len = SITEINFO.length; i < len; i++) {
		var self = this;
		f(i);
	}
}

Item.prototype.insertTable = function() {
	var tr = document.createElement("tr");
	var td = document.createElement("td");
	var inner = "<table class='ACBC'><tbody>";
	for (var i = 0, len = SITEINFO.length; i < len; i++) {
		inner += ("<tr><td class='label'>" + SITEINFO[i].label + "</td><td><span class='loading'>loading...</span></td></tr>");
	}
	td.innerHTML = (inner += "</tbody></table>");
	tr.appendChild(td);
	this.target.parentNode.insertBefore(tr, this.target.nextSibling);
	this.table = tr.firstChild.firstChild;
}

Item.prototype.buildURL = function(info) {
	var url = info.url;
	if (info.isbn13) {
		url += conv2ISBN13(this.isbn);
	} else if (info.bothISBN) {
		url += (conv2ISBN13(this.isbn) + "|" + this.isbn);
	} else {
		url += this.isbn;
	}
	if (info.afterISBN) url += info.afterISBN;
	return url;
}

Item.prototype.getContent = function(res, info, url) {
	if (res.responseText.match(info.regexp)) {
		var price = (RegExp.$1.length > 0)? "\uFFE5 "+ RegExp.$1 : "Found";
		return "<a href='" + url + "' target='_blank' class='found'>" + price + "</a>";
    } else {
    	return "<a href='" + url + "' target='_blank' class='notfound'>NotFound</a>";
    }
}

Item.prototype.insertContent = function(n, str) {
	this.table.firstChild.childNodes[n].childNodes[1].innerHTML = str;
}

function getPageType(url) {
	for (var i = 0, len = PAGEINFO.length; i < len; i++) {
    	var pinfo = PAGEINFO[i];
    	if (url.indexOf(pinfo.urlExp) != -1) return pinfo;
    }
    if (getISBN(url)) return 'detail';
    return false;
}

function getISBN(str) {
	if (str.match(/[\/\=]([\d]{9}[\dX])[^&]?/)) return RegExp.$1;
}

//----main----

var pageType = getPageType(document.location.href);
if (pageType) {
	var checker = new Checker(pageType);
	checker.run();
}

//----utility----

function conv2ISBN13(str) {
    var result = "978" + str.substr(0,9);
    var checkDigit = 38;
    for (var i = 0; i < 9; i++) {
        var c = str.charAt(i);
        checkDigit += ( i % 2 == 0 )? c * 3 : c * 1;
    }
    checkDigit = (10 - (checkDigit % 10)) % 10;
    result += checkDigit;
    return result;
}

function getElementsByXPath(xpath, doc) {
    var nodes = doc.evaluate(xpath, doc, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
	var data = [];
	for (var i = 0, len = nodes.snapshotLength; i < len; i++) {
  		data.push(nodes.snapshotItem(i));
	}
	return data;
}
function log(str) {
	unsafeWindow.console.log(str);
}