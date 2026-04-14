---
name: refactoring
description: |
  [What] Integrated refactoring workflow for TypeScript/JavaScript/React code.
  Combines similarity-ts (duplicate detection) and react-doctor (React
  diagnostics) for incremental quality improvement. Orchestrator that works
  with code-quality-improvement (ESLint/type safety fixes) and tsr (dead code
  removal).
  [When] Use when: "リファクタ", "refactor", "重複コード", "コード整理",
  "clean up", "duplicate code", "react-doctor", "similarity",
  "コードの品質を改善", "コードを綺麗に", "リファクタリング計画",
  "デッドコード削除", "未使用ファイル", "未使用 export", or cleanup-only
  plans are mentioned. Do not use for feature implementation or task
  execution; use implementation-engine instead.
  [Keywords] refactor, cleanup, dead code, unused files, unused exports,
  similarity, react-doctor, tsr, code quality
---

# Refactoring - Integrated TypeScript/JavaScript/React Refactoring Workflow

An orchestrator skill that combines `similarity-ts` (duplicate code detection) and `react-doctor` (React diagnostics) to incrementally improve code quality.

## 🎯 Core Mission

Integrate multiple specialized skills (`similarity`, `react-doctor`, `code-quality-improvement`, `tsr`) to create and execute an optimal refactoring plan based on project type.

## 🏗️ Prerequisites: Project Type Detection

```bash
# Detect React project (check if package.json contains "react")
cat package.json | grep '"react"'

# Detect TypeScript project
ls tsconfig.json 2>/dev/null && echo "TypeScript project"
```

| Project Type              | Tools to Run                       |
| ------------------------- | ---------------------------------- |
| React + TypeScript/JS     | react-doctor + similarity-ts + tsr |
| TypeScript/JS (non-React) | similarity-ts + tsr                |

---

## 📋 3-Phase Workflow

### Phase 1: Diagnose

#### 1-A: React Project Diagnostics

```bash
# Run only if package.json contains "react"
npx -y react-doctor@latest . --verbose
```

Save output to `/tmp/react-doctor-report.txt` for analysis.

#### 1-B: Duplicate Code Detection (All TS/JS Projects)

```bash
# Scan at 90%+ similarity (start with severe duplicates)
similarity-ts --threshold 0.9 . > /tmp/similarity-report.md

# Check for duplicate type definitions (optional)
similarity-ts --types --threshold 0.95 src/types/ >> /tmp/similarity-report.md
```

For detailed usage, refer to `../similarity/skills/SKILL.md`.

---

### Phase 2: Analyze & Plan

Classify diagnostic results using the following priority matrix.

#### Priority Matrix

| Priority    | Condition                                  | Action                          |
| ----------- | ------------------------------------------ | ------------------------------- |
| 🔴 Critical | react-doctor errors AND similarity 95%+    | Fix immediately (this session)  |
| 🟡 High     | react-doctor warnings OR similarity 90-95% | Plan fix (high priority)        |
| 🟢 Low      | similarity 87-90% (default threshold)      | Future candidate (needs review) |

#### Plan Output Format

```markdown
## Refactoring Plan

### Diagnostics Summary

- react-doctor score: XX/100 (75+ = Great, 50-74 = Needs work, 0-49 = Critical)
- Duplicate code pairs: XX (95%+: X pairs, 90-95%: X pairs)

### Priority Actions

1. 🔴 [Critical] react-doctor error: <description> → <fix approach>
2. 🔴 [Critical] Duplicate 95%+: <file1> ↔ <file2> → Extract common function
3. 🟡 [High] react-doctor warning: <description> → <fix approach>
4. 🟡 [High] Duplicate 90-95%: <file1> ↔ <file2> → Review pattern

### Estimated Scope

- Immediate fixes: X items
- Planned fixes: X items
- Future candidates: X items
```

---

### Phase 3: Execute

#### 3-1: Fix react-doctor Errors

Fix react-doctor errors first (highest severity).

```
Error Type → Fix Approach:
- Architecture: components inside components → Move components to top level
- State & Effects: useState from props → Change to proper state management
- Security: hardcoded secrets → Migrate to environment variables
- Bundle Size: barrel imports → Change to direct imports
- Next.js: missing metadata → Add metadata export
```

For react-doctor skill details, refer to `../react-doctor/SKILL.md` (if it exists).

#### 3-2: Consolidate Duplicate Code at 95%+

```typescript
// Pattern 1: Simple function extraction
// Before: 98% similar functions in 2 files
// After: Extract to common utils and import from both files

// Pattern 2: Generalization
// Before: getUserById / getAdminById (94% similar)
// After: Consolidate into findByIdOrThrow<T>(model, id, resourceName)

// Pattern 3: Extract common interface
// Before: Multiple similar type definitions
// After: Base type + extends to centralize common parts
```

For similarity skill details, refer to `../similarity/skills/SKILL.md`.

#### 3-3: Fix ESLint/Type Safety Issues

Fix remaining code quality issues after deduplication.

```bash
# Attempt auto-fix
pnpm lint:fix

# Check remaining errors
pnpm lint 2>&1 | tail -20
```

For complex type safety issues (any-type elimination, Result<T,E> patterns), delegate to `../code-quality-improvement/SKILL.md`.

#### 3-4: Remove Dead Code

Remove code that becomes unused after refactoring.

```bash
# Detect dead code
pnpm tsr:check > /tmp/tsr-report.txt

# Review report, then remove incrementally
pnpm tsr:fix
```

For tsr skill details, refer to `../tsr/SKILL.md`.

#### 3-5: Verification (Required)

### Run after every fix step

```bash
pnpm type-check && pnpm lint && pnpm test
```

Do not proceed to the next phase until all pass.

---

## 🔄 Skill Delegation

| Problem Area                      | Delegated Skill                        |
| --------------------------------- | -------------------------------------- |
| Detailed duplicate code analysis  | `../similarity/skills/SKILL.md`        |
| ESLint errors / type safety       | `../code-quality-improvement/SKILL.md` |
| Dead code removal                 | `../tsr/SKILL.md`                      |
| React-specific pattern diagnosis  | `../react-doctor/SKILL.md` (if exists) |
| Impact scope / reference tracking | MCP Serena: `find_referencing_symbols` |

---

## ⚠️ Important Notes

### Principle of Incremental Execution

1. Do not make large-scale changes at once: Start with similarity 95%+, stop at 90-95% in the planning phase
2. Commit between phases: After each phase, run `git commit` to keep rollback possible
3. Verify business logic: High similarity ≠ must consolidate (may have different semantics)

### Integration with MCP Serena

```bash
# Check impact scope before consolidation
# Use mcp__serena__find_referencing_symbols to identify callers
# Use mcp__serena__find_symbol to check implementation details
```

### Thorough Verification

```bash
# Before fixes: backup with git stash or branch
# After fixes: always run type-check + lint + test
pnpm type-check && pnpm lint && pnpm test
```

---

## 🎯 Expected Outcomes

- Reduced code duplication (goal: zero similarity 90%+ pairs)
- Improved react-doctor score (goal: 75+)
- Leaner codebase through dead code removal
- Improved type safety (0 type errors, 0 ESLint violations)
