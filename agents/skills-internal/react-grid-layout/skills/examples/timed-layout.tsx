/**
 * Time-Based Layout Example
 *
 * This example demonstrates ASTA's time-based layout generation pattern
 * for calendar and schedule applications.
 */

import React from 'react';
import { Layout } from 'react-grid-layout';
import { SafeGridLayout } from './safe-wrapper';

/**
 * LayoutsById: Fast O(1) lookup by ID
 */
type LayoutsById = Record<string, Layout>;

/**
 * Time-based layout input
 */
interface TimedLayoutInput {
  id: string;
  baseLayoutKey: string;  // Reference layout for x position (e.g., "room-A")
  startKey: string;       // Time slot key for start position (e.g., "time-09:00")
  endKey: string;         // Time slot key for end position (e.g., "time-11:00")
  width: number;          // Width in grid units
  layoutsById: LayoutsById;
  static?: boolean;
}

/**
 * Create time-based span layout
 *
 * This is the core ASTA pattern for generating layouts that span time ranges.
 */
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
    console.warn('[createTimedSpanLayout] Missing required data:', {
      id,
      baseLayoutKey,
      startKey,
      endKey,
      hasBaseLayout: !!baseLayout,
      hasStartY: startY !== null,
      hasEndY: endY !== null,
    });
    return null;  // Return null if data incomplete
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

/**
 * Simple calendar example
 */
export function SimpleCalendarExample() {
  const layout = React.useMemo(() => {
    const layoutsById: LayoutsById = {};

    // Step 1: Register time slots
    const timeSlots = ['09:00', '10:00', '11:00', '12:00', '13:00', '14:00'];
    timeSlots.forEach((time, index) => {
      layoutsById[`time-${time}`] = {
        i: `time-${time}`,
        x: 0,
        y: index,
        w: 2,
        h: 1,
        static: true,
      };
    });

    // Step 2: Register rooms
    const rooms = [
      { id: 'room-A', name: 'Room A', x: 2 },
      { id: 'room-B', name: 'Room B', x: 6 },
      { id: 'room-C', name: 'Room C', x: 10 },
    ];
    rooms.forEach(room => {
      layoutsById[room.id] = {
        i: room.id,
        x: room.x,
        y: 0,
        w: 4,
        h: 1,
        static: true,
      };
    });

    // Step 3: Generate event layouts using time-based pattern
    const events = [
      {
        id: 'event-1',
        roomId: 'room-A',
        startTime: '09:00',
        endTime: '11:00',
        name: 'Meeting A',
      },
      {
        id: 'event-2',
        roomId: 'room-B',
        startTime: '10:00',
        endTime: '12:00',
        name: 'Workshop B',
      },
      {
        id: 'event-3',
        roomId: 'room-C',
        startTime: '13:00',
        endTime: '14:00',
        name: 'Presentation C',
      },
    ];

    const eventLayouts = events
      .map(event =>
        createTimedSpanLayout({
          id: event.id,
          baseLayoutKey: event.roomId,
          startKey: `time-${event.startTime}`,
          endKey: `time-${event.endTime}`,
          width: 4,
          layoutsById,
        })
      )
      .filter((layout): layout is Layout => layout !== null);

    // Combine all layouts
    const allLayouts = [
      ...timeSlots.map(time => layoutsById[`time-${time}`]),
      ...rooms.map(room => layoutsById[room.id]),
      ...eventLayouts,
    ];

    console.log('[SimpleCalendar] Generated layouts:', {
      timeSlots: timeSlots.length,
      rooms: rooms.length,
      events: eventLayouts.length,
      total: allLayouts.length,
    });

    return allLayouts;
  }, []);

  // Calculate cols and width
  const cols = React.useMemo(() => {
    const pointsX = layout.map(({ x, w }) => x + w);
    return Math.max(...pointsX, 12);
  }, [layout]);

  const gridWidth = cols * 24;

  return (
    <div style={{ padding: '20px' }}>
      <h1>Simple Calendar Example</h1>

      <div className="info">
        <h3>How it works:</h3>
        <ol>
          <li>Register time slots (09:00, 10:00, ...)</li>
          <li>Register rooms (Room A, B, C)</li>
          <li>
            Generate events using <code>createTimedSpanLayout</code>
          </li>
          <li>Events automatically align to time slots and rooms</li>
        </ol>
      </div>

      <SafeGridLayout
        className="calendar-grid"
        layout={layout}
        cols={cols}
        width={gridWidth}
        rowHeight={24}
        margin={[2, 2]}
        compactType={null}
        preventCollision={true}
        isDraggable={false}
        isResizable={false}
        useCSSTransforms={true}
      >
        {layout.map(item => {
          const isTimeSlot = item.i.startsWith('time-');
          const isRoom = item.i.startsWith('room-');
          const isEvent = item.i.startsWith('event-');

          return (
            <div
              key={item.i}
              className={`grid-item ${
                isTimeSlot ? 'time-slot' : isRoom ? 'room' : 'event'
              }`}
            >
              {isTimeSlot && item.i.replace('time-', '')}
              {isRoom && item.i.replace('room-', 'Room ')}
              {isEvent && item.i.replace('event-', 'Event ')}
            </div>
          );
        })}
      </SafeGridLayout>

      <style jsx>{`
        .info {
          background: #e8f5e9;
          border: 1px solid #4caf50;
          padding: 15px;
          margin-bottom: 20px;
          border-radius: 4px;
        }

        .info h3 {
          margin-top: 0;
          color: #2e7d32;
        }

        .info code {
          background: #fff;
          padding: 2px 6px;
          border-radius: 3px;
          font-size: 13px;
        }

        .grid-item {
          background: white;
          border: 1px solid #ddd;
          padding: 8px;
          font-size: 12px;
          overflow: hidden;
          display: flex;
          align-items: center;
          justify-content: center;
          text-align: center;
        }

        .grid-item.time-slot {
          background: #e3f2fd;
          border-color: #2196f3;
          font-weight: bold;
        }

        .grid-item.room {
          background: #f3e5f5;
          border-color: #9c27b0;
          font-weight: bold;
        }

        .grid-item.event {
          background: #fff3e0;
          border-color: #ff9800;
        }
      `}</style>
    </div>
  );
}

/**
 * Advanced example with multiple resource types
 */
export function AdvancedCalendarExample() {
  const layout = React.useMemo(() => {
    const layoutsById: LayoutsById = {};

    // Register time grid (30-minute intervals)
    const times = ['09:00', '09:30', '10:00', '10:30', '11:00', '11:30', '12:00'];
    times.forEach((time, index) => {
      layoutsById[`time-${time}`] = {
        i: `time-${time}`,
        x: 0,
        y: index,
        w: 2,
        h: 1,
        static: true,
      };
    });

    // Register multiple floors
    const floors = [
      { id: 'floor-1', name: '1F', x: 2, w: 6 },
      { id: 'floor-2', name: '2F', x: 8, w: 6 },
    ];
    floors.forEach(floor => {
      layoutsById[floor.id] = {
        i: floor.id,
        x: floor.x,
        y: 0,
        w: floor.w,
        h: 1,
        static: true,
      };
    });

    // Register rooms within floors
    const rooms = [
      { id: 'room-101', floorId: 'floor-1', x: 2, w: 3 },
      { id: 'room-102', floorId: 'floor-1', x: 5, w: 3 },
      { id: 'room-201', floorId: 'floor-2', x: 8, w: 3 },
      { id: 'room-202', floorId: 'floor-2', x: 11, w: 3 },
    ];
    rooms.forEach(room => {
      layoutsById[room.id] = {
        i: room.id,
        x: room.x,
        y: 1,
        w: room.w,
        h: 1,
        static: true,
      };
    });

    // Generate reservations with varying durations
    const reservations = [
      {
        id: 'reservation-1',
        roomId: 'room-101',
        startTime: '09:00',
        endTime: '10:30',
      },
      {
        id: 'reservation-2',
        roomId: 'room-102',
        startTime: '10:00',
        endTime: '11:00',
      },
      {
        id: 'reservation-3',
        roomId: 'room-201',
        startTime: '09:30',
        endTime: '12:00',
      },
    ];

    const reservationLayouts = reservations
      .map(reservation =>
        createTimedSpanLayout({
          id: reservation.id,
          baseLayoutKey: reservation.roomId,
          startKey: `time-${reservation.startTime}`,
          endKey: `time-${reservation.endTime}`,
          width: rooms.find(r => r.id === reservation.roomId)?.w || 3,
          layoutsById,
        })
      )
      .filter((layout): layout is Layout => layout !== null);

    return [
      ...times.map(time => layoutsById[`time-${time}`]),
      ...floors.map(floor => layoutsById[floor.id]),
      ...rooms.map(room => layoutsById[room.id]),
      ...reservationLayouts,
    ];
  }, []);

  const cols = React.useMemo(() => {
    const pointsX = layout.map(({ x, w }) => x + w);
    return Math.max(...pointsX, 12);
  }, [layout]);

  const gridWidth = cols * 24;

  return (
    <div style={{ padding: '20px' }}>
      <h1>Advanced Calendar Example</h1>

      <div className="features">
        <h3>Advanced Features:</h3>
        <ul>
          <li>Multiple floors and rooms</li>
          <li>30-minute time intervals</li>
          <li>Variable duration reservations</li>
          <li>Nested layout hierarchy</li>
        </ul>
      </div>

      <SafeGridLayout
        className="advanced-calendar"
        layout={layout}
        cols={cols}
        width={gridWidth}
        rowHeight={24}
        margin={[1, 1]}
        compactType={null}
        preventCollision={true}
        isDraggable={false}
        isResizable={false}
      >
        {layout.map(item => {
          const isTime = item.i.startsWith('time-');
          const isFloor = item.i.startsWith('floor-');
          const isRoom = item.i.startsWith('room-');
          const isReservation = item.i.startsWith('reservation-');

          let className = 'grid-item';
          let content = item.i;

          if (isTime) {
            className += ' time';
            content = item.i.replace('time-', '');
          } else if (isFloor) {
            className += ' floor';
            content = item.i.replace('floor-', 'Floor ');
          } else if (isRoom) {
            className += ' room';
            content = `Room ${item.i.replace('room-', '')}`;
          } else if (isReservation) {
            className += ' reservation';
            content = `Reserved (${item.h * 30}min)`;
          }

          return (
            <div key={item.i} className={className}>
              {content}
            </div>
          );
        })}
      </SafeGridLayout>

      <style jsx>{`
        .features {
          background: #fce4ec;
          border: 1px solid #e91e63;
          padding: 15px;
          margin-bottom: 20px;
          border-radius: 4px;
        }

        .features h3 {
          margin-top: 0;
          color: #c2185b;
        }

        .grid-item {
          background: white;
          border: 1px solid #ddd;
          padding: 6px;
          font-size: 11px;
          overflow: hidden;
          display: flex;
          align-items: center;
          justify-content: center;
          text-align: center;
        }

        .grid-item.time {
          background: #e3f2fd;
          border-color: #2196f3;
          font-weight: bold;
          font-size: 10px;
        }

        .grid-item.floor {
          background: #f3e5f5;
          border-color: #9c27b0;
          font-weight: bold;
        }

        .grid-item.room {
          background: #f5f5f5;
          border-color: #9e9e9e;
          font-weight: bold;
        }

        .grid-item.reservation {
          background: #ffecb3;
          border: 2px solid #ff9800;
          font-weight: bold;
        }
      `}</style>
    </div>
  );
}

/**
 * Usage:
 *
 * import { SimpleCalendarExample, AdvancedCalendarExample } from './examples/timed-layout';
 * import { createTimedSpanLayout } from './examples/timed-layout';
 *
 * // Simple usage
 * function App() {
 *   return <SimpleCalendarExample />;
 * }
 *
 * // Advanced usage
 * function App() {
 *   return <AdvancedCalendarExample />;
 * }
 *
 * // Custom implementation
 * function MyCalendar() {
 *   const layoutsById: LayoutsById = {};
 *   // ... register layouts ...
 *
 *   const eventLayout = createTimedSpanLayout({
 *     id: 'my-event',
 *     baseLayoutKey: 'my-room',
 *     startKey: 'time-09:00',
 *     endKey: 'time-11:00',
 *     width: 4,
 *     layoutsById,
 *   });
 * }
 */
