# ASTA Project Patterns

This document describes ASTA project-specific patterns for react-grid-layout implementation, particularly for calendar/schedule layouts.

## Table of Contents

1. [Project Overview](#project-overview)
2. [Constants Management](#constants-management)
3. [Layout Utilities](#layout-utilities)
4. [Time-Based Layouts](#time-based-layouts)
5. [Implementation Patterns](#implementation-patterns)
6. [Common Workflows](#common-workflows)

## Project Overview

### Purpose

ASTA uses react-grid-layout for two main calendar systems:

- **Studio Calendar**: Studio/room scheduling with event and stream management
- **RoomSchedule Calendar**: Dressing room scheduling

### Architecture

```
src/components/Calendar/
├── SafeGridLayout.tsx          # React 18 wrapper
├── Studio/
│   ├── GridLayout.tsx          # Studio calendar grid
│   └── layouts.ts              # Layout generation logic
├── RoomSchedule/
│   ├── GridLayout.tsx          # Room schedule grid
│   └── layouts.ts              # Layout generation logic
└── lib/
    ├── layoutUtils.ts          # Shared utilities
    └── timedLayout.ts          # Time-based layout helpers
```

## Constants Management

### Constants Definition

```typescript
// src/config/constants.ts

// Grid sizing
export const CALENDAR_ROW_HEIGHT = 24; // pixels per grid row
export const CALENDAR_CELL_MARGIN: [number, number] = [2, 2]; // [x, y] margin

// Layout dimensions (in grid units)
export const FLOOR_COL_HEIGHT = 1;
export const STUDIO_COL_HEIGHT = 2;
export const ROOM_COL_WIDTH = 4;
```

### Usage Pattern

```typescript
import {
  CALENDAR_ROW_HEIGHT,
  CALENDAR_CELL_MARGIN,
  STUDIO_COL_HEIGHT,
} from "@/config/constants";

const gridWidth = cols * CALENDAR_ROW_HEIGHT;
```

### Benefits:

- Centralized configuration
- Easy to adjust dimensions globally
- Type-safe constant values

## Layout Utilities

### Core Utility Functions

Located in `src/components/Calendar/lib/layoutUtils.ts`:

#### 1. addDateTimeLayouts

```typescript
/**
 * Register date/time layouts for time-based positioning
 */
export const addDateTimeLayouts = (params: {
  dateTimes: DateTime[];
  layoutsById: LayoutsById;
}): void => {
  const { dateTimes, layoutsById } = params;

  dateTimes.forEach((dateTime, index) => {
    const layout = createDateLayouts({
      dateTime,
      yPosition: index,
    });

    // Register each layout component
    registerLayouts(layout, layoutsById);
  });
};
```

**Purpose:** Register date/time grid positions for use in time-based calculations

#### 2. createDateLayouts

```typescript
/**
 * Generate layout items for date/time headers
 */
export const createDateLayouts = (params: {
  dateTime: DateTime;
  yPosition: number;
}): Layout[] => {
  const { dateTime, yPosition } = params;

  return [
    {
      i: `date-${dateTime}`,
      x: 0,
      y: yPosition,
      w: 4,
      h: 1,
      static: true,
    },
    {
      i: `time-${dateTime}`,
      x: 4,
      y: yPosition,
      w: 2,
      h: 1,
      static: true,
    },
  ];
};
```

**Purpose:** Create header layouts for date/time columns

#### 3. registerLayouts

```typescript
/**
 * Register layout array into layoutsById map
 */
export const registerLayouts = (
  layouts: Layout[],
  layoutsById: LayoutsById,
): void => {
  layouts.forEach((layout) => {
    layoutsById[layout.i] = layout;
  });
};
```

**Purpose:** Convert layout array to ID-indexed map for fast lookup

#### 4. filterValidLayouts

```typescript
/**
 * Filter out null/undefined layout items
 */
export const filterValidLayouts = (
  layouts: (Layout | null | undefined)[],
): Layout[] => {
  return layouts.filter(
    (layout): layout is Layout => layout !== null && layout !== undefined,
  );
};
```

**Purpose:** Clean layout array before rendering

### Layout Registry Pattern

```typescript
// LayoutsById type: O(1) lookup by ID
type LayoutsById = Record<string, Layout>;

// Build registry
const layoutsById: LayoutsById = {};

// Register base layouts
registerLayouts(dateLayouts, layoutsById);
registerLayouts(roomLayouts, layoutsById);

// Use for lookups
const roomLayout = layoutsById["room-123"];
```

### Why use this pattern:

- Fast lookups for time-based calculations
- Prevents duplicate layout generation
- Clean separation between base and derived layouts

## Time-Based Layouts

### Time-Based Layout Generation

Located in `src/components/Calendar/lib/timedLayout.ts`:

```typescript
export interface TimedLayoutInput {
  id: string;
  baseLayoutKey: string; // Reference layout for x position
  startKey: string; // Time slot key for start position
  endKey: string; // Time slot key for end position
  width: number; // Width in grid units
  layoutsById: LayoutsById;
  static?: boolean;
}

export const createTimedSpanLayout = ({
  id,
  baseLayoutKey,
  startKey,
  endKey,
  width,
  layoutsById,
  static: definedStatic = false,
}: TimedLayoutInput): Layout | null => {
  // Look up base layout for x position
  const baseLayout = layoutsById[baseLayoutKey];
  const x = baseLayout?.x;

  // Look up time positions for y coordinates
  const startY = layoutsById[startKey]?.y ?? null;
  const endY = layoutsById[endKey]?.y ?? null;

  // Validate all required data is available
  if (x === undefined || startY === null || endY === null) {
    return null; // Return null if data incomplete
  }

  // Calculate height from time span
  const height = endY - startY;

  return {
    i: id,
    x,
    y: startY,
    w: width,
    h: height,
    static: definedStatic,
  };
};
```

### Example Usage

```typescript
// 1. Register time slots
const dateTimes = ["09:00", "10:00", "11:00", "12:00"];
const layoutsById: LayoutsById = {};

dateTimes.forEach((time, index) => {
  layoutsById[`time-${time}`] = {
    i: `time-${time}`,
    x: 0,
    y: index,
    w: 2,
    h: 1,
    static: true,
  };
});

// 2. Register room layouts
layoutsById["room-A"] = {
  i: "room-A",
  x: 10,
  y: 0,
  w: 4,
  h: 1,
  static: true,
};

// 3. Generate event spanning time range
const eventLayout = createTimedSpanLayout({
  id: "event-123",
  baseLayoutKey: "room-A", // Use room's x position (10)
  startKey: "time-09:00", // Start at y=0
  endKey: "time-11:00", // End at y=2
  width: 4, // Same width as room
  layoutsById,
});

// Result:
// {
//   i: 'event-123',
//   x: 10,     // From room-A
//   y: 0,      // From time-09:00
//   w: 4,
//   h: 2,      // endY (2) - startY (0)
//   static: false
// }
```

### Benefits of Time-Based Pattern

1. **Automatic Positioning**: Events align to time slots automatically
2. **Consistent Layout**: All items follow same time grid
3. **Easy Updates**: Change time slot positions without updating events
4. **Null-Safe**: Returns null if required data missing

## Implementation Patterns

### Studio Calendar Pattern

Complete implementation in `src/components/Calendar/Studio/layouts.ts`:

```typescript
import { Layout } from "react-grid-layout";
import {
  addDateTimeLayouts,
  createDateLayouts,
  registerLayouts,
  filterValidLayouts,
} from "../lib/layoutUtils";
import { createTimedSpanLayout, LayoutsById } from "../lib/timedLayout";

interface GetLayoutParams {
  dateTimes: DateTime[];
  floors: Floor[];
  studios: Studio[];
  rooms: Room[];
  events: Event[];
  streams: Stream[];
}

export const getLayout = ({
  dateTimes,
  floors,
  studios,
  rooms,
  events,
  streams,
}: GetLayoutParams): Layout[] => {
  const layoutsById: LayoutsById = {};

  // Step 1: Register date/time grid
  addDateTimeLayouts({ dateTimes, layoutsById });

  // Step 2: Register structural layouts (floors, studios, rooms)
  const floorLayouts = floors.map((floor, index) => ({
    i: `floor-${floor.id}`,
    x: index * 10,
    y: 0,
    w: 10,
    h: FLOOR_COL_HEIGHT,
    static: true,
  }));
  registerLayouts(floorLayouts, layoutsById);

  const studioLayouts = studios.map((studio) => ({
    i: `studio-${studio.id}`,
    x: layoutsById[`floor-${studio.floorId}`]?.x ?? 0,
    y: 1,
    w: 10,
    h: STUDIO_COL_HEIGHT,
    static: true,
  }));
  registerLayouts(studioLayouts, layoutsById);

  const roomLayouts = rooms.map((room, index) => ({
    i: `room-${room.id}`,
    x: index * ROOM_COL_WIDTH,
    y: 3,
    w: ROOM_COL_WIDTH,
    h: 1,
    static: true,
  }));
  registerLayouts(roomLayouts, layoutsById);

  // Step 3: Generate time-based event layouts
  const eventLayouts = events.map((event) =>
    createTimedSpanLayout({
      id: `event-${event.id}`,
      baseLayoutKey: `room-${event.roomId}`,
      startKey: `time-${event.startTime}`,
      endKey: `time-${event.endTime}`,
      width: ROOM_COL_WIDTH,
      layoutsById,
    }),
  );

  // Step 4: Generate time-based stream layouts
  const streamLayouts = streams.map((stream) =>
    createTimedSpanLayout({
      id: `stream-${stream.id}`,
      baseLayoutKey: `room-${stream.roomId}`,
      startKey: `time-${stream.startTime}`,
      endKey: `time-${stream.endTime}`,
      width: ROOM_COL_WIDTH,
      layoutsById,
      static: true, // Streams are static
    }),
  );

  // Step 5: Combine and filter all layouts
  return filterValidLayouts([
    ...floorLayouts,
    ...studioLayouts,
    ...roomLayouts,
    ...eventLayouts,
    ...streamLayouts,
  ]);
};
```

### RoomSchedule Calendar Pattern

Similar pattern in `src/components/Calendar/RoomSchedule/layouts.ts`:

```typescript
export const getLayout = ({
  dateTimes,
  areas,
  rooms,
  reservations,
}: GetLayoutParams): Layout[] => {
  const layoutsById: LayoutsById = {};

  // Register time grid
  addDateTimeLayouts({ dateTimes, layoutsById });

  // Register areas and rooms
  // ... (similar to Studio pattern)

  // Generate reservation layouts
  const reservationLayouts = reservations.map((reservation) =>
    createTimedSpanLayout({
      id: `reservation-${reservation.id}`,
      baseLayoutKey: `room-${reservation.roomId}`,
      startKey: `time-${reservation.startTime}`,
      endKey: `time-${reservation.endTime}`,
      width: ROOM_COL_WIDTH,
      layoutsById,
    }),
  );

  return filterValidLayouts([
    // ... combine all layouts
  ]);
};
```

## Common Workflows

### Workflow 1: Adding New Time-Based Item

```typescript
// 1. Ensure time slots registered
addDateTimeLayouts({ dateTimes, layoutsById });

// 2. Ensure base layout registered (room, resource, etc.)
const roomLayout = {
  i: `room-${roomId}`,
  x: calculateX(room),
  y: 0,
  w: ROOM_COL_WIDTH,
  h: 1,
  static: true,
};
layoutsById[roomLayout.i] = roomLayout;

// 3. Create time-based layout
const itemLayout = createTimedSpanLayout({
  id: `item-${itemId}`,
  baseLayoutKey: `room-${roomId}`,
  startKey: `time-${startTime}`,
  endKey: `time-${endTime}`,
  width: ROOM_COL_WIDTH,
  layoutsById,
});

// 4. Add to final layout array
if (itemLayout) {
  layouts.push(itemLayout);
}
```

### Workflow 2: Debugging Layout Issues

```typescript
const layout = getLayout({ /* params */ });

// Log layout statistics
console.log('[Layout Debug]', {
  totalItems: layout.length,
  staticItems: layout.filter(l => l.static).length,
  dynamicItems: layout.filter(l => !l.static).length,
  nullLayouts: layout.filter(l => l === null).length,
});

// Validate layout integrity
const pointsX = layout.map(({ x, w }) => x + w);
const calculatedCols = Math.max(...pointsX);
console.log('[Grid Dimensions]', {
  calculatedCols,
  expectedCols: /* your expected value */,
  match: calculatedCols === /* expected */,
});

// Check for overlap issues
layout.forEach(item => {
  const overlaps = layout.filter(other =>
    other.i !== item.i &&
    other.x < item.x + item.w &&
    other.x + other.w > item.x &&
    other.y < item.y + item.h &&
    other.y + other.h > item.y
  );
  if (overlaps.length > 0) {
    console.warn(`[Overlap Detected] ${item.i} overlaps with:`, overlaps.map(o => o.i));
  }
});
```

### Workflow 3: Performance Optimization

```typescript
// Memoize expensive layout calculations
const layout = React.useMemo(
  () => getLayout({ dateTimes, floors, studios, rooms, events, streams }),
  [dateTimes, floors, studios, rooms, events, streams],
);

// Memoize cols calculation
const cols = React.useMemo(() => {
  const pointsX = layout.map(({ x, w }) => x + w);
  return Math.max(...pointsX, 150);
}, [layout]);

// Memoize width calculation
const gridWidth = React.useMemo(() => cols * CALENDAR_ROW_HEIGHT, [cols]);
```

## Best Practices

### 1. Always Register Before Creating Time-Based Layouts

```typescript
// ✅ Good: Register first
layoutsById['base'] = baseLayout;
const derived = createTimedSpanLayout({ baseLayoutKey: 'base', ... });

// ❌ Bad: Create without registering
const derived = createTimedSpanLayout({ baseLayoutKey: 'base', ... });
// Result: null (base not found)
```

### 2. Filter Null Layouts Before Rendering

```typescript
// ✅ Good: Filter nulls
const layout = filterValidLayouts([...allLayouts]);

// ❌ Bad: Include nulls
const layout = [...allLayouts]; // May contain null!
```

### 3. Use Constants for Dimensions

```typescript
// ✅ Good: Use constants
import { ROOM_COL_WIDTH } from "@/config/constants";
const layout = { w: ROOM_COL_WIDTH };

// ❌ Bad: Magic numbers
const layout = { w: 4 }; // What does 4 mean?
```

### 4. Consistent Key Naming

```typescript
// ✅ Good: Consistent pattern
const eventKey = `event-${event.id}`;
const roomKey = `room-${room.id}`;
const timeKey = `time-${datetime}`;

// ❌ Bad: Inconsistent
const key1 = `event_${id}`;
const key2 = `${id}-room`;
```

### 5. Memoize Layout Calculations

```typescript
// ✅ Good: Memoized
const layout = React.useMemo(() => getLayout(params), [params]);

// ❌ Bad: Recalculates every render
const layout = getLayout(params);
```

## Next Steps

- For cols/width calculation details, see `references/02-cols-width-calculation.md`
- For TypeScript patterns, see `references/03-typescript-nextjs.md`
- For working examples, see `examples/timed-layout.tsx`
