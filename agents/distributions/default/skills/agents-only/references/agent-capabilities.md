# Agent Capabilities Matrix - エージェント能力マトリックス

完全なエージェント能力定義、評価基準、最適用途の詳細です。

## 🎯 完全能力マトリックス

```python
AGENT_CAPABILITIES = {
    "error-fixer": {
        "primary": ["error-detection", "auto-fix", "type-safety", "lint-fix"],
        "quality_score": 0.92,
        "speed_score": 0.90,
        "best_for": ["TypeScriptエラー", "ESLint違反", "型安全性向上", "コード品質改善"]
    },
    "orchestrator": {
        "primary": ["implementation", "refactoring", "task-breakdown", "systematic-execution"],
        "quality_score": 0.90,
        "speed_score": 0.85,
        "best_for": ["新機能実装", "大規模リファクタリング", "アーキテクチャ変更", "体系的な修正"]
    },
    "researcher": {
        "primary": ["investigation", "analysis", "debugging", "understanding"],
        "quality_score": 0.85,
        "speed_score": 0.80,
        "best_for": ["原因調査", "コードベース分析", "問題診断", "技術調査"]
    },
    "code-reviewer": {
        "primary": ["code-review", "quality-assessment", "security-check", "pattern-analysis"],
        "quality_score": 0.95,
        "speed_score": 0.70,
        "best_for": ["コード品質評価", "設計レビュー", "セキュリティ監査", "ベストプラクティス確認"]
    },
    "docs-manager": {
        "primary": ["documentation", "link-validation", "formatting", "structure-optimization"],
        "quality_score": 0.90,
        "speed_score": 0.95,
        "best_for": ["ドキュメント整備", "リンク修正", "Markdown最適化", "構造改善"]
    },
    "serena": {
        "primary": ["semantic-analysis", "symbol-search", "dependency-mapping", "safe-refactoring"],
        "quality_score": 0.94,
        "speed_score": 0.88,
        "best_for": ["コード探索", "シンボル検索", "参照追跡", "安全なリファクタリング"]
    },
    "github-pr-reviewer": {
        "primary": ["github-pr-review", "semantic-analysis", "documentation-validation", "architectural-impact"],
        "quality_score": 0.96,
        "speed_score": 0.85,
        "best_for": ["GitHub PRレビュー", "セマンティック解析連携", "Context7統合", "包括的品質評価"]
    }
}
```

## 📊 評価基準

### Quality Score (品質スコア)

- **0.95-1.0**: 最高品質（code-reviewer, github-pr-reviewer）
- **0.90-0.94**: 高品質（error-fixer, orchestrator, docs-manager, serena）
- **0.85-0.89**: 標準品質（researcher）

### Speed Score (速度スコア)

- **0.90-1.0**: 高速実行（error-fixer, docs-manager）
- **0.85-0.89**: 標準速度（orchestrator, github-pr-reviewer, serena）
- **0.70-0.84**: 慎重実行（code-reviewer, researcher）

## 🎯 エージェント選択基準

### error-fixer

**選択すべき状況**:

- TypeScriptの型エラーが発生している
- ESLint違反を自動修正したい
- any型を排除して型安全性を向上させたい
- コード品質の自動改善が必要

**避けるべき状況**:

- 新機能の設計・実装
- アーキテクチャレベルの変更
- 複雑な調査・分析タスク

### orchestrator

**選択すべき状況**:

- 新機能を実装する
- 大規模なリファクタリングを実施
- アーキテクチャ変更を伴う修正
- 複数ステップの体系的実行が必要

**避けるべき状況**:

- 単純なエラー修正
- 既存コードの調査のみ
- ドキュメント整備のみ

### researcher

**選択すべき状況**:

- 問題の原因を調査する
- コードベース全体を分析する
- バグの診断が必要
- 技術的な調査を実施

**避けるべき状況**:

- 即座の修正が必要なエラー
- 明確な実装タスク
- GitHub PRレビュー

### code-reviewer

**選択すべき状況**:

- コード品質を評価する
- 設計パターンをレビューする
- セキュリティ監査を実施
- ベストプラクティス適合を確認

**避けるべき状況**:

- GitHub PR（github-pr-reviewerを使用）
- 緊急の修正作業
- 単純な調査タスク

### github-pr-reviewer

**選択すべき状況**:

- GitHub PRをレビューする（URL検出時は最高優先度）
- セマンティック解析連携が必要
- Context7統合でライブラリドキュメント参照
- 包括的な品質評価が必要

**避けるべき状況**:

- ローカルコードのレビュー（code-reviewerを使用）
- 実装タスク
- 調査のみ

### docs-manager

**選択すべき状況**:

- ドキュメントを整備する
- リンク切れを修正する
- Markdownフォーマットを最適化
- ドキュメント構造を改善

**避けるべき状況**:

- コード実装
- エラー修正
- 技術調査

### serena

**選択すべき状況**:

- コードを探索する（シンボル検索）
- 参照を追跡する（依存関係分析）
- 安全にリファクタリングする
- コードベースをナビゲート

**避けるべき状況**:

- エラー修正（error-fixerを使用）
- 新機能実装（orchestratorを使用）
- ドキュメント整備（docs-managerを使用）

## 🔗 関連リファレンス

- [Selection Algorithm](selection-algorithm.md) - スコア計算ロジック
- [Task Classification](task-classification.md) - タスク意図分析
- [Context7 Integration](context7-integration.md) - Context7統合によるスコア調整
