// ==UserScript==
// @name        livedoor Reader meets Hatena Bookmark
// @namespace	http://tokyoenvious.xrea.jp/
// @include     http://reader.livedoor.com/reader/*
// @version     1.0
// ==/UserScript==

// {{{
Function.prototype.bind = function(object) {
	var __method = this;
	return function() {
		return __method.apply(object, arguments);
	};
};

function XMLRPC() {
	this.calls  = [];
	this.called = 0;
	this.chunk  = 0;
}
XMLRPC.prototype = {
	proxy: function(endPoint)
	{
		this.endPoint = endPoint;
		return this;
	},
	call: function(method, params)
	{
		this.parts = this.chunk ? Math.ceil(params.length / this.chunk) : 1;
		for (var i = 0; i < this.parts; i++) {
			var call =
				<methodCall>
					<methodName>{method}</methodName>
					<params></params>
				</methodCall>
			;
			var param = this.chunk ?
				params.slice(this.chunk * i, this.chunk * (i + 1)) : params;
			for (var j = 0; j < param.length; j++) {
				call..params.appendChild(
					<param><value><string>{param[j]}</string></value></param>
				);
			}
			this.calls.push(call);
		}
		return this;
	},
	result: function(callback)
	{
		this.callback = callback;
		for (var i = 0; i < this.parts; i++) {
			GM_xmlhttpRequest({
				method: 'post',
				url: this.endPoint,
				data: this.calls[i].toString(),
				onload: this._loadHandler.bind(this)
			});
		}
		return this;
	},
	split: function(chunk)
	{
		this.chunk = chunk;
		return this;
	},
	_loadHandler: function(res)
	{
		var response = new XML(res.responseText.replace(/^<\?xml.*?\?>/, ''));
		if (this.response) {
			this.response..struct.appendChild(response..member);
		} else {
			this.response = response;
		}
		if (++this.called == this.parts) {
			this.callback(this.response);
		}
	}
};
// }}}

var __Filter_created_on = unsafeWindow.Filter.created_on;
unsafeWindow.Filter.created_on = function(v, k, tmpl) {
	Hatebu.getBookmarkers(tmpl.get_param('link'), tmpl.get_param('id'));
	return '<a id="hatebu_' + tmpl.get_param('id') + '" href="' + Hatebu.entryURI + tmpl.get_param('link').replace(/#/, '%23') + '">?B</a> | '
	+ __Filter_created_on(v, k, tmpl); 
}

var Hatebu = {
	bookmarkers: { },

	getBookmarkers: function(uri, id) {
		if (uri in Hatebu.bookmarkers) {
			Hatebu.updateLinkElementByUsers(id, Hatebu.bookmarkers[uri]);
		} else {
			new XMLRPC()
				.proxy(Hatebu.endPoint)
				.call('bookmark.getCount', [uri])
				.result(function(response) {
					for each (var member in response..member)
						Hatebu.bookmarkers[member.name] = member..int;
					Hatebu.updateLinkElementByUsers(id, Hatebu.bookmarkers[uri]);
				})
		}
	},

	updateLinkElementByUsers: function(id, users) {
		var link = document.getElementById('hatebu_' + id);
		if (!link) {
			setTimeout(function() { Hatebu.updateLinkElementByUsers(id, users) }, 100);
		} else {
			link.innerHTML += ' ' + users + (users == 1 ? ' user' : ' users');
			link.setAttribute('class', users >= 10 ? 'hottest' :
									   users >=  5 ? 'hotter'  :
													 'hot');
		}
	},

	entryURI: 'http://b.hatena.ne.jp/entry/',

	endPoint: 'http://b.hatena.ne.jp/xmlrpc'
}

var style = document.createElement('style');
style.setAttribute('type', 'text/css');
style.innerHTML
	=  '.hotter'
	+  '{'
	+  '	color: #ff6666 !important;'
	+  '	background-color: #fff0f0;'
	+  '	font-weight: bold;'
	+  '	font-style: normal;'
	+  '}'
	+  '.hottest'
	+  '{'
	+  '	color: red !important;'
	+  '	background-color: #ffcccc;'
	+  '	font-weight: bold;'
	+  '	font-style: normal;'
	+  '}';
document.getElementsByTagName('head')[0].appendChild(style);
