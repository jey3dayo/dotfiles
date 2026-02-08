---
最終更新: 2025-12-17
対象: 開発者
タグ: category/documentation, audience/developer, tech/typography, tech/drawio
---

# Draw.io Font Configuration Reference

このドキュメントは draw.io ダイアグラムにおけるフォント設定とタイポグラフィ管理の完全ガイドです。PNG/SVG エクスポート時のフォントレンダリング問題を解決するための重要な情報を含みます。

## Table of Contents

1. [Font Hierarchy](#font-hierarchy)
2. [Critical Requirement](#critical-requirement)
3. [Font Size Strategy](#font-size-strategy)
4. [Multi-Language Support](#multi-language-support)
5. [Fallback Font Chains](#fallback-font-chains)
6. [PNG/SVG Export Issues](#pngsvg-export-issues)
7. [Troubleshooting](#troubleshooting)
8. [Best Practices](#best-practices)

## Font Hierarchy

draw.io のフォント設定には2つのレベルがあります:

### Level 1: Model-Level Default (mxGraphModel)

```xml
<mxGraphModel ... defaultFontFamily="Helvetica">
```

#### Purpose

- 全要素のデフォルトフォントを設定
- アプリ内プレビューで使用される
- **注意:** PNG/SVG エクスポート時には不十分

#### Limitation

- PNG/SVG エクスポート時、このレベルだけではフォントが適用されない
- 各要素に明示的な fontFamily 指定が必須

### Level 2: Element-Level Override (mxCell style)

```xml
<mxCell ... style="...; fontFamily=Helvetica; fontSize=18; ..." />
```

#### Purpose

- 各テキスト要素に明示的にフォントを指定
- PNG/SVG エクスポート時に正しくレンダリングされる
- **必須:** 全テキスト要素に指定

## Critical Requirement

### The Golden Rule

> **全テキスト要素に明示的な `fontFamily` を指定すること**

これは PNG/SVG エクスポート時に正しいフォントでレンダリングするための**絶対条件**です。

### Why It Matters

draw.io のエクスポート機能は以下の順序でフォントを解決します:

1. **Element-level fontFamily** (mxCell style 内)
2. ~~Model-level defaultFontFamily~~ (エクスポート時は無視される)
3. System default (環境依存、予測不可能)

#### Result

- ✅ Element-level fontFamily あり → 指定フォントでレンダリング
- ❌ Element-level fontFamily なし → システムデフォルト (環境依存)

### Bad Example (Common Mistake)

```xml
<!-- ❌ BAD: model-level のみ -->
<mxGraphModel defaultFontFamily="Helvetica">
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>

    <!-- fontFamily がない! -->
    <mxCell id="text1" value="テキスト"
            style="text;html=1;fontSize=18;"
            parent="1" vertex="1">
      <mxGeometry x="100" y="100" width="105" height="30" as="geometry"/>
    </mxCell>
  </root>
</mxGraphModel>
```

#### Problem

- アプリ内では Helvetica でプレビューされる (defaultFontFamily が効く)
- PNG エクスポートすると異なるフォントになる (環境依存)

### Good Example (Correct)

```xml
<!-- ✅ GOOD: 両方指定 -->
<mxGraphModel defaultFontFamily="Helvetica">
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>

    <!-- fontFamily を明示! -->
    <mxCell id="text1" value="テキスト"
            style="text;html=1;fontSize=18;fontFamily=Helvetica;"
            parent="1" vertex="1">
      <mxGeometry x="100" y="100" width="105" height="30" as="geometry"/>
    </mxCell>
  </root>
</mxGraphModel>
```

#### Result

- アプリ内: Helvetica (defaultFontFamily)
- PNG エクスポート: Helvetica (element fontFamily)
- 一貫性が保たれる ✓

## Font Size Strategy

### The 1.5× Rule

標準フォントサイズ (12px) の 1.5倍 = **18px** を推奨します。

#### Rationale

- より読みやすい
- プレゼンテーション/ドキュメントに適した大きさ
- 小さい画面でも視認性が高い

### Size Hierarchy

```
Title:      24px (18px × 1.33)
Heading:    20px (18px × 1.11)
Body:       18px (標準)
Caption:    14px (18px × 0.78)
```

### Example

```xml
<!-- Title -->
<mxCell value="System Architecture"
        style="text;html=1;fontSize=24;fontFamily=Helvetica;fontStyle=1;"
        .../>

<!-- Body Text -->
<mxCell value="Application Server"
        style="text;html=1;fontSize=18;fontFamily=Helvetica;"
        .../>

<!-- Caption -->
<mxCell value="*Internal use only"
        style="text;html=1;fontSize=14;fontFamily=Helvetica;fontStyle=2;"
        .../>
```

### fontStyle Values

```css
fontStyle=0   /* Normal */
fontStyle=1   /* Bold */
fontStyle=2   /* Italic */
fontStyle=3   /* Bold + Italic */
fontStyle=4   /* Underline */
fontStyle=5   /* Bold + Underline */
```

## Multi-Language Support

### Japanese + English

日本語と英語が混在する場合、以下のフォントを推奨:

#### Option 1: Helvetica (推奨)

```xml
style="fontFamily=Helvetica;fontSize=18;"
```

#### Pros

- クロスプラットフォーム対応
- 日本語・英語両方に対応
- draw.io のデフォルト

#### Cons

- 日本語の美しさは Hiragino Sans に劣る

#### Option 2: Hiragino Sans (macOS)

```xml
style="fontFamily=Hiragino Sans;fontSize=18;"
```

#### Pros

- 日本語が美しい
- macOS 標準

#### Cons

- macOS 専用 (Windows/Linux では代替フォント)

#### Option 3: Noto Sans JP (Web)

```xml
style="fontFamily=Noto Sans JP;fontSize=18;"
```

#### Pros

- 日本語専用フォント
- Web フォントとして利用可能

#### Cons

- ローカル環境にインストールが必要
- ファイルサイズが大きい

### Recommendation

**Helvetica を推奨** (理由: クロスプラットフォーム対応、安定性)

## Fallback Font Chains

### Concept

複数のフォントをカンマ区切りで指定し、フォールバックチェーンを構築:

```xml
style="fontFamily=Hiragino Sans,Arial,sans-serif;fontSize=18;"
```

#### Resolution Order

1. Hiragino Sans (available on macOS)
2. Arial (available on Windows/macOS)
3. sans-serif (system default sans-serif)

### Common Chains

#### For Japanese

```xml
<!-- macOS優先 -->
style="fontFamily=Hiragino Sans,Arial,sans-serif;"

<!-- Windows優先 -->
style="fontFamily=Meiryo,Arial,sans-serif;"

<!-- Web フォント -->
style="fontFamily=Noto Sans JP,Helvetica,sans-serif;"
```

#### For English

```xml
<!-- Sans-serif -->
style="fontFamily=Helvetica,Arial,sans-serif;"

<!-- Serif -->
style="fontFamily=Times New Roman,serif;"

<!-- Monospace (code) -->
style="fontFamily=Courier New,monospace;"
```

### When to Use Fallbacks

#### Use

- マルチプラットフォーム対応が必要
- 特定フォントが利用できない環境を考慮
- チーム内で異なる OS を使用

#### Don't Use

- シンプルさを優先する場合
- Helvetica だけで十分な場合
- トークン数を節約したい場合

## PNG/SVG Export Issues

### Common Issue: Font Not Applied

#### Symptom

- draw.io アプリ内では正しいフォントで表示
- PNG/SVG エクスポート後、異なるフォントになる

#### Cause

```xml
<!-- defaultFontFamily はあるが... -->
<mxGraphModel defaultFontFamily="Helvetica">
  <!-- Element-level fontFamily がない! -->
  <mxCell value="Text" style="text;html=1;fontSize=18;" .../>
</mxGraphModel>
```

#### Solution

```xml
<mxGraphModel defaultFontFamily="Helvetica">
  <!-- Element-level fontFamily を追加 -->
  <mxCell value="Text" style="text;html=1;fontSize=18;fontFamily=Helvetica;" .../>
</mxGraphModel>
```

### Verification Method

#### Step 1: Check XML

```bash
# Count fontFamily occurrences
grep -o 'fontFamily=' diagram.drawio.xml | wc -l

# Count text elements (approximate)
grep -o 'value="[^"]*"' diagram.drawio.xml | wc -l
```

#### 両方の数が一致するか近い値であるべき

#### Step 2: Export Test

1. Open diagram in draw.io
2. Export as PNG (File > Export as > PNG)
3. Open exported PNG
4. Verify font appearance

#### Step 3: Compare

- アプリ内表示と PNG を比較
- フォントが同じか確認

### Edge Case: Font Substitution

一部の環境では指定フォントが利用できず、代替フォントが使用される:

#### Solution: Test on target platform

```bash
# macOS
open diagram.drawio.xml  # draw.io desktop app

# Export PNG
# Verify on production environment
```

## Troubleshooting

### Issue 1: Japanese Text Appears in Wrong Font

#### Cause

- fontFamily 未指定
- フォールバックチェーン不足

#### Solution

```xml
<!-- Before -->
<mxCell value="日本語" style="text;html=1;fontSize=18;" .../>

<!-- After -->
<mxCell value="日本語" style="text;html=1;fontSize=18;fontFamily=Helvetica;" .../>
```

### Issue 2: Font Changes After Export

#### Cause

- Element-level fontFamily が欠けている

#### Solution

```bash
# Find all text elements without fontFamily
grep -E 'value="[^"]*"' diagram.drawio.xml | grep -v 'fontFamily='

# Add fontFamily to each
```

### Issue 3: Text Width Incorrect for Japanese

#### Cause

- 日本語は英語より幅が広い (30-40px/char vs 8-10px/char)

#### Solution

```xml
<!-- Calculate width: chars × 35px + 10px margin -->
<mxCell value="テストユーザー"
        style="text;html=1;fontSize=18;fontFamily=Helvetica;"
        parent="1" vertex="1">
  <!-- 7 chars × 35px + 10px = 255px -->
  <mxGeometry x="100" y="100" width="255" height="30" as="geometry"/>
</mxCell>
```

### Issue 4: Bold/Italic Not Working

#### Cause

- fontStyle 未指定

#### Solution

```xml
<!-- Bold -->
<mxCell value="Bold Text"
        style="text;html=1;fontSize=18;fontFamily=Helvetica;fontStyle=1;" .../>

<!-- Italic -->
<mxCell value="Italic Text"
        style="text;html=1;fontSize=18;fontFamily=Helvetica;fontStyle=2;" .../>

<!-- Bold + Italic -->
<mxCell value="Bold Italic"
        style="text;html=1;fontSize=18;fontFamily=Helvetica;fontStyle=3;" .../>
```

### Issue 5: Font Too Small in Presentation

#### Cause

- fontSize=12 (標準) は小さすぎる

#### Solution

```xml
<!-- Use 18px (1.5×) -->
<mxCell value="Text"
        style="text;html=1;fontSize=18;fontFamily=Helvetica;" .../>
```

## Best Practices

### ✅ DO

#### 1. Always Specify fontFamily at Element Level

```xml
<mxCell value="Text" style="...; fontFamily=Helvetica; ..." .../>
```

#### 2. Use 18px Font Size

```xml
style="fontSize=18;fontFamily=Helvetica;"
```

#### 3. Set defaultFontFamily at Model Level (as backup)

```xml
<mxGraphModel defaultFontFamily="Helvetica" ...>
```

#### 4. Use Helvetica for Cross-Platform Compatibility

```xml
style="fontFamily=Helvetica;"
```

#### 5. Calculate Correct Width for Japanese Text

```javascript
width = charCount * 35 + 10; // 30-40px per char + margin
```

#### 6. Verify fontFamily in All Text Elements

```bash
grep -c 'fontFamily=' diagram.drawio.xml
# Should match text element count
```

### ❌ DON'T

#### 1. Don't Rely on defaultFontFamily Alone

```xml
<!-- ❌ BAD -->
<mxGraphModel defaultFontFamily="Helvetica">
  <mxCell value="Text" style="text;html=1;fontSize=18;" .../>
</mxGraphModel>
```

#### 2. Don't Use fontSize=12 (Too Small)

```xml
<!-- ❌ BAD -->
style="fontSize=12;fontFamily=Helvetica;"
```

#### 3. Don't Forget fontFamily in Any Text Element

```xml
<!-- ❌ BAD -->
<mxCell value="Label" style="text;html=1;fontSize=18;" .../>
```

#### 4. Don't Use Platform-Specific Fonts Without Fallback

```xml
<!-- ❌ BAD (macOS only) -->
style="fontFamily=Hiragino Sans;"

<!-- ✅ GOOD (with fallback) -->
style="fontFamily=Hiragino Sans,Arial,sans-serif;"
```

#### 5. Don't Underestimate Japanese Text Width

```xml
<!-- ❌ BAD (width=100 for 7 chars) -->
<mxCell value="テストユーザー" ...>
  <mxGeometry ... width="100" .../>
</mxCell>

<!-- ✅ GOOD (width=255 for 7 chars) -->
<mxCell value="テストユーザー" ...>
  <mxGeometry ... width="255" .../>
</mxCell>
```

## Summary

### Critical Checklist

- [ ] `<mxGraphModel defaultFontFamily="Helvetica">` を設定
- [ ] **全**テキスト要素に `fontFamily=Helvetica` を指定
- [ ] `fontSize=18` を使用 (1.5倍)
- [ ] 日本語テキストに十分な width (30-40px/char)
- [ ] PNG エクスポート後、フォントを確認

### Quick Reference

#### Minimum Style for Text

```xml
style="text;html=1;fontSize=18;fontFamily=Helvetica;"
```

#### With Alignment

```xml
style="text;html=1;fontSize=18;fontFamily=Helvetica;align=center;verticalAlign=middle;"
```

#### With Bold

```xml
style="text;html=1;fontSize=18;fontFamily=Helvetica;fontStyle=1;"
```

### Recommended Font

#### Primary: Helvetica

- クロスプラットフォーム対応
- 安定性が高い
- 日本語・英語両方に対応

#### Alternative: Hiragino Sans (macOS), Meiryo (Windows)

- より美しい日本語
- フォールバックチェーン必須

### Key Takeaway

> **PNG/SVG エクスポート時に正しいフォントでレンダリングするには、全テキスト要素に明示的な `fontFamily` 指定が必須です。**

このルールを守ることで、アプリ内プレビューとエクスポート後の見た目が一致し、一貫性のある高品質なダイアグラムを作成できます。
