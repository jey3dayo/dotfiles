// ==UserScript==
// @name          Google Reader - Social Bookmark
// @namespace     http://at-aka.blogspot.com/
// @description   Add shortcut keys 'b' for bookmarking Hatena Bookmark and 'B' for livedoor clip.
// @include       http://www.google.com/reader/*
// @include       https://www.google.com/reader/*
// @include       http://reader.google.com/*
// @include       https://reader.google.com/*
// ==/UserScript==

var entry = new Array();

function greader_get_title_and_url ()
{
  var current_entry = document.getElementById('current-entry');
  var a = current_entry.getElementsByTagName('a');
  var h2 = current_entry.getElementsByTagName('h2')[0];

  // Title
  var blog_name = '';
  var entry_title = '';
  if (h2.firstChild == a[0]) {
    // Expanded View
    blog_name = a[1].textContent;
    entry_title = a[0].firstChild.textContent;
  } else {
    // List View
    blog_name = current_entry.getElementsByTagName('span')[0].textContent;
    entry_title = h2.textContent;
  }
  entry['title'] = encodeURIComponent(blog_name + ": " + entry_title);

  // URL
  var url = a[0].href;
  // trim ?ref=atom, ?ref=rss, &f=rss, ?from=RSS, &f=rss1027
  // ref. http://sho.tdiary.net/20051101.html#p01
  // ref. http://watcher.moe-nifty.com/memo/2006/04/delicious__df5c.html
  url = url.replace(/(\?|&)(ref|from|fr|f)=(RSS|rss.*|atom)/,'');
  entry['url']   = encodeURIComponent(url);
}

function greader_open_link (link)
{
  window.open(link);
  // if you prefer to open a tab in background, you can use this alternative.
  // GM_openInTab(link);
}

function greader_hatena_bookmark () {
  var b_hatena = 'http://b.hatena.ne.jp/add?mode=confirm&is_bm=1';
  var link = b_hatena + '&title=' + entry['title'] + '&url=' + entry['url'];
  greader_open_link(link);
}

function greader_livedoor_clip ()
{
  var livedoor_clip = 'http://clip.livedoor.com/clip/add?';
  var link = livedoor_clip + 'title=' + entry['title'] + '&link=' + entry['url'];
  greader_open_link(link);
}

function greader_delicious ()
{
  var delicious = 'http://del.icio.us/post?v=4';
  var link = delicious + ';title=' + entry['title'] + ';url=' + entry['url'];
  greader_open_link(link);
}

function GRT_key(event)
{
  var element = event.target;
  elementName = element.nodeName.toLowerCase();
  var typing = false;
  if (elementName == "input") {
    typing = (element.type == "text" || element.type == "password");
  } else {
    typing = (elementName == "textarea");
  }
  if (typing) return true;
  var key = String.fromCharCode(event.which);
  if ((key == "B" || key == "b") && !event.ctrlKey && !event.altKey) {
    greader_get_title_and_url();
    if (key == "B"){
      greader_livedoor_clip();
    } else { // "b"
      greader_hatena_bookmark();
    }
    try {
      event.preventDefault();
    } catch (e) {
    }
    return false;
  }
  return true;
}

//document.addEventListener("keypress", GRT_key, false);
document.addEventListener("keydown", GRT_key, false);
