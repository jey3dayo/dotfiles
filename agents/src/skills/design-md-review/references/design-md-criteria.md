# Design MD Review Criteria

Use this reference when the base skill needs a more explicit decision table for reviewing an existing `DESIGN.md`.

## Core Baseline

Treat these sections as the default Stitch-oriented baseline:

1. `Visual Theme & Atmosphere`
2. `Color Palette & Roles`
3. `Typography Rules`
4. `Component Stylings`
5. `Layout Principles`

Optional sections can strengthen the file, but the absence of optional sections should not outweigh weakness in the core baseline.

## Review Labels

- `OK`: The section is present, specific, and reusable in prompts with minimal ambiguity.
- `要修正`: The section exists, but important details are vague, incomplete, or not very reusable.
- `不足`: The section is missing, too thin to be useful, or unusable for prompt-driven design generation.

## Checklist

### 1. Structure

### What good looks like

- The document is easy to scan.
- Core sections are clearly separated.
- Section names are stable enough that another model can find design guidance quickly.

### Mark `要修正` when

- Core sections are merged into one long narrative.
- Important guidance is buried in unrelated sections.
- The document contains repetition that obscures the actual rules.

### Mark `不足` when

- Two or more core sections are missing.
- The document reads like notes instead of a reusable design system.

### 2. Visual Theme & Atmosphere

### What good looks like

- The document describes mood, density, and visual philosophy in natural language.
- Adjectives are anchored to observable traits such as restraint, warmth, editorial feel, density, or motion.
- The section helps a model infer how a new page should feel, not only how the current page looks.

### Mark `要修正` when

- The section uses generic words such as "modern," "clean," or "professional" without evidence.
- The mood is described, but not tied to concrete visual cues.

### Mark `不足` when

- No atmosphere section exists.
- The section is too vague to influence generation.

### 3. Color Palette & Roles

### What good looks like

- Each important color has a descriptive semantic name.
- Each important color includes an exact `hex` value.
- Each important color has a role such as primary CTA, surface, border, headline, muted text, success, or alert.

### Mark `要修正` when

- `hex` values exist without functional roles.
- Roles exist without exact values.
- Too many colors are listed without hierarchy.

### Mark `不足` when

- The file only says "blue accent" or similar.
- The document omits core brand or UI colors entirely.

### 4. Typography Rules

### What good looks like

- The font family or families are named.
- The hierarchy explains headers, body, labels, and metadata.
- Weight, spacing, scale, or line-height tendencies are described.
- The section explains the visual character of typography, not only the family name.

### Mark `要修正` when

- The section lists fonts but not their usage.
- Hierarchy exists, but body and display behavior are unclear.

### Mark `不足` when

- Typography is absent or reduced to one sentence with no hierarchy.

### 5. Component Stylings

### What good looks like

- The file covers the most important reusable components such as buttons, cards, inputs, navigation, or equivalent domain-specific primitives.
- Shape, surface, stroke, spacing, and interaction behavior are described.
- Component descriptions are semantic enough to reuse on screens that do not yet exist.

### Mark `要修正` when

- The section covers only appearance, not behavior.
- The section covers only one component despite a broader system.
- It lists raw utility classes without translating them into visual meaning.

### Mark `不足` when

- Reusable components are not described at all.

### 6. Layout Principles

### What good looks like

- The file explains spacing philosophy, density, alignment, and grid behavior.
- The section clarifies whether the system is compact, airy, editorial, dashboard-like, or utility-first.
- Breakpoints or responsive tendencies are noted when they matter.

### Mark `要修正` when

- The section says "spacious" or "minimal" without explaining how that shows up in layout.
- Grid or alignment strategy is implied but not written down.

### Mark `不足` when

- No layout guidance exists.

### 7. Stitch Reusability

### What good looks like

- The file can be used as prompt context for new screens with little extra interpretation.
- Phrases are concrete enough to reuse directly in prompts.
- The document avoids overfitting to a single page while still staying visually specific.

### Mark `要修正` when

- The file is descriptive but not directive.
- It contains useful observations, but not reusable phrasing.

### Mark `不足` when

- The file is mostly implementation notes, token dumps, or copied CSS values.

## High-Signal Failure Patterns

- Tailwind classes appear without semantic translation.
- Multiple sections use empty adjectives like "premium," "clean," or "beautiful" without support.
- Colors lack priority, so a model cannot tell primary surfaces from accents.
- Typography lacks a visible hierarchy, causing generated screens to flatten.
- Components ignore states, producing brittle or lifeless generated UI.
- Layout guidance is missing, so generated screens drift away from the original density.

## Optional Sections

These are useful additions, especially for shared or distributed `DESIGN.md` files:

- `Depth & Elevation`
- `Responsive Behavior`
- `Do's and Don'ts`
- `Agent Prompt Guide`

Treat them as quality multipliers, not substitutes for weak core sections.

## Prioritization Rule

When summarizing fixes, prioritize in this order:

1. Missing or weak color role mapping
2. Missing reusable component descriptions
3. Missing layout principles
4. Weak atmosphere language
5. Weak typography hierarchy
6. Optional expansion sections

## Patch Guidance

When drafting text for a weak section:

- Reuse the document's current tone where possible.
- Add the smallest amount of text that makes the section reusable.
- Prefer short, dense paragraphs and focused bullets over long essays.
- Do not introduce new brand facts unless the user or source document supports them.
