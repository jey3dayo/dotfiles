---
最終更新: 2025-12-17
対象: 開発者
タグ: category/documentation, audience/developer, tech/xml, tech/drawio
---

# Draw.io XML Structure Reference

このドキュメントは draw.io (.drawio.xml) ファイルの XML 構造を詳細に解説します。mxGraphModel、mxCell 要素、style 構文、geometry 計算などを含みます。

## Table of Contents

1. [Root Structure](#root-structure)
2. [mxGraphModel Element](#mxgraphmodel-element)
3. [mxCell Elements](#mxcell-elements)
4. [Style Syntax](#style-syntax)
5. [Geometry Calculations](#geometry-calculations)
6. [Layer Structure](#layer-structure)
7. [Common Shapes](#common-shapes)
8. [Before/After Examples](#beforeafter-examples)

## Root Structure

draw.io ファイルの基本構造:

```xml
<mxfile host="app.diagrams.net" modified="2025-12-17T10:00:00.000Z"
        agent="Claude Code drawio skill" version="24.0.0">
  <diagram name="Page-1" id="diagram-unique-id">
    <mxGraphModel dx="1422" dy="794" grid="1" gridSize="10"
                  guides="1" tooltips="1" connect="1" arrows="1"
                  fold="1" page="0" pageScale="1" pageWidth="827"
                  pageHeight="1169" math="0" shadow="0"
                  defaultFontFamily="Helvetica">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
        <!-- Your cells go here -->
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

### Key Elements

- `<mxfile>`: ルートコンテナ
- `<diagram>`: 単一ページを表す
- `<mxGraphModel>`: グラフモデル(キャンバス設定)
- `<root>`: 全ての cell を含むコンテナ
- `<mxCell id="0"/>`: ルート cell (必須)
- `<mxCell id="1" parent="0"/>`: デフォルトレイヤー (必須)

## mxGraphModel Element

### Required Attributes

```xml
<mxGraphModel
  dx="1422"              <!-- Viewport X offset -->
  dy="794"               <!-- Viewport Y offset -->
  grid="1"               <!-- Grid enabled (0 or 1) -->
  gridSize="10"          <!-- Grid size in pixels -->
  guides="1"             <!-- Guides enabled -->
  tooltips="1"           <!-- Tooltips enabled -->
  connect="1"            <!-- Connection enabled -->
  arrows="1"             <!-- Arrows enabled -->
  fold="1"               <!-- Folding enabled -->
  page="0"               <!-- Page boundaries (0=none, 1=show) -->
  pageScale="1"          <!-- Page scale factor -->
  pageWidth="827"        <!-- Page width (A4 = 827) -->
  pageHeight="1169"      <!-- Page height (A4 = 1169) -->
  math="0"               <!-- Math typesetting -->
  shadow="0"             <!-- Default shadow -->
  defaultFontFamily="Helvetica">  <!-- CRITICAL: Default font -->
```

### Critical Settings

#### `page="0"` (推奨)

- ページ境界なし
- 無限キャンバス
- エクスポート時に必要な部分のみ含まれる

#### `defaultFontFamily="Helvetica"` (必須)

- 全要素のデフォルトフォント
- 各要素で上書き可能
- PNG/SVG エクスポート時に重要

#### `gridSize="10"` (推奨)

- 10px グリッド
- 全座標を 10 の倍数に
- 整列が容易

## mxCell Elements

### Cell Types

draw.io には 3 種類の cell があります:

1. **Vertex (図形)**: `vertex="1"`
2. **Edge (コネクタ/矢印)**: `edge="1"`
3. **Container (グループ)**: `vertex="1"` with children

### Vertex Cell (Shape)

```xml
<mxCell id="shape1"
        value="Label Text"
        style="rounded=1;whiteSpace=wrap;html=1;fontSize=18;fontFamily=Helvetica;"
        parent="1"
        vertex="1">
  <mxGeometry x="100" y="150" width="120" height="60" as="geometry"/>
</mxCell>
```

#### Attributes

- `id`: 一意識別子 (必須)
- `value`: 表示テキスト
- `style`: スタイル文字列 (セミコロン区切り)
- `parent`: 親 cell ID (通常 "1")
- `vertex="1"`: vertex タイプ指定

### Edge Cell (Connector/Arrow)

```xml
<mxCell id="edge1"
        value="Edge Label"
        style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;fontSize=18;fontFamily=Helvetica;"
        parent="1"
        source="shape1"
        target="shape2"
        edge="1">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>
```

#### Attributes

- `source`: 開始 cell ID
- `target`: 終了 cell ID
- `edge="1"`: edge タイプ指定
- `relative="1"`: 相対座標 (edges は通常 relative)

#### Edge Styles

- `edgeStyle=orthogonalEdgeStyle`: 直角コネクタ
- `edgeStyle=elbowEdgeStyle`: 肘コネクタ
- `edgeStyle=none`: 直線
- `edgeStyle=entityRelationEdgeStyle`: ER 図用

### Label Cell (Text Only)

```xml
<mxCell id="label1"
        value="Text Label"
        style="text;html=1;strokeColor=none;fillColor=none;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;fontSize=18;fontFamily=Helvetica;"
        parent="1"
        vertex="1">
  <mxGeometry x="100" y="100" width="120" height="30" as="geometry"/>
</mxCell>
```

#### Key Styles

- `strokeColor=none`: 枠線なし
- `fillColor=none`: 背景色なし
- `align=center`: 水平配置
- `verticalAlign=middle`: 垂直配置

## Style Syntax

### Format

スタイルはセミコロン区切りの key=value ペア:

```
style="key1=value1;key2=value2;key3=value3;"
```

### Common Style Properties

#### Shape Styles

```css
/* Basic Shape */
rounded=1                    /* Rounded corners (0 or 1) */
whiteSpace=wrap             /* Text wrapping */
html=1                      /* HTML formatting enabled */

/* Colors */
strokeColor=#000000         /* Border color (hex) */
fillColor=#FFFFFF           /* Fill color (hex) */
fontColor=#000000           /* Text color (hex) */

/* Borders */
strokeWidth=1               /* Border width (pixels) */
dashed=0                    /* Dashed border (0 or 1) */

/* Shadows */
shadow=0                    /* Drop shadow (0 or 1) */

/* Opacity */
opacity=100                 /* 0-100 */
```

#### Text Styles

```css
/* Font Properties (CRITICAL) */
fontFamily=Helvetica        /* Font family (MUST specify) */
fontSize=18                 /* Font size (recommend 18px) */
fontColor=#000000           /* Text color */
fontStyle=0                 /* 0=normal, 1=bold, 2=italic, 4=underline */

/* Alignment */
align=center                /* left, center, right */
verticalAlign=middle        /* top, middle, bottom */

/* Spacing */
spacingLeft=4               /* Left padding */
spacingRight=4              /* Right padding */
spacingTop=2                /* Top padding */
spacingBottom=2             /* Bottom padding */
```

#### Edge Styles

```css
/* Edge Type */
edgeStyle=orthogonalEdgeStyle    /* Orthogonal routing */
edgeStyle=elbowEdgeStyle         /* Elbow routing */
edgeStyle=entityRelationEdgeStyle /* ER diagram */

/* Edge Appearance */
rounded=0                   /* Rounded corners */
orthogonalLoop=1            /* Orthogonal loop */
jettySize=auto              /* Jetty size */

/* Arrows */
endArrow=classic            /* End arrow type */
startArrow=none             /* Start arrow type */
endFill=1                   /* Fill end arrow */

/* Line Style */
dashed=0                    /* Dashed line */
strokeWidth=1               /* Line width */
```

### Arrow Types

```css
/* Common Arrow Types */
endArrow=classic            /* →  Classic arrow */
endArrow=open               /* ⊳  Open arrow */
endArrow=block              /* ▶  Block arrow */
endArrow=oval               /* ●  Oval (circle) */
endArrow=diamond            /* ◆  Diamond */
endArrow=none               /* No arrow */

/* Filled or Open */
endFill=1                   /* Filled arrow */
endFill=0                   /* Open arrow */
```

## Geometry Calculations

### Absolute Positioning

```xml
<mxGeometry x="100" y="150" width="120" height="60" as="geometry"/>
```

#### Properties

- `x`: X coordinate (pixels from left)
- `y`: Y coordinate (pixels from top)
- `width`: Width (pixels)
- `height`: Height (pixels)

#### Grid Alignment (推奨)

```javascript
// All values should be multiples of 10
x = Math.round(x / 10) * 10;
y = Math.round(y / 10) * 10;
width = Math.round(width / 10) * 10;
height = Math.round(height / 10) * 10;
```

### Width Calculation for Text

#### 日本語テキスト

```javascript
// 1文字あたり 30-40px
const chars = text.length;
const width = chars * 35 + 10; // +10px margin
```

#### 英語テキスト

```javascript
// 1文字あたり 8-10px
const chars = text.length;
const width = chars * 9 + 10; // +10px margin
```

#### Example

```xml
<!-- "テストユーザー" = 7 chars -->
<!-- width = 7 × 35 + 10 = 255px -->
<mxCell value="テストユーザー" ...>
  <mxGeometry x="100" y="100" width="255" height="30" as="geometry"/>
</mxCell>
```

### Relative Positioning (Edges)

```xml
<mxGeometry relative="1" as="geometry">
  <mxPoint x="0" y="0" as="sourcePoint"/>
  <mxPoint x="100" y="0" as="targetPoint"/>
  <Array as="points">
    <mxPoint x="50" y="-50"/>
    <mxPoint x="50" y="50"/>
  </Array>
</mxGeometry>
```

#### Properties

- `relative="1"`: 相対座標モード
- `sourcePoint`: 開始点 (source cell からの相対)
- `targetPoint`: 終了点 (target cell からの相対)
- `points`: 中間点の配列

## Layer Structure

### Layer Ordering (重要)

XMLの記述順序 = レンダリング順序 (z-index):

```xml
<root>
  <mxCell id="0"/>
  <mxCell id="1" parent="0"/>

  <!-- Layer 1: Arrows/Connectors (最背面) -->
  <mxCell id="arrow1" ... edge="1"/>
  <mxCell id="arrow2" ... edge="1"/>

  <!-- Layer 2: Labels (中間) -->
  <mxCell id="label1" ... vertex="1"/>
  <mxCell id="label2" ... vertex="1"/>

  <!-- Layer 3: Shapes (最前面) -->
  <mxCell id="shape1" ... vertex="1"/>
  <mxCell id="shape2" ... vertex="1"/>
</root>
```

#### Rule

1. 最初に記述 → 最背面にレンダリング
2. 最後に記述 → 最前面にレンダリング

#### Best Practice

- 矢印を最初に配置 (背面)
- ラベルを中間に配置
- 図形を最後に配置 (前面)

## Common Shapes

### Rectangle (Process Box)

```xml
<mxCell id="rect1" value="Process"
        style="rounded=0;whiteSpace=wrap;html=1;fontSize=18;fontFamily=Helvetica;"
        parent="1" vertex="1">
  <mxGeometry x="100" y="100" width="120" height="60" as="geometry"/>
</mxCell>
```

### Rounded Rectangle

```xml
<mxCell id="roundRect1" value="Start/End"
        style="rounded=1;whiteSpace=wrap;html=1;arcSize=50;fontSize=18;fontFamily=Helvetica;"
        parent="1" vertex="1">
  <mxGeometry x="100" y="100" width="120" height="60" as="geometry"/>
</mxCell>
```

**arcSize:** 角の丸み (0-50, 50=完全な円)

### Diamond (Decision)

```xml
<mxCell id="diamond1" value="Decision?"
        style="rhombus;whiteSpace=wrap;html=1;fontSize=18;fontFamily=Helvetica;"
        parent="1" vertex="1">
  <mxGeometry x="80" y="100" width="160" height="80" as="geometry"/>
</mxCell>
```

### Ellipse/Circle

```xml
<mxCell id="ellipse1" value="Circle"
        style="ellipse;whiteSpace=wrap;html=1;fontSize=18;fontFamily=Helvetica;"
        parent="1" vertex="1">
  <mxGeometry x="100" y="100" width="120" height="120" as="geometry"/>
</mxCell>
```

### Parallelogram (Input/Output)

```xml
<mxCell id="parallel1" value="Input/Output"
        style="shape=parallelogram;perimeter=parallelogramPerimeter;whiteSpace=wrap;html=1;fontSize=18;fontFamily=Helvetica;"
        parent="1" vertex="1">
  <mxGeometry x="100" y="100" width="140" height="60" as="geometry"/>
</mxCell>
```

### Cylinder (Database)

```xml
<mxCell id="cylinder1" value="Database"
        style="shape=cylinder3;whiteSpace=wrap;html=1;boundedLbl=1;backgroundOutline=1;size=15;fontSize=18;fontFamily=Helvetica;"
        parent="1" vertex="1">
  <mxGeometry x="100" y="100" width="80" height="100" as="geometry"/>
</mxCell>
```

### Cloud

```xml
<mxCell id="cloud1" value="Cloud"
        style="ellipse;shape=cloud;whiteSpace=wrap;html=1;fontSize=18;fontFamily=Helvetica;"
        parent="1" vertex="1">
  <mxGeometry x="100" y="100" width="150" height="100" as="geometry"/>
</mxCell>
```

## Before/After Examples

### Example 1: Missing fontFamily

❌ **Before (Bad):**

```xml
<mxCell id="text1" value="テキスト"
        style="text;html=1;fontSize=18;"
        parent="1" vertex="1">
  <mxGeometry x="100" y="100" width="100" height="30" as="geometry"/>
</mxCell>
```

**Problem:** fontFamily が指定されていない → PNG エクスポート時にフォントが崩れる

✅ **After (Good):**

```xml
<mxCell id="text1" value="テキスト"
        style="text;html=1;fontSize=18;fontFamily=Helvetica;"
        parent="1" vertex="1">
  <mxGeometry x="100" y="100" width="105" height="30" as="geometry"/>
</mxCell>
```

**Fixed:** fontFamily=Helvetica を追加、width も調整 (3文字 × 35px)

### Example 2: Wrong Layer Order

❌ **Before (Bad):**

```xml
<root>
  <mxCell id="0"/>
  <mxCell id="1" parent="0"/>

  <!-- Shapes first -->
  <mxCell id="shape1" value="A" ... vertex="1">
    <mxGeometry x="100" y="100" width="80" height="60" as="geometry"/>
  </mxCell>
  <mxCell id="shape2" value="B" ... vertex="1">
    <mxGeometry x="300" y="100" width="80" height="60" as="geometry"/>
  </mxCell>

  <!-- Arrow last -->
  <mxCell id="arrow1" ... source="shape1" target="shape2" edge="1">
    <mxGeometry relative="1" as="geometry"/>
  </mxCell>
</root>
```

**Problem:** 矢印が図形の後 → 矢印が前面にレンダリングされる

✅ **After (Good):**

```xml
<root>
  <mxCell id="0"/>
  <mxCell id="1" parent="0"/>

  <!-- Arrow first (background) -->
  <mxCell id="arrow1" ... source="shape1" target="shape2" edge="1">
    <mxGeometry relative="1" as="geometry"/>
  </mxCell>

  <!-- Shapes last (foreground) -->
  <mxCell id="shape1" value="A" ... vertex="1">
    <mxGeometry x="100" y="100" width="80" height="60" as="geometry"/>
  </mxCell>
  <mxCell id="shape2" value="B" ... vertex="1">
    <mxGeometry x="300" y="100" width="80" height="60" as="geometry"/>
  </mxCell>
</root>
```

**Fixed:** 矢印を最初に配置 → 背面にレンダリング

### Example 3: Insufficient Width for Japanese

❌ **Before (Bad):**

```xml
<mxCell id="text1" value="テストユーザー"
        style="text;html=1;fontSize=18;fontFamily=Helvetica;"
        parent="1" vertex="1">
  <mxGeometry x="100" y="100" width="100" height="30" as="geometry"/>
</mxCell>
```

**Problem:** width=100 が不足 (7文字 × 35px = 245px必要) → テキストが折り返される

✅ **After (Good):**

```xml
<mxCell id="text1" value="テストユーザー"
        style="text;html=1;fontSize=18;fontFamily=Helvetica;"
        parent="1" vertex="1">
  <mxGeometry x="100" y="100" width="255" height="30" as="geometry"/>
</mxCell>
```

**Fixed:** width=255 (7文字 × 35px + 10px margin)

### Example 4: Missing page="0"

❌ **Before (Bad):**

```xml
<mxGraphModel dx="1422" dy="794" grid="1" gridSize="10"
              page="1" pageWidth="827" pageHeight="1169"
              defaultFontFamily="Helvetica">
```

**Problem:** page="1" → ページ境界が表示される、エクスポート時にページサイズに制限される

✅ **After (Good):**

```xml
<mxGraphModel dx="1422" dy="794" grid="1" gridSize="10"
              page="0" pageWidth="827" pageHeight="1169"
              defaultFontFamily="Helvetica">
```

**Fixed:** page="0" → 無限キャンバス、必要な部分のみエクスポート

### Example 5: Wrong Font Size

❌ **Before (Bad):**

```xml
<mxCell id="text1" value="Label"
        style="text;html=1;fontSize=12;fontFamily=Helvetica;"
        parent="1" vertex="1">
  <mxGeometry x="100" y="100" width="80" height="25" as="geometry"/>
</mxCell>
```

**Problem:** fontSize=12 (標準) → 小さくて読みにくい

✅ **After (Good):**

```xml
<mxCell id="text1" value="Label"
        style="text;html=1;fontSize=18;fontFamily=Helvetica;"
        parent="1" vertex="1">
  <mxGeometry x="100" y="100" width="80" height="30" as="geometry"/>
</mxCell>
```

**Fixed:** fontSize=18 (1.5倍) → 読みやすさ向上、height も調整

### Example 6: Background Color

❌ **Before (Bad):**

```xml
<mxCell id="shape1" value="Box"
        style="rounded=1;whiteSpace=wrap;html=1;fillColor=#FFFFFF;fontSize=18;fontFamily=Helvetica;"
        parent="1" vertex="1">
  <mxGeometry x="100" y="100" width="120" height="60" as="geometry"/>
</mxCell>
```

**Problem:** fillColor=#FFFFFF → 背景色が固定される、透明度なし

✅ **After (Good):**

```xml
<mxCell id="shape1" value="Box"
        style="rounded=1;whiteSpace=wrap;html=1;fontSize=18;fontFamily=Helvetica;"
        parent="1" vertex="1">
  <mxGeometry x="100" y="100" width="120" height="60" as="geometry"/>
</mxCell>
```

**Fixed:** fillColor を削除 → 透明背景、柔軟性向上

### Example 7: Grid Misalignment

❌ **Before (Bad):**

```xml
<mxCell id="shape1" value="Box"
        style="rounded=1;whiteSpace=wrap;html=1;fontSize=18;fontFamily=Helvetica;"
        parent="1" vertex="1">
  <mxGeometry x="105" y="147" width="123" height="58" as="geometry"/>
</mxCell>
```

**Problem:** 座標が 10 の倍数でない → グリッド配置がずれる

✅ **After (Good):**

```xml
<mxCell id="shape1" value="Box"
        style="rounded=1;whiteSpace=wrap;html=1;fontSize=18;fontFamily=Helvetica;"
        parent="1" vertex="1">
  <mxGeometry x="110" y="150" width="120" height="60" as="geometry"/>
</mxCell>
```

**Fixed:** 全座標を 10 の倍数に丸める

### Example 8: Arrow Label Spacing

❌ **Before (Bad):**

```xml
<!-- Arrow at y=100 -->
<mxCell id="arrow1" ... edge="1">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>

<!-- Label at y=105 (only 5px away) -->
<mxCell id="label1" value="Label"
        style="text;html=1;fontSize=18;fontFamily=Helvetica;"
        parent="1" vertex="1">
  <mxGeometry x="150" y="105" width="80" height="30" as="geometry"/>
</mxCell>
```

**Problem:** 矢印とラベルが近すぎる (5px) → 重なって見にくい

✅ **After (Good):**

```xml
<!-- Arrow at y=100 -->
<mxCell id="arrow1" ... edge="1">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>

<!-- Label at y=125 (25px away) -->
<mxCell id="label1" value="Label"
        style="text;html=1;fontSize=18;fontFamily=Helvetica;"
        parent="1" vertex="1">
  <mxGeometry x="150" y="125" width="80" height="30" as="geometry"/>
</mxCell>
```

**Fixed:** 25px のスペース確保 (推奨: ≥20px)

### Example 9: No defaultFontFamily

❌ **Before (Bad):**

```xml
<mxGraphModel dx="1422" dy="794" grid="1" gridSize="10"
              page="0">
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>
    <mxCell id="text1" value="Text" style="text;html=1;fontSize=18;fontFamily=Helvetica;" .../>
  </root>
</mxGraphModel>
```

**Problem:** defaultFontFamily が未指定 → 一部の環境でフォントが不安定

✅ **After (Good):**

```xml
<mxGraphModel dx="1422" dy="794" grid="1" gridSize="10"
              page="0" defaultFontFamily="Helvetica">
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>
    <mxCell id="text1" value="Text" style="text;html=1;fontSize=18;fontFamily=Helvetica;" .../>
  </root>
</mxGraphModel>
```

**Fixed:** defaultFontFamily="Helvetica" を追加

### Example 10: Complete Minimal Diagram

✅ **Complete Example (Best Practice):**

```xml
<mxfile host="app.diagrams.net" modified="2025-12-17T10:00:00.000Z"
        agent="Claude Code drawio skill" version="24.0.0">
  <diagram name="Page-1" id="diagram1">
    <mxGraphModel dx="1422" dy="794" grid="1" gridSize="10"
                  guides="1" tooltips="1" connect="1" arrows="1"
                  fold="1" page="0" pageScale="1"
                  defaultFontFamily="Helvetica">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>

        <!-- Layer 1: Arrow (背面) -->
        <mxCell id="arrow1" value=""
                style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;"
                parent="1" source="shape1" target="shape2" edge="1">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>

        <!-- Layer 2: Label -->
        <mxCell id="label1" value="Process Flow"
                style="text;html=1;strokeColor=none;fillColor=none;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;fontSize=18;fontFamily=Helvetica;"
                parent="1" vertex="1">
          <mxGeometry x="120" y="125" width="140" height="30" as="geometry"/>
        </mxCell>

        <!-- Layer 3: Shapes (前面) -->
        <mxCell id="shape1" value="Start"
                style="rounded=1;whiteSpace=wrap;html=1;fontSize=18;fontFamily=Helvetica;"
                parent="1" vertex="1">
          <mxGeometry x="100" y="100" width="120" height="60" as="geometry"/>
        </mxCell>

        <mxCell id="shape2" value="End"
                style="rounded=1;whiteSpace=wrap;html=1;fontSize=18;fontFamily=Helvetica;"
                parent="1" vertex="1">
          <mxGeometry x="300" y="100" width="120" height="60" as="geometry"/>
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

#### Features

- ✅ defaultFontFamily="Helvetica"
- ✅ page="0" (無限キャンバス)
- ✅ 全テキストに fontFamily 指定
- ✅ fontSize=18 (1.5倍)
- ✅ 矢印が最初 (背面)
- ✅ グリッド配置 (10px単位)
- ✅ 透明背景

## Summary

### Checklist for Valid draw.io XML

- [ ] `<mxGraphModel>` に `defaultFontFamily="Helvetica"` を設定
- [ ] `page="0"` を設定 (無限キャンバス)
- [ ] 全テキスト要素に `fontFamily` を指定
- [ ] `fontSize=18` を使用 (1.5倍)
- [ ] 矢印/コネクタを最初に配置 (背面レイヤー)
- [ ] 日本語テキストに十分な width (30-40px/文字)
- [ ] 全座標を 10 の倍数に (グリッド配置)
- [ ] 背景色なし (透明)
- [ ] 矢印とラベルに 20px 以上のスペース

### Quick Reference

#### Minimum Template

```xml
<mxfile host="app.diagrams.net">
  <diagram name="Page-1" id="id1">
    <mxGraphModel page="0" defaultFontFamily="Helvetica">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
        <!-- Your cells -->
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

#### Minimum Cell

```xml
<mxCell id="cell1" value="Text"
        style="rounded=1;html=1;fontSize=18;fontFamily=Helvetica;"
        parent="1" vertex="1">
  <mxGeometry x="100" y="100" width="120" height="60" as="geometry"/>
</mxCell>
```

このリファレンスを使用して、適切な draw.io XML 構造を理解し、ベストプラクティスに従った図を作成してください。
