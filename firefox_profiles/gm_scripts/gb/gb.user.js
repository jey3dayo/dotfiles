// ==UserScript==
// @name          G+?B
// @namespace     http://ukgk.g.hatena.ne.jp/faerie/
// @description   show ?B count in Google search result
// @include       http://*.google.*/*q=*
// ==/UserScript==

(function() {
  function setBookmarkCount(link, count) {
    var a = document.createElement("a");
    a.setAttribute("href", "http://b.hatena.ne.jp/entry/"+link.href);
    a.appendChild(document.createTextNode(""+count+" user"+(count>1?"s":"")));
    with (a.style) {
      fontSize = "0.9em";
      textDecoration = "none";
      if (count >= 5) {
        fontWeight = "bold";
        backgroundColor = "#fff0f0";
        color = "#f66";
      }
      if (count >= 10) {
        backgroundColor = "#ffcccc";
        color = "red";
      }
    }
    link.parentNode.insertBefore(a, link.nextSibling);
    link.parentNode.insertBefore(document.createTextNode(" "), link.nextSibling);
  }
  function callXmlrpc(requestbody, url2link) {
    const endpoint = "http://b.hatena.ne.jp/xmlrpc";
    function onload(response) {
      var pattern = /<name>([^<]+)<\/name>\s*<value><int>(\d+)/g;
      var m;
      while (m = pattern.exec(response.responseText)) {
        var link = url2link[m[1]];
        if (link && m[2] > 0) setBookmarkCount(link, m[2]);
      }
    }
    GM_xmlhttpRequest({method: "POST", url: endpoint, data: requestbody, onload: onload});
  }

  var links = document.evaluate('//a[@class="l"]', document, null, XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE, null);
  if (!links.snapshotLength) return;
  var request = '<?xml version="1.0"?>\n<methodCall>\n<methodName>bookmark.getCount</methodName>\n<params>\n';
  var url2link = new Array(links.snapshotLength);
  String.prototype.htmlescape = function() {
    return this.replace(/&/, "&amp;").replace(/</g, "&lt;");
  }
  for (var i = 0; i < links.snapshotLength; ++i) {
    var link = links.snapshotItem(i);
    request += "<param><value><string>"+link.href.htmlescape()+"</string></value></param>\n";
    url2link[link.href] = link;
  }
  request += "</params>\n</methodCall>\n";
  callXmlrpc(request, url2link);
})();
