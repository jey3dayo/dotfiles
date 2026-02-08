---
name: drawio
description: Create professional draw.io diagrams (AWS architecture, flowcharts, sequence diagrams, ER diagrams) with proper XML structure, font configuration, and layout best practices. Trigger when users mention "draw.io", "diagram creation", "architecture diagram", work with .drawio or .drawio.xml files, or request technical diagrams for documentation purposes.
---

# Draw.io Diagram Creation

Create professional technical diagrams in draw.io format (.drawio.xml) with automatic application of font settings and layout best practices.

## When to Use

Trigger this skill when:

- User mentions keywords: "draw.io", "drawio", "diagram", "architecture diagram", "アーキテクチャ図"
- User requests specific diagram types: "flowchart", "sequence diagram", "ER diagram", "AWS diagram"
- User works with `.drawio` or `.drawio.xml` files
- User needs visual documentation: "create a diagram", "diagram作成"
- AWS context: AWS service names (ECS, RDS, Lambda) + "diagram" or "architecture"

## Core Capabilities

### 1. AWS Architecture Diagrams

Generate AWS infrastructure diagrams with official icons and proper layout.

**Use when:** Infrastructure documentation, system design reviews, architecture proposals needed.

**Outputs:** VPC, subnets, ALB, ECS, RDS, Lambda, CloudWatch with proper connections and labeling.

### 2. Flowcharts

Generate process flowcharts with standard shapes and proper routing.

**Use when:** Business process documentation, workflow visualization, logic flow explanation needed.

**Outputs:** Process boxes, decision diamonds, terminators, connectors with clean routing.

### 3. Sequence Diagrams

Generate interaction flow diagrams showing component communication.

**Use when:** API documentation, system interaction design, integration flow explanation needed.

**Outputs:** Participants, sync/async messages, lifelines, activation boxes.

### 4. ER Diagrams

Generate entity-relationship diagrams for data modeling.

**Use when:** Database design documentation, data model explanation, table relationship visualization needed.

**Outputs:** Entity boxes with attributes, relationships (1:1, 1:N, N:M), cardinality notation.

## How to Use This Skill

### Workflow

#### Step 1: Identify Diagram Type

- Determine type from user request: AWS/Flowchart/Sequence/ER
- Understand target system/process/data model

#### Step 2: Load Template

- Select appropriate template from `resources/assets/templates/`
- Available: `aws-basic.drawio.xml`, `flowchart-basic.drawio.xml`, `sequence-basic.drawio.xml`, `er-basic.drawio.xml`

#### Step 3: Load References (Progressive Disclosure)

- **Always load:** `references/xml-structure.md` for XML format basics
- **For font issues:** `references/font-config.md` for font troubleshooting
- **For AWS diagrams:** Load AWS-specific patterns if needed
- **For other types:** Load diagram-specific patterns if needed
- **For complex layouts:** Load layout rules if needed

#### Step 4: Generate XML

- Start from template
- Add/customize elements based on user requirements
- Apply font configuration to ALL text elements
- Set `defaultFontFamily="Helvetica"` in mxGraphModel
- Ensure `fontFamily=Helvetica` in every text element's style

#### Step 5: Apply Layout Rules

- Place arrows first (background layer)
- Apply spacing rules: ≥20px between arrows and labels
- Calculate width for Japanese text: chars × 35px + 10px
- Align to 10px grid

#### Step 6: Validate

- Verify XML structure
- Confirm all text elements have `fontFamily`
- Check layer ordering (arrows → labels → shapes)

#### Step 7: Output

- Provide complete XML
- Include usage instructions
- Provide validation checklist

### Critical Requirements

#### Font Configuration (CRITICAL)

```xml
<!-- Model level (backup) -->
<mxGraphModel ... defaultFontFamily="Helvetica">

<!-- Element level (REQUIRED for PNG/SVG export) -->
<mxCell value="Text" style="...; fontFamily=Helvetica; fontSize=18; ..." />
```

**IMPORTANT:** PNG/SVG export requires explicit `fontFamily` in EVERY text element. `defaultFontFamily` alone is insufficient.

#### Layout Requirements

- Arrows first in XML (background layer)
- Minimum 20px spacing: arrows to labels
- Japanese text: 30-40px per character
- All coordinates: multiples of 10 (grid alignment)
- Background: transparent (no fillColor)
- Page: `page="0"` (infinite canvas)

#### Font Size

- Standard: 18px (1.5× for readability)
- Title: 24px
- Caption: 14px

### Output Format

Use this template for every diagram creation:

```markdown
## 🎨 Draw.io Diagram Created

**Diagram Type**: [AWS Architecture | Flowchart | Sequence | ER Diagram]
**Output File**: [filename.drawio.xml]
**Font Configuration**: Helvetica, 18px
**Elements**: [N] shapes, [M] connectors

### Key Features

- [Feature 1]
- [Feature 2]
- [Feature 3]

### Usage Instructions

1. Save XML content to `[filename].drawio.xml`
2. Open with draw.io desktop app or https://app.diagrams.net/
3. Verify rendering
4. Export to PNG/SVG: File > Export as > PNG (scale: 2.0)

### Validation Checklist

- [ ] All text elements have fontFamily specified
- [ ] Arrow labels have 20px+ spacing
- [ ] Japanese text width: 30-40px per character
- [ ] Background is transparent
- [ ] page="0" is set
```

## Bundled Resources

### Templates (`assets/templates/`)

Ready-to-use diagram templates with all best practices applied:

- `aws-basic.drawio.xml` - VPC, ALB, ECS, RDS, CloudWatch
- `flowchart-basic.drawio.xml` - Start/End, Process, Decision, Connectors
- `sequence-basic.drawio.xml` - 3 participants, sync/async messages
- `er-basic.drawio.xml` - 3 entities with attributes, 1:N relationships

All templates include:

- ✅ `defaultFontFamily="Helvetica"`
- ✅ `fontFamily` in all text elements
- ✅ `fontSize="18"`
- ✅ Arrows in background layer
- ✅ Proper spacing (≥20px)
- ✅ Transparent background
- ✅ `page="0"`

### References (`references/`)

Load these as needed using progressive disclosure:

**`xml-structure.md`** (ALWAYS LOAD FIRST)

- Draw.io XML format fundamentals
- mxGraphModel and mxCell structure
- Style syntax reference
- Common shapes and styles
- Before/After examples (10 examples)
- **Load when:** Creating any diagram (foundation knowledge)

#### `font-config.md`

- Font hierarchy (model-level vs element-level)
- PNG/SVG export font issues
- Multi-language support
- Troubleshooting guide (5 common issues)
- **Load when:** Font rendering problems, custom fonts needed

## Best Practices

### ✅ DO

1. **Always specify fontFamily at element level**

   ```xml
   <mxCell ... style="...; fontFamily=Helvetica; ..." />
   ```

2. **Use 18px font size** (1.5× standard for readability)

   ```xml
   style="fontSize=18;fontFamily=Helvetica;"
   ```

3. **Set defaultFontFamily as backup**

   ```xml
   <mxGraphModel ... defaultFontFamily="Helvetica">
   ```

4. **Place arrows first** (background layer)
   - Arrows → Labels → Shapes in XML order

5. **Calculate width for Japanese text**

   ```
   width = charCount × 35 + 10
   ```

6. **Maintain minimum spacing**
   - Arrows to labels: ≥20px

7. **Align to grid**
   - All x, y, width, height: multiples of 10

8. **Use transparent background**
   - No fillColor specification

9. **Set page="0"**
   - Infinite canvas, export only needed area

### ❌ DON'T

1. **Don't rely on defaultFontFamily alone**
   - PNG/SVG export ignores it
   - Must specify at element level

2. **Don't use fontSize=12**
   - Too small, use 18px

3. **Don't forget fontFamily in any text element**
   - Every single text element needs it

4. **Don't place shapes before arrows**
   - Arrows render on top (wrong)

5. **Don't use insufficient width for Japanese**
   - 30-40px per character required

6. **Don't use fillColor**
   - Keep background transparent

## Common Issues & Solutions

### Issue: Font changes after PNG export

**Cause:** Missing element-level `fontFamily`

#### Solution

```bash
# Find elements without fontFamily
grep -E 'value="[^"]*"' diagram.drawio.xml | grep -v 'fontFamily='
```

Add `fontFamily=Helvetica` to each.

### Issue: Arrows appear in front of shapes

**Cause:** Wrong XML order

**Solution:** Move arrow cells to beginning of root element (before shapes).

### Issue: Japanese text wraps unexpectedly

**Cause:** Insufficient width

#### Solution

```
width = charCount × 35 + 10
```

### Issue: Elements not aligned to grid

**Cause:** Coordinates not multiples of 10

#### Solution

```javascript
x = Math.round(x / 10) * 10;
y = Math.round(y / 10) * 10;
```

## Integration with ASTA Project

### Document Location

- Save diagrams: `docs/diagrams/`
- Filename format: `{feature}-{type}.drawio.xml`
- Example: `asta-ecs-architecture.drawio.xml`

### Version Control

- Commit both `.drawio.xml` (source) and `.png` (export)
- Update diagrams when architecture changes
- Link updates to related PRs/issues

### Metadata

- Follow `.claude/rules/documentation-rules.md`
- Add 最終更新, 対象, タグ in accompanying .md
- Tags: `category/documentation`, `category/architecture`, `tech/aws`

## Examples

### Example 1: AWS Architecture Request

```
User: "Create an AWS architecture diagram for ECS deployment with ALB and RDS"

Action:
1. Load xml-structure.md (foundation)
2. Select aws-basic.drawio.xml template
3. Customize: ALB → ECS → RDS flow
4. Apply all font/layout rules
5. Output complete XML with usage instructions
```

### Example 2: Flowchart Request

```
User: "フローチャートを作成して、予約承認プロセス用"

Action:
1. Load xml-structure.md
2. Select flowchart-basic.drawio.xml template
3. Add: Start → Request → Decision → Notification → End
4. Apply Japanese text width (35px/char)
5. Output complete XML with usage instructions
```

## Quick Reference

### Minimum Text Style

```xml
style="text;html=1;fontSize=18;fontFamily=Helvetica;"
```

### Minimum Cell

```xml
<mxCell id="cell1" value="Text"
        style="rounded=1;html=1;fontSize=18;fontFamily=Helvetica;"
        parent="1" vertex="1">
  <mxGeometry x="100" y="100" width="120" height="60" as="geometry"/>
</mxCell>
```

### Minimum Template

```xml
<mxfile host="app.diagrams.net">
  <diagram name="Page-1" id="id1">
    <mxGraphModel page="0" defaultFontFamily="Helvetica">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
        <!-- Arrows first, then shapes -->
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

## Summary

This skill creates professional draw.io diagrams by:

1. **Loading appropriate template** from `assets/templates/`
2. **Applying font configuration** (element-level fontFamily)
3. **Following layout rules** (layer order, spacing, grid)
4. **Outputting complete XML** with usage instructions

**Key Success Factor:** Explicit `fontFamily` in every text element ensures consistent rendering across app preview and PNG/SVG export.

Load `references/xml-structure.md` first for every diagram, then load other references as needed based on diagram type and complexity.
