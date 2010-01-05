// ==UserScript==
// @name           NicoWatch Tools
// @namespace      http://wktklabs.blog98.fc2.com/
// @description    ニコニコ動画Greasemonkeyスクリプトの統合スクリプト
// @include        http://www.nicovideo.jp/watch/*
// @version        0.3.20090428
// ==/UserScript==

(function(){

    var defaultConfig = {
        position : "top", /* top or bottom */
    };
    var functionEnable = {
        getflv : { flag : true, label : "FLV/MP4/SWF"},
        getxml : { flag : true, label : "XML"},
        getmp3 : { flag : true, label : "MP3"},
        comments_search : { flag : true, label : "コメント検索"},
        comments_getLinks : { flag : true, label : "リンク抽出"},
        getFilter : { flag : true, label : "フィルター"},
        tagsReload : { flag : false, label : ""},
        viewLockedTags : { flag : false, label : ""},
        tagLinker : { flag : false, label : ""},
        getUsername : { flag : false, label : ""},
        replaceUserTextLink : { flag : false, label : ""},
        replaceUserTextSpace : { flag : false, label : ""},
        ecoMode : { flag : false, label : "", label2 : ""},
        autoPlay : { flag : false, label : "", waitTime : 1000, interval : 500 },
    };

    function $(e){return document.getElementById(e)||e}
    var $$ = unsafeWindow.$$;
    function htmlspecialchars(c){return c.replace(/&/g,"&amp;").replace(/"/g,"&quot;").replace(/'/g,"&#039;").replace(/</g,"&lt;").replace(/>/g,"&gt;")}
    var observe = {
        set : function(e, hdlr, func){($(e)||e).addEventListener(hdlr, func, false)},
        del : function(e, hdlr, func){($(e)||e).removeEventListener(hdlr, func, false)}
    };
	function xpath(query) {
		var results = document.evaluate(query, document, null, XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE, null);
		var nodes = new Array();
		for(var i=0; i<results.snapshotLength; i++){
			nodes.push(results.snapshotItem(i));
		}
		return nodes;
	}

    var api = {
        vid : false,
        prm : {
            all : false
        },
        xml : {
            publicCom : {
                text : false,
                dom : false,
                flag : false
            },
            userCom : {
                text : false,
                dom : false,
                flag : false
            }
        },
        checkWrapper : function(){
            if (unsafeWindow.$('flvplayer').GetVariable('o') == "base") return true;
            else return false;
        },
        get : function(func){
        	/* ニコニコ動画新プレーヤー変更のため一時的コメントアウト */
//            if (!this.prm.all) {
//                /* for flvplayer_wrapper */
//                if (this.checkWrapper()) var player_info = unsafeWindow.$('flvplayer').GetVariable('nico.o');
//                else var player_info = unsafeWindow.$('flvplayer').GetVariable('o');
//                var o = {responseText : decodeURIComponent(player_info)};
//                this.prm.all = o.responseText;
//            }
//            else var o = {responseText : this.prm.all};
//            if (func) {
//                if (o.responseText) func(o);
//                else {
//                    GM_xmlhttpRequest({
//                        method: 'GET',
//                        url: 'http://www.nicovideo.jp/api/getflv?v=' + this.vid,
//                        onload: func,
//                        onerror: function(res){
//                            $("tools_status").innerHTML = "接続エラー";
//                            GM_log(res.status + ':' + res.statusText);
//                        }
//                    });
//                }
//            }
//            else return this.prm.all;
        	/* 以下追加分 */
            if (!this.prm.all) {
                GM_xmlhttpRequest({
                    method: 'GET',
                    url: 'http://www.nicovideo.jp/api/getflv?v=' + this.vid,
                    onload: function(res){api.prm.all = res.responseText;},
                    onerror: function(res){
                        $("tools_status").innerHTML = "接続エラー";
                        GM_log(res.status + ':' + res.statusText);
                    }
                });
            }
            if (!func) return this.prm.all;
            else func({responseText : this.prm.all});
        	/* ここまで */
        },
        comments : function(type, func){
            var xml;
            if (type==1) {
                xml = this.xml.userCom;
                $("tools_status").innerHTML = "投稿者コメントデータ取得中...";
            }
            else {
                xml = this.xml.publicCom;
                $("tools_status").innerHTML = "一般コメントデータ取得中...";
            }
            this.get(function(res){
                if(/thread_id=(.+?)&/.test(res.responseText)){
                    var thread_id = decodeURIComponent(RegExp.$1);
                    res.responseText.match(/&ms=(.+?)&/);
                    var url = decodeURIComponent(RegExp.$1);
                    var dataStr;
                    if (type==1) dataStr = '<thread res_from="-1000" fork="1" version="20061206" thread="' + thread_id + '" />';
                    else dataStr = '<thread res_from="-1000" version="20061206" thread="' + thread_id + '" />';
                    GM_xmlhttpRequest({
                        method: 'POST',
                        headers: { 'Content-type': 'text/xml' },
                        url: url,
                        data: dataStr,
                        onload: function(res){
                            xml.text = res.responseText;
                            xml.dom = (new DOMParser()).parseFromString(res.responseText, "text/xml").wrappedJSObject;
                            $("tools_status").innerHTML = "";
                            if (!xml.flag) {
                                switch (type) {
                                    case 0:
                                        $("reload_public_xml").innerHTML = '<a id="reload_public_xml_act" href="javascript:void(0);" title="通常コメントデータを更新">' +
                                                                            '<img src="data:image/gif;base64,R0lGODlhDAAMAIMAAG1tbcvLy6WlpYCAgP7+/ra2tnZ2dubm5q6uroqKigAAAAAAAAAAAAAAAAAAAAAAACwAAAAADAAMAAAIVwATABgIgAABBAUMGhQ40KABAAMOGBxA0GAAigMIFIAoUCEBigUEBiCQwGMAAAw9eiRYUKXBgSI9CiBwMsHGjAoBCAD5EeJIAgRxHqBo4CVMjwUQGIUZEAA7">' +
                                                                            ' 通常コメ' +
                                                                            '</a>';
                                        observe.set("reload_public_xml_act", "click", function(){
                                            api.comments(0, function(){
                                                $("tools_status").innerHTML = "通常コメントデータを更新しました";
                                            })
                                        });
                                        if (!api.xml.userCom.flag) break;
                                    case 1:
                                        $("reload_user_xml").innerHTML = '<a id="reload_user_xml_act" href="javascript:void(0);" title="投稿者コメントデータを更新">' +
                                                                            '<img src="data:image/gif;base64,R0lGODlhDAAMAIMAAG1tbcvLy6WlpYCAgP7+/ra2tnZ2dubm5q6uroqKigAAAAAAAAAAAAAAAAAAAAAAACwAAAAADAAMAAAIVwATABgIgAABBAUMGhQ40KABAAMOGBxA0GAAigMIFIAoUCEBigUEBiCQwGMAAAw9eiRYUKXBgSI9CiBwMsHGjAoBCAD5EeJIAgRxHqBo4CVMjwUQGIUZEAA7">' +
                                                                            ' 投稿者コメ' +
                                                                            '</a>';
                                        observe.set("reload_user_xml_act", "click", function(){
                                            api.comments(1, function(){
                                                $("tools_status").innerHTML = "投稿者コメントデータを更新しました";
                                            })
                                        });
                                        break;
                                }
                                xml.flag = true;
                            }
                            func();
                        },
                        onerror: function(res){
                            $("tools_status").innerHTML = "接続エラー";
                            GM_log(res.status + ':' + res.statusText);
                        }
                    });
                }
            });
        }
    }
  
    /*--- tools ---*/
    var tools = {
        flag : {
            getflv : 0,
            search : 0,
            getLinks : 0,
            getFilter : 0
        },
        show : function(){
            if (document.URL.match(/^http:\/\/.*?\.nicovideo\.jp\/watch\/([^\/?<>"'#]+)/)) {
                api.vid = RegExp.$1;
                var toolbar = document.createElement("table");
                toolbar.id = 'tools_table';
                toolbar.cellpadding = 0;
                toolbar.cellspacing = 4;
                toolbar.border = 0;
                toolbar.className = 'TXT12';
                toolbar.innerHTML = '<tr>' +
                                    '<td>' +
                                    '<div style="padding:3px;font-weight:bold;">ツール：</div>' +
                                    '</td>' +
                                    ((functionEnable.getflv.flag)?'<td><input type="submit" id="flv_dl" class="submit" value="'+functionEnable.getflv.label+'"/></td>':"") +
                                    ((functionEnable.getxml.flag)?'<td><input type="submit" id="xml_dl" class="submit" value="'+functionEnable.getxml.label+'"/></td>':"") +
                                    ((functionEnable.getmp3.flag)?'<td><input type="submit" id="mp3_dl" class="submit" value="'+functionEnable.getmp3.label+'"/></td>':"") +
                                    ((functionEnable.comments_search.flag)?'<td><input type="submit" id="search_comments" class="submit" value="'+functionEnable.comments_search.label+'"/></td>':"") +
                                    ((functionEnable.comments_getLinks.flag)?'<td><input id="get_links" type="submit" class="submit" value="'+functionEnable.comments_getLinks.label+'"/></td>':"") +
                                    ((functionEnable.getFilter.flag)?'<td><input id="get_filter" type="submit" class="submit" value="'+functionEnable.getFilter.label+'"/></td>':"") +
                                    ((functionEnable.tagsReload.flag)?'<td><input id="tags_reload" type="submit" value="'+functionEnable.tagsReload.label+'" class="submit" /></td>':"") +
                                    ((functionEnable.ecoMode.flag)?'<td><input id="eco_mode" type="submit" class="submit" value="'+functionEnable.ecoMode.label+'"/></td>':"") +
                                    ((functionEnable.autoPlay.flag)?'<td><input id="autoPlay_btn" type="submit" class="submit" value="'+functionEnable.autoPlay.label+'" style="color:#aaa;"/></td>':"") +
                                    '<td id="tools_status" width="100%">' +
                                    '' +
                                    '</td>' +
                                    '<td id="tools_status2">' +
                                    '' +
                                    '</td>' +
                                    '<td id="reload_public_xml" style="padding:5px 10px 0 0;">' +
                                    '' +
                                    '</td>' +
                                    '<td id="reload_user_xml" style="padding:5px 10px 0 0;">' +
                                    '' +
                                    '</td>' +
                                    '</tr>';
                var search_box = document.createElement("div");
                search_box.id = "search_comments_box";
                if (functionEnable.comments_search.flag) {
                    search_box.className = "TXT12";
                    search_box.style.display="none";
                    search_box.setAttribute("name","");
                    search_box.style.padding="0 0 5px 30px";
                    search_box.innerHTML = '<form id="search_comments_form" style="margin:0;padding:0;" onsubmit="return false">' +
                                            '検索対象：<select id="comment_type" name="comment_type">' +
                                            '<option value="public">通常コメント</option>' +
                                            '<option value="user">投稿者コメント</option></select>' +
                                            ' キーワード：<input id="search_comments_input" type="text" style="width:150px" />' +
                                            ' <input type="submit" value="検索/全表示" style="background-color:#f0f0f0;border-width:1px;border-style:solid;border-color : #cccccc #999999 #999999 #cccccc;" />' +
                                            ' <input type="button" value="消" onclick="$(\'search_comments_input\').value=\'\'" style="background-color:#f0f0f0;border-width:1px;border-style:solid;border-color : #cccccc #999999 #999999 #cccccc;" />' +
                                            '　　表示：' +
                                            '<input type="checkbox" id="search_disp_mail" name="mail" value=1><label for="search_disp_mail">コマンド</label>' +
                                            ' <input type="checkbox" id="search_disp_post" name="post" value=1><label for="search_disp_post">書き込み日時</label>' +
                                            ' <input type="checkbox" id="search_disp_number" name="number" value=1><label for="search_disp_number">コメント番号</label>' +
                                            ' </form>';
                }
                var toolbox = document.createElement("div");
                toolbox.id = "toolbox";
                toolbox.className = "TXT12";
                
                if (defaultConfig.position=="bottom") {
			    	var doc = document.createElement("div");
			    	doc.id = "nicowatchtools";
			    	var doc1 = document.createElement("div");
			    	doc1.id = "nicowatchtools_top";
			    	doc.appendChild(doc1);
			    	doc1 = document.createElement("div");
			    	doc1.id = "nicowatchtools_container";
	                doc1.appendChild(toolbar);
	                doc1.appendChild(search_box);
	                doc1.appendChild(toolbox);
			    	doc.appendChild(doc1);
			    	doc1 = document.createElement("div");
			    	doc1.id = "nicowatchtools_bottom";
			    	doc.appendChild(doc1);
			        $("WATCHFOOTER").insertBefore(doc, $("WATCHFOOTER").firstChild);
                }
                else {
	                $("WATCHHEADER").appendChild(toolbar);
	                $("WATCHHEADER").appendChild(search_box);
	                $("WATCHHEADER").appendChild(toolbox);
                }
                
                if (functionEnable.tagsReload.flag) observe.set("tags_reload", "click", tools.tagsReload);
                if (functionEnable.tagLinker.flag) tools.tagLinker();
                if (functionEnable.viewLockedTags.flag) tools.viewLockedTags();
                
                if (functionEnable.getflv.flag) observe.set("flv_dl", "click", tools.getflv);
                if (functionEnable.getxml.flag) observe.set("xml_dl", "click", tools.getxml);
                if (functionEnable.getmp3.flag) observe.set("mp3_dl", "click", tools.getmp3);
                if (functionEnable.comments_search.flag) observe.set("search_comments", "click", tools.comments.search.input);
                if (functionEnable.comments_search.flag) observe.set("search_comments_form", "submit", tools.comments.search.act);
                if (functionEnable.comments_getLinks.flag) observe.set("get_links", "click", tools.comments.getLinks);
                if (functionEnable.getFilter.flag) observe.set("get_filter", "click", tools.getFilter.show);
                if (functionEnable.getFilter.flag) tools.getFilter.count();
                if (functionEnable.ecoMode.flag) observe.set("eco_mode", "click", tools.ecoMode.change);
                if (functionEnable.ecoMode.flag) tools.ecoMode.show();
                if (functionEnable.getUsername.flag) tools.getUsername();
                if (functionEnable.autoPlay.flag) observe.set("autoPlay_btn", "click", tools.autoPlay.switch);
                if (functionEnable.autoPlay.flag) tools.autoPlay.act();
                tools.replaceUserText();
            }
        },
        getflv : function(){
            if ($("toolbox").getAttribute("name") == "getflv") {
                $("toolbox").setAttribute("name","");
                $("toolbox").innerHTML = "";
            }
            else {
                $("search_comments_box").style.display = "none";
                $("tools_status").innerHTML = "セッションの再確立中...";
	            GM_xmlhttpRequest({
	                method : 'GET',
	                url : document.URL,
	                onload : function(res) {
	                    GM_xmlhttpRequest({
	                        method: 'GET',
	                        url: 'http://www.nicovideo.jp/api/getflv?v=' + location.href.split('/').reverse()[0],
	                        onload: function(res){
				                $("tools_status").innerHTML = "";
	                            var api=res.responseText;
	                            var movie_type = unsafeWindow.$('flvplayer').GetVariable('movie_type');
				                if (/&url=(.+?)&/.test(api)) {
				                    var note = '', ecoNote = '', url = decodeURIComponent(RegExp.$1);
				                    var ecoFlag = /low$/.test(url);
				                    if (ecoFlag) ecoNote = '　(エコノミーモードにより画質が低下しています)';
				                    if (ecoFlag || (movie_type != "swf" && movie_type != "mp4")) {
				                        movie_type = "flv";
				                    }
				                    else {
				                        note = '<tr><td align="right">ヒント　</td><td>：　ダウンロードURLを右クリック→「名前を付けてリンク先を保存」から任意の保存先を選択し、拡張子を「.' + movie_type + '」にして保存してください。</td></tr>';
				                    }
				                    $("toolbox").innerHTML = '<div style="margin:0 30px;">' +
				                                                '<table style="margin-top:5px;border:2px #ccc solid;" width="100%" cellpadding="0" cellspacing="5">' +
				                                                '<tr>' +
				                                                '<td align="right" width="100px">' +
				                                                'タイトルコピペ用　' +
				                                                '</td>' +
				                                                '<td>' +
				                                                '：　<input type="text" class="paste" style="width:500px;" value="' + decodeURIComponent(unsafeWindow.Video.title) + "." + movie_type + '" onfocus="this.select();" readonly="readonly" />' +
				                                                '</td>' +
				                                                '</tr>' +
				                                                '<tr>' +
				                                                '<td align="right">' +
				                                                '動画ファイル形式　' +
				                                                '</td>' +
				                                                '<td>' +
				                                                '：　' + movie_type + ecoNote +
				                                                '</td>' +
				                                                '</tr>' +
				                                                '<tr>' +
				                                                '<td align="right">' +
				                                                'ダウンロードURL　' +
				                                                '</td>' +
				                                                '<td>' +
				                                                '：　<a href="'+url+'" target="_blank">'+url+'</a>' +
				                                                '</td>' +
				                                                '</tr>' +
				                                                note +
				                                                '</table>' +
				                                                '</div>' +
				                                                '<div style="text-align:right">' +
				                                                '<a id="toolbox_close" href="javascript:void(0);">[×]とじる</a>' +
				                                                '</div>';
				                    observe.set("toolbox_close", "click", tools.getflv);
				                    $("toolbox").setAttribute("name","getflv");
				                }
	                        }
	                    });
	                }
	            });
            }
        },
        getmp3 : function(){
            var mp3window = window.open('http://www.nicomimi.com/play/' + location.href.split('/').reverse()[0]);
        },
        get3gp : function(){
            var nico3gpwindow = window.open('http://www.nico3gp.com/?nicomimi=' + location.href.split('/').reverse()[0]);
        },
        getxml : function(){
            var func = function(type){
                var iframe = document.createElement("iframe");
                iframe.style.display = "none";
                var text;
                if (type==1) text = api.xml.userCom.text;
                else text = api.xml.publicCom.text;
                iframe.src = 'data:application/x-xml;charset=utf-8,' + encodeURIComponent(text.replace(/></g, '>\r\n<'));
                $("tools_status2").appendChild(iframe);
            }
            if (confirm("通常コメントまたは投稿者コメントデータをダウンロードします。\nOK => 通常コメント\nキャンセル => 投稿者コメント")) {
                if (confirm("通常コメントデータをダウンロードします。\nよろしいですか？")) {
                    if (!api.xml.publicCom.flag) api.comments(0,function(){func(0);});
                    else func(0);
                }
            }
            else {
                if (confirm("投稿者コメントデータをダウンロードします。\nよろしいですか？")) {
                    if (!api.xml.userCom.flag) api.comments(1,function(){func(1);});
                    else func(1);
                }
            }
        },
        comments : {
            display : function(nonText, reg, linkOnly, type, func){
                $("tools_status").innerHTML = "";
                var table = function(reg){
                    var xml;
                    if (type==1) xml = api.xml.userCom;
                    else xml = api.xml.publicCom;
                    var results = '';
                    var chatText;
                    var premi;
                    var reg = new RegExp(reg, "ig");
                    var match = false, match2 = false;
                    var flag = false;
                    var com;
                    var ii = false;
                    var user_id;
                    var date = new Date();
                    var chat = xml.dom.getElementsByTagName("chat");
                    var num = chat.length;
                    var month, day, hour, seconds;
                    for (var i = 0; i < num; i++) {
                        chatText = chat[i].textContent;
                        user_id = chat[i].getAttribute("user_id");
                        if (linkOnly) match = /((sm|fz|yo|ig|ax|na|nm|za|yk|sk|fx|cw|zc|zb|ca|zd)\d+)|(watch\/\d+)|(mylist\/\d+)|(h?ttps?:\/\/[-_.!~*()a-zA-Z0-9;\/?:@&=+$,%#]+)/.test(chatText);
                        else {
                            match = reg.test(chatText);
                            match2 = reg.test(user_id);
                        }
                        if (match || match2) {
                            flag = true;
                            user_id = user_id;
                            vpos_min = Math.floor(Math.floor(chat[i].getAttribute("vpos") / 100) / 60);
                            vpos_sec = Math.floor(chat[i].getAttribute("vpos") / 100) - vpos_min * 60;
                            if (vpos_min < 10) vpos_min = '0' + vpos_min;
                            if (vpos_sec < 10) vpos_sec = '0' + vpos_sec;
                            if (chat[i].getAttribute("premium")) premi = '[P] ';
                            else premi = '';
                            com = htmlspecialchars(chatText);
                            if (com.match(/(h?ttps?:\/\/[-_.!~*()a-zA-Z0-9;\/?:@&=+$,%#]+)/i)) {
                                com = com.replace(/(h?ttps?:\/\/[-_.!~*()a-zA-Z0-9;\/?:@&=+$,%#]+)/ig, 
                                    function($1){
                                        var url = $1, deurl = $1;
                                        if (!/^h/.test(url)) deurl = "h" + url;
                                        return '<a href="'+deurl+'" target="_blank">'+url+'</a>';
                                    }
                                );
                            }
                            else if (com.match(/((sm|fz|yo|ig|ax|na|nm|za|yk|sk|fx|cw|zc|zb|ca|zd)\d+)/ig))
                                com = com.replace(/((sm|fz|yo|ig|ax|na|nm|za|yk|sk|fx|cw|zc|zb|ca|zd)\d+)/ig, '<a href="/watch/'+RegExp.$1+'">'+RegExp.$1+'</a>');
                            else if (com.match(/(watch\/\d+)/ig))
                                com = com.replace(/(watch\/\d+)/ig, '<a href="/'+RegExp.$1+'">'+RegExp.$1+'</a>');
                            else if (com.match(/(mylist\/\d+)/ig))
                                com = com.replace(/(mylist\/\d+)/ig, '<a href="/'+RegExp.$1+'">'+RegExp.$1+'</a>');
                            else if (com.match(/(user\/\d+)/ig))
                                com = com.replace(/(user\/\d+)/ig, '<a href="/'+RegExp.$1+'">'+RegExp.$1+'</a>');
                            else if (com.match(/([-_.!~*()a-zA-Z0-9;\/?:@&=+$,%#]{50})/ig))
                                com = com.replace(/([-_.!~*()a-zA-Z0-9;\/?:@&=+$,%#]{50})/ig, RegExp.$1+'<br />');
                            com = com.replace(/\\r\\n/ig,'<br />');
                            if (ii) {
                                trStyle = 'style="background:#efefef;"';
                                ii = false;
                            } else {
                                trStyle = '';
                                ii = true;
                            }
                            date.setTime(chat[i].getAttribute("date")+'000');
                            month = date.getMonth() + 1;
                            if (month < 10) month = '0' + month;
                            day = date.getDate();
                            if (day < 10) day = '0' + day;
                            hour = date.getHours();
                            if (hour < 10) hour = '0' + hour;
                            seconds = date.getMinutes();
                            if (seconds < 10) seconds = '0' + seconds;
                            results += '<tr ' + trStyle + '>'
                                    + '<td>'
                                    + vpos_min + ':' + vpos_sec
                                    + '</td>'
                                    + '<td class="comment">'
                                    + com
                                    + '</td>'
                                    + (($('search_disp_mail').checked)?'<td class="mail" style="white-space:nowrap;">'
                                    + ((chat[i].getAttribute("mail")!=null)?chat[i].getAttribute("mail"):"-")
                                    + '</td>':"")
                                    + (($('search_disp_post').checked)?'<td>'
                                    + month + '/' + day + ' ' + hour + ':' + seconds
                                    + '</td>':"")
                                    + (($('search_disp_number').checked)?'<td>'
                                    + chat[i].getAttribute("no")
                                    + '</td>':"")
                                    + '<td style="white-space:nowrap;padding:0 5px;text-align:left;">'
                                    + premi
                                    + ((type==0)?'<a href="javascript:void(0);" onclick="var id=$(\'search_comments_input\');id.value=this.innerHTML;$(\'search_comments_box\').style.display=\'\';id.focus();window.Element.scrollTo($$(\'p.TXT12\').first());" class="uid_link">'
                                    + user_id
                                    + '</a>':'')
                                    + '</td>'
                                    + '</tr>';
                        }
                    }
                    if (flag) {
                        $("toolbox").innerHTML = '<table id="toolbox_table" cellpadding="0" cellspacing="0"><tbody>' +
                                                        '<tr class="top_bar">' +
                                                        '<td>再生時間</td>' +
                                                        '<td width="100%">コメント</td>' +
                                                        (($('search_disp_mail').checked)?'<td>コマンド</td>':"") +
                                                        (($('search_disp_post').checked)?'<td>書き込み日時</td>':"") +
                                                        (($('search_disp_number').checked)?'<td>コメ番号</td>':"") +
                                                        ((type==1)?'<td>プレミアム</td>':"<td>[プレミアム] ユーザーID</td>") +
                                                        '</tr>' +
                                                        results +
                                                        '</tbody></table>' +
                                                        '<div style="text-align:right">' +
                                                        '<a id="toolbox_close" href="javascript:void(0);">[×]とじる</a>' +
                                                        '</div>';
                        observe.set("toolbox_close", "click", function(){
                            $("search_comments_box").style.display = "none";
                            $("toolbox").innerHTML = "";
                            $("toolbox").setAttribute("name","");
                        });
                    } else {
                        $("toolbox").innerHTML = "";
                        alert(nonText);
                    }
                    if (func) func();
                };
                if (type==0 && !api.xml.publicCom.dom) api.comments(0,function(){table(reg)});
                else if (type==1 && !api.xml.userCom.dom) api.comments(1,function(){table(reg)});
                else table(reg);
            },
            search : {
                input : function(){
                    $("tools_status").innerHTML = "";
                    if ($("search_comments_box").style.display == ""){
                        $("search_comments_box").style.display = "none";
                        $("toolbox").innerHTML = "";
                        $("toolbox").setAttribute("name","");
                    }
                    else {
                        $("toolbox").innerHTML = "";
                        $("search_comments_box").style.display = "";
                        $("search_comments_input").focus();
                        $("toolbox").setAttribute("name","searchComments");
                    }
                },
                act : function(){
                    $("tools_status").innerHTML = "";
                    word = $("search_comments_input").value.replace('　', ' ').split(' ');
                    var num = word.length;
                    var type;
                    if ($('comment_type').value=="user") type=1;
                    else type=0;
                    if (num > 0 && word != '') {
                        var words = '';
                        for (var i = 0; i < num; i++) {
                            words += '|(' + word[i] + ')'
                        }
                        tools.comments.display('該当するコメントは見つかりませんでした。', words.substr(1), false, type, false);
                    } else {
                        if (type==1) tools.comments.display('投稿者コメントはありませんでした。', '', false, type, false);
                        else tools.comments.display('', '', false, type, false);
                    }
                }
            },
            getLinks : function(){
                $("search_comments_box").style.display = "none";
                if ($("toolbox").getAttribute("name") == "getLinks"){
                    $("toolbox").innerHTML = "";
                    $("toolbox").setAttribute("name","");
                }
                else {
                    tools.comments.display('コメント内にリンクは見つかりませんでした。', '', true, 0, function(){
                        if ($("toolbox").innerHTML != "") $("toolbox").setAttribute("name","getLinks");
                        else $("toolbox").setAttribute("name","");
                    });
                }
            },
            getUserComments : function(){
                $("search_comments_box").style.display = "none";
                if ($("toolbox").getAttribute("name") == "getUserComments"){
                    $("toolbox").innerHTML = "";
                    $("toolbox").setAttribute("name","");
                }
                else {
                    tools.comments.display('', '', false, 0, 
                        function(){$("toolbox").setAttribute("name","getUserComments");}
                    );
                }
            }
        },
        getFilter : {
            count : function(){
                setTimeout(function(){
                    var o = api.get(false);
                    var num = '';
                    if (/ng_up=(.+)&ng/.test(o)) {
                        filters = decodeURIComponent(RegExp.$1).split('&');
                        if (filters.length > 0) num =  '(' + filters.length + ')';
                    }
                    $('get_filter').value += num;
                }, 5000);
            },
            show : function(){
                $("search_comments_box").style.display = "none";
                $("toolbox").innerHTML = "";
                $("tools_status").innerHTML = "";
                if ($("toolbox").getAttribute("name") == "getFilter") {
                    $("toolbox").setAttribute("name","");
                }
                else {
                    if (/ng_up=(.+)&ng/.test(api.get())) {
                        filters = decodeURIComponent(RegExp.$1).split('&');
                        var results = '';
                        var ii = false;
                        for (var i = 0; i < filters.length; i++) {
                            filters[i].match(/(.+)=(.+)/);
                            if (ii) {
                                trStyle = 'style="background:#efefef;"';
                                ii = false;
                            } else {
                                trStyle = '';
                                ii = true;
                            }
                            results += '<tr ' + trStyle + '><td style="white-space:nowrap;padding:0 10px;">' + RegExp.$1 + '</td><td class="comment">' + RegExp.$2 + '</td></tr>';
                        }
                        $("toolbox").innerHTML = '<table id="toolbox_table" cellpadding="0" cellspacing="0"><tbody>' +
                                                        '<tr class="top_bar">' +
                                                        '<td>変換前</td>' +
                                                        '<td width="100%">変換後</td>' +
                                                        '</tr>' +
                                                        results +
                                                        '</tbody></table>' +
                                                        '<div style="text-align:right">' +
                                                        '<a id="toolbox_close" href="javascript:void(0);">[×]とじる</a>' +
                                                        '</div>';
                        observe.set("toolbox_close", "click", function(){
                            $("toolbox").innerHTML = "";
                            $("toolbox").setAttribute("name","");
                        });
                        $("toolbox").setAttribute("name","getFilter");
                    }
                    else {
                        alert("フィルターは設定されていません。");
                        $("toolbox").setAttribute("name","");
                    }
                }
            }
        },
        tagsReload : function(){
        	if (!functionEnable.tagsReload.flag) return;
            $("tools_status").innerHTML = "";
            GM_xmlhttpRequest({
                method : 'POST',
                url : "http://www.nicovideo.jp/tag_edit/" + api.vid,
                headers : {
                    'X-Requested-With' :'XMLHttpRequest',
                    'Content-Type' : 'application/x-www-form-urlencoded; charset=UTF-8'
                },
                data : 'cmd=tags',
                onload : function(res) {
                    if (/^<\!DOCTYPE HTML PUBLIC/.test(res.responseText)) alert("タグの更新に失敗しました。");
                    else {
                        $('video_tags').innerHTML = res.responseText;
                        tools.tagLinker(tools.viewLockedTags(unsafeWindow.Nicopedia.decorateLinks));
                        var tagfrm = $$("p.tag_txt").first();
                        tagfrm.id = "rt_nicowatch";
                        tagBGcolor = 125;
                        timeId = setInterval(function(){
                            tagBGcolor += 10;
                            tagfrm.style.backgroundColor = "#ffff" + tagBGcolor.toString(16);
                            if (tagBGcolor >= "255") clearInterval(timeId);
                        }, 100);
                    }
                }
            });
        },
        tagLinker : function(func){
        	if (!functionEnable.tagLinker.flag) return;
            var tags = (xpath("//div[@id='video_tags']//a[@rel='tag']"));
            for (var i=0; i<tags.length-1 ;i++) {
                if (tags[i].href.match(/((sm|fz|yo|ig|ax|na|nm|za|yk|sk|fx|cw|zc|zb|ca|zd)\d+)/ig))
                    tags[i].href = "/watch/"+RegExp.$1;
                else if (tags[i].href.match(/((co)\d+)/ig))
                	tags[i].href = "http://com.nicovideo.jp/community/"+RegExp.$1;
                else if (tags[i].href.match(/(mylist%2F\d+)/ig))
                    tags[i].href = "/"+RegExp.$1;
                else if (tags[i].href.match(/(user%2F\d+)/ig))
                    tags[i].href = "/"+RegExp.$1;
            }
            if (func!=undefined) func();
        },
        viewLockedTags : function(func){
        	if (!functionEnable.viewLockedTags.flag) return;
            var tagList = unsafeWindow.Video.lockedTags;
            var tags = (xpath("//div[@id='video_tags']//a[@rel='tag']"));
            var starHTML;
            for (var i=0; i<tags.length ;i++) {
                for (var ii=0;ii<tagList.length;ii++) {
                    if (tags[i].href.match(new RegExp('tag/'+encodeURIComponent(tagList[ii])+'$', 'i'))) {
                        starHTML = document.createElement("span");
                        starHTML.className = "tools_locked_tags_star";
                        starHTML.innerHTML = "★";
                        tags[i].parentNode.insertBefore(starHTML, tags[i]);
                        break;
                    }
                }
            }
            if (func!=undefined) func();
        },
        getUsername : function(){
            GM_xmlhttpRequest({
                method: 'GET',
                url: 'http://www.smilevideo.jp/view/' + api.vid.replace(/^[a-z]{2}/, ''),
                onload: function(res){
                    if(/<strong>(.+?)<\/strong> が/.test(res.responseText)) {
                        var user = decodeURIComponent(RegExp.$1);
                        var doc1 = document.createElement("span");
                        doc1.style.fontSize = "12px";
                        doc1.innerHTML = " [ <b>"+user+"</b> ] ";
                        (xpath("//div[@id='des_1']/table/tbody/tr/td"))[0].insertBefore(doc1, (xpath("//div[@id='des_1']/table/tbody/tr/td/span"))[0]);
                        var doc2 = document.createElement("span");
                        doc2.style.fontSize = "12px";
                        doc2.innerHTML = " [ うｐ主 ： <b>"+user+"</b> ] ";
                        (xpath("//div[@id='des_2']/table/tbody/tr/td[2]/div/p"))[0].appendChild(doc2);
                    }
                }
            });
        },
        replaceUserText : function(){
            setTimeout(function(){
	        	var p;
	            if (api.checkWrapper()) p = $('WATCHHEADER').getElementsByTagName('p')[2];
	            else p = (xpath("//p[@class='video_description']"))[0];
	            var userText = p.innerHTML;
	        	if (functionEnable.replaceUserTextLink.flag) 
		            userText = userText.replace(/("?>?h?ttps?:\/\/[-_.!~*()a-zA-Z0-9;\/?:@&=+$,%#]+)/ig, 
		                function($1){
		                    var url = $1;
		                    if (!/^("|>)/.test(url) && !url.match(/nicovideo\.jp/ig)) {
		                        url.match(/(h?ttps?:\/\/[-_.!~*()a-zA-Z0-9;\/?:@&=+$,%#]+)$/ig);
		                        url = RegExp.$1;
		                        if (!/^h/.test(url)) url = "h" + url;
		                        return '<a href="'+url+'" target="_blank">'+url+'</a>';
		                    }
		                    else return url;
		                }
		            );
	        	if (functionEnable.replaceUserTextSpace.flag && p.getElementsByTagName('br').length<1)
		            userText = userText.replace(/([ 　]{3,})/ig, "<br />");
	        	if (functionEnable.replaceUserTextLink.flag || functionEnable.replaceUserTextSpace.flag)
		            p.innerHTML = userText;
            }, 1000);
        },
        ecoMode : {
            show : function(){
                if (/(.*)\?eco=1$/.test(document.URL)) $('eco_mode').value = functionEnable.ecoMode.label2;
            },
            change : function(){
                if (/(.*)\?eco=1$/.test(document.URL)) window.self.location.href = RegExp.$1;
                else window.self.location.href = document.URL+"?eco=1";
            },
        },
        autoPlay : {
        	switch : function(){
				if (GM_getValue("nicowatch_autoPlay", 0) == 1) {
					GM_setValue("nicowatch_autoPlay", 0);
					$("autoPlay_btn").style.color = "#aaa";
				}
				else {
					$("autoPlay_btn").style.color = "";
					GM_setValue("nicowatch_autoPlay", 1);
				}
        	},
        	act : function(){
/*--------------------
this "autoPlay.act()" function quote from
 http://userscripts.org/scripts/show/35194
--------------------*/
				if (GM_getValue("nicowatch_autoPlay", 1) == 1) {
					$("autoPlay_btn").style.color = "";
					setTimeout(function(){
							var script = document.createElement('script');
							script.setAttribute('type', 'text\/javascript');
							script.innerHTML = 'function nico_auto_play(){var flvplayer=document.getElementById("flvplayer");'
												+ 'if(!flvplayer)setTimeout(nico_auto_play,300);'
												+ 'try{flvplayer.ext_play(1);}catch(e){setTimeout(nico_auto_play,200);}'
												+ 'if(flvplayer.ext_getStatus()!="playing")setTimeout(nico_auto_play,'+functionEnable.autoPlay.interval+');}'
												+ 'setTimeout(nico_auto_play,'+functionEnable.autoPlay.waitTime+');';
							document.body.appendChild(script);
					}, 1000);
				}
	        }
        }
    };

    GM_addStyle(<><![CDATA[
        #tools_table {
            max-width: 960px;
            white-space: nowrap;
        }
        #toolbox {
            padding: 0 20px;
        }
        #toolbox_table {
            width: 920px;
        }
        #toolbox_table td{
            text-align: center;
            padding: 2px 0;
        }
        #toolbox_table .comment{
            white-space: normal;
            text-align: left;
            padding-left: 5px;
        }
        #toolbox_table a.uid_link{ text-decoration: none; color: #666666; }
        #toolbox_table a.uid_link:hover{ text-decoration: underline; color: #000; }
        #toolbox_table .top_bar{
            background: url('data:image/gif;base64,R0lGODlhAQAXAIIAAI%2BPj8%2FP0Pf38Kenp%2Fn59AAAAAAAAAAAACwAAAAAAQAXAAAIDgAFCBxIsCBBAgAGBAgIADs%3D');
        }
        #toolbox_table .top_bar td{
            white-space: nowrap;
            padding: 0 10px;
            height: 23px;
            line-height: 23px;
            background: url('data:image/gif;base64,R0lGODlhAQAXAIIAAI%2BPj8%2FP0MHBwff38Kenp%2Fn59AAAAAAAACH5BAAAAAAALAAAAAABABcAAAgRAAcIHCCgoMGDBwcUAEAgQEAAOw%3D%3D') no-repeat;
        }
        #toolbox_table a{
            color: #0099CC;
            height: 22px;
        }
        #tools_status {
            padding-left: 5px;
        }
        span.tools_locked_tags_star {
            color:orange;
            font-weight: bold;
            cursor: text;
            text-decoration: none;
        }
        
        #nicowatchtools {
            width: 950px;
        	padding: 0 4px;
        	margin-bottom: 5px;
        }
        #nicowatchtools_top{
            height: 5px;
            width: 950px;
            background: url('data:image/gif;base64,R0lGODlhtgMFAIIAACgtLbGzs29ycvn6%2BpOWlj1CQri6unZ5eSwAAAAAtgMFAAAIrwAHDAggoACAgwgTKlzIsKHDhxAjSpxIsaLFixgzatzIsaPHjyBDihxJsqTJkyhTqlzJsqXLlyoLCAggcACBAwZq6tzJs6fPn0CDCh1KtKjRo0iTKl3KtKnTp1CjSp1KtarVq1izat3KtavXr2DBGjhAYOCBsGjTql3Ltq3bt3Djyp1Lt67du3iTHiCYM6%2Ffv4ADCx5MuLDhw4gTKzZQULHjx5AjS55MubLly5ILBAQAOw%3D%3D') no-repeat top left;
        }
        #nicowatchtools_container{
        	padding: 0 10px;
        	background-color: #f9fafa;
        	border-left: 1px #000 solid;
        	border-right: 1px #000 solid;
        }
        #nicowatchtools_bottom{
            height: 5px;
            width: 950px;
            background: url('data:image/gif;base64,R0lGODlhtgMFAIIAACgtLbGzs29ycvn6%2BpOWlj1CQri6unZ5eSwAAAAAtgMFAAAIsgALDBhIsKDBgwgTKlzIsKHDhxAjSpxIsaLFixgzatzIsaPHjyBDihxJsqTJkyhTqlzJcmABAQZaypxJs6bNmzhz6tzJs6fPn0CDCh1gQECAA0OTKl3KtKnTp1CjSp1KdeiBAAMIHIhZtavXr2DDih1LtqxZoQYOECAYQEABAHDjyp1Lt67du3jz6t3Lt6%2Ffv4ADCx5MuLDhw4gTK17MuLHjx5AjS55MubLly5gnv8Q6ICAAOw%3D%3D') no-repeat bottom left;
        }
    ]]></>);
    tools.show();
})();
