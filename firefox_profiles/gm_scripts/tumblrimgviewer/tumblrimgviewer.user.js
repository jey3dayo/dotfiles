// ==UserScript==
// @name          TumblrImgViewer
// @namespace     http://d.hatena.ne.jp/kasei_san/
// @include       http://*.tumblr.com/*
// @exclude       http://www.tumblr.com/*
// @exclude       http://*.tumblr.com/post/*
// ==/UserScript==
(function(){

	$t("h1")[0].innerHTML += "<br><input id='kaseisan_flg' type='hidden' value='0'>";
	$t("h1")[0].innerHTML += "<input id='kaseisan_button' type='button' value='ImgAllView!!' onclick='document.getElementById(\"kaseisan_flg\").value=\"1\"'>";
	$t("h1")[0].innerHTML += "<div id='kaseisan_result'></div>";


	var timer = setInterval ( function () {
    	try {
				if($("kaseisan_flg") && ($("kaseisan_flg").value - 0 == 1)){
					getAllImg();
					clearInterval(timer);
				}
	    } catch (e) {
    	}
	},100);

	var baseUrl = location.href.match(/http:\/\/.*\.tumblr\.com\//);
	var urlMax		= 100;
	var imgs		= [];

	function getAllImg(){

		var imgMax = -1;
		var imgCnt = 0;
		var num = 50;
		var loadingFlg = false;
		var postsReg	= new RegExp(/([0-9]+)\"/);
		var photoReg	= new RegExp(/<photo-url max-width="75">http:\/\/data\.tumblr\.com\/([0-9]+)_/);

		var ids={};

		$("kaseisan_button").value="loading... ";
		$("kaseisan_button").disabled = true;

		// photo�S�Ă�擾
		getImg();

		function getImg(){

			$("kaseisan_button").value="loading... " + imgCnt + "/" + imgMax;
			GM_xmlhttpRequest({
				method : "GET",
				url : baseUrl + "api/read?type=photo&num=" + num + "&start=" + imgCnt,
				onload : function (req) {

					// �����擾
					if( imgMax < 0 ){
						var totalReg	= new RegExp(/posts start="0" total="([0-9]+)" type="photo">/);
						if( req.responseText.match(totalReg) ){
							imgMax = RegExp.$1 - 0;
						}
					}
					var posts	 = req.responseText.split("post id=\"");
					var buf = [];
					for( var i = 1; i < posts.length; i++ ){
						if( posts[i].match(postsReg) ){
							var id = RegExp.$1 - 0;
							if( posts[i].match(photoReg) ){
								var photoId = RegExp.$1 - 0;
								if( !ids[id] ){
									ids[id] = true;
									buf.push(
										["<a href='", baseUrl, "post/", id, "' target='_blank'><img src='http://data.tumblr.com/", photoId, "_100.jpg' style='position:static; width:auto; height:auto;'></a>"].join("")
									);
								}
							}
						}
					}
					$("kaseisan_result").innerHTML += buf.join("");
					imgCnt += num;
					if( imgCnt < imgMax ){
						getImg();
					}else{
						$("kaseisan_button").value = "finished";
						$("kaseisan_button").disabled = false;
					}
				}
			});
		}
	}

	function $(id){
		return document.getElementById(id);
	}

	function $t(tag){
		return document.getElementsByTagName(tag);
	}
	function $c (className) {
	  var children = document.getElementsByTagName('*') || document.all;
	  var elements = new Array();
	  for (var i = 0; i < children.length; i++) {
	    var child = children[i];
	    var classNames = child.className.split(' ');
	    for (var j = 0; j < classNames.length; j++) {
	      if (classNames[j] == className) {
	        elements.push(child);
	        break;
	      }
	    }
	  }
	  return elements;
	}

	function $c (tagName, className) {
	  var children = document.getElementsByTagName(tagName);
	  var elements = new Array();
	  for (var i = 0; i < children.length; i++) {
	    var child = children[i];
	    var classNames = child.className.split(' ');
	    for (var j = 0; j < classNames.length; j++) {
	      if (classNames[j] == className) {
	        elements.push(child);
	        break;
	      }
	    }
	  }
	  return elements;
	}



})();