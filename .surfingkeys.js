// Constants
const SEARCH_URL = "https://www.google.co.jp/search?q=";
const HINTS_CHARACTERS = "asdfghjklnmvbrtyu";
const SCROLL_STEP_SIZE = 150;

settings.blocklistPattern =
  /youtube.com\/watch|mail.google.com|console.aws.amazon.com|docs.google.com\/.*\/d/i;

// Search Query Function
const searchWordQuery = (q) =>
  `${SEARCH_URL}${q}&tbs=qdr:y,lr:lang_1ja&lr=lang_ja')`;

// Settings
api.Hints.characters = HINTS_CHARACTERS;
settings.scrollStepSize = SCROLL_STEP_SIZE;
settings.nextLinkRegex = /((forward|>>|next|次[のへ]|→)+)/i;
settings.prevLinkRegex = /((back|<<|prev(ious)?|前[のへ]|←)+)/i;
settings.aceKeybindings = "vim";
settings.omnibarPosition = "bottom";
settings.hintAlign = "left";
settings.cursorAtEndOfInput = false;
settings.tabsMRUOrder = false;
settings.historyMUOrder = false;
settings.historyOrder = false;
settings.aceKeybindings = true;

// Key Mappings
api.map("H", "S"); // back in history
api.map("L", "D"); // forward in history
api.map("h", "E"); // previous tab
api.map("l", "R"); // next tab
api.map("zz", "zr"); // zoom reset
api.map("d", "x"); // close current tab
api.map("D", "gx$"); // close all tab on right
api.map("u", "X"); // restore tab
api.map("o", "go"); // open a url in current tab
api.map("F", "gf");
api.map("@", "<Alt-p>");
api.map("<Ctrl-h>", "<<"); // Move current tab to left
api.map("<Ctrl-l>", ">>"); // Move current tab to right
api.map("<Ctrl-i>", "gi");
api.map("<Meta-i>", "gi");

// Chrome URLs
api.unmap("gc");
api.unmap("gk");

// Proxy
api.unmap("cp");
api.unmap(";pa");
api.unmap(";pb");
api.unmap(";pd");
api.unmap(";ps");
api.unmap(";pc");
api.unmap(";cp");
api.unmap(";ap");

// Insert Mode
api.imap("<Ctrl-[>", "<Esc>");
api.iunmap(":"); // disable emoji completion
api.iunmap("<Ctrl-f>");
api.iunmap("<Ctrl-u>");
api.iunmap("<Ctrl-i>");

// Site
const defaultUnmapAllExcept = [
  "<Ctrl-i>",
  "q",
  "f",
  "F",
  "<Ctrl-k>",
  "<Ctrl-j>",
  "T",
  "X",
  "h",
  "l",
  "w",
  "L",
  "H",
  "t",
  "v",
  "b",
  "'",
];

const urls = [
  "jp.inoreader.com",
  "colab.research.google.com",
  "docs.google.com",
];
const regex = new RegExp(urls.join("|"), "i");
api.unmapAllExcept(defaultUnmapAllExcept, regex);

api.unmapAllExcept(["h", "l", "d", "u", "r"], /irodr.netlify.app/);

// qMark
// cf. https://gist.github.com/chroju/2118c2193fb9892d95b9686eb95189d2
var overlaidGlobalMarks = {
  // webservice
  M: "https://moneyforward.com/",
  n: "https://www.notion.so/",
  a: "https://www.amazon.co.jp/",
  b: "https://b.hatena.ne.jp/J138/bookmark",
  g: "https://www.github.com",
  m: "https://mail.google.com/mail/u/0/",
  N: "https://www.netflix.com/",
  t: "https://twitter.com/",
  w: "https://healthmate.withings.com/",
  y: "https://wwww.youtube.com/",
  l: "https://localhost.ca-adv.dev:3000",
  L: "http://localhost:8080",
};

// paste URL
const openClipboard = ({ newTab }) => {
  api.Clipboard.read(({ data }) => {
    var markInfo = {
      scrollLeft: 0,
      scrollTop: 0,
      tab: { tabbed: newTab, active: newTab },
      url: /^http/.test(data) ? data : searchWordQuery(data),
    };
    api.RUNTIME("openLink", markInfo);
  });
};
api.mapkey("p", "Open URL in clipboard", () =>
  openClipboard({ newTab: false }),
);
api.mapkey("P", "Open clipboard URL in new tab", () =>
  openClipboard({ newTab: true }),
);

api.mapkey("gn", "Open Quickmark in new tab", (mark) => {
  var priorityURLs = overlaidGloalMarks[mark];
  if (priorityURLs === undefined) {
    // fallback to Surfingkeys default jump
    Normal.jumpVIMark(mark, true);
    return;
  }
  if (typeof priorityURLs == typeof "") {
    priorityURLs = [priorityURLs];
  }
  for (var url of priorityURLs) {
    var markInfo = {
      url: url,
      scrollLeft: 0,
      scrollTop: 0,
    };
    markInfo.tab = {
      tabbed: true,
      active: true,
    };
    api.RUNTIME("openLink", markInfo);
  }
});

api.mapkey("go", "Open Quickmark in current tab", (mark) => {
  var priorityURLs = overlaidGlobalMarks[mark];
  if (priorityURLs === undefined) {
    // fallback to Surfingkeys default jump
    Normal.jumpVIMark(mark, true);
    return;
  }
  if (typeof priorityURLs == typeof "") {
    priorityURLs = [priorityURLs];
  }
  for (var url of priorityURLs) {
    var markInfo = {
      url: url,
      scrollLeft: 0,
      scrollTop: 0,
    };
    markInfo.tab = {
      tabbed: false,
      active: false,
    };
    api.RUNTIME("openLink", markInfo);
  }
});

// Copy
// cf. https://github.com/hushin/dotfiles/blob/master/docs/SurfingkeysSetting.js
const copyTitleAndUrl = (format) => {
  const text = format
    .replace("%URL%", location.href)
    .replace("%TITLE%", document.title);
  api.Clipboard.write(text);
};

api.mapkey("y", "Copy link", () => copyTitleAndUrl("%URL%"));
api.mapkey("Y", "Copy title and url", () => copyTitleAndUrl("%TITLE% - %URL%"));

api.mapkey("gD", "Open Chrome dns cache", function () {
  api.tabOpenLink("chrome://net-internals/#dns");
});
api.mapkey("gE", "Open Chrome Extensions", function () {
  api.tabOpenLink("chrome://extensions/");
});
api.mapkey("gH", "Open Chrome Help", function () {
  api.tabOpenLink("chrome://settings/help");
});
api.mapkey("gK", "Open Chrome Extensons shortcuts", function () {
  api.tabOpenLink("chrome://extensions/shortcuts");
});
api.mapkey("gS", "Open Chrome Settings", function () {
  api.tabOpenLink("chrome://settings/");
});

// short Amazon URL include AA.
// api.mapkey(',a', 'short Amazon URL include AA.', () => {
//   var affliateId = 'uncB9uZ7Md9P0d-22';
//   var asin = document.body.querySelector("input[name^='ASIN']").value;
//   var url = `https://www.amazon.co.jp/exec/obidos/ASIN/${asin}/${affliateId}`;
//   location.href = url;
// });

// Search Engines
api.removeSearchAlias("b", "s");
api.removeSearchAlias("d", "s");
api.removeSearchAlias("h", "s");
api.removeSearchAlias("w", "s");
api.removeSearchAlias("y", "s");
api.removeSearchAlias("s", "s");

// Search
api.addSearchAlias("1", "Google 1年以内", searchWordQuery("{0}"));
api.mapkey("O", "Search with alias Google 1年以内", () =>
  api.Front.openOmnibar({ type: "SearchEngine", extra: "1" }),
);
api.addSearchAlias(
  "a",
  "Amazon.co.jp",
  "https://www.amazon.co.jp/s?k={0}&emi=AN1VRQENFRJN5",
);
api.addSearchAlias("gh", "github", "https://github.com/search?utf8=✓&q=", "s");
api.addSearchAlias("r", "reddit", "https://old.reddit.com/r/", "s");
api.addSearchAlias(
  "t",
  "twitter",
  "https://twitter.com/search?q={0}&src=typed_query",
  "s",
);

// Help
// PassThrough mode 2秒間だけsurfingkeys無効
api.mapkey(
  "<Ctrl-v>",
  "#0enter ephemeral PassThrough mode to temporarily suppress SurfingKeys",
  function () {
    api.Normal.passThrough(2000);
  },
);

// Theme
api.Hints.style(
  "border: solid 2px #4C566A; color:#A6E22E; background: initial; background-color: #3B4252;",
);
api.Hints.style(
  "border: solid 2px #4C566A !important; padding: 1px !important; color: #E5E9F0 !important; background: #3B4252 !important;",
  "text",
);
api.Visual.style("marks", "background-color: #A3BE8C;");
api.Visual.style("cursor", "background-color: #88C0D0;");

settings.theme = `
:root {
  /* Font */
  --font: 'Source Code Pro', Ubuntu, sans;
  --font-size: 12;
  --font-weight: bold;
   /* -------------- */
  /* --- THEMES --- */
  /* -------------- */
  /* -------------------- */
  /* --      NORD      -- */
  /* -------------------- */
  --fg: #e5e9f0;
  --bg: #3b4252;
  --bg-dark: #2E3440;
  --border: #4C566A;
  --main-fg: #88C0D0;
  --accent-fg: #A3BE8C;
  --info-fg: #5E81AC;
  --select: #4C566A;
  /* Unused Alternate Colors */
  /* --orange: #D08770; */
  /* --red: #BF616A; */
  /* --yellow: #EBCB8B; */
}
/* ---------- Generic ---------- */
.sk_theme {
background: var(--bg);
color: var(--fg);
  background-color: var(--bg);
  border-color: var(--border);
  font-family: var(--font);
  font-size: var(--font-size);
  font-weight: var(--font-weight);
}
input {
  font-family: var(--font);
  font-weight: var(--font-weight);
}
.sk_theme tbody {
  color: var(--fg);
}
.sk_theme input {
  color: var(--fg);
}
/* Hints */
#sk_hints .begin {
  color: var(--accent-fg) !important;
}
#sk_tabs .sk_tab {
  background: var(--bg-dark);
  border: 1px solid var(--border);
  color: var(--fg);
}
#sk_tabs .sk_tab_hint {
  background: var(--bg);
  border: 1px solid var(--border);
  color: var(--accent-fg);
}
.sk_theme #sk_frame {
  background: var(--bg);
  opacity: 0.2;
  color: var(--accent-fg);
}
/* ---------- Omnibar ---------- */
/* Uncomment this and use settings.omnibarPosition = 'bottom' for Pentadactyl/Tridactyl style bottom bar */
/* .sk_theme#sk_omnibar {
  width: 100%;
  left: 0;
} */
.sk_theme .title {
  color: var(--accent-fg);
}
.sk_theme .url {
  color: var(--main-fg);
}
.sk_theme .annotation {
  color: var(--accent-fg);
}
.sk_theme .omnibar_highlight {
  color: var(--accent-fg);
}
.sk_theme .omnibar_timestamp {
  color: var(--info-fg);
}
.sk_theme .omnibar_visitcount {
  color: var(--accent-fg);
}
.sk_theme #sk_omnibarSearchResult ul li:nth-child(odd) {
  background: var(--bg-dark);
}
.sk_theme #sk_omnibarSearchResult ul li.focused {
  background: var(--border);
}
.sk_theme #sk_omnibarSearchArea {
  border-top-color: var(--border);
  border-bottom-color: var(--border);
}
.sk_theme #sk_omnibarSearchArea input,
.sk_theme #sk_omnibarSearchArea span {
  font-size: var(--font-size);
}
.sk_theme .separator {
  color: var(--accent-fg);
}
/* ---------- Popup Notification Banner ---------- */
#sk_banner {
  font-family: var(--font);
  font-size: var(--font-size);
  font-weight: var(--font-weight);
  background: var(--bg);
  border-color: var(--border);
  color: var(--fg);
  opacity: 0.9;
}
/* ---------- Popup Keys ---------- */
#sk_keystroke {
  background-color: var(--bg);
}
.sk_theme kbd .candidates {
  color: var(--info-fg);
}
.sk_theme span.annotation {
  color: var(--accent-fg);
}
/* ---------- Popup Translation Bubble ---------- */
#sk_bubble {
  background-color: var(--bg) !important;
  color: var(--fg) !important;
  border-color: var(--border) !important;
}
#sk_bubble * {
  color: var(--fg) !important;
}
#sk_bubble div.sk_arrow div:nth-of-type(1) {
  border-top-color: var(--border) !important;
  border-bottom-color: var(--border) !important;
}
#sk_bubble div.sk_arrow div:nth-of-type(2) {
  border-top-color: var(--bg) !important;
  border-bottom-color: var(--bg) !important;
}
/* ---------- Search ---------- */
#sk_status,
#sk_find {
  font-size: var(--font-size);
  border-color: var(--border);
}
.sk_theme kbd {
  background: var(--bg-dark);
  border-color: var(--border);
  box-shadow: none;
  color: var(--fg);
}
.sk_theme .feature_name span {
  color: var(--main-fg);
}
/* ---------- ACE Editor ---------- */
#sk_editor {
  background: var(--bg-dark) !important;
  height: 50% !important;
  /* Remove this to restore the default editor size */
}
.ace_dialog-bottom {
  border-top: 1px solid var(--bg) !important;
}
.ace-chrome .ace_print-margin,
.ace_gutter,
.ace_gutter-cell,
.ace_dialog {
  background: var(--bg) !important;
}
.ace-chrome {
  color: var(--fg) !important;
}
.ace_gutter,
.ace_dialog {
  color: var(--fg) !important;
}
.ace_cursor {
  color: var(--fg) !important;
}
.normal-mode .ace_cursor {
  background-color: var(--fg) !important;
  border: var(--fg) !important;
  opacity: 0.7 !important;
}
.ace_marker-layer .ace_selection {
  background: var(--select) !important;
}
.ace_editor,
.ace_dialog span,
.ace_dialog input {
  font-family: var(--font);
  font-size: var(--font-size);
  font-weight: var(--font-weight);
}
`;
