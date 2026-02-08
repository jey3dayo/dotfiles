# Claude Code Use Cases

## Overview

このドキュメントは、Codex/GeminiからClaude Codeを呼び出すべき具体的なユースケースを詳細に説明します。

## 1. Creative Design & Ideation

### When to Use

- 新機能のコンセプト設計
- 複数の設計案のブレインストーミング
- 既存システムの再設計・リアーキテクチャ
- UI/UXのアイデア出し

### Example Scenarios

### Scenario 1: New Feature Conceptualization

```
User: "ユーザー管理機能を追加したい"
Codex: "これは創造的な設計が必要 → Claude Codeに委譲"

Subprocess call:
claude -p "Design user management feature.
Current system: {describe current architecture}
Requirements: CRUD operations, role-based access, audit logging
Output: 3-5 design alternatives with pros/cons" \
  --allowedTools "Read,Glob,Grep,Write" \
  --model sonnet \
  2>/dev/null > .claude/docs/design/user-management-design.md

Claude response:
- Design Alt 1: Monolithic approach (pros: simple, cons: tight coupling)
- Design Alt 2: Microservice (pros: scalable, cons: complexity)
- Design Alt 3: Plugin architecture (pros: flexible, cons: overhead)
```

### Scenario 2: Architectural Brainstorming

```
User: "この認証システムをスケーラブルにしたい"
Codex: "アーキテクチャ設計 → Claude Codeに委譲"

Subprocess call:
claude -p "Brainstorm scalable authentication architecture.
Current: Monolithic session-based auth
Target: Support 1M+ concurrent users
Constraints: Must maintain backward compatibility" \
  --allowedTools "Read,Glob,Grep,Write" \
  --model opus \
  2>/dev/null > .claude/docs/design/auth-scalability.md
```

### Success Criteria

- 複数の設計案が提示される
- それぞれのトレードオフが明確
- 実装への具体的な道筋が示される

## 2. Ambiguous Requirement Clarification

### When to Use

- ユーザーのリクエストが曖昧
- 複数の解釈が可能な要求
- ドメイン知識が不足している場合
- 要件定義の初期段階

### Example Scenarios

### Scenario 1: Vague User Request

```
User: "アプリを速くして"
Codex: "曖昧な要求 → Claude Codeに要件整理を依頼"

Subprocess call:
claude -p "User request: 'Make the app faster'
Current context: {describe current performance metrics}
Task: Identify possible interpretations and create clarifying questions." \
  --allowedTools "Read,Glob,Grep" \
  --model sonnet \
  2>/dev/null > .claude/docs/design/requirement-clarification.md

Claude response:
Possible interpretations:
1. UI response time improvement
2. API latency reduction
3. Database query optimization
4. Bundle size reduction

Clarifying questions:
- Which user action feels slow? (page load, form submission, search?)
- What is acceptable performance target? (< 100ms, < 1s?)
- Are there specific metrics you're monitoring?
```

### Scenario 2: Underspecified Feature

```
User: "エクスポート機能を追加"
Codex: "詳細不明 → Claude Codeに要件探索を依頼"

Subprocess call:
claude -p "User wants 'export functionality'
Context: {current data model}
Task: Explore possible export formats, scopes, and triggers" \
  --allowedTools "Read,Glob,Grep" \
  --model sonnet \
  2>/dev/null > .claude/docs/design/export-feature-exploration.md
```

### Success Criteria

- 曖昧さが特定される
- 明確化のための質問リストが作成される
- 可能な解釈がすべてリストアップされる

## 3. Design Exploration & Trade-off Analysis

### When to Use

- 技術選定の比較検討
- 設計パターンの選択
- パフォーマンスとメンテナンス性のトレードオフ
- 複数アプローチの評価

### Example Scenarios

### Scenario 1: Technology Selection

```
User: "状態管理ライブラリを選びたい"
Codex: "複数選択肢の比較 → Claude Codeに設計探索を依頼"

Subprocess call:
claude -p "Compare state management libraries for React.
Candidates: Redux, Zustand, Jotai, React Context
Criteria: Learning curve, bundle size, DevEx, ecosystem
Output: Comparison table with recommendations" \
  --allowedTools "Read,Glob,Grep" \
  --model sonnet \
  2>/dev/null > .claude/docs/design/state-management-comparison.md
```

### Scenario 2: Design Pattern Selection

```
User: "データフェッチングのパターンを決めたい"
Codex: "設計パターン比較 → Claude Code"

Subprocess call:
claude -p "Compare data fetching patterns.
Options: REST, GraphQL, tRPC, Server Components
Context: Next.js 14 app, TypeScript
Trade-offs: Type safety, cache control, developer experience" \
  --allowedTools "Read,Glob,Grep,Write" \
  --model sonnet \
  2>/dev/null > .claude/docs/design/data-fetching-patterns.md
```

### Success Criteria

- 各選択肢のメリット・デメリットが明確
- 具体的な評価基準に基づく比較
- プロジェクトコンテキストに即した推奨

## 4. Fast Bulk File Operations

### When to Use

- 複数ファイルの一括編集
- プロジェクト全体のリファクタリング
- 一括リネーム・移動
- コードベース全体のパターン適用

### Example Scenarios

### Scenario 1: Bulk Refactoring

```
User: "すべてのコンポーネントでpropsの型定義を統一したい"
Codex: "一括編集 → Claude Code"

Subprocess call:
claude -p "Bulk refactor: Unify props type definitions.
Pattern: Convert inline types to interface definitions
Target: All *.tsx files in src/components/
Safety: Create backup, preview changes before applying" \
  --allowedTools "Read,Write,Edit,Glob,Grep,Bash" \
  --model sonnet \
  2>/dev/null > .claude/docs/design/bulk-props-refactor.md
```

### Scenario 2: Mass File Organization

```
User: "テストファイルを__tests__ディレクトリに移動"
Codex: "ファイル移動 → Claude Code"

Subprocess call:
claude -p "Reorganize test files.
Current: *.test.ts files scattered in src/
Target: Move to __tests__/ directories
Update: Import paths in all affected files" \
  --allowedTools "Read,Write,Edit,Glob,Grep,Bash" \
  --model sonnet \
  2>/dev/null > .claude/docs/design/test-file-reorganization.md
```

### Success Criteria

- すべての対象ファイルが処理される
- 変更前のバックアップが作成される
- 変更の妥当性が検証される

## 5. Interactive Design Dialogue

### When to Use

- 設計の詳細を段階的に詰める必要がある
- ユーザーのフィードバックを得ながら進める
- 複数の設計判断が相互依存している
- 探索的な設計プロセス

### Example Scenarios

### Scenario 1: Progressive Design Refinement

```
User: "ダッシュボードを設計したい"
Codex: "対話的設計 → Claude Code（対話モード推奨）"

Interactive subprocess:
# 初回：全体構造を提案
claude -p "Design dashboard structure.
Users: Admin, Manager, Viewer
Features: Analytics, Reports, Settings" \
  --model sonnet \
  2>/dev/null > .claude/docs/design/dashboard-v1.md

# ユーザーフィードバック後：詳細設計
claude -p "Refine dashboard based on feedback:
- Prefer card-based layout
- Analytics should be primary view
- Need real-time data updates
Detail: Component structure, data flow, update strategy" \
  --model sonnet \
  2>/dev/null > .claude/docs/design/dashboard-v2.md
```

### Scenario 2: Constraint-Based Exploration

```
User: "API設計、でも制約がいくつかある"
Codex: "段階的な制約適用 → Claude Code"

Subprocess:
claude -p "Design REST API with progressive constraints.
Base: CRUD for User, Post, Comment
Constraint 1: Must support pagination
Constraint 2: Need filtering by date range
Constraint 3: Rate limiting required
Output: API spec adapting to each constraint" \
  --model opus \
  2>/dev/null > .claude/docs/design/api-design-constrained.md
```

### Success Criteria

- 段階的に設計が洗練される
- 各フィードバックループで改善が見られる
- 最終設計が要件を完全に満たす

## Anti-Patterns (When NOT to Use Claude Code)

### ❌ Anti-Pattern 1: Simple Bug Fixes

```
BAD:
User: "このループにバグがある"
Codex: "Claude Codeに委譲" ❌

GOOD:
Codex: "バグ修正 → Codex自身で対応" ✓
```

### ❌ Anti-Pattern 2: Code Implementation

```
BAD:
User: "ログイン機能を実装して"
Codex: "Claude Codeに委譲" ❌

GOOD:
Codex: "実装タスク → Codex自身で実装" ✓
（設計が必要な場合のみClaude Codeに相談）
```

### ❌ Anti-Pattern 3: Research Tasks

```
BAD:
User: "最新のReactベストプラクティスを調べて"
Codex: "Claude Codeに委譲" ❌

GOOD:
Codex: "リサーチタスク → Geminiに委譲" ✓
```

### ❌ Anti-Pattern 4: Deep Reasoning

```
BAD:
User: "このアルゴリズムの時間計算量を解析して"
Codex: "Claude Codeに委譲" ❌

GOOD:
Codex: "論理的推論 → Codex自身で分析" ✓
```

## Integration Workflow

```
┌─────────────────────────────────────────────────────────────┐
│ User Request                                                 │
└───────────────┬─────────────────────────────────────────────┘
                │
                ▼
┌───────────────────────────────────────────────────────────────┐
│ Codex/Gemini: Request Classification                          │
│ - Design/Ideation? → Claude Code                              │
│ - Reasoning/Implementation? → Codex                            │
│ - Research/Multimodal? → Gemini                               │
└───────────────┬───────────────────────────────────────────────┘
                │
                ▼ (if Design/Ideation)
┌───────────────────────────────────────────────────────────────┐
│ Subprocess: Claude Code                                       │
│ - Interactive design exploration                              │
│ - Save artifacts to .claude/docs/design/                      │
│ - Return key insights                                         │
└───────────────┬───────────────────────────────────────────────┘
                │
                ▼
┌───────────────────────────────────────────────────────────────┐
│ Codex/Gemini: Receive Summary                                 │
│ - Extract design decisions                                    │
│ - Report to user in Japanese                                  │
│ - Proceed with implementation (if applicable)                 │
└───────────────────────────────────────────────────────────────┘
```

## Best Practices

1. **Clear task description**: 具体的なコンテキストと制約を含める
2. **Appropriate tool restrictions**: 必要最小限の`--allowedTools`を指定
3. **Model selection**: Haiku (quick), Sonnet (standard), Opus (complex)
4. **Artifact preservation**: 設計ドキュメントを`.claude/docs/design/`に保存
5. **Subprocess isolation**: メインプロセスのコンテキスト汚染を避ける
