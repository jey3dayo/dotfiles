---
name: task-router
description: Intelligent task router with multi-layer analysis and automatic agent selection. Analyzes natural language requests, selects optimal agents, and orchestrates execution. Use when user provides task descriptions like "review this code" or "improve performance".
argument-hint: <task-description> [--interactive] [--dry-run] [--verbose] [--deep-think]
disable-model-invocation: false
user-invocable: true
context: fork
agent: general-purpose
allowed-tools: Task, Read, Grep, Glob, WebFetch
---

# Task Router - インテリジェント・タスク・ルーター

自然言語でタスクを指定すると、最適なエージェントを自動選択して実行する次世代統合システムです。

## 🎯 Core Mission

自然言語タスクを解析し、プロジェクトコンテキストを理解した上で、最適なエージェント・コマンド・ツールチェーンを選択・実行し、実用的な成果を提供する。

## 🔧 Enhanced Integration Framework

このスキルは統合フレームワークを使用して、以下の高度な機能を提供します。

### 4つのコアコンポーネント

1. **統合オーケストレーター**: 全システムコンポーネントの協調動作
2. **強化されたタスクルーター**: 機械学習ベースの最適エージェント選択
3. **標準化インターフェース**: エージェント・コマンド間の seamless な連携
4. **自動エラー回復**: 高度なエラー処理と回復戦略

### 実装された機能

1. **深層自然言語解析**: 多層的なタスク意図理解
2. **動的コンテキスト統合**: プロジェクト・履歴・環境の総合判断
3. **インテリジェントルーティング**: 確信度ベースの最適選択
4. **実行結果の最適化**: メトリクス駆動の継続改善

## 📋 4 Phase Task Processing

### Phase 1: Multi-Layer Task Analysis

タスクを複数の観点から分析し、実行戦略を決定します。

#### 3層分析システム

1. **Semantic Layer** (意味理解)

   - 9種類の意図タイプ分類: error, implement, fix, analyze, review, github_pr, refactor, navigate, docs
   - タスク構造の分解
   - 実行可能な単位への変換

2. **Intent Layer** (意図分析)

   - 主要意図と副次的意図の抽出
   - キーワードベースの確信度スコアリング
   - タスクカテゴリの決定

3. **Structural Layer** (構造分解)
   - ターゲット、制約、スコープの特定
   - 依存関係の分析
   - 複雑度計算 (0.8以下: 単純、0.8以上: 複雑)

#### Task Analysis Report

```markdown
🎯 **Task Analysis Report**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 **Original Request**: "ユーザー認証を実装"
🔍 **Interpreted Intent**: implement
🎯 **Task Category**: implementation
📊 **Complexity**: complex (0.85)
⏱️ **Estimated Time**: 2-4hr
📚 **Referenced Libraries**: express, passport, bcrypt
🔧 **Required Capabilities**: implementation, testing, security

**Decomposed Actions**:

1. Setup authentication middleware
2. Implement user registration
3. Add password hashing
4. Create login endpoint
5. Add JWT token generation
```

**詳細**: [Phase 1-4詳細フロー](references/processing-architecture.md)を参照

### Phase 2: Dynamic Context Integration

プロジェクト情報と実行履歴を統合して最適な実行戦略を決定します。

#### 統合される情報

- **プロジェクト情報**: タイプ、技術スタック、構造、規約
- **実行履歴**: 類似タスクの成功率、平均時間、推奨エージェント
- **環境情報**: リソース制約、利用可能なツール
- **ライブラリドキュメント**: Context7による最新API情報

#### Context7統合

タスク内のライブラリ参照を自動検出し、最新のドキュメントを取得します。

```python
# 自動的なライブラリ検出
detected_libraries = detect_library_references(task_description)
# "React Hooks", "Next.js", "TypeScript" など

# ドキュメント強化
context = enhance_context_with_docs(context, detected_libraries)
# context.documentation に最新API情報が追加される
```

**詳細**: [Dynamic Context Integration](references/processing-architecture.md#phase-2-dynamic-context-integration)

### Phase 3: Intelligent Agent Selection

確信度ベースの多段階エージェント選択を行います。

#### 選択プロセス

1. **意図分析**: タスクの主要意図と副次的意図を抽出
2. **能力マッチング**: エージェント能力マトリックスと照合
3. **確信度スコアリング**: 0.0-1.0のスコア計算
4. **Context7調整**: ライブラリドキュメント有無で±10%調整
5. **実行戦略決定**: 単一 or 複数エージェント

#### エージェント能力マトリックス

| エージェント       | 主要能力               | 品質       | 速度       | 最適用途                 |
| ------------------ | ---------------------- | ---------- | ---------- | ------------------------ |
| error-fixer        | エラー修正、型安全性   | ⭐⭐⭐⭐⭐ | ⚡⚡⚡⚡   | 型エラー、lint修正       |
| orchestrator       | 実装、リファクタリング | ⭐⭐⭐⭐⭐ | ⚡⚡⚡     | 新機能、大規模変更       |
| code-reviewer      | レビュー、品質評価     | ⭐⭐⭐⭐⭐ | ⚡⚡⚡⚡   | コード品質、セキュリティ |
| researcher         | 調査、分析             | ⭐⭐⭐⭐⭐ | ⚡⚡⚡     | 問題究明、技術調査       |
| github-pr-reviewer | PRレビュー             | ⭐⭐⭐⭐⭐ | ⚡⚡⚡⚡   | GitHub PR専門            |
| docs-manager       | ドキュメント管理       | ⭐⭐⭐⭐   | ⚡⚡⚡⚡⚡ | リンク検証、更新         |
| serena             | セマンティック分析     | ⭐⭐⭐⭐⭐ | ⚡⚡⚡⚡⚡ | シンボル検索、影響分析   |

**詳細**:

- [エージェント詳細プロファイル](references/agent-profiles.md)
- [選択アルゴリズム](references/agent-selection-logic.md)

### Phase 4: Execution & Optimization

実行とリアルタイムの最適化を行います。

#### 実行フロー

1. **実行計画の表示**: 戦略、エージェント、確信度、推定時間
2. **メトリクス初期化**: 開始時刻、ステータス
3. **Context7ドキュメントの適用**: エージェントにライブラリ情報を提供
4. **エージェントベース実行**: 必ずエージェントを使用して実行
5. **結果の強化**: 品質スコア計算、メトリクス更新
6. **コンテキストの永続化**: 学習システムへの記録

#### 実行戦略

- **単純タスク** (複雑度 < 0.8): 単一エージェントで実行
- **複雑タスク** (複雑度 ≥ 0.8): 複数エージェントによる協調実行

```markdown
🚀 **Task Execution Plan** (Agent-Based)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 **Strategy**: single_agent
🤖 **Primary Agent**: orchestrator
🎯 **Confidence**: 92.5%
⏱️ **Estimated Time**: 2-3hr
📚 **Library Docs**: express, passport, bcrypt
```

**詳細**: [Execution & Optimization](references/processing-architecture.md#phase-4-execution--optimization)

## 🧠 Deep Thinking Mode

複雑な技術判断が必要なタスクでは、Deep Thinking モードを有効化します。

### 有効化方法

```bash
/task --deep-think "複雑な技術判断が必要なタスク"
/task --thinking "なぜこのエラーが発生するか調査"
```

### 焦点領域の自動決定

タスクの内容から以下の焦点領域を自動的に決定します。

- **root_cause_analysis**: 「なぜ」「原因」「理由」を含む場合
- **design_decisions**: 「設計」「アーキテクチャ」「パターン」を含む場合
- **optimization_strategies**: 「最適」「改善」「パフォーマンス」を含む場合
- **implementation_strategies**: 「実装」「方法」「アプローチ」を含む場合

## 🎯 Usage Examples

### Basic Usage

```bash
# 自然言語でタスク指定
/task "このコードをレビューして品質を確認"
/task "ユーザー認証機能を実装"
/task "パフォーマンスを改善"
/task "ドキュメントのリンクを修正"

# Git/ブランチ関連のレビュー
/task "origin/developでレビューして"
/task "origin/mainとの差分をレビュー"
```

### Advanced Usage

```bash
# 複雑なマルチステップタスク
/task "新機能を実装してテストを書いてドキュメントも更新"

# 制約付きタスク
/task "Go言語でClean Architectureに従ってREST APIを実装"

# 分析タスク
/task "なぜこのテストが失敗するのか原因を調査して修正案を提示"

# セマンティック分析タスク
/task "AuthServiceインターフェースの全ての実装を見つけて"
/task "getUserByIdメソッドを呼び出している全ての場所を探して"
```

### Context7統合によるライブラリドキュメント活用

```bash
/task "React HooksのuseStateとuseEffectの使い方を教えて"
/task "Next.js 14のApp Routerでデータフェッチングを実装"
/task "TypeScriptでジェネリック型を使った関数を実装"
/task "Tailwind CSSでレスポンシブデザインを適用"
```

### Interactive Mode

```bash
# 対話的実行
/task --interactive "複雑な問題を解決"

# ドライラン
/task --dry-run "大規模リファクタリング"

# 詳細ログ付き実行
/task --verbose "パフォーマンス最適化"
```

**詳細**: [使用パターン集](examples/usage-patterns.md)

## 📊 Continuous Learning System

タスク実行から学習し、将来の精度を向上させるシステムです。

### 記録される情報

- タスクID、意図、プロジェクトタイプ
- 使用されたエージェント
- 実行メトリクス (時間、品質スコア、リソース使用量)
- 実行結果 (成功/失敗)

### 生成される推奨事項

類似タスクから以下を生成します。

- **成功率**: 同様のタスクの成功確率
- **期待時間**: 平均実行時間
- **推奨エージェント**: 最も高いパフォーマンスを示したエージェント

```markdown
## 🧠 Learning Insights

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
**Pattern Detected**: "実装" tasks in Go projects
**Success Rate**: 87% (35/40 executions)
**Average Time**: 18m (±5m)

**Recommendations**:

- Use 'researcher' agent (95% success)
- Include Clean Architecture context
- Pre-load project conventions
```

## 🔄 Integration Points

### 統合フレームワーク

- **integration-framework**: TaskContext標準化、Communication Busパターン
- **agents-only**: エージェント選択ロジックと能力マトリックス
- **mcp-tools**: Context7やその他MCPサーバー統合

### コマンド統合

- **TodoWrite**: 実行後のフォローアップタスクを自動追加
- **Learnings**: 実行から得られた知見を自動記録
- **Review**: 実装タスク完了後の自動レビュー起動

### 技術スタック別スキル (自動検出)

| 検出条件               | スキル            | 提供内容                                           |
| ---------------------- | ----------------- | -------------------------------------------------- |
| TypeScriptプロジェクト | typescript        | 型安全性、any型排除、Result<T,E>パターン           |
| Reactプロジェクト      | react             | コンポーネント設計、Hooks、パフォーマンス最適化    |
| Go言語プロジェクト     | golang            | イディオマティックGo、エラーハンドリング、並行処理 |
| API/バックエンド       | security          | OWASP Top 10、入力検証、認証・認可                 |
| セマンティック解析必要 | semantic-analysis | シンボル検索、影響分析、依存関係追跡               |

**詳細**: [スキル統合ガイド](references/skill-integration-guide.md)

## 📁 Reference Documentation

### アーキテクチャ詳細

- [処理アーキテクチャ詳細](references/processing-architecture.md) - 4 Phase詳細フロー
- [エージェント選択ロジック](references/agent-selection-logic.md) - 多層分析アルゴリズム

### エージェントとスキル

- [エージェント詳細プロファイル](references/agent-profiles.md) - 能力マトリックス詳細
- [スキル統合ガイド](references/skill-integration-guide.md) - 自動統合パターン

### 実用例とエラー処理

- [使用パターン集](examples/usage-patterns.md) - 実用的な使用例
- [エラー回復戦略](examples/error-recovery-strategies.md) - エラーハンドリング詳細

## 🎯 目標

エージェントの存在を意識することなく、自然な言葉でどんな開発タスクでも実行できる、真のインテリジェント開発アシスタント
