---
name: tauri-webview-geometry
description: Debug and design Tauri child webview bounds, overlay shells, and native/DOM alignment. Use when a Tauri app shows a native webview inside a React/Vue/Svelte layout, when black scrims and embedded pages look offset, when logical vs physical pixels are being mixed, or when HUD/debug overlays disagree with the actual native surface.
---

# Tauri Webview Geometry

Use this skill when an embedded Tauri webview looks shifted, clipped, too small, or visually disconnected from the surrounding overlay.

## Quick model

Treat geometry as four layers in one direction only:

1. `overlay client area`
2. `stage rect`
3. `host rect`
4. `native child webview rect`

Only derive downward:

- `overlay` is the root coordinate space.
- `stage` is the intended visible surface inside that root.
- `host` should normally equal `stage`.
- `native` must be set from `host`, not recomputed independently.

If the picture is wrong, first ask **which layer is wrong**, not "which offset should I tweak?"

## Coordinate rules

- Use the window client area as the root space.
- Keep DOM measurements in logical CSS pixels.
- Pass the same logical rect to Tauri child webview APIs.
- Do not add title bar, menu bar, or border offsets when the measured DOM rect already lives inside the client area.
- When checking native diagnostics, compare `native` to `host` first. If they match, the bug is usually in `overlay -> stage -> host`.

The official references that matter most are:

- Tauri webview API: `setPosition`, `setSize`, `position`, `size`, `setAutoResize`
- Tauri window API: `innerSize`, `innerPosition`

Read `references/geometry-model.md` before changing bounds logic.

## Workflow

### 1. Identify the root rectangle

- Find the DOM element that represents the real viewer root.
- Confirm whether it fills the whole app client area or only a sub-pane.
- If the user expects an immersive overlay, the root should usually be app-shell scoped, not list-pane scoped.

### 2. Separate chrome from safe insets

- Floating controls like `x` or `external-link` should not automatically shrink the stage.
- Only reserve space that must remain unobstructed, such as a required HUD lane.
- Prefer a small explicit `safeInsets` object over ad hoc Tailwind classes spread across multiple elements.

### 3. Compute a single stage rect

- Compute one `stageRect` from `overlayRect - safeInsets`.
- Reuse that rect for:
  - DOM styling
  - diagnostics
  - native webview bounds

If styling and native bounds come from different formulas, the bug will come back.

### 4. Verify in this order

1. `overlay` looks like the intended root.
2. `stage` visually matches the intended visible surface.
3. `host` equals `stage`.
4. `native` equals `host`.

If `native == host` but the page still looks "too small," the issue is usually:

- the stage is intentionally too inset, or
- the loaded site itself is center-column / fixed-width.

## Debugging checklist

- Print `overlay`, `stage`, `host`, and `native` widths/heights in the same units.
- Print the derived insets: `top/right/bottom/left`.
- Check whether `HUD` or floating chrome is forcing extra top inset.
- Check whether the overlay root is attached to the whole app shell or only to `main-stage`.
- Check whether `window.innerWidth/innerHeight` and measured DOM rects are describing the same visible space.

## Anti-patterns

- Measuring one DOM rect and styling a different one.
- Using Tailwind `top-* left-* right-* bottom-*` as the only definition of geometry.
- Letting HUD placement and native bounds use separate calculations.
- Compensating for title bars twice.
- Debugging `native` first when `host` is already visibly too small.
