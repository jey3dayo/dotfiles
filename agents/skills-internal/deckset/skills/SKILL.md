---
name: deckset
description: Use this skill when working with Deckset presentations. Provides Deckset-specific syntax guidance, image modifiers, metadata settings, and best practices for creating professional Markdown-based presentations. Trigger when users mention "Deckset", request help with Deckset syntax, need to create Deckset presentations, or want to check/fix Deckset-specific formatting issues.
---

# Deckset

## Overview

This skill provides comprehensive guidance for creating and reviewing Deckset presentations. Deckset transforms Markdown into professional presentations, and this skill ensures proper use of Deckset-specific syntax, image modifiers, metadata configuration, and presentation best practices.

## Core Capabilities

### 1. Deckset Syntax Guidance

Provide proper Deckset syntax for creating presentations:

#### Slide Separators

- Place `---` on its own line with blank lines before and after
- Ensure no extra whitespace or characters around the separator
- Verify consistent slide separation throughout the document

#### Header Hierarchy

- Use `#` through `####` for appropriate heading levels
- Apply the `[fit]` modifier correctly: `# [fit] Large Text`
- Note: `[fit]` must come after the `#` symbol, not before

#### Metadata Configuration

**Critical**: All metadata must be placed at the very beginning of the file:

```markdown
footer: Your Footer Text
slidenumbers: true
theme: Next, 1
```

- No blank lines between metadata lines
- Metadata must precede all slide content
- Common metadata fields: `footer:`, `slidenumbers:`, `theme:`

### 2. Image Processing and Placement

Guide users on Deckset's powerful image modifier system:

#### Single Image Modifiers

- `![fit]()` - Scale image to fit the slide
- `![x%]()` - Scale to specific percentage (e.g., `![50%](image.png)`)
- `![left]()` / `![right]()` - Position image on left or right
- `![inline]()` - Display image inline with text
- `![filtered]()` / `![original]()` - Control image filtering

#### Multiple Image Layout

- Same-line `![inline]` images for horizontal arrangement
- Combine `![left]` and `![right]` for split layout
- Use `![inline, fill]` for grid layouts

#### Background Images

- Single `![](image.png)` without modifiers creates full-screen background
- Consider text readability when combining backgrounds with content

### 3. Code Display

Optimize code presentation in Deckset:

- Specify language for syntax highlighting: ` ```javascript `
- Keep code blocks to reasonable size (fitting one slide)
- Use indentation for monospace display without syntax highlighting
- Highlight important code sections through surrounding content

### 4. Special Features

#### Speaker Notes

- Use `^` prefix for speaker notes
- Provide comprehensive notes to support presentation delivery
- Include timing hints, transitions, or audience interaction cues

#### Quotations

- Use `>` for quotation markup
- Add `--` for attribution
- Consider dedicated quote slides for emphasis

#### [fit] Text

- Apply only to headers (`# [fit]`, `## [fit]`)
- Position after the `#` symbol: `# [fit] Text`, not `[fit] # Text`
- Use for impactful, large-format text

### 5. Video and Media

Embed video content effectively:

- Use `![autoplay](video.mp4)` for automatic playback
- Ensure local file paths are accurate and relative
- Support for YouTube URLs
- Prefer MP4 format for compatibility

## Syntax Validation

When reviewing Deckset files, check for these common errors:

### Metadata Errors

- ❌ Metadata placed in the middle of the file
- ❌ Blank lines between metadata fields
- ✅ All metadata at file start, no blank lines between

### Slide Separator Issues

- ❌ `---` without surrounding blank lines
- ❌ Extra characters on the separator line
- ✅ Clean `---` with blank lines before and after

### Image Modifier Mistakes

- ❌ Incorrect spelling: `[fitted]`, `[center]`
- ❌ Wrong syntax position: `[fit] #` instead of `# [fit]`
- ✅ Correct modifiers in proper positions

### Layout Problems

- ❌ Incorrect file paths for images
- ❌ Line breaks between `![inline]` images
- ✅ Proper path references and image arrangement

## Best Practices

### File Organization

- Place metadata at file beginning
- Use high-resolution images
- Use lowercase for modifiers
- Leverage speaker notes extensively

### Performance Optimization

- Pre-resize images to appropriate dimensions
- Use MP4 format for videos
- Avoid excessive animations

### Maintainability

- Use relative paths for images
- Create reusable slide structures
- Consider version control diff-friendliness

## Theme and Export Considerations

### Theme Compatibility

- Test with selected theme before presenting
- Verify custom CSS effects
- Check filter effects on images

### Export Settings

- Review PDF output layout
- Verify link clickability in exported formats
- Ensure image resolution is suitable for export format

## Example Workflows

### Creating a New Deckset Presentation

1. Start with metadata at the top of the file
2. Use `---` to separate slides
3. Apply appropriate image modifiers for visual impact
4. Add speaker notes with `^` prefix
5. Test with desired theme
6. Review on actual presentation device

### Fixing Common Deckset Errors

1. Move any metadata to file beginning
2. Check all `---` separators have blank lines
3. Verify image modifier spelling and syntax
4. Ensure `[fit]` is positioned correctly
5. Test image paths are accurate

## Resources

### references/

Contains links to the comprehensive Deckset manual for advanced features and detailed documentation.

#### Related documentation

- Deckset manual: `~/.claude/docs/deckset-manual.md`
