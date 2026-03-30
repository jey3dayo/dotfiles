---
name: dev-browser
description: Browser automation with persistent page state. Use when users ask to navigate websites, fill forms, take screenshots, extract web data, test web apps, or automate browser workflows. Trigger phrases include "go to [url]", "click on", "fill out the form", "take a screenshot", "scrape", "automate", "test the website", "log into", or any browser interaction request.
---

# Dev Browser

A CLI for controlling browsers with sandboxed JavaScript scripts. Scripts run in a QuickJS WASM sandbox (NOT Node.js).

## Basic Usage

Scripts are passed via heredoc to stdin — NOT via `dev-browser run`:

```bash
dev-browser <<'EOF'
  const page = await browser.getPage("main");
  await page.goto("https://example.com");
  console.log(await page.title());
EOF
```

#### Wrong (do NOT use)

- `dev-browser run - <<'EOF'` — `run` requires a file path, not stdin
- `dev-browser --page foo` — `--page` flag does not exist

## Sandbox Constraints

QuickJS environment — the following are NOT available:

- `require()` / `import()` — no module loading
- `process`, `fs`, `path`, `os` — no system access
- `fetch` / `WebSocket` — no direct network access

Available globals:

- `browser` — pre-connected browser handle
- `console.log/warn/error/info`
- `setTimeout` / `clearTimeout`
- `saveScreenshot(buf, name)` — saves to `~/.dev-browser/tmp/`
- `writeFile(name, data)` / `readFile(name)` — temp dir I/O

## browser API

```js
browser.getPage(nameOrId); // Get or create named page (persists between runs)
browser.newPage(); // Create anonymous page (cleaned up after script)
browser.listPages(); // List all tabs: [{id, url, title, name}]
browser.closePage(name); // Close and remove a named page
```

Named pages persist between script runs — no need to re-navigate.

## Key Playwright Page Methods

```js
page.goto(url);
page.title();
page.url();
page.snapshotForAI(options); // AI-optimized snapshot → {full, incremental?}
page.getByRole(role, { name });
page.fill(selector, value);
page.click(selector);
page.press(selector, key);
page.waitForSelector(selector);
page.waitForURL(url);
page.screenshot(); // Returns buffer; save with saveScreenshot(...)
page.evaluate(fn); // Plain JS only — no TypeScript in browser context
page.locator(selector);
page.textContent(selector);
page.innerHTML(selector);
page.$$eval(selector, fn);
```

## Common Patterns

### Snapshot for element discovery

```bash
dev-browser <<'EOF'
const page = await browser.getPage("main");
const result = await page.snapshotForAI();
console.log(result.full);
// Read output, then interact:
// await page.getByRole("button", { name: "Continue" }).click();
EOF
```

### Screenshot

```bash
dev-browser <<'EOF'
const page = await browser.getPage("main");
const buf = await page.screenshot();
const path = await saveScreenshot(buf, "debug.png");
console.log(path);
EOF
```

### Error recovery

```bash
dev-browser <<'EOF'
const page = await browser.getPage("checkout");
const path = await saveScreenshot(await page.screenshot(), "debug.png");
console.log(JSON.stringify({ screenshot: path, url: page.url(), title: await page.title() }));
EOF
```

### Connect to existing Chrome

```bash
dev-browser --connect <<'EOF'
const page = await browser.getPage("main");
console.log(await page.title());
EOF
```

## CLI Options

| Option                  | Default   | Description                                        |
| ----------------------- | --------- | -------------------------------------------------- |
| `--browser <NAME>`      | `default` | Named browser instance (separate state per name)   |
| `--connect [URL]`       | —         | Attach to running Chrome (auto-discover if no URL) |
| `--headless`            | —         | Launch Chromium in headless mode                   |
| `--ignore-https-errors` | —         | Ignore HTTPS certificate errors                    |
| `--timeout <SECONDS>`   | `30`      | Max script execution time                          |

## LLM Tips

- Write small, focused scripts — one action per run
- Use `console.log(JSON.stringify(...))` for structured output
- Prefer `page.snapshotForAI()` for unknown pages; use direct selectors for known ones
- Use short timeouts (`--timeout 10`) so scripts fail fast
- Keep page names stable (e.g. `"login"`, `"checkout"`) for resumability
