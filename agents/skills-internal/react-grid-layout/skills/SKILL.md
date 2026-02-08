---
name: react-grid-layout
description: |
  [What] React grid layout implementation with Context7 integration and ASTA-specific patterns. Combines latest react-grid-layout documentation with project-specific time-based layouts, cols/width calculations, and TypeScript/Next.js integration
  [When] Use when: users mention "react-grid-layout", "ReactGridLayout", "GridLayout", "cols calculation", "width calculation", or work with grid layout components in ASTA project
  [Keywords] react-grid-layout, ReactGridLayout, GridLayout, cols calculation, width calculation, ASTA calendar
---

# React Grid Layout Skill (Context7 Enhanced)

## Overview

This skill orchestrates react-grid-layout implementation by combining Context7's latest documentation with ASTA-specific patterns for calendar/schedule systems.

## Context7 Integration

Fetch latest react-grid-layout documentation:

```typescript
// Basic API and configuration
context7.query(
  "/react-grid-layout/react-grid-layout",
  "basic usage layout structure cols width rowHeight",
);

// TypeScript integration
context7.query(
  "/react-grid-layout/react-grid-layout",
  "TypeScript types GridConfig Layout",
);

// Next.js SSR handling
context7.query(
  "/react-grid-layout/react-grid-layout",
  "Next.js SSR dynamic import useContainerWidth",
);

// Responsive and hooks
context7.query(
  "/react-grid-layout/react-grid-layout",
  "useContainerWidth responsive grid hooks",
);
```

## ASTA-Specific Patterns

### Time-Based Layout Generation

ASTA uses react-grid-layout for calendar systems with time-based event positioning:

- **Studio Calendar**: Studio/room scheduling (src/components/Calendar/Studio/)
- **RoomSchedule Calendar**: Dressing room scheduling (src/components/Calendar/RoomSchedule/)

**Key pattern**: See `references/04-asta-patterns.md` for:

- Constants management (CALENDAR_ROW_HEIGHT, CALENDAR_CELL_MARGIN)
- Layout utilities (layoutUtils.ts, timedLayout.ts)
- Time-based layout generation
- Event positioning logic

### Cols/Width Calculation

ASTA-specific dynamic calculation pattern:

```typescript
// Calculate required columns from layout
const pointsX = layout.map(({ x, w }) => x + w);
const cols = Math.max(...pointsX) || 150;

// Calculate grid width
const gridWidth = cols * rowHeight;
```

**Details**: See `references/02-cols-width-calculation.md` for:

- Dynamic vs fixed calculation strategies
- Common calculation mistakes
- Debugging techniques

### TypeScript/Next.js Integration

ASTA uses SafeGridLayout wrapper for React 18 compatibility:

```typescript
interface SafeGridLayoutProps extends ReactGridLayoutProps {
  children: React.ReactNode;
}

const SafeGridLayout: React.FC<SafeGridLayoutProps> = props => {
  return <ReactGridLayout {...props} />;
};
```

**SSR considerations**: See `references/03-typescript-nextjs.md` for:

- Type-safe wrappers
- Dynamic imports with ssr: false
- Width specification strategies

## Implementation Workflow

1. **Query Context7**: Get latest API documentation
2. **Apply ASTA Patterns**: Use project-specific time-based layout logic
3. **Calculate Sizing**: Use ASTA's dynamic cols/width calculation
4. **Handle SSR**: Apply SafeGridLayout wrapper for Next.js
5. **Test**: Verify calendar rendering and interaction

## Progressive Documentation

- **SKILL.md** (this file): Overview and Context7 integration
- **references/04-asta-patterns.md**: ASTA calendar patterns (always load for ASTA projects)
- **references/02-cols-width-calculation.md**: Load for sizing issues
- **references/03-typescript-nextjs.md**: Load for TypeScript/SSR issues
- **examples/timed-layout.tsx**: ASTA implementation example

## Common Use Cases

| Issue                                     | Solution                                                               |
| ----------------------------------------- | ---------------------------------------------------------------------- |
| "How to use react-grid-layout?"           | Query Context7 for basic API                                           |
| "Grid items overlapping in ASTA calendar" | Check `references/02-cols-width-calculation.md`                        |
| "TypeScript errors with ReactGridLayout"  | See `references/03-typescript-nextjs.md`                               |
| "ASTA time-based event layout"            | Study `references/04-asta-patterns.md`                                 |
| "Next.js SSR issues"                      | Apply SafeGridLayout pattern from `references/03-typescript-nextjs.md` |
