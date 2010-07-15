// ==UserScript==
// @name          GR+?B
// @namespace     http://d.hatena.ne.jp/nozom/
// @description   show ?B button and count in Google Reader
// @include       http://www.google.com/reader/view/*
// @include       https://www.google.com/reader/view/*
// ==/UserScript==

// original author is id:kusigahama
// see http://d.hatena.ne.jp/kusigahama/20051207#p1

(function() {
  const user = 'J138';

  var timerID = null;
  var busy = false;
  var urlCache = new Object();

  function getUrlCache(url) {
    if (typeof urlCache[url] == 'undefined')
      urlCache[url] = new Object();
    return urlCache[url];
  }

  String.prototype.htmlescape = function() {
    return this.replace(/&/g, "&amp;").replace(/</g, "&lt;");
  }

  function findNode(root, xpath) {
    var result = document.evaluate(xpath, root, null, XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE, null);
    if (! result.snapshotLength) return null;
    return result.snapshotItem(0);
  }

  function getBookmarkCountSpan(node) {
    return findNode(node, 'span[@class="hatena-bookmark-count"]');
  }

  function insertBookmarkCount(targetNode, url, count) {
    var a = document.createElement('a');
    a.setAttribute('href', "http://b.hatena.ne.jp/entry/" + url);
    a.setAttribute('target', '_blank');

    var str = (count > 0 ? "" + count : "no") + " user" + (count != 1 ? "s" : "");
    a.appendChild(document.createTextNode(str));

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

    with (targetNode) {
      appendChild(document.createTextNode(" ("));
      appendChild(a);
      appendChild(document.createTextNode(") "));
    }
  }

  function createBookmarkCount(url, count) {
    var node = document.createElement('span');
    node.setAttribute('class', 'hatena-bookmark-count');
    if (count > 0) {
      insertBookmarkCount(node, url, count);
    } else {
      node.appendChild(document.createTextNode(' '));
    }
    return node;
  }

  function setBookmarkCounts(infoArray) {
    for (var i = 0; i < infoArray.length; i++) {
      var entry = infoArray[i].entry;
      var url = infoArray[i].url;
      var title = infoArray[i].title;
      var entryContainerTitle = infoArray[i].entryContainerTitle;
      var collapsedTitle = infoArray[i].collapsedTitle;
      var entryActions = infoArray[i].entryActions;

      var count = getUrlCache(url).count;
      if (typeof count != 'undefined') {
        if (typeof collapsedTitle != 'undefined') {
          var node = createBookmarkCount(url, count);
          collapsedTitle.insertBefore(node, collapsedTitle.childNodes[1]);
        }
        if (typeof entryContainerTitle != 'undefined') {
          var node = createBookmarkCount(url, count);
          entryContainerTitle.insertBefore(node, entryContainerTitle.childNodes[1]);
        }
      }
    }
  }

  function callXmlrpc(requestbody, infoArray) {
    const endpoint = "http://b.hatena.ne.jp/xmlrpc";
    function onload(response) {
      if (response.responseText.match(/<fault>/)) {
        clearInterval(timerID);
        alert("xmlrpc call failed: " + response.responseText + "\n" + "request: " + requestbody);
      } else {
        var pattern = /<name>([^<]+)<\/name>\s*<value><int>(\d+)/g;
        var m;
        while (m = pattern.exec(response.responseText)) {
          getUrlCache(m[1]).count = m[2];
        }
        setBookmarkCounts(infoArray);
      }
      busy = false;
    }

    // alert('xmlrpc call');
    GM_xmlhttpRequest({ method: "POST", url: endpoint, data: requestbody, onload: onload });
  }

  function createAddBookmarkIcon(url, title) {
    var a = document.createElement('a');
    a.setAttribute('href', 'http://b.hatena.ne.jp/add?mode=confirm&is_bm=1&title=' + escape(title) + '&url=' + escape(url));
    a.setAttribute('target', '_blank');

    var img = document.createElement('img');
    img.setAttribute('src', 'http://b.hatena.ne.jp/images/append.gif');
    img.setAttribute('alt', 'add bookmark');
    img.setAttribute('title', 'add bookmark');
    with (img.style) {
      borderWidth = '0px';
    }
    a.appendChild(img);

    var node = document.createElement('span');
    node.setAttribute('class', 'hatena-bookmark-icon');
    node.appendChild(a);

    return node;
  }

  function createBookmarkIcon() {
    var img = document.createElement('img');
    img.setAttribute('src', 'http://www.hatena.ne.jp/images/user_bookmark.gif');
    img.setAttribute('alt', 'bookmarked');
    img.setAttribute('title', 'bookmarked');

    var node = document.createElement('span');
    node.setAttribute('class', 'hatena-bookmark-icon');
    node.appendChild(img);

    return node;
  }

  function addBookmarkIcon(currentEntry) {
    var entryContainerTitle = findNode(currentEntry, './/div[@class="entry-container"]//h2');
    var entryActions = findNode(currentEntry, './/div[@class="entry-actions"]');
    if ((entryContainerTitle == null) || (entryActions == null)) return;

    var link = entryContainerTitle.firstChild;
    var title = link.firstChild.textContent;

    function onload(response) {
      if (response.responseText != null) {
        var responseXML = (new DOMParser()).parseFromString(response.responseText, "application/xml");
        if (responseXML != null) {
          var channel = responseXML.getElementsByTagName('channel')[0];
          if (channel != null) {
            var items = channel.getElementsByTagName('items')[0];
            if (items != null) {
              var lis = items.getElementsByTagName('li');
              if (lis.length > 0) {
                getUrlCache(link.href).bookmarked = true;
                entryActions.appendChild(createBookmarkIcon());
              } else {
                getUrlCache(link.href).bookmarked = false;
                entryActions.appendChild(createAddBookmarkIcon(link.href, title));
              }
            }
          }
        }
      }
    }

    var bookmarked = getUrlCache(link.href).bookmarked;
    if (typeof bookmarked == 'undefined') {
      getUrlCache(link.href).bookmarked = 'loading';
      var url = 'http://b.hatena.ne.jp/' + user + '/rss?url=' + escape(link.href);
      GM_xmlhttpRequest({ method: "GET", url: url, onload: onload });
    } else if (bookmarked == 'loading') {
      // skipped
    } else if (bookmarked) {
      entryActions.appendChild(createBookmarkIcon());
    } else {
      entryActions.appendChild(createAddBookmarkIcon(link.href, title));
    }
  }

  function timerHandler() {
    if (busy) return;

    var entries = document.getElementById('entries');
    if (entries == null) return;

    var currentEntry = document.getElementById('current-entry');
    if (currentEntry != null) {
      if (findNode(currentEntry, './/span[@class="hatena-bookmark-icon"]') == null) {
        addBookmarkIcon(currentEntry);
      }
    }

    busy = true;

    var infoArray = new Array();
    var reqUrlArray = new Array();
    var reqUrlHash = new Object();
    for (var i = 0; i < entries.childNodes.length; i++) {
      var entry = entries.childNodes[i];
      var collapsedTitle = findNode(entry, './/div[@class="collapsed"]//h2');
      var entryContainerTitle = findNode(entry, './/div[@class="entry-container"]//h2');

      var link = null;
      var title = null;
      if (entryContainerTitle != null) {
        link = entryContainerTitle.firstChild;
        title = link.firstChild.textContent;
      } else if (collapsedTitle != null) {
        link = collapsedTitle.parentNode.parentNode.firstChild;
        title = collapsedTitle.textContent;
      }

      if (link != null) {
        var info = { entry: entry, url: link.href, title: title };
        if ((collapsedTitle != null) && (getBookmarkCountSpan(collapsedTitle) == null)) {
          info.collapsedTitle = collapsedTitle;
        }
        if ((entryContainerTitle != null) && (getBookmarkCountSpan(entryContainerTitle) == null)) {
          info.entryContainerTitle = entryContainerTitle;
        }
        if ((info.collapsedTitle != null) || (info.entryContainerTitle != null)) {
          infoArray.push(info);
          if ((getUrlCache(link.href).count == null) &&
              (! reqUrlHash[link.href])) {
            reqUrlHash[link.href] = true;
            reqUrlArray.push(link.href);
          }
        }
      }
    }

    if (infoArray.length == 0) {
      busy = false;
      return;
    }

    if (reqUrlArray.length == 0) {
      // all items are found in the cache
      setBookmarkCounts(infoArray);
      busy = false;
    } else {
      // avoid xmlrpc call failure in 'too many params' error
      reqUrlArray = reqUrlArray.splice(0, 50);

      var request = '<?xml version="1.0"?>\n<methodCall>\n<methodName>bookmark.getCount</methodName>\n<params>\n';
      for (var i = 0; i < reqUrlArray.length; i++) {
        var url = reqUrlArray[i];
        request += "<param><value><string>" + url.htmlescape() + "</string></value></param>\n";
      }
      request += "</params>\n</methodCall>\n";
      callXmlrpc(request, infoArray);
    }
  }

  // be careful not to be too busy
  timerID = setInterval(timerHandler, 3000);
})();
