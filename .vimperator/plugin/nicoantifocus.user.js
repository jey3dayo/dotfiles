// ==UserScript==
// @name           NicoAntiFocus
// @namespace      http://d.hatena.ne.jp/nokturnalmortum/20080802/1217633913
// @description    ニコニコ動画で、Flashプレイヤーにフォーカスしないようにする。
// @include        http://www.nicovideo.jp/watch/*
// @include        http://de.nicovideo.jp/watch/*
// @include        http://es.nicovideo.jp/watch/*
// @include        http://tw.nicovideo.jp/watch/*
// ==/UserScript==
//
// License:
//    Creative Commons 2.1 (Attribution + Share Alike)
//
// Neko:
//    nicontroller.js 用？スクリプト。
//    うっかりプレイヤーのボタンを押すとVimperator のキーが効かなくなるので、無理矢理フォーカスしないようにする。
//
// Author:
//    anekos
//    http://d.hatena.ne.jp/nokturnalmortum/20080802/1217633913
//
// Link:
//    Vimperator 用の(ニコニコ動画|YouTube)プラグイン
//    http://vimperator.kurinton.net/plugins/stella.html

(function (es) {

  for (var i = es.length; i --> 0; hocusPocus(es[i]));

  function hocusPocus (elem) {
    var doubleClick = false;
    elem.addEventListener(
      'focus',
      function () {
        if (doubleClick) {
          doubleClick = false;
        } else {
          doubleClick = true;
          setTimeout(function () { doubleClick = false; }, 500);
          setTimeout(function () { elem.blur(); }, 0);
        }
      },
    true);
  }

})(document.getElementsByTagName('embed'));

