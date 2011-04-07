// ==UserScript==
// @name           0LDRize SITEINFO
// @namespace      http://ss-o.net/
// @description    oLDRize SITEINFO
// @include        http*
// @checkurl       http://ss-o.net/userjs/0LDRize.SITEINFO.user.js
// ==/UserScript==
window.LDRizeWedataSiteinfo = [
{
"name":"read.cgi",
"paragraph":"(//dl[contains(@class,\"thread\")] | id(\"thread-body\") | //dl)[1]/dt",
"domain":"^http://(?:[^/]+/search\\?.*?\\bq=[^&;=]*?cache:[^:]+:)?(?:(?:[^.]+\\.)+?2ch\\.net/(?:test/read\\.cgi/|[^/]+/kako/\\d+)|[^.]+\\.bbspink\\.com/test/read\\.cgi/|jbbs\\.livedoor\\.jp/(?:bbs/read\\.cgi/|[^/]+/\\d+/[^/]+/\\d+\\.html)|p2\\.chbox\\.jp/read\\.php)",
"stripe":"0"
},
{
"name":"",
"paragraph":"//tr[@class='odd_normal' or @class='even_normal']",
"domain":"^https?://(?:www\\.k\\.kyoto-u\\.ac\\.jp|student\\.iimc\\.kyoto-u\\.ac\\.jp/iwproxy/KULASIS)/student/(?:la|[gu]/[a-z]+)/(?:syllabus/|timeslot/lecture_)search",
"stripe":"false",
"height":"",
"disable":"",
"link":".//a[img[@alt='\u8a73\u7d30']]",
"view":""
},
{
"name":"Amazon bestsellers and others category",
"paragraph":"//strong[contains(concat(\" \", @class, \" \"), \" sans \")]/ancestor::tr",
"domain":"^http://www\\.amazon\\.(?:[^.]+\\.)?[^./]+/gp/(?:bestsellers|mo(?:st-(?:wished-for|gifted)|vers-and-shakers)|new-releases)/(?:[^/]+/)+ref",
"link":".//a"
},
{
"name":"",
"paragraph":"//tr[@class='odd_normal' or @class='even_normal']",
"domain":"^https?://(?:www\\.k\\.kyoto-u\\.ac\\.jp|student\\.iimc\\.kyoto-u\\.ac\\.jp/iwproxy/KULASIS)/student/(?:la|[gu]/[a-z]+)/notice",
"stripe":"false",
"height":"",
"disable":"",
"link":".//a[img[@alt='\u8a73\u7d30']]",
"view":""
},
{
"name":"Amazon bestsellers and others",
"paragraph":"//div[contains(concat(\" \", @class, \" \"), \" product \")]/ancestor::td",
"domain":"^http://www\\.amazon\\.(?:[^.]+\\.)?[^./]+/gp/(?:bestsellers|mo(?:st-(?:wished-for|gifted)|vers-and-shakers)|new-releases)/ref",
"link":".//a"
},
{
"name":"Tumblr",
"paragraph":"id(\"posts\")/li[starts-with(@id,\"post\")] | id(\"posts\")/li[starts-with(@id,\"tweet\")]",
"domain":"^http://www\\.tumblr\\.com/(?:d(?:ashboard|rafts)|filter|like(?:s|d)|popular|queue|show|t(?:umblelog|witter|agged))",
"height":"0",
"link":".//a[@title=\"Permalink\"]",
"exampleUrl":"http://www.tumblr.com/dashboard"
},
{
"name":"coneco.net",
"paragraph":"//tr[td[contains(concat(\" \",@class,\" \"),\" img_pro \")]]|//table[contains(concat(\" \",@class,\" \"),\" imgtable \")]//td",
"domain":"^http://www\\.coneco\\.net/(?:[sS]pecList(?:/\\d+/?|\\.asp\\?.+)|list_(?:spec|cate(?:brand|maker))/\\d+/.+\\.html)",
"height":"1",
"link":"td/a|a",
"view":"td/span[contains(concat(\" \",@class,\" \"),\" ttl \")]/a/text()|a/strong/following-sibling::text()"
},
{
"name":"RandomNote",
"paragraph":"//h1",
"domain":"html/body[child::div[1][@class=\"head\"] and child::div[2][@class=\"main\"] and child::div[3][@class=\"sidebar\"]]",
"link":"a[text()=\"*\"]"
},
{
"name":"\u95c7\u9ed2\u65e5\u8a18",
"paragraph":"//dt",
"domain":"^http://(?:members\\.jcom\\.home\\.ne\\.jp/w3c/omake/diary\\.html|noz\\.hp\\.infoseek\\.co\\.jp/diary/)",
"exampleUrl":"http://members.jcom.home.ne.jp/w3c/omake/diary.html"
},
{
"name":"Vicuna CMS",
"paragraph":"//div[contains(concat(\" \",normalize-space(@class),\" \"),\" entry \")]",
"domain":"//div[@id=\"footer\"]/ul[@class=\"support\"]/li[@class=\"template\"]/a[@href=\"http://vicuna.jp/\"]",
"link":"h2/a",
"exampleUrl":"http://rapeme.org/mt/archives/2010/04/jc.htmlrnhttp://rapeme.org/"
},
{
"name":"Search results - Vim Tips Wiki",
"paragraph":"id(\"bodyContent\")/ul[contains(concat(\" \", @class, \" \"), \" mw-search-results \")]/li",
"domain":"^http://vim\\.wikia\\.com/(?:wiki/Special:Search\\?|index\\.php\\?title=Special%3ASearch&)search=",
"link":".//a",
"exampleUrl":"http://vim.wikia.com/wiki/Special:Search"
},
{
"name":"Wikipedia",
"paragraph":"//h1 | //h2[not(parent::*[@id=\"toctitle\"])] | //h3[not(@id=\"siteSub\")] | //h4",
"domain":"^(http://[^.]+\\.wikipedia\\.org/wiki/|https://secure\\.wikimedia\\.org/wikipedia/[a-z]+/wiki/)",
"view":"span[@class=\"mw-headline\"]/text() | text()"
},
{
"name":"Last.fm groups forum",
"focus":"id(\"editorTitle\")",
"paragraph":"//table[@class=\"forumtable\"]/tbody/tr[position()>1] | //ul[@class=\"thecomments\"]/li",
"domain":"^http://(?:cn\\.last\\.fm|www\\.last(?:\\.fm|fm\\.(?:com\\.[bt]r|[^./]{2})))/group/[^/]+/forum",
"height":"0",
"link":"td[1]/a | div/div[@class=\"forumLine\"]/a[contains(@class,\"permalinkbutton\")]",
"exampleUrl":"http://www.last.fm/",
"view":"td[1]/a/text() | ul/li[@class=\"date\"]/text()"
},
{
"name":"blogger",
"paragraph":"id(\"main\")//h3[contains(@class,\"post-title\")]",
"domain":"//meta[@name=\"generator\" and translate(@content,\"BLOGGER\",\"blogger\")=\"blogger\"]",
"link":"descendant::a[contains(@class,\"parmanent link\")]"
},
{
"name":"Yahoo!\u30c8\u30e9\u30d9\u30eb \u65c5\u30e1\u30e2(\u4e00\u89a7)",
"paragraph":"id(\"ytrvTmWrMain\")/div[@class=\"ytrvTmWrDomMain\" or @class=\"ytrvTmWrAbrMain\"]/div[@class=\"ytrvTmWrDomMainBody\" or @class=\"ytrvTmWrAbrMainBody\"]/div[@class=\"ytrvTmMdTdList\" or @class=\"ytrvTmMdRepList\"]",
"domain":"^http://community\\.travel\\.yahoo\\.co\\.jp/(?:abroad|domestic).*/b(?:log|uzz)\\.html",
"link":"./div[@class=\"muBody\"]/div[@class=\"pt01\"]/div[@class=\"pt01b\"]/h3/a",
"exampleUrl":"http://community.travel.yahoo.co.jp/domestic/blog.html"
},
{
"name":"Google News",
"paragraph":"//div[contains(concat(\" \",normalize-space(@class),\" \"),\" story \")]",
"domain":"^http://(news\\.google\\.(?:[^.]+\\.)?[^./]+/|www\\.google\\.(?:[^.]+\\.)?[^./]+/news)",
"stripe":"1",
"link":"*[contains(concat(\" \",@class,\" \"),\" title \")]/a[not(contains(concat(\" \",@class,\" \"),\" star-link \"))]",
"exampleUrl":"http://news.google.com/"
},
{
"name":"Amazon product pages",
"paragraph":"id(\"handleBuy\") | //*[td | div][contains(concat(\" \",normalize-space(@class),\" \"),\" bucket \")]",
"domain":"^http://www\\.amazon\\.(?:[^.]+\\.)?[^./]+/(?:[^/]+/)?(?:dp|exec/obidos/ASIN|o/ASIN)/",
"height":"0"
},
{
"name":"Last.fm inbox",
"focus":"id(\"to\")",
"paragraph":"id(\"frm\")//tr[position()>1]",
"domain":"^http://(?:cn\\.last\\.fm|www\\.last(?:\\.fm|fm\\.(?:com\\.[bt]r|[^./]{2})))/inbox",
"height":"0",
"link":"td[@class=\"msgTitle\"]/a",
"exampleUrl":"http://www.last.fm/"
},
{
"name":"MDC search",
"paragraph":"id(\"searchResults\")/ul/li",
"domain":"^https://developer\\.mozilla\\.org/(?:index\\.php\\?title=)?Special(?::|%3A)Search",
"link":".//a",
"exampleUrl":"https://developer.mozilla.org/Special:Search"
},
{
"name":"Twitter following",
"paragraph":"//tr[contains(concat(\" \",normalize-space(@class),\" \"),\" vcard \")]",
"domain":"^https?://(?:(?:api|explore|m)\\.)?twitter\\.com/(?:[^/]+/)?f(?:ollower|riend)s",
"stripe":"1",
"height":"0",
"link":".//*[@class=\"thumb\"]/a[contains(@rel,\"contact\")]",
"exampleUrl":"http://twitter.com/friends"
},
{
"name":"pukiwiki - h3",
"paragraph":"//h3",
"domain":"//strong[starts-with(translate(text(),\"PUKIWIKI\",\"pukiwiki\"),\"pukiwiki\")]",
"link":"a[contains(@class,\"anchor_super\")]"
},
{
"name":"pukiwiki - h3-h2",
"paragraph":"(//h3 | //h2)",
"domain":"//strong[starts-with(translate(text(),\"PUKIWIKI\",\"pukiwiki\"),\"pukiwiki\")]",
"link":"a[contains(@class,\"anchor_super\")]"
},
{
"name":"silog - script/LDRize/siteinfo",
"paragraph":"//ul[@class=\"list1\"]",
"domain":"^http://white\\.s151\\.xrea\\.com/wiki/index\\.php\\?script%2FLDRize%2Fsiteinfo",
"link":"./li/a",
"exampleUrl":"http://white.s151.xrea.com/wiki/index.php?script%2FLDRize%2Fsiteinfo"
},
{
"name":"Live Search",
"paragraph":"id(\"results\")/ul/li",
"domain":"^http://search\\.(?:live\\.com|msn\\.co\\.jp)/(?:(?:feed|new)s/)?results\\.aspx",
"stripe":"1",
"height":"10",
"link":"h3/a",
"exampleUrl":"http://www.live.com/"
},
{
"name":"Last.fm",
"focus":"id(\"searchInput\")",
"paragraph":"//h3",
"domain":"^http://(?:cn\\.last\\.fm|www\\.last(?:\\.fm|fm\\.(?:com\\.[bt]r|[^./]{2})))/",
"link":"a",
"exampleUrl":"http://www.last.fm/",
"view":"a/text()"
},
{
"name":"Twitter",
"paragraph":"//li[contains(concat(\" \",normalize-space(@class),\" \"),\" hentry \")]",
"domain":"^https?://(?:(?:api|explore|m)\\.)?twitter\\.com/(?![\\w-]+/status(?:es)?/)",
"stripe":"1",
"height":"0",
"link":".//a[contains(concat(\" \",normalize-space(@class),\" \"),\" entry-date \")]",
"exampleUrl":"http://twitter.com/"
},
{
"paragraph":"//div[@id=\"contestNo01\"] | //div[@id=\"contestRanking\"]/table/tbody/tr",
"domain":"^http://contest.pets.yahoo.co.jp/hiroba/photocontest/contest/[0-9]*/list/",
"link":"./ul/li/a | ./td[contains(@class, \"txt\")]/ul/li[last()]/a"
},
{
"name":"\u8fd1\u4ee3\u30c7\u30b8\u30bf\u30eb\u30e9\u30a4\u30d6\u30e9\u30ea\u30fc\u672c\u6587",
"paragraph":"//td[img]",
"domain":"^http://kindai\\.(?:da\\.)?ndl\\.go\\.jp/scrpt/ndlimageviewer-rgc\\.aspx",
"exampleUrl":"http://kindai.da.ndl.go.jp/scrpt/ndlimageviewer-rgc.aspx?pid=info:ndljp/pid/932848&jp=43003797&vol=00000&koma=1"
},
{
"name":"Yahoo!\u30c8\u30e9\u30d9\u30eb \u65c5\u30e1\u30e2(\u691c\u7d22\u7d50\u679c)",
"paragraph":"id(\"ytrvTmWrSearchBody\")/div[@class=\"ytrvTmMdSearchTdList\" or @class=\"ytrvTmMdSearchRepList\"]",
"domain":"^http://community\\.travel\\.yahoo\\.co\\.jp/search/search_result\\.html",
"link":"./div[@class=\"muBody\"]/div[@class=\"pt01\"]/div[@class=\"pt01b\"]/h3/a",
"exampleUrl":"http://community.travel.yahoo.co.jp/search/search_result.html?p=%BA%F9"
},
{
"name":"\u4fa1\u683c.com",
"paragraph":"//table[contains(concat(\" \",@class,\" \"),\" mTop5 \") or contains(concat(\" \",@class,\" \"),\" tbl-compare02 \")]//tr[td]",
"domain":"^http://kakaku\\.com/(?:specsearch/\\d+|(?:[\\w-]+/){2}[a-z]{2}_\\d+)/?",
"height":"1",
"link":".//a[1]",
"exampleUrl":"http://kakaku.com/specsearch/0510/",
"view":".//a[ancestor::strong]/text()|.//strong[ancestor::a]/text()"
},
{
"name":"\u30cb\u30b3\u30cb\u30b3\u52d5\u753b - ranking / mylist / history",
"paragraph":"//h3/ancestor::tr[not(.//table)]",
"domain":"^http://(?:de|es|tw|www)\\.nicovideo\\.jp/(?:history|mylist|ranking)",
"link":".//a",
"exampleUrl":"http://www.nicovideo.jp/"
},
{
"name":"Google Blog Search",
"paragraph":"//a[starts-with(@id,\"p-\")]",
"domain":"^http://(?:www|blogsearch)\\.google\\.(?:[^.]+\\.)?[^./]+/blogsearch",
"link":".",
"exampleUrl":"http://www.google.com/blogsearch",
"view":".//text()"
},
{
"name":"google sites",
"paragraph":"id(\"sites-canvas\")/descendant::*[self::h1 or self::h2 or self::h3 or self::h4 or self::h5 or self::h6]",
"domain":"//b[@class=\"powered-by\"]/a[contains(@href, \"sites.google.com\")]",
"stripe":"",
"height":"",
"disable":"",
"link":"",
"view":"",
"exampleUrl":"http://wiki.slash-reader.com/"
},
{
"name":"Jottit recent changes",
"paragraph":"id(\"content\")//tbody/tr",
"domain":"^http://(?:[^.]+\\.)?jottit\\.com(?::\\d+)?/(?:[^/]+/)?site/changes",
"link":"//a",
"exampleUrl":"http://youpy.jottit.com/site/changes"
},
{
"name":"Amazon yourstore and history",
"paragraph":"//h3/ancestor::tr",
"domain":"^http://www\\.amazon\\.(?:[^.]+\\.)?[^./]+/gp/(?:history|yourstore)",
"link":".//a"
},
{
"name":"mixi - view_community|show_friend",
"paragraph":"//div[contains(concat(\" \",normalize-space(@class),\" \"),\" contents \")]/dl[contains(concat(\" \",normalize-space(@class),\" \"),\" contentsList01 \")]/dt",
"domain":"^https?://mixi\\.jp/(?:show_friend|view_community)\\.pl\\?id=\\d+$",
"link":"following-sibling::dd[1]/a",
"exampleUrl":"http://mixi.jp/",
"view":"following-sibling::dd[1]/a/text()"
},
{
"name":"Reuters/SecondLife Blog",
"paragraph":"//div[@id=\"primaryContent\"]/h5",
"domain":"^http://secondlife.reuters.com/stories/category/second-life/blog/",
"stripe":"1",
"link":"a",
"exampleUrl":"http://secondlife.reuters.com/stories/category/second-life/blog/"
},
{
"name":"\u4e8c\u6642\u306e\u30c1\u30e7\u30b3",
"paragraph":"//table[@WIDTH=\"95%\"]//dl",
"domain":"http://nijinochocolate.homelinux.net/niji/head_[\\w_]+\\d+\\.html",
"stripe":"1",
"link":"dd/a[2]",
"exampleUrl":"http://nijinochocolate.homelinux.net/niji/"
},
{
"paragraph":"//div[a[starts-with(@href, \"member_illust.php?mode=big\")]]",
"domain":"^http://www\\.pixiv\\.net/member_illust\\.php\\?.*\\bmode=medium",
"link":"a",
"exampleUrl":"http://www.pixiv.net/"
},
{
"name":"\u306f\u3066\u306a\u30c0\u30a4\u30a2\u30ea\u30fc\u30fb\u30b0\u30eb\u30fc\u30d7",
"paragraph":"//div[@class=\"day\"]//div[contains(concat(\" \",normalize-space(@class),\" \"), \" section \")]",
"domain":"^https?://(?:d|[^.]+\\.g)\\.hatena\\.ne\\.jp/(?![^/?]+/archive)",
"link":"h3/a[1]",
"exampleUrl":"http://d.hatena.ne.jp/"
},
{
"name":"Amazon wishlist",
"paragraph":"//form[@name=\"editItems\"]/table/tbody",
"domain":"^http://www\\.amazon\\.(?:[^.]+\\.)?[^./]+/gp/registry/wishlist",
"link":".//a"
},
{
"name":"\u30ab\u30ca\u901f",
"paragraph":"id(\"content\")//h2 | id(\"content\")//div[contains(concat(\" \", @class, \" \"), \" entry_body \")]//span[contains(concat(\" \", @class, \" \"), \" nnn \")] | id(\"content\")//div[contains(concat(\" \", @class, \" \"), \" comment \")]//ul[contains(concat(\" \", @class, \" \"), \" suuji \")]//li",
"domain":"^http://kanasoku\\.blog82\\.fc2\\.com/blog-entry-[\\d]+\\.html",
"exampleUrl":"http://kanasoku.blog82.fc2.com/blog-entry-13208.html"
},
{
"name":"VIP Uploder",
"paragraph":"//table[@summary=\"upinfo\" or @summary=\"uplist\"]/tbody/tr[position()>1]",
"domain":"^http://(?:dat|ktkr|mup|nullpo|w(?:ktk|wwww))\\.vip2ch\\.com/",
"stripe":"1",
"height":"0",
"link":"(td[2] | td[3])/a",
"exampleUrl":"http://vip2ch.com/",
"view":"td[2]/a/text() | td[2]/text()"
},
{
"name":"tDiary",
"paragraph":"(//div[@class=\"day autopagerize_page_element\"]/h2 | //div[@class=\"day autopagerize_page_element\"]//div[contains(concat(\" \",normalize-space(@class),\" \"), \" section \")])",
"domain":"//div[@class=\"footer\"]/a[@href=\"http://www.tdiary.org/\"]"
},
{
"name":"bestgate",
"paragraph":"//tr[td[contains(concat(\" \",@class,\" \"),\" ranking \")]]",
"domain":"^http://www\\.bestgate.net/(?:product|store)\\.phtml(\\?.+)?",
"stripe":"",
"height":"",
"disable":"",
"link":"td/a",
"view":"td[contains(concat(\" \",@class,\" \"),\" name \")]/a/strong/text()"
},
{
"name":"Wikipedia\u691c\u7d22",
"paragraph":"//dl",
"domain":"^http://athlon64\\.fsij\\.org/~mikio/wikipedia/estseek\\.cgi",
"link":"dt/a[contains(@class,\"doc_title\")]",
"exampleUrl":"http://athlon64.fsij.org/~mikio/wikipedia/"
},
{
"name":"Amazon account home",
"paragraph":"//div[contains(concat(\" \", @class, \" \"), \" content \")]//div[contains(concat(\" \", @class, \" \"), \" product \")] | //div[starts-with(@id, \"rhfCell\") or starts-with(@id, \"shvlCell\")]",
"domain":"^http://www\\.amazon\\.(?:[^.]+\\.)?[^./]+/gp/yourstore/home",
"link":".//a"
},
{
"name":"Amazon search result",
"paragraph":"//div[contains(concat(\" \", normalize-space(@class), \" \"), \" result \")]",
"domain":"^http://www\\.amazon\\.(?:[^.]+\\.)?[^./]+/(?:gp/search|s/)",
"height":"0",
"link":".//div[@class=\"productTitle\"]/a",
"view":".//div[@class=\"productImage\"]/a/img | .//div[@class=\"productTitle\"]/a/text()"
},
{
"name":"Google Reader User's Shared Items",
"paragraph":"id(\"items\")/div[@class=\"item\"]",
"domain":"^https?://www\\.google\\.(?:[^.]+\\.)?[^./]+/reader/shared/",
"stripe":"1",
"link":"h2/div/a",
"exampleUrl":"http://www.google.com/reader/"
},
{
"name":"\u306f\u3066\u306a\u30c0\u30a4\u30a2\u30ea\u30fc\u30fb\u30b0\u30eb\u30fc\u30d7 \u8a18\u4e8b\u4e00\u89a7",
"focus":"//div[contains(concat(\" \",@class,\" \"),\" day \")]/form/h2/input[1]",
"paragraph":"//li[contains(concat(\" \",@class,\" \"), \" archive-section \")]",
"domain":"^https?://(?:d|[^.]+\\.g)\\.hatena\\.ne\\.jp/[^/?]+/archive",
"link":"./a[not(contains(concat(\" \", @class, \" \"), \" sectioncategory \"))]"
},
{
"name":"Yahoo!\u30b0\u30eb\u30e1 \u30af\u30c1\u30b3\u30df",
"paragraph":"id(\"main\")/div[contains(concat(\" \", @class, \" \"), \" wrpreview \")]/ul/li",
"domain":"^http://restaurant\\.gourmet\\.yahoo\\.co\\.jp/\\d+/review/",
"stripe":"true",
"link":".//h3/a",
"exampleUrl":"http://restaurant.gourmet.yahoo.co.jp/0001615461/review/",
"view":".//h3/a/text()"
},
{
"name":"coneco.net Review",
"paragraph":"//div[contains(concat(\" \",@class,\" \"), \" box01reb \")]",
"domain":"^http://www\\.coneco\\.net/[rR]eviewList/(?:cate/)?\\d+/?",
"stripe":"",
"height":"1",
"disable":"",
"link":".//div[contains(concat(\" \",@class,\" \"), \" box03reb \")]/a",
"view":".//div[contains(concat(\" \",@class,\" \"), \" box03reb \")]/a/b/text()"
},
{
"name":"Yahoo!\u30c8\u30e9\u30d9\u30eb \u65c5\u306e\u77e5\u6075\u888b\uff08\u4e00\u89a7\uff09",
"paragraph":"//div[contains(concat(\" \",@class,\" \"), \" ytrvKlgQstn \")]/dl[not(@class=\"pt02\")]",
"domain":"http://chiebukuro.travel.yahoo.co.jp/(list|search).html.*",
"link":"./dt/a",
"exampleUrl":"http://chiebukuro.travel.yahoo.co.jp/list.html"
},
{
"name":"\"\u306f\u3066\u306a\u30d5\u30a9\u30c8\u30e9\u30a4\u30d5 \u30ad\u30fc\u30ef\u30fc\u30c9\u30fb\u8272\u5225\u30fb\u65b0\u7740\"",
"paragraph":"//li[contains(concat(\" \",@class,\" \"),\" global \")]",
"domain":"http://f.hatena.ne.jp/(userlist|keyword|fotocolor)?(/mm)?",
"stripe":"1",
"link":"a",
"exampleUrl":"http://f.hatena.ne.jp/"
},
{
"name":"Yahoo!\u77e5\u6075\u888b \u691c\u7d22\u7d50\u679c",
"paragraph":"//div[contains(concat(\" \",@id,\" \"),\"yschqlist\")]/ol/li",
"domain":"^http://search.chiebukuro.yahoo.co.jp/search/search.php.*",
"stripe":"1",
"link":"div/div/h4/a",
"exampleUrl":"http://chiebukuro.yahoo.co.jp/"
},
{
"name":"gumonji \u30b3\u30df\u30e5\u30cb\u30c6\u30a3\u4e00\u89a7",
"paragraph":"id(\"list\")/tbody/tr[not(position()=1)]",
"domain":"^http://www\\.gumonji\\.net/cgi-bin/community_list\\.cgi",
"height":"23",
"link":"td/p/a",
"exampleUrl":"http://www.gumonji.net/"
},
{
"name":"\u30cb\u30b3\u30cb\u30b3\u52d5\u753b - search / tag",
"paragraph":"//div[contains(concat(\" \",@class,\" \"), \" thumb_frm \")]",
"domain":"^http://(?:de|es|tw|www)\\.nicovideo\\.jp/(?:search|tag)",
"link":".//a",
"exampleUrl":"http://www.nicovideo.jp/"
},
{
"name":"Twitter \u691c\u7d22\u30a2\u30fc\u30ab\u30a4\u30d6 - home",
"paragraph":"//form[contains(concat(\" \",@action,\" \"), \"/home/new\")]/div[last()]/p",
"domain":"^http://searcharchives\\.ssig33\\.com/(home/?(index)?)?$",
"stripe":"true",
"height":"",
"disable":"",
"link":".//a[1]",
"view":"",
"exampleUrl":"http://searcharchives.ssig33.com/home/"
},
{
"name":"NASA Earth Observatory : Image of the Day Archive",
"paragraph":"//div[@class=\"thumbnail-image\"]",
"domain":"^http://earthobservatory\\.nasa\\.gov/IOTD/archive\\.php",
"stripe":"",
"height":"",
"disable":"",
"link":"./a",
"view":""
},
{
"name":"trac",
"paragraph":"(//div[@class=\"wiki\"]//h1 | //div[@class=\"wiki\"]//h2 | //div[@class=\"wiki\"]//h3|//div[@class=\"wiki\"]//h4 | //div[@class=\"wiki\"]//h5 | //div[@class=\"wiki\"]//h6|//div[@class=\"report\"]/table[contains(@class,\"listing\")]/tbody/tr|//div[@class=\"query\"]//table[@class=\"listing tickets\"]/tbody/tr)",
"domain":"id(\"tracpowered\")[@href=\"http://trac.edgewall.org/\"]",
"link":".//a",
"exampleUrl":"http://trac.edgewall.org/"
},
{
"name":"Google Video",
"paragraph":"//div[contains(@class,\"SearchResultItem\")]",
"domain":"^http://video\\.google\\.(?:[^.]+\\.)?[^./]+/videosearch",
"stripe":"1",
"link":"table/tbody/tr/td[2]/div/a",
"exampleUrl":"http://video.google.com/"
},
{
"name":"\u30d9\u30a2\u901f - article",
"paragraph":"//div[@class=\"entry_body\"]/font[@color=\"#009900\"] | //div[@class=\"entry_block\"]/ol/li",
"domain":"^http://vipvipblogblog\\.blog119\\.fc2\\.com/blog-entry",
"exampleUrl":"http://vipvipblogblog.blog119.fc2.com/"
},
{
"name":"Yahoo!\u30c8\u30e9\u30d9\u30eb \u65c5\u306e\u77e5\u6075\u888b\uff08\u8cea\u554f\uff09",
"paragraph":"(//div[contains(concat(\" \",@class,\" \"), \" ytrvKlgMdTit02 \")] | //div[contains(concat(\" \",@class,\" \"), \" title01 \")] | //div[contains(concat(\" \",@class,\" \"), \" ytrvKlgDetailCmt \")] | //ul[contains(concat(\" \",@class,\" \"), \" ytrvKlgDetailAns \")]/li)",
"domain":"http://chiebukuro.travel.yahoo.co.jp/detail/.+\\.html.*",
"stripe":"",
"height":"",
"disable":"",
"link":"",
"view":"",
"exampleUrl":"http://chiebukuro.travel.yahoo.co.jp/detail/1219068682.html"
},
{
"name":"Acronym Finder",
"paragraph":"//center/table[2]/tbody/tr[position()>2 and last()-1>position()]",
"domain":"^http://(?:[^.]+\\.)?acronymfinder\\.com/af-query\\.asp",
"exampleUrl":"http://www.acronymfinder.com/",
"view":"td[4]/text()"
},
{
"name":"mixi - new_friend_diary|new_comment|new_bbs",
"paragraph":"id(\"bodyMainArea\")/div/ul[@class=\"entryList01\"]/li",
"domain":"^http://mixi\\.jp/new_(?:bbs|comment|friend_diary)\\.pl",
"height":"0",
"link":"./dl/dd/a",
"exampleUrl":"http://mixi.jp/"
},
{
"name":"\u4eba\u72fc\u7269\u8a9e\u3050\u305f\u56fd",
"paragraph":"//div[contains(@id,\"mestype\")]",
"domain":"^http://www3\\.marimo\\.or\\.jp/~fgmaster/sow/sow\\.cgi"
},
{
"name":"\u3055\u3055\u3084\u304b\u306a\u697d\u3057\u307f",
"paragraph":"(//div[@class=\"blogbody\"]/div/p/font/b | //div[@class=\"main\"]/dl/dt//font | //div[@class=\"mainmore\"]/dl/dt//font)",
"domain":"http://blog.livedoor.jp/sasayakana_tanoshimi/archives/",
"exampleUrl":"http://blog.livedoor.jp/sasayakana_tanoshimi/"
},
{
"name":"Find Job !",
"paragraph":"//div[contains(@class,\"search_result_list02\")]",
"domain":"^https?://www\\.find-job\\.net/fj/(new|search)\\.cgi.*",
"link":"div//strong/a",
"exampleUrl":"http://www.find-job.net/",
"view":"div//strong/a/text()"
},
{
"name":"\u9854\u6587\u5b57\u3093\u3050\u30fd(\u00b4\u30fc\uff40)\u30ce",
"paragraph":"//ul/li",
"domain":"^http://rokudemonai\\.appspot\\.com/kaomojing/himitsu/",
"stripe":"",
"height":"",
"disable":"",
"link":"a",
"view":""
},
{
"name":"Google",
"paragraph":"id(\"res\")//li[contains(@class,\"g\")]",
"domain":"^https?://www\\.(?:l\\.)?google\\.(?:[^.]+\\.)?[^./]+/",
"stripe":"1",
"link":"descendant::a[contains(concat(\" \",normalize-space(@class),\" \"),\" l \")]",
"exampleUrl":"http://www.google.com/"
},
{
"name":"powertabs.net search",
"paragraph":"//ol[@class=\"listing\"]/li",
"domain":"^http://(?:www\\.)?powertabs\\.net/search_global\\.php",
"stripe":"1",
"height":"1",
"link":"a",
"exampleUrl":"http://powertabs.net/"
},
{
"name":"Bloglines",
"domain":"^http://www\\.bloglines\\.com/(?:info/myfeed|myblog)s",
"disable":"1",
"exampleUrl":"http://www.bloglines.com/"
},
{
"name":"Google Code Search",
"paragraph":"//div[@class=\"h\"]",
"domain":"^http://www\\.google\\.(?:[^.]+\\.)?[^./]+/codesearch",
"link":"//div[@class=\"h\"]/a",
"exampleUrl":"http://www.google.com/codesearch"
},
{
"name":"\u4e2d\u592e\u5927\u5b66",
"paragraph":"//ul[@class=\"ulnewsmore\" or @class=\"uleventmore\"]/li",
"domain":"^http://www\\.chuo-u\\.ac\\.jp/chuo-u/(?:event|news)/",
"link":".//a[1]",
"exampleUrl":"http://www.chuo-u.ac.jp/",
"view":".//a[1]/text()"
},
{
"name":"NASA Earth Observatory : Image of the Day",
"paragraph":"//div[@class=\"images\"]//img[not(ancestor::div[@class=\"colorbar\"])]",
"domain":"^http://earthobservatory\\.nasa\\.gov/IOTD/view\\.php",
"link":"following::div[@class=\"image-info\"][1]//a"
},
{
"name":"\u30cb\u30b3\u30cb\u30b3\u52d5\u753b - related_tag",
"paragraph":"id(\"PAGEBODY\")//td[./a]",
"domain":"^http://(?:de|es|tw|www)\\.nicovideo\\.jp/related_tag",
"link":"a",
"exampleUrl":"http://www.nicovideo.jp/"
},
{
"name":"gumonji \u53cb\u9054\u30ea\u30b9\u30c8",
"paragraph":"id(\"friend_list\")/li[@class=\"friend\"]",
"domain":"^http://www\\.gumonji\\.net/cgi-bin/friend_list\\.cgi",
"height":"23",
"link":"a[2]",
"exampleUrl":"http://www.gumonji.net/"
},
{
"name":"gumonji \u30e1\u30c3\u30bb\u30fc\u30b8",
"paragraph":"id(\"list\")/tbody/tr[not(position()=1)]",
"domain":"^http://www\\.gumonji\\.net/cgi-bin/message_box\\.cgi",
"height":"23",
"link":"td[5]/a",
"exampleUrl":"http://www.gumonji.net/"
},
{
"name":"\u30cb\u30b3\u30cb\u30b3\u52d5\u753b",
"paragraph":"//td[./a/img] | id(\"recommend_video\")/td | //p[contains(concat(\" \", @class, \" \"), \" media_mid \")]",
"domain":"^http://(?:de|es|tw|www)\\.nicovideo\\.jp/(?=[?#]|$)",
"link":".//a",
"exampleUrl":"http://www.nicovideo.jp/"
},
{
"name":"gumonji \u65e5\u8a18",
"paragraph":"id(\"list\")/tbody/tr[not(position()=1)]",
"domain":"^http://www\\.gumonji\\.net/cgi-bin/diary_list\\.cgi",
"height":"23",
"link":"td/div[contains(@class,\"list_dtitle\")]/p/a",
"exampleUrl":"http://www.gumonji.net/"
},
{
"name":"Redmine",
"paragraph":"id(\"content\")/h2 | id(\"activity\")//dt | id(\"history\")/div",
"domain":"id(\"footer\")//a[@href=\"http://www.redmine.org/\"]",
"stripe":"",
"height":"",
"disable":"",
"link":".//a",
"view":".//a/text()",
"exampleUrl":"http://www.redmine.org/projects/redmine/activity"
},
{
"name":"gumonji \u30a2\u30eb\u30d0\u30e0\u4e00\u89a7",
"paragraph":"id(\"album_list\")/ul/li[@class=\"album1\"]",
"domain":"^http://www\\.gumonji\\.net/cgi-bin/album_list\\.cgi",
"height":"23",
"link":"div[@class=\"album_tn\"]/a",
"exampleUrl":"http://www.gumonji.net/"
},
{
"name":"",
"paragraph":"//div[@id=\"main\"]/div[@style=\"clear: both;\"]/div",
"domain":"^http://latlonglab\\.yahoo\\.co\\.jp/macro/list\\.rb",
"stripe":"",
"height":"",
"disable":"",
"link":"./div[contains(@class, \"entry_image\")]/a",
"view":""
},
{
"name":"Google Web History",
"paragraph":"//tr[starts-with(@id,\"r\") and @class=\"valign\"]",
"domain":"^https?://www\\.google\\.(?:[^.]+\\.)?[^./]+/history",
"link":".//a[starts-with(@id,\"bkmk_href_\")]",
"exampleUrl":"http://www.google.com/history"
},
{
"name":"Jottit history",
"paragraph":"id(\"content\")//tbody/tr",
"domain":"^http://(?:[^.]+\\.)?jottit\\.com/[^/?]+\\?m=history",
"link":".//a",
"exampleUrl":"http://youpy.jottit.com/grdii?m=history"
},
{
"name":"gumonji \u30d3\u30fc\u30e0\u30ea\u30b9\u30c8",
"paragraph":"//div[@class=\"frame\"]/div[@class=\"main\"]/div[@class=\"beam\"]",
"domain":"^http://www\\.gumonji\\.net/cgi-bin/beam_list\\.cgi",
"height":"23",
"link":"div[@class=\"beam_text\"]/div[@class=\"beam_url\"]/a",
"exampleUrl":"http://www.gumonji.net/"
},
{
"name":"JET SET Reccomendations",
"paragraph":"//div[contains(concat(\"\", @class, \"\"), \"recommendItemImage\")]",
"domain":"^http://www\\.jetsetrecords\\.net/jp/products/.*/.+",
"stripe":"true",
"link":"./a"
},
{
"name":"gumonji \u30be\u30fc\u30f3\u4e00\u89a7",
"paragraph":"id(\"list\")/tbody/tr[not(position()=1)]",
"domain":"^http://www\\.gumonji\\.net/cgi-bin/zone_list\\.cgi",
"height":"23",
"link":"td/a",
"exampleUrl":"http://www.gumonji.net/"
},
{
"name":"\u4efb\u5929\u5802\uff1a\u682a\u4e3b\u30fb\u6295\u8cc7\u5bb6\u5411\u3051\u60c5\u5831\uff1a\u8cc7\u6599\u96c6 - IR\u30a4\u30d9\u30f3\u30c8",
"paragraph":"id(\"contentsArea\")/table[@class=\"textBlock\"]/tbody/tr",
"domain":"^http://www\\.nintendo\\.co\\.jp/ir/library/events/",
"stripe":"",
"height":"",
"disable":"",
"link":".//a[@class=\"thickbox\"]",
"view":""
},
{
"name":"MusicBrainz / Browse edits",
"paragraph":"//table[@class=\"editfields\"]",
"domain":"^http://musicbrainz\\.org/mod/search/results\\.html",
"link":"//a[@title=\"View details of this edit\"]"
},
{
"name":"Wescript",
"paragraph":"//table[contains(concat(\" \",normalize-space(@class),\" \"),\" scripts \") or contains(concat(\" \",normalize-space(@class),\" \"),\" users \")]/tbody/tr[contains(concat(\" \",normalize-space(@class),\" \"),\" even\") or contains(concat(\" \",normalize-space(@class),\" \"),\" odd\")]",
"domain":"^http://(?:beta\\.)?wescript\\.net/(?:script|user)s",
"link":"./td[1]//a",
"exampleUrl":"http://wescript.net/"
},
{
"name":"gumonji \u8db3\u3042\u3068",
"paragraph":"id(\"shikakusanlist\")/div[@class=\"shikakusan\"]",
"domain":"^http://www\\.gumonji\\.net/cgi-bin/footprint\\.cgi",
"height":"23",
"link":"div[@class=\"footprint_ww\"]/a",
"exampleUrl":"http://www.gumonji.net/"
},
{
"name":"\u30ab\u30c8\u3086\u30fc\u5bb6\u65ad\u7d76 - index2",
"paragraph":"//span[@class=\"xfolkentry\"]/a[@class=\"taggedlink\"] | //span[@class=\"xfolkentry\"]/span[@class=\"description\"]/a",
"domain":"^http://www6\\.ocn\\.ne\\.jp/~katoyuu/index2\\.html",
"link":".",
"exampleUrl":"http://www6.ocn.ne.jp/~katoyuu/index2.html"
},
{
"name":"gumonji \u30a2\u30a4\u30c7\u30a3\u30a2\u30ea\u30b9\u30c8",
"paragraph":"id(\"list\")/tbody/tr[not(position()=1)]",
"domain":"^http://www\\.gumonji\\.net/cgi-bin/idea_list\\.cgi",
"height":"23",
"link":"td/a",
"exampleUrl":"http://www.gumonji.net/"
},
{
"name":"livedoor Reader",
"domain":"^http://reader\\.livedoor\\.com/(?:public|reader)/",
"disable":"1",
"exampleUrl":"http://reader.livedoor.com/reader/"
},
{
"name":"mozillaZine Forums (Topic)",
"paragraph":"id(\"page-body\")/div[starts-with(@class, \"post\")]",
"domain":"^http://forums\\.mozillazine\\.org/viewtopic\\.php",
"stripe":"0",
"link":".//p[@class=\"author\"]/a",
"exampleUrl":"http://forums.mozillazine.org/viewtopic.php"
},
{
"name":"\u5317\u68ee\u74e6\u7248(\u8a18\u4e8b)",
"paragraph":"//div[@class=\"mainEntryBlock\"]|//div[@class=\"mainCommentBody\"]/div[@class=\"mainCommentBody\"]",
"domain":"^http://northwood\\.blog60\\.fc2\\.com/blog-entry-",
"exampleUrl":"http://northwood.blog60.fc2.com/"
},
{
"name":"\u30ab\u30c8\u3086\u30fc\u5bb6\u65ad\u7d76 - index",
"paragraph":"//table[@bgcolor=\"#5173e6\"]//a",
"domain":"^http://www6\\.ocn\\.ne\\.jp/~katoyuu/index\\.html",
"link":".",
"exampleUrl":"http://www6.ocn.ne.jp/~katoyuu/index.html"
},
{
"name":"Youtube(search)",
"paragraph":"//div[contains(concat(\" \",@class,\" \"),\"vlcell\")]",
"domain":"http://[^.]+.youtube.com/results\\?search_query\\=",
"stripe":"1",
"link":".//div[contains(concat(\" \",@class,\" \"),\"vllongTitle\")]/a",
"exampleUrl":"http://www.youtube.com/"
},
{
"name":"Oekaki BBS.com",
"paragraph":"//center/table/tbody/tr/td/table",
"domain":"http://[^.]+.oekakibbs.com/bbs/[^.]+/oekakibbs.cgi",
"exampleUrl":"http://www.oekakibbs.com/"
},
{
"name":"gumonji \u30b3\u30df\u30e5\u30cb\u30c6\u30a3\u304a\u984c\u4e00\u89a7",
"paragraph":"id(\"list\")/tbody/tr[not(position()=1)]",
"domain":"^http://www\\.gumonji\\.net/cgi-bin/bbs_list\\.cgi",
"height":"23",
"link":"td/div[@class=\"list_dtitle\"]/a",
"exampleUrl":"http://www.gumonji.net/"
},
{
"name":"\u6687\u4eba\uff3c(\uff3eo\uff3e)\uff0f\u901f\u5831",
"paragraph":"//h2[contains(concat(\" \", @class, \" \"), \" article-title \")] | //div[contains(concat(\" \", @class, \" \"), \" article-body-inner \")]//dt | id(\"comments-list\")/ol/li",
"domain":"^http://blog\\.livedoor\\.jp/himasoku123/archives/",
"stripe":"",
"height":"",
"disable":"",
"link":"",
"view":"",
"exampleUrl":"http://blog.livedoor.jp/himasoku123/archives/51451566.html"
},
{
"name":"dannna_o Blog",
"paragraph":"//div[contains(concat(\" \",normalize-space(@class),\" \"), \" post \")]",
"domain":"^http://www\\.optimagraphics\\.org/dannna_o/blog/",
"stripe":"",
"height":"",
"disable":"",
"link":"./h2/a[@rel=\"bookmark\"]",
"view":""
},
{
"name":"uploader.jp",
"paragraph":"id(\"content\")/table/tbody/tr[position()>1]",
"domain":"^http://www\\d*\\.uploader\\.jp/(?:home|p)/[^/]+/",
"stripe":"1",
"height":"0",
"link":"td[1]/a",
"exampleUrl":"http://www.uploader.jp/",
"view":"td[1]/a/text()"
},
{
"name":"Github commit",
"paragraph":"id(\"files\")//div[contains(concat(\" \", @class, \" \"), \" meta \")]",
"domain":"^http://github\\.com/[^/]+/[^/]+/commit/[0-9a-f]+",
"link":".//a",
"exampleUrl":"http://github.com"
},
{
"name":"mixi - list_echo|recent_echo|res_echo",
"paragraph":"//div[contains(@class,\"archiveList\")]/table//tr",
"domain":"^http://mixi\\.jp/(?:list|re(?:cent|s))_echo\\.pl",
"link":"td[contains(@class,\"comment\")]/span/a",
"exampleUrl":"http://mixi.jp/",
"view":"td[contains(@class,\"comment\")]/text()"
},
{
"name":"\"@bb\"",
"paragraph":"//span[contains(concat(\" \",@class,\" \"),\" name \") or contains(concat(\" \",@class,\" \"),\" postername \")]",
"domain":"^http://[^.]+\\.atbb\\.jp/[^/]+/viewtopic\\.php.*",
"stripe":"1",
"link":"t    '",
"exampleUrl":"http://atbb.jp/"
},
{
"name":"Yahoo!\u30aa\u30fc\u30af\u30b7\u30e7\u30f3",
"paragraph":"//tr[@bgcolor=\"#eeeeee\"]/td[@align=\"left\"] | //td[contains(concat(\" \",@class,\" \"),\" pad0101 \")]",
"domain":"^http://(?:[^.]+\\.)+?auctions\\.yahoo\\.co\\.jp/",
"link":".//a | a",
"exampleUrl":"http://auctions.yahoo.co.jp/jp/"
},
{
"name":"Backlog - Revision",
"paragraph":"//div[@class=\"content\"]",
"domain":"https://(?:.+?)\\.backlog\\.jp/rev/(?:.+?)/\\d+$"
},
{
"name":"\u4eba\u72fcBBS",
"paragraph":"//div[contains(@class,\"main\")]/div[not(contains(@class,\"login_form\"))]",
"domain":"^http://ninjin[^.]*\\.x0\\.com/wolf.*/index\\.rb"
},
{
"name":"\u3075\u305f\u3070\u3061\u3083\u3093\u306d\u308b",
"paragraph":"/html/body/form[@action=\"futaba.php\"]/img[contains(@src, \"src/\")]|/html/body/form[@action=\"futaba.php\"]/a/img[contains(@src, \"thumb/\")]|/html/body/img[contains(@src, \"src/\")]|/html/body/a/img[contains(@src, \"thumb/\")]",
"domain":"^http://[^.]+\\.2chan\\.net/[^/]+/[\\da-z]+.htm$",
"height":"13",
"link":"following-sibling::a|parent::a/following-sibling::a[text()=\"\u8fd4\u4fe1\"]",
"exampleUrl":"http://www.2chan.net/"
},
{
"name":"\u30102ch\u3011\u30cb\u30e5\u30fc\u901fVIP\u30d6\u30ed\u30b0(`\uff65\u03c9\uff65\u00b4)",
"paragraph":"id(\"content\")//h3[contains(concat(\" \", @class, \" \"), \" title \")] | id(\"content\")//div[contains(concat(\" \", @class, \" \"), \" main \")]/font[@color=\"#006600\"] | id(\"content\")//ol/li/div[contains(concat(\" \", @class, \" \"), \" comments-body \")]",
"domain":"^http://blog\\.livedoor\\.jp/insidears/archives/",
"stripe":"",
"height":"",
"disable":"",
"link":"",
"view":"",
"exampleUrl":"http://blog.livedoor.jp/insidears/archives/52327921.html"
},
{
"name":"VIPPER\u306a\u4ffa\uff08\u30e9\u30a4\u30d6\u30c9\u30a2\u30d6\u30ed\u30b0\u79fb\u8ee2\u5f8c\uff09",
"paragraph":"//h2[contains(concat(\" \", @class, \" \"), \" article-title \")] | //div[contains(concat(\" \", @class, \" \"), \" article-body-inner \")]//b/font[@color=\"green\"] | id(\"comments-list\")/ol/li",
"domain":"^http://blog\\.livedoor\\.jp/news23vip/archives/",
"exampleUrl":"http://blog.livedoor.jp/news23vip/archives/2522716.html"
},
{
"name":"\u30cb\u30b3\u30cb\u30b3\u52d5\u753b - watch",
"paragraph":"id(\"WATCHHEADER flvplayer PAGEFOOTER\") | id(\"WATCHFOOTER\")/div[1]",
"domain":"^http://(?:de|es|tw|www)\\.nicovideo\\.jp/watch/",
"height":"0",
"exampleUrl":"http://www.nicovideo.jp/"
},
{
"name":"\u5317\u68ee\u74e6\u7248(\u8a18\u4e8b\u4e00\u89a7)",
"paragraph":"//div[@class=\"mainEntryBlock\"]",
"domain":"^http://northwood.blog60.fc2.com/(?!blog-entry-)",
"link":"div[@class=\"mainEntryTitle\"]//a",
"exampleUrl":"http://northwood.blog60.fc2.com/"
},
{
"name":"\u4eba\u72fc@\u6b27\u5dde",
"paragraph":"//table[contains(@class,\"vil_main\")]/tbody/tr/td/div",
"domain":"^http://euroz\\.sakura\\.ne\\.jp/wolf/index\\.rb"
},
{
"name":"\u30cb\u30b3\u30cb\u30b3\u30cb\u30e5\u30fc\u30b9 / \u30cb\u30b3\u30cb\u30b3\u30e9\u30e0",
"paragraph":"//div[contains(concat(\" \",@class,\" \"),\" article \")]",
"domain":"^http://blog\\.nicovideo\\.jp/nico(?:lumn|news)/",
"stripe":"0",
"link":".//span[contains(concat(\" \",@class,\" \"),\" article-footer-permalink \")]/a",
"exampleUrl":"http://blog.nicovideo.jp/niconews"
},
{
"name":"iPhoneBBS",
"paragraph":"id(\"contents\")/div[@class=\"res-box\"]/div[@class=\"res-box\"]",
"domain":"^http://jp\\.forum\\.appbank\\.net/thread/\\d+/",
"stripe":"",
"height":"",
"disable":"",
"link":"",
"view":""
},
{
"name":"JavaScript Reference",
"paragraph":"//img[contains(@src,\"gif\") and starts-with(@alt,\"JavaScript\")]",
"domain":"^http://(?:www\\.)?javascript-reference\\.info/",
"exampleUrl":"http://javascript-reference.info/"
},
{
"name":"Google Scholar",
"focus":"//input[contains(concat(\" \",@type,\" \"),\" text \")]",
"paragraph":"//h3[contains(concat(\" \", @class, \" \"), \" r \")]",
"domain":"^http://scholar\\.google\\.(?:[^.]+\\.)?[^./]+/",
"stripe":"1",
"link":"a",
"exampleUrl":"http://scholar.google.com/"
},
{
"name":"Flickr friends",
"paragraph":"//p[@class=\"RecentPhotos\"]",
"domain":"^http://(?:www\\.)?flickr\\.com/photos/friends/",
"link":"./a",
"exampleUrl":"http://www.flickr.com/photos/friends/"
},
{
"paragraph":"//div[contains(concat(\" \", @class, \" \"), \" entry_case \")]",
"domain":"^http://latlonglab\\.yahoo\\.co\\.jp/route/list",
"stripe":"true",
"link":"./div[contains(concat(\" \", @class, \" \"), \" entry_image \")]/a"
},
{
"name":"gumonji \u65e5\u8a18\u30b3\u30e1\u30f3\u30c8",
"paragraph":"id(\"dtitle\") | //div[@class=\"frame\"]/div[@class=\"main\"]/div[@class=\"diary\"]/div[contains(@class,\"comment_body\")]/div[contains(@class,\"diary_comment_author\")]",
"domain":"^http://www\\.gumonji\\.net/cgi-bin/diary\\.cgi",
"height":"23",
"exampleUrl":"http://www.gumonji.net/"
},
{
"name":"\u7d4c\u8def\u3001\u904b\u8cc3\u63a2\u7d22\u7d50\u679c - Yahoo!\u8def\u7dda\u60c5\u5831",
"paragraph":"//div[contains(concat(\" \", @class, \" \"), \" route-head \")]",
"domain":"^http://transit.map.yahoo.co.jp/search/result.+",
"stripe":"",
"height":"",
"disable":"",
"link":"",
"view":""
},
{
"name":"gumonji \u30a2\u30a4\u30c7\u30a3\u30a2",
"paragraph":"//div[@class=\"frame\"]/div[@class=\"main\"]/div[@class=\"diary\"]/h2 | //div[@class=\"frame\"]/div[@class=\"main\"]/div[@class=\"diary\"]/div[@class=\"comment_body\"]/div[@class=\"diary_comment_author\"]/div[@class=\"author_wrapper\"]/a/img",
"domain":"^http://www\\.gumonji\\.net/cgi-bin/idea\\.cgi",
"height":"23",
"exampleUrl":"http://www.gumonji.net/"
},
{
"name":"\u6559\u3048\u3066!goo \u691c\u7d22\u7d50\u679c",
"paragraph":"//div[@id=\"incontents\"]/table/tbody/tr/td/div[position()=3]/div[@class=\"contents\"]",
"domain":"^http://oshiete.goo.ne.jp/search_goo/result/.*",
"stripe":"1",
"link":"table/tbody/tr[1]/td[contains(concat(\" \",@class,\" \"),\"midasi\")]/a[1]",
"exampleUrl":"http://oshiete.goo.ne.jp/"
},
{
"name":"\u30e2\u30d0\u30c4\u30a4\u30c3\u30bf\u30fc",
"paragraph":"//div[contains(concat(\" \",normalize-space(@class),\" \"), \" tlGray \") or contains(concat(\" \",normalize-space(@class),\" \"), \" tlWhite \")]",
"domain":"^http://(?:www.movatwi|movatwitter)\\.jp/user/",
"link":".//a",
"exampleUrl":"http://movatwitter.jp/"
},
{
"name":"iPhoneBBS",
"paragraph":"//div[@class=\"res-box\"]",
"domain":"^http://jp\\.forum\\.appbank\\.net/thread/\\d+",
"link":"./div[@class=\"txt\"]/a"
},
{
"name":"SecondLife Forum",
"paragraph":"//div[@id=\"posts\"]/div/div/div/div/table[contains(concat(\" \",@class,\" \"),\" tborder \")]",
"domain":"^http://forums.secondlife.com/showthread.php.*",
"stripe":"1",
"exampleUrl":"http://forums.secondlife.com/"
},
{
"name":"gumonji \u30d3\u30fc\u30e0\u3059\u308b",
"paragraph":"id(\"list\")/tbody/tr[not(position()=1)]",
"domain":"^http://www\\.gumonji\\.net/cgi-bin/beam\\.cgi",
"height":"23",
"exampleUrl":"http://www.gumonji.net/"
},
{
"name":"\u75db\u3044\u30cb\u30e5\u30fc\u30b9(\u30ce\u2200`) \u30b3\u30e1\u30f3\u30c8\u306a\u3057",
"paragraph":"id(\"articlebody\")/div/div[contains(@class,\"titlebody\")] | id(\"articlebody\")/div/div[@class=\"mainmore\"]//text()[contains(self::text(),\"ID\")]/following::span",
"domain":"^http://blog\\.livedoor\\.jp/dqnplus/archives/",
"exampleUrl":"http://blog.livedoor.jp/dqnplus/"
},
{
"name":"Yahoo!\u77e5\u6075\u888b",
"paragraph":"id(\"wrapper\")/table[2] | id(\"wrapper\")/table/tbody/tr[@bgcolor=\"#eeeeee\"] | //div[contains(concat(\" \",@class,\" \"),\" Extends-details \")]",
"domain":"^http://detail\\.chiebukuro\\.yahoo\\.co\\.jp/",
"stripe":"1",
"exampleUrl":"http://chiebukuro.yahoo.co.jp/"
},
{
"name":"Google \u30ab\u30b9\u30bf\u30e0\u691c\u7d22",
"paragraph":"id(\"res\")//div[contains(@class,\"g\")]",
"domain":"^http://www\\.google\\.(?:[^.]+\\.)?[^./]+/cse",
"stripe":"1",
"link":"h2/a[contains(concat(\" \",normalize-space(@class),\" \"),\" l \")]",
"exampleUrl":"http://www.google.com/"
},
{
"name":"\u8679\u9921",
"paragraph":"//div[contains(concat(\" \",@class,\" \"),\"thread \")]",
"domain":"http://frappe\\.sakura\\.ne\\.jp/kuri/aaa.php",
"stripe":"false",
"link":"./a[contains(concat(\" \",@class,\" \"),\"thread-url \")]",
"view":"./a/div[contains(concat(\" \",@class,\" \"),\"thread-text \")]/text()"
},
{
"name":"Google Books",
"paragraph":"//div[contains(concat(\" \",normalize-space(@class),\" \"),\" boxeybrown \")] | //table[contains(concat(\" \",normalize-space(@class),\" \"),\" rsi \")]",
"domain":"^http://books\\.google\\.(?:[^.]+\\.)?[^./]+/",
"stripe":"1",
"link":".//a[img[contains(concat(\" \",normalize-space(@class),\" \"),\" thumbocover \")] or img[contains(concat(\" \",normalize-space(@class),\" \"),\" coverthumb \")]]",
"exampleUrl":"http://books.google.com/"
},
{
"name":"\u307e\u3054\u30d7\u30ed\u30b0\u30ec\u30c3\u30b7\u30d6",
"paragraph":"//div[@class=\"entry_text\"]/parent::td",
"domain":"^http://danceofeternity\\.blog76\\.fc2\\.com/",
"exampleUrl":"http://danceofeternity.blog76.fc2.com/"
},
{
"name":"\u30a4\u30df\u30d5www\u3046\u306fwwww\u304akwwww - article",
"paragraph":"//font[@color=\"green\"]/preceding-sibling::text()[1]",
"domain":"^http://imihu\\.blog30\\.fc2\\.com/blog-entry",
"exampleUrl":"http://imihu.blog30.fc2.com/"
},
{
"name":"\u30af\u30c3\u30af\u30d1\u30c3\u30c9\u3064\u304f\u308c\u307d(\u30ab\u30c6\u30b4\u30ea\u5225)",
"paragraph":"//div[contains(concat(\" \",@class,\" \"), \" tsukurepo \")]",
"domain":"^http://cookpad\\.com/category/\\d+/tsukurepo",
"stripe":"1",
"link":"div/a[contains(concat(\" \",@class,\" \"), \" recipe-title \")]",
"exampleUrl":"http://cookpad.com/category"
},
{
"name":"MyGamerCard.net (My Custom Leaderboards)",
"paragraph":"//div[contains(concat(\" \",@class,\" \"),\"row\")]",
"domain":"http://(.*)\\.mygamercard\\.net/clboard\\.php",
"link":"div[contains(concat(\" \",@class,\" \"),\"colpic\")]/a",
"exampleUrl":"http://www.mygamercard.net/"
},
{
"name":"gumonji \u30b3\u30df\u30e5\u30cb\u30c6\u30a3\u304a\u984c",
"paragraph":"id(\"dtitle\") | id(\"main\")/div[@class=\"bbs\"]/div[@class=\"comment_body\"]/div[contains(@class,\"bbs_comment_author\")]",
"domain":"^http://www\\.gumonji\\.net/cgi-bin/bbs\\.cgi",
"height":"23",
"exampleUrl":"http://www.gumonji.net/"
},
{
"name":"\u30d9\u30a2\u901f",
"paragraph":"//div[@class=\"entry_block\"]/p[@class=\"entry_day\"]/..",
"domain":"^http://vipvipblogblog\\.blog119\\.fc2\\.com/",
"link":"div[@class=\"entry_body\"]//div[@class=\"more\"]//a",
"exampleUrl":"http://vipvipblogblog.blog119.fc2.com/"
},
{
"name":"\uff12\u3061\u3083\u3093\u306d\u308b\u30ec\u30b9\u30d6\u30c3\u30af",
"paragraph":"//div[@class=\"blogbody\"]/div/font/b",
"domain":"http://blog.livedoor.jp/ressbook2ch/archives/",
"exampleUrl":"http://blog.livedoor.jp/ressbook2ch/"
},
{
"name":"tabelog_rank",
"paragraph":"id(\"column-main\")/ul[@class=\"ranking-list\"]/li",
"domain":"^http://r\\.tabelog\\.com/.+/rank/(?:\\d+/)?",
"stripe":"",
"height":"",
"disable":"",
"link":".//h3[@class=\"mname\"]//a",
"view":""
},
{
"name":"\u30102ch\u3011\u65e5\u520a\u30b9\u30ec\u30c3\u30c9\u30ac\u30a4\u30c9",
"paragraph":"//div[contains(@class,\"main\") and not(contains(@class,\"blogpeople-main\"))] | //div[contains(@class,\"mainmore\")]/div[not(@class=\"moto\")] | id(\"commentbody\")/div[contains(@class,\"commentttl\")]",
"domain":"^http://guideline\\.livedoor\\.biz/archives/",
"height":"20",
"exampleUrl":"http://guideline.livedoor.biz/"
},
{
"name":"\u7121\u984c\u306e\u30c9\u30ad\u30e5\u30e1\u30f3\u30c8",
"paragraph":"//div[@class=\"article\"]/a[text()=number(text())]",
"domain":"^http://mudainodqnment\\.blog35\\.fc2\\.com/",
"exampleUrl":"http://www.mamegyorai.co.jp/"
},
{
"name":"redhat bugzilla",
"paragraph":"//td[@id=\"comment-header\"]",
"domain":"https://bugzilla\\.redhat\\.com/show_bug.cgi",
"stripe":"0",
"exampleUrl":"http://bugzilla.redhat.com/"
},
{
"name":"YouTube playlist",
"paragraph":"//div[contains(@class,\"vDetailEntry\")]",
"domain":"^http://[^.]+\\.youtube\\.com/view_play_list",
"link":"descendant::div[contains(@class,\"title\")]/a",
"exampleUrl":"http://www.youtube.com/"
},
{
"name":"Franceradio.net",
"paragraph":"//table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table[not(position()=last())]",
"domain":"^http://www\\.franceradio\\.net/search\\.php",
"stripe":"1",
"height":"0",
"link":"tbody/tr/td[4]/a",
"exampleUrl":"http://www.franceradio.net/",
"view":"tbody/tr/td[4]/span[@class=\"adsense\"]/a/u/b/text()"
},
{
"name":"livedoor \u30ca\u30ec\u30c3\u30b8",
"paragraph":"//div[@class=\"listboxin\"]",
"domain":"^http://knowledge\\.livedoor\\.com/[^/]+/\\d",
"link":"div[@class=\"listboxtxt\"]/h3/a",
"exampleUrl":"http://knowledge.livedoor.com/",
"view":"div[@class=\"listboxtxt\"]/h3/a/text()"
},
{
"name":"VIP\u30ef\u30a4\u30c9\u30ac\u30a4\u30c9",
"paragraph":"id(\"articlebody\")//h3[contains(concat(\" \", @class, \" \"), \" title \")] | id(\"articlebody\")//div[contains(concat(\" \", @class, \" \"), \" blogbody \")]//span[@style=\"font-size: 12px;\"] | id(\"commentbody\")/div[contains(concat(\" \", @class, \" \"), \" commentttl \")]",
"domain":"^http://news4wide\\.livedoor\\.biz/archives/",
"exampleUrl":"http://news4wide.livedoor.biz/archives/1454962.html"
},
{
"name":"Tumblr followers and following",
"paragraph":"id(\"following follower\")[self::ul]/li",
"domain":"^http://www\\.tumblr\\.com/follow(?:ers|ing)",
"link":"./a",
"exampleUrl":"http://www.tumblr.com/followers"
},
{
"name":"Fastladder",
"domain":"^http://fastladder\\.com/(?:public|reader)/",
"disable":"1",
"exampleUrl":"http://fastladder.com/reader/rnhttp://fastladder.com/public/mala"
},
{
"name":"WordPress",
"paragraph":"id(\"content\")/div[contains(@class,post)]",
"domain":"//meta[starts-with(@content,\"WordPress\")]",
"link":"descendant::a[@rel=\"bookmark\"]"
},
{
"name":"\u30b9\u30c1\u30fc\u30e0\u901f\u5831\u3000\uff36\uff29\uff30",
"paragraph":"id(\"main\")//h2[contains(concat(\" \", @class, \" \"), \" article-title \")] | id(\"main\")//div[contains(concat(\" \", @class, \" \"), \" article-body-inner \")]//font[@color=\"green\"] | id(\"article-options\")/ul[contains(concat(\" \", @class, \" \"), \" comment-info \")]",
"domain":"^http://newsteam\\.livedoor\\.biz/archives/",
"stripe":"",
"height":"",
"disable":"",
"link":"",
"view":"",
"exampleUrl":"http://newsteam.livedoor.biz/archives/51495332.html"
},
{
"name":"\u30cb\u30e5\u30fc\u901f\u30af\u30aa\u30ea\u30c6\u30a3",
"paragraph":"//font[@color=\"green\"]/preceding-sibling::text()[1] | //div[@class=\"blogbody\"]/div[contains(@class,\"comments-body\")]",
"domain":"^http://news4vip\\.livedoor\\.biz/archives/",
"exampleUrl":"http://news4vip.livedoor.biz/"
},
{
"name":"\u672c\u3084\u30bf\u30a6\u30f3\u691c\u7d22",
"paragraph":"//div/div",
"domain":"http://www.honya-town.co.jp/hst/HTdispatch*",
"height":"12",
"link":"table/tbody/tr/td/strong/a",
"exampleUrl":"http://www.honya-town.co.jp/hst/HT/index.html"
},
{
"name":"Google Apps for Your Domain control panel",
"paragraph":"//tr[td]",
"domain":"^https://www\\.google\\.com/a/cpanel/[^/]+/",
"link":".//a"
},
{
"name":"Twitter \u691c\u7d22\u30a2\u30fc\u30ab\u30a4\u30d6 - view",
"paragraph":"//table[contains(concat(\" \",@class,\" \"), \"autopagerize_page_element\")]/tbody/tr",
"domain":"^http://searcharchives\\.ssig33\\.com/view/",
"stripe":"true",
"height":"",
"disable":"",
"link":".//td[last()]/a[last()]",
"view":"",
"exampleUrl":"http://searcharchives.ssig33.com/view/3919073e4060fba5639681828d2a4598"
},
{
"name":"\u30af\u30c3\u30af\u30d1\u30c3\u30c9 \u30ec\u30b7\u30d4 (\u691c\u7d22\u7d50\u679c\u30fb\u30ab\u30c6\u30b4\u30ea\u5225)",
"paragraph":"//div[contains(concat(\" \",@class,\" \"), \" recipe-preview \")]",
"domain":"^http://cookpad\\.com/(?:category/\\d|[^/])",
"stripe":"1",
"link":"div[contains(concat(\" \",@class,\" \"), \" recipe-text \")]/span[1]/a",
"exampleUrl":"http://cookpad.com/rnhttp://cookpad.com/category"
},
{
"name":"\u840c\u3048\u9023",
"paragraph":"//table[contains(@bgcolor,\"#ffffff\") and contains(@width,\"100%\")]",
"domain":"http://(xera|moepic|moepic.).moe-ren.net/.*",
"stripe":"1",
"height":"3",
"link":"tbody/tr/td[contains(@bgcolor,\"#effbeb\")]/a",
"exampleUrl":"http://moepic.dip.jp/gazo/",
"view":"tbody/tr[2]/*/*/img"
},
{
"name":"CodeRepos::Changeset",
"paragraph":"//h1 | //li[contains(concat(\" \", @class, \" \"), \" entry \")]",
"domain":"^http://coderepos\\.org/share/changeset/\\d",
"link":".//a",
"exampleUrl":"http://coderepos.org/share/changeset"
},
{
"name":"Yahoo!\u30cb\u30e5\u30fc\u30b9\u3000\u30d8\u30c3\u30c9\u30e9\u30a4\u30f3",
"paragraph":"id(\"ynDetail\") | id(\"ynRating\") | id(\"commentbody\")//li[contains(concat(\" \", @class, \" \"), \" hdTop \")]",
"domain":"^http://headlines\\.yahoo\\.co\\.jp\\/hl.+"
},
{
"name":"Urban Dictionary",
"paragraph":"//td[contains(@class,\"def_number\")]",
"domain":"^http://www\\.urbandictionary\\.com/define",
"stripe":"0",
"exampleUrl":"http://www.urbandictionary.com/"
},
{
"name":"\u4e8c\u6b21\u5143",
"paragraph":"id(\"content\")/descendant::div[contains(concat(\" \",normalize-space(@class),\" \"),\" entry-section \")]",
"domain":"^http:\\/\\/nijigen\\.straightline\\.jp\\/",
"link":"descendant::a",
"exampleUrl":"http://nijigen.straightline.jp/"
},
{
"name":"Punyu2 Munyu",
"paragraph":"/html/body/table[16]/tbody/tr/td[contains(@bgcolor,\"#ffc0cb\") and not(contains(@colspan,\"10\"))] | /html/body/table[20]/tbody/tr/td[contains(@bgcolor,\"#ffc0cb\") and not(contains(@colspan,\"10\"))]",
"domain":"^http://www\\.punyu\\.com/puny/page\\.html",
"height":"0",
"link":"a"
},
{
"name":"\u306d\u305f\u30df\u30b7\u30e5\u30e9\u30f3",
"paragraph":"//h3",
"domain":"^http://netamichelin\\.blog68\\.fc2\\.com/",
"link":"a",
"exampleUrl":"http://netamichelin.blog68.fc2.com/"
},
{
"name":"Punyu2 Munyu details",
"paragraph":"/html/body/center/table/tbody/tr[2]/td/table/tbody/tr[3]/td/table/tbody/tr/td[child::a] | /html/body/center/table/tbody/tr[2]/td/table/tbody/tr[5]/td/table/tbody/tr/td[child::a]",
"domain":"^http://www\\.punyu\\.com/puny/daily_html/",
"height":"0",
"link":"a"
},
{
"name":"Youtube(favorites)",
"paragraph":"//div[contains(concat(\" \",@class,\" \"),\"vlcell\")]",
"domain":"http://[^.]+.youtube.com/profile_favorites",
"link":".//div[contains(concat(\" \",@class,\" \"),\"vlshortTitle\")]/a",
"exampleUrl":"http://www.youtube.com/"
},
{
"name":"LibraryThing Catalog",
"paragraph":"//tr[contains(@class,\"even\") or contains(@class,\"odd\")]",
"domain":"^http://[^.]+\\.librarything\\.com/catalog",
"link":"descendant::a[1]",
"exampleUrl":"http://www.librarything.com/catalog"
},
{
"name":"\u671d\u76ee\u65b0\u805e",
"paragraph":"//table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/p/font/a[1]",
"domain":"^http://www\\.ne\\.jp/asahi/asame/shinbun/",
"link":"."
},
{
"name":"\u3072\u3089\u3081&\u9699\u9593TurboLoader",
"paragraph":"//table[contains(concat(\" \",normalize-space(@class),\" \"),\" imgw \")]",
"domain":"^http://(?:hirame|sukima)\\.vip2ch\\.com/",
"stripe":"",
"height":"",
"disable":"",
"link":".//a",
"view":""
},
{
"name":"Google Reader",
"domain":"^https?://www\\.google\\.com/reader/view/",
"disable":"1",
"exampleUrl":"http://www.google.com/reader/view/"
},
{
"name":"TOKKY.COM",
"paragraph":"//font[starts-with(text(),\"\u25a0\")]",
"domain":"^http://www\\.ac\\.auone-net\\.jp/~tokky/",
"exampleUrl":"http://www.h3.dion.ne.jp/~tokky/"
},
{
"name":"P_BLOG",
"focus":"//div[contains(@class, \"section\")]/h3",
"paragraph":"//div[contains(@class, \"section\")]/div[contains(@class, \"section\")]",
"domain":"//address/a[contains(@title, \"P_BLOG\")]"
},
{
"name":"\u30c9\u30e9\u3048\u3082",
"paragraph":"//a[substring-before(text(),\".\")>0]",
"domain":"^http://nyumen\\.hp\\.infoseek\\.co\\.jp/",
"link":".",
"exampleUrl":"http://nyumen.hp.infoseek.co.jp/"
},
{
"name":"Tumblr Archive",
"paragraph":"//a[contains(@class,\"brick\")]",
"domain":"^http://.*\\.tumblr\\.com/archive(?:/.*)?",
"link":"."
},
{
"name":"\u30d6\u30ed\u30b0\u3061\u3083\u3093\u306d\u308b - article",
"paragraph":"//font[@color=\"green\"]",
"domain":"http://blog.livedoor.jp/blog_ch/archives/",
"exampleUrl":"http://blog.livedoor.jp/blog_ch/"
},
{
"name":"e-hon",
"paragraph":"//div/table[10]/tbody/tr[position()>1 and position() mod 2 = 1]",
"domain":"^http://www\\.e-hon\\.ne\\.jp/bec/SA/List",
"stripe":"1",
"link":"td[3]/a",
"exampleUrl":"http://www.e-hon.ne.jp/"
},
{
"name":"JIRA-BBS",
"paragraph":"//li[starts-with(@id,\"post-\")]",
"domain":"http://lsl-users.jp/jira-bbs/topic.php?.*",
"stripe":"1",
"exampleUrl":"http://lsl-users.jp/jira-bbs/"
},
{
"name":"kakaku.com Review",
"paragraph":"//div[contains(concat(\" \",@class,\" \"),\" box05 \")]",
"domain":"^http://review\\.kakaku\\.com/review/.+/?",
"stripe":"",
"height":"",
"disable":"",
"link":".//span[contains(concat(\" \",@class,\" \"),\" fontV \")]/a",
"view":""
},
{
"name":"Remember The Milk",
"domain":"^http://(?:www\\.)?rememberthemilk\\.com/",
"disable":"1",
"exampleUrl":"http://www.rememberthemilk.com/"
},
{
"name":"OKWave \u30ab\u30c6\u30b4\u30ea",
"paragraph":"//div[contains(concat(\" \",@class,\" \"),\" ok_condition\")]",
"domain":"^http://okwave.jp/[^/]+/[^/]+/c[^.]+.html",
"stripe":"1",
"link":"../../td[contains(concat(\" \",@class,\" \"),\" ok_list_content \")]/a",
"exampleUrl":"http://okwave.jp/"
},
{
"name":"\u30cf\u30e0\u30b9\u30bf\u30fc\u901f\u5831 2\u308d\u3050 - article",
"paragraph":"//font[@color=\"green\"]",
"domain":"http://urasoku.blog106.fc2.com/blog-entry",
"exampleUrl":"http://urasoku.blog106.fc2.com/"
},
{
"name":"AltaVista Search Web",
"paragraph":"//div[@id=\"results\"]/a[contains(concat(\" \",@class,\" \"),\" res \")]",
"domain":"^http://www.altavista.com/web/results?.*",
"stripe":"1",
"link":"../a[contains(concat(\" \",@class,\" \"),\" res \")]",
"exampleUrl":"http://www.altavista.com/"
},
{
"name":"\u697d\u5929\u30d6\u30ed\u30b0",
"paragraph":"//h4[contains(concat(\" \",@class,\" \"),\" h4 \")]",
"domain":"^http://plaza.rakuten.co.jp/[^/]+/diary/",
"stripe":"1",
"link":".//a",
"exampleUrl":"http://plaza.rakuten.co.jp/"
},
{
"name":"@search:@nifty \u691c\u7d22\u7d50\u679c",
"paragraph":"//ol[@class=\"searchList\"]/li",
"domain":"http://search.nifty.com/websearch/search",
"stripe":"1",
"link":"h3/a",
"exampleUrl":"@nifty \u691c\u7d22\u7d50\u679c:http://search.nifty.com/websearch/"
},
{
"name":"\u7fe0\u661f\u77f3\u306e\u30ae\u30e3\u30eb\u30b2\u30fc\u30d6\u30ed\u30b0",
"paragraph":"(//div[@class=\"ently_text\"]/span/strong)",
"domain":"http://suiseisekisuisui.blog107.fc2.com/",
"exampleUrl":"http://suiseisekisuisui.blog107.fc2.com/"
},
{
"name":"Github history",
"paragraph":"id(\"commit\")/div[contains(concat(\" \", @class, \" \"), \" group \")]/div",
"domain":"^http://github\\.com/[^/]+/[^/]+/commits",
"link":".//a",
"exampleUrl":"http://github.com"
},
{
"name":"Planet Perl Iron Man",
"paragraph":"id(\"main\")/div[@class=\"entry\"]",
"domain":"^http://ironman\\.enlightenedperl\\.org/",
"stripe":"",
"height":"",
"disable":"",
"link":".//a[@class=\"entry-permalink\"]",
"view":""
},
{
"name":"Photos | tophertumblr",
"paragraph":"id(\"container\")/a/img",
"domain":"^http://omg\\.topherchris\\.com/photos/",
"stripe":"",
"height":"",
"disable":"",
"link":"..",
"view":""
},
{
"name":"Flickr photos",
"paragraph":"//h1 | id(\"DiscussPhoto\")/table/tbody/tr",
"domain":"^http://(?:www\\.)?flickr\\.com/photos/",
"height":"0",
"link":"p[contains(@class,\"Photo\")]/span/a",
"exampleUrl":"http://www.flickr.com/"
},
{
"name":"\u3068\u3089\u306e\u3042\u306a\u901a\u4fe1\u8ca9\u58f2",
"paragraph":"//td[@class=\"td_ItemBox\"]",
"domain":"^http://www\\.toranoana\\.jp/mailorder/",
"link":"./a",
"exampleUrl":"http://www.toranoana.jp/mailorder/"
},
{
"name":"AltaVista Search (Video, News)",
"paragraph":"//td[contains(concat(\" \",@class,\" \"),\" s \")]",
"domain":"^http://www.altavista.com/(video|news)/",
"stripe":"1",
"link":"a",
"exampleUrl":"http://www.altavista.com/"
},
{
"name":"Meister Online BBS",
"paragraph":"id(\"contents\")/div[contains(concat(\" \", @class, \" \"), \" message \")]//*[translate(local-name(), \"23\", \"\")=\"H\"]",
"domain":"^http://(www\\.)?meister\\.ne\\.jp/bbs/",
"stripe":"",
"height":"",
"disable":"",
"link":"",
"view":""
},
{
"paragraph":"//div[contains(@class, \"List\")][1]//div[contains(@class, \"Img\") or contains(@class, \"Content\")] | //div[@class=\"Content\"] | //div[@id=\"Blog\"]//*[@class=\"CmtBy\" or @id=\"BlogImg\"]",
"domain":"^http://(?:www\\.)?pipa\\.jp/tegaki/V.*",
"link":"a[@href]",
"exampleUrl":"http://pipa.jp/tegaki/VNewArrival.jsp"
},
{
"name":"Yahoo!\u691c\u7d22",
"paragraph":"id(\"WS2m\")/ul/li",
"domain":"^http://search\\.yahoo\\.co\\.jp/search",
"stripe":"1",
"link":"descendant::a[1]",
"exampleUrl":"http://search.yahoo.co.jp/search?p=wedata&ei=UTF-8"
},
{
"name":"F\u901fVIP(\u30fb\u03c9\u30fb)y-~",
"paragraph":"//div[@class=\"entry-kiji\"]/dl/dt/a",
"domain":"^http://fsokuvip\\.blog101\\.fc2\\.com/",
"exampleUrl":"http://fsokuvip.blog101.fc2.com/"
},
{
"name":"Userscripts.org scripts",
"paragraph":"//table[@class=\"wide forums\"]/tbody/tr[contains(@class,\"post\")]",
"domain":"^http://userscripts\\.org/scripts/show/",
"height":"0",
"exampleUrl":"http://userscripts.org/"
},
{
"name":"Flickr search",
"paragraph":"//table[@class=\"DetailResults\"]/tbody/tr",
"domain":"^http://(?:www\\.)?flickr\\.com/search/",
"link":"td[contains(@class,\"DetailPic\")]/div/span/a",
"exampleUrl":"http://www.flickr.com/"
},
{
"name":"Flickr person",
"paragraph":"//tr[@valign=\"top\"]/td/div[contains(concat(\" \",normalize-space(@class),\" \"),\" StreamView \")]",
"domain":"^http://(?:www\\.)?flickr\\.com/photos/",
"height":"30",
"link":"p[contains(@class,\"Photo\")]/span/a",
"exampleUrl":"http://www.flickr.com/photos/whitehouse/"
},
{
"name":"\u30cb\u30b3\u30cb\u30b3\u30c1\u30e3\u30f3\u30cd\u30eb\uff06\u30b3\u30df\u30e5\u30cb\u30c6\u30a3",
"paragraph":"//div[contains(concat(\" \", @class, \" \"), \" official_channel_frm \") or contains(concat(\" \", @class, \" \"), \" community_frm \") or contains(concat(\" \", @class, \" \"), \" chan_rank_frm \")] | //p[contains(concat(\" \", @class, \" \"), \" category_bg \")]",
"domain":"^http://ch\\.nicovideo\\.jp/(?=[?#]|$)",
"link":".//a",
"exampleUrl":"http://ch.nicovideo.jp/"
},
{
"name":"Yahoo!\u30d6\u30ed\u30b0\u691c\u7d22",
"paragraph":"id(\"result-main-l-in\")/ol/li",
"domain":"^http://blog-search\\.yahoo\\.co\\.jp/",
"stripe":"1",
"link":"a",
"exampleUrl":"http://search.yahoo.co.jp/"
},
{
"name":"\u30d1\u30bd\u30b3\u30f3\u904a\u622f",
"paragraph":"//*[translate(local-name(), \"234\", \"\")=\"H\"]",
"domain":"^http://pasokon-yugi\\.cool\\.ne\\.jp/",
"exampleUrl":"http://pasokon-yugi.cool.ne.jp/"
},
{
"name":"twitter\u691c\u7d22",
"paragraph":"//table//tr",
"domain":"^http://pcod\\.no-ip\\.org/yats/search",
"link":"./td[last()]/a",
"exampleUrl":"http://pcod.no-ip.org/yats/search?query=ldrize"
},
{
"name":"\u767a\u8a00\u5c0f\u753a \u30c8\u30d4\u30c3\u30af",
"paragraph":"//a[contains(@id, \"hd\")] | //h1",
"domain":"^http://komachi\\.yomiuri\\.co\\.jp/t/"
},
{
"paragraph":"//div[@class=\"entry\"]",
"domain":"^http://(?:[^.]{6}\\.)?sa\\.yona\\.la/",
"link":".//h2/a",
"exampleUrl":"http://sa.yona.la/"
},
{
"name":"",
"paragraph":"//div[@class='tweetuser']",
"domain":"^http://tps\\.lefthandle\\.net/search/",
"stripe":"false",
"height":"",
"disable":"",
"link":".//div[@class='username']/a",
"view":""
},
{
"name":"CodeRepos::Timeline",
"paragraph":"id(\"content\")//dt[@class=\"changeset\" or @class=\"wiki\"]",
"domain":"^http://coderepos\\.org/share/timeline",
"link":"a",
"exampleUrl":"http://coderepos.org/share/timeline"
},
{
"name":"livedoor \u30ca\u30ec\u30c3\u30b8 ask",
"paragraph":"id(\"content\")/div[2] | //div[contains(@class,\"listboxsubheadtitle\")]",
"domain":"^http://knowledge\\.livedoor\\.com/\\d",
"exampleUrl":"http://knowledge.livedoor.com/"
},
{
"name":"kanpoo daily page",
"paragraph":"//table[@class=\"topics\"]",
"domain":"^http://kanpoo\\.jp/(?:$|#|topic\\.p/)",
"stripe":"",
"height":"",
"disable":"",
"link":"",
"view":"",
"exampleUrl":"http://kanpoo.jp/"
},
{
"paragraph":"//p[@class=\"date\"]",
"domain":"^http://smoothfoxxx\\.livedoor\\.biz/",
"stripe":"false",
"link":"//a[child::h2]"
},
{
"name":"yahoo meme dashboard",
"paragraph":"//div[contains(@class,\"post\")]",
"domain":"^http://meme\\.yahoo\\.com/dashboard/",
"stripe":"",
"height":"",
"disable":"",
"link":"./p[@class=\"form\"]/a[2]",
"view":""
},
{
"name":"CodeRepos::BrowseSource",
"paragraph":"//tbody/tr",
"domain":"^http://coderepos\\.org/share/browser",
"link":".//a",
"exampleUrl":"http://coderepos.org/share/browser"
},
{
"name":"\u2282\u2312\u2283\u3002\u0414\u3002)\u2283\u30ab\u30b8\u901f\u2261\u2261\u2261\u2282\u2312\u3064\u309c\u0414\u309c)\u3064Full Auto - article",
"paragraph":"//div[@class=\"entry_body\"]/p/font[@color=\"green\"] | //dt[starts-with(@id,\"res\")]",
"domain":"^http://www\\.kajisoku\\.org/archives",
"exampleUrl":"http://www.kajisoku.org/"
},
{
"name":"Tokyo Toshokan",
"paragraph":"id(\"main\")//table[@class=\"listing\"]/tbody/tr/td[@class=\"desc-top\"]/ancestor::tr",
"domain":"^http://(?:www\\.)?tokyotosho\\.info/",
"link":"td[@class=\"desc-top\"]/a",
"exampleUrl":"http://tokyotosho.info/"
},
{
"name":"\u55aa\u7537\u306e\u66f8\u304d\u7559\u3081\u305f\u3044\u4e8b\u3002",
"paragraph":"id(\"contents\")/div[@class=\"entry\"]/p[not(@class)]//text()[contains(self::text(),\"ID\")]",
"domain":"http://mootoko.blog.shinobi.jp/Entry/",
"exampleUrl":"http://mootoko.blog.shinobi.jp/"
},
{
"name":"Tumblr",
"paragraph":"//*[count(child::*[.//a[@class=\"permalink\"] | .//a[child::img[@class=\"permalink\"]] | .//*[@class=\"date\"]/a | .//div[contains(concat(\" \",normalize-space(@class),\" \"),\" permalink \")]/a | .//a[contains(@title,\"permalink\")] | .//a[@class=\"fecha\"] |.//a[contains(@href,\"/post/\")]])>=4]/*[.//a[@class=\"permalink\"] | .//a[child::img[@class=\"permalink\"]] | .//*[@class=\"date\"]/a | .//div[contains(concat(\" \",normalize-space(@class),\" \"),\" permalink \")]/a | .//a[contains(@title,\"permalink\")] | .//a[@class=\"fecha\"] |.//a[contains(@href,\"/post/\")]]",
"domain":"id(\"tumblr_controls\")[self::iframe]",
"link":".//a[@class=\"permalink\"] | .//a[child::img[@class=\"permalink\"]] | .//*[@class=\"date\"]/a | .//div[contains(concat(\" \",normalize-space(@class),\" \"),\" permalink \")]/a | .//a[contains(@title,\"permalink\")] | .//a[@class=\"fecha\"] |.//a[contains(@href,\"/post/\")]",
"exampleUrl":"http://mrmt.tumblr.com/rnhttp://staff.tumblr.com/rnhttp://www.davidslog.com/rnhttp://figuremeout.tumblr.com/rnhttp://toomany.tumblr.com/rnhttp://mikirosi.tumblr.com/"
},
{
"name":"Twitter Search",
"paragraph":"id(\"results\")/descendant::li[contains(concat(\" \",normalize-space(@class),\" \"),\" result \")]",
"domain":"^http://search\\.twitter\\.com/search",
"stripe":"1",
"link":"descendant::div[contains(concat(\" \",normalize-space(@class),\" \"),\" info \")]/a[contains(concat(\" \",normalize-space(@class),\" \"),\" lit \")]",
"exampleUrl":"http://search.twitter.com/"
},
{
"name":"\u4fa1\u683c.com \u30e9\u30f3\u30ad\u30f3\u30b0",
"paragraph":"//div[contains(concat(\" \", @class, \" \"), \" elementBox \")]",
"domain":"^http://kakaku\\.com/.+/ranking_\\d+/",
"link":".//a",
"exampleUrl":"http://kakaku.com/"
},
{
"name":"Google Images",
"paragraph":"(id(\"ImgContent\")|id(\"ImgCont\"))/table/tbody/tr/td[starts-with(@id,\"tDataImage\")]",
"domain":"^http://[^.]+\\.google\\.[^/]+/images",
"stripe":"1",
"link":"a",
"exampleUrl":"http://images.google.co.jp/"
},
{
"name":"Second Life Herald",
"paragraph":"//div[@id=\"beta-inner\"]/div/h3[contains(concat(\" \",@class,\" \"),\" entry-header \")]",
"domain":"^http://foo.secondlifeherald.com/slh/",
"stripe":"1",
"link":"a",
"exampleUrl":"http://foo.secondlifeherald.com/slh/"
},
{
"name":"Github tree",
"paragraph":"id(\"browser\")/table/tbody/tr",
"domain":"^http://github\\.com/[^/]+/[^/]+/tree",
"link":".//a",
"exampleUrl":"http://github.com"
},
{
"name":"\u8c46\u9b5a\u96f7",
"paragraph":"//table[@id=\"DataGrid1\"]/tbody/tr",
"domain":"http://www.mamegyorai.co.jp/net/main/",
"link":"td/table/tbody/tr/td/a",
"exampleUrl":"http://www.mamegyorai.co.jp/"
},
{
"name":"",
"paragraph":"//div[contains(@class, \"racecase\")]",
"domain":"^http://latlonglab.yahoo.co.jp/race/",
"stripe":"",
"height":"",
"disable":"",
"link":"./div[contains(@class, \"racetitle\")]/a",
"view":"./div[contains(@class, \"racetitle\")]/a/text()"
},
{
"name":"livedoor \u30af\u30ea\u30c3\u30d7",
"paragraph":"//li[contains(concat(\" \",normalize-space(@class),\" \"),\" clip \")]",
"domain":"^http://clip\\.livedoor\\.com/clips/",
"stripe":"1",
"height":"0",
"link":"div[2]/h4/a",
"exampleUrl":"http://clip.livedoor.com/clips/",
"view":"div[2]/h4/a/text()"
},
{
"name":"\u3076\u308b\u901f-VIP",
"paragraph":"id(\"main\")//h2 | id(\"main\")//div[contains(concat(\" \", @class, \" \"), \" article-body-inner \")]//span/strong | id(\"comments-list\")//ul/li[contains(concat(\" \", @class, \" \"), \" comment-author \")]",
"domain":"^http://burusoku-vip\\.com/archives/",
"stripe":"",
"height":"",
"disable":"",
"link":"",
"view":"",
"exampleUrl":"http://burusoku-vip.com/archives/1248349.html"
},
{
"name":"\u30cb\u30b3\u30cb\u30b3\u30c1\u30e3\u30f3\u30cd\u30eb\uff06\u30b3\u30df\u30e5\u30cb\u30c6\u30a3 \u500b\u5225\u30c1\u30e3\u30f3\u30cd\u30eb",
"paragraph":"//div[contains(concat(\" \", @class, \" \"), \" g-video \")] | //td[p[contains(concat(\" \", @class, \" \"), \" g-rank \")]]/parent::tr | //table[contains(concat(\" \", @class, \" \"), \" g-thumbnailL \")]",
"domain":"^http://ch\\.nicovideo\\.jp/channel/",
"link":".//a",
"exampleUrl":"http://ch.nicovideo.jp/"
},
{
"name":"phpspot",
"paragraph":"//div[@class=\"entrybody\"]/*[position()=1] | //div[@class=\"entrybody\"]/p",
"domain":"^http://phpspot\\.org/blog/archives/",
"exampleUrl":"http://phpspot.org/blog/"
},
{
"name":"vimperator labs gitweb",
"paragraph":"( //tr[contains(concat(\" \", @class, \" \"), \" dark \") or contains(concat(\" \", @class, \" \"), \" light \")] | //div[contains(concat(\" \", @class, \" \"), \" header \")])",
"domain":"^http://vimperator\\.org/trac/gitweb",
"link":".//a",
"exampleUrl":"http://vimperator.org/trac/gitweb?p=vimperator.git;a=summary"
},
{
"name":"kichikutter",
"paragraph":"//div[@class=\"recentEntry\"]",
"domain":"^http://ki(?:chiku|kuchi)\\.oq\\.la/",
"stripe":"1",
"link":".//span/a",
"exampleUrl":"http://kichiku.oq.la/",
"view":".//div[@class=\"user\"]/p/a/img|.//span/a/text()"
},
{
"name":"CodeRepos::ViewTicket",
"paragraph":"id(\"content\")//td[@class=\"report\" or @class=\"ticket\"]",
"domain":"^http://coderepos\\.org/share/report",
"link":"a",
"exampleUrl":"http://coderepos.org/share/report"
},
{
"name":"CodeRepos::SearchResult",
"focus":"id(\"results\")",
"paragraph":"id(\"results\")//dt",
"domain":"^http://coderepos\\.org/share/search",
"link":"a",
"exampleUrl":"http://coderepos.org/share/search?q=js"
},
{
"name":"MUJI.NET \u6d3b\u52d5\u30ec\u30dd\u30fc\u30c8 \u304f\u3089\u3057\u306e\u826f\u54c1\u7814\u7a76\u6240",
"paragraph":"//div[@class=\"entry-content\"]",
"domain":"^http://www\\.muji\\.net/lab/report/",
"stripe":"",
"height":"",
"disable":"",
"link":"",
"view":""
},
{
"name":"Erohoo!",
"paragraph":"id(\"main\")/ol/li",
"domain":"^http://pulpsite\\.net/erohoo/word/",
"stripe":"1",
"link":"id(\"main\")/ol/li/div[@class=\"search-title\"]/a[@class=\"search-title-link\"]",
"exampleUrl":"http://pulpsite.net/erohoo/"
},
{
"name":"Nearch",
"paragraph":"id(\"s-main\")//table",
"domain":"http://nico\\.n-labo\\.net/video/.+",
"link":".//a[text()=\"\u518d\u751f\"]",
"exampleUrl":"http://nico.n-labo.net/"
},
{
"paragraph":"( //h3 | //li[contains(concat(\" \",@class,\" \"), \" delete-favorite-row-container \")] | //table[contains(concat(\" \",@class,\" \"), \" modified-history \")]/tbody/tr | //table[contains(concat(\" \",@class,\" \"), \" modified-history \")]/tbody/tr)",
"domain":"^http://k\\.hatena\\.ne\\.jp/[^/]+/",
"link":".//a",
"exampleUrl":"http://d.hatena.ne.jp/keyword/"
},
{
"name":"YouTube",
"paragraph":"//h1 | id(\"recent_comments\")/div[@id] | id(\"watch-main-area watch-comments-stats\")",
"domain":"^http://[^.]+\\.youtube\\.com/watch",
"height":"0",
"exampleUrl":"http://www.youtube.com/"
},
{
"name":"\u306f\u3066\u306a\u3057\u308a\u3068\u308a",
"paragraph":"//div[contains(@class,\"data\")][position()!=last()]",
"domain":"http://youkoseki.com/hatenacapping/",
"stripe":"1",
"height":"0",
"link":"p[contains(@class,\"word\")]/a[@id]",
"exampleUrl":"http://youkoseki.com/hatenacapping/"
},
{
"name":"\u50cd\u304f\u30e2\u30ce\u30cb\u30e5\u30fc\u30b9 : \u4eba\u751fVIP\u8077\u4eba\u30d6\u30ed\u30b0www",
"paragraph":"(//div[@class=\"mainEntryBase\"]/div/dl/dt)",
"domain":"http://workingnews.blog117.fc2.com/",
"exampleUrl":" \u4eba\u751fVIP\u8077\u4eba\u30d6\u30ed\u30b0www:http://workingnews.blog117.fc2.com/"
},
{
"paragraph":"//td[contains(concat(\"\", @class, \"\"), \"head\")]/a[contains(concat(\"\", @href, \"\"), \"userinfo\")]",
"domain":"^http://cakephp\\.jp/modules/newbb/",
"stripe":"true"
},
{
"name":"powertabs.net browse",
"paragraph":"//table[@class=\"browser\"]/tbody/tr",
"domain":"^http://(?:www\\.)?powertabs\\.net/",
"stripe":"1",
"height":"1",
"link":"td[1]/a",
"exampleUrl":"http://powertabs.net/"
},
{
"name":"mixi - home",
"paragraph":"//div[@class=\"contentsBody01\"]/div/dl[@class=\"contentsList01\"]/dt",
"domain":"^https?://mixi\\.jp/(?:home\\.pl|$)",
"link":"following-sibling::dd[1]/a",
"exampleUrl":"http://mixi.jp/",
"view":"following-sibling::dd[1]/a/text()"
},
{
"name":"Yahoo!Pipes Search",
"paragraph":"//li[@class=\"pipelistli\"]",
"domain":"http://pipes.yahoo.com/pipes/search",
"link":".//a[@class=\"pipelink\"]",
"exampleUrl":"http://pipes.yahoo.com/pipes/",
"view":".//a[@class=\"pipelink\"]/text()"
},
{
"name":"\u30b2\u30fc\u30e0\u30e1\u30fc\u30bf\u30fc",
"paragraph":"//div[@class=\"book\"]",
"domain":"^http://(?:www\\.)?gamemeter\\.net/",
"stripe":"1",
"link":"a",
"exampleUrl":"http://gamemeter.net"
},
{
"name":"\u30a4\u30df\u30d5www\u3046\u306fwwww\u304akwwww - top",
"paragraph":"//div[@class=\"left\"]/h3",
"domain":"^http://imihu\\.blog30\\.fc2\\.com/",
"link":"following-sibling::div[1]/a[position()=last()]",
"exampleUrl":"http://imihu.blog30.fc2.com/"
},
{
"name":"\u30cb\u30b3\u30cb\u30b3\u30c1\u30e3\u30f3\u30cd\u30eb\uff06\u30b3\u30df\u30e5\u30cb\u30c6\u30a3 \u30b3\u30df\u30e5\u30cb\u30c6\u30a3\u53c2\u52a0\u30e1\u30f3\u30d0\u30fc",
"paragraph":"//img[contains(concat(\" \", @class, \" \"), \" user_img \")]/ancestor::td[not(.//table)]",
"domain":"^http://ch\\.nicovideo\\.jp/member/",
"link":".//a[.//img]",
"exampleUrl":"http://ch.nicovideo.jp/"
},
{
"name":"Jaiku",
"paragraph":"id(\"stream\")//li[@class!=\"date\"]",
"domain":"^http://(?:[^.]+\\.)?jaiku\\.com\\/",
"link":".//h3/a",
"exampleUrl":"http://jaiku.com/"
},
{
"name":"HMV",
"paragraph":"//tr/td[@valign=\"top\"]/table/tbody/tr/td[@valign=\"top\"]/table/tbody/child::tr[position()=1 and position()=last()]",
"domain":"^http://www\\.hmv\\.co\\.jp/search/",
"stripe":"1",
"link":"td[3]/table/tbody/tr/td/span[1]/a",
"exampleUrl":"http://www.hmv.co.jp/"
},
{
"name":"\u6642\u901f\u30cb\u30b3\u30e1\u30fc\u30c8\u30eb",
"paragraph":"id(\"content\")/div",
"domain":"^http://(?:www\\.)?nicometer\\.net/",
"link":"div/h3/a[contains(@href,\"nicovideo.jp/watch\")][1]",
"exampleUrl":"http://nicometer.net/"
},
{
"name":"Twitpic - Photo",
"paragraph":"//img[@id=\"photo-display\"]",
"domain":"^http://twitpic\\.com/(?!photos/).",
"stripe":"",
"height":"",
"disable":"",
"link":"../id(\"photo-controls\")/a[contains(@href,\"full\")]",
"view":"."
},
{
"name":"AltaVista Search Music",
"paragraph":"//table[2]/tbody/tr/td/table/tbody/tr/td[contains(concat(\" \",@class,\" \"),\" s \") and position()=1]/span[text()=\"File Name\"]",
"domain":"^http://www.altavista.com/audio/.*",
"stripe":"1",
"link":"",
"exampleUrl":"http://www.altavista.com/"
},
{
"name":"\u30cb\u30b3\u30cb\u30b3\u30c1\u30e3\u30f3\u30cd\u30eb\uff06\u30b3\u30df\u30e5\u30cb\u30c6\u30a3 \u30b3\u30df\u30e5\u30cb\u30c6\u30a3\u52d5\u753b",
"paragraph":"//td/h3/ancestor::tr[not(.//table)]",
"domain":"^http://ch\\.nicovideo\\.jp/video/",
"link":".//a",
"exampleUrl":"http://ch.nicovideo.jp/"
},
{
"name":"GazoPa",
"paragraph":"//div[contains(concat(\" \",normalize-space(@class),\" \"),\" image_list \")]",
"domain":"^http://www\\.gazopa\\.com/similar",
"stripe":"true",
"height":"",
"disable":"",
"link":".//a[@title=\"View original image\"] | .//div[contains(concat(\" \",normalize-space(@class),\" \"),\" icons_section \")]//a",
"view":""
},
{
"name":"Mac\u306e\u624b\u66f8\u304d\u8aac\u660e\u66f8",
"paragraph":"//h2[@class=\"entry_title\"]",
"domain":"http://veadardiary.blog29.fc2.com/",
"link":"a",
"exampleUrl":"http://veadardiary.blog29.fc2.com/"
},
{
"name":"bugzilla.mozilla.org",
"paragraph":"//div[@class=\"bz_comment\"]",
"domain":"^https://bugzilla\\.mozilla\\.org/",
"exampleUrl":"https://bugzilla.mozilla.org/"
},
{
"name":"Jottit",
"paragraph":"id(\"content\")/descendant::*[self::h1 or self::h2 or self::h3 or self::h4 or self::h5 or self::h6]",
"domain":"^http://(?:[^.]+\\.)?jottit\\.com/",
"exampleUrl":"http://jottit.com/"
},
{
"name":"Engadget Japanese",
"focus":"id(\"sbi\")",
"paragraph":"id(\"content\")/div[@class=\"post\"]",
"domain":"^http://japanese\\.engadget\\.com/",
"link":"h2/a",
"exampleUrl":"http://japanese.engadget.com/"
},
{
"name":"www.share-amateur.com",
"paragraph":"id(\"body\")/center[./a/img]",
"domain":"^http://www\\.share-amateur\\.com/",
"link":"./a[contains(text(),\"link on this page\")]"
},
{
"name":"play:game db",
"paragraph":"//span[@class=\"jimgbold\"]/a",
"domain":"http://www.gamers-jp.com/playgame/",
"stripe":"0",
"height":"0",
"link":".",
"exampleUrl":"http://www.gamers-jp.com/playgame/db_newsa.php"
},
{
"name":"\u30a2\u30eb\u30d5\u30a1\u30eb\u30d5\u30a1\u30e2\u30b6\u30a4\u30af\uff08\u79fb\u8ee2\u5f8c\uff09",
"paragraph":"id(\"articlebody\")//div[contains(concat(\" \", @class, \" \"), \" titlebody \")] | id(\"articlebody\")//div[contains(concat(\" \", @class, \" \"), \" main \") or contains(concat(\" \", @class, \" \"), \" mainmore \")]/span[contains(concat(\" \", @class, \" \"), \" NM \")] | id(\"articlebody\")//div[contains(concat(\" \", @class, \" \"), \" commentttl \")] | id(\"articlebody\")//div[contains(concat(\" \", @class, \" \"), \" menu6 \")]/div",
"domain":"^http://alfalfalfa\\.com/archives/",
"stripe":"",
"height":"",
"disable":"",
"link":"",
"view":"",
"exampleUrl":"http://alfalfalfa.com/archives/388957.html"
},
{
"name":"CPAN Search",
"paragraph":"//h2[@class=\"sr\"]",
"domain":"^http://search\\.cpan\\.org/search",
"stripe":"1",
"link":"a",
"exampleUrl":"http://search.cpan.org/"
},
{
"name":"XPathGraph",
"paragraph":"id(\"body\")//ul/li[@class=\"graph\"]",
"domain":"^http://xpath\\.kayac\\.com/recent",
"link":"./h2/a",
"exampleUrl":"http://xpath.kayac.com/"
},
{
"name":"\u5897\u7530\u306b\u3083\u3093\u306d\u308b\u03b2",
"paragraph":"/descendant::span[contains(concat(\" \", @class, \" \"), \" main \")]|/descendant::div[contains(concat(\" \", @class, \" \"), \" commentttl \")]",
"domain":"^http://masuda\\.livedoor\\.biz/.*"
},
{
"name":"Twitter\u691c\u7d22",
"paragraph":"//table[@class=\"list\"]/tbody/tr",
"domain":"^http://twitter\\.1x1\\.jp/search/",
"stripe":"1",
"height":"0",
"link":"td[5]/a",
"exampleUrl":"http://twitter.1x1.jp/search/"
},
{
"name":"Tumblr iPhone",
"paragraph":"id(\"posts\")/li[contains(concat(\" \",normalize-space(@class),\" \"),\" post \") and not(contains(concat(\" \",normalize-space(@class),\" \"),\" controls \"))]",
"domain":"^http://www\\.tumblr\\.com/iphone",
"link":".//a[contains(concat(\" \",normalize-space(@class),\" \"), \" permalink \")]",
"exampleUrl":"http://www.tumblr.com/iphone"
},
{
"name":"@nifty \u30af\u30ea\u30c3\u30d7",
"focus":"id(\"tagname\")",
"paragraph":"//*[contains(concat(\" \",normalize-space(@class),\" \"), \" xfolkentry \")]",
"domain":"^http://clip\\.nifty\\.com/users/",
"link":".//a[contains(concat(\" \",normalize-space(@class),\" \"), \" taggedlink \")]",
"exampleUrl":"http://clip.nifty.com/",
"view":".//*[contains(concat(\" \",normalize-space(@class),\" \"), \" description \")]//text()"
},
{
"name":"\u4eba\u529b\u691c\u7d22\u306f\u3066\u306a \u8cea\u554f\u4e00\u89a7",
"paragraph":"//td[@class=\"questioncell\"]",
"domain":"^http://q\\.hatena\\.ne\\.jp/list",
"link":"a",
"exampleUrl":"http://q.hatena.ne.jp/list"
},
{
"name":"\u30b3\u30d4\u30da\u904b\u52d5\u4f1a",
"paragraph":"//div[@class=\"entry\"]",
"domain":"^http://copipe\\.cureblack\\.com/",
"stripe":"",
"height":"",
"disable":"",
"link":"ul[@class=\"links\"]/li/a[1]",
"view":""
},
{
"name":"Tumblr photos",
"paragraph":"id(\"container\")//img[@class=\"thumbnail\"]",
"domain":"^http://www\\.tumblr\\.com/photos",
"link":"parent::a",
"exampleUrl":"http://www.tumblr.com/photos/"
},
{
"name":"mixi - diary",
"paragraph":"id(\"bodyMainAreaMain\")/div[contains(concat(\" \",normalize-space(@class),\" \"),\" viewDiaryBox \")] | id(\"diaryComment\")/div[contains(concat(\" \",normalize-space(@class),\" \"),\" diaryMainArea02 \")]/div",
"domain":"^http://mixi\\.jp/view_diary\\.pl",
"height":"0",
"exampleUrl":"http://mixi.jp/"
},
{
"name":"google pdf viewer",
"paragraph":"id(\"content-pane\")//div[contains(@class,\"page-element\")]",
"domain":"^http://docs\\.google\\.com/gview",
"link":"./div/img[last()]"
},
{
"name":"\u30af\u30c3\u30af\u30d1\u30c3\u30c9\u3064\u304f\u308c\u307d(\u30ec\u30b7\u30d4\u5225)",
"paragraph":"//div[contains(concat(\" \",@class,\" \"), \" tsukurepo \")]",
"domain":"^http://cookpad\\.com/recipe/\\d+",
"stripe":"1",
"link":"div/p[contains(concat(\" \",@class,\" \"), \" tsukurepo-author \")]/a",
"exampleUrl":"http://cookpad.com/recipe"
},
{
"name":"\u306f\u3066\u306a\u691c\u7d22\uff08Hatena Search\uff09",
"paragraph":"//div[contains(concat(\" \",@class,\" \"),\" hatena-search-result \")]/div",
"domain":"http://search\\.hatena\\.ne\\.jp/",
"stripe":"1",
"link":"descendant::a[contains(concat(\" \",@class,\" \"),\" item-search \")]",
"exampleUrl":"http://search.hatena.ne.jp/"
},
{
"name":"\u30a2\u30eb\u30d5\u30a1\u30eb\u30d5\u30a1\u30e2\u30b6\u30a4\u30af",
"paragraph":"/descendant::div[contains(concat(\" \", @class, \" \"), \" main \") or contains(concat(\" \", @class, \" \"), \" mainmore \")]/span[contains(concat(\" \", @class, \" \"), \" NM \")] | //descendant::div[contains(concat(\" \", @class, \" \"), \" commentttl \")]",
"domain":"^http://alfalfa\\.livedoor\\.biz/",
"link":"./following-sibling::div[contains(concat(\" \", @class, \" \"), \" emore \")]/a[contains(concat(\" \", @class, \" \"), \" continues \")]",
"exampleUrl":"http://alfalfa.livedoor.biz/"
},
{
"name":"\u30cb\u30b3\u30cb\u30b3VIP2ch",
"paragraph":"//div[@class=\"entry_text\"]/dl/dt",
"domain":"http://nicovip2ch.blog44.fc2.com/",
"exampleUrl":"http://nicovip2ch.blog44.fc2.com/"
},
{
"name":"\u30d4\u30a2\u30d7\u30ed\u3000\u691c\u7d22\u7d50\u679c",
"paragraph":"id(\"form_content_list\")//div[contains(concat(\" \",@class,\" \"),\" thumbox \")]",
"domain":"^http://piapro.jp/content_list/.+",
"stripe":"1",
"link":"a"
},
{
"name":"VIPPER\u306a\u4ffa",
"paragraph":"//div[@class=\"entry_body\"]//text()[contains(self::text(),\"\u540d\u524d\uff1a\")]",
"domain":"http://news23vip.blog109.fc2.com/",
"height":"20",
"exampleUrl":"http://news23vip.blog109.fc2.com/"
},
{
"name":"Juno Download",
"paragraph":"//td[@class=\"productcover\" or @class=\"track_cover\"]",
"domain":"^http://www\\.junodownload\\.com/",
"link":"a[last()]"
},
{
"name":"Onlife(hospital books)",
"paragraph":"//div[@id=\"tobyobon-top\"]/ul/li",
"domain":"http://onlife\\.ne\\.jp/tobyobon/",
"link":"//div[@id=\"tobyobon-top\"]/ul/li//a",
"exampleUrl":"http://onlife.ne.jp/tobyoki/"
},
{
"paragraph":"//a[starts-with(@href,\"member_illust.php?mode=medium&illust_id\")]/img[@border=\"0\"]",
"domain":"^http://www\\.pixiv\\.net/ranking",
"stripe":"0",
"link":"..",
"exampleUrl":"http://www.pixiv.net/"
},
{
"name":"\u30cb\u30b3\u30cb\u30b3\u30c1\u30e3\u30f3\u30cd\u30eb\uff06\u30b3\u30df\u30e5\u30cb\u30c6\u30a3 \u30ab\u30c6\u30b4\u30ea\u5225\u4e00\u89a7",
"paragraph":"//div[contains(concat(\" \", @class, \" \"), \" number_menu \")]",
"domain":"^http://ch\\.nicovideo\\.jp/menu/",
"link":".//a",
"exampleUrl":"http://ch.nicovideo.jp/"
},
{
"name":"Google Holiday Logos",
"paragraph":"//dl[contains(concat(\" \",normalize-space(@class),\" \"), \" doodles \")]/dd",
"domain":"^http://www\\.google\\.com/logos/",
"stripe":"",
"height":"",
"disable":"",
"link":"",
"view":""
},
{
"name":"Pixort",
"paragraph":"//div[@class=\"illust\"]/ul/li",
"domain":"^http:\\/\\/www\\.pixort\\.net\\/",
"link":".//a[1]",
"exampleUrl":"http://www.pixort.net/index.php?to=next&word=%E3%83%AA%E3%83%AA%E3%82%AB%E3%83%AB%E3%81%AA%E3%81%AE%E3%81%AF"
},
{
"name":"\u82f1\u8f9e\u90ce on the Web",
"paragraph":"//span[contains(@class,\"midashi\")]/..",
"domain":"^http://eow\\.alc\\.co\\.jp/[^/]",
"stripe":"1",
"height":"5"
},
{
"name":"Onlife(hospital diaries)",
"paragraph":"//div[@id=\"tobyoki-top\"]/ul/li",
"domain":"http://onlife\\.ne\\.jp/tobyoki/",
"link":"//div[@id=\"tobyoki-top\"]/ul/li/a",
"exampleUrl":"http://onlife.ne.jp/tobyoki/"
},
{
"name":"redhat manual",
"paragraph":"(//h6 | //h5 | //h4 | //h3 | //h2 | //h1)",
"domain":"^http://www\\.redhat\\.com/docs/",
"exampleUrl":"http://www.redhat.com/docs/manuals/"
},
{
"name":"Yahoo!\u30d6\u30c3\u30af\u30de\u30fc\u30af",
"paragraph":"id(\"ybmmain\")//div[contains(concat(\" \", @class, \" \"), \" saveitem \")]",
"domain":"^http://bookmarks.yahoo.co.jp/.+",
"stripe":"",
"height":"",
"disable":"",
"link":".//h4/a",
"view":".//h4/a/text()",
"exampleUrl":"http://bookmarks.yahoo.co.jp/all"
},
{
"name":"Feecle",
"paragraph":"//dl[@class=\"post\"]",
"domain":"http://www\\.feecle\\.jp/blog/.+",
"link":".//li[@class=\"date\"]/a",
"exampleUrl":"http://www.feecle.jp/blog/"
},
{
"name":"\uff12\u3061\u3083\u3093\u306d\u308b \u30b3\u30d4\u30da",
"paragraph":"//td[@id=\"center_contents\"]/span/strong",
"domain":"http://2chkopipe.blog24.fc2.com/",
"exampleUrl":"http://2chkopipe.blog24.fc2.com/"
},
{
"name":"clipp",
"paragraph":"//div[contains(concat(\" \",normalize-space(@class),\" \"), \" item \")]",
"domain":"^http://(?:[^.]+\\.)?clipp\\.in/",
"link":".//a[contains(text(), \"\u56fa\u5b9a\u30ea\u30f3\u30af\")]",
"exampleUrl":"http://clipp.in/"
},
{
"name":"AMO",
"paragraph":"//h2[contains(concat(\" \",normalize-space(@class),\" \"),\" addonname \")]",
"domain":"^https://addons\\.mozilla\\.org/",
"link":"a",
"exampleUrl":"https://addons.mozilla.org/"
},
{
"name":"\u307f\u3093\u3057\u3085\u3046 ES",
"paragraph":"id(\"es\")/font/strong",
"domain":"^http://www.nikki.ne.jp/es/\\d+/",
"stripe":"1",
"exampleUrl":"http://www.nikki.ne.jp/es/"
},
{
"name":"So-net blog",
"paragraph":"//h2[@class=\"articles-title\"] | //div[@class=\"each-comment\"]",
"domain":"^http://blog\\.so-net\\.ne\\.jp/",
"link":"a",
"exampleUrl":"http://blog.so-net.ne.jp/"
},
{
"name":"\u30cf\u30e0\u30b9\u30bf\u30fc\u901f\u5831\uff08\u79fb\u8ee2\u5f8c\uff09",
"paragraph":"//h2[contains(concat(\" \", @class, \" \"), \" article-title \")] | //div[contains(concat(\" \", @class, \" \"), \" article-body-inner \")]//font[@color=\"green\"] | id(\"comments-list\")/ol/li",
"domain":"^http://hamusoku\\.com/archives/",
"stripe":"",
"height":"",
"disable":"",
"link":"",
"view":"",
"exampleUrl":"http://hamusoku.com/archives/2877806.html"
},
{
"name":"\u30b5\u30d0\u30a4\u30d6SNS",
"paragraph":"//td[@class=\"bg_05\"]/div[@class=\"padding_s\"]",
"domain":"^http://yonige\\.so-netsns\\.jp/",
"stripe":"0",
"link":"../..//div[@class=\"padding_s\"]/a",
"exampleUrl":"http://yonige.so-netsns.jp/"
},
{
"name":"\u3076\u3053\u3081\u3059\u305f\u30fc",
"paragraph":"//div[@class=\"commententry\"]",
"domain":"http://bcmstar\\.ashitano\\.in/*",
"link":"div[@class=\"post\"]/a[2]",
"exampleUrl":"http://bcmstar.ashitano.in/"
},
{
"name":"\u6559\u3048\u3066\uff01goo",
"paragraph":"id(\"ok_main\")/table[contains(@class, \"ok_question\") or contains(@class, \"ok_answer\")]",
"domain":"^http://oshiete\\.goo\\.ne\\.jp/",
"exampleUrl":"http://oshiete.goo.ne.jp/"
},
{
"name":"Posterous",
"paragraph":"//article[@class=\"post clearfix\"]",
"domain":"^http://[^.]+\\.posterous\\.com/",
"link":".//a[contains(text(), \"Comments\")]",
"exampleUrl":"http://garry.posterous.com/"
},
{
"name":"\u3069\u3063\u3068\u3046p\u308d\u3060.org",
"paragraph":"//div/font/table/tbody/tr[position()>1]",
"domain":"^http://(?:www\\.)?dotup\\.org/",
"stripe":"1",
"height":"0",
"link":"td[2]/a",
"exampleUrl":"http://www.dotup.org/"
},
{
"name":"Onlife(members)",
"paragraph":"//div[@class=\"member-list\"]/div[@class=\"member-list-left\"]",
"domain":"http://onlife\\.ne\\.jp/member/",
"link":"//div[@class=\"member-list\"]/div[@class=\"member-list-left\"]/a",
"exampleUrl":"http://onlife.ne.jp/member/"
},
{
"name":"Wassr\u691c\u7d22",
"paragraph":"//table/tbody/tr/td[@class=\"photo\"]/a/img",
"domain":"^http://labs\\.ceek\\.jp/wassr/",
"stripe":"1",
"link":"../../../td[@class=\"postdate\"]/a",
"exampleUrl":"http://labs.ceek.jp/wassr/"
},
{
"name":"\u30cf\u30e0\u30b9\u30bf\u30fc\u901f\u5831 2\u308d\u3050",
"paragraph":"//div[contains(@class,\"EntryTitle\")]",
"domain":"http://urasoku.blog106.fc2.com/",
"link":"a",
"exampleUrl":"http://urasoku.blog106.fc2.com/"
},
{
"name":"\u30ef\u30e9\u30ce\u30fc\u30c8",
"paragraph":"//div[@class=\"entry-body\"]/text()[contains(self::text(), \"\u540d\u524d\uff1a\")]",
"domain":"http://waranote.blog76.fc2.com/",
"exampleUrl":"http://waranote.blog76.fc2.com/"
},
{
"name":"\u6559\u3048\u3066!goo - \u8cea\u554f&\u56de\u7b54\u4e00\u89a7",
"paragraph":"//div[@id=\"ok_main\"]/table[@class=\"ok_list\"]/tbody/tr/td[@class=\"ok_list_state\"]/div",
"domain":"^http://oshiete[^.]+.goo.ne.jp/",
"stripe":"1",
"link":"../../td[@class=\"ok_list_content\"]/a",
"exampleUrl":"http://oshiete.goo.ne.jp/"
},
{
"name":"mixi - bbs",
"paragraph":"id(\"bodyMainArea bbsComment\")/dl/dt",
"domain":"^http://mixi\\.jp/view_bbs\\.pl",
"height":"0",
"exampleUrl":"http://mixi.jp/"
},
{
"name":"Blogger",
"paragraph":"//h3[@class=\"post-title\"]",
"domain":"^http://[^.]+\\.blogspot\\.com/",
"stripe":"0",
"link":"a",
"exampleUrl":"http://www.blogspot.com/"
},
{
"name":"NAVER pick",
"paragraph":"//div[@class=\"section\"]",
"domain":"^http://(?:pick\\.)?naver\\.jp/",
"link":".//p[@class=\"permalink\"]/a",
"exampleUrl":"http://naver.jp/otsunernhttp://pick.naver.jp/otsune"
},
{
"name":"\u7121\u9650\u30b7\u30a4\u30bf\u30b1",
"paragraph":"(//div[@class=\"entry_title\"] | //div[@class=\"entry_body\"]/font/b | //div[@class=\"comtitle\"])",
"domain":"http://kuratika.blog25.fc2.com/",
"link":"a[2]",
"exampleUrl":"http://kuratika.blog25.fc2.com/"
},
{
"name":"i use this",
"focus":"id(\"searchinput\")",
"paragraph":"//div[@class=\"individualapps\" or @class=\"comment\"] | //table[@class=\"list\"]",
"domain":"^http://[^.]+\\.iusethis\\.com/",
"link":".//div[@class=\"appcontent\"]/h2/a | .//div[@class=\"commenthead\"]/h4/a[2] | .//div[@class=\"apphide\"]/span/a",
"exampleUrl":"http://osx.iusethis.com/"
},
{
"name":"Instapaper",
"paragraph":"id(\"content\")//div[contains(concat(\" \",normalize-space(@class),\" \"),\" tableViewCell \")]",
"domain":"^http://www\\.instapaper\\.com/",
"stripe":"1",
"link":".//a[contains(concat(\" \",normalize-space(@class),\" \"),\" tableViewCellTitleLink \")]",
"exampleUrl":"http://www.instapaper.com/"
},
{
"name":"Bing",
"paragraph":"id(\"results\")/ul/li",
"domain":"^http://www\\.bing\\.com/search",
"stripe":"true",
"height":"",
"disable":"",
"link":"descendant::h3/a",
"view":""
},
{
"name":"\u304a\u3044\u306c\u307e\u65e5\u5831",
"paragraph":"//div[@class=\"post\"]/h2",
"domain":"http://tech.lampetty.net/tech/",
"link":"a",
"exampleUrl":"http://tech.lampetty.net/tech/",
"view":"a/text()"
},
{
"name":"Mozshot",
"paragraph":"//div[contains(@class,\"item\")]",
"domain":"^http://mozshot\\.nemui\\.org/",
"stripe":"0",
"height":"3",
"link":"a[last()]",
"exampleUrl":"http://mozshot.nemui.org/"
},
{
"name":"\u30cb\u30b3\u30cb\u30b3\u52d5\u753b\u958b\u767a\u8005\u30d6\u30ed\u30b0",
"paragraph":"//div[contains(concat(\" \",@class,\" \"),\" entry \")]",
"domain":"^http://blog\\.nicovideo\\.jp/",
"stripe":"0",
"link":"div[@style]/p/a[1]",
"exampleUrl":"http://blog.nicovideo.jp/"
},
{
"name":"OKWave",
"paragraph":"//table[contains(concat(\" \",@class,\" \"),\" ok_\")]",
"domain":"^http://okwave.jp/qa[^.]+.html",
"stripe":"1",
"exampleUrl":"http://okwave.jp/"
},
{
"name":"\"\u306f\u3066\u306a\u30d5\u30a9\u30c8\u30e9\u30a4\u30d5 \u500b\u5225\u30a4\u30e1\u30fc\u30b8\"",
"paragraph":"//div[contains(concat(\" \",@class,\" \"),\" foto-body \")]",
"domain":"http://f.hatena.ne.jp/[^/]+/.+",
"stripe":"1",
"link":"",
"exampleUrl":"http://f.hatena.ne.jp/"
},
{
"name":"\"SecondLife Web-Search\"",
"paragraph":"//div[contains(concat(\" \",@class,\" \"),\" result \")]",
"domain":"^http://search.secondlife.com/",
"stripe":"1",
"link":"h3/a",
"exampleUrl":"http://search.secondlife.com/"
},
{
"name":"Twitpic - Photos",
"paragraph":"//div[contains(concat(\" \", @class, \" \"), \" profile-photo \")]",
"domain":"^http://twitpic\\.com/photos/.",
"stripe":"",
"height":"",
"disable":"",
"link":"./div[contains(concat(\" \", @class, \" \"), \" profile-photo-img \")]/a",
"view":"",
"exampleUrl":"http://twitpic.com/photos/noaheverett"
},
{
"name":"Posterous My Subscriptions",
"paragraph":"//div[contains(concat(\" \",normalize-space(@class),\" \"), \" articlePost \")]",
"domain":"^http://posterous\\.com/reader",
"link":".//h2[contains(concat(\" \",normalize-space(@class),\" \"), \" titlelink \")]/a",
"exampleUrl":"http://posterous.com/reader"
},
{
"name":"Stack Stock Books",
"paragraph":"//div[@class=\"book\"]",
"domain":"^http://stack\\.nayutaya\\.jp/",
"link":".//div[@class=\"title\"]/a",
"exampleUrl":"http://stack.nayutaya.jp/"
},
{
"name":"\"mixi Engineer's Blog\"",
"paragraph":"//div[contains(@class,\"post\")]",
"domain":"^http://alpha.mixi.co.jp/blog/",
"link":"div/h2/a",
"exampleUrl":"http://alpha.mixi.co.jp/blog/",
"view":"div/h2/a/text()"
},
{
"name":"CiteULike",
"paragraph":"//div[contains(@class,\"list\")]/li",
"domain":"^http://www\\.citeulike\\.org/",
"link":"div/a[contains(@class,\"title\")]",
"exampleUrl":"http://www.citeulike.org/"
},
{
"name":"Gmail",
"domain":"^https?://mail\\.google\\.com/",
"disable":"1",
"exampleUrl":"http://mail.google.com/"
},
{
"name":"youkoseki.com/diary",
"paragraph":"//div[contains(concat(\" \",normalize-space(@class),\" \"), \" diary_img \") or contains(concat(\" \",normalize-space(@class),\" \"), \" diary_text \")]",
"domain":"^http://youkoseki\\.com/diary/",
"link":".//a[@id]"
},
{
"name":"Mitter tag",
"paragraph":"//ul[contains(concat(\" \", @class, \" \"), \" logs \")]/li",
"domain":"^http://mitter\\.jp/[^/]+/tag/",
"link":".//a",
"exampleUrl":"http://mitter.jp/"
},
{
"name":"W3C Semantic Web Activity News",
"paragraph":"//div[@class=\"bPosts\"]/div[contains(concat(\" \",normalize-space(@class),\" \"),\"bPost\")]",
"domain":"^http://www\\.w3\\.org/blog/SW",
"link":"div[@class=\"bSmallPrint\"]/a"
},
{
"name":"Togetter",
"paragraph":"//div[@class=\"list_box\"]",
"domain":"^http://togetter\\.com/li/\\d+",
"stripe":"true",
"height":"",
"disable":"",
"link":"./div[@class=\"list_body\"]/h5/a",
"view":""
},
{
"name":"",
"paragraph":"//div[contains(@class, \"review-box\")]",
"domain":"^http://www.castleofpagan.com/",
"stripe":"",
"height":"",
"disable":"",
"link":"",
"view":""
},
{
"name":"mediajam",
"paragraph":"id(\"sgmtMain\")/ul/li",
"domain":"^http://mediajam\\.info/topic/",
"stripe":"1",
"link":"p[contains(@class,\"newsInfo\")]/a",
"exampleUrl":"http://mediajam.info/",
"view":"h3/a/text()"
},
{
"name":"Seesaa \u30d6\u30ed\u30b0",
"paragraph":"//h3[contains(concat(\" \",@class,\" \"),\" title \")]",
"domain":"^http://[^.]+\\.seesaa\\.net/",
"stripe":"1",
"link":"a",
"exampleUrl":"http://blog.seesaa.jp/"
},
{
"name":"Danbooru",
"paragraph":"//span[contains(concat(\" \",normalize-space(@class),\" \"),\"thumb\")]",
"domain":"http://[^\\.]+.donmai.us/post",
"link":"a",
"exampleUrl":"http://miezaru.donmai.us/",
"view":"a/img"
},
{
"name":"BoardGameGeek for Games",
"paragraph":"//table[@class=\"gamebrowser_table\"]/tbody/tr/td[3]",
"domain":"http://www.boardgamegeek.com/",
"stripe":"0",
"height":"40",
"link":"a",
"exampleUrl":"http://www.boardgamegeek.com/browser.php?itemtype=game&sortby=rank"
},
{
"name":"goo\u30db\u30fc\u30e0",
"paragraph":"//div[contains(@class,\"unit\")]//td[contains(@class,\"d\")]",
"domain":"^http://home\\.goo\\.ne\\.jp/",
"link":"//div[contains(@class,\"unit\")]//td[contains(@class,\"t\")]/a",
"exampleUrl":"http://home.goo.ne.jp/"
},
{
"name":"MixClips",
"paragraph":"//div[@class=\"bookmark\"]",
"domain":"^http://www\\.mixclips\\.org/",
"stripe":"1",
"height":"0",
"link":"div[@id=\"url-box\"]/div[contains(@class,\"title\")]/a",
"exampleUrl":"http://www.mixclips.org/",
"view":"div[@id=\"url-box\"]/div[contains(@class,\"title\")]/a/text()"
},
{
"name":"\u4eba\u529b\u691c\u7d22\u306f\u3066\u306a",
"paragraph":"//h3",
"domain":"^http://q\\.hatena\\.ne\\.jp/",
"link":"span/a",
"exampleUrl":"http://q.hatena.ne.jp/"
},
{
"name":"\u2282\u2312\u2283\u3002\u0414\u3002)\u2283\u30ab\u30b8\u901f\u2261\u2261\u2261\u2282\u2312\u3064\u309c\u0414\u309c)\u3064Full Auto",
"paragraph":"//div[contains(@class,\"fullbody\")]",
"domain":"^http://www\\.kajisoku\\.org/",
"link":"descendant::a[contains(text(),\"\u7d9a\u304d\")]",
"exampleUrl":"http://www.kajisoku.org/"
},
{
"name":"All things CakePHP :: The Cookbook",
"paragraph":"//div[contains(concat(\" \",@class,\" \"),\"nodes\")]/h2 | //div[contains(concat(\" \",@class,\" \"),\"nodes\")]/h3",
"domain":"^http://book\\.cakephp\\.org/",
"stripe":"false"
},
{
"name":"ALPSLAB stamp",
"paragraph":"//div[@class=\"contents\"]/table",
"domain":"^http://stamp\\.alpslab\\.jp/",
"link":"descendant::a[contains(concat(\" \",normalize-space(@class),\" \"),\"title\")]",
"exampleUrl":"http://stamp.alpslab.jp/"
},
{
"name":"bbs2chreader",
"paragraph":"//dl[@class=\"resContainer\"] | //dl[@class=\"resContainer resNew\"]",
"domain":"http://127.0.0.1:8823/thread/"
},
{
"name":"Muxtape",
"paragraph":"//li[contains(concat(\" \",normalize-space(@class),\" \"),\" stripe \")]",
"domain":"^ttp://[^.]+\\.muxtape\\.com/",
"exampleUrl":"http://www.muxtape.com/"
},
{
"name":"\u80ce\u754c\u4e3b",
"paragraph":"//h2/a/img",
"domain":"http://www\\.taikaisyu\\.com/",
"stripe":"",
"height":"",
"disable":"",
"link":"..",
"view":""
},
{
"name":"\u306f\u3066\u306a\u30d6\u30c3\u30af\u30de\u30fc\u30af",
"paragraph":"//ul[contains(concat(\" \", @class, \" \"), \" hotentry \") or contains(concat(\" \", @class, \" \"), \" newhotentry \") or contains(concat(\" \", @class, \" \"), \" hotvideo \") or contains(concat(\" \", @class, \" \"), \" hotasin \") or contains(concat(\" \", @class, \" \"), \" bookmarked_user \")]/li",
"domain":"^http://b\\.hatena\\.ne\\.jp/",
"height":"23",
"link":".//a",
"exampleUrl":"http://b.hatena.ne.jp"
},
{
"name":"\"Second Life Issues\"",
"paragraph":"//tr[starts-with(@id,\"issuerow\")]",
"domain":"^http://jira.secondlife.com/",
"stripe":"1",
"link":"td[contains(concat(\" \",@class,\" \"),\" nav issuekey \")]/a",
"exampleUrl":"http://jira.secondlife.com/"
},
{
"name":"minkch.com",
"paragraph":"//img[@class=\"pict\"]",
"domain":"http://minkch.com/archives/*",
"stripe":"",
"height":"",
"disable":"",
"link":"..",
"view":""
},
{
"name":"\uff12\u3061\u3083\u3093\u306d\u308b\u691c\u7d22",
"paragraph":"//div[@class=\"content_pane\"]/dl/dt",
"domain":"^http://find\\.2ch\\.net/\\?",
"stripe":"1",
"link":"a",
"exampleUrl":"http://find.2ch.net/"
},
{
"name":"2ch\u4e16\u754c\u30cb\u30e5\u30fc\u30b9",
"paragraph":"id(\"content\")//h2[contains(concat(\" \", @class, \" \"), \" title \")] | id(\"content\")//div[contains(concat(\" \", @class, \" \"), \" entry \")]/dl/dt | id(\"comments\")//div[contains(concat(\" \", @class, \" \"), \" commenttext \")]",
"domain":"^http://120\\.hp2\\.jp/\\?p=",
"stripe":"",
"height":"",
"disable":"",
"link":"",
"view":"",
"exampleUrl":"http://120.hp2.jp/?p=3438"
},
{
"name":"hatena::let",
"paragraph":"//div[contains(concat(\" \", @class, \" \"), \" codelist \")]",
"domain":"^http://let\\.hatelabo\\.jp/",
"link":".//a[@class=\"code-path\"]"
},
{
"name":"tabesugi.net/memo",
"paragraph":"//descendant::*[self::h5]",
"domain":"^http://tabesugi\\.net/memo/",
"link":"./a[1]",
"exampleUrl":"http://tabesugi.net/memo/cur/cur.html"
},
{
"name":"\u30e1\u30c7\u30a3\u30a2\u30de\u30fc\u30ab\u30fc(\u30d0\u30a4\u30f3\u30c0\u30fc)",
"paragraph":"//td[@class=\"main\"]|//div[@class=\"binder_data\"]",
"domain":"^http://mediamarker\\.net/u/",
"link":".//div[@class=\"med_title\"]//span//a",
"exampleUrl":"http://mediamarker.net/"
},
{
"name":"\u3072\u3089\u3081\u3044\u3063\u305f\u30fc",
"paragraph":"//div[@class=\"idea_twit\"]",
"domain":"http://ryo.hayamin.com/idea/",
"stripe":"1",
"height":"0",
"link":".//span[@class=\"star\"]/h3/a",
"exampleUrl":"http://ryo.hayamin.com/idea/",
"view":".//span[@class=\"twit\"]/text()"
},
{
"paragraph":".//div[@class=\"entries\"]/div[@class=\"entry\"]",
"domain":"http://h.hatena.(com|ne.jp)/",
"stripe":"1",
"link":".//span[@class=\"timestamp\"]/a",
"exampleUrl":"http://h.hatena.ne.jp/"
},
{
"name":"\u03bd\u901f\u5c02\u7528\u3046\uff50\u308d\u3060\uff202ch.at",
"paragraph":"id(\"page_main\")/table",
"domain":"^http://tsushima\\.2ch\\.at/",
"stripe":"false",
"height":"",
"disable":"",
"link":".//a[img]",
"view":""
},
{
"name":"",
"paragraph":"//img[@class=\"pict\"] | //div[@class=\"article-body-more\"]/a[@target=\"_blank\"]/img|//div[@class=\"article-body-more\"]/p/a[@target=\"_blank\"]/img",
"domain":"http://minkch.com/archives/*",
"stripe":"false",
"height":"",
"disable":"",
"link":"..",
"view":""
},
{
"name":"Gist GitHub",
"paragraph":"id(\"files\")/div[contains(concat(\" \",normalize-space(@class),\" \"), \" file \")]",
"domain":"^http://gist\\.github\\.com/",
"stripe":"",
"height":"",
"disable":"",
"link":".//div[contains(concat(\" \",normalize-space(@class),\" \"), \" info\")]/span/a",
"view":""
},
{
"name":"hatena bookmark entry page",
"paragraph":"//li[starts-with(@id,\"bookmark-user\")]",
"domain":"http://b.hatena.ne.jp/entry/",
"link":"./a[contains(@class, \"username\")]",
"exampleUrl":"http://b.hatena.ne.jp/entry"
},
{
"name":"\"slideshare\"",
"paragraph":"//a[contains(concat(\" \",@class,\" \"),\" thumbnail_img_link \")]/img",
"domain":"^http://www.slideshare.net/",
"stripe":"1",
"link":"../../a",
"exampleUrl":"http://www.slideshare.net/"
},
{
"name":"mangahelpers",
"paragraph":"//tr",
"domain":"^http://mangahelpers\\.com/",
"link":"./td[3]/a"
},
{
"name":"4U",
"paragraph":"id(\"content\")/div/ul[contains(concat(\" \",normalize-space(@class),\" \"), \" entry-list \")]/li",
"domain":"^http://4u.straightline.jp/",
"link":".//p[@class=\"entry-information\"]/a",
"exampleUrl":"http://4u.straightline.jp/"
},
{
"paragraph":"//h2[@class=\"date\"]",
"domain":"^http://[^.]+.slmame.com/.*",
"stripe":"1",
"link":"../div[@class=\"blogbody\"]/h3[@class=\"title\"]/a",
"exampleUrl":"http://www.slmame.com/",
"view":"../div[@class=\"blogbody\"]/h3[@class=\"title\"]/a"
},
{
"name":"Gizmodo Japan",
"paragraph":"//h2",
"domain":"^http://www\\.gizmodo\\.jp/",
"link":"a",
"exampleUrl":"http://www.gizmodo.jp/"
},
{
"name":"Hatena Bookmark News(ceek.jp)",
"paragraph":"//div[@class=\"entry\"]",
"domain":"http://labs.ceek.jp/hbnews/",
"stripe":"1",
"height":"2",
"link":"./a[1]",
"exampleUrl":"http://labs.ceek.jp/hbnews/"
},
{
"name":"brightkite.com",
"paragraph":"//div[@id=\"stream\"]/div[contains(concat(\"\", @class, \"\"), \"item\")]",
"domain":"^http://brightkite\\.com/.+",
"stripe":"1",
"link":".//a[contains(text(), \"ago\")]",
"exampleUrl":"http://brightkite.com/objects"
},
{
"name":"nanapi[\u30ca\u30ca\u30d4]\u3000\u30e9\u30a4\u30d5\u30ec\u30b7\u30d4\u8a73\u7d30",
"paragraph":"//div[contains(concat(\" \" , @class, \" \"), \" article-body \")]/h2 | id(\"show_message\")",
"domain":"^http://r.nanapi.jp/[0-9]+/",
"stripe":"",
"height":"",
"disable":"",
"link":"",
"view":""
},
{
"paragraph":"//div[starts-with(@id,\"illust_c\")]/ul/li",
"domain":"^http://www\\.pixiv\\.net/",
"stripe":"0",
"link":"a",
"exampleUrl":"http://www.pixiv.net/"
},
{
"name":"\"Xlink kai\u8a2d\u5b9a\u624b\u9806\"",
"paragraph":"//div[contains(concat(\" \",@class,\" \"),\" no_block \")]",
"domain":"http://xlink.planex.co.jp/",
"stripe":"1",
"link":"",
"exampleUrl":"http://xlink.planex.co.jp/"
},
{
"paragraph":"//div[starts-with(@id,\"post\")]",
"domain":"^http://[^.]+\\.soup\\.io/",
"link":"(.//div[@class=\"meta\"]//a)[1]"
},
{
"name":"SAGURI",
"paragraph":"id(\"search_result_in\")//li",
"domain":"^http://saguri\\.jp/search",
"stripe":"1",
"link":"div[1]/table/tbody/tr/td[1]/div/a",
"exampleUrl":"http://saguri.jp/"
},
{
"name":"Userscripts.org",
"paragraph":"//table[@class=\"wide forums\"]/tbody/tr[not(position()=1)]",
"domain":"^http://userscripts\\.org/",
"stripe":"1",
"height":"0",
"link":"td[contains(@class,\"script-meat\")]/a",
"exampleUrl":"http://userscripts.org/",
"view":"td[contains(@class,\"script-meat\")]/a/text()"
},
{
"name":"Massively",
"paragraph":"//div[contains(concat(\" \",@class,\" \"),\" post \")]",
"domain":"^http://www.massively.com/",
"stripe":"1",
"link":"h2/a",
"exampleUrl":"http://www.massively.com/"
},
{
"name":"Hatena Haiku Search",
"paragraph":"//div[@class=\"entry\"]",
"domain":"http://hhs.trashsuite.org/",
"link":".//div[@class=\"info\"]/a[1]",
"exampleUrl":"http://hhs.trashsuite.org/"
},
{
"name":"( ;^\u03c9^)<\u3078\u3044\u308f\u307c\u3051",
"paragraph":"id(\"center\")/h2",
"domain":"http://www.heiwaboke.com/$",
"link":"a",
"exampleUrl":"http://www.heiwaboke.com/"
},
{
"name":"moewe",
"paragraph":"//h3|//h4",
"domain":"^http://moewe\\.xrea\\.jp/",
"exampleUrl":"http://moewe.xrea.jp/"
},
{
"name":"moe.imouto.org",
"paragraph":"//span[contains(concat(\" \",normalize-space(@class),\" \"),\"thumb\")]",
"domain":"http://moe.imouto.org/post",
"link":"a",
"exampleUrl":"http://moe.imouto.org/",
"view":"a/img"
},
{
"name":"reblog.ido.nu",
"paragraph":"//div[@class=\"even\" or @class=\"odd\"]",
"domain":"^http://reblog\\.ido\\.nu/",
"link":"./a[contains(text(), \"reblog\")]",
"exampleUrl":"http://reblog.ido.nu/"
},
{
"name":"\u30a6\u30ce\u30a6\u30e9\u30dc Unoh Labs",
"paragraph":"//div[starts-with(@id,\"entry\")]",
"domain":"^http://labs\\.unoh\\.net/",
"exampleUrl":"http://labs.unoh.net/"
},
{
"paragraph":"//ul[contains(@class, \"result\")]/li",
"domain":"^http://nanapi.jp/search.*",
"stripe":"true",
"link":"./dl/dt/a",
"view":"./dl/dt/a/text()"
},
{
"name":"\u3055\u304f\u3089\u306e\u30d6\u30ed\u30b0",
"paragraph":"//h2[contains(concat(\" \", @class, \" \"), \" title \")]",
"domain":"^http://[^/]+\\.sblo\\.jp/",
"link":".//a",
"exampleUrl":"http://www.sblo.jp"
},
{
"name":"Feecle",
"paragraph":"//ul[@id=\"entr\"]/li",
"domain":"http://www\\.feecle\\.jp/",
"link":".//a[@class=\"link\"]",
"exampleUrl":"http://www.feecle.jp/"
},
{
"name":"AppShopper",
"paragraph":"//ul[@class=\"appdetails\"]/li",
"domain":"^http://appshopper\\.com/",
"stripe":"",
"height":"",
"disable":"",
"link":"./h3/a",
"view":"./h3/a/text()"
},
{
"name":"Web2Rain",
"paragraph":"//div[contains(concat(\" \",@class,\" \"),\" columnleft \")]",
"domain":"^http://www.web2rain.com/",
"stripe":"1",
"link":"div[contains(concat(\" \",@class,\" \"),\" rightcontent \")]/div[contains(concat(\" \",@class,\" \"),\" posttxt \")]/a",
"exampleUrl":"http://www.web2rain.com/index.php"
},
{
"name":"tumblr.pics",
"paragraph":"id(\"left_box\")//ul[@class=\"autopagerize_page_element\"]/li[starts-with(@id,\"info_box_\")]",
"domain":"^http://tumblrpics\\.net/",
"link":"./div/a"
},
{
"name":"FriendFeed",
"paragraph":"//div[contains(concat(\" \",normalize-space(@class),\" \"),\" entry \")]",
"domain":"^http://friendfeed\\.com/",
"link":".//a[@class=\"date\"]",
"exampleUrl":"http://friendfeed.com/"
},
{
"name":"\u304a\u3044\u306c\u307e\u65e5\u5831(\u4e0d\u5b9a\u671f)",
"paragraph":"//div[contains(@class,\"section\")]//h3",
"domain":"http://diary.lampetty.net",
"link":"a",
"exampleUrl":"http://diary.lampetty.net/",
"view":"text()"
},
{
"name":"\u306f\u3066\u306a\u533f\u540d\u30c0\u30a4\u30a2\u30ea\u30fc",
"paragraph":"//div[@class=\"section\"]",
"domain":"http://anond.hatelabo.jp/",
"link":"p[@class=\"sectionfooter\"]/a[1]",
"exampleUrl":"http://anond.hatelabo.jp/"
},
{
"name":"crossreview",
"paragraph":"id(\"Main\")/div[contains(concat(\" \",normalize-space(@class),\" \"),\" Review01 \")]",
"domain":"^http://crossreview\\.jp/",
"link":".//h3/a",
"exampleUrl":"http://crossreview.jp/"
},
{
"name":"( ;^\u03c9^)<\u3078\u3044\u308f\u307c\u3051 - article",
"paragraph":"(id(\"center\")/h1 | //div[@class=\"entry-body\"]/dl/dt)",
"domain":"http://www.heiwaboke.com/",
"exampleUrl":"http://www.heiwaboke.com/"
},
{
"name":"Vector\uff1a\u30bd\u30d5\u30c8\u30a6\u30a7\u30a2\u30fb\u30e9\u30a4\u30d6\u30e9\u30ea\uff06PC\u30b7\u30e7\u30c3\u30d7",
"paragraph":"id(\"subbody\")/ul[contains(concat(\" \",@class,\" \"),\" file_list \")]/li",
"domain":"^http://www.vector.co.jp/",
"stripe":"true",
"link":"a",
"exampleUrl":"http://www.vector.co.jp/"
},
{
"name":"mimizun.com",
"paragraph":"//dt",
"domain":"^http://mimizun\\.com/.*",
"stripe":"",
"height":"",
"disable":"",
"link":"",
"view":""
},
{
"name":"iPhone\u30fbiPod Touch \u30e9\u30dc",
"paragraph":"id(\"main\")//h2",
"domain":"http://ipodtouchlab.com/",
"stripe":"1",
"link":"..//a[contains(text(),\"Perma\")]",
"exampleUrl":"http://ipodtouchlab.com/"
},
{
"name":"ameba blog",
"paragraph":"//div[@class=\"entry\"]",
"domain":"^http://ameblo.jp/[^/]+/",
"stripe":"1",
"exampleUrl":"http://www.ameblo.jp/"
},
{
"name":"Mitter edit",
"paragraph":"//ul[@class=\"entries\"]/li",
"domain":"^http://mitter\\.jp/edit",
"stripe":"1",
"link":"div/h2/a",
"exampleUrl":"http://mitter.jp/"
},
{
"name":"Mitter video history",
"paragraph":"//ul[contains(concat(\" \", @class, \" \"), \" activities \")]/li",
"domain":"^http://mitter\\.jp/[^/]",
"link":".//a",
"exampleUrl":"http://mitter.jp/"
},
{
"name":"konachan",
"paragraph":"//span[contains(concat(\" \",normalize-space(@class),\" \"),\"thumb\")]",
"domain":"http://konachan.com/post",
"link":"a",
"exampleUrl":"http://konachan.com/",
"view":"a/img"
},
{
"name":"Delicious",
"paragraph":"//div[contains(concat(\" \",normalize-space(@class),\" \"),\" bookmark \")]",
"domain":"^http://delicious\\.com/",
"stripe":"1",
"link":".//a[contains(concat(\" \",normalize-space(@class),\" \"),\" taggedlink \")]",
"exampleUrl":"http://delicious.com/"
},
{
"name":"\u30a2\u30eb\u30d5\u30a1\u30d6\u30c3\u30af\u30de\u30fc\u30ab\u30fc\u306e\u6ce8\u76ee\u3059\u308b\u30a8\u30f3\u30c8\u30ea\u30fc",
"paragraph":"//div[@class=\"section entry\"]",
"domain":"^http://ab\\.wryy\\.net/",
"stripe":"1",
"link":".//h3/a",
"exampleUrl":"http://ab.wryy.net/",
"view":".//h3/a/text()"
},
{
"name":"\"Second Life Library Project\"",
"paragraph":"//div[contains(concat(\" \",@class,\" \"),\" post \")]",
"domain":"^http://infoisland.org/",
"stripe":"1",
"link":"h1/a",
"exampleUrl":"http://infoisland.org/"
},
{
"name":"4chan",
"paragraph":"//form/input[@value=\"delete\"] | //form/table[@border=\"0\"] | //form/table/tbody/tr/td[@class=\"doubledash\"]",
"domain":"http://[^.]+.4chan.org/",
"exampleUrl":"http://www.4chan.org/"
},
{
"name":"python\u30c9\u30ad\u30e5\u30e1\u30f3\u30c8",
"paragraph":"(//h6 | //h5 | //h4 | //h3 | //h2 | //h1)",
"domain":"http://docs.python.org/",
"exampleUrl":"http://docs.python.org/"
},
{
"name":"\u5b64\u5cf6\u304b\u3089\u30d3\u30f3\u3092\u6d41\u3059\u4f1a",
"paragraph":"//*[contains(@class,\"mymessage\") or contains(@class,\"friendmessage\")]",
"domain":"^http://b\\.pira\\.jp/",
"stripe":"0",
"exampleUrl":"http://b.pira.jp/"
},
{
"name":"Slashdot Japan",
"paragraph":"id(\"articles\")//div[contains(concat(\" \",@class,\" \"),\" article \")]",
"domain":"http://slashdot.jp.*/$",
"link":"following-sibling::div[contains(concat(\" \",@class,\" \"),\" storylinks \")]//a[1]",
"exampleUrl":"http://slashdot.jp/"
},
{
"name":"image.baidu.jp",
"paragraph":"id(\"c\")/div",
"domain":"http://image.baidu.jp/",
"link":"//p[@class=\"t\"]/a",
"exampleUrl":"http://image.baidu.jp/"
},
{
"name":"\"\u306f\u3066\u306a\u30d5\u30a9\u30c8\u30e9\u30a4\u30d5\u3000\u30c8\u30c3\u30d7\u30da\u30fc\u30b8\"",
"paragraph":"//div[contains(concat(\" \",@class,\" \"),\" indexfotolist \") or contains(concat(\" \",@class,\" \"),\" fotolife-infomation \")]",
"domain":"http://f.hatena.ne.jp/",
"stripe":"1",
"link":"h2/a",
"exampleUrl":"http://f.hatena.ne.jp/"
},
{
"name":"AA\u4fdd\u5b88\uff01(\uff65\u2200\uff65",
"paragraph":"//div[contains(concat(\" \",normalize-space(@class),\" \"),\" aa-wrapper \")]",
"domain":"^http://aahosyu\\.com/",
"stripe":"true",
"height":"",
"disable":"",
"link":".//div[contains(concat(\" \",normalize-space(@class),\" \"),\" title \")]//a",
"view":""
},
{
"name":"",
"paragraph":"//div[@id=\"bookmarks\"]/div",
"domain":"^http://pinboard\\.in/",
"stripe":"true",
"height":"",
"disable":"",
"link":".//a[contains(concat(\"\", @class, \"\"), \"bookmark_title\")]",
"view":""
},
{
"name":"Slashdot Japan - article",
"paragraph":"id(\"articles\") | id(\"commentlisting\")//li[contains(concat(\" \",@class,\" \"),\" comment \")]",
"domain":"http://slashdot.jp/.+",
"link":".//span[contains(concat(\" \",@class,\" \"),\" otherdetails \")]//a[1]",
"exampleUrl":"http://slashdot.jp/"
},
{
"name":"P2P today \u30c0\u30d6\u30eb\u30b9\u30e9\u30c3\u30b7\u30e5",
"paragraph":"//div[@class=\"itembody\"]/p[position() < last()]",
"domain":"^http://wslash\\.com/",
"stripe":"1",
"link":"a",
"exampleUrl":"http://wslash.com/"
},
{
"name":"Topsy Search results",
"paragraph":"//div[contains(concat(\" \", @class, \" \"), \" list \")]/div | //div[contains(concat(\" \", @class, \" \"), \" image-v1 \")]",
"domain":"^http://topsy\\.com/s",
"stripe":"true",
"link":".//a[contains(concat(\" \", @class, \" \"), \" trackback-link \")]",
"exampleUrl":"http://topsy.com/s?q=twitter http://topsy.com/s/twitter/image?site=twitpic.com&window=h"
},
{
"name":"\u306f\u3066\u306a\u30a2\u30a4\u30c7\u30a2",
"paragraph":"//table[@class=\"table-list\"]/tbody/tr",
"domain":"http://i.hatena.ne.jp",
"stripe":"0",
"link":"td[contains(@class,\"icontent\")]//a",
"exampleUrl":"http://i.hatena.ne.jp/idealist"
},
{
"name":"blog.baidu.jp",
"paragraph":"//table[@class=\"n\"]//font[@size=\"3\"]",
"domain":"http://blog.baidu.jp/",
"link":"a",
"exampleUrl":"http://blog.baidu.jp/"
},
{
"name":"Twitxr.com",
"paragraph":"id(\"frontpage\")//div[contains(concat(\" \",normalize-space(@class),\" \"),\" update \")]",
"domain":"^http://twitxr\\.com/",
"link":"a[2]",
"exampleUrl":"http://twitxr.com/"
},
{
"name":"Buzzurl",
"paragraph":"//ul[@class=\"autopagerize_page_element\"]/li | //dl[@class=\"autopagerize_page_element\"]/dt",
"domain":"^http://buzzurl\\.jp/",
"link":"*[@class=\"new_win\"]/a | a[@rel=\"new_win\"]",
"exampleUrl":"http://buzzurl.jp/"
},
{
"name":"drawr",
"paragraph":"//div[contains(concat(\" \",normalize-space(@class),\" \"),\" homeBox \") or contains(concat(\" \",normalize-space(@class),\" \"),\" drawr_box \") or contains(concat(\" \",normalize-space(@class),\" \"),\" favoriteBox \") or contains(concat(\" \",normalize-space(@class),\" \"),\" permalinkEntry \") or contains(concat(\" \",normalize-space(@class),\" \"),\" entryArea \")]",
"domain":"^http://drawr\\.net/",
"stripe":"true",
"height":"",
"disable":"",
"link":".[contains(concat(\" \",normalize-space(@class),\" \"),\" homeBox \") or contains(concat(\" \",normalize-space(@class),\" \"),\" drawr_box \") or contains(concat(\" \",normalize-space(@class),\" \"),\" favoriteBox \")]//table//a[img] | .[contains(concat(\" \",normalize-space(@class),\" \"),\" permalinkEntry \")]/div[contains(concat(\" \",normalize-space(@class),\" \"),\" floleft \")]//a[img] | .//div[contains(concat(\" \",normalize-space(@class),\" \"),\" entryAreaImg \")]//a[img]",
"view":""
},
{
"name":"www.baidu.jp",
"paragraph":"//table[@class=\"n\"]//font[@size=\"3\"]",
"domain":"http://www.baidu.jp/",
"link":"a",
"exampleUrl":"http://www.baidu.jp/"
},
{
"name":"\u30c0\u30f3\u30ab\u30f3\u3002",
"paragraph":"//h2[contains(@class,\"diaryTitle\")]",
"domain":"^http://dancom\\.jp/",
"exampleUrl":"http://dancom.jp/"
},
{
"name":"\u30dc\u30b1\u3066\uff08bokete\uff09",
"paragraph":"//div[contains(concat(\" \", normalize-space(@class), \" \"), \" ui-widget \")]",
"domain":"^http://bokete\\.jp/",
"stripe":"",
"height":"",
"disable":"",
"link":".//a",
"view":""
},
{
"name":"\u30c6\u30ad\u30b9\u30c8\u738b",
"paragraph":"//div[@id=\"honbun\"]/dl/dt[@class=\"title\"] | //dl[@id=\"honbun\"]/dt[@class=\"title\"] | //div[@id=\"honbun\"]/ul/li[@class=\"title\"] | //ul[@id=\"children\"]/li[@class=\"post-title\"] | //div[@id=\"search_body\"]/p[@class=\"title\"]",
"domain":"^http://kudok\\.com/",
"link":"a"
},
{
"name":"\u643a\u5e2f\u767e\u666f",
"paragraph":"//td[contains(concat(\" \",@class,\" \"), \" image \")]",
"domain":"http://movapic.com/*",
"link":"./a"
},
{
"name":"p2.2ch.net",
"paragraph":"//td[contains(@class,\"tl\")]|//dt[contains(@id,\"r\")]",
"domain":"http://p2.2ch.net/*",
"height":"5",
"link":"a[contains(@id,\"tt\")]",
"exampleUrl":"http://p2.2ch.net/",
"view":"a/text()"
},
{
"name":"Qaa(\u30af\u30a1\u30fc)",
"paragraph":"//div[contains(concat(\" \",normalize-space(@class),\" \"),\"bubble\")]",
"domain":"http://qaa.orig.jp/",
"stripe":"0",
"height":"0",
"link":".//a",
"exampleUrl":"http://qaa.orig.jp/"
},
{
"name":"Digg",
"paragraph":"//div[@class=\"main\"]//div[@class=\"news-summary\"]",
"domain":"^http://digg\\.com/",
"link":"descendant::a[0]",
"exampleUrl":"http://digg.com/"
},
{
"name":"start.io",
"paragraph":"//div[@class=\"cell\"]",
"domain":"^http://start\\.io/",
"link":"./a[@class=\"link\"]"
},
{
"name":"\u5f15\u7528\u03b2",
"paragraph":"//div[@class=\"quote\"]",
"domain":"^http://inyo\\.jp/",
"link":".//a[@class=\"permalink\"]"
},
{
"name":"MIAU",
"paragraph":"//h2[contains(concat(\" \",normalize-space(@class),\" \"),\" contentheader \")]",
"domain":"^http://miau\\.jp/",
"link":"a",
"exampleUrl":"http://miau.jp/",
"view":"a/text()"
},
{
"name":"\u30b3\u30d4\u30da\u3061\u3083\u3093\u306d\u308b",
"paragraph":"id(\"middle\")//a[starts-with(@name,\"R\")] | id(\"middle\")//p[@id=\"resinfo\"]",
"domain":"^http://cpch\\.jp/",
"stripe":"1",
"link":"",
"exampleUrl":"http://cpch.jp/"
},
{
"name":"\u30a8\u30eb\u30a8\u30eb",
"paragraph":"//div[@class=\"mainmaru\"]",
"domain":"^http://10e\\.org/",
"stripe":"0",
"link":".//a[last()]/preceding-sibling::*[last()]",
"exampleUrl":"http://10e.org/"
},
{
"name":"femo",
"paragraph":"//div[contains(concat(\" \",normalize-space(@class),\" \"),\" entry \")]",
"domain":"^http://femo\\.jp/",
"stripe":"",
"height":"",
"disable":"",
"link":"./h2[contains(concat(\" \",normalize-space(@class),\" \"),\" entry-header \")]/a",
"view":""
},
{
"name":"Twib",
"paragraph":"//div[@class=\"box-post-content\"]/h2",
"domain":"^http://twib\\.jp/",
"stripe":"true",
"height":"",
"disable":"",
"link":"a",
"view":""
},
{
"name":"qwik.jp",
"paragraph":"//div[contains(@class,\"day\")]",
"domain":"^http://qwik\\.jp/",
"stripe":"0",
"exampleUrl":"http://qwik.jp/"
},
{
"name":"\"Blogs|SLCN\"",
"paragraph":"//h3[contains(concat(\" \",@class,\" \"),\" title \")]",
"domain":"^http://slcn.tv/",
"stripe":"1",
"link":"a",
"exampleUrl":"http://slcn.tv/"
},
{
"name":"\"[riro]\"",
"paragraph":"(//table[@class=\"userTable\"]//tr[child::node()[@class=\"comment\"]]|//table[@class=\"memberTable\"]//td)",
"domain":"http://riro.jp/",
"stripe":"1",
"link":"(//div[contains(concat(\" \",@class,\" \"),\" comment_foot \"]/a|//a)",
"exampleUrl":"http://riro.jp/"
},
{
"name":"lwn.net",
"paragraph":"//div[@class=\"Headline\"]",
"domain":"http://lwn.net/",
"exampleUrl":"http://lwn.net/"
},
{
"name":"hAtom 0.1",
"paragraph":"//*[contains(concat(\" \",normalize-space(@class),\" \"), \" hentry \")]",
"domain":"microformats",
"link":".//*[contains(concat(\" \",normalize-space(@rel),\" \"), \" bookmark \")]",
"exampleUrl":"http://microformats.org/wiki/hatom",
"view":".//*[contains(concat(\" \",normalize-space(@class),\" \"), \" entry-title \")]//text()"
},
{
"name":"xFolk RC1",
"paragraph":"//*[contains(concat(\" \",normalize-space(@class),\" \"), \" xfolkentry \")]",
"domain":"microformats",
"link":".//a[contains(concat(\" \",normalize-space(@class),\" \"), \" taggedlink \")]",
"exampleUrl":"http://microformats.org/wiki/xfolk",
"view":".//*[contains(concat(\" \",normalize-space(@class),\" \"), \" description \")]//text()"
},
{
"name":"file:///",
"paragraph":"id(\"UI_goUp\") | //table/tbody/tr[td]",
"domain":"^file:///",
"link":".//a"
},
{
"name":"img",
"paragraph":"//img[not(contains(@id,\"gm_ldrize\")) and parent::a]",
"link":"parent::a"
},
{
"name":"h6-h5-h4-h3-h2-h1",
"paragraph":"(//h6 | //h5 | //h4 | //h3 | //h2 | //h1)",
"link":"descendant::a"
},
{
"name":"mp3-file",
"paragraph":"//a[translate(substring(@href, string-length(@href)-3),\"MP\",\"mp\") = \".mp3\"]",
"link":"self::node()"
},
{
"name":"zip-file",
"paragraph":"//a[translate(substring(@href, string-length(@href)-3),\"ZIP\",\"zip\") = \".zip\"]",
"link":"self::node()"
},
{
"name":"zip-html-file",
"paragraph":"//a[translate(substring(@href, string-length(@href)-8),\"ZIPHTML\",\"ziphtml\") = \".zip.html\"]",
"link":"self::node()"
}
];
