// ==UserScript==
// @name           wikipedia.googleimage
// @namespace      http://www.kagami.org/
// @include        http://ja.wikipedia.org/wiki/*
// ==/UserScript==

(function () {
    var baseurl = 'http://images.google.co.jp/images?hl=ja&oe=UTF-8&ie=UTF-8&um=1&q=';
    var word = unsafeWindow.wgTitle;
    var searchurl = baseurl + word;

    var img = document.createElement('img');
    img.alt = 'Google Image Search: ' + word;

    var a = document.createElement('a');
    a.appendChild(img);
    a.href = searchurl;

    var div = document.createElement('div');
    div.appendChild(a);

    var h1 = document.getElementsByTagName('h1')[0];
    h1.parentNode.insertBefore(div, h1.nextSibling);

    GM_xmlhttpRequest({
        method: 'GET',
	url: searchurl,
        headers: { 'User-agent': 'Mozilla/4.0 (compatible) Greasemonkey' }, 
        onload: function(responseDetails) {
	    if (responseDetails.responseText.match(/<img src=(http:\/\/tbn.+?) width/)) {
		img.src = RegExp.$1;
	    }
	}
    });
})();
