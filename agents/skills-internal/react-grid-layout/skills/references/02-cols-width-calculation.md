# Cols and Width Calculation Patterns

This document provides comprehensive guidance on calculating `cols` and `width` for react-grid-layout. Understanding these calculations is crucial for proper grid rendering.

## Table of Contents

1. [Fundamental Concepts](#fundamental-concepts)
2. [The Two Required Props](#the-two-required-props)
3. [Calculation Approaches](#calculation-approaches)
4. [ASTA Dynamic Calculation Pattern](#asta-dynamic-calculation-pattern)
5. [Common Mistakes and Solutions](#common-mistakes-and-solutions)
6. [Debugging Techniques](#debugging-techniques)
7. [Performance Considerations](#performance-considerations)

## Fundamental Concepts

### Grid Units vs Pixels

react-grid-layout uses a **grid unit system** for layout calculations:

- **Grid Units**: Abstract units for positioning (x, y, w, h in Layout items)
- **Pixels**: Actual screen dimensions (width, rowHeight in ReactGridLayout props)

### Conversion Formula:

```
Pixel Width = (Grid Units × Row Height) + (Margins × (Grid Units - 1))
```

### Why Both cols and width?

```typescript
<ReactGridLayout
  cols={12}          // Number of columns in the grid
  width={1200}       // Total width in pixels
  rowHeight={30}     // Height per row in pixels
  {...props}
>
```

- **cols**: Defines the grid's column structure (logical)
- **width**: Defines the container's pixel width (physical)
- **rowHeight**: Converts grid units to pixels

## The Two Required Props

### 1. cols (Number of Columns)

```typescript
cols: number; // default: 12
```

### Purpose:

- Defines the maximum number of columns in the grid
- All layout items must have `x + w ≤ cols`

### Common Values:

- **12**: Standard (Bootstrap-style) - highly divisible (1, 2, 3, 4, 6, 12)
- **24**: Fine-grained control
- **Dynamic**: Calculated from actual layout content (ASTA pattern)

### 2. width (Container Width in Pixels)

```typescript
width: number; // Required for drag calculations
```

### Purpose:

- Required for react-grid-layout to calculate pixel positions during dragging
- Determines the actual rendered width of the grid

### Two Approaches:

1. **Manual**: Calculate and provide width explicitly
2. **Automatic**: Use `WidthProvider` HOC (not suitable for SSR)

## Calculation Approaches

### Approach 1: Fixed Values (Simplest)

### When to use:

- Simple, non-responsive layouts
- Known container dimensions
- SSR-compatible

```typescript
const COLS = 12;
const CONTAINER_WIDTH = 1200;  // pixels
const ROW_HEIGHT = 30;

<ReactGridLayout
  cols={COLS}
  width={CONTAINER_WIDTH}
  rowHeight={ROW_HEIGHT}
  layout={layout}
>
  {children}
</ReactGridLayout>
```

### Pros:

- Simple and predictable
- Works with SSR
- Easy to reason about

### Cons:

- Not responsive
- May not fit content optimally

### Approach 2: WidthProvider (Responsive)

### When to use:

- Responsive layouts
- Container width varies
- Client-side rendering only

```typescript
import { WidthProvider } from 'react-grid-layout';

const GridLayoutWithWidth = WidthProvider(ReactGridLayout);

<GridLayoutWithWidth
  cols={12}
  rowHeight={30}
  layout={layout}
>
  {children}
</GridLayoutWithWidth>
```

### Pros:

- Automatically responsive
- No manual width calculation

### Cons:

- Not SSR-compatible (width is undefined on server)
- Less control over exact dimensions

### Approach 3: Dynamic Calculation (ASTA Pattern)

### When to use:

- Content-driven grid sizing
- Variable number of columns based on data
- Calendar/schedule layouts
- Need precise control with SSR support

```typescript
// Calculate cols from layout
const pointsX = layout.map(({ x, w }) => x + w);
const cols = pointsX.length > 0
  ? Math.max(...pointsX)
  : 12;  // fallback

// Calculate width from cols
const gridWidth = cols * rowHeight;

<ReactGridLayout
  cols={cols}
  width={gridWidth}
  rowHeight={rowHeight}
  layout={layout}
>
  {children}
</ReactGridLayout>
```

### Pros:

- Adapts to actual content
- SSR-compatible
- Optimal space usage

### Cons:

- More complex logic
- Requires careful layout generation

## ASTA Dynamic Calculation Pattern

### Complete Implementation

```typescript
import React from 'react';
import ReactGridLayout, { Layout } from 'react-grid-layout';
import 'react-grid-layout/css/styles.css';
import 'react-resizable/css/styles.css';

const CALENDAR_ROW_HEIGHT = 24;  // pixels
const CALENDAR_CELL_MARGIN: [number, number] = [2, 2];

function DynamicGridLayout({ layout: inputLayout }: { layout: Layout[] }) {
  // Memoize layout calculation
  const layout = React.useMemo(() => {
    return inputLayout.filter(item => item !== null && item !== undefined);
  }, [inputLayout]);

  // Step 1: Calculate required columns from layout
  // Find the rightmost edge of all items (x + w)
  const pointsX = layout.map(({ x, w }) => x + w);

  // Step 2: Determine cols as the maximum value
  // Fallback to 150 if no items (prevents zero-width grid)
  const cols = pointsX.length > 0
    ? Math.max(...pointsX)
    : 150;

  console.log('[Grid Calculation]', {
    itemCount: layout.length,
    pointsX,
    calculatedCols: cols,
  });

  // Step 3: Calculate pixel width
  // Each column takes rowHeight pixels
  const gridWidth = cols * CALENDAR_ROW_HEIGHT;

  console.log('[Grid Dimensions]', {
    cols,
    gridWidth,
    rowHeight: CALENDAR_ROW_HEIGHT,
  });

  // Step 4: Render grid with calculated values
  return (
    <ReactGridLayout
      className="layout"
      layout={layout}
      cols={cols}
      rowHeight={CALENDAR_ROW_HEIGHT}
      width={gridWidth}
      margin={CALENDAR_CELL_MARGIN}
      compactType={null}
      preventCollision={true}
      isDraggable={false}
      isResizable={false}
      useCSSTransforms={true}
    >
      {layout.map(item => (
        <div key={item.i} className="grid-item">
          {item.i}
        </div>
      ))}
    </ReactGridLayout>
  );
}
```

### Step-by-Step Breakdown

#### Step 1: Calculate Required Columns

```typescript
const pointsX = layout.map(({ x, w }) => x + w);
```

### What this does:

- For each layout item, calculate its rightmost edge: `x + w`
- Example: `{ x: 2, w: 3 }` → right edge is at column 5

### Example:

```typescript
const layout = [
  { i: "a", x: 0, w: 4 }, // right edge: 0 + 4 = 4
  { i: "b", x: 4, w: 6 }, // right edge: 4 + 6 = 10
  { i: "c", x: 10, w: 2 }, // right edge: 10 + 2 = 12
];

const pointsX = [4, 10, 12];
```

#### Step 2: Find Maximum Columns

```typescript
const cols = pointsX.length > 0 ? Math.max(...pointsX) : 150;
```

### What this does:

- Find the highest value in `pointsX` (rightmost item position)
- This becomes the minimum number of columns needed
- Fallback to 150 if empty (ASTA convention)

### Example:

```typescript
const pointsX = [4, 10, 12];
const cols = Math.max(...pointsX); // 12
```

### Why the fallback?

```typescript
// Prevents issues with empty grids
const emptyLayout = [];
const pointsX = []; // No items
const cols = 150; // Fallback ensures grid has width
```

#### Step 3: Calculate Pixel Width

```typescript
const gridWidth = cols * CALENDAR_ROW_HEIGHT;
```

### Simple proportional calculation:

- Each column occupies `rowHeight` pixels
- Total width = columns × pixels per column

### Example:

```typescript
const cols = 12;
const CALENDAR_ROW_HEIGHT = 24;
const gridWidth = 12 * 24; // 288 pixels
```

### Why This Pattern Works

1. **Content-Driven**: Grid size adapts to actual content
2. **SSR-Compatible**: All calculations happen with available data
3. **Predictable**: No external dependencies (window width, etc.)
4. **Efficient**: Uses React.useMemo for expensive layout calculations

### When to Use This Pattern

✅ **Use when:**

- Building calendar/schedule layouts
- Content determines grid structure
- Need SSR support
- Want precise control over dimensions

❌ **Don't use when:**

- Need responsive behavior based on container
- Grid structure is fixed (use Approach 1)
- Using WidthProvider is simpler (use Approach 2)

## Common Mistakes and Solutions

### Mistake 1: Hardcoding cols Without Checking Layout

```typescript
// ❌ Bad: Cols doesn't match actual content
const cols = 12;
const layout = [
  { i: "item", x: 0, y: 0, w: 20, h: 2 }, // w exceeds cols!
];
```

**Problem:** Item width (20) exceeds cols (12) → rendering issues

### Solution:

```typescript
// ✅ Good: Calculate cols from layout
const maxX = Math.max(...layout.map(({ x, w }) => x + w));
const cols = Math.max(maxX, 12); // at least 12, more if needed
```

### Mistake 2: Zero or Negative cols

```typescript
// ❌ Bad: Empty layout with no fallback
const layout = [];
const cols = Math.max(...layout.map(({ x, w }) => x + w)); // -Infinity!
```

**Problem:** `Math.max()` on empty array returns `-Infinity`

### Solution:

```typescript
// ✅ Good: Provide fallback
const cols =
  layout.length > 0 ? Math.max(...layout.map(({ x, w }) => x + w)) : 12; // sensible default
```

### Mistake 3: Forgetting to Filter Invalid Layout Items

```typescript
// ❌ Bad: Null/undefined items cause errors
const layout = [
  { i: "a", x: 0, y: 0, w: 4, h: 2 },
  null, // ← Problem!
  { i: "b", x: 4, y: 0, w: 4, h: 2 },
];

const cols = Math.max(...layout.map(({ x, w }) => x + w)); // TypeError!
```

### Solution:

```typescript
// ✅ Good: Filter out invalid items
const validLayout = layout.filter(
  (item) => item !== null && item !== undefined,
);
const cols = Math.max(...validLayout.map(({ x, w }) => x + w));
```

### Mistake 4: Miscalculating Width with Margins

```typescript
// ❌ Bad: Forgetting margins affect actual width
const gridWidth = cols * rowHeight; // Doesn't account for margins!
```

### For exact calculations including margins:

```typescript
// ✅ Better: Account for margins
const [marginX, marginY] = margin;
const gridWidth = cols * rowHeight + (cols - 1) * marginX;
```

### However, ASTA pattern uses simplified calculation:

```typescript
// ✅ ASTA: Simplified (margins are small, negligible impact)
const gridWidth = cols * CALENDAR_ROW_HEIGHT;
```

### Mistake 5: Not Using React.useMemo for Expensive Calculations

```typescript
// ❌ Bad: Recalculates on every render
function GridLayout({ data }) {
  const layout = generateLayoutFromData(data); // Expensive!
  const cols = Math.max(...layout.map(({ x, w }) => x + w));
  // ...
}
```

### Solution:

```typescript
// ✅ Good: Memoize expensive calculations
function GridLayout({ data }) {
  const layout = React.useMemo(() => generateLayoutFromData(data), [data]);

  const cols = React.useMemo(
    () => Math.max(...layout.map(({ x, w }) => x + w), 12),
    [layout],
  );
  // ...
}
```

## Debugging Techniques

### Technique 1: Add Console Logs

```typescript
const pointsX = layout.map(({ x, w }) => x + w);
const cols = Math.max(...pointsX, 12);
const gridWidth = cols * rowHeight;

console.log("[Grid Debug]", {
  itemCount: layout.length,
  layoutItems: layout.map(({ i, x, w }) => ({ i, x, w, rightEdge: x + w })),
  pointsX,
  calculatedCols: cols,
  gridWidth,
  rowHeight,
});
```

### Example Output:

```
[Grid Debug] {
  itemCount: 3,
  layoutItems: [
    { i: 'header', x: 0, w: 12, rightEdge: 12 },
    { i: 'content1', x: 0, w: 6, rightEdge: 6 },
    { i: 'content2', x: 6, w: 6, rightEdge: 12 }
  ],
  pointsX: [12, 6, 12],
  calculatedCols: 12,
  gridWidth: 288,
  rowHeight: 24
}
```

### Technique 2: Visualize Grid Boundaries

```css
/* Add to your CSS to see grid boundaries */
.react-grid-layout {
  border: 2px solid red;
}

.react-grid-item {
  border: 1px solid blue;
}
```

### Technique 3: Validate Layout Integrity

```typescript
function validateLayout(layout: Layout[], cols: number): boolean {
  const errors: string[] = [];

  layout.forEach((item) => {
    // Check if item exceeds grid
    if (item.x + item.w > cols) {
      errors.push(
        `Item "${item.i}" exceeds grid: x=${item.x} + w=${item.w} > cols=${cols}`,
      );
    }

    // Check for negative positions
    if (item.x < 0 || item.y < 0) {
      errors.push(
        `Item "${item.i}" has negative position: x=${item.x}, y=${item.y}`,
      );
    }

    // Check for zero dimensions
    if (item.w <= 0 || item.h <= 0) {
      errors.push(
        `Item "${item.i}" has invalid dimensions: w=${item.w}, h=${item.h}`,
      );
    }
  });

  if (errors.length > 0) {
    console.error("[Layout Validation Failed]", errors);
    return false;
  }

  return true;
}

// Usage
const isValid = validateLayout(layout, cols);
if (!isValid) {
  // Handle invalid layout
}
```

### Technique 4: Compare Calculation Methods

```typescript
// Method 1: ASTA pattern
const colsAsta = Math.max(...layout.map(({ x, w }) => x + w), 12);

// Method 2: Alternative
const colsAlt = layout.reduce(
  (max, item) => Math.max(max, item.x + item.w),
  12,
);

console.log("[Comparison]", {
  astaCols: colsAsta,
  alternativeCols: colsAlt,
  match: colsAsta === colsAlt,
});
```

## Performance Considerations

### Optimize with React.useMemo

```typescript
function OptimizedGridLayout({ events, rooms, times }) {
  // Memoize layout generation
  const layout = React.useMemo(
    () => generateLayout({ events, rooms, times }),
    [events, rooms, times]
  );

  // Memoize cols calculation
  const cols = React.useMemo(
    () => {
      const pointsX = layout.map(({ x, w }) => x + w);
      return Math.max(...pointsX, 150);
    },
    [layout]
  );

  // Memoize width calculation
  const gridWidth = React.useMemo(
    () => cols * CALENDAR_ROW_HEIGHT,
    [cols]
  );

  return (
    <ReactGridLayout
      cols={cols}
      width={gridWidth}
      layout={layout}
      {...otherProps}
    >
      {children}
    </ReactGridLayout>
  );
}
```

### Avoid Recalculation on Every Render

### ❌ Bad:

```typescript
function GridLayout({ data }) {
  // Recalculated on every render!
  const layout = data.map(createLayoutItem);
  const cols = Math.max(...layout.map(({ x, w }) => x + w));
  // ...
}
```

### ✅ Good:

```typescript
function GridLayout({ data }) {
  const layout = React.useMemo(() => data.map(createLayoutItem), [data]);

  const cols = React.useMemo(
    () => Math.max(...layout.map(({ x, w }) => x + w), 12),
    [layout],
  );
  // ...
}
```

## Summary Checklist

When implementing cols/width calculation:

- [ ] Choose appropriate calculation approach (fixed, WidthProvider, or dynamic)
- [ ] Ensure `cols` is never zero or negative (use fallback)
- [ ] Filter out null/undefined layout items
- [ ] Validate that all items fit within cols: `x + w ≤ cols`
- [ ] Use `React.useMemo` for expensive calculations
- [ ] Add debug logs during development
- [ ] Test with empty layout edge case
- [ ] Consider SSR requirements if applicable

## Next Steps

- For TypeScript type safety, see `references/03-typescript-nextjs.md`
- For ASTA-specific layout generation, see `references/04-asta-patterns.md`
- For working examples, see `examples/cols-width-calculation.tsx`
