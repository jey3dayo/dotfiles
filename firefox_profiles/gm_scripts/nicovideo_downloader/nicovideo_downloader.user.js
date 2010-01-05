// ==UserScript==
// @name      nicovideo downloader
// @namespace http://muumoo.jp/
// @include   http://www.nicovideo.jp/watch/*
// @author    pool
// @version   0.5
// ==/UserScript==

(function(){
	var h1 = document.getElementsByTagName('h1')[0];
	if(!h1) return;
	
	var video_link = document.createElement('a');
	video_link.href = 'javascript:void(0);';
	video_link.innerHTML = '[video]';
	video_link.addEventListener('click',
		function(){
			video_link.removeEventListener('click', arguments.callee, false);
			video_link.innerHTML = '[please wait...]';
			call_api(function(res){
				if(/&url=(.+?)&/.test(res.responseText)){
					var url = decodeURIComponent(RegExp.$1);
					video_link.href = url;
					video_link.innerHTML = '[download]';
				}
			});
		}, false);
	h1.parentNode.insertBefore(video_link, h1);
	
	var comments_link = document.createElement('a');
	comments_link.href = 'javascript:void(0);';
	comments_link.innerHTML = '[comments]';
	comments_link.addEventListener('click',
		function(){
			call_api(function(res){
				if(/thread_id=(.+?)&.+&ms=(.+?)&/.test(res.responseText)){
					var thread_id = decodeURIComponent(RegExp.$1);
					var url = decodeURIComponent(RegExp.$2);
					GM_xmlhttpRequest({
						method: 'POST',
						headers: { 'Content-type': 'text/xml' },
						url: url,
						data: '<thread res_from="-500" version="20061206" thread="' + thread_id + '" />',
						onload: function(res){
							var data = encodeURIComponent(res.responseText.replace(/></g, '>\n<'));
							location.href = 'data:application/xml;charset=utf-8,' + data;
						},
						onerror: function(res){ GM_log(res.status + ':' + res.statusText); }
					});
				}
			});
		}, false);
	h1.parentNode.insertBefore(comments_link, h1);
	
	function call_api(callback){
		if(/watch\/([^/]+)$/.test(location.href)){
			var video_id = RegExp.$1;
			GM_xmlhttpRequest({
				method: 'GET',
				url: 'http://www.nicovideo.jp/api/getflv?v=' + video_id,
				onload: callback,
				onerror: function(res){ GM_log(res.status + ':' + res.statusText); }
			});
		}
	}
})();
