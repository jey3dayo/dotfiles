/**
 * Cols/Width Calculation Example
 *
 * This example demonstrates dynamic cols and width calculation patterns.
 * This is the ASTA-style approach for content-driven grid sizing.
 */

import React from 'react';
import ReactGridLayout, { Layout } from 'react-grid-layout';
import 'react-grid-layout/css/styles.css';
import 'react-resizable/css/styles.css';

// Constants (from ASTA pattern)
const CALENDAR_ROW_HEIGHT = 24;
const CALENDAR_CELL_MARGIN: [number, number] = [2, 2];

interface DynamicGridProps {
  items: Array<{
    id: string;
    x: number;
    y: number;
    w: number;
    h: number;
  }>;
}

/**
 * Grid with dynamic cols/width calculation
 */
export function DynamicGrid({ items }: DynamicGridProps) {
  // Step 1: Convert items to layout array
  const layout: Layout[] = React.useMemo(() => {
    console.log('[Step 1] Converting items to layout');

    const layouts = items.map(item => ({
      i: item.id,
      x: item.x,
      y: item.y,
      w: item.w,
      h: item.h,
    }));

    console.log('[Step 1 Result]', {
      itemCount: layouts.length,
      layouts: layouts.map(l => ({ i: l.i, x: l.x, w: l.w, rightEdge: l.x + l.w })),
    });

    return layouts;
  }, [items]);

  // Step 2: Calculate required columns (ASTA dynamic calculation pattern)
  const cols = React.useMemo(() => {
    console.log('[Step 2] Calculating required columns');

    // Calculate the rightmost edge of each item (x + w)
    const pointsX = layout.map(({ x, w }) => x + w);
    console.log('[Step 2] Right edges:', pointsX);

    // Find the maximum value (= minimum required columns)
    // Use fallback of 12 if no items
    const calculatedCols = pointsX.length > 0
      ? Math.max(...pointsX)
      : 12;

    console.log('[Step 2 Result]', {
      pointsX,
      calculatedCols,
      fallbackUsed: pointsX.length === 0,
    });

    return calculatedCols;
  }, [layout]);

  // Step 3: Calculate pixel width from cols
  const gridWidth = React.useMemo(() => {
    console.log('[Step 3] Calculating pixel width');

    // Simple proportional calculation:
    // Each column occupies rowHeight pixels
    const calculatedWidth = cols * CALENDAR_ROW_HEIGHT;

    console.log('[Step 3 Result]', {
      cols,
      rowHeight: CALENDAR_ROW_HEIGHT,
      gridWidth: calculatedWidth,
      formula: `${cols} cols × ${CALENDAR_ROW_HEIGHT}px = ${calculatedWidth}px`,
    });

    return calculatedWidth;
  }, [cols]);

  // Step 4: Render debug information
  const debugInfo = React.useMemo(() => {
    return {
      itemCount: layout.length,
      calculatedCols: cols,
      gridWidth: gridWidth,
      rowHeight: CALENDAR_ROW_HEIGHT,
      itemBreakdown: layout.map(item => ({
        id: item.i,
        position: `(${item.x}, ${item.y})`,
        size: `${item.w}×${item.h}`,
        rightEdge: item.x + item.w,
      })),
    };
  }, [layout, cols, gridWidth]);

  return (
    <div style={{ padding: '20px' }}>
      <h1>Dynamic Cols/Width Calculation</h1>

      {/* Debug Panel */}
      <div className="debug-panel">
        <h3>Calculation Breakdown</h3>
        <pre>{JSON.stringify(debugInfo, null, 2)}</pre>
      </div>

      {/* Grid */}
      <div className="grid-container">
        <ReactGridLayout
          className="layout"
          layout={layout}

          // Dynamic values calculated above
          cols={cols}
          width={gridWidth}

          // Fixed configuration
          rowHeight={CALENDAR_ROW_HEIGHT}
          margin={CALENDAR_CELL_MARGIN}

          // ASTA calendar behavior
          compactType={null}           // No compaction
          preventCollision={true}       // Items cannot push each other
          isDraggable={false}           // Static layout
          isResizable={false}           // Static layout
          useCSSTransforms={true}       // Performance optimization
        >
          {layout.map(item => (
            <div key={item.i} className="grid-item">
              <strong>{item.i}</strong>
              <br />
              Position: ({item.x}, {item.y})
              <br />
              Size: {item.w}×{item.h}
              <br />
              Right edge: {item.x + item.w}
            </div>
          ))}
        </ReactGridLayout>
      </div>

      <style jsx>{`
        .debug-panel {
          background: #f5f5f5;
          border: 1px solid #ddd;
          padding: 15px;
          margin-bottom: 20px;
          border-radius: 4px;
          font-family: monospace;
          font-size: 12px;
        }

        .debug-panel h3 {
          margin-top: 0;
          font-family: sans-serif;
        }

        .debug-panel pre {
          background: white;
          padding: 10px;
          border: 1px solid #ddd;
          border-radius: 4px;
          overflow: auto;
          max-height: 300px;
        }

        .grid-container {
          border: 2px solid #2196f3;
          padding: 10px;
          background: #e3f2fd;
        }

        .grid-item {
          background: white;
          border: 1px solid #1976d2;
          padding: 8px;
          font-size: 11px;
          overflow: hidden;
          box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
      `}</style>
    </div>
  );
}

/**
 * Example with various layouts
 */
export function ColsWidthExamples() {
  const [exampleIndex, setExampleIndex] = React.useState(0);

  const examples = [
    {
      name: 'Simple 3-column layout',
      items: [
        { id: 'a', x: 0, y: 0, w: 3, h: 2 },
        { id: 'b', x: 3, y: 0, w: 3, h: 2 },
        { id: 'c', x: 6, y: 0, w: 3, h: 2 },
      ],
      expectedCols: 9,
    },
    {
      name: 'Wide layout (12 columns)',
      items: [
        { id: 'header', x: 0, y: 0, w: 12, h: 1 },
        { id: 'content', x: 0, y: 1, w: 12, h: 3 },
      ],
      expectedCols: 12,
    },
    {
      name: 'Sparse layout',
      items: [
        { id: 'item1', x: 0, y: 0, w: 2, h: 2 },
        { id: 'item2', x: 10, y: 0, w: 4, h: 2 },  // Gap between items
      ],
      expectedCols: 14,
    },
    {
      name: 'Empty layout (fallback)',
      items: [],
      expectedCols: 12,  // Fallback value
    },
    {
      name: 'ASTA calendar-style (variable width)',
      items: [
        { id: 'time-09:00', x: 0, y: 0, w: 2, h: 1 },
        { id: 'room-A', x: 2, y: 0, w: 4, h: 1 },
        { id: 'room-B', x: 6, y: 0, w: 4, h: 1 },
        { id: 'event-1', x: 2, y: 1, w: 4, h: 2 },
        { id: 'event-2', x: 6, y: 2, w: 4, h: 3 },
      ],
      expectedCols: 10,
    },
  ];

  const currentExample = examples[exampleIndex];

  return (
    <div style={{ padding: '20px' }}>
      <h1>Cols/Width Calculation Examples</h1>

      {/* Example Selector */}
      <div className="selector">
        <h3>Select an example:</h3>
        {examples.map((example, index) => (
          <button
            key={index}
            onClick={() => setExampleIndex(index)}
            className={index === exampleIndex ? 'active' : ''}
          >
            {example.name}
            <br />
            <small>Expected cols: {example.expectedCols}</small>
          </button>
        ))}
      </div>

      {/* Current Example */}
      <DynamicGrid items={currentExample.items} />

      <style jsx>{`
        .selector {
          margin-bottom: 20px;
          padding: 15px;
          background: #f5f5f5;
          border-radius: 4px;
        }

        .selector button {
          display: inline-block;
          margin: 5px;
          padding: 10px 15px;
          background: white;
          border: 2px solid #ddd;
          border-radius: 4px;
          cursor: pointer;
          transition: all 0.2s;
        }

        .selector button:hover {
          background: #e3f2fd;
          border-color: #2196f3;
        }

        .selector button.active {
          background: #2196f3;
          color: white;
          border-color: #1976d2;
        }

        .selector button small {
          display: block;
          font-size: 11px;
          margin-top: 4px;
        }
      `}</style>
    </div>
  );
}

/**
 * Usage:
 *
 * import { DynamicGrid, ColsWidthExamples } from './examples/cols-width-calculation';
 *
 * // With custom items
 * function App() {
 *   const items = [
 *     { id: 'a', x: 0, y: 0, w: 4, h: 2 },
 *     { id: 'b', x: 4, y: 0, w: 4, h: 2 },
 *   ];
 *
 *   return <DynamicGrid items={items} />;
 * }
 *
 * // With interactive examples
 * function App() {
 *   return <ColsWidthExamples />;
 * }
 */
