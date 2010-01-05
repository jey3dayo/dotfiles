// ==UserScript==
// @name          Tumblr - Dashbord brushup
// @namespace     http://userstyles.org
// @description	  This code is not made by me
// @author        brasil
// @homepage      http://userstyles.org/styles/2410
// @include       http://www.tumblr.com/dashboard*
// ==/UserScript==
(function() {
var css = "@namespace url(http://www.w3.org/1999/xhtml); /* ReBlogされた画像が白くならないように */ ol#posts li.dim div.post_container { opacity: 1.00 !important; } /* ReBlogされたものもReBlog出来るように */ ol#posts li.dim a.reblog_link { display: inline !important; } /* RSSから更新されてるものがわかるように */ ol#posts li.not_mine div.imported_from { display: block !important; } /*自分の吹きだし三角*/ ol#posts li.is_mine div.arrow { display: block !important; } ol#posts li.same_user_as_last div.arrow, ol#posts.only_me li.is_mine div.arrow { display: none !important; } /*自分の名前*/ ol#posts li.is_mine div.username { display: block !important; } ol#posts li.same_user_as_last div.username, ol#posts.only_me li.is_mine div.username { display: none !important; } /*自分のアイコン*/ ol#posts li.is_mine div.avatar { display: inline !important; } ol#posts li.same_user_as_last div.avatar, ol#posts.only_me li.is_mine div.avatar { display: none !important; }";
if (typeof GM_addStyle != "undefined") {
	GM_addStyle(css);
} else if (typeof addStyle != "undefined") {
	addStyle(css);
} else {
	var heads = document.getElementsByTagName("head");
	if (heads.length > 0) {
		var node = document.createElement("style");
		node.type = "text/css";
		node.appendChild(document.createTextNode(css));
		heads[0].appendChild(node); 
	}
}
})();
