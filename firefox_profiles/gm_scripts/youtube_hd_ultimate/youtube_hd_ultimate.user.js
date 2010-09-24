// ==UserScript==
// @name          YouTube HD Ultimate
// @description   The best of the hundreds of YouTube scripts, because we make it. Updated all the time, by me and you! Your favorite YouTube script is better than ever!
// @include       http://www.youtube.com/watch*
// @include       http://youtube.com/watch*
// @namespace     #aVg
// @license       CC-BY-NC-SA http://creativecommons.org/licenses/by-nc-sa/3.0/
// @version       1.2.5
// ==/UserScript==
function Params(A) {
	var obj = {};
	for (var i = 0, isProp = true, cur, curProp = "", curValue = ""; i < A.length; ++i) {
		cur = A.charAt(i);
		if (isProp) {
			if (cur=="=") {
				isProp = false;
				continue;
			} else curProp += cur;
		} else {
			if (cur=="&") {
				obj[curProp] = decodeURIComponent(curValue).replace(/\+/g, " ");
				curValue = "";
				curProp = "";
				isProp = true;
				continue;
			} else curValue += cur;
		}
	}
	return obj;
}
function $(A) {return document.getElementById(A);}
const thisVer="1.2.5";
function script() {
function update(resp) {
	GM_xmlhttpRequest({
		url : "http://userscripts.org/scripts/source/31864.meta.js",
		method : "GET",
		onload : function(A) {
			if (A.responseText.match(/\/\/ @version {7}(\S+)/) == null) return;
			if (RegExp.$1 != thisVer) {
				if (confirm("There is a new version of YouTube HD Ultimate.\n\nInstall it?")) location.href = "http://userscripts.org/scripts/source/31864.user.js";
			} else if (resp) alert("There is no new version at this time.");
		}
	});
}
var now=new Date().getTime();
if ((GM_getValue("lastCheck"), now) <= (now - 86400000)) {
	GM_setValue("lastCheck", now);
	update(false);
}
var player=unsafeWindow.document.getElementById("movie_player"),
	swfArgs = new Params(player.getAttribute("flashvars")),
	optionBox,
	globals = {
		getHeight : function(miniMode) {
			return miniMode ? 35 : 29;
		},
		setStyle : function(s, v) {
			player.parentNode.style[s] = v + "px";
		},
		setHeight : function(v) {
			this.setStyle("height", v);
		},
		setWidth : function(v) {
			this.setStyle("width", v);
		},
		handleSize : function(grow) {
			fitBig(grow);
			unsafeWindow.onresize = grow && opts.fit ? fitToWindow : null;
		},
		isWide : false
	},
	head=$("watch-headline-title"),
	newOpts = new Array();
document.title = document.title.substring(10);
var opts = {
	vq : new Array("Max Quality", new Array("240p", "360p", "480p", "720p", "1080p"), "Please choose the maximum video quality your computer can handle."),
	autoplay : new Array("Autoplay", true, "By default, YouTube autoplays all of it's videos."),
	autobuffer : new Array("Autobuffer", false, "If you have a slow computer and/or a slow connection, turn this on to let the video download while it's paused, then you can hit the play button."),
	hidenotes : new Array("Hide annotations", true, "Annotations are those annoying notes some users leave that say \"visit my site!\" or \"make sure to watch in HD!!\" in the video. But we already know that, right? You can turn them off if you want."),
	hideRate : new Array("Hide Warnings", false, "Choose this if you want to hide warnings about language, sex or violence."),
	bigMode : new Array("Big mode", true, "Have a nice monitor? Like seeing things big? Turn this on. Ensures proper aspect ratio, and maximum viewing in the comfort of your browser."),
	fit : new Array("Fit to window", true, "The player will size itself to the window, ensuring optimal screen use in windowed mode."),
	min : new Array("Mini mode", false, "For those who use YouTube mainly for music, turn this on. Can also be toggled from the button."),
	maxLock : new Array("True Resolution", false, "Turn this on to lock videos at their actual maximum resolution, if your monitor supports such enormous resolutions."),
	useVol : new Array("Enabled Fixed Volume", false, "This will enabled the fixed volume feature (script sets volume to custom amount at the start of every video)."),
	vol : new Array("Volume", "50", "The volume, as an integer, from 0 to 100."),
	snapBack : new Array("Snap back", true, "Makes the video smaller if you turn off HD/HQ mid-video using the player's button."),
	loop : new Array("Loop", false, "Are you a loopy fanatic? Turn this on! Goes well if you watch a lot of AMV's I hear."),
	jumpToPlayer : new Array("Jump to player", true, "Especially with big mode on, this is nice. It scrolls down to the video for you."),
	tools : new Array("Script tools", true, "Display the script toolbox to the right of the video title."),
	qlKill : new Array("Kill Quicklist", false, "Permanently removes the quicklist from view. Not recommended if you use playlists.")
};
function Element(A, B, C, D) {
	A = document.createElement(A);
	if (B) for (var b in B) {
		var cur=B[b];
		if (b.indexOf("on")==0) A.addEventListener(b.substring(2), cur, false);
		else if (b=="style") A.setAttribute("style", B[b]);
		else A[b]=B[b];
	}
	if (D) for (var d in D) A.setAttribute(d, D[d]);
	if (C) for each(var c in C) A.appendChild(c);
	return A;
}
function center() {
	var psize = player.offsetWidth;
	if (psize > 960) globals.setStyle("marginLeft", Math.round((960 - psize) / 2) - 1);
	else {
		if(globals.isWide) player.parentNode.style.removeProperty("margin-left");
		else globals.setStyle("marginLeft", Math.round((637 - psize) / 2) - 1);
	}
}
function fitToWindow() {
	fitBig(true);
}
function fitBig(force) {
	globals.isWide = (typeof force=="boolean") ? force : !globals.isWide;
	unsafeWindow.yt.www.watch.player.onPlayerSizeClicked(globals.isWide);
	if(globals.isWide) {
		var h = window.innerHeight - 150;
		if(opts.maxLock) {
			var max;
			switch(player.getPlaybackQuality()) {
				case "hd1080" : max = 1080; break;
				case "hd720" : max = 720; break;
			}
			max += globals.getHeight();
			if(h > max) h = max;
		}
		globals.setHeight(h);
	} else globals.setHeight("385");
	globals.setWidth(Math.round((player.offsetHeight - globals.getHeight()) * (config.IS_WIDESCREEN ? 1.77 : 1.32)));
	center();
}
GM_addStyle("#vidtools > * {\
	position : relative;\
	z-index : 6 !important;\
	float:right;\
}\
.yt-menulink-menu {z-index:700 !important}\
.yt-menulink {z-index:4 !important}\
.yt-rounded {background-color:white!important}\
#movie_player {\
width:1px!important;height:1px!important;\
} .loop {\
	width: 11px;height: 15px;\
	margin-left: 3px;\
	margin-right: 3px;\
	margin-top: 4px;\
} .loop.on {\
	background-image: url(data:image/gif;base64,R0lGODlhEAAQAPQAAP/29v8AAP7w8P42Nv5/f/4FBf4kJP7Pz/6iov4VFf5ycv5iYv7c3P6Tk/6/v/5FRf5TUwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkKAAAAIf4aQ3JlYXRlZCB3aXRoIGFqYXhsb2FkLmluZm8AIf8LTkVUU0NBUEUyLjADAQAAACwAAAAAEAAQAAAFUCAgjmRpnqUwFGwhKoRgqq2YFMaRGjWA8AbZiIBbjQQ8AmmFUJEQhQGJhaKOrCksgEla+KIkYvC6SJKQOISoNSYdeIk1ayA8ExTyeR3F749CACH5BAkKAAAALAAAAAAQABAAAAVoICCKR9KMaCoaxeCoqEAkRX3AwMHWxQIIjJSAZWgUEgzBwCBAEQpMwIDwY1FHgwJCtOW2UDWYIDyqNVVkUbYr6CK+o2eUMKgWrqKhj0FrEM8jQQALPFA3MAc8CQSAMA5ZBjgqDQmHIyEAIfkECQoAAAAsAAAAABAAEAAABWAgII4j85Ao2hRIKgrEUBQJLaSHMe8zgQo6Q8sxS7RIhILhBkgumCTZsXkACBC+0cwF2GoLLoFXREDcDlkAojBICRaFLDCOQtQKjmsQSubtDFU/NXcDBHwkaw1cKQ8MiyEAIfkECQoAAAAsAAAAABAAEAAABVIgII5kaZ6AIJQCMRTFQKiDQx4GrBfGa4uCnAEhQuRgPwCBtwK+kCNFgjh6QlFYgGO7baJ2CxIioSDpwqNggWCGDVVGphly3BkOpXDrKfNm/4AhACH5BAkKAAAALAAAAAAQABAAAAVgICCOZGmeqEAMRTEQwskYbV0Yx7kYSIzQhtgoBxCKBDQCIOcoLBimRiFhSABYU5gIgW01pLUBYkRItAYAqrlhYiwKjiWAcDMWY8QjsCf4DewiBzQ2N1AmKlgvgCiMjSQhACH5BAkKAAAALAAAAAAQABAAAAVfICCOZGmeqEgUxUAIpkA0AMKyxkEiSZEIsJqhYAg+boUFSTAkiBiNHks3sg1ILAfBiS10gyqCg0UaFBCkwy3RYKiIYMAC+RAxiQgYsJdAjw5DN2gILzEEZgVcKYuMJiEAOw==);\
} .loop.off {\
	background-image: url(data:image/gif;base64,R0lGODlhEAAQAPMJAG4AAYoAAJUAAKkAALYAAcYAANkBAOYBAP8AAP///wAAAAAAAAAAAAAAAAAAAAAAACH5BAEKAAkAIf4NQnkgSmVyb2VuejByCgAsAAAAABAAEAAABE0wyUmrvTYMQoIUWHIYBiEFwnAdiKFKRFodRWGAE/FORiEBFRulhiFOjBZkolcBJoSUDUXQKxwqA5lkYEBcLVlPgmv4XnABzkAcarslEQA7);\
} #version {\
	float : right;\
	padding-left: 7px !important;padding-right: 3px;\
	background-color: white;\
	color: black;\
	-moz-border-radius-bottomright : 5px;-moz-border-radius-bottomleft : 3px;\
	border : solid grey 1px;\
} #opts {\
	background-color: black;\
	color : white;\
	position : absolute;\
	padding : 20px;\
	top : 80px;left : 25%;right : 25%;\
	-moz-border-radius : 12px;\
	border : 5px outset red;\
	z-index : 100000;\
} #myLinks {\
	float : right;\
	font-size: 16px;\
} #myLinks a {\
	color : white;\
	text-decoration: underline;\
	display: block;\
	font-size: 12px;\
} #opts input, #opts select {\
	margin-left: 3px;\
	padding-left: 4px;\
} #opts label {\
	display : block;\
	padding : 2px;\
} #opts label:hover {text-shadow: 1px 2px 1px yellow !important;}\
#opts label.on {\
	font-style : italic;\
	text-shadow : 1px 0 4px white;\
	color : white;\
} a {cursor:pointer;}\
#opts h1 {\
	background-color: red;\
	-moz-border-radius: 6px;\
	padding : 4px;\
	text-shadow: 1px -1px 4px white;\
} .watch-wide-mode, #watch-this-vid, #watch-player-div {padding-left:0!important}\
#opts p {\
	padding-left: 20px;\
	font-family : Calibri, Comic Sans MS;\
}");
optionBox = new Element("div", {
	innerHTML : "<h1>YouTube HD Ultimate Options</h1><span id=\"version\">v "+thisVer+"</span><p>Settings, if changed, will be applied on the next video. Roll over an option to find out more about it.</p>",
	style : "display : none",
	id : "opts"
});
optionBox = optionBox.appendChild(new Element("div", {
	style : "float:left"
}));
for (var opt in opts) {
	var val = GM_getValue(opt), full = opts[opt][1], a, s=document.createElement("label"), append = true;
	if (val == null) {
		if (typeof full == "object") val = 0;
		else val = full;
	}
	switch (typeof val) {
		case "string" :
		a = document.createElement("input");
		a.value = val;
		break;
		case "boolean" :
		a = document.createElement("input");
		a.type = "checkbox";
		a.addEventListener("click", function() {this.parentNode.className = this.checked ? "on" : "";}, false);
		a.checked = val;
		if (val) s.className = "on";
		s.appendChild(a);
		s.appendChild(document.createTextNode(opts[opt][0]));
		append = false;
		break;
		case "number" :
		a = document.createElement("select");
		for (var i = full.length - 1; i>=0; --i)
			a.appendChild(new Element("option", {
				textContent : full[i]
			}));
		a.selectedIndex = val;
		break;
	}
	a.name = opt;
	if (append) {
		s.appendChild(document.createTextNode(opts[opt][0]));
		s.appendChild(a);
	}
	s.title=opts[opt][2];
	optionBox.appendChild(s);
	opts[opt]=val;
	newOpts.push(a);
}
optionBox = optionBox.parentNode;
var linkbox;
optionBox.appendChild(linkbox=new Element("div",
	{
		id : "myLinks"
	}, new Array(
		document.createTextNode("Script links: ")
	)
));
optionBox.appendChild(new Element("br", {style : "clear:both"}));
optionBox.appendChild(new Element("a", {
	className : "yt-uix-button",
	style : "float: right; height: 20px; padding-top: 3px; margin-top: -25px; color: black;",
	onclick : function(E) {
		E.preventDefault();
		globals.toggler.textContent="Show Ultimate Options";
		for (var newOpt, i=newOpts.length-1; i>=0; --i) {
			newOpt=newOpts[i];
			GM_setValue(newOpt.name, newOpt[newOpt.nodeName=="SELECT" ? "selectedIndex" : newOpt.type=="text" ? "value" : "checked"]);
		}
		optionBox.style.display="none";
	}
	}, new Array(
		new Element("span", {
			textContent : "Save Options"
		})
	)
));
var sLinks = {
	"homepage" : "http://userscripts.org/scripts/show/31864",
	"development" : "http://code.google.com/p/youtubehd/",
	"author" : "http://userscripts.org/users/avindra",
	"donate" : "https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=steveaarti%40gmail%2ecom&lc=US&item_name=Avindra%20Goolcharan&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_LG%2egif%3aNonHosted",
	"e-mail" : "mailto:aavindraa@gmail.com",
	"forums" : "http://userscripts.org/scripts/discuss/31864",
	"help / wiki" : "http://userscripts.wikia.com/wiki/YouTube_HD_Ultimate",
	"open bugs + requests" : "http://code.google.com/p/youtubehd/issues/list",
	"all bugs + requests" : "http://code.google.com/p/youtubehd/issues/list?can=1",
	"report new bug" : "http://code.google.com/p/youtubehd/issues/entry",
	"create new request" : "http://code.google.com/p/youtubehd/issues/entry?template=Feature%20Request"
};
for (var link in sLinks) {
	linkbox.appendChild(new Element("a", {
		textContent : link,
		href : sLinks[link]
	}));
}
linkbox.appendChild(new Element("a", {
	textContent : "check for update",
	onclick : function(E) {
		E.preventDefault();
		update(true);
	}
}));
linkbox.appendChild(new Element("a", {
	textContent : "debugString",
	title : "This is for easing development. Don't worry about it unless the devs tell you to use it.",
	onclick : function(E) {
		E.preventDefault();
		for (var arg in swfArgs) if (arg.indexOf("rv")==0) delete swfArgs[arg];
		opts.swfArgs = swfArgs;
		opts.ver = thisVer;
		opts.ua = navigator.userAgent;
		opts.flash = unsafeWindow.navigator.plugins["Shockwave Flash"].description;
		prompt("This is your debugString. Copy it with CTRL + X. If posting on userscripts.org, please use pastebin.com to post it.", opts.toSource());
	}
}));
document.body.appendChild(optionBox);
$("masthead-nav").appendChild(globals.toggler=new Element("a", {
	style : "font-weight:bold; padding: 4px 10px; background-color: #0033CC; color: white; -moz-border-radius: 8px;",
	textContent : "Show Ultimate Options",
	onclick : function(E) {
		E.preventDefault();
		var isHidden = optionBox.style.display=="none";
		this.textContent= (isHidden ? "Hide" : "Show") + " Ultimate Options";
		optionBox.style.display=isHidden ? "inline" : "none";
	}
}));
if (!opts.bigMode && (opts.maxLock || opts.fit)) opts.bigMode = true;
head.addEventListener("click", function() {
	this.scrollIntoView(true);
}, false);
if (opts.jumpToPlayer) head.scrollIntoView(true);
unsafeWindow.stateChanged=function(state) {
	if (state!=0) return;
	if (config.LIST_AUTO_PLAY_ON) location.href = config["LIST_PLAY_NEXT_URL" + (config.SHUFFLE_ENABLED ? "_WITH_SHUFFLE" : "")];
	else if (opts.loop) {
		player.seekTo(0, true);
		player.playVideo();
	}
};
unsafeWindow.onYouTubePlayerReady=function(A) {
	if (player.getAttribute("wmode")!="opaque") return;
	player.setPlaybackQuality(["hd1080", "hd720", "large", "medium", "small"][opts.vq]);
	if(opts.autobuffer || opts.autoplay) {
	} else {
		function playVideo(e) {
			player.playVideo();
			unsafeWindow.removeEventListener("focus", playVideo, false);
			unsafeWindow.removeEventListener("mousemove", playVideo, false);
		}
		unsafeWindow.addEventListener("focus", playVideo, false);
		unsafeWindow.addEventListener("mousemove", playVideo, false);
	}
	if(!opts.autoplay) player.pauseVideo();
	var el = $("quicklist");
	if (el) {
		if(opts.qlKill) el.style.display = "none";
		else el.setAttribute("data-autohide-mode", "on");
	}
	if (opts.bigMode) fitBig(true);
	if (opts.min) {
		fitToWindow();
		globals.setHeight(globals.getHeight(true));
	} else if (opts.fit) unsafeWindow.onresize = fitToWindow;
	if (opts.useVol && opts.vol.match(/(\d+)/)) player.setVolume(Number(RegExp.$1));
	unsafeWindow.sizeClicked = globals.handleSize;
	player.addEventListener("onStateChange", "stateChanged");
	player.addEventListener("SIZE_CLICKED", "sizeClicked");
	player.addEventListener("NEXT_CLICKED", "yt.www.watch.player.onPlayerNextClicked");
	player.addEventListener("NEXT_SELECTED", "yt.www.watch.player.onPlayerNextSelected");
	if (opts.snapBack) {
		unsafeWindow.newFmt=function(fmt) {
			if(player.getPlaybackQuality()!=fmt) globals.handleSize(/hd(?:72|108)0|large/.test(fmt));
		};
		player.addEventListener("onPlaybackQualityChange", "newFmt");
	}
	globals.lastHeight = player.offsetHeight;
	player.focus();
};
if (opts.hidenotes) swfArgs.iv_load_policy="3";
if (config.LIST_AUTO_PLAY_ON) swfArgs.playnext = "1";
if (!opts.autoplay && !opts.autobuffer) swfArgs.autoplay="0";
else if (opts.autoplay) swfArgs.autoplay="1";
var ads=new Array("infringe", "invideo", "ctb", "interstitial", "watermark");
if (opts.hideRate) {
	ads.push("ratings");
	ads.push("ratings_module");
}
for (var i=ads.length-1;i>=0;i--) delete swfArgs[ads[i]];
/*
	swfArgs.cc_load_policy = "1";
	swfArgs.cc_font = "Arial Unicode MS, arial, verdana, _sans";
*/
swfArgs.vq=["hd1080", "hd720", "large", "medium", "small"][opts.vq];
if (swfArgs.fmt_map.indexOf("18")==0 && /3[457]|22/.test(swfArgs.fmt_map)) swfArgs.fmt_map=swfArgs.fmt_map.replace(/18.+?,/, "");
else if (/5\/(0|320x240)\/7\/0\/0/.test(swfArgs.fmt_map) && !/(?:18|22|3[457])\//.test(swfArgs.fmt_map)) {
	if (swfArgs.fmt_stream_map.split(",").length == 1) {
		// 240p default, 360p secret
		if (location.search.indexOf("fmt=18")==-1) {
			location.replace(location.protocol + "//" + location.host +location.pathname + location.search + "&fmt=18" + location.hash);
			return;
		}
	}
	else swfArgs.fmt_stream_map = swfArgs.fmt_stream_map.match(/\|([^,]+)/)[1].replace(/itag=\d+/, "itag=18");
	swfArgs.fmt_list = "18/" + (RegExp.$1=="0" ? "512000" : "640x360") + "/9/0/115," + swfArgs.fmt_list;
	swfArgs.fmt_map = swfArgs.fmt_list;
	swfArgs.fmt_url_map = swfArgs.fmt_stream_map.replace(/\|\|tc\.v\d+\.cache\d+\.c\.youtube\.com/g, "");
}
if (location.hash.match(/t=(?:(\d+)m)?(?:(\d+)s?)?/)) {
	var start=0;
	if (RegExp.$1) start += Number(RegExp.$1 + "0") * 6;
	if (RegExp.$2) start += Number(RegExp.$2);
	swfArgs.start = start;
}
var vars="";
for (var arg in swfArgs) if (!/^(?:ad|ctb|rec)_/i.test(arg)) vars+="&"+arg+"="+encodeURIComponent(swfArgs[arg]);
player.setAttribute("flashvars", vars);
player.setAttribute("wmode", "opaque");
player.src = purl;
head = head.insertBefore(new Element("div", {id:"vidtools"}), head.firstChild);
document.addEventListener("keydown", function(E) {
	if ("INPUTEXTAREA".indexOf(E.target.nodeName) >= 0) return;
	switch (E.keyCode) {
		case 83: globals.setHeight(globals.getHeight(true)); return;
		case 80: player[(player.getPlayerState()==1 ? "pause" : "play") + "Video"](); return;
		case 82: player.seekTo(0, true); return;
		case 77: player[player.isMuted() ? "unMute" : "mute"](); return;
		case 69: player.seekTo(player.getDuration(), true); return;
		case 66: fitBig(); return;
		case 39: player.seekTo(player.getCurrentTime()+.5, true);return;
		case 37: player.seekTo(Math.round(player.getCurrentTime()-1), true);return;
		return;
	}
	if (E.ctrlKey)
		switch (E.keyCode) {
			case 38:
				E.preventDefault();
				player.setVolume(player.getVolume() + 4);
				return;
			case 40:
				E.preventDefault();
				player.setVolume(player.getVolume() - 4);
				return;
		}
}, false);
if(opts.tools) {
head.appendChild(new Element("span", {
	className : "loop o" + (opts.loop ? "n" : "ff"),
	style : "padding-left:2px;padding-right:2px;",
	onclick : function() {
		GM_setValue("loop", opts.loop = !opts.loop);
		this.className = "loop o" + (opts.loop ? "n" : "ff");
	}
}));
head.appendChild(new Element("a", {
	style : "font-size:12px;padding-top:3px;padding-left:3px;",
	onclick : function() {
		if (this.textContent=="mini mode on")
		{
			this.textContent = "mini mode off";
			if (opts.fit) {
				unsafeWindow.onresize = fitToWindow;
				fitToWindow();
			} else globals.setHeight(globals.lastHeight);
		} else {
			this.textContent = "mini mode on";
			globals.setHeight(globals.getHeight(true));
			unsafeWindow.onresize = null;
		}
	},
	textContent : "mini mode o" + (opts.min ? "n" : "ff")
}));
}
var mnuActions, watch=$("watch-actions");
$("watch-actions-right").appendChild(
	new Element("button", {
		className : "yt-uix-button yt-uix-tooltip",
		onclick : function(E) {
		//	E.preventDefault();
		}
	}, new Array(
		new Element("span", {
			className : "yt-uix-button-content",
			textContent : "YTHD",
			onclick : function() {
			}
		}),
		new Element("img", {
			className : "yt-uix-button-arrow"
		}),
		mnuActions = new Element("ul", {
			className : "yt-uix-button-menu"
		})
	), {
		"type" : "button",
		"data-tooltip" : "This allows you to share links with friends with the current time and best quality."
	}),
	watch.childNodes[8]
);
var actions = {
	"Get time link" : function() {
			var time = "";
			var ct = player.getCurrentTime();
			var m = Math.floor( ct / 60), s = Math.round(ct - m * 60);
			time = "#t=";
			if (m > 0) time += m + "m";
			if (s > 0) time += s + "s";
			prompt("Here is your custom made link for highest quality:", "http://www.youtube.com/watch" + location.search.replace(/[?&]fmt=\d*/,"") + "&fmt=" + (config.IS_HD_AVAILABLE ? "22" : "18") + time);
	}
};
unsafeWindow.actions = actions;
for (var action in actions) {
	mnuActions.appendChild(new Element("li", null, new Array(new Element(
	"span", {
		className : "yt-uix-button-menu-item",
		onclick : actions[action],
		textContent : action
	}, null, {
		onclick : "actions[\"" + action + "\"]()"
	}))));
}
var downloads={"terrible flv" : "5", "3gp":"17", mp4:"18", "hq 3gp" : "36"}, dls = {};
for(var fmt_map = swfArgs.fmt_stream_map.split(","), trail = "&title=" + encodeURIComponent($("eow-title").title), i = fmt_map.length - 1; i >= 0; --i) {
	var s = fmt_map[i].split("|");
	dls[s[0]] = s[1] + trail;
}
if (/(?:^|,)34/.test(swfArgs.fmt_map)) downloads["hq flv"]="34";
if (config.IS_HD_AVAILABLE || /(?:^|,)35/.test(swfArgs.fmt_map)) downloads["super hq flv"]="35";
if (config.IS_HD_AVAILABLE) {
	downloads["720p mp4"] = "22";
	if (/(?:^|,)37/.test(swfArgs.fmt_map)) downloads["1080p mp4"] = "37";
}
var info=$("watch-ratings-views"), block=new Element("div");
block.appendChild(document.createTextNode("Download this video as: "));
var flv=new Element("a", {
	href : "/get_video?asv&video_id="+swfArgs.video_id+"&t="+swfArgs.t,
	textContent : "flv"
});
block.appendChild(flv);
for (var dl in downloads) {
	var temp=flv.cloneNode(false), fmt = downloads[dl];
	temp.appendChild(document.createTextNode(dl));
	if(fmt in dls) temp.href = dls[fmt];
	else temp.href += "&fmt=" + fmt;
	block.appendChild(document.createTextNode(" // "));
	block.appendChild(temp);
}
$("watch-info").appendChild(block);
}
if (!$("watch-headline-title")) location.replace(location.href.replace("#!", "?"));

function getPurl() {
	GM_xmlhttpRequest({
		url : "http://www.youtube.com/watch?v=-AIwkpCH1yA",
		method : "GET",
		onload : function(A) {
			if(A.responseText.match(/<param name=\\"movie\\" value=\\"([^"]+)/))
			{
				purl = RegExp.$1.replace(/\\/g, "");
				GM_setValue("purl", purl);
				script();
			} else alert("Error retrieving url for the new player!\n\nIf you feel this is a mistake on my part, please let me know: http://userscripts.org/scripts/show/31864");
		}
	});
}

var config = unsafeWindow.yt.config_, purl = config.SWF_CONFIG.url;
if (purl.indexOf("as3")==-1) {
	purl = GM_getValue("purl");
	if (purl == null) getPurl();
	else GM_xmlhttpRequest({
		url : purl,
		method : "HEAD",
		onload : function(A)
		{
			if(A.status == 200) script();
			else getPurl();
		}
	});
} else script();