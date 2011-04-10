// ==UserScript==
// @name           GoogleWithHatenaBookmark
// @namespace      http://d.hatena.ne.jp/eclipse-a/
// @description    search entry posted Hatena Bookmark with Google
// @include        http://www.google.*/search?*
// ==/UserScript==

(function() {
    // option
    var user_id = "J138";
    var use_favicon = true;
    var show_limit = 10;

    // constant
    var hatebu_url = "http://b.hatena.ne.jp/"
    var hatebu_user_url = hatebu_url + user_id
    var feed_url = hatebu_user_url + "/rss";
    var search_dara_url = hatebu_user_url + "/search.data";
    var box_id = "google_with_hatenabookmark";
    var gm_bookmarks = "bookmarks";

    // abstract function
    var load_bookmarks = null;
    var load_keywords = null;
    var filter_bookmarks = null;
    var show_bookmarks = null;
    var main = null;

    // concrete function
    load_bookmarks = function(onload) {
        var bookmarks = GM_getValue(gm_bookmarks, "");
        if (bookmarks == undefined || bookmarks == null || bookmarks == "") {
            // reload bookmarks
            var onload_search_data = function(response) {
                var bookmarks = new Array();
                var lines = response.responseText.split("\n");
                var total = lines.length / 4;
                for (var i = 0; i < lines.length && i < total * 3; i += 3) {
                    var bookmark = {};
                    bookmark.title = lines[i];
                    bookmark.tags = lines[i + 1];
                    bookmark.url = lines[i + 2];
                    bookmarks.push(bookmark);
                }
                GM_log("load_bookmarks():lines.length=" + lines.length + ",bookmarks.length=" + bookmarks.length);
                GM_setValue(gm_bookmarks, bookmarks.toSource());
                onload(bookmarks);
            };
            GM_xmlhttpRequest({method: "GET", url: search_dara_url, onload: onload_search_data});
        } else {
            onload(eval(bookmarks));
        }
    };

    load_keywords = function() {
        var titles = document.getElementsByTagName("TITLE");
        if (titles == null) {
            return null;
        }
        var title = titles[0].firstChild;
        return title.nodeValue.replace(/ -[^-]*$/, "").split(" "); 
    };

    filter_bookmarks = function(bookmarks, keywords) {
        Array.forEach(keywords, function(k, i, a) {
                var l = k.toLowerCase();
                bookmarks = Array.filter(bookmarks, function(b, i2, a2) {
                        return ((b.title + b.tags + b.url).toLowerCase().indexOf(l) != -1);
                    });
            });
        return bookmarks;
    };

    show_bookmarks = function(bookmarks, keywords) {
        if (bookmarks == null) {
            return;
        }
        var target = document.getElementById("res");
        if (target == null) {
            return;
        }
        var box = document.getElementById(box_id);
        if (box != null) {
            GM_log("show_bookmarks()");
            box.parentNode.removeChild(box);
        }
        box = document.createElement("div");
        box.setAttribute("id", box_id);
        with (box.style) {
            lineHeight = "1.4";
            fontSize = "90%";
        };
        var span = document.createElement("span");
        span.appendChild(document.createTextNode(" "));
        var a_hatebu = document.createElement("a");
        a_hatebu.setAttribute("href", hatebu_url);
        a_hatebu.appendChild(document.createTextNode("Hatena::Bookmark"));
        span.appendChild(a_hatebu);
        span.appendChild(document.createTextNode(" "));
        var a_user = document.createElement("a");
        a_user.setAttribute("href", hatebu_user_url);
        a_user.appendChild(document.createTextNode("::" + user_id.toLowerCase()));
        span.appendChild(a_user);
        span.appendChild(document.createTextNode(" "));
        span.appendChild(document.createTextNode("("));
        span.appendChild(document.createTextNode(bookmarks.length));
        span.appendChild(document.createTextNode(")"));
        span.appendChild(document.createTextNode(" "));
        var a_reload = document.createElement("a");
        a_reload.setAttribute("href", "javascript:void(0)");
        a_reload.setAttribute("id", box_id + "_reload");
        a_reload.addEventListener("click", function() {
                var reload = document.getElementById(box_id + "_reload");
                reload.removeEventListener("click", arguments.callee, false);
                reload.innerHTML = "Loading";
                var ul = document.getElementById(box_id + "_ul");
                ul.style.display = "none";
                GM_setValue(gm_bookmarks, "");
                main();
            }, false);
        a_reload.appendChild(document.createTextNode("Reload"));
        span.appendChild(a_reload);
        span.appendChild(document.createTextNode(" "));
        var a_keywords = document.createElement("a");
        a_keywords.setAttribute("href", hatebu_user_url + "/?q="
                + encodeURIComponent(keywords.join(" ")));
        a_keywords.appendChild(document.createTextNode('["' + keywords.join('","') + '"]'));
        span.appendChild(a_keywords);
        box.appendChild(span);
        var ul = document.createElement("ul");
        ul.setAttribute("id", box_id + "_ul");
        Array.some(bookmarks, function(b, i) {
                if (i >= show_limit) {
                    return true;
                }
                var li = document.createElement("li");
                li.style.padding = "0px";
                li.style.overflow = "hidden";
                li.style.minHeight = "18px";
                li.style.height = "1.4em";
                var a = document.createElement("a");
                a.setAttribute("href", b.url);
                if (use_favicon) {
                    var favicon = document.createElement("div");
                    with (favicon.style) {
                        width = "16px";
                        height = "16px";
                        margin = "0px";
                        padding = "0px";
                        cssFloat = "left";
                        backgroundImage = 'url("http://' + a.hostname + '/favicon.ico")';
                    };
                    li.appendChild(favicon);
                }
                a.appendChild(document.createTextNode(b.title)); // TODO: tags
                li.appendChild(a);
                ul.appendChild(li);
                return false;
            });
        box.appendChild(ul);
        target.parentNode.insertBefore(box, target);
    };

    var main = function() {
        var onload = function(bookmarks) {
            GM_log("bookmarks.length=" + bookmarks.length);
            // load keywords
            var keywords = load_keywords();
            GM_log("keywords=" + keywords);
            // filter bookmarks
            bookmarks = filter_bookmarks(bookmarks, keywords);
            GM_log("filter_bookmarks.length=" + bookmarks.length);
            // show bookmarks & keywords
            show_bookmarks(bookmarks, keywords);
        };
        // load(reload) bookmarks
        load_bookmarks(onload);
    };

    main();

})();
