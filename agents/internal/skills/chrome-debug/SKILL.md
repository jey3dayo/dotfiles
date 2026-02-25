---
name: chrome-debug
description: |
  [What] Knowledge base for frontend debugging using Chrome DevTools / MCP / agent-browser.
  [When] Use when: browser debugging, network diagnostics, cookie inspection, or rendering issue investigation is needed.
  [Keywords] chrome, devtools, debug, network, console, cookie, screenshot, WSL, mcp
---

# Chrome Debug Skill

A knowledge base for frontend debugging using Chrome DevTools.
Covers remote debugging in WSL2 environments, MCP Chrome DevTools integration, and agent-browser automation.

## Tool Selection Guide

Select the optimal tool based on your goal:

| Goal                                | Recommended Tool    | Reason                                       |
| ----------------------------------- | ------------------- | -------------------------------------------- |
| Page interaction automation         | agent-browser       | Efficient with snapshot + ref                |
| JavaScript execution / Cookie check | MCP Chrome DevTools | Direct execution via evaluate_script         |
| Network/Console logs                | MCP Chrome DevTools | list_network_requests, list_console_messages |
| Manual deep inspection              | Chrome F12          | Most flexible, breakpoint support            |
| Screenshots                         | agent-browser       | Easy path specification, WSL2 compatible     |

## Debug Modes

### 1. MCP Chrome DevTools (Recommended)

Launch Chrome in remote debug mode and operate via MCP.

### Setup

### Workflow

1. Launch Chrome in debug mode
2. Verify MCP connection
3. `take_snapshot` → `list_console_messages` → `list_network_requests` → `evaluate_script`
4. Save results with `take_screenshot`

### Diagnostic Checklist

### 2. agent-browser

Best for page interaction automation and screenshot capture.

### Workflow

```bash
agent-browser open <TARGET_URL>
agent-browser snapshot -i
# Interact (click, fill, etc.)
agent-browser snapshot -i  # update ref
```

### Diagnostic Patterns

### 3. Manual DevTools (F12)

Fallback when MCP is unavailable.

1. Press F12 in Chrome to open DevTools
2. **Console** tab: Check for JavaScript errors
3. **Network** tab: Check for infinite request loops or failures
4. **Application** > **Cookies**: Inspect cookies

## Common Issues

→ `references/troubleshooting.md`

## References

- `references/wsl-setup.md` — WSL2 ↔ Windows Chrome setup, IP addresses, MCP configuration
- `references/devtools-checklist.md` — DevTools tab-by-tab checkpoints and diagnostic scripts
- `references/agent-browser-patterns.md` — agent-browser diagnostic patterns and screenshot saving
- `references/troubleshooting.md` — Connection errors, stale refs, headed mode, and other solutions
