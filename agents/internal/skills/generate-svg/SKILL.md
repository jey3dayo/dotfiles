---
name: generate-svg
description: SVG diagram generation skill. Supports transparent background, dark mode compatibility, accessibility compliance, Material Icons integration, and 6 design patterns.
allowed-tools: Read, Write, Bash
---

# Generate SVG Skill

Generates SVG diagrams for technical blog articles and logos. Supports transparent background, dark mode compatibility, accessibility compliance, Material Icons integration, and 6 design patterns.

## When to Use

Use this skill in the following cases:

- When the user requests "create an SVG", "make a diagram", "generate a diagram", etc.
- When architecture diagrams, flow diagrams, relationship diagrams, or comparison diagrams are needed
- When SVG files are needed for logos or icons
- When SVGs with transparent background and dark mode support are needed
- When you want to insert diagrams into articles for SEO improvement

## Supported Diagram Patterns

### 1. Architecture Diagrams

- Layered Architecture: Representation of horizontal layers
- Microservices: Visualization of inter-service communication
- Event-Driven: Representation of event flows

### 2. Flow Diagrams

- Process Flow: Step-by-step processing
- Data Flow: Data transformation and movement
- User Flow: User interactions

### 3. Relationship Diagrams

- Entity Relationship Diagrams: Data models
- Class Diagrams: Object relationships
- Sequence Diagrams: Time-series interactions

### 4. Comparison Diagrams

- Before/After: Contrast of before and after improvements
- Option Comparison: Side-by-side display of multiple choices
- Performance Comparison: Visualization of metrics

### 5. Component Diagrams

- System Configuration: Dependencies between components
- Deployment Diagrams: Physical placement

### 6. Conceptual Diagrams

- Concept Maps: Relationships between concepts
- Tree Structures: Hierarchical information

## Design Specifications

### Size and Format

- Recommended size: 1280 x 720 px (16:9)
- viewBox: `0 0 1280 720`
- Format: SVG 1.1
- Save location: `docs/article/[feature-name]/images/`

### Save Location Examples

- `docs/article/tmp-driven-development/images/architecture-diagram.svg`
- `docs/article/uv-workspace/images/flow-diagram.svg`

### Accessibility Requirements

- Contrast ratio: WCAG Level AA compliant (4.5:1 or higher)
- Alternative text: Include `<title>` and `<desc>` elements
- Avoid color dependency: Combine color + shape + pattern
- Text size: Minimum 14px or larger

### Design Guidelines

- Simplicity first: Do not overcrowd
- Appropriate whitespace: Sufficient space between elements
- Letter spacing: Maintain readable spacing
- Gradients: Use sparingly
- Color count limit: Avoid excessive color information (3-5 colors recommended)

### Transparent Background and Dark Mode Support

### Goals

- ✅ White background is fully transparent
- ✅ Displays naturally in iOS/Android dark mode
- ✅ Logo looks great on any background color

### Implementation Principles

1. Do not include background elements
   - Do not include background elements such as `<rect fill="white">` or `<rect fill="#FFFFFF">` in the SVG
   - The background should be transparent (draw nothing)

2. viewBox optimization
   - Set viewBox to match the actual drawing area
   - Minimize whitespace to reduce transparent areas during PNG conversion

3. Color palette considerations
   - Choose colors with high visibility in both light and dark modes
   - Avoid pure white (#FFFFFF) and pure black (#000000)
   - Recommended mid-tones: #212121 (dark gray), #E0E0E0 (light gray)

4. Settings for PNG conversion
   - When using `sharp` library: `background: { r: 0, g: 0, b: 0, alpha: 0 }`
   - Output as transparent PNG (RGBA) format

### Material Icons Usage

- Icon source: <https://fonts.google.com/icons>
- Format: SVG embedded
- Size: 24px, 32px, 48px (depending on use case)
- Style: Choose from Outlined, Filled, Rounded

## Usage Flow

### 1. Confirm the User's Request

Check whether the user has provided the following information:

- Type of diagram (architecture, flow, relationship, comparison, etc.)
- Elements to include (components, steps, relationships, etc.)
- Special notes (color preferences, parts to emphasize, etc.)

### 2. Clarify Missing Information

Ask the following as needed:

- Title of the diagram
- Main elements and their relationships
- Points to emphasize
- Color preferences (if any)

### 3. SVG Generation

Generate an SVG that meets the following requirements:

#### Basic Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg"
     viewBox="0 0 1280 720"
     width="1280"
     height="720"
     role="img"
     aria-labelledby="diagram-title diagram-desc">

  <title id="diagram-title">[Diagram title]</title>
  <desc id="diagram-desc">[Diagram description]</desc>

  <defs>
    <!-- Define reusable elements -->
  </defs>

  <!-- Diagram content -->

</svg>
```

#### Recommended Color Palette

Color scheme example considering accessibility:

```
Primary:   #2196F3 (blue)
Secondary: #4CAF50 (green)
Accent:    #FF9800 (orange)
Text:      #212121 (dark gray)
BG:        #FFFFFF (white)
Border:    #BDBDBD (gray)
```

### 4. Confirm Save Location

Ask the user for the article directory:

```
Which article is this diagram for?
Example: tmp-driven-development, uv-workspace, etc.
```

### 5. Save File

Save to the `images/` folder in the confirmed article directory:

```
docs/article/[feature-name]/images/[descriptive-filename].svg
```

### Save Path Examples

- `docs/article/tmp-driven-development/images/architecture-diagram.svg`
- `docs/article/uv-workspace/images/workflow-flow.svg`
- `docs/article/html-to-markdown-converter/images/before-after-comparison.svg`

### File Naming Conventions

- Use lowercase letters and hyphens
- Name that makes the diagram content clear
- May include pattern (e.g., `flow-user-auth.svg`, `arch-layered.svg`)

### 6. Report to User

Report the following information to the user:

- Type of diagram generated
- Save path
- Main elements included
- Accessibility compliance status
- Next steps (suggestion for PNG conversion)

## Response to User

### On Success

````
SVG diagram has been generated.

[Diagram Information]
- Type: [pattern name]
- Title: [title]
- Size: 1280 x 720 px (16:9)
- Save location: docs/article/[feature-name]/images/[filename].svg

[Accessibility]
- Contrast ratio: WCAG Level AA compliant
- Alternative text: Included
- Material Icons: [count] used

[Next Steps]
To convert to PNG format, use the svg-to-png Skill or run the following command:
```bash
uv run --package sios-tech-lab-analytics-ga4-tools svg2png docs/article/[feature-name]/images/[filename].svg
````

```

### When Clarification is Needed

```

Additional details needed for the diagram.

Please provide the following information:

- [Question 1]
- [Question 2]
- [Question 3]

```````

## Important Notes

1. **viewBox setting**: Always set `viewBox="0 0 1280 720"`
2. **Transparent background required**: Do not include background elements (such as `<rect fill="white">`)
3. **Accessibility**: `<title>` and `<desc>` are required
4. **Material Icons**: Embed as SVG paths (avoid font references)
5. **Contrast**: Maintain a contrast ratio of 4.5:1 or higher between text and background
6. **Simplicity**: Do not overcrowd information; ensure appropriate whitespace
7. **Reusability**: Use `<defs>` to define reusable elements
8. **Dark mode support**: Avoid pure white/black; use mid-tones

## Design Pattern Examples

### Architecture Diagram Example

``````xml
<!-- Layered Architecture (transparent background, dark mode compatible) -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1280 720">
  <title>Layered Architecture</title>
  <desc>Configuration diagram of 3-tier architecture</desc>

  <!-- No background element (transparent) -->

  <!-- Presentation Layer -->
  <rect x="200" y="100" width="880" height="120"
        fill="#E3F2FD" stroke="#2196F3" stroke-width="2"/>
  <text x="640" y="170" text-anchor="middle"
        font-size="24" fill="#212121">Presentation Layer</text>

  <!-- Business Logic Layer -->
  <rect x="200" y="260" width="880" height="120"
        fill="#E8F5E9" stroke="#4CAF50" stroke-width="2"/>
  <text x="640" y="330" text-anchor="middle"
        font-size="24" fill="#212121">Business Logic Layer</text>

  <!-- Data Access Layer -->
  <rect x="200" y="420" width="880" height="120"
        fill="#FFF3E0" stroke="#FF9800" stroke-width="2"/>
  <text x="640" y="490" text-anchor="middle"
        font-size="24" fill="#212121">Data Access Layer</text>

  <!-- Arrows -->
  <path d="M 640 220 L 640 260"
        stroke="#212121" stroke-width="2"
        marker-end="url(#arrowhead)"/>
  <path d="M 640 380 L 640 420"
        stroke="#212121" stroke-width="2"
        marker-end="url(#arrowhead)"/>

  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="10"
            refX="5" refY="5" orient="auto">
      <polygon points="0 0, 10 5, 0 10" fill="#212121"/>
    </marker>
  </defs>
</svg>
```````

### Flow Diagram Example

```xml
<!-- Simple process flow -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1280 720">
  <title>User Authentication Flow</title>
  <desc>Flow from login to session establishment</desc>

  <!-- Start -->
  <ellipse cx="200" cy="100" rx="80" ry="40"
           fill="#4CAF50" stroke="#2E7D32" stroke-width="2"/>
  <text x="200" y="110" text-anchor="middle"
        font-size="18" fill="#FFFFFF">Start</text>

  <!-- Process 1 -->
  <rect x="120" y="180" width="160" height="60" rx="5"
        fill="#2196F3" stroke="#1976D2" stroke-width="2"/>
  <text x="200" y="215" text-anchor="middle"
        font-size="16" fill="#FFFFFF">Enter credentials</text>

  <!-- Process 2 -->
  <rect x="120" y="280" width="160" height="60" rx="5"
        fill="#2196F3" stroke="#1976D2" stroke-width="2"/>
  <text x="200" y="315" text-anchor="middle"
        font-size="16" fill="#FFFFFF">Validation</text>

  <!-- End -->
  <ellipse cx="200" cy="400" rx="80" ry="40"
           fill="#F44336" stroke="#C62828" stroke-width="2"/>
  <text x="200" y="410" text-anchor="middle"
        font-size="18" fill="#FFFFFF">Complete</text>

  <!-- Arrows -->
  <path d="M 200 140 L 200 180" stroke="#212121" stroke-width="2"
        marker-end="url(#arrowhead)"/>
  <path d="M 200 240 L 200 280" stroke="#212121" stroke-width="2"
        marker-end="url(#arrowhead)"/>
  <path d="M 200 340 L 200 360" stroke="#212121" stroke-width="2"
        marker-end="url(#arrowhead)"/>

  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="10"
            refX="5" refY="5" orient="auto">
      <polygon points="0 0, 10 5, 0 10" fill="#212121"/>
    </marker>
  </defs>
</svg>
```

## Material Icons Integration

When using Material Icons, embed them as SVG paths.

### How to Obtain Icons

1. Go to <https://fonts.google.com/icons>
2. Select the icon you want to use
3. Copy the `<path>` element from the "SVG" tab
4. Embed it in the diagram's SVG

### Embedding Example

```xml
<!-- Example of Database icon -->
<g transform="translate(100, 100)">
  <path d="M12,3C7.58,3 4,4.79 4,7C4,9.21 7.58,11 12,11C16.42,11 20,9.21 20,7C20,4.79 16.42,3 12,3M4,9V12C4,14.21 7.58,16 12,16C16.42,16 20,14.21 20,12V9C20,11.21 16.42,13 12,13C7.58,13 4,11.21 4,9M4,14V17C4,19.21 7.58,21 12,21C16.42,21 20,19.21 20,17V14C20,16.21 16.42,18 12,18C7.58,18 4,16.21 4,14Z"
        fill="#2196F3"/>
</g>
```

## Related Tools

- sharp (Node.js): Convert SVG to PNG format
  - Transparent background setting: `background: { r: 0, g: 0, b: 0, alpha: 0 }`
  - Resize: `resize(width, height, { fit: 'contain' })`

## Related Documentation

Refer to the following for detailed design information:

- `docs/research/blog-diagram-design-patterns.md`: Design pattern research
- Material Icons: <https://fonts.google.com/icons>
- WCAG Guidelines: <https://www.w3.org/WAI/WCAG21/quickref/>
