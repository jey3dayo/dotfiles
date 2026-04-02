---
name: tauri-dev-screenshot
description: Use when a Windows Tauri dev or WebView app is already running and Codex needs HWND-based screenshot capture, occlusion-safe UI snapshots, title-match or active-window resolution, layout debugging, state comparison, or display-breakage checks inside the current project workspace.
---

# Tauri Dev Screenshot

## Overview

Capture a running Tauri dev window on Windows and save it to `<project-root>/tmp/screenshots` as a timestamped PNG.

Prefer the bundled PowerShell script for deterministic capture and machine-readable JSON output.

Prefer direct HWND capture whenever possible. The bundled script resolves a target window to an HWND and captures it with `PrintWindow`, so overlapping windows do not leak into the PNG the way `CopyFromScreen` would.

## Quick Start

Prefer direct window-handle capture for repeatable, occlusion-safe screenshots:

```powershell
$hwnd = (Get-Process | Where-Object { $_.MainWindowTitle -like "*My Tauri App*" } |
  Select-Object -First 1 -ExpandProperty MainWindowHandle)

powershell -ExecutionPolicy Bypass -File .\scripts\capture-tauri-window.ps1 `
  -ProjectRoot C:\path\to\project `
  -WindowHandle $hwnd
```

Use `-ClientArea` when you want only the webview/content area without window chrome:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\capture-tauri-window.ps1 `
  -ProjectRoot C:\path\to\project `
  -WindowHandle $hwnd `
  -ClientArea
```

Use title matching when HWND discovery is inconvenient:

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

- Prefer `-WindowHandle` whenever you can identify the target process or HWND ahead of time.
- Use `-ClientArea` when you want a padding-free capture of only the content area.
- Use `-TitleContains` as a discovery shortcut, then switch to `-WindowHandle` if titles are ambiguous.
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
  "windowHandle": "0x0000000000123456",
  "selector": "window-handle",
  "captureArea": "client",
  "captureMethod": "print-window",
  "timestamp": "2026-04-02T23:14:55.0000000+09:00",
  "bounds": { "left": 100, "top": 80, "width": 1280, "height": 900 }
}
```

Failure shape:

```json
{
  "ok": false,
  "code": "invalid_window_handle",
  "message": "WindowHandle '0xDEADBEEF' is not valid.",
  "selector": "window-handle",
  "windowHandle": "0xDEADBEEF"
}
```

Failure codes:

- `invalid_selector`
- `invalid_window_handle`
- `window_not_found`
- `multiple_windows_matched`
- `window_not_visible`
- `capture_failed`
- `save_failed`

`multiple_windows_matched` may include a `matches` array of candidate titles and handles.

## Script Notes

- Use PowerShell + .NET + Win32 + DWM only.
- Resolve selectors to an HWND, then capture with `PrintWindow` instead of `CopyFromScreen`.
- Capture only visible, non-minimized, non-zero-size top-level windows.
- Use extended frame bounds for whole-window capture and client rect bounds for `-ClientArea`.
- Save PNG files under `<project-root>/tmp/screenshots`.
- Sanitize `-Label` before adding it to the filename.
- Return clear failure reasons instead of throwing raw PowerShell errors.
