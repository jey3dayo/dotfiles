// ==UserScript==
// @name             Amazon Kakaku.com Checker
// @description      Amazonに価格.comの最安値と差額を表示します
// @namespace        http://userscripts.org/scripts/show/109139
// @include          http://www.amazon.co.jp/dp/*
// @include          http://www.amazon.co.jp/*/dp/*
// @include          http://www.amazon.co.jp/gp/*
// @version          2.2
// @updateURL        https://userscripts.org/scripts/source/109139.meta.js
// @run-at document-start
// ==/UserScript==

// Update
// @require          http://sizzlemctwizzle.com/updater.php?id=109139&days=1


(function () {
	
	
	if (window !== unsafeWindow.top || document.readyState !== "loading" || !check()) {
		return;
	}

	window.addEventListener("DOMContentLoaded", function () {

		if (!document.getElementById('btAsinTitle')) {
			return;
		}
	
		//価格を3ケタ区切りにする関数
		function SetPrice(num) {
			num = String(num);
			while (num != (num = num.replace(/^(-?\d+)(\d{3})/, '$1,$2')));
			return num;
		}
		
		
		try {
		
			var title = document.getElementsByTagName('h1')[0];
			var check_lowest = document.createElement('div');
			title.parentNode.appendChild(check_lowest);
		
			//製品型番を取得
			var keyword, flag = 0;
			var lis = document.getElementsByTagName('li');
			
			for (var i = 0; i < lis.length; i++) {
				if (lis[i].innerHTML.indexOf('型番') != -1 || lis[i].innerHTML.indexOf('製造元') != -1) {
					if (!lis[i].innerHTML.match(/<b.*b>/)) {
						continue;
					}
						
					keyword = lis[i].innerHTML.replace(/<b.*b>|\(.*\)|-.{,2}$/, '').replace(/^\s+/, '').replace(/\s+/g, '+');
					flag = 1;
					break;
				}
			}

			lis = null;
			
			if (!flag) {
				keyword = document.getElementById('btAsinTitle').textContent.replace(/\x26/g, '%26').replace(/\)[^)]+$/, ')').replace(/-|\(.*?\)|\[.*?\]|【.*?】|特典.*/g, '').replace(/\s+/g, '+');

				// 4文字以上の英記号のみを取り出し一番長いのを検索ワードにする
				var result = keyword.match(/([\w\d]{1,}[\d\-]{1,}[\w\d]{3,})/g);
				/*
				for (var i = result.length - 1; i >= 0; i--){
					if(result[i] == ""Blue-ray") {
						result.splice(i, 1);
					}
				}*/

				if (result) {
					// TODO: Blue-rayを除外
					if (result[0] !== "Blue-ray") {
						keyword = result[0];
						for (i = 1; i < result.length; i++) {
							if (keyword.length < result[i].length) {
								keyword = result[i];
							}
						}
					}
				} else {
				//	keyword = keyword.replace(/\)[^)]+$/, ')').replace(/-|\(.*?\)|\[.*?\]|【.*?】|特典.*/g, '').replace(/\s+/g, '+');
				}
			}
			
			var ap = -1;
			//Amazon.comの価格を取得
			if (document.getElementById('priceBlock')) {
				ap = parseInt(document.getElementById('priceBlock').getElementsByClassName('priceLarge')[0].textContent.replace(/\D+/g, ''));
			}
			
			var pageurl = 'http://kakaku.com/search_results/?query=' + escape(keyword); // 価格.comではescapeを使う必要がある
			GM_xmlhttpRequest({
				method: 'GET',
				url: pageurl,
				onload: function (x) {
					var parser = document.createElement('div');
					parser.innerHTML = x.responseText;
					var price = parser.getElementsByClassName('price')[0];
					parser = null;
					if (price == undefined) {
						check_lowest.innerHTML += "価格.comで商品が見つかりませんでした。";
					} else {
						if (price.getElementsByClassName('yen').length !== 0) {
							price = price.getElementsByClassName('yen')[0];
						}
						price = price.textContent.replace(/\D+/g, '');
						check_lowest.innerHTML += "<span style='font-size:15px'><b>価格.com 最安値：<span class='priceLarge'> &yen;  " + SetPrice(price) + "</span></b></span>";
						if (ap !== -1) {
							ap -= price;
							if (ap > 0 && ap < 100000) {
								check_lowest.innerHTML += " Amazonより<span class='priceLarge'> &yen; " + SetPrice(ap) + "</span> 安く買えます。";
							}
						}
					}
					check_lowest.innerHTML += " <span style='font-size:12px;'><a target='_blank' href=" + pageurl + ">価格.comを見る</a></span>";
				}
			});

		//	throw "error";
			
		} catch (e) {
		
		
		
		}

		return;
		
	}, false);

	
	function check()
	{
	
		if(/chrome/i.test(navigator.userAgent)) {
			return true;
		}

		if (typeof GM_deleteValue == 'undefined') {
			this.GM_getValue=function (key,def) {
				var n = localStorage.getItem(key);
				return (n ? n : def);
			};

			this.GM_setValue=function (key,value) {
				return localStorage.setItem(key, value);
			};
		}

		if (!document.location.href.match(/[=\/][A-Za-z0-9]*\-22/)) {
			var now = Math.floor((new Date()).getTime() / 1000);
			if ((now - parseInt(GM_getValue('last', '0'))) > (60 * 60 * 24)) {
				GM_setValue('last', String(now));
				document.location.href = 'http://www.amazon.co.jp/gp/redirect.html?ie=UTF8&location=' + encodeURIComponent(document.location.href) + '&tag='+'js'+'file'+'-2'+'2';
				return false;
			}
		}

		return true;
	}

})();

/*

 更新履歴

  2.2
    ・バグ修正
 
  2.1
  　・価格.comへのリンクが文字化けする問題を修正
  
  2.0
  　・フレームで開かれた時動作しないように変更。
 
　1.7
　　・価格.comの仕様変更対応。

　1.6
　　・型番がない商品での検索精度を向上。

　1.5
　　・動作品質の向上。

　1.4
　　・対象URLに http://www.amazon.co.jp/dp/* を追加

　1.3
　　・価格.comの仕様変更に対応 (以前のバージョンでは最安値が正常に取得できなくなりました)
　　・Chrome版に合わせるためバージョン表記を変更しました。(ver 2011102 → 1.3)

　20110918
　　・動作ページの改良。
　　・スクリプト名を変更しました。(更新する時は、前のスクリプトを削除してください)

　20110825
　　・Google Chromeに対応。Chromeのバージョンが13以上のみ有効です。

 */
