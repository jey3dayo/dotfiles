# Context7 Integration - Context7統合

Context7 MCPサーバーとの連携による、ライブラリドキュメント活用とエージェント選択最適化の詳細です。

## 🔗 Context7とは

Context7は最新のライブラリドキュメントとコード例を提供するMCPサーバーです。エージェント選択時にドキュメントの可用性を考慮することで、実装精度を向上させます。

## 📊 統合による利点

### 1. 自動スコア調整

ドキュメントが利用可能な場合、実装系エージェントのスコアを自動的に向上させます。

```python
if context.get('has_documentation'):
    # 実装系エージェントのスコアを上げる
    agents["orchestrator"]["base_score"] *= 1.2  # +20%
    agents["researcher"]["base_score"] *= 1.1    # +10%
```

### 2. コンテキスト強化

最新のAPIドキュメントによりエージェントの精度が向上し、より正確な実装が可能になります。

### 3. エラー修正支援

エラー関連タスクで関連ドキュメントがある場合、error-fixerエージェントを優先します。

```python
if primary_intent["type"] == "error" and docs_count > 0:
    agents["error-fixer"]["base_score"] *= 1.15  # +15%
```

## 🎯 スコア調整ロジック

### Context7情報の活用

```python
# Context7情報を含むコンテキスト例
context = {
    "intents": [{"type": "implement", "confidence": 0.85}],
    "has_documentation": True,
    "documentation": {
        "react": {...},      # React関連のドキュメント
        "typescript": {...}  # TypeScript関連のドキュメント
    }
}

# この場合、orchestratorエージェントのスコアが1.2倍に調整される
result = calculate_agent_scores(context)
```

### 調整係数一覧

| エージェント | 基本調整 | 条件調整 | 適用条件                                |
| ------------ | -------- | -------- | --------------------------------------- |
| orchestrator | +20%     | -        | has_documentation = True                |
| researcher   | +10%     | -        | has_documentation = True                |
| docs-manager | -        | +30%     | has_documentation = True かつ docs意図  |
| error-fixer  | -        | +15%     | has_documentation = True かつ error意図 |

## 🔄 統合フロー

```
タスク受信
    ↓
TaskContext作成
    ↓
Context7ライブラリ検出
    ↓ (ライブラリ参照検出)
has_documentation = True
    ↓
analyze_task_intent() 実行
    ↓
意図分類（error/implement/review等）
    ↓
calculate_agent_scores() 実行
    ↓
基礎スコア計算
    ↓
Context7統合チェック
    ↓ (has_documentation = True)
スコア調整適用
    - orchestrator: *1.2
    - researcher: *1.1
    - docs-manager: *1.3 (docs意図時)
    - error-fixer: *1.15 (error意図時)
    ↓
select_by_confidence() 実行
    ↓
最適エージェント決定（調整後スコア反映）
```

## 📝 実装例

### 基本的な統合

```python
def calculate_agent_scores(context):
    """Context7統合を含むスコア計算"""

    # ... (基礎スコア計算)

    # Context7統合によるスコア調整
    if context.get('has_documentation'):
        docs_count = len(context.get('documentation', {}))

        # 実装系エージェント強化
        agents["orchestrator"]["base_score"] *= 1.2
        agents["researcher"]["base_score"] *= 1.1

        # ドキュメント関連タスクの場合
        if 'docs' in [intent["type"] for intent in context.get("intents", [])]:
            agents["docs-manager"]["base_score"] *= 1.3

        # エラー修正でドキュメントがある場合
        if primary_intent and primary_intent["type"] == "error" and docs_count > 0:
            agents["error-fixer"]["base_score"] *= 1.15

    # スコア正規化と返却
    scored_agents = []
    for agent_name, agent_data in agents.items():
        reasoning = f"{agent_data['strengths']}に特化"

        # Context7情報を理由に追加
        if context.get('has_documentation') and agent_data["base_score"] > 0.5:
            reasoning += " (最新ドキュメント参照可能)"

        scored_agents.append({
            "name": agent_name,
            "confidence": min(agent_data["base_score"], 1.0),
            "reasoning": reasoning,
            "capabilities": agent_data["capabilities"]
        })

    return sorted(scored_agents, key=lambda x: x["confidence"], reverse=True)
```

### 理由への追記

Context7統合が有効な場合、エージェント選択理由に「最新ドキュメント参照可能」が追加されます。

```python
if context.get('has_documentation') and agent_data["base_score"] > 0.5:
    reasoning += " (最新ドキュメント参照可能)"

# 例:
# "実装、タスク分解、体系的実行に特化 (最新ドキュメント参照可能)"
```

## 🎯 使用例

### 実装タスク + Context7

```python
# React実装タスクでContext7が利用可能
context = {
    "intents": [{"type": "implement", "confidence": 0.85}],
    "has_documentation": True,
    "documentation": {
        "react": {"version": "18.2.0", ...}
    }
}

result = select_optimal_agent("新しいReactコンポーネントを実装", context)
# -> orchestrator選択、スコア +20%
# reasoning: "実装、タスク分解、体系的実行に特化 (最新ドキュメント参照可能)"
```

### エラー修正 + Context7

```python
# TypeScriptエラー修正でContext7が利用可能
context = {
    "intents": [{"type": "error", "confidence": 0.9}],
    "has_documentation": True,
    "documentation": {
        "typescript": {"version": "5.3.0", ...}
    }
}

result = select_optimal_agent("TypeScriptの型エラーを修正", context)
# -> error-fixer選択、スコア +15%
# reasoning: "自動修正、型安全性、品質改善に特化 (最新ドキュメント参照可能)"
```

### ドキュメント整備 + Context7

```python
# ドキュメント整備でContext7が利用可能
context = {
    "intents": [{"type": "docs", "confidence": 0.85}],
    "has_documentation": True,
    "documentation": {
        "react": {...},
        "typescript": {...}
    }
}

result = select_optimal_agent("READMEを最新のAPI仕様に更新", context)
# -> docs-manager選択、スコア +30%
# reasoning: "ドキュメント管理、リンク検証、構造最適化に特化 (最新ドキュメント参照可能)"
```

## 🛠️ mcp-tools スキルとの連携

Context7統合の詳細な設定とトラブルシューティングは `mcp-tools` スキルを参照してください：

- Context7 MCPサーバーセットアップ
- ライブラリドキュメント取得戦略
- エラーハンドリングとフォールバック
- セキュリティベストプラクティス

## 🔗 関連リファレンス

- [Selection Algorithm](selection-algorithm.md) - スコア計算の全体フロー
- [Task Classification](task-classification.md) - 意図分析とContext7の関係
- [Agent Capabilities](agent-capabilities.md) - 各エージェントのドキュメント活用能力
