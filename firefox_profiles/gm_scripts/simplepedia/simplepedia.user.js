// ==UserScript==
// @name		Simplepedia
// @version		.982
// @namespace		http://userscripts.org/scripts/show/42312
// @description		MediaWiki beautification
// @author		Grant Stavely http://grantstavely.com/ 
// @copyright 		2009+ Grant Stavely
// @license 		(CC) Attribution Non-Commercial Share Alike; http://creativecommons.org/licenses/by-nc-sa/3.0/
// @include		*
// @exclude		http://userscripts.org/*
// @contributer 	http://userscripts.org/users/auscompgeek
// @contributer    	http://userscripts.org/users/sizzle
// @contributer		http://userscripts.org/users/67105
// @contributer    	http://www.howtocreate.co.uk/bio.html
// ==/UserScript==
////////////////////////////////////////////////////////////////////////////////
// GreaseKit users: You will need http://userscripts.org/topics/21030
// Opera users: You will need http://www.howtocreate.co.uk/operaStuff/userjs/aagmfunctions.js
////////////////////////////////////////////////////////////////////////////////
// User Options 
// Heading font?
if (GM_getValue('headingFont') == undefined) {
	// Use the full name of the font you would like
	// I suggest 'Helvetica Neue Bold' or 'Hoeflter Text'
	GM_setValue('headingFont', "HelveticaNeue-Bold, Helvetica, sans-serif");
	//GM_setValue('headingFont', "'Hoefler Text', 'Times New Roman', Times, serif");
}
// Here you can set the font that most of the site will use
if (GM_getValue('bodyFont') == undefined) {
	GM_setValue('bodyFont', "HelveticaNeue, Helvetica, Arial, sans-serif");
	//GM_setValue('bodyFont', "'Times New Roman', Georgia, Times, serif");
}
// Show login, edit-page, and other metadata tabs
if (GM_getValue('user') == undefined) {
	// boolean true/false
	GM_setValue('user', ''); 
}
// Link color! 
if (GM_getValue('color') == undefined) {
	// use a css compatible value '#ff0000', '#f00', 'red', and so on...
	GM_setValue('color', '#0892D0');
}
// Language settings are persistent, but you can give it a default if you like
if (GM_getValue('default_language') == undefined) {
	// string value of wikipedia subdomains: http://meta.wikimedia.org/wiki/List_of_Wikipedias
	// 'en', 'fr', 'gr', etc...
	GM_setValue('default_language', 'en'); 
}
// Show a selection list of all alternate language versions of any document
// Wikipedia specific
if (GM_getValue('international') == undefined) {
	// anything but ''
	GM_setValue('international', '');
}
// Omniweb, Safari, etc users:
// Greasekit lacks an about:config, so make your changes here
// GM_setvalue('user', false);
////////////////////////////////////////////////////////////////////////////////
// Store the url and protocol
var url = location.href;
var protocol = 'http';
if (url.match(/^https/)) {
        protocol = 'https';
}
// If the site has a monobook css link, it's a witch
// If the site imports monobook css using a hack, it's wikipedia
var monobook = false;
var cssLinks = document.getElementsByTagName("link");
var inlineStyle = document.getElementsByTagName("style");
for (var i = cssLinks.length -1; i >=0; i--) {
	var cssLink = cssLinks[i].getAttribute("href");
	if (cssLink.match(/monobook/i)) {
		monobook = true;
	}
}
for (var i = inlineStyle.length -1; i >=0; i--) {
	var style = inlineStyle[i].childNodes[0].data;
	if (style.match(/monobook/i) || style.match(/wiki/i)) {
		monobook = true;
	}
}

////////////////////////////////////////////////////////////////////////////////
function simplepedia() {
////////////////////////////////////////////////////////////////////////////////
	// Begin altering the page, if it is a mediaWiki
	try {
		GM_addStyle("body, p {background-color: inherit !important;color: #333 !important; font-size: 13px;line-height: 18px;background-image: none;}span, div {border: none !important;background-color: inherit !important;color: #333 !important;font-size: inherit !important;line-height: inherit !important;}.toctext:hover, toclevel-1:hover, .toclinks:hover, a:hover {color: #333 !important;}a:active {color: #000 !important;}b { color: #333;}h1, h2, h3, h4, h5 {background-image: none !important;background-color: transparent !important;-webkit-background-clip: none !important;-webkit-background-origin: none !important;font-weight: bold !important;color: #333 !important;border-bottom: #eee 1px solid !important;border-top: none !important;border-left: none !important;border-right: none !important;}h1 {font-size: 200% !important;}h2 {font-size: 150% !important;}h3 {font-size: 120% !important;}li, p, ul, blockquote {padding: 5px !important;color: #333 !important;background-color: inherit;}ul, ul li {list-style-image: none !important;list-style-type: disc !important;list-style-position: outside !important;}table{margin: 0px !important;padding: 3px !important;background-color: #f6f6f6 !important;color: #333;-moz-border-radius: 3px;-webkit-border-radius: 3px;border-radius: 3px;border: 1px solid #eaeaea !important;border-collapse: inherit !important;}th, tr, td, .thumbinner {background-color: #f6f6f6 !important;color: #333!important;border: none !important;padding: 10px !important;margin: 0px !important;border-collapse: inherit !important;}ol {list-style-type: decimal !important;list-style-position: outside !important;}.selected, pre {-moz-border-radius: 3px;-webkit-border-radius: 3px;border-radius: 3px;border: 1px solid #eaeaea !important;}fieldset {-moz-border-radius: px;-webkit-border-radius: 6px;border-radius: 3px;border: 1px solid #eaeaea !important;}.logotype, a.logotype:link, a.logotype:visited, a.logotype:active {font-weight: normal !important;}#logotype {margin-top: 180px;}#logotype, #globeLogo, #front_search_bar{width: 100%;text-align: center;}#frontsearchInput {width: 390px;}#frontsearchbar {z-index: 10000;height: 100%;background-color: inherit !important;color: black;text-align: center;}#front-search, #random-article {display: inline !important;}#globalWrapper {position: absolute;left: 0px;top: 0px;z-index: 50;border: none;margin: 0px !important;padding: 0px !important;}#content {margin: 0px !important;padding: 15px !important;top: 0px !important;position: absolute !important;}#column-one, #column-content {margin: 0px !important;}#contentSub {margin-top: 20px !important;margin-left: 0px !important;}#mp-topbanner, #mp-topbanner table, #mp-topbanner tr, #mp-topbanner td, #mp-topbanner th, #mp-topbanner tbody {background-color: #fff !important;}h2 .edisection, .editsection, .editsection a:link, .editsection a:visited, .editsection a:active {font-size: 9px !important;color: #ddd !important;font-weight: normal !important;}h2 .editsection:hover, .editsection  a:hover {color: #000 !important;}.smallcaps {font-variant: small-caps !important;font-size: 70%;color: #0892D0 !important;}.relarticle, .mainarticle {color: #333 !important;background-color: inherit !important;}.toclevel-1, .toclevel-2, .toclevel-3, .toclevel-4 {list-style: none !important;}.topicon,#featured-star,  #protected-icon, #protected-icon div, #spoken-icon, #spoken-icon div {display : none !important;}.dablink {padding-top: 0px !important;padding-left: 10px !important;}.printfooter {padding-top: 10px !important;}#edit-ul {position: relative;float: right;margin: 0px;}#p-cactcions, #ca-nstab-citations, #ca-nstab-citations a, #ca-move, #ca-move a, #ca-nstab-portal, #ca-nstab-portal a, #ca-nstab-main, #ca-nstab-main a, #ca-nstab-special, #ca-nstab-special a, #ca-nstab-category, #ca-nstab-category a, #ca-nstab-help, #ca-nstab-help a, #ca-nstab-user, #ca-nstab-user a, #ca-talk, #ca-talk a, #ca-edit, #ca-history, #ca-history a, #ca-addsection, #ca-addsection a, #ca-watch, #ca-watch a, #ca-viewsource, #ca-viewsource a, #ca-nstab-project, #ca-nstab-project a {font-size: smaller !important;z-index: 1500;color: #ddd !important;border: none !important;text-align: left !important;margin: 0px !important;position: relative !important;background-color: transparent !important;font-weight: normal !important;padding-top: 0px !important;}#ca-nstab-main a:hover, #ca-nstab-special a:hover, #ca-nstab-category a:hover, #ca-nstab-help a:hover,#ca-nstab-user a:hover, #ca-talk a:hover, #ca-history a:hover, #ca-addsection a:hover, #ca-watch a:hover, #ca-viewsource a:hover, #ca-nstab-project a:hover  {color: #000 !important;}#p-cactions li a, #p-cactions li.selected, #content div.thumb {background-color: transparent!important;}#p-cactions {left: inherit !important;top: 55px !important;right: 5px !important;}.portlet {padding: 0px !important;margin: 0px !important;}#p-personal {position: absolute !important;top: 0px;right: 20px;font-size: smaller !important;margin-right: 20px !important;z-index: 1500;}#pt-login, #pt-login a {font-size: smaller !important;color: #ddd !important;}#pt-login a:hover {color: #000 !important;}#pt-userpage a:link, #pt-mytalk a:link, #pt-preferences a:link, #pt-watchlist a:link, #pt-mycontris a:link, #pt-logout a:link {color: #ddd !important;}#pt-userpage a:hover, #pt-mytalk a:hover, #pt-preferences a:hover, #pt-watchlist a:hover, #pt-mycontris a:hover, #pt-logout a:hover {color: #333 !important;}.pBody {padding-right: 20px !important;}.pBody {}#p-personal li{background-image: none !important;}#preftoc li {border-right: none !important;list-style-type: none !important;background-color: transparent !important;}.toccolours, .navbox-abovebelow, .navbox-group, #toc, .nowraplinks, .collapsible, .autocollapse, #catlinks, .printfooter, .ambox, .ambox-content, .infobox, .geography, .vcard, .thumb, .tright, .mbox-text {margin: 10px !important;background-color: #f6f6f6 !important;color: #333;-moz-border-radius: 3px;-webkit-border-radius: 3px;border-radius: 3px;border: 1px solid #eaeaea !important;}tr, th, td, tbody, .toclevel-1, .toclevel-2, .toclevel-3 {background-color: #f6f6f6 !important;-moz-border-radius: 3px;-webkit-border-radius: 3px;border-radius: 3px;border: 1px solid #f6f6f6 !important;border-collapse: inherit !important;margin: 0px !important;}.toc:link, #toc:link, th:link, td:link, tbody:link {border-color: #ddd !important;}th:hover, td:hover, tbody:hover{background-color: #eee !important;border-color: #ddd !important;} .thumb:hover, .thumbcaption:hover, .thumbinner:hover{background-color: #eee !important;border-color: #ddd !important;}th:hover, td:hover, tbody:hover, .thumb:hover, .thumbcaption:hover, .thumbinner:hover{background-color: #eee !important;border-color: #ddd !important;}#toc ul:hover li, #toc ul:hover, #toc li:hover, .toclevel-1:hover, .toclevel-2:hover, .toclevel-3:hover {background-color: #eee !important;border-color: #eee !important;}.wikitable, .prettytable {margin: 0px 0px 0px 0px;background-color: #f6f6f6 !important;color: #333;-moz-border-radius: 3px;-webkit-border-radius: 3px;border-radius: 3px;border: 1px solid #eaeaea !important;}td table {width: auto !important;background-color: transparent !important;}#p-search { display: block !important;position: absolute;top: 20px;right: 10px;visibility: visible;z-index: 1000;background-color: inherit;height: 500px;color: #333;}#langJump{z-index: 100; position: absolute; top: 30px; right: 220px;}#floatingsearch{z-index: 100;border: none;position: absolute;top: 30px;right: 20px;}#mp-upper, #mp-upper table, #mp-upper td, #mp-upper tr, #mp-upper th, #mp-upper tbody {z-index: 0 !important;margin-top: 100px;background-color: #fff !important;border: none !important;}#mp-newhead {margin-top: 10px;margin-bottom: 0.1em;line-height: 2.0em;}#mpheader {z-index: 100 !important;width: 500px !important;height: 100px;}.mp-header {font-variant: small-caps;font-weight: normal !important;font-size: 200% !important; }tbody, .MainPageBG, #mp-left, #mp-tfa-h2, #mp-tfa, #mp-dyk-h2, #mp-dyk, #mp-right, #mp-itn-h2, mp-itn, #mp-otd-h2, #mp-otd, #mp-tfp, #mp-tfp-h2, #mp-other, #mp-sister, #mp-lang, #jump-to-nav, #mp-strapline, #mp-banner, #mp-upper {background-image: none !important;background-color: inherit!important;color: #333!important;border: none !important;}#mp-left, #mp-right {margin-top: 80px;}#mp-upper img, #mp-tfa img, #mp-left img, #mp-right img {background-color: #f6f6f6 !important;color: #333!important;border: none !important;padding: 10px !important;margin: 10px !important;-moz-border-radius: 3px;-webkit-border-radius: 3px;border-radius: 3px;border: 1px solid #eaeaea !important;}#mp-upper img:hover, #mp-tfa img:hover, #mp-left img:hover, #mp-right img:hover {background-color: #eee !important;border-color: #ddd !important;}#mp-tfp-h2, .mw-headline{color: #333!important;background-color: inherit!important; font-weight: bold !important; }.mp-left .image { border: 1px solid #f00;}.MainPageBG, .MainPageBG tbody, .MainPageBG table, .MainPageBG td, .MainPageBG tr, .MainPageBG th {background-color: #fff !important;color: #333 !important;border: none !important;}.mergedrow, .floatnone, #searchBody {border: none !important;text-align: left !important;}h5#p-search {display: inline;}#artikelstadium {position: absolute !important;left: 30px !important;top: 60px !important;background-color: inherit!important;width: 15px;display: inline !important;}.portlet h5, .hiddeninputs, .metadata, .centralauth-login-box, .generated-sidebar, .mbox-image, .floatleft, .floatright {display: none !important;}#coordinates, #p-gigyaapplet, #p-sharethis, #p-, #p-navigation, #p-interaction, #p-search,p-tb, #donate, #p-lang, #anontip, #anon-banner, #mp-banner, #filetoc, #No_article_title_matches, #msg-noexactmatch,#mp-strapline, #footer, #siteSub, #p-search, #p-navigation, #p-logo, #p-interaction, #p-tb, #p-lang, #f-list, #f-poweredbyico, #f-copyrightico, #mw_header, #siteNotice, #mr_banner, #mr_banner_topad, #mr_header, #guides, #background_strip, #wikia_header, #widget_sidebar, #monaco_footer, #LEFT_SKYSCRAPER_2_load, #LEFT_SKYSCRAPER_3_load, #LEFT_SKYSCRAPER_1_load, #TOP_RIGHT_BOXAD_load, #page_bar, #google_ads_div_LEFT_SPOTLIGHT_1, #ads{display: none !important;}");
	}
	catch(err) {}

	// Add font option styles
	if (GM_getValue('bodyFont') !== null || GM_getValue('HeadingFont') !==  null ) {
		try {
			GM_addStyle("h1, h2, h3, h4, h5 #mp-tfp-h2, .mp-header, #mp-tfp-h2, .mw-headline{font-family: " + GM_getValue('headingFont') + " !important;}p, body, #globalWrapper {font-family: " + GM_getValue('bodyFont') + " !important;}");
		}
		catch(err) {}
	}
	
	// Add link colors
	if (GM_getValue('color') !== null) {
		try {
			GM_addStyle(".toctext, .toclinks,.toclevel-1, a:link, a:visited, a:active{text-decoration: none;color: " + GM_getValue('color') + " !important;font-weight: normal;}");
		}
		catch(err) {}
	}
	
	// Hide all logged in user commands
	if (GM_getValue('user') === '') {
		try {
			GM_addStyle("#login, #pt-login, #edit-ul, #login-ul, #user-ul, .editsection {display: none !important;}");
		}
		catch(err) {}
	}
	
	// Give the article editing ul an id 
	try {
		var editNav = document.getElementById("ca-nstab-main");        
		editNav.parentNode.setAttribute('id', 'edit-ul');
	}
	catch(err) {}

	// Front-page specific change for WikipediA only
	if (url == "http://wikipedia.org/"|| url == "http://www.wikipedia.org/") {
		var newFrontPage = document.createElement("div");
		newFrontPage.innerHTML='\
			<div id="logotype">\
				<a href="http://' + GM_getValue("default_language") + '.wikipedia.org/">\
					<img src="http://upload.wikimedia.org/wikipedia/commons/6/62/174px-Wikipedia-word1_7.png"  width="174" height="50" alt="WIKIPEDIA" />\
				</a>\
			</div>\
			<div id="globeLogo">\
				<a href="http://' + GM_getValue("default_language") + '.wikipedia.org/wiki/Special:Random?random=I%27m+Feeling+Lucky">\
					<img src="http://upload.wikimedia.org/wikipedia/en/b/bd/Bookshelf-40x201_6.png" alt="WikipediA" />\
					<img src="http://upload.wikimedia.org/wikipedia/en/b/bd/Bookshelf-40x201_6.png" alt="WikipediA" />\
					<img src="http://upload.wikimedia.org/wikipedia/en/b/bd/Bookshelf-40x201_6.png" alt="WikipediA" />\
					<img src="http://upload.wikimedia.org/wikipedia/en/b/bd/Bookshelf-40x201_6.png" alt="WikipediA" />\
					<img src="http://upload.wikimedia.org/wikipedia/en/b/bd/Bookshelf-40x201_6.png" alt="WikipediA" />\
					<img src="http://upload.wikimedia.org/wikipedia/en/b/bd/Bookshelf-40x201_6.png" alt="WikipediA" />\
				</a>\
        </div>\
				<div id="front_search_bar">\
					<form id="front-search" action="/w/index.php" method="get">\
						<input name="title" type="hidden" value="Special:Search" />\
						<input name="ns0" type="hidden" value="1" />\
						<input id="frontsearchInput" name="search" type="text" tabindex="1" title="Search Wikipedia [f]" accesskey="f" value="" />\
						<br />\
						<br />\
						<input type="submit" name="submit" value="Search" />\
					</form>\
					<form id="random-article" action="/wiki/Special:Random">\
						<input type="submit" name="random" value="I\'m Feeling Lucky" />\
					</form>\
				</div>\
        ';
		try {
			newFrontPage.setAttribute('id', 'NewFront');
			var oldFrontPage = document.getElementById("column-content");
			oldFrontPage.parentNode.replaceChild(newFrontPage, oldFrontPage);
		}
		catch(err) {}
	}

	// Replace the main page header
	var newHeaderContent = document.createElement("div");
	newHeaderContent.innerHTML='\
		<h1 class="mp-header">WikipediA</h1>\
			';
	try {
		newHeaderContent.setAttribute('id', 'mp-newhead')
		var oldheader = document.getElementById("mp-topbanner");
		oldheader.parentNode.replaceChild(newHeaderContent, oldheader);
	}
	catch(err) {}
	
	// Create a floating search and language jump nav element
	// Search using whatever search form the page already has 
	var searchform = document.getElementById("searchform").getAttribute("action");
        var searchbar = document.createElement("div");
        searchbar.innerHTML='\
                <form id="search" action="' + searchform + '" method="get">\
                        <div id="search_bar">\
                        <a href="/">\
                                        <img src="http://upload.wikimedia.org/wikipedia/en/b/bd/Bookshelf-40x201_6.png" alt="WikipediA" id="homeLink" />\
                                </a>\
                                <input name="title" type="hidden" value="Special:Search" />\
                                <input name="ns0" type="hidden" value="1" />\
                                <input id="searchInput" name="search" type="text" title="Search Wikipedia [f]" accesskey="f" value="" />\
                        </div>\
                </form>\
        '; 
        searchbar.id="floatingsearch";
        document.getElementById("column-one").appendChild(searchbar);

	// Jump to the same article in other languages
	// This mostly works but doesn't jump on change, so I'm not using it yet
	if (GM_getValue('international') === 'yes') {
		try {
			var langList = document.getElementById("p-lang").getElementsByTagName("a");
			if (langList.length > 0) {
				var langJump = document.createElement("select");
				langJump.id = "langJump";
				langJump.name = "langJump";
				var langList = document.getElementById("p-lang").getElementsByTagName("a");
				var langTitle = document.createElement("option");
				langTitle.text = ""; 
				langJump.add(langTitle,null);
				for (var i = 0;i <= langList.length -1; i++) {
					var langOpt = document.createElement("option");
					langOpt.text = langList[i].innerHTML;
					langOpt.value = langList[i];
					try {
						langJump.add(langOpt,null);
					}
				catch(err) {}
				}
				try {
					document.getElementById("column-one").appendChild(langJump);
				}		
				catch(err) {}
				function switchLang() {
					var newURL = document.getElementById("langJump").options[selectedIndex].value;
					location.href = newURL;
				}
			}
		}
		catch(err) {}
	}

	// pt-userpage is only there if already logged in
	try {
		var userNav = document.getElementById("pt-userpage");
		userNav.parentNode.setAttribute('id', 'user-ul');
	}
	catch(err) {}
	// when not, use pt-login
	try {
		var userLogin = document.getElementById("pt-login");
		userLogin.parentNode.parentNode.setAttribute('id', 'login');
		userLogin.parentNode.parentNode.setAttribute('class', '');
	}
	catch(err) {}
}

////////////////////////////////////////////////////////////////////////////////
// Away we go
if (monobook == true) {
	simplepedia();
}

////////////////////////////////////////////////////////////////////////////////
// Auto-updating for firefox users
CheckScriptForUpdate = {
 days: 1, // Days to wait between update checks
 id: '42312',
 time: new Date().getTime() | 0,
 name: 'Simplepedia',
 call: function(response) {
    GM_xmlhttpRequest({
      method: 'GET',
          url: 'https://userscripts.org/scripts/source/'+this.id+'.meta.js',
          onload: function(xpr) {CheckScriptForUpdate.compare(xpr,response);}
      });
  },
 compare: function(xpr,response) {
    this.xversion=/\/\/\s*@version\s+(.*)\s*\n/i.exec(xpr.responseText);
    this.xname=/\/\/\s*@name\s+(.*)\s*\n/i.exec(xpr.responseText);
    if ( (this.xversion) && (this.xname[1] == this.name) ) {
      this.xversion = this.xversion[1].replace(/\./g, '');
      this.xname = this.xname[1];
    } else {
      if ( (xpr.responseText.match('Uh-oh! The page could not be found!')) || (this.xname[1] != this.name) ) GM_setValue('updated', 'off');
      return false;
    }
    if ( (this.xversion > this.version.replace(/\./g, '')) && (confirm('A new version of the '+this.xname+' user script is available. Do you want to update?')) ) {
      GM_setValue('updated', this.time);
      GM_openInTab('http://userscripts.org/scripts/source/'+this.id+'.user.js');
    } else if ( (this.xversion) && (this.xversion > this.version.replace(/\./g, '')) ) {
      if(confirm('Do you want to turn off auto updating for this script?')) {
        GM_setValue('updated', 'off');
        GM_registerMenuCommand("Auto Update "+this.name, function(){GM_setValue('updated', new Date().getTime() | 0);CheckScriptForUpdate.call('return');});
        alert('Automatic updates can be re-enabled for this script from the User Script Commands submenu.');
      } else {
        GM_setValue('updated', this.time);
      }
    } else {
      if(response) alert('No updates available for '+this.name);
      GM_setValue('updated', this.time);
    }
  },
 check: function() {
if (GM_getValue('updated', 0) == 0) GM_setValue('updated', this.time);
if ( (GM_getValue('updated', 0) != 'off') && (+this.time > (+GM_getValue('updated', 0) + (1000*60*60*24*this.days))) ) {
      this.call();
    } else if (GM_getValue('updated', 0) == 'off') {
      GM_registerMenuCommand("Enable "+this.name+" updates", function(){GM_setValue('updated', new Date().getTime() | 0);CheckScriptForUpdate.call(true);});
    } else {
      GM_registerMenuCommand("Check "+this.name+" for updates", function(){GM_setValue('updated', new Date().getTime() | 0);CheckScriptForUpdate.call(true);});
    }
    }
};
if (self.location == top.location && GM_xmlhttpRequest) CheckScriptForUpdate.check();

////////////////////////////////////////////////////////////////////////////////
// Change Log
// Version .982 June 22, 2009
// - Tweaked thumbnail picture padding to correct a hover issue
// 	(thanks sdfghrr)
// - Tweaked Encyclopedia Dramatica again
//
// Version .98 June 2, 2009
// - Added a new about:config / cookie option to make customizing link colors
//   more discoverable
//
// Version .97 June 2, 2009
// - Resolved issues with preference handling in webkit
// - Added disabled preference to dynamically create jump-list of all alternate
//   language versions of a given document on wikipedia 
//   
// Version .96
//  - Generic wiki export has been expanded to specifically support wikia.com,
//    while generically supporting any other site with 'wiki' in the css @import
//
// Version .95 May 18, 2009
// - Improved font selection changes and examples
// - Updated namespace
// - Fixed Auto-updating menu selection controls
//
// Version .94 May 16, 2009
// - Reset font selection to allow greater user control
// - Tweaked javascript style, thanks iandalton
// - Updated css for multiple fixes
//
// Version .93 May 14, 2009
// - Added checks to leave user configured items alone, thanks iandalton
// - Updated css for multiple fixes
//
// Version .92 May 10, 2009
// - Complete rewrite
// - Removed document title adjustment
// - Removed specific site support
// - Added generic mediaWiki detection
// - Added proper search form submission detection
// - Began using GreaseMonkey API - Mac users will need secondary scripts now
//
// Version .9.1 April 30, 2009
// - Fixed front page WikipediA logo (wikipedia moved it)
// - Dumped firefox specific auto-updater in favor of pure js 
//      version by Jarett http://userscripts.org/scripts/show/20145
// - Fixed http/https mixup when browsing secure sites, simplepedia
//      will now also use https to grab external css 
// - Updated front page bookshelves to link to random pages
//      because it makes more sense to me
//      
// Version .9 April 29, 2009
// - Added auto-updating via Another Auto Update Script
//      by  sizzlemctwizzle
//      http://userscripts.org/scripts/show/38017
// - Restored TOC toggle for auscompgeek
//
// Version .8.1.51 April 13, 2009
// - Added support for http://*.intelink.gov/wiki/*, just in case
//
// Version .8.1 April 11, 2009
// - Added a simple wikipedia graphic anchor for / by the search bar
// - Swapped the same out on wikipedia.org/
// - Added support for http://wiki.greasespot.net/*
// - Improved user/editor display option
//
// Version .8 April 5, 2009
// - Added preliminary support for many more wikis http://en.wikipedia.org/wiki/List_of_wikis
//      - with main page bugs calling them all WikipediA
//
// Version .7.5 March 30, 2009
// - Reintroduced edit links, page and user login tabs, ++
//
// Version .7.2.1 March 25, 2009
// - Added helper functions, basic error checking
//
// Version .7.2 March 18, 2009
// - Added basic support for wikileaks.org
// - Added support for secure wikimedia sites
//
// Version .7.1 March 17, 2009
// - Fixed front page form elements in Firefox 
// - Added default language links to the front page
//
// Version .7 March 17, 2009
// - Added 'I'm feeling lucky' and 'Search' buttons to the front portal
// - Reintroduced .noprint content for the main pages
// - Fixed center td border display 