---
name: tauri-dev-screenshot
description: Use when a Tauri dev or WebView app is already running on Windows or macOS and Codex needs window-targeted screenshot capture, title-match or active-window resolution, layout debugging, state comparison, or display-breakage checks inside the current project workspace.
---

# Tauri Dev Screenshot

## Overview

Capture a running Tauri dev window on Windows or macOS and save it to `<project-root>/tmp/screenshots` as a timestamped PNG.

Prefer the bundled platform-native scripts for deterministic capture and machine-readable JSON output.

- Windows: prefer direct HWND capture whenever possible. The bundled PowerShell script resolves a target window to an HWND and captures it with `PrintWindow`, so overlapping windows do not leak into the PNG the way `CopyFromScreen` would.
- macOS: prefer direct window-id capture whenever possible. The bundled Swift script resolves a target window via `CGWindowListCopyWindowInfo` and captures it via `screencapture -l<windowid>`.

## Quick Start

### Windows

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

### macOS

Prefer direct window-id capture for repeatable screenshots:

```bash
swift ./scripts/capture-tauri-window-macos.swift \
  --project-root /path/to/project \
  --window-handle 1033
```

Use title matching when window-id discovery is inconvenient:

```bash
swift ./scripts/capture-tauri-window-macos.swift \
  --project-root /path/to/project \
  --title-contains "My Tauri App"
```

Use the frontmost app window only for manual debugging when the target app is already focused:

```bash
swift ./scripts/capture-tauri-window-macos.swift \
  --project-root /path/to/project \
  --active-window
```

Add `--label` to make saved states easier to scan:

```bash
swift ./scripts/capture-tauri-window-macos.swift \
  --project-root /path/to/project \
  --title-contains "My Tauri App" \
  --label settings-open
```

## Selector Strategy

- Prefer `-WindowHandle` whenever you can identify the target process or HWND ahead of time.
- Use `-ClientArea` when you want a padding-free capture of only the content area.
- Use `-TitleContains` as a discovery shortcut, then switch to `-WindowHandle` if titles are ambiguous.
- Use case-insensitive partial title matching.
- Use `-ActiveWindow` only when driving the app manually.
- Stop with an error when multiple visible windows match.
- Do not start `tauri dev`, wait for a window, or bring a window to front in this MVP.
- On macOS, `window-handle` means `CGWindowID`.
- On macOS, `ClientArea` is not supported in this MVP.

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
  "captureArea": "window",
  "captureMethod": "print-window",
  "timestamp": "2026-04-02T23:14:55.0000000+09:00",
  "bounds": { "left": 100, "top": 80, "width": 1280, "height": 900 }
}
```

`captureMethod` is platform-specific:

- Windows: `print-window`
- macOS: `screencapture-window-id`

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
- `permission_denied`

`multiple_windows_matched` may include a `matches` array of candidate titles and handles.

## Script Notes

- Windows uses PowerShell + .NET + Win32 + DWM.
- macOS uses Swift + AppKit + CoreGraphics + `/usr/sbin/screencapture`.
- Resolve selectors to a native window identifier before capture.
- Capture only visible, non-minimized, non-zero-size top-level windows.
- Windows uses extended frame bounds for whole-window capture and client rect bounds for `-ClientArea`.
- macOS requires Screen Recording permission and returns `permission_denied` when it is missing.
- Save PNG files under `<project-root>/tmp/screenshots`.
- Sanitize the label before adding it to the filename.
- Return clear failure reasons instead of throwing raw PowerShell errors.
