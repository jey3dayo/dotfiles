// ==UserScript==
// @name             Show Keybind In RMT
// @namespace        http://espion.just-size.jp/archives/05/136155838.html
// @include          http://www.rememberthemilk.com/*
// /==UserScript==

// HTML data from http://at-aka.blogspot.com/2006/07/remember-milk_27.html

function main() {
   var div = document.createElement('div');

   with(div.style) {
      top      = 0;
      left     = 0;
      display  = 'none';
      position = 'fixed';
      padding  = '5px 10px';
      fontSize = 'x-small';
      color    = "#000";
      backgroundColor = "#eee";
      zIndex   = 100;
      width    = '400px';
      height   = '90%';
      overflow = 'auto';
      textAlign= 'left';
   }

   div.innerHTML = msg;
   div.className = 'skirmt';
   document.body.appendChild(div);

   GM_addStyle('.skirmt dd { margin-left: 1.7em; } ');

   document.addEventListener(
      'keypress',
      function(e) {
         var target = new String(e.target.tagName);
         if(target == 'INPUT' || target == 'TEXTAREA') return;

         if(e.charCode == 63)
            div.style.display = div.style.display ? '' : 'none';
      },
      false
   );
}

var msg = '<h4>\u30BF\u30B9\u30AF\u7BA1\u7406</h4>'
+ '<dl>'
+ ' <dt><kbd>t</kbd> (Add)</dt>'
+ ' <dd>\u65B0\u3057\u3044\u30BF\u30B9\u30AF\u3092\u8FFD\u52A0\u3059\u308B\u3002\u30AB\u30FC\u30BD\u30EB\u306F\u30BF\u30B9\u30AF\u5165\u529B\u6B04\u306B\u79FB\u52D5\u3002</dd>'
+ ''
+ ' <dt><kbd>c</kbd> (Complete)</dt>'
+ ''
+ ' <dd>\u9078\u629E\u3057\u305F\u30BF\u30B9\u30AF\u3092\u300C\u5B8C\u4E86\u300D\u3055\u305B\u308B (\u8907\u6570\u9078\u629E\u53EF)\u3002</dd>'
+ ''
+ ' <dt><kbd>p</kbd> (Postpone)</dt>'
+ ' <dd>\u9078\u629E\u3057\u305F\u30BF\u30B9\u30AF\u3092\u7FCC\u65E5\u306B\u300C\u5EF6\u671F\u300D\u3055\u305B\u308B (\u8907\u6570\u9078\u629E\u53EF)\u3002</dd>'
+ ''
+ ' <dt><kbd>r</kbd> (Rename)</dt>'
+ ''
+ ' <dd>\u9078\u629E\u3057\u305F\u30BF\u30B9\u30AF\u306E\u540D\u524D\u3092\u7DE8\u96C6\u3059\u308B\u3002</dd>'
+ ''
+ ' <dt><kbd>Del</kbd> (Delete)</dt>'
+ ' <dd>\u9078\u629E\u3057\u305F\u30BF\u30B9\u30AF\u3092\u524A\u9664\u3059\u308B (\u8907\u6570\u9078\u629E\u53EF)\u3002</dd>'
+ '</dl>'
+ ''
+ '<h4>\u30BF\u30B9\u30AF\u7DE8\u96C6</h4>'
+ ''
+ '<p>\u4EE5\u4E0B\u306E\u30BF\u30B9\u30AF\u7DE8\u96C6\u7CFB\u306E\u30AD\u30FC\u64CD\u4F5C\u306F\u3001\u6700\u5F8C\u306B\u9078\u629E\u3057\u305F\u30BF\u30B9\u30AF\u306B\u306E\u307F\u6709\u52B9\u3068\u306A\u308B\u3002\u8907\u6570\u30BF\u30B9\u30AF\u3092\u4E00\u62EC\u306B\u7DE8\u96C6\u3059\u308B\u5834\u5408\u306F\u3001<kbd>m</kbd> \u30AD\u30FC\u3092\u62BC\u3057\u300CMulti Edit\u300D\u30E2\u30FC\u30C9\u306B\u5165\u308B\u5FC5\u8981\u304C\u3042\u308B (ref. <a href="http://at-aka.blogspot.com/2006/07/remember-milk_23.html">clmemo@aka: Remember the Milk \u3067\u8907\u6570\u306E\u30BF\u30B9\u30AF\u306B\u30BF\u30B0\u3092\u4ED8\u3051\u308B</a>)\u3002</p>'
+ '<dl>'
+ ' <dt><kbd>d</kbd> (Due Date)</dt>'
+ ' <dd>\u300C\u671F\u65E5\u300D\u3092\u7DE8\u96C6\u3002</dd>'
+ ''
+ ' <dt><kbd>f</kbd> (Repeat)</dt>'
+ ' <dd>\u300C\u30EA\u30D4\u30FC\u30C8\u300D\u3092\u7DE8\u96C6\u3002</dd>'
+ ''
+ ' <dt><kbd>g</kbd> (Time Estimate)</dt>'
+ ' <dd>\u300C\u4E88\u6E2C\u6642\u9593\u300D\u3092\u7DE8\u96C6\u3002</dd>'
+ ''
+ ' <dt><kbd>s</kbd> (Tags)</dt>'
+ ' <dd>\u300C\u30BF\u30B0\u300D\u3092\u7DE8\u96C6\u3002</dd>'
+ ''
+ ' <dt><kbd>u</kbd> (URL)</dt>'
+ ' <dd>\u300CURL\u300D\u3092\u7DE8\u96C6\u3002</dd>'
+ ''
+ ' <dt><kbd>l</kbd> (Location)</dt>'
+ ' <dd>\u300C\u5834\u6240\u300D\u3092\u7DE8\u96C6\u3002</dd>'
+ ''
+ ' <dt><kbd>y</kbd> (Add Note)</dt>'
+ ' <dd>\u300C\u30CE\u30FC\u30C8\u300D\u3092\u7DE8\u96C6\u3002</dd>'
+ ''
+ '</dl>'
+ ''
+ '<p>\u30BF\u30B9\u30AF\u7DE8\u96C6\u306B\u306F\u3001\u6B21\u306E\u30B3\u30DE\u30F3\u30C9\u3082\u6709\u7528\u3002</p>'
+ ''
+ '<dl>'
+ ' <dt><kbd>h</kbd> (Switch Tabs)</dt>'
+ ' <dd>\u9078\u629E\u3057\u305F\u30BF\u30B9\u30AF\u306E\u30BF\u30D6 (\u300C\u30BF\u30B9\u30AF\u300D\u30BF\u30D6\u3068\u300C\u30CE\u30FC\u30C8\u300D\u30BF\u30D6) \u3092\u5207\u308A\u66FF\u3048\u308B\u3002\u30BF\u30B9\u30AF\u3092\u9078\u629E\u3057\u3066\u3044\u306A\u3044\u5834\u5408\u306F\u3001\u30EA\u30B9\u30C8\u306E\u30BF\u30D6 (\u300C\u30EA\u30B9\u30C8\u300D\u30BF\u30D6\u3068\u300C\u5171\u6709\u300D\u30BF\u30D6\u3068\u300C\u516C\u958B\u300D\u30BF\u30D6) \u3092\u5207\u308A\u66FF\u3048\u308B\u3002</dd>'
+ ''
+ ' <dt><kbd>m</kbd> (Multi Edit)</dt>'
+ ''
+ ' <dd>\u30DE\u30EB\u30C1\u30A8\u30C7\u30A3\u30C3\u30C8\u30E2\u30FC\u30C9\u306E ON \u3068 OFF \u3092\u5207\u308A\u66FF\u3048\u308B (\u30C7\u30D5\u30A9\u30FC\u30EB\u30C8\u3067\u306F OFF)\u3002</dd>'
+ '</dl>'
+ ''
+ '<h4>\u512A\u5148\u5EA6\u5909\u66F4</h4>'
+ ''
+ '<p>\u512A\u5148\u5EA6\u306B\u95A2\u308B\u30B7\u30E7\u30FC\u30C8\u30AB\u30C3\u30C8\u30FB\u30AD\u30FC\u306F\u3001\u9078\u629E\u3057\u305F\u30BF\u30B9\u30AF\u5168\u3066\u306B\u9069\u7528\u3055\u308C\u308B\u3002</p>'
+ '<dl>'
+ ' <dt><kbd>1</kbd> (Priority 1)</dt>'
+ ' <dd>\u9078\u629E\u3057\u305F\u30BF\u30B9\u30AF\u306E\u512A\u5148\u5EA6\u3092 1 (\u6700\u91CD\u8981) \u306B\u8A2D\u5B9A\u3002</dd>'
+ ''
+ ' <dt><kbd>2</kbd> (Priority 2)</dt>'
+ ' <dd>\u9078\u629E\u3057\u305F\u30BF\u30B9\u30AF\u306E\u512A\u5148\u5EA6\u3092 2 \u306B\u8A2D\u5B9A\u3002</dd>'
+ ''
+ ' <dt><kbd>3</kbd> (Priority 3)</dt>'
+ ' <dd>\u9078\u629E\u3057\u305F\u30BF\u30B9\u30AF\u306E\u512A\u5148\u5EA6\u3092 3 \u306B\u8A2D\u5B9A\u3002</dd>'
+ ''
+ ' <dt><kbd>4</kbd> (No Priority)</dt>'
+ ' <dd>\u9078\u629E\u3057\u305F\u30BF\u30B9\u30AF\u304B\u3089\u512A\u5148\u5EA6\u3092\u6D88\u3059\u3002</dd>'
+ '</dl>'
+ ''
+ '<h4>\u30BF\u30B9\u30AF\u9078\u629E\u30FB\u79FB\u52D5</h4>'
+ ''
+ '<dl>'
+ ' <dt><kbd>a</kbd> (Select All)</dt>'
+ ''
+ ' <dd>\u5168\u3066\u306E\u30BF\u30B9\u30AF\u3092\u9078\u629E\u3059\u308B\u3002</dd>'
+ ''
+ ' <dt><kbd>n</kbd> (Select None)</dt>'
+ ' <dd>\u5168\u3066\u306E\u30BF\u30B9\u30AF\u304B\u3089\u30C1\u30A7\u30C3\u30AF\u3092\u5916\u3059\u3002</dd>'
+ ''
+ ' <dt><kbd>i</kbd> (Select Item)</dt>'
+ ''
+ ' <dd>\u73FE\u5728\u3001\u30AB\u30FC\u30BD\u30EB\u306E\u3042\u308B\u30BF\u30B9\u30AF\u3092\u9078\u629E\u3059\u308B (\u30C1\u30A7\u30C3\u30AF\u30DC\u30C3\u30AF\u30B9\u306B\u30C1\u30A7\u30C3\u30AF\u3092\u5165\u308C\u308B)\u3002\u9078\u629E\u6E08\u307F\u306E\u30BF\u30B9\u30AF\u306E\u5834\u5408\u3001\u30C1\u30A7\u30C3\u30AF\u3092\u5916\u3059\u3002</dd>'
+ ''
+ ' <dt><kbd>k</kbd> (Move Up)</dt>'
+ ' <dd>\u524D\u306E\u30BF\u30B9\u30AF (\u4E0A\u306E\u30BF\u30B9\u30AF) \u306B\u30AB\u30FC\u30BD\u30EB\u3092\u79FB\u52D5\u3055\u305B\u308B\u3002</dd>'
+ ''
+ ' <dt><kbd>j</kbd> (Move Down)</dt>'
+ ''
+ ' <dd>\u6B21\u306E\u30BF\u30B9\u30AF (\u4E0B\u306E\u30BF\u30B9\u30AF) \u306B\u30AB\u30FC\u30BD\u30EB\u3092\u79FB\u52D5\u3055\u305B\u308B\u3002</dd>'
+ '</dl>'
+ ''
+ '<h4>\u5927\u304D\u306A\u79FB\u52D5</h4>'
+ ''
+ '<dl>'
+ ' <dt><kbd>Ctrl + Shift + \u53F3\u77E2\u5370</kbd> (Move Next)</dt>'
+ ' <dd>\u6B21\u306E\u30EA\u30B9\u30C8\u3078\u79FB\u52D5\u3002</dd>'
+ ''
+ ' <dt><kbd>Ctrl + Shift + \u5DE6\u77E2\u5370</kbd> (Move Previous)</dt>'
+ ' <dd>\u524D\u306E\u30EA\u30B9\u30C8\u3078\u79FB\u52D5\u3002</dd>'
+ ''
+ ' <dt><kbd>Ctrl + Shift + 6</kbd> (Switch to Overview)</dt>'
+ ' <dd>\u300C\u5168\u4F53\u300D\u30DA\u30FC\u30B8\u3078\u79FB\u52D5\u3002</dd>'
+ ''
+ ' <dt><kbd>Ctrl + Shift + 7</kbd> (Switch to Tasks)</dt>'
+ ' <dd>\u300C\u30BF\u30B9\u30AF\u300D\u30DA\u30FC\u30B8\u3078\u79FB\u52D5\u3002</dd>'
+ ''
+ ' <dt><kbd>Ctrl + Shift + 8</kbd> (Switch to Locations)</dt>'
+ ' <dd>\u300C\u5834\u6240\u300D\u30DA\u30FC\u30B8\u3078\u79FB\u52D5\u3002</dd>'
+ ''
+ ' <dt><kbd>Ctrl + Shift + 9</kbd> (Switch to Contacts)</dt>'
+ ' <dd>\u300C\u30B3\u30F3\u30BF\u30AF\u30C8\u300D\u30DA\u30FC\u30B8\u3078\u79FB\u52D5\u3002</dd>'
+ ''
+ ' <dt><kbd>Ctrl + Shift + 0</kbd> (Switch to Settings)</dt>'
+ ' <dd>\u300C\u8A2D\u5B9A\u300D\u30DA\u30FC\u30B8\u3078\u79FB\u52D5\u3002</dd>'
+ ''
+ ' <dt><kbd>Ctrl + Shift + l</kbd> (Switch to Login screen)</dt>'
+ ' <dd>\u30ED\u30B0\u30A4\u30F3\u30FB\u30DA\u30FC\u30B8\u3078\u79FB\u52D5 (?\uFF09</dd>'
+ '</dl>'
+ ''
+ '<h4>\u305D\u306E\u4ED6</h4>'
+ ''
+ '<dl>'
+ ' <dt><kbd>Ctrl + Shift + /</kbd> (Search)</dt>'
+ ''
+ ' <dd>\u691C\u7D22\u3092\u958B\u59CB\u3059\u308B (\u30AB\u30FC\u30BD\u30EB\u3092\u691C\u7D22\u30DC\u30C3\u30AF\u30B9\u3078\u79FB\u52D5)\u3002</dd>'
+ ''
+ ' <dt><kbd>z</kbd> (Undo)</dt>'
+ ' <dd>Undo (\u3084\u308A\u76F4\u3057) \u3092\u5B9F\u884C\u3002</dd>'
+ ''
+ ' <dt><kbd>TAB</kbd></dt>'
+ ' <dd>\u6B21\u306E\u7DE8\u96C6\u9818\u57DF\u306B\u30AB\u30FC\u30BD\u30EB\u3092\u79FB\u52D5\u3002</dd>'
+ ''
+ ' <dt><kbd>Esc</kbd></dt>'
+ ' <dd>\u7DE8\u96C6\u9818\u57DF\u304B\u3089\u30AB\u30FC\u30BD\u30EB\u3092\u53D6\u308A\u9664\u304F\u3002</dd>'
+ '</dl>'
;

main();

