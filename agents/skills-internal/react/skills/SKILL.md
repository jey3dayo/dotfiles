---
name: react
description: |
  [What] Specialized skill for reviewing React projects. Evaluates component design, Hooks usage, performance optimization, and accessibility. Provides assessment of component architecture, proper Hooks patterns, re-rendering optimization, and a11y compliance
  [When] Use when: users mention "React", "React component", "Hooks", "useState", "useEffect", "JSX", work with .jsx/.tsx files, or discuss React patterns and performance
  [Keywords] React, React component, Hooks, useState, useEffect, JSX
---

# React Project Review

## Overview

This skill provides specialized review guidance for React projects, focusing on component design, Hooks best practices, performance optimization, and accessibility. **For generic React documentation, this skill delegates to Context7 MCP** (`/websites/18_react_dev`). This document contains **project-specific evaluation criteria** and **agent integration patterns**.

## Context7 Integration

### React Documentation Queries

Use Context7 MCP for generic React documentation instead of maintaining static documentation:

```typescript
// Component design patterns
context7.query(
  "/websites/18_react_dev",
  "component composition patterns single responsibility",
);

// Hooks usage and patterns
context7.query(
  "/websites/18_react_dev",
  "useState useEffect dependency arrays cleanup functions",
);

// Custom Hooks
context7.query(
  "/websites/18_react_dev",
  "custom hooks best practices reusable logic",
);

// Performance optimization
context7.query(
  "/websites/18_react_dev",
  "React.memo useMemo useCallback optimization",
);

// Accessibility
context7.query(
  "/websites/18_react_dev",
  "semantic HTML ARIA keyboard navigation a11y",
);

// Form handling
context7.query(
  "/websites/18_react_dev",
  "controlled uncontrolled forms validation",
);

// Error handling
context7.query(
  "/websites/18_react_dev",
  "Error Boundary error handling async operations",
);
```

### Available Context7 React Libraries

- `/websites/18_react_dev` (recommended, 3921 snippets, score: 82.6)
- `/websites/react_dev` (4359 snippets, score: 74.5)
- `/reactjs/react.dev` (official, 3742 snippets, score: 70.5)

## Project-Specific Evaluation Criteria (⭐️ 5-Star System)

### Component Design

### Hooks Usage

### Performance

### Accessibility

## Review Workflow

1. Component structure (Context7: "component composition patterns") 2. Hooks patterns (Context7: "useEffect dependency arrays") 3. Performance (Context7: "React.memo optimization") 4. Accessibility (Context7: "semantic HTML ARIA") 5. Forms (Context7: "controlled forms") 6. Error handling (Context7: "Error Boundary") 7. Testing 8. Bundle size

## Common Issues (Project-Specific)

### Component Design

### Hooks

### Performance

### Accessibility

## 🤖 Agent Integration

### Code-Reviewer

### 自動ロード条件

### 統合例

## Related Skills

### typescript
