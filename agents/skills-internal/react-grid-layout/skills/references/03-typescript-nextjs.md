# TypeScript and Next.js Integration

This document covers TypeScript type definitions and Next.js-specific integration patterns for react-grid-layout.

## Table of Contents

1. [TypeScript Setup](#typescript-setup)
2. [React 18 Compatibility](#react-18-compatibility)
3. [Next.js SSR Considerations](#nextjs-ssr-considerations)
4. [Type-Safe Patterns](#type-safe-patterns)
5. [Common Type Errors and Solutions](#common-type-errors-and-solutions)

## TypeScript Setup

### Installation

```bash
# Install type definitions
npm install @types/react-grid-layout
# or
pnpm add @types/react-grid-layout
```

### Type Imports

```typescript
import ReactGridLayout, {
  Layout,
  ReactGridLayoutProps,
  ItemCallback,
  WidthProvider,
} from "react-grid-layout";
```

### Core Type Definitions

```typescript
// Layout item
interface Layout {
  i: string;
  x: number;
  y: number;
  w: number;
  h: number;
  minW?: number;
  maxW?: number;
  minH?: number;
  maxH?: number;
  static?: boolean;
  isDraggable?: boolean;
  isResizable?: boolean;
  resizeHandles?: ResizeHandle[];
  isBounded?: boolean;
}

// Resize handle types
type ResizeHandle = "s" | "w" | "e" | "n" | "sw" | "nw" | "se" | "ne";

// Item callback type
type ItemCallback = (
  layout: Layout[],
  oldItem: Layout,
  newItem: Layout,
  placeholder: Layout,
  event: MouseEvent,
  element: HTMLElement,
) => void;

// Main props interface
interface ReactGridLayoutProps {
  className?: string;
  style?: React.CSSProperties;
  width: number;
  autoSize?: boolean;
  cols?: number;
  draggableCancel?: string;
  draggableHandle?: string;
  compactType?: "vertical" | "horizontal" | null;
  layout?: Layout[];
  margin?: [number, number];
  containerPadding?: [number, number] | null;
  rowHeight?: number;
  maxRows?: number;
  isDraggable?: boolean;
  isResizable?: boolean;
  isDroppable?: boolean;
  preventCollision?: boolean;
  useCSSTransforms?: boolean;
  transformScale?: number;
  allowOverlap?: boolean;
  resizeHandles?: ResizeHandle[];
  resizeHandle?:
    | ReactElement
    | ((resizeHandle: string, ref: React.Ref) => ReactElement);
  onLayoutChange?: (layout: Layout[]) => void;
  onDragStart?: ItemCallback;
  onDrag?: ItemCallback;
  onDragStop?: ItemCallback;
  onResizeStart?: ItemCallback;
  onResize?: ItemCallback;
  onResizeStop?: ItemCallback;
  onDrop?: (layout: Layout[], layoutItem: Layout, event: Event) => void;
  onDropDragOver?: (e: DragOverEvent) => { w?: number; h?: number } | false;
  children: React.ReactNode;
}
```

## React 18 Compatibility

### The Problem

React 18 introduced stricter type checking for children props. react-grid-layout's type definitions may not explicitly declare `children: React.ReactNode`, causing TypeScript errors:

```typescript
// ❌ Error in React 18
<ReactGridLayout layout={layout} cols={12} rowHeight={30} width={1200}>
  <div key="a">Content</div>
</ReactGridLayout>

// Error: Property 'children' is missing in type 'ReactGridLayoutProps'
```

### ASTA Solution: SafeGridLayout Wrapper

Create a type-safe wrapper that explicitly declares the children prop:

```typescript
// src/components/Calendar/SafeGridLayout.tsx
import React from 'react';
import ReactGridLayout, { ReactGridLayoutProps } from 'react-grid-layout';

/**
 * Type-safe wrapper for ReactGridLayout compatible with React 18
 *
 * Resolves type compatibility by explicitly declaring children prop
 */
export interface SafeGridLayoutProps extends ReactGridLayoutProps {
  children: React.ReactNode;
}

export const SafeGridLayout: React.FC<SafeGridLayoutProps> = props => {
  return <ReactGridLayout {...props} />;
};

// Usage
import { SafeGridLayout } from '@/components/Calendar/SafeGridLayout';

<SafeGridLayout layout={layout} cols={12} rowHeight={30} width={1200}>
  <div key="a">Content</div>
</SafeGridLayout>
```

### Alternative Approach: Type Assertion

If you don't want to create a wrapper:

```typescript
// Type assertion (less recommended)
<ReactGridLayout
  {...props}
  // @ts-ignore: React 18 children prop compatibility
>
  {children}
</ReactGridLayout>

// Or use 'as' assertion
const GridLayoutWithChildren = ReactGridLayout as React.ComponentType<
  ReactGridLayoutProps & { children: React.ReactNode }
>;

<GridLayoutWithChildren {...props}>
  {children}
</GridLayoutWithChildren>
```

**Recommendation:** Use SafeGridLayout wrapper for cleaner, maintainable code.

## Next.js SSR Considerations

### The Width Problem

react-grid-layout requires the `width` prop for drag calculations. In SSR, the container width is unknown at render time, causing issues.

### Solution 1: Dynamic Import with SSR Disabled

```typescript
// components/GridLayout.tsx
import React from 'react';
import { Layout } from 'react-grid-layout';
import { SafeGridLayout } from './SafeGridLayout';

interface GridLayoutProps {
  layout: Layout[];
}

export function GridLayout({ layout }: GridLayoutProps) {
  return (
    <SafeGridLayout
      layout={layout}
      cols={12}
      rowHeight={30}
      width={1200}
    >
      {layout.map(item => (
        <div key={item.i}>{item.i}</div>
      ))}
    </SafeGridLayout>
  );
}
```

```typescript
// pages/calendar.tsx
import dynamic from 'next/dynamic';

// Dynamic import with SSR disabled
const GridLayout = dynamic(
  () => import('@/components/GridLayout').then(mod => mod.GridLayout),
  { ssr: false }
);

export default function CalendarPage() {
  const layout = [
    { i: 'a', x: 0, y: 0, w: 1, h: 2 },
    { i: 'b', x: 1, y: 0, w: 3, h: 2 },
  ];

  return (
    <div>
      <h1>Calendar</h1>
      <GridLayout layout={layout} />
    </div>
  );
}
```

### Pros:

- Simple and clean
- No SSR complexity

### Cons:

- Component not rendered on server
- May impact SEO if grid content is important
- Flash of unstyled content possible

### Solution 2: Calculate Width Explicitly (ASTA Pattern)

```typescript
// Calculate fixed width based on layout
const cols = Math.max(...layout.map(({ x, w }) => x + w), 12);
const gridWidth = cols * 24;  // Fixed calculation

<SafeGridLayout
  layout={layout}
  cols={cols}
  width={gridWidth}  // Explicit width, SSR-safe
  rowHeight={24}
>
  {children}
</SafeGridLayout>
```

### Pros:

- SSR-compatible
- Predictable rendering
- No hydration mismatches

### Cons:

- Not responsive to container size
- Requires manual width management

### Solution 3: WidthProvider (Client-Only)

```typescript
import { WidthProvider } from "react-grid-layout";
import { SafeGridLayout } from "./SafeGridLayout";

const ResponsiveGridLayout = WidthProvider(SafeGridLayout);

// Must use dynamic import
const GridLayout = dynamic(() => import("./GridLayout"), { ssr: false });
```

**Recommendation for ASTA:** Use Solution 2 (explicit width) for SSR compatibility and predictable rendering.

## Type-Safe Patterns

### Custom Grid Component with Strong Types

```typescript
import React from 'react';
import { Layout } from 'react-grid-layout';
import { SafeGridLayout, SafeGridLayoutProps } from './SafeGridLayout';

interface CalendarGridProps extends Omit<SafeGridLayoutProps, 'width' | 'cols' | 'rowHeight'> {
  events: Event[];
  rooms: Room[];
}

export const CalendarGrid: React.FC<CalendarGridProps> = ({
  events,
  rooms,
  layout,
  ...gridProps
}) => {
  // Calculate dimensions from layout
  const cols = React.useMemo(() => {
    const pointsX = layout.map(({ x, w }) => x + w);
    return Math.max(...pointsX, 12);
  }, [layout]);

  const gridWidth = React.useMemo(
    () => cols * 24,
    [cols]
  );

  return (
    <SafeGridLayout
      layout={layout}
      cols={cols}
      width={gridWidth}
      rowHeight={24}
      margin={[2, 2]}
      compactType={null}
      preventCollision={true}
      {...gridProps}
    >
      {layout.map(item => (
        <div key={item.i} className="calendar-cell">
          {item.i}
        </div>
      ))}
    </SafeGridLayout>
  );
};
```

### Type-Safe Layout Generation

```typescript
interface LayoutInput {
  id: string;
  x: number;
  y: number;
  width: number;
  height: number;
  isStatic?: boolean;
}

function createLayout(input: LayoutInput): Layout {
  return {
    i: input.id,
    x: input.x,
    y: input.y,
    w: input.width,
    h: input.height,
    static: input.isStatic ?? false,
  };
}

// Type-safe usage
const layouts: Layout[] = [
  createLayout({
    id: "header",
    x: 0,
    y: 0,
    width: 12,
    height: 2,
    isStatic: true,
  }),
  createLayout({ id: "content", x: 0, y: 2, width: 12, height: 4 }),
];
```

### Generic Layout Builder

```typescript
interface LayoutBuilder<T> {
  items: T[];
  toLayout: (item: T, index: number) => Layout;
}

function buildLayout<T>(builder: LayoutBuilder<T>): Layout[] {
  return builder.items
    .map((item, index) => builder.toLayout(item, index))
    .filter((layout): layout is Layout => layout !== null);
}

// Usage
interface Event {
  id: string;
  startTime: Date;
  duration: number;
  roomId: string;
}

const events: Event[] = [...];

const layout = buildLayout({
  items: events,
  toLayout: (event, index) => ({
    i: event.id,
    x: getRoomColumn(event.roomId),
    y: getTimeRow(event.startTime),
    w: 4,
    h: getDurationHeight(event.duration),
  }),
});
```

## Common Type Errors and Solutions

### Error 1: Children Prop Missing

```typescript
// ❌ Error
<ReactGridLayout layout={layout} cols={12}>
  <div>Content</div>
</ReactGridLayout>

// Error: Property 'children' is missing in type 'ReactGridLayoutProps'
```

**Solution:** Use SafeGridLayout wrapper

```typescript
// ✅ Fixed
<SafeGridLayout layout={layout} cols={12}>
  <div>Content</div>
</SafeGridLayout>
```

### Error 2: Layout Type Mismatch

```typescript
// ❌ Error
const layout = [
  { id: "a", x: 0, y: 0, w: 1, h: 2 }, // 'id' should be 'i'
];
```

**Solution:** Use correct property names

```typescript
// ✅ Fixed
const layout: Layout[] = [{ i: "a", x: 0, y: 0, w: 1, h: 2 }];
```

### Error 3: Width Type Error

```typescript
// ❌ Error
<ReactGridLayout width="1200" {...props}>  // string instead of number
```

**Solution:** Use number type

```typescript
// ✅ Fixed
<ReactGridLayout width={1200} {...props}>
```

### Error 4: Callback Type Mismatch

```typescript
// ❌ Error
const handleDragStop = (layout: Layout[]) => {
  // Missing required parameters
};

<ReactGridLayout onDragStop={handleDragStop} />
```

**Solution:** Use correct callback signature

```typescript
// ✅ Fixed
import { ItemCallback } from 'react-grid-layout';

const handleDragStop: ItemCallback = (layout, oldItem, newItem, placeholder, event, element) => {
  console.log('Drag stopped:', newItem);
};

<ReactGridLayout onDragStop={handleDragStop} />
```

### Error 5: Null/Undefined in Layout Array

```typescript
// ❌ Error
const layout: Layout[] = [
  { i: "a", x: 0, y: 0, w: 1, h: 2 },
  null, // Type error!
];
```

**Solution:** Filter out null/undefined

```typescript
// ✅ Fixed
const rawLayout = [{ i: "a", x: 0, y: 0, w: 1, h: 2 }, null];

const layout: Layout[] = rawLayout.filter(
  (item): item is Layout => item !== null && item !== undefined,
);
```

## CSS Import in TypeScript

Always import the required CSS files:

```typescript
// In _app.tsx or layout component
import "react-grid-layout/css/styles.css";
import "react-resizable/css/styles.css";
```

If using CSS modules:

```typescript
import styles from './GridLayout.module.css';

<SafeGridLayout className={styles.grid} {...props}>
  {children}
</SafeGridLayout>
```

## Best Practices

### 1. Use SafeGridLayout Wrapper

Always use the SafeGridLayout wrapper for React 18 compatibility:

```typescript
// ✅ Recommended
import { SafeGridLayout } from "@/components/Calendar/SafeGridLayout";
```

### 2. Type Layout Arrays Explicitly

```typescript
// ✅ Explicit typing
const layout: Layout[] = [{ i: "a", x: 0, y: 0, w: 1, h: 2 }];

// ❌ Implicit typing (may cause issues)
const layout = [{ i: "a", x: 0, y: 0, w: 1, h: 2 }];
```

### 3. Use React.useMemo for Expensive Calculations

```typescript
const cols = React.useMemo(
  () => Math.max(...layout.map(({ x, w }) => x + w), 12),
  [layout],
);
```

### 4. Handle SSR Appropriately

- Use dynamic import with `ssr: false` for responsive grids
- Use explicit width calculation for SSR-compatible grids

### 5. Filter Null/Undefined Early

```typescript
const validLayout = React.useMemo(
  () => rawLayout.filter((item): item is Layout => item !== null),
  [rawLayout],
);
```

## Complete ASTA Example

```typescript
// src/components/Calendar/GridLayout.tsx
import React from 'react';
import { Layout } from 'react-grid-layout';
import { SafeGridLayout } from './SafeGridLayout';
import 'react-grid-layout/css/styles.css';
import 'react-resizable/css/styles.css';

const CALENDAR_ROW_HEIGHT = 24;
const CALENDAR_CELL_MARGIN: [number, number] = [2, 2];

interface GridLayoutProps {
  layout: (Layout | null)[];
}

export const GridLayout: React.FC<GridLayoutProps> = ({ layout: inputLayout }) => {
  // Filter and memoize layout
  const layout = React.useMemo(
    () => inputLayout.filter((item): item is Layout => item !== null),
    [inputLayout]
  );

  // Calculate cols
  const cols = React.useMemo(() => {
    const pointsX = layout.map(({ x, w }) => x + w);
    return Math.max(...pointsX, 150);
  }, [layout]);

  // Calculate width
  const gridWidth = React.useMemo(
    () => cols * CALENDAR_ROW_HEIGHT,
    [cols]
  );

  return (
    <SafeGridLayout
      className="calendar-grid"
      layout={layout}
      cols={cols}
      width={gridWidth}
      rowHeight={CALENDAR_ROW_HEIGHT}
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
    </SafeGridLayout>
  );
};
```

## Next Steps

- For ASTA-specific patterns, see `references/04-asta-patterns.md`
- For working examples, see `examples/safe-wrapper.tsx`
- For cols/width calculations, see `references/02-cols-width-calculation.md`
