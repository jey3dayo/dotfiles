---
name: typescript
description: |
  [What] Specialized skill for reviewing TypeScript projects. Evaluates type safety, TypeScript best practices, type definitions, and compiler options. Provides detailed assessment of any type usage, type assertions, strict mode compliance, and performance considerations
  [When] Use when: users mention "TypeScript", "TS", "type checking", "type safety", "type error", work with .ts/.tsx files or tsconfig.json, or discuss TypeScript compilation issues
  [Keywords] TypeScript, TS, type checking, type safety, type error
---

# TypeScript Project Review

## Overview

This skill provides specialized review guidance for TypeScript projects, focusing on type safety, best practices, and effective use of TypeScript's type system. It orchestrates Context7 MCP for generic TypeScript documentation while enforcing project-specific type safety policies.

## Context7 Integration

### Generic TypeScript Documentation

Delegate generic TypeScript questions to Context7 MCP with library ID `/websites/typescriptlang` or `/microsoft/typescript`:

**Type Guards and Unknown**:

```
Query: "TypeScript type guards unknown types implementation"
Result: typeof, instanceof, user-defined type predicates
```

**Generics and Constraints**:

```
Query: "TypeScript generics type constraints examples"
Result: Generic type parameters, extends keyword, default types
```

**Union and Intersection Types**:

```
Query: "TypeScript discriminated unions intersection types"
Result: Union type narrowing, tagged unions, type composition
```

**Utility Types**:

```
Query: "TypeScript utility types Partial Pick Omit Record"
Result: Built-in utility types for type transformations
```

**tsconfig.json Options**:

```
Query: "TypeScript strict mode compiler options configuration"
Result: strict, noImplicitAny, strictNullChecks, etc.
```

**Performance Optimization**:

```
Query: "TypeScript compilation performance bundle size optimization"
Result: type-only imports, tree shaking, build performance
```

### When to Use Context7

- ✅ Generic TypeScript syntax and features
- ✅ Compiler options explanations
- ✅ Built-in utility types
- ✅ Standard type patterns
- ❌ Project-specific type safety policies (see below)
- ❌ Code review criteria (see below)

## Project-Specific Type Safety Policy

### Zero-Any Policy

**Goal**: Eliminate all `any` types from codebase

**Strategies**: Replace `any` with `unknown` + type guards, use type inference, define explicit interfaces, implement user-defined type guards

**Justification Required**: If `any` is truly necessary, document why

### Result Type Pattern (Recommended)

**Pattern**: `type Result<T, E> = { success: true; data: T } | { success: false; error: E };`

**Benefits**: Type-safe error handling, explicit success/failure states, no exception throwing, composable discriminated unions

### Type Assertion Guidelines

**Minimize**: Avoid `as` type assertions whenever possible

**Prefer**: Type guards and type narrowing (`data is Type` predicates)

### Strict Mode Compliance

**Required**: `strict: true`, `noImplicitAny: true`, `strictNullChecks: true` in tsconfig.json

**Verification**: Check tsconfig.json compilerOptions, scan codebase for `any` types

## ⭐️ 5-Star Evaluation Criteria

### Type Safety Assessment

**⭐⭐⭐⭐⭐ (5/5) Excellent**: Zero `any`, minimal type assertions, active type guards, full strict mode, Result<T,E> pattern

**⭐⭐⭐⭐☆ (4/5) Good**: Rare justified `any`, controlled assertions, good type guard coverage, most strict flags enabled

**⭐⭐⭐☆☆ (3/5) Standard**: Some `any` usage, moderate assertions, basic type guards, partial strict mode

**⭐⭐☆☆☆ (2/5) Needs Improvement**: Frequent `any`, heavy assertion reliance, missing type guards, strict mode not enabled

**⭐☆☆☆☆ (1/5) Requires Overhaul**: Pervasive `any`, type system circumvented, no type guards, minimal TypeScript benefit

### Type Definition Quality

Interface design clarity, generic usage appropriateness, type reusability, documentation completeness, discriminated union patterns

### Compiler Utilization

Strict mode configuration, compiler options, build configuration, ESLint + TypeScript integration

## Review Workflow

When reviewing TypeScript code:

1. **Check tsconfig.json**: Verify strict mode and compiler options
2. **Scan for `any`**: Identify and eliminate `any` type usage
3. **Review type assertions**: Minimize and justify all assertions
4. **Evaluate type definitions**: Assess interfaces, types, and generics
5. **Check error handling**: Verify Result<T,E> pattern or type-safe alternatives
6. **Test type narrowing**: Ensure proper type guards
7. **Verify tool integration**: Check ESLint and TypeScript alignment
8. **Assess performance**: Consider compilation and bundle impact

## 🤖 Agent Integration

このスキルはTypeScriptプロジェクトを扱うエージェントに専門知識を提供します:

### Error-Fixer Agent

- **提供内容**: TypeScript型エラー修正、any型排除戦略、strictモード対応
- **タイミング**: TypeScriptエラー修正・型安全性向上時
- **コンテキスト**: 型エラー自動修正、any→unknown変換、型ガード実装、tsconfig.json最適化

### Code-Reviewer Agent

- **提供内容**: TypeScript型安全性評価基準、ベストプラクティス
- **タイミング**: TypeScriptコードレビュー時
- **コンテキスト**: ⭐️5段階評価、型アサーション評価、Result<T,E>パターン、パフォーマンス影響

### Orchestrator Agent

- **提供内容**: TypeScriptプロジェクト構成、アーキテクチャパターン
- **タイミング**: TypeScript機能実装・リファクタリング時
- **コンテキスト**: モジュール構成、型定義ファイル管理、コンパイラオプション設定

### 自動ロード条件

- "TypeScript"、"TS"、"型エラー"、"型安全性"に言及
- .ts、.tsx、tsconfig.jsonファイル操作時
- TypeScriptコンパイルエラー対応時
- プロジェクト検出: TypeScriptプロジェクト

**統合例**:

```
ユーザー: "TypeScriptの型エラーを修正してany型を排除"
    ↓
TaskContext作成
    ↓
プロジェクト検出: TypeScript + React
    ↓
スキル自動ロード: typescript, react
    ↓
Context7クエリ: 型ガード実装パターン
    ↓
エージェント選択: error-fixer
    ↓ (スキルコンテキスト提供)
TypeScript型エラー修正パターン + any型排除戦略
    ↓
実行完了（型安全性向上、strictモード準拠）
```

## Integration with Related Skills

- **react skill**: For React + TypeScript projects
- **clean-architecture skill**: For TypeScript architecture patterns
- **security skill**: For type-safe security implementations
