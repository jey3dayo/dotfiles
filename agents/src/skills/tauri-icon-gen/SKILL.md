---
name: tauri-icon-gen
description: |
  Use when generating Tauri app icons from existing artwork, converting source
  images into transparent square PNGs, or regenerating platform icon sets for
  Tauri builds. Do not use for skill directory moves, path fixes, distribution,
  or marketplace packaging even if the path contains `tauri-icon-gen`; use
  `skill-creator` instead.
version: 1.0.0
tags: [tauri, icon, png, transparency, image-processing]
triggers:
  - アイコン生成
  - アイコン変換
  - 透過PNG
  - tauri icon
  - app icon
---

# Tauri App Icon Generation

Tauri アプリ用のアイコン生成ワークフロー。ソース画像の白背景除去から全プラットフォーム向けアイコン一式の生成まで。

## Prerequisites

- Python 3 + Pillow (`python3 -m pip install Pillow`)
- pnpm + Tauri CLI (`pnpm tauri icon`)
- Background-removal script path:
  - Codex: `~/.codex/skills/tauri-icon-gen/scripts/remove_white_bg.py`
  - Claude Code: `~/.claude/skills/tauri-icon-gen/scripts/remove_white_bg.py`

## Workflow

### Step 1: ソース画像の透過化

白背景のソース PNG をアルファ透過に変換する。

```bash
python3 ~/.codex/skills/tauri-icon-gen/scripts/remove_white_bg.py <input.png> [output.png]
```

- `threshold=235`: この値以上の RGB は完全透過 (alpha=0)
- `soft_threshold=215`: threshold 未満でもこの値以上なら半透過（エッジのスムージング）
- output を省略すると input を上書き
- Claude Code では `~/.claude/skills/...` 側の同名スクリプトを使う

### Step 2: 透過確認

```bash
python3 - "output.png" <<'PY'
from PIL import Image
import sys

img = Image.open(sys.argv[1])
has_alpha = "yes" if "A" in img.getbands() else "no"
transparent_pixels = (
    sum(1 for alpha in img.getchannel("A").getdata() if alpha == 0)
    if has_alpha == "yes"
    else 0
)

print(f"hasAlpha: {has_alpha}")
print(f"transparentPixels: {transparent_pixels}")
PY
```

`hasAlpha: yes` であることを確認。目視でも透過が正しいか確認する。

### Step 3: Tauri アイコン一式生成

```bash
pnpm tauri icon <source.png>
```

生成先: `src-tauri/icons/`

生成されるもの:

- PNG: 32x32, 64x64, 128x128, 128x128@2x, icon.png (512x512)
- ICNS: macOS 用 (icon.icns)
- ICO: Windows 用 (icon.ico)
- iOS: AppIcon 各サイズ
- Android: mipmap 各密度
- Windows Store: Square ロゴ各サイズ

### Step 4: 生成結果確認

```bash
python3 - "src-tauri/icons/icon.png" <<'PY'
from PIL import Image
import sys

img = Image.open(sys.argv[1])
has_alpha = "yes" if "A" in img.getbands() else "no"

print(f"hasAlpha: {has_alpha}")
print(f"pixelWidth: {img.width}")
print(f"pixelHeight: {img.height}")
PY
```

## Typical Usage (Ultra RSS Reader)

```bash
# ダーク版アイコンの白背景を除去
python3 ~/.codex/skills/tauri-icon-gen/scripts/remove_white_bg.py assets/app-icon.png

# ライト版も同様
python3 ~/.codex/skills/tauri-icon-gen/scripts/remove_white_bg.py assets/app-icon-light.png

# ダーク版をメインアイコンとして全プラットフォーム向けに生成
pnpm tauri icon assets/app-icon.png

# 確認
python3 - "src-tauri/icons/icon.png" <<'PY'
from PIL import Image
import sys

img = Image.open(sys.argv[1])
print(f"hasAlpha: {'yes' if 'A' in img.getbands() else 'no'}")
PY
```

## Notes

- ソース画像は 1024x1024 以上を推奨（Tauri が各サイズにリサイズ）
- macOS の `.icns` と Windows の `.ico` も自動生成される
- 元画像が既に透過であれば Step 1 はスキップ可
- Pillow がない場合: `python3 -m pip install Pillow`
- `ModuleNotFoundError: No module named 'PIL'` が出たら Pillow 未導入
