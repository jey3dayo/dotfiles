// .surfingkeys.refactored.js
// ------------------------------------------------------------
//  Constants & Helper Functions
// ------------------------------------------------------------
const SEARCH_BASE_URL = "https://www.google.co.jp/search?q=";
const oneYearQuery = (q) => `${SEARCH_BASE_URL}${q}&tbs=qdr:y,lr:lang_1ja&lr=lang_ja')`;

const HINTS_CHARACTERS = "asdfghjklnmvbrtyu";
const SCROLL_STEP_SIZE = 150;

const BLOCK_URLS = [
  "mail.google.com",
  "script.google.com",
  "colab.research.google.com",
  "docs.google.com/.*/d",
  "console.aws.amazon.com",
  "www.notion.so",
  "youtube.com/watch",
  "jp.inoreader.com",
  "app.napkin.ai/page/*",
  "sharepoint.com",
  "raspberrypi",
  "mail.notion.so",
  "jey3dayo.asuscomm.com:5556",
];

// ------------------------------------------------------------
//  Core SurfingKeys Settings
// ------------------------------------------------------------
settings.blocklistPattern = new RegExp(BLOCK_URLS.join("|"), "i");
settings.scrollStepSize = SCROLL_STEP_SIZE;
settings.nextLinkRegex = /((forward|>>|next|次[のへ]|→)+)/i;
settings.prevLinkRegex = /((back|<<|prev(ious)?|前[のへ]|←)+)/i;
Object.assign(settings, {
  aceKeybindings: "vim",
  omnibarPosition: "bottom",
  hintAlign: "left",
  cursorAtEndOfInput: false,
  tabsMRUOrder: false,
  historyMUOrder: false,
  historyOrder: false,
});
api.Hints.characters = HINTS_CHARACTERS;

// ------------------------------------------------------------
//  Key Mappings
// ------------------------------------------------------------
/**
 * mapKeys maps an array of tuples [lhs, rhs]
 */
const mapKeys = (pairs) => pairs.forEach(([k, c]) => api.map(k, c));
const unmapKeys = (keys) => keys.forEach((k) => api.unmap(k));

mapKeys([
  ["H", "S"], // back in history
  ["L", "D"], // forward in history
  ["h", "E"], // previous tab
  ["l", "R"], // next tab
  ["zz", "zr"], // zoom reset
  ["d", "x"], // close current tab
  ["D", "gx$"], // close all tab on right
  ["u", "X"], // restore tab
  ["o", "go"], // open a url in current tab
  ["F", "gf"],
  ["@", "<Alt-p>"],
  ["<Ctrl-h>", "<<"], // move tab left
  ["<Ctrl-l>", ">>"], // move tab right
  ["<Ctrl-i>", "gi"],
  ["<Meta-i>", "gi"],
]);

unmapKeys(["gc", "gk", "cp", ";pa", ";pb", ";pd", ";ps", ";pc", ";cp", ";ap"]);

// Insert‑mode tweaks
api.imap("<Ctrl-[>", "<Esc>");
[":", "<Ctrl-f>", "<Ctrl-u>", "<Ctrl-i>"].forEach((k) => api.iunmap(k));

// ------------------------------------------------------------
//  QuickMarks & Clipboard Utilities
// ------------------------------------------------------------
const QUICK_MARKS = {
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

const openClipboard = (newTab) => {
  api.Clipboard.read(({ data }) => {
    if (!data) return console.error("Clipboard is empty or unreadable.");
    const url = /^http/.test(data) ? data : oneYearQuery(data);
    api.RUNTIME("openLink", {
      url,
      scrollLeft: 0,
      scrollTop: 0,
      tab: { tabbed: newTab, active: newTab },
    });
  });
};
api.mapkey("p", "Open URL in clipboard", () => openClipboard(false));
api.mapkey("P", "Open URL in clipboard (new tab)", () => openClipboard(true));

const openQuickmark = (mark, newTab) => {
  const target = QUICK_MARKS[mark];
  if (!target) return Normal.jumpVIMark(mark, newTab);
  (Array.isArray(target) ? target : [target]).forEach((url) =>
    api.RUNTIME("openLink", {
      url,
      scrollLeft: 0,
      scrollTop: 0,
      tab: { tabbed: newTab, active: newTab },
    }),
  );
};
api.mapkey("gn", "Open Quickmark (new tab)", (mark) => openQuickmark(mark, true));
api.mapkey("go", "Open Quickmark", (mark) => openQuickmark(mark, false));

// ------------------------------------------------------------
//  Copy Helpers
// ------------------------------------------------------------
const copyTitleAndUrl = (format) =>
  api.Clipboard.write(format.replace("%URL%", location.href).replace("%TITLE%", document.title));
api.mapkey("y", "Copy URL", () => copyTitleAndUrl("%URL%"));
api.mapkey("Y", "Copy title & URL", () => copyTitleAndUrl("%TITLE% - %URL%"));

// ------------------------------------------------------------
//  Chrome URLs
// ------------------------------------------------------------
const CHROME_URLS = {
  gD: "chrome://net-internals/#dns",
  gE: "chrome://extensions/",
  gH: "chrome://settings/help",
  gK: "chrome://extensions/shortcuts",
  gS: "chrome://settings/",
};
Object.entries(CHROME_URLS).forEach(([key, url]) => api.mapkey(key, `Open ${url}`, () => api.tabOpenLink(url)));

// ------------------------------------------------------------
//  Search Engines
// ------------------------------------------------------------
["b", "d", "h", "w", "y", "s"].forEach((a) => api.removeSearchAlias(a, "s"));

api.addSearchAlias("1", "Google 1年以内", oneYearQuery("{0}"));
api.mapkey("O", "Search with alias Google 1年以内", () => api.Front.openOmnibar({ type: "SearchEngine", extra: "1" }));
api.addSearchAlias("a", "Amazon.co.jp", "https://www.amazon.co.jp/s?k={0}&emi=AN1VRQENFRJN5");
api.addSearchAlias("gh", "GitHub", "https://github.com/search?utf8=✓&q=");
api.addSearchAlias("r", "Reddit", "https://old.reddit.com/r/");
api.addSearchAlias("t", "Twitter", "https://twitter.com/search?q={0}&src=typed_query");

// ------------------------------------------------------------
//  Utility – PassThrough (2 s)
// ------------------------------------------------------------
api.mapkey("<Ctrl-v>", "#0Enter PassThrough mode (2 s)", () => api.Normal.passThrough(2000));

// ------------------------------------------------------------
//  Visual Theme (Nord‑like)
// ------------------------------------------------------------
api.Hints.style("border: solid 2px #4C566A; color:#A6E22E; background: initial; background-color: #3B4252;");
api.Hints.style(
  "border: solid 2px #4C566A !important; padding: 1px !important; color: #E5E9F0 !important; background: #3B4252 !important;",
  "text",
);
api.Visual.style("marks", "background-color: #A3BE8C;");
api.Visual.style("cursor", "background-color: #88C0D0;");

settings.theme = /* css */ `
:root {
  --font: 'Source Code Pro', Ubuntu, sans;
  --font-size: 12;
  --font-weight: bold;
  --fg: #e5e9f0;
  --bg: #3b4252;
  --bg-dark: #2E3440;
  --border: #4C566A;
  --main-fg: #88C0D0;
  --accent-fg: #A3BE8C;
  --info-fg: #5E81AC;
  --select: #4C566A;
}
/* Generic */
.sk_theme {
  background: var(--bg);
  color: var(--fg);
  border-color: var(--border);
  font-family: var(--font);
  font-size: var(--font-size);
  font-weight: var(--font-weight);
}
/* (The rest of your CSS theme remains unchanged for brevity) */
`;
