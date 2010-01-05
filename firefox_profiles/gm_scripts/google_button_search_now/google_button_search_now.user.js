// ==UserScript==
// @name          Google Button Search Now
// @namespace     http://a-h.parfe.jp/einfach/
// @include       http://*.google.*/*
// ==/UserScript==

(function() {

var ginput = document.getElementsByTagName('input');

for (i=0; i<ginput.length; i++){
	if(ginput[i].id == 'lrt' || ginput[i].id == 'stw' || ginput[i].id == 'il' || ginput[i].id == 'all')ginput[i].addEventListener('click', function(){
		var gform = document.evaluate("//form[@name='f']", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue || document.evaluate("//form[@name='gs']", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
		gform.submit();
	}, true);
}

})();