---
name: tauri-dev-screenshot
description: Use when a Windows Tauri app is already running and Codex needs to capture the app window as a saved screenshot for UI debugging, layout checks, or state snapshots inside the current project workspace.
---

# Tauri Dev Screenshot

## Overview

Capture a running Tauri dev window on Windows and save it to `<project-root>/tmp/screenshots` as a timestamped PNG.

Prefer the bundled PowerShell script for deterministic capture and machine-readable JSON output.

## Quick Start

Prefer title matching for repeatable capture:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\capture-tauri-window.ps1 `
  -ProjectRoot C:\path\to\project `
  -TitleContains "My Tauri App"
```

Use the active window only for manual debugging when the target app is already focused:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\capture-tauri-window.ps1 `
  -ProjectRoot C:\path\to\project `
  -ActiveWindow
```

Add `-Label` to make saved states easier to scan:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\capture-tauri-window.ps1 `
  -ProjectRoot C:\path\to\project `
  -TitleContains "My Tauri App" `
  -Label settings-open
```

## Selector Strategy

- Prefer `-TitleContains` for normal Tauri dev workflows.
- Use case-insensitive partial title matching.
- Use `-ActiveWindow` only when driving the app manually.
- Stop with an error when multiple visible windows match.
- Do not start `tauri dev`, wait for a window, or bring a window to front in this MVP.

## Output Contract

Always emit a single JSON object.

Success shape:

```json
{
  "ok": true,
  "savedPath": "C:\\repo\\tmp\\screenshots\\20260402-231455-home.png",
  "windowTitle": "My App",
  "selector": "title-contains",
  "timestamp": "2026-04-02T23:14:55.0000000+09:00",
  "bounds": { "left": 100, "top": 80, "width": 1280, "height": 900 }
}
```

Failure shape:

```json
{
  "ok": false,
  "code": "window_not_found",
  "message": "No window matched TitleContains='My App'.",
  "selector": "title-contains"
}
```

Failure codes:

- `invalid_selector`
- `window_not_found`
- `multiple_windows_matched`
- `window_not_visible`
- `capture_failed`
- `save_failed`

`multiple_windows_matched` may include a `matches` array of candidate titles.

## Script Notes

- Use PowerShell + .NET + Win32 only.
- Capture only visible, non-minimized, non-zero-size top-level windows.
- Save PNG files under `<project-root>/tmp/screenshots`.
- Sanitize `-Label` before adding it to the filename.
- Return clear failure reasons instead of throwing raw PowerShell errors.
