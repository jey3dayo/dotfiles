// ==UserScript==
// @name           ReblogCommand
// @namespace      http://white.s151.xrea.com/
// @include        *
// ==/UserScript==

(function(){

const ALLOW_OWN_DOMAIN = true;

if(!window.Minibuffer) return;
var $X = window.Minibuffer.$X
var D  = window.Minibuffer.D

// ----------------------------------------------------------------------------
// Reblog
// ----------------------------------------------------------------------------

function isTumblrUserURL(url){
	return url.match("^https?://\\w+.tumblr.com/post/(\\d+)$") ||
	  // tumblr allow to use own domain. but this is risky. (?)
	  (ALLOW_OWN_DOMAIN && url.match("^https?://[^/]+/post/(\\d+)$"));
}

function getIDByPermalink(url){
	if(isTumblrUserURL(url)){
		return RegExp.$1;
	}else{
		// return what ?
		return false;
	}
}

function getURLByID(id){
	return "http://www.tumblr.com/reblog/" + id;
}

function getSource(url){
	with(D()){
		return xhttp.get(url)
	}
}

function convertToHTMLDocument(html){
	var xsl = (new DOMParser()).parseFromString(
		'<?xml version="1.0"?>\
				<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform">\
				<output method="html"/>\
			</stylesheet>', "text/xml");
	var xsltp = new XSLTProcessor();
	xsltp.importStylesheet(xsl);
	var doc = xsltp.transformToDocument(document.implementation.createDocument("", "", null));
	doc.appendChild(doc.createElement("html"));
	var range = doc.createRange();
	range.selectNodeContents(doc.documentElement);
	doc.documentElement.appendChild(range.createContextualFragment(html));
	return doc;
}

function parseParams(doc){
	var elms = $X('id("edit_post")//*[name()="INPUT" or name()="TEXTAREA" or name()="SELECT"]', doc);
	var params = {};
	elms.forEach(function(elm){
		params[elm.name] = elm.value;
	});
	return params;
}

function createPostData(params){
	var arr = [];
	for(param in params){
		if(param != "preview_post"){
			arr.push(encodeURIComponent(param));
			arr.push("=");
			arr.push(encodeURIComponent(params[param]));
			arr.push("&");
		}
	}
	return arr.join('')
}

function postData(url, aData){
	with(D()){
		return xhttp.post(url, aData)
	}
}

function reblog(aURL){
	var id  = getIDByPermalink(aURL);
	var d;
	with(D()){
		d = Deferred();
		if(!id) {
			wait(0).next(function(){d.call()});
			return d;
		}
	}
	var url = getURLByID(id);
	window.Minibuffer.status('ReblogCommand'+id, 'Reblog ...');
	getSource(url).
	next(function(res){
		return postData(url, createPostData( parseParams( convertToHTMLDocument(res.responseText))));
	}).
	next(function(){ window.Minibuffer.status('ReblogCommand'+id, 'Reblog ... done.', 100); d.call()}).
	error(function(){
		if(confirm('reblog manually ? \n' + url)) reblogManually(aURL);
		d.call();
	});
	return d;
}

function reblogManually(aURL){
	var id  = getIDByPermalink(aURL);
	if(!id) return;
	var url = getURLByID(id);
	window.open(url);
}

// ----------------------------------------------------------------------------
// Command
// ----------------------------------------------------------------------------


function getTargetCommand(){
	var target_cmd = '';
	var loc = window.location.href;
	if(loc == "http://fastladder.com/reader/" ||
	   loc == "http://reader.livedoor.com/reader/"){
		target_cmd = 'pinned-or-current-link';
	}else if(isTumblrUserURL(loc)){
		target_cmd = 'location';
	}else if(window.LDRize){
		target_cmd = 'pinned-or-current-link';
	}else{
		target_cmd = 'location';
	}
	return target_cmd;
}

window.Minibuffer.addShortcutkey({
  key: 't',
  description: 'Reblog',
  command: function(){
	  var target_cmd = getTargetCommand();
	  var clear_pin = (target_cmd == 'pinned-or-current-link') ? ' | clear-pin' : '';
	  window.Minibuffer.execute(target_cmd + ' | reblog' + clear_pin);
  }});

window.Minibuffer.addShortcutkey({
  key: 'T',
  description: 'Reblog manually',
  command: function(){
	  var target_cmd = getTargetCommand();
	  var clear_pin = (target_cmd == 'pinned-or-current-link') ? ' | clear-pin' : '';
	  window.Minibuffer.execute(target_cmd + ' | reblog -m' + clear_pin );
  }});

window.Minibuffer.addCommand({
  name: 'reblog',
  command: function(stdin){
	  var args = this.args;
	  var urls = [];
	  if(!stdin.length){
		  // command line is just 'reblog'
		  urls = [window.location.href];
		  nodes = new Array(1);
	  }else if(stdin.every(function(a){return typeof a == 'string'})){
		  // command line is 'location | reblog'
		  urls = stdin;
	  }else if(stdin.every(function(a){return a && a.nodeName == 'A'})){
		  // command line is 'pinned-or-current-link | reblog'
		  urls = stdin.map(function(node){return node.href});
	  }

	  // reblog
	  if(args.length = 1 && args[0] == '-m'){
		  urls.forEach(function(aURL){
			  reblogManually(aURL);
		  });
	  }else if(args.length){
		  console.log('unknown args...');
	  }else{
		  urls = urls.filter(isTumblrUserURL);
		  if(!urls.length) return stdin;
		  var lst = urls.map(reblog);
		  if(lst.length > 1){
			  with(D()){
				  parallel(lst).wait(2).
				  next(function(){window.Minibuffer.status('ReblogCommand','Everything is OK', 1000)});
			  }
		  }
	  }
	  return stdin;
  }
});

})()
