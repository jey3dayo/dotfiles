# Geometry Model

## Primary sources

- Tauri webview reference: `https://v2.tauri.app/ja/reference/javascript/api/namespacewebview/`
- Tauri window reference: `https://v2.tauri.app/reference/javascript/api/namespacewindow/`

Paraphrased takeaways used by this skill:

- `window.innerSize()` describes the client area, excluding title bar and borders.
- Webview position/size APIs accept logical or physical values explicitly.
- Child webviews can auto-resize with the parent window, but custom embedded layouts still need a stable source rect.

## Source-of-truth chain

Use this chain:

```text
overlayRect
  -> safeInsets
  -> stageRect
  -> hostRect
  -> nativeRect
```

Recommended invariants:

- `hostRect === stageRect`
- `nativeRect === hostRect`

Only `stageRect` should express layout intent.

## Suggested formulas

```text
overlayRect = bounding box of the immersive viewer root

safeInsets = {
  left,
  top,
  right,
  bottom,
}

stageRect = inset(overlayRect, safeInsets)
hostRect = stageRect
nativeRect = hostRect
```

For floating viewer chrome:

- place close / external buttons independently
- do not subtract their full size from `stageRect`
- reserve additional top inset only when a HUD or fixed lane must stay completely outside the native surface

## Interpreting diagnostics

- `overlay` small: wrong portal/root
- `stage` small, `host == native`: layout model bug
- `host` differs from `native`: Tauri/native application bug or wrong rect conversion
- `stage` correct but page still narrow: website layout is the limiting factor

## Recommended implementation pattern

Create a pure helper that accepts:

- viewport width/height
- debug HUD visibility
- compact/narrow mode

and returns:

- `safeInsets`
- `stageRect`
- positions for floating chrome
- optional HUD lane rect

Then make:

- DOM styles use that helper
- diagnostics use that helper
- Rust/native bounds use the measured host rect produced from that helper

That keeps “what should be visible” and “what is sent to native” aligned.
