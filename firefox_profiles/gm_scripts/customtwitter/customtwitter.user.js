// ==UserScript==
// @name           CustomTwitter
// @namespace      h13i32maru
// @include        http://twitter.com/*
// @include        https://twitter.com/*
// @exclude        http://twitter.com/invitations/*
// @exclude        http://twitter.com/settings/*
// @exclude        http://twitter.com/goodies/*
// @exclude        https://twitter.com/invitations/*
// @exclude        https://twitter.com/settings/*
// @exclude        https://twitter.com/goodies/*
// @resource       style http://h13i32maru.sakura.ne.jp/gm/custom_twitter/20100827/style.css
// @resource       gstyle http://h13i32maru.sakura.ne.jp/gm/custom_twitter/20100827/gstyle.css
// ==/UserScript==
(function()
{

  function $(id){ return document.getElementById(id); }

  GME = {
    scriptName : "CustomTwitter",
    scriptURL : "http://userscripts.org/scripts/show/67940",
    scriptVersion : "20100827",
    scriptVersionJS : "http://h13i32maru.sakura.ne.jp/gm/custom_twitter/version.js" ,
    //{{{isGM : function()
    isGM : function()
    {
      if(typeof(unsafeWindow) == "object"){ return true;}
      else{ return false; }
    },
    //}}}
    //{{{getValue : function(key , _default , notConvert)
    getValue : function(key , _default , notConvert)
    {
      if(window.localStorage)
      {
        var value = window.localStorage.getItem(key);
        if(value != null)
        {
          //localStorageは文字のみの扱いのみなので、型変換を行う。
          //ただしnotConvertがtrueの場合、型変換を行わない
          if(notConvert != false)
          {
            if(value == "true"){ value = true; }
            else if(value == "false"){ value = false; }
            else if(value.match(/^[0-9.]+$/)){ value = Number(value); }
          }
          return value;
        }
        else { return _default}
      }
      else if(typeof(GM_getValue) == "function")
      {
        return GM_getValue(key , _default);
      }
      else
      {
        throw "window.localStorage and GM_getValue are not defined";
      }
    },
    //}}}
    //{{{setValue : function(key , value)
    setValue : function(key , value)
    {
      if(window.localStorage)
      {
        window.localStorage.setItem(key , value);
      }
      else if(typeof(GM_setValue) == "function")
      {
        GM_setValue(key , value);
      }
      else
      {
        throw "window.localStorage and GM_setValue are not defined";
      }
    },
    //}}}
    //{{{deleteValue : function(key)
    deleteValue : function(key)
    {
      if(window.localStorage)
      {
        window.localStorage.removeItem(key);
      }
      else if(typeof(GM_deleteValue) == "function")
      {
        GM_deleteValue(key);
      }
      else
      {
        throw "window.localStorage and GM_deleteValue are not defined";
      }
    },
    //}}}
    //{{{listValues : function()
    listValues : function()
    {
      if(window.localStorage)
      {
        //localStorage.length is not availabled in user script
        var list = [];
        var key;
        try{
          for(var i = 0 ; ; i++)
          {
            key = window.localStorage.key(i);
            if(!key){ break; }
            list.push(key);
          }
        }
        catch(e)
        {
        }
        return list;
      }
      else if(typeof(GM_listValues) == "function")
      {
        return GM_listValues();
      }
      else
      {
        throw "window.localStorage and GM_listValues are not defined";
      }
    },
    //}}}
    //{{{addStyle : function(text , id)
    addStyle : function(text , id)
    {
      if(document.getElementById(id)){ return; }

      var e = document.createElement("style");
      if(id){ e.id = id; }
      e.textContent = text;
      document.getElementsByTagName("head")[0].appendChild(e);
    },
    //}}}
    //{{{xmlhttpRequest : function(param)
    xmlhttpRequest : function(param)
    {
      if(typeof(GM_xmlhttpRequest) == "function")
      {
        GM_xmlhttpRequest(param);
      }
      else
      {
        GME.sendRequest(param.url , true , param.method , param.data || "" , param.onload , "");
      }
    },
    //}}}
    //{{{log : function(data)
    log : function(data)
    {
      if(typeof(GM_log) == "function")
      {
        GM_log(data);
      }
      else if(typeof(console.log) == "function")
      {
        consoloe.log(data);
      }
    },
    //}}}
    //{{{openInTab : function(url)
    openInTab : function(url)
    {
      if(typeof(GM_openInTab) == "function")
      {
        GM_openInTab(url);
      }
      else
      {
        window.open(url);
      }
    },
    //}}}
    //{{{sendRequest : function(url , async , method , data , callback , callbackArgument)
    sendRequest : function(url , async , method , data , callback , callbackArgument)
    {
      var req = new XMLHttpRequest;

      if(async){
        req.onreadystatechange = function(){ if(req.readyState == 4) callback(req , callbackArgument); }
      }

      if(method.toUpperCase() == "GET" && data.length > 0){
        url += "?" + data;
        data = "";
      }

      req.open(method , url , async);
      req.setRequestHeader("Content-Type" , "application/x-www-form-urlencoded; charset=UTF-8");
      req.send(data);
      if(!async){ callback(req , callbackArgument);}
    },
    //}}}
    //{{{addStyleEx : function(id , resourceName , url)
    addStyleEx : function(id , resourceName , url)
    {
      if(typeof(GM_getResourceText) == "function")
      {
        GME.addStyleResource(id , resourceName);
      }
      else
      {
        GME.addStyleURL(id , url);
      }
    },
    //}}}
    //{{{addStyleURL : function(id , url)
    addStyleURL : function(id , url)
    {
      var e = document.createElement("link");
      e.id = id;
      e.rel = "stylesheet";
      e.type = "text/css";
      e.href = url;
      document.getElementsByTagName("head")[0].appendChild(e);
    },
    //}}}
    //{{{addStyleResource : function(id , resourceName)
    addStyleResource : function(id , resourceName)
    {
      if(typeof(GM_getResourceText) == "function")
      {
        var e = document.createElement("style");
        e.id = id;
        e.textContent = GM_getResourceText(resourceName);
        document.getElementsByTagName("head")[0].appendChild(e);
      }
    },
    //}}}
    //{{{addScriptURL : function(id , url)
    addScriptURL : function(id , url)
    {
      var s = document.createElement("script");
      s.id = id;
      s.type = "text/javascript";
      s.src = url;
      document.body.appendChild(s);
    },
    //}}}
    //{{{removeById : function(id)
    removeById : function(id)
    {
      var e = document.getElementById(id);
      if(e)
      {
        e.parentNode.removeChild(e);
        return true;
      }
      else
      {
        return false;
      }
    },
    //}}}
    //{{{insertBefore : function(elm , after)
    insertBefore : function(elm , after)
    {
      if(after){ after.parentNode.insertBefore(elm , after); }
    },
    //}}}
    //{{{checkVersion : function()
    checkVersion : function()
    {
      document.addEventListener("CustomTwitterCheckVersion" , execCheckVersion , false);
      GME.addScriptURL("h13i32maru-check-version" , GME.scriptVersionJS);

      function execCheckVersion(ev)
      {
        //var latestVersion = ev.command;
        var latestVersion = document.getElementById("custom-twitter-latest-version").textContent;
        if(GME.scriptVersion < latestVersion)
        {
          if(GME.getValue("checkVersion" , true) == false){ return; }

          GME.setValue("checkVersion" , false);

          //GMでは上書きインストールで良いが、Chromeでは一度アンインストールが必要
          var installText = GME.scriptName + "の新しいバージョンがリリースされています。\n以下のダウンロードサイトから最新版をインストールすることができます。\n" + GME.scriptURL;
          if(GME.isGM() == false)
          {
            installText += "\n\n※Google Chromeの場合、一度" + GME.scriptName +"をアンインストールしてから最新版をインストールしてください";
          }
          installText += "\n\nダウンロードサイトへ移動しますか?";

          if(confirm(installText))
          {
            //event内ではGM_openInTabが使えない?
            //GME.openInTab(GME.scriptURL);

            window.open(GME.scriptURL , "_self");
          }
        }
        else
        {
          GME.setValue("checkVersion" , true);
        }
      }
    }
    //}}}
  };

  customUser = {
    //{{{init : function()
    init : function()
    {
      customUser.updateTimeline();
      customUser.custom();

      var more = document.getElementById("more");
      if(more){ more.addEventListener("click" , customUser.readMore , true); }

      var newResults = document.getElementById("new_results_notification");
      if(newResults){ newResults.addEventListener("click" , customUser.newResultsNotification , true); }

      document.body.addEventListener("AutoPagerize_DOMNodeInserted" , customUser.autoPagerize , true);

      if($("home"))
      {
        $("home_tab").addEventListener("click" , customUser.tabLoading , true);
        $("replies_tab").addEventListener("click" , customUser.tabLoading , true);
        $("direct_messages_tab").addEventListener("click" , customUser.tabLoading , true);
        $("favorites_tab").addEventListener("click" , customUser.tabLoading , true);

        //retweets_by_other_tabに何故かaddEventできない。ページロード後に要素が書き換えられてしまっている？
        $("retweets_by_others_tab").addEventListener("click" , customUser.tabLoading , true);
      }
    },
    //}}}
    //{{{lightMe : function()
    //@replyで自分宛に返信されているエントリーを目立たせる
    lightMe : function()
    {
      if(document.body.id == "replies"){ return; }

      var me;
      if(document.body.id == "home")
      {
        me = document.getElementById("me_name").textContent;
      }
      else if($("profile_link"))
      {
        me = $("profile_link").href.replace(/^.*twitter\.com\// , "");
      }
      else
      {
        return;
      }

      var list = document.getElementsByClassName("entry-content");
      for(var i = 0 ; i < list.length ; i++)
      {
        if(list[i].textContent.match("@" + me))
        {
          list[i].parentNode.parentNode.parentNode.style.backgroundColor = "#ffcccc";
        }
      }
    },
  //}}}
    //{{{absTimestamp : function()
    //エントリーの時間を絶対時刻で表示する
    absTimestamp : function()
    {
      var list = document.getElementsByClassName("timestamp");
      var data;
      var stamp;
      var weekList = ["日" , "月" , "火" , "水" , "木" , "金" , "土"];
      var weekListEn = {Sunday:"日" , Monday:"月" , Tuesday:"火" , Wednesday:"水" , Thursday:"木" , Friday:"金" , Saturday:"土"};
      var monthListEn = {January:"01" , February:"02" , March:"03" , April:"04" , May:"05" , June:"06" , July:"07" , August:"08" , September:"09" , October:"10" , November:"11" , December:"12"};
      var dateString;
      var weekIndex;
      for(var i = 0 ; i < list.length ; i++)
      {
        //すでに絶対時刻を追加しているものはcontinue
        if(list[i].textContent.match(/20[0-9[0-9]/)){ continue; }

        //dataに絶対時刻が入っている
        data = eval(list[i].getAttribute("data"));
        stamp = new Date(data);

        try
        {
          weekIndex = parseInt(stamp.toLocaleFormat("%w"));//toLocaleFormatでは曜日(日本語)が文字化けして返されるため
          dateString = stamp.toLocaleFormat("%Y/%m/%d(@@) %H:%M:%S").replace("@@" , weekList[weekIndex]);
        }
        catch(error)
        {
          //for google chrome
          var dateStringList = stamp.toLocaleDateString().split(",");
          var year = dateStringList[2];
          var month = dateStringList[1].split(" ")[1];
          var day = dateStringList[1].split(" ")[2];
          var week = dateStringList[0];
          var dateStringFormat = year + "/" + monthListEn[month] + "/" + day + " (" + weekListEn[week] + ")";
          dateString = dateStringFormat + " " + stamp.toLocaleTimeString();
          //dateString = stamp.toLocaleDateString() + " " + stamp.toLocaleTimeString();

        }

        list[i].textContent = dateString + " " + list[i].textContent;
      }
    },
    //}}}
    //{{{addMenu : function()
    //show , icon , hideのメニューを追加追加する
    addMenu : function()
    {
      if(document.body.id != "home"){ return; }

      var list = document.getElementsByClassName("hentry");
      var span;
      var ul;
      var li;
      var name;
      var menuObj = [
                      ["default" , "の表示を元に戻す" , this.show],
                      ["light" , "を強調して表示する" , this.light],
                      ["icon" , "のツイートは表示せず、アイコンだけを表示する" , this.icon],
                      ["hide" , "を表示しない" , this.hide]
                    ];

      for(var i = 0 ; i < list.length ; i++)
      {
        //custom-userがすでにあればcontinue
        if(list[i].getElementsByClassName("custom-user").length > 0){ continue; }

        name = list[i].className.match(/ u-[^ ]* /).join("").replace(/ /g , "").replace(/^u-/ , "");

        ul = document.createElement("ul");

        for(var j = 0 ; j < menuObj.length ; j++)
        {
          li = document.createElement("li");
          li.textContent = menuObj[j][0];
          li.setAttribute("data" , name);
          li.title = name + menuObj[j][1];
          li.addEventListener("click" , menuObj[j][2] , true);
          ul.appendChild(li);
        }

        span = document.createElement("span");
        span.className = "custom-user";
        span.innerHTML = ">";
        list[i].getElementsByClassName("entry-meta")[0].insertBefore(span , list[i].getElementsByClassName("entry-meta")[0].firstChild);
        span.appendChild(ul);
      }
    },
    //}}}
    //{{{show : function(name)
    show : function(name)
    {
      var name = this.getAttribute ? this.getAttribute("data") : name;
      GME.removeById("custom-user-" + name); 

      GME.deleteValue(name);
    },
    //}}}
    //{{{hide : function(name)
    hide : function(name)
    {
      var name = this.getAttribute ? this.getAttribute("data") : name;

      var style = "";
      style += ".u-@ { display:block !important; border-bottom-style:none !important; width:100px !important; padding:0 !important;}\n";
      style += ".u-@ > span { display:none !important; }\n";
      //style += " .u-@:before { font-family:arial !important; font-size:10px; white-space:pre !important; content:'@\\A'; color:#44aaff; }\n";
      style += ".u-@:before { font-family:arial !important; font-size:10px; content:'@'; color:#44aaff; }\n";
      style += "body[gstyle='true'] .u-@:before { margin-left:10px; }\n";
      style += ".u-@:hover { width:100% !important; padding:10px 0 !important; }\n";
      style += ".u-@hover[gstyle='false']{ border-bottom-style:solid !important;}\n";
      style += ".u-@:hover > span { display:block !important; }\n";
      style += ".u-@:hover:before { display:none; }\n";

      style = style.replace(/@/g , name);

      GME.removeById("custom-user-" + name); 
      GME.addStyle(style , "custom-user-" + name);

      GME.setValue(name , "hide");
/*
      var name = this.getAttribute ? this.getAttribute("data") : name;
      var style = "li.u-" + name + " { opacity:0; } li.u-" + name + ":hover { opacity:1; }";
      GME.removeById("custom-user-" + name); 
      GME.addStyle(style , "custom-user-" + name);

      GME.setValue(name , "hide");
*/
    },
    //}}}
    //{{{icon : function(name)
    icon : function(name)
    {
      var name = this.getAttribute ? this.getAttribute("data") : name;
      var style = "li.u-" + name + " span.status-body { opacity:0; } li.u-" + name + ":hover span.status-body{ opacity:1; }";
      GME.removeById("custom-user-" + name); 
      GME.addStyle(style , "custom-user-" + name);

      GME.setValue(name , "icon");
    },
    //}}}
    //{{{light : function(name)
    light : function(name)
    {
      var name = this.getAttribute ? this.getAttribute("data") : name;
      var style = "li.u-" + name + "{ background:#ffff77 !important; }";
      GME.removeById("custom-user-" + name); 
      GME.addStyle(style , "custom-user-" + name);

      GME.setValue(name , "light");
    },
    //}}}
    //{{{custom : function()
    custom : function()
    {
      if(document.body.id != "home"){ return; }

      var list = GME.listValues();
      var name;
      //for eachはchromeで使えない?
      for(var i = 0 ; i < list.length ; i++)
      {
        name = list[i];
        switch(GME.getValue(name))
        {
          case "hide": this.hide(name); break;
          case "icon": this.icon(name); break;
          case "light": this.light(name); break;
        }
      }
    },
    //}}}
    //{{{updateTimeline : function()
    updateTimeline : function()
    {
      customUser.lightMe();
      customUser.absTimestamp();
      customUser.addMenu();
    },
    //}}}
    //{{{newResultsNotification : function()
    newResultsNotification : function()
    {
      //すぐにupdateTimelineを実行すると絶対時刻が反映されないので500ms後に実行。
      setTimeout(customUser.updateTimeline , 500);
    },
    //}}}
    //{{{readMore : function()
    //"もっと読む"がクリックされたときにエントリーの内容を更新するためにlightMeやabsTimestampを実行する
    readMore : function()
    {
      //"もっと読む"がクリックされる前のエントリーの数とクリック後のエントリーの数を比較してロードが完了したかどうかを判断する
      var oldCount = document.getElementsByClassName("hentry").length;
      function wait()
      {
        var newCount = document.getElementsByClassName("hentry").length;
        if(oldCount == newCount)//数が同じながらまだロードは完了していない
        {
          setTimeout(wait , 500);
        }
        else
        {
          customUser.updateTimeline();
          document.getElementById("more").addEventListener("click" , customUser.readMore , true);
        }
      }
      wait();
    },
    //}}}
    //{{{autoPagerize : function()
    autoPagerize : function()
    {
      var length = $("timeline").getElementsByClassName("status").length;
      if(length % 20 == 0)
      {
        customUser.updateTimeline();
      }
    },
    //}}}
    //{{{tabLoading : function()
    tabLoading : function()
    {
      function wait(elm , count)
      {
        if(count == 0){ return; }

        if(/loading/.test(elm.className))
        {
          setTimeout(wait , 500 , elm , count - 1);
        }
        else
        {
          customUser.updateTimeline();
          var more = document.getElementById("more");
          if(more){ more.addEventListener("click" , customUser.readMore , true); }
        }
      }

      setTimeout(wait , 500 , this , 10);
    }
    //}}}
  };

  customStyle = {
    //{{{init : function()
    init : function()
    {

      document.body.setAttribute("gstyle" , "false");

      customStyle.addGoogleButton();

      customStyle.addElementForGoogle();

      if(GME.getValue("gstyle" , false))
      {
        customStyle.onGStyle();
        customStyle.iconConfig();
      }
    },
    //}}}
    //{{{addElementForGoogle : function()
    addElementForGoogle : function()
    {
      //google-logo
      (function()
      {
        if(document.getElementById("google-logo")){return;}
        if(document.body.id == "home" || document.body.id == "replies" || document.body.id == "favorites" || document.body.id.match(/retweet/) || document.body.id == "search")
        {
          var statusParent = document.getElementById("status").parentNode;
          var a = document.createElement("a");
          a.id = "google-logo";
          a.innerHTML = '<img src="http://www.google.co.jp/intl/en_com/images/srpr/logo1w.png">';
          a.href = "/";
          statusParent.insertBefore(a , statusParent.firstChild);
        }

        if($("direct_message_form"))
        {
          var a = document.createElement("a");
          a.id = "google-logo-absolute";
          a.innerHTML = '<img src="http://www.google.co.jp/intl/en_com/images/srpr/logo1w.png">';
          a.href = "/";
          GME.insertBefore(a , $("direct_message_form"));
        }

        if(document.body.id == "list_memberships" || document.body.id == "list_subscriptions")
        {
          var a = document.createElement("a");
          a.id = "google-logo-absolute";
          a.innerHTML = '<img src="http://www.google.co.jp/intl/en_com/images/srpr/logo1w.png">';
          a.href = "/";
          $("content").appendChild(a);
        }
      })();

      //side-icon
      (function(){
        if(document.getElementById("side-icon-last-li")){return;}

        var list = ["me_name" , "following_count" , "follower_count" , "lists_count"];
        for(var i in list)
        {
          var elm = document.getElementById(list[i]);
          if(! elm){ continue; }
          var sideIcon = document.createElement("span");
          sideIcon.id = "side-icon" + i;
          sideIcon.className = "side-icon";
          GME.insertBefore(sideIcon , elm);
        }

        var sideIconLast = document.createElement("li");
        sideIconLast.id = "side-icon-last-li";
        sideIconLast.innerHTML = "<span id='side-icon-last' class='side-icon'></span><span>その他のツール</span>";
        var elm = document.getElementById("saved_searches");
        if(elm){ elm.getElementsByTagName("ul")[0].appendChild(sideIconLast); }
      })();

      //top-navigation-dummy
      (function(){
        if(document.getElementById("top-navigation-dummy")){return;}

        var span = document.createElement("span");
        span.id = "top-navigation-dummy";
        span.innerHTML = "<span>ウェブ履歴</span> | <span>検索設定</span> | <span>ログイン</span>";
        document.getElementById("header").appendChild(span);
      })();

      //search-option
      (function(){
        if(document.getElementById("chars_left_notice_dummy")){return;}

        if(! document.getElementById("chars_left_notice")){ return; }

        var span = document.createElement("span");
        span.id = "chars_left_notice_dummy";
        span.innerHTML = ",000,000 件 ( 0.11秒 )";
        document.getElementById("chars_left_notice").appendChild(span);

        span = document.createElement("span");
        span.id = "search-option-dummy";
        span.innerHTML = "検索オプション";
        document.getElementById("chars_left_notice").appendChild(span);
      })();

      //アイコン設定リンク
      (function(){
        var navi = document.getElementsByClassName("top-navigation")[0];
        if(! navi){ return; }

        var li = document.createElement("li");
        li.id = "icon-config";
        li.title = "アイコンの設定";
        li.innerHTML = "<a>アイコン</a>";
        li.addEventListener("click" , customStyle.iconConfig , true);
        navi.appendChild(li);
      })();

      //footer
      (function(){
        if(!$("pagination")){return;}

        var table = document.createElement("table");
        table.id = "google-footer";
        table.innerHTML = "<tbody><tr><td style='vertical-align:top;'><span class='o-logo-first'></span></td><td><span class='o-logo-red'></span><span style='font-weight:bold;color:#000'>1</span></td><td><span class='o-logo'></span>2</td><td><span class='o-logo'></span>3</td><td><span class='o-logo'></span>4</td><td><span class='o-logo'></span>5</td><td><span class='o-logo'></span>6</td><td><span class='o-logo'></span>7</td><td><span class='o-logo'></span>8</td><td><span class='o-logo'></span>9</td><td><span class='o-logo'></span>10</td><td><span class='o-logo-last'></span><span style='color:#1111cc;text-decoration:underline;font-weight:bold;'>次へ</span></td></tr></tbody>";
        GME.insertBefore(table , document.getElementById("pagination"));

        var dummy = document.createElement("div");
        dummy.id = "dummy-textarea";
        GME.insertBefore(dummy , document.getElementById("pagination"));
      })();

      //front
      (function(){
        if(document.body.id != "front"){ return; }

        var span = document.createElement("span");
        span.id = "google-nav-dummy";
        span.innerHTML = "<a>ウェブ</a><a>画像</a><a>動画</a><a>地図</a><a>ニュース</a><a>書籍</a><a>Gmail</a><a>その他</a>▼";
        document.body.appendChild(span);

        var div = document.createElement("div");
        div.id = "google-nav-dummy-separator";
        document.body.appendChild(div);

        var twitterTitle = document.createElement("span"); 
        twitterTitle.id = "twitter-title";
        twitterTitle.textContent = "Twitter";
        $("signin_menu").appendChild(twitterTitle);
      })();
    },
    //}}}
    //{{{iconConfig : function(ev)
    iconConfig : function(ev)
    {
      var icon = GME.getValue("userIcon" , 0);
      if(ev){ icon = prompt("各ユーザのアイコンを表示する場合は1を指定してください。\n表示しない場合は0を指定してください" , icon); }
      if(icon == null){ return; }

      GME.setValue("userIcon" , icon);

      switch(parseInt(icon))
      {
        case 0:
          GME.removeById("gstyle-user-icon");
          break;
        case 1:
          GME.addStyle("span.thumb , span.thumb .photo { display:inline-block !important;} span.status-body{ margin-left: 20px !important;}" , "gstyle-user-icon");
          break;
      }
    },
    //}}}
    //{{{addGoogleButton : function()
    addGoogleButton : function()
    {
      var a = document.createElement("a");
      a.innerHTML = "G";
      a.className = "google-button";
      a.title = "Googleスタイル";
      a.addEventListener("click" , customStyle.toggleGStyle , true);
      document.body.appendChild(a);

      var a2 = a.cloneNode(true);
      a2.innerHTML = "標準";
      a2.className = "google-button2";
      a2.title = "標準スタイル";
      a2.addEventListener("click" , customStyle.toggleGStyle , true);
      document.body.appendChild(a2);
   },
    //}}}
    //{{{onGStyle : function()
    onGStyle : function()
    {

      GME.addStyleEx("google-style" , "gstyle" , "http://h13i32maru.sakura.ne.jp/gm/custom_twitter/" + GME.scriptVersion + "/gstyle.css");

      if(document.body.id == "home" || document.body.id == "replies" || document.body.id == "favorites" || document.body.id.match(/retweet/))
      {
        document.getElementById("tweeting_button").firstChild.textContent = "検索";
      }

      if(document.body.id == "front")
      {
        $("username").setAttribute("title" , "Twitter : ユーザ名かメールアドレス");
        $("password").setAttribute("title" , "Twitter : パスワード");

        with($("signin_submit"))
        {
          setAttribute("value" , "Google 検索");
          setAttribute("title" , "Twitter : ログイン");
        }
        with(document.getElementsByClassName("remember")[0].getElementsByTagName("label")[0])
        {
          innerHTML = "I'm Feeling Lucky";
          setAttribute("title" , "Twitter : 次回から入力を省略");
        }

        with($("resend_password_link"))
        {
          innerHTML = "検索オプション";
          setAttribute("title" , "Twitter : パスワードを忘れた?");
        }

        with($("forgot_username_link"))
        {
          innerHTML = "言語ツール";
          setAttribute("title" , "Twitter : ユーザ名を忘れた?");
        }
      }

      setTimeout(function()
      {
        try{
          unsafeWindow.document.origTitle = document.title;
          unsafeWindow.document.title = "Google 検索";
        }
        catch(e)
        {
        }
      } , 500);//少し待ってから変更しないと、twitter.comによって上書きされる

      var link = document.createElement("link");
      link.id = "google-style-icon";
      link.rel = "icon";
      link.type = "image/x-icon";
      link.href = "http://www.google.co.jp/favicon.ico";
      document.getElementsByTagName("head")[0].appendChild(link);

      GME.setValue("gstyle" , true);

      document.body.setAttribute("gstyle" , "true");
    },
    //}}}
    //{{{offGStyle : function() 
    offGStyle : function() 
    {

      GME.removeById("google-style"); 

      if(document.body.id == "home" || document.body.id == "replies" || document.body.id == "favorites" || document.body.id.match(/retweet/))
      {
        document.getElementById("tweeting_button").firstChild.textContent = "ツイート";
      }

      if(document.body.id == "front")
      {
        $("username").removeAttribute("title");
        $("password").removeAttribute("title");

        with($("signin_submit"))
        {
          setAttribute("value" , "ログイン");
          removeAttribute("title");
        }
        with(document.getElementsByClassName("remember")[0].getElementsByTagName("label")[0])
        {
          innerHTML = "次回から入力を省略";
          removeAttribute("title");
        }

        with($("resend_password_link"))
        {
          innerHTML = "パスワードを忘れた?<br/>";
          removeAttribute("title");
        }

        with($("forgot_username_link"))
        {
          innerHTML = "ユーザ名を忘れた?";
          setAttribute("title" , "ユーザ名を忘れたを覚えている場合は、メールアドレスでログインしてみてください");
        }
 
      }

      GME.removeById("google-style-icon"); 
      var link = document.createElement("link");
      link.rel = "icon";
      link.type = "image/x-icon";
      link.href = "/favicon.ico";
      document.getElementsByTagName("head")[0].appendChild(link);

      try { unsafeWindow.document.title = unsafeWindow.document.origTitle; }
      catch(e){}

      GME.removeById("gstyle-user-icon");

      GME.setValue("gstyle" , false);

      document.body.setAttribute("gstyle" , "false");
    },
    //}}}
    //{{{toggleGStyle : function()
    toggleGStyle : function()
    {
      if(document.getElementById("google-style"))
      {
        customStyle.offGStyle();
      }
      else
      {
        customStyle.onGStyle();
      }
    } 
    //}}}
  };

  customReply = {
    //{{{init : function()
    init : function()
    {
      if(document.body.id == "replies")
      {
        customReply.updateReadReply();
      }
      else if(document.body.id == "home")
      {
        customReply.checkReply();
        document.getElementById("replies_tab").addEventListener("click" , customReply.updateReadReply2 , true);
        document.getElementById("home_tab").addEventListener("click" , customReply.checkReply , true);
        setInterval(customReply.checkReply , 120 * 1000);
      }
    },
    //}}}
    //{{{checkReply : function()
    //すでに読んだreplyと最新のreplayを比較する
    checkReply : function()
    {
      GME.xmlhttpRequest({method:"GET" , url:"http://twitter.com/replies" , onload:onload});
      function onload(res)
      {
        var latestReply = res.responseText.match(/id="status_[0-9]*"/);
        if(latestReply == null){return;}

        latestReply = latestReply.toString().replace(/[^0-9]/g , "").toString();

        GME.removeById("unread-icon");

        if(GME.getValue("readReply" , "0" , false) < latestReply)
        {
          document.getElementById("replies_tab").getElementsByTagName("a")[0].innerHTML += "<span id='unread-icon'>*</span>";
        }
      }
    },
  //}}}
    //{{{updateReadReply : function()
    //#repliesを新しいページで表示したときに読んだreplyのIDを更新する
    updateReadReply : function()
    {
      var name = document.getElementById("me_name").textContent;
      var hentry = document.getElementsByClassName("hentry")[0];
      if(hentry.textContent.match("@" + name))
      {
        var readReply = hentry.id.replace(/[^0-9]/g , "").toString();
        GME.setValue("readReply" , readReply);
        GME.removeById("unread-icon");
      }
    },
    //}}}
    //{{{updateReadReply2 : function()
    //#replesを同じページ内で表示したときに読んだreplyのIDを更新する
    updateReadReply2 : function()
    {
      GME.xmlhttpRequest({method:"GET" , url:"http://twitter.com/replies" , onload:onload});
      function onload(res)
      {
        var readReply = res.responseText.match(/id="status_[0-9]*"/);
        if(readReply == null){return;}

        readReply = readReply.toString().replace(/[^0-9]/g , "").toString();
        GME.setValue("readReply" , readReply);
        GME.removeById("unread-icon");
      }
    }
    //}}}
  }

  GME.addStyleEx("custom-twitter-style" , "style" , "http://h13i32maru.sakura.ne.jp/gm/custom_twitter/" + GME.scriptVersion + "/style.css");

  customUser.init();
  customStyle.init();
  customReply.init();

  GME.checkVersion();

})();
