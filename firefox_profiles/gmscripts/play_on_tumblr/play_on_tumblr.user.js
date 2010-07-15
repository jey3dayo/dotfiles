// ==UserScript==
// @name           play on tumblr
// @namespace      tag:mattn.jp@gmail.com,2008-04-03:/coderepos.org
// @description    play current image or video on tumblr dashboard with 'ENTER' key. open notes with 'h' key. like it with 'l' key. if won't work, pray on tumblr!
// @include        http://www.tumblr.com/dashboard*
// @include        http://www.tumblr.com/show/*
// @include        http://www.tumblr.com/tumblelog/*
// @include        http://www.tumblr.com/tagged/*
// ==/UserScript==

(function() {
  var boot = function() {
    with (window.Minibuffer) {
      var click = function(n) {
        var e = document.createEvent('MouseEvents');
        e.initMouseEvent("click",true,true,unsafeWindow,1,10,50,10,50,0,0,0,0,1,n);
        n.dispatchEvent(e);
      };

      addShortcutkey({
        key: "RET",
        description: 'tumblr.play',
        command: function() {
          try { execute( 'tumblr.play', execute('current-node')); } catch (e) { }
        }});

      addShortcutkey({
        key: "h",
        description: 'tumblr.reblogcount',
        command: function() {
          try { execute( 'tumblr.reblogcount', execute('current-node')); } catch (e) { }
        }});

      addShortcutkey({
        key: "l", 
        description: 'tumblr.like', 
        command: function() {
          try { execute( 'tumblr.like', execute('current-node')); } catch(e) { }
        }});

      addCommand({
        name: 'tumblr.play',
        command: function(stdin) {
          try {
            if (!stdin.length) stdin = execute('current-node');
            var img = $X('.//div[starts-with(@id, "highres_photo")]', stdin[0]);
            for (var n = 0; n < img.length; n++) {
              if (img[n].style.display != 'none') {
                click($X('./a', img[n])[0]);
                return stdin;
              }
              else{
                click($X('./preceding-sibling::a[1]', img[n])[0]);
                return stdin;
              }
            }
            var mov = $X('.//div[contains(@id,"watch_") and .//a]', stdin[0]);
            for (var n = 0; n < mov.length; n++) {
              if (mov[n].style.display != 'none') {
                click($X('.//a', mov[n])[0]);
                return stdin;
              }
            }
            var timg = $X('.//img[contains(@src,"media.tumblr.com/tumblr_")]', stdin[0]);
            for (var n = 0; n < timg.length; n++) {
              click(timg[n]);
            }
            return stdin;
          } catch (e) { }
          return stdin;
        }});

      addCommand({
        name: 'tumblr.reblogcount',
        command: function(stdin) {
          try {
            if (!stdin.length) stdin = execute('current-node');
            var count = $X('.//a[contains(concat(" ",@class," "), " reblog_count ")]', stdin[0]);
            for (var n = 0; n < count.length; n++) {
              click(count[n]);
              return stdin;
            }
          } catch (e) { }
          return stdin;
        }});

      addCommand({
        name: "tumblr.like",
        command: function(stdin) {
          try {
            if (!stdin.length) stdin = execute('current-node');
            var count = $X('.//input[contains(concat(" ",@class," "), " like_button ")]', stdin[0]);
              for (var n = 0; n < count.length; n++) {
              if(!count[n].clientWidth) continue;
              count[n].click();
              return stdin;
            }
          } catch(e) {}
          return stdin;
        }});
    }
  }

  if (window.Minibuffer) {
    boot();
  } else {
    window.addEventListener('GM_MinibufferLoaded', boot, false);
  }
})()
