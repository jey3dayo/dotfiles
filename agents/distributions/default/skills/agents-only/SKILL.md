---
name: agents-only
description: Agent selection framework with capability matrix and task classification. Use when routing tasks, selecting optimal agents, or understanding agent capabilities. Focuses exclusively on agent orchestration via Task tool.
disable-model-invocation: false
user-invocable: false
---

# Agents - エージェント選択フレームワーク

タスクの意図とコンテキストに基づいて最適なエージェントを選択するフレームワークです。Task toolによるエージェント起動に特化しています。

## 🎯 Purpose

- **タスクルーティング**: 意図分析に基づく自動エージェント選択
- **能力マトリックス**: 7エージェントの能力定義と評価基準
- **スキル統合**: 技術スタック検出と関連スキル提案
- **Context7連携**: ライブラリドキュメント活用によるスコア最適化

## 🚀 Quick Reference

### 主要関数

#### select_optimal_agent(task_description, context=None)

タスクに最適なエージェントと起動すべきSkillsを返します。

```python
result = select_optimal_agent("Refactor TypeScript React app", context)
# {
#   "agent_type": "orchestrator",
#   "task_type": "implementation",
#   "skills": [
#     {"name": "typescript", "confidence": 0.86, ...},
#     {"name": "react", "confidence": 0.80, ...}
#   ],
#   "prompt": "..."  # 推奨Skillリスト付き
# }
```

### 使用タイミング

#### detect_relevant_skills(task_description, context=None)

技術スタック検出と言語別キーワードから、エージェントが併走すべきSkillを推定します。

```python
skills = detect_relevant_skills(
    "Fix security bug in React TypeScript app",
    context={"project": {"language": "typescript", "frameworks": ["react"]}}
)
# -> [SkillSuggestion(name="typescript", reason="...", confidence=0.86), ...]
```

### 使用タイミング

#### calculate_agent_scores(context)

各エージェントのスコアを計算し、最適なエージェントを決定します。

```python
scores = calculate_agent_scores({
    "intents": [{"type": "error", "confidence": 0.9}],
    "has_documentation": True
})
# -> [{"name": "error-fixer", "confidence": 0.95, ...}, ...]
```

### 使用タイミング

## 🤖 Available Agents (7エージェント)

### 1. error-fixer

- **専門分野**: エラー検出・自動修正・型安全性
- **品質スコア**: 0.92 | **速度スコア**: 0.90
- **最適用途**: TypeScriptエラー、ESLint違反、型安全性向上

### 2. orchestrator

- **専門分野**: 実装・リファクタリング・タスク分解
- **品質スコア**: 0.90 | **速度スコア**: 0.85
- **最適用途**: 新機能実装、大規模リファクタリング、アーキテクチャ変更

### 3. researcher

- **専門分野**: 調査・分析・デバッグ
- **品質スコア**: 0.85 | **速度スコア**: 0.80
- **最適用途**: 原因調査、コードベース分析、問題診断

### 4. code-reviewer

- **専門分野**: コードレビュー・品質評価・セキュリティチェック
- **品質スコア**: 0.95 | **速度スコア**: 0.70
- **最適用途**: コード品質評価、設計レビュー、セキュリティ監査

### 5. github-pr-reviewer

- **専門分野**: GitHub PRレビュー・セマンティック解析・Context7統合
- **品質スコア**: 0.96 | **速度スコア**: 0.85
- **最適用途**: GitHub PRレビュー、包括的品質評価、ドキュメント検証

### 6. docs-manager

- **専門分野**: ドキュメント管理・リンク検証・構造最適化
- **品質スコア**: 0.90 | **速度スコア**: 0.95
- **最適用途**: ドキュメント整備、リンク修正、Markdown最適化

### 7. serena

- **専門分野**: セマンティック解析・シンボル検索・依存関係分析
- **品質スコア**: 0.94 | **速度スコア**: 0.88
- **最適用途**: コード探索、シンボル検索、参照追跡、安全なリファクタリング

## 📚 Detailed References

詳細な実装ロジックとマトリックスは以下のリファレンスを参照してください：

- **[Agent Capabilities Matrix](references/agent-capabilities.md)** - 完全な能力マトリックスと評価基準
- **[Selection Algorithm](references/selection-algorithm.md)** - 多層分析アルゴリズムとスコア計算
- **[Task Classification](references/task-classification.md)** - タスク意図分析パターン
- **[Context7 Integration](references/context7-integration.md)** - Context7統合とスコア調整

## 🎓 Examples

実践的な使用例とパターンは以下を参照してください：

- **[Routing Patterns](examples/routing-patterns.md)** - 一般的なルーティングシナリオ
- **[Skill Suggestions](examples/skill-suggestions.md)** - スキル自動提案パターン
