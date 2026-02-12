# Routing Patterns - 一般的なルーティングシナリオ

実践的なエージェント選択パターンとタスクルーティングの例です。

## 📊 基本的な使用例

### 単純なタスクルーティング

```python
# TypeScriptエラー修正
result = select_optimal_agent("TypeScriptのエラーを修正して")
print(f"選択されたエージェント: {result['agent']} (信頼度: {result['confidence']:.2f})")
# -> error-fixer (0.95)

# 新機能実装
result = select_optimal_agent("新しいユーザー認証機能を実装")
# -> orchestrator (0.9)

# コードベース調査
result = select_optimal_agent("パフォーマンス問題の原因を調査")
# -> researcher (0.9)
```

### コンテキスト付きルーティング

```python
# プロジェクトコンテキストを含む選択
context = {
    "project_type": "typescript-react",
    "recent_changes": ["src/components/Button.tsx"],
    "has_tests": True
}

result = select_optimal_agent("新しいユーザー認証機能を実装", context)
# -> orchestrator (スキル提案: typescript, react)
```

### 複数の選択肢確認

```python
result = select_optimal_agent("コードを改善してエラーも修正")

if result["alternatives"]:
    print("代替エージェント:")
    for alt in result["alternatives"][:3]:
        print(f"  - {alt['name']}: {alt['confidence']:.2f}")

# Output:
# - orchestrator: 0.85 (最適: 改善タスク)
# - error-fixer: 0.80 (代替: エラー修正)
# - researcher: 0.50 (低優先: 調査)
```

## 🎯 タスク意図別パターン

### Error系タスク

```python
# パターン1: 型エラー修正
select_optimal_agent("any型を排除して型安全性を向上")
# -> error-fixer (0.95)
# skills: ["typescript"]

# パターン2: ESLint違反
select_optimal_agent("ESLintのエラーを全て修正")
# -> error-fixer (0.95)
# skills: ["code-quality-improvement"]

# パターン3: Context7統合
context = {"has_documentation": True, "documentation": {"typescript": {...}}}
select_optimal_agent("TypeScript型エラーを修正", context)
# -> error-fixer (0.95 * 1.15 = 1.0+)
# reasoning: "最新ドキュメント参照可能"
```

### Implement系タスク

```python
# パターン1: 新機能実装
select_optimal_agent("新しいダッシュボード機能を実装")
# -> orchestrator (0.9)
# skills: ["react", "typescript"]

# パターン2: 大規模リファクタリング
select_optimal_agent("コンポーネント構造を全面的にリファクタリング")
# -> orchestrator (0.85)
# skills: ["react", "semantic-analysis"]

# パターン3: Context7統合
context = {"has_documentation": True, "documentation": {"react": {...}}}
select_optimal_agent("Reactコンポーネントを実装", context)
# -> orchestrator (0.9 * 1.2 = 1.0+)
# reasoning: "最新ドキュメント参照可能"
```

### Review系タスク

```python
# パターン1: GitHub PR (最高優先度)
select_optimal_agent("https://github.com/org/repo/pull/123 をレビュー")
# -> github-pr-reviewer (0.99)
# skills: ["semantic-analysis", "code-review"]

# パターン2: ブランチ差分レビュー
select_optimal_agent("origin/developとの差分をレビュー")
# -> code-reviewer (0.95)
# skills: []

# パターン3: ローカルコードレビュー
select_optimal_agent("コード品質を評価")
# -> code-reviewer (0.9)
# skills: ["code-review"]
```

### Analyze系タスク

```python
# パターン1: 原因調査
select_optimal_agent("パフォーマンス問題の原因を調査")
# -> researcher (0.9)
# skills: []

# パターン2: 依存関係分析（Serena優先）
select_optimal_agent("この関数の依存関係を分析")
# -> serena (0.85)
# skills: ["semantic-analysis"]

# パターン3: コードベース理解
select_optimal_agent("プロジェクト全体のアーキテクチャを理解したい")
# -> researcher (0.9)
# skills: []
```

### Refactor系タスク

```python
# パターン1: 安全なリファクタリング（Serena最優先）
select_optimal_agent("関数名を変更して影響範囲を確認")
# -> serena (0.95)
# skills: ["semantic-analysis"]

# パターン2: 大規模リファクタリング
select_optimal_agent("モジュール構造を全面的に整理")
# -> orchestrator (0.8)
# skills: ["semantic-analysis"]

# パターン3: コード整理
select_optimal_agent("重複コードを削除して整理")
# -> serena (0.85)
# skills: ["semantic-analysis"]
```

### Navigate系タスク

```python
# パターン1: シンボル検索（Serena最優先）
select_optimal_agent("この関数がどこで使われているか探す")
# -> serena (0.98)
# skills: ["semantic-analysis"]

# パターン2: ファイル検索
select_optimal_agent("設定ファイルがどこにあるか検索")
# -> researcher (0.6)
# skills: []

# パターン3: 参照追跡
select_optimal_agent("APIの使用箇所を全て見つける")
# -> serena (0.98)
# skills: ["semantic-analysis"]
```

### Docs系タスク

```python
# パターン1: ドキュメント整備
select_optimal_agent("READMEを更新")
# -> docs-manager (0.95)
# skills: ["markdown-docs"]

# パターン2: リンク修正
select_optimal_agent("ドキュメントのリンク切れを全て修正")
# -> docs-manager (0.95)
# skills: ["markdown-docs"]

# パターン3: Context7統合
context = {"has_documentation": True, "documentation": {"react": {...}}}
select_optimal_agent("最新のAPI仕様に合わせてREADMEを更新", context)
# -> docs-manager (0.95 * 1.3 = 1.0+)
# reasoning: "最新ドキュメント参照可能"
```

## 🔄 複合タスクパターン

### エラー修正 + 実装

```python
result = select_optimal_agent("ログイン機能のバグを修正して新しいOAuth対応を追加")

# 意図検出:
# 1. "fix" (0.8) - バグ修正
# 2. "implement" (0.85) - 新機能追加
# -> implementが優先（信頼度高）

# 選択: orchestrator (0.7)
# 理由: 実装タスクが主、修正は副次的
```

### レビュー + 修正

```python
result = select_optimal_agent("PRをレビューして問題があれば修正")

# 意図検出:
# 1. "review" (0.9) - レビュー
# 2. "fix" (0.8) - 修正

# 選択: code-reviewer (0.9)
# 理由: レビューが主タスク、修正は後続
```

### 調査 + リファクタリング

```python
result = select_optimal_agent("コードの問題箇所を調査してリファクタリング")

# 意図検出:
# 1. "analyze" (0.85) - 調査
# 2. "refactor" (0.85) - リファクタリング

# 選択: serena (0.85) または researcher (0.9)
# 理由: 両方とも高信頼度、コンテキストで決定
```

## 🎯 Context7統合パターン

### 実装 + ドキュメント参照

```python
context = {
    "intents": [{"type": "implement", "confidence": 0.85}],
    "has_documentation": True,
    "documentation": {
        "react": {"version": "18.2.0"},
        "typescript": {"version": "5.3.0"}
    }
}

result = select_optimal_agent("Reactコンポーネントを実装", context)
# orchestrator: 0.9 * 1.2 = 1.08 (正規化後 1.0)
# skills: ["react", "typescript"]
# reasoning: "実装、タスク分解、体系的実行に特化 (最新ドキュメント参照可能)"
```

### エラー修正 + ドキュメント参照

```python
context = {
    "intents": [{"type": "error", "confidence": 0.9}],
    "has_documentation": True,
    "documentation": {
        "typescript": {"version": "5.3.0"}
    }
}

result = select_optimal_agent("TypeScript型エラーを修正", context)
# error-fixer: 0.95 * 1.15 = 1.09 (正規化後 1.0)
# skills: ["typescript"]
# reasoning: "自動修正、型安全性、品質改善に特化 (最新ドキュメント参照可能)"
```

## 🔗 関連リファレンス

- [Task Classification](../references/task-classification.md) - 意図分析の詳細
- [Selection Algorithm](../references/selection-algorithm.md) - スコア計算ロジック
- [Context7 Integration](../references/context7-integration.md) - Context7統合パターン
