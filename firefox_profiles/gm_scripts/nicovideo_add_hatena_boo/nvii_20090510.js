/*=======================================================
 Nicovideo Info Inserter
 ニコニコ動画内のありとあらゆる場所に要素を挿入するためのライブラリ
 version: 2009-05-10

 * 使い方
   ユーザースクリプトの最初に@require指定を追加するだけで使えます。

 * 特徴
   ・複数のスクリプトで共通の処理(DOMツリーの探索など)をまとめることができる
   ・AutoPagerize対応
   ・名前空間を極力汚さない設計(になっているつもり)

 * 更新履歴
   ・2009/01/03 公開
   ・2009/01/12 マイリストページの仕様変更に追従
   ・2009/02/21 動画再生ページの仕様変更に追従
   ・2009/03/29 マイリスト編集ページに対応
   ・2009/04/01 視聴履歴ページの仕様変更に追従
   ・2009/05/04 検索ページで4列表示時の仕様変更に追従
   ・2009/05/05 検索ページで4列表示時に挙動がおかしかったのを修正
   ・2009/05/10 myvideoで動作しなくなっていたのを修正

 * 利用例
   function handler(url, type) {
     // url: 挿入場所に関連したURL,
     // type: 挿入場所の種類(PointType)

     var elem = document.createElement('span');
     elem.textContent = url;
     // 挿入する要素を返す
     return elem;
   }

   // PageType, PointType を省略した際の値はそれぞれ
   // PageType.ALL, PointType.ALL
   with(NicovideoInfoInserter) {
     addInsertHandler(
       handler,                 // 挿入する要素を生成する関数
       PageType.ALL,            // 挿入するページを指定
       PointType.AROUND_TITLE | PointType.AROUND_MOVIE
       // 挿入する場所を指定。複数箇所の指定も可能
     );
   }
 * 挿入可能ページの一覧
   ** 直接指定
     SITETOP, WATCH
     TAG_SEARCH, RELATED_TAG_SEARCH, KEYWORD_SEARCH
     MYVIDEO, NEW_ARRIVAL, RECENT
     MYLIST, HISTORY, RANKING, MYLIST_EDIT
   ** 特殊な指定
     ANY_PAGE, ANY_SEARCH, THUMB_PAGE

 * 挿入可能箇所の一覧
   ** 直接指定
     BEFORE_TITLE:
       h1要素の前の要素(previousElement)内に追加
     AFTER_TITLE:
       h1要素の末尾に追加
     BEFORE_H3:
       a要素を子に持つh3要素の前の要素内に追加
     AFTER_H3:
       a要素を子にもつh3要素の末尾に追加
     THUMBNAIL_2COL_TOP, BOTTOM, LEFT, RIGHT, BEFORE_LINK, AFTER_LINK:
     THUMBNAIL_4COL_TOP, BOTTOM, LEFT, RIGHT, BEFORE_LINK, AFTER_LINK:
       サムネイル付近
   ** 特殊な指定
     ANY_POINT:
         全ての場所に挿入する
         重複する指定(BEFORE_TITLEとAFTER_TITLE)はどちらか片方のみ指定する
     ENFORCED_ANY_POINT:
         全ての場所に挿入する
         指定の重複は一切考慮しない
     AROUND_TITLE:
       BEFORE_TITLE, AFTER_TITLE のうち，現在のページで使える物
       (両方使える場合は，BEDORE_TITLE を優先する線)
     AROUND_THUMB:
       THUMB_2COL_LEFT | THUMB_4COL_BEFORE_LINK
     AROUND_MOVIE:
       BEFORE_H3, AFTER_H3, AROUND_TITLE, AROUND_THUMB の中の適切なもの

 =======================================================*/

// ライブラリ外に公開するオブジェクト
var NicovideoInfoInserter;

(function() {
   const LIBRARY_NAME = 'NICOVIDEO_INFO_INSERTER';
   const VERSION = '20090510';
   var oldLib;

   GM_log('Nicovideo Info Inserter - version:' + VERSION);
   if(window[LIBRARY_NAME] !== undefined) {
     oldLib = window[LIBRARY_NAME];
     if(window[LIBRARY_NAME].VERSION != VERSION) {
       GM_log('Nicovideo Info Inserter: ' +
              '[warning] Different versions of this script are installed.');
     }
     if(window[LIBRARY_NAME].VERSION >= VERSION) {
       NicovideoInfoInserter = window[LIBRARY_NAME];
       return;
     }
   }



   var BitField = function(array, defaultType) {
     var val = 1;
     array.forEach(
       function(name) {
         this[name] = val;
         val *= 2;
       },
       this);
     this.fieldNames = array;
     this.fieldSum = val - 1;
   };
   BitField.prototype.test = function(filter, type) {
     if(type === undefined)
       type = this.defaultType;
     return (filter & type) != 0;
   };
   BitField.prototype.toFieldName = function(num) {
     return this.fieldNames.filter(
       function(name) {
         return this.test(num, this[name]);
       },
       this).join(' | ');
   };



   var PageType = new BitField(
     ['SITETOP', 'WATCH',
      'TAG_SEARCH', 'RELATED_TAG_SEARCH', 'KEYWORD_SEARCH',
      'MYVIDEO', 'NEW_ARRIVAL', 'RECENT', 'MYLIST', 'HISTORY', 'RANKING',
      'MYLIST_EDIT', 'UNKNOWN'
     ]);
   PageType.getType = function(url) {
     var data = url.match(
       new RegExp('^http://www\.nicovideo\.jp/(?:([^/]+)/?(.*))?$'));
     var type = data[1], param = data[2];
     switch(type){
     case 'watch':            return [this.WATCH, param];
     case 'tag':              return [this.TAG_SEARCH, param];
     case 'related_tag':      return [this.RELATED_TAG_SEARCH, param];
     case 'search':           return [this.KEYWORD_SEARCH, param];
     case 'myvideo':          return [this.MYVIDEO, param];
     case 'newarrival':       return [this.NEW_ARRIVAL, param];
     case 'recent':           return [this.RECENT, param];
     case 'mylist':           return [this.MYLIST, param];
     case 'mylist_edit':           return [this.MYLIST_EDIT, param];
     case 'history':          return [this.HISTORY, param];
     case 'ranking':          return [this.RANKING, param];
     case '':                 return [this.SITETOP, param];
     }
     return [this.UNKNOWN, param];
   };

   (function() {
      this.ANY_SEARCH =
        this.TAG_SEARCH | this.RELATED_TAG_SEARCH | this.KEYWORD_SEARCH;

      this.THUMB_PAGE =
        this.TAG_SEARCH | this.KEYWORD_SEARCH
        | this.MYVIDEO | this.NEW_ARRIVAL | this.RECENT | this.SITETOP;

      this.ANY_PAGE = this.fieldSum;

      [this.currentPageType, this.currentPageParam] =
        this.getType(location.href);
      this.defaultType = this.currentPageType;
    }).call(PageType);



   var PointType = new BitField(
     ['BEFORE_TITLE', 'AFTER_TITLE',
      'BEFORE_H3', 'AFTER_H3',
      'THUMB_2COL_TOP', 'THUMB_2COL_BOTTOM',
      'THUMB_2COL_LEFT', 'THUMB_2COL_RIGHT',
      'THUMB_2COL_BEFORE_LINK', 'THUMB_2COL_AFTER_LINK',
      'THUMB_4COL_TOP', 'THUMB_4COL_BOTTOM',
      'THUMB_4COL_LEFT', 'THUMB_4COL_RIGHT',
      'THUMB_4COL_BEFORE_LINK', 'THUMB_4COL_AFTER_LINK'
     ]);
   (function() {
      this.AROUND_THUMB =
        this.THUMB_2COL_LEFT | this.THUMB_4COL_BEFORE_LINK;

      this.AROUND_TITLE =
        PageType.test(PageType.WATCH | PageType.MYLIST | PageType.MYLIST_EDIT)
        ? this.BEFORE_TITLE
        : this.AFTER_TITLE;

      this.AROUND_MOVIE =
        PageType.test(PageType.WATCH)
        ? this.AROUND_TITLE
        : PageType.test(PageType.MYLIST | PageType.RANKING | PageType.HISTORY
                        | PageType.MYLIST_EDIT)
        ? this.BEFORE_H3
        : PageType.test(PageType.THUMB_PAGE)
        ? this.AROUND_THUMB
        : this.AFTER_H3;

      this.ANY_POINT = this.AROUND_TITLE | this.AROUND_MOVIE;
      this.ENFORCED_ANY_POINT = this.fieldSum;
      this.defaultType = this.ANY_POINT;
    }).call(PointType);



   var Point = function(container, url) {
     this.container = container;
     this.wrapper = document.createDocumentFragment();
     this.url = url;
     this.insertPointer = null;
   };
   Point.prototype = {
     invokeHandler: function(handler) {
       var elem = handler(this.url, this.type);
       if(elem == null)
         return;
       this.wrapper.appendChild(document.createTextNode(' '));
       this.wrapper.appendChild(elem);
       if(this.wrapper.parentNode == null) {
         this.container.insertBefore(this.wrapper, this.insertPointer);
       }
     }
   };



   var PointGenerator = function(type, generator) {
     this.points = [];
     this.handlers = [];
     this.unprocessedContexts = [];
     this.generator = generator;
     this.type = type;
   };
   PointGenerator.prototype = {
     addHandler: function(handler) {
       if(this.unprocessedContexts.length != 0)
         this.updatePoints();
       this.handlers.push(handler);
       this.points.forEach(
         function(p) { p.invokeHandler(handler); }
       );
     },
     addContext: function(context) {
       this.unprocessedContexts.push(context);
       if(this.handlers.length != 0)
         this.updatePoints();
     },
     updatePoints: function() {
       this.unprocessedContexts.forEach(
         function(context) {
           var newPoints = this.generator(context);
           this.points = this.points.concat(newPoints);
           newPoints.forEach(
             function(p) {
               p.type = this.type;
               this.handlers.forEach(
                 function(h) {
                   p.invokeHandler(h);
                 });
             },
             this);
         },
         this);
       this.unprocessedContexts = [];
     }
   };



   var Inserter = {
     generators: [],
     registGenarator: function(type, fun) {
       this.generators.push(new PointGenerator(type, fun));
     },
     registXPath: function(type, exp, url) {
       if(url === undefined)
         url = location.href;
       this.registGenarator(
         type,
         function(context) {
           var elem = $XSingle(exp, context);
           if(elem == null)
             return [];
           return [new Point(elem, url)];
         });
     },
     registElement: function(type, name, url) {
       if(url === undefined)
         url = location.href;
       this.registGenarator(
         type,
         function(context) {
           var elem = context.getElementsByTagName(name);
           if(elem.length == 0)
             return [];
           return [new Point(elem[0], url)];
         });
     },
     registXPathWithLink: function(type, linkExp, elemExp, filter){
       this.registGenarator(
         type,
         function(context) {
           return $XMemo(linkExp, context).map(
             function(link) {
               var elem;
               if(link == null ||
                  (elem = $XSingleMemo(elemExp, link)) == null)
                 return null;
               var p = new Point(elem, link.href);
               if(typeof filter == 'function')
                 filter(link, elem, p);
               return p;
             }).filter(function(p) { return p != null; });
         }
       );
     },
     registAroundThumbnail: function() {
       function setWrapperTXT10(link, elem, point){
         point.wrapper = document.createElement('p');
         point.wrapper.className = 'TXT10';
       }
       var thumb_link_2col_xpath = 'descendant-or-self::table' +
         '[@summary="video" or (@id = "video_table" and @summary="list")]' +
         '[descendant::tr[1][count(td)=2]]' +
         '//a[contains(concat(" ", @class, " "), " video ")]';
       this.registXPathWithLink(
         PointType.THUMB_2COL_TOP,
         thumb_link_2col_xpath,
         'ancestor::div[1]' +
           '[contains(concat(" ", @class, " "), " thumb_frm ")]' +
           '/p[1]');
       this.registXPathWithLink(
         PointType.THUMB_2COL_LEFT,
         thumb_link_2col_xpath,
         'ancestor::td[1]/preceding-sibling::td[1]',
         setWrapperTXT10);
       this.registXPathWithLink(
         PointType.THUMB_2COL_RIGHT,
         thumb_link_2col_xpath,
         'ancestor::td[1]',
         setWrapperTXT10);
       this.registXPathWithLink(
         PointType.THUMB_2COL_BEFORE_LINK,
         thumb_link_2col_xpath,
         '../preceding-sibling::p[1]');
       this.registXPathWithLink(
         PointType.THUMB_2COL_AFTER_LINK,
         thumb_link_2col_xpath,
         '..',
         function(link, elem, point) {
           point.insertPointer = link.nextSibling;
         });
       this.registXPathWithLink(
         PointType.THUMB_2COL_BOTTOM,
         thumb_link_2col_xpath,
         'ancestor::div' +
           '[contains(concat(" ", @class, " "), " thumb_frm ")]' +
           '/p[last()]',
         function(link, elem, point) {
           if(hasClassName(elem, 'TXT10')
              || hasClassName(elem, 'vinfo_last_res')) {
             point.container = elem.parentNode;
             point.wrapper = document.createElement('p');
           }
         }
       );

       var thumb_link_4col_xpath = 'descendant-or-self::table' +
         '[@summary="video" or (@id = "video_table" and @summary="list")]' +
         '[descendant::tr[1][count(td)=4]]' +
         '//a[contains(concat(" ", @class, " "), " video ")]';
       this.registXPathWithLink(
         PointType.THUMB_4COL_TOP,
         thumb_link_4col_xpath,
         'ancestor::div' +
           '[contains(concat(" ", @class, " "), " thumb_frm ")]' +
           '/p[1]',
         function setWrapperTXT10(link, elem, point){
           elem.className = 'TXT10';
           elem.style.lineHeight = '9px';
           elem.getElementsByTagName('img')[0].style.verticalAlign = 'bottom';
         });
       this.registXPathWithLink(
         PointType.THUMB_4COL_LEFT,
         thumb_link_4col_xpath,
         '../preceding-sibling::table/tbody/tr[1]/td[1]/p[last()]'
       );
       this.registXPathWithLink(
         PointType.THUMB_4COL_RIGHT,
         thumb_link_4col_xpath,
         '../preceding-sibling::table/tbody/tr[1]/td[2]',
         setWrapperTXT10);
       this.registXPathWithLink(
         PointType.THUMB_4COL_BEFORE_LINK,
         thumb_link_4col_xpath,
         '..',
         function(link, elem, point) {
           point.insertPointer = link;
           setWrapperTXT10(link, elem, point);
         });
       this.registXPathWithLink(
         PointType.THUMB_4COL_AFTER_LINK,
         thumb_link_4col_xpath,
         '..',
         function(link, elem, point) {
           point.insertPointer = link.nextSibling;
         });
       this.registXPathWithLink(
         PointType.THUMB_4COL_BOTTOM,
         thumb_link_4col_xpath,
         'ancestor::div' +
           '[contains(concat(" ", @class, " "), " thumb_frm ")]' +
           '/p[last()]',
         function(link, elem, point) {
           point.container = elem.parentNode;
           setWrapperTXT10(link, elem, point);
         });
     },
     init: function() {
       switch(PageType.currentPageType) {
       case PageType.WATCH:
         this.registElement(PointType.AFTER_TITLE, 'h1');
         this.registXPath(
           PointType.BEFORE_TITLE,
           'descendant::h1/preceding-sibling::p[1]');
         break;
       case PageType.TAG_SEARCH:
       case PageType.RELATED_TAG_SEARCH:
       case PageType.KEYWORD_SEARCH:
         this.registXPath(
           PointType.AFTER_TITLE,
           // id("PAGEBODY") とするとページが継ぎ足された時に
           // 2重に要素が追加されてしまう
           // descendant::node()/id("PAGEBODY")
           // だと構文エラー
           'descendant::div[@id="PAGEBODY"]' +
             '/div[contains(concat(" ", @class, " "), " mb8p4 ")][1]' +
             '/p');
         this.registAroundThumbnail();
         break;
       case PageType.NEW_ARRIVAL:
       case PageType.RECENT:
       case PageType.MYVIDEO:
         this.registElement(PointType.AFTER_TITLE, 'h1');
         this.registAroundThumbnail();
         break;
       case PageType.MYLIST:
       case PageType.MYLIST_EDIT:
         this.registElement(PointType.AFTER_TITLE, 'h1');
         this.registXPath(
           PointType.BEFORE_TITLE,
           'descendant::h1/preceding-sibling::p[1]');
         this.registXPathWithLink(
           PointType.AFTER_H3,
           'descendant::h3/a', '..');
         this.registXPathWithLink(
           PointType.BEFORE_H3,
           'descendant::h3/a', '../preceding-sibling::p[1]');
         break;
       case PageType.HISTORY:
         this.registElement(PointType.AFTER_TITLE, 'h1');
         this.registXPath(
           PointType.BEFORE_TITLE,
           'descendant::h1/preceding-sibling::p[1]');
         this.registXPathWithLink(
           PointType.AFTER_H3,
           'descendant::h3/a', '..');
         this.registXPathWithLink(
           PointType.BEFORE_H3,
           'descendant::h3/a', '../preceding-sibling::p[1]');
         break;
       case PageType.RANKING:
         this.registXPath(
           PointType.AFTER_TITLE,
           'descendant::p[@id="ranking-name"]');
         this.registXPathWithLink(
           PointType.AFTER_H3,
           'descendant::h3/a', '..');
         this.registXPathWithLink(
           PointType.BEFORE_H3,
           'descendant::h3/a', '../preceding-sibling::p[1]');
         break;
       }
     },
     parsePage: function(context) {
       this.generators.forEach(
         function(generator) {
           generator.addContext(context);
         });
     }
   };
   Inserter.init();
   Inserter.parsePage(document.documentElement);

   var pagerizeHandler = [];
   NicovideoInfoInserter = window[LIBRARY_NAME] = {
     NAME: 'Nicovideo Info Inserter',
     VERSION: VERSION,
     PageType: PageType,
     PointType: PointType,
     addInsertHandler: function(handler, pageFilter, pointFilter) {
       if(!PageType.test(pageFilter))
         return;
       Inserter.generators.forEach(
         function(generator) {
           if(PointType.test(pointFilter, generator.type))
             generator.addHandler(handler);
         });
     },
     addPagerizeHandler: function(handler) {
       pagerizeHandler.push(handler);
     }
   };
   if(oldLib !== undefined) {
     oldLib.addInsertHandler = NicovideoInfoInserter.addInsertHandler;
     oldLib.addPagerizeHandler = NicovideoInfoInserter.addPagerizeHandler;
   }

   if(window.AutoPagerize !== undefined &&
      typeof window.AutoPagerize.addFilter == 'function') {
     AutoPagerize.addFilter(
       function(pages) {
         pages.forEach(Inserter.parsePage, Inserter);
         pagerizeHandler.forEach(function(h) { h(pages); });
       });
   }
   if(window.NicovideoShowAllRanks !== undefined &&
      typeof window.NicovideoShowAllRanks.addFilter == 'function') {
     NicovideoShowAllRanks.addFilter(
       function(td) {
         Inserter.parsePage(td);
         pagerizeHandler.forEach(function(h) { h(td); });
       }
     );
   }

   // Utilities
   function nextElement(elem) {
     do {
       elem = elem.nextSibling;
     } while(elem && elem.nodeType != 1);
     return elem;
   }
   function previousElement(elem) {
     do {
       elem = elem.previousSibling;
     } while(elem && elem.nodeType != 1);
     return elem;
   }
   function $XSingle(exp, context) {
     var doc = context.ownerDocument;
     var xpath = doc.evaluate(
       exp, context, null,
       XPathResult.FIRST_ORDERED_NODE_TYPE, null
     );
     if(xpath == null)
       return null;
     return xpath.singleNodeValue;
   }
   function $X(exp, context) {
     var doc = context.ownerDocument;
     var xpath = doc.evaluate(
       exp, context, null,
       XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null
     );
     if(xpath == null)
       return [];
     var result = [];
     for(var i = 0; i < xpath.snapshotLength; i++) {
       result.push(xpath.snapshotItem(i));
     };
     return result;
   }
   function $XSingleMemo(exp, context) {
     var name = 'XPATH_S_MEMO_' + exp;
     if(!(name in context))
       context[name] = $XSingle(exp, context);
     return context[name];
   }
   function $XMemo(exp, context) {
     var name = 'XPATH_MEMO_' + exp;
     if(!(name in context))
       context[name] = $X(exp, context);
     return context[name];
   }
   function hasClassName(elem, name){
     return (' ' + elem.className + ' ')
       .indexOf(' ' + name + ' ') != -1;
   }
 })();
