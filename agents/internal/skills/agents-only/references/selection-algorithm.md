# Selection Algorithm - エージェント選択アルゴリズム

多層分析とスコア計算による最適エージェント決定ロジックの詳細です。

## 🧮 スコア計算アルゴリズム

### calculate_agent_scores(context)

各エージェントのスコアを意図ベースで計算し、Context7統合により調整します。

```python
def calculate_agent_scores(context):
    """各エージェントのスコアを計算"""

    agents = {
        "error-fixer": {
            "capabilities": ["error", "quality", "fix", "type-safety"],
            "strengths": ["自動修正", "型安全性", "品質改善"],
            "base_score": 0.0
        },
        "orchestrator": {
            "capabilities": ["implement", "refactor", "build", "architecture"],
            "strengths": ["実装", "タスク分解", "体系的実行"],
            "base_score": 0.0
        },
        "researcher": {
            "capabilities": ["analyze", "investigate", "debug", "understand"],
            "strengths": ["調査", "分析", "問題究明"],
            "base_score": 0.0
        },
        "code-reviewer": {
            "capabilities": ["review", "quality", "security", "patterns"],
            "strengths": ["コード評価", "設計レビュー", "品質監査"],
            "base_score": 0.0
        },
        "github-pr-reviewer": {
            "capabilities": ["github", "pr", "review", "semantic", "documentation"],
            "strengths": ["GitHub PR専門レビュー", "MCP Serena統合", "Context7活用"],
            "base_score": 0.0
        },
        "docs-manager": {
            "capabilities": ["docs", "links", "markdown", "formatting"],
            "strengths": ["ドキュメント管理", "リンク検証", "構造最適化"],
            "base_score": 0.0
        },
        "serena": {
            "capabilities": ["navigate", "refactor", "semantic", "references"],
            "strengths": ["コード探索", "シンボル検索", "依存関係分析"],
            "base_score": 0.0
        }
    }

    # 意図に基づくスコアリング
    primary_intent = context["intents"][0] if context["intents"] else None

    if primary_intent:
        intent_type = primary_intent["type"]
        intent_confidence = primary_intent["confidence"]

        # 意図とエージェントのマッピング
        intent_agent_map = {
            "error": {"error-fixer": 0.95, "orchestrator": 0.3, "researcher": 0.3},
            "implement": {"orchestrator": 0.9, "researcher": 0.6, "error-fixer": 0.2},
            "fix": {"orchestrator": 0.7, "error-fixer": 0.6, "researcher": 0.5},
            "analyze": {"researcher": 0.9, "serena": 0.85, "code-reviewer": 0.4},
            "review": {"github-pr-reviewer": 0.98, "code-reviewer": 0.9, "researcher": 0.3},
            "github_pr": {"github-pr-reviewer": 0.99, "code-reviewer": 0.3},
            "refactor": {"serena": 0.95, "orchestrator": 0.8, "error-fixer": 0.3},
            "navigate": {"serena": 0.98, "researcher": 0.6, "orchestrator": 0.2},
            "docs": {"docs-manager": 0.95, "researcher": 0.3}
        }

        if intent_type in intent_agent_map:
            for agent, weight in intent_agent_map[intent_type].items():
                agents[agent]["base_score"] += weight * intent_confidence

    # Context7統合によるスコア調整
    if context.get('has_documentation'):
        # ドキュメントが利用可能な場合のスコア調整
        docs_count = len(context.get('documentation', {}))

        # 実装系エージェントのスコアを上げる
        agents["orchestrator"]["base_score"] *= 1.2
        agents["researcher"]["base_score"] *= 1.1

        # ドキュメント関連タスクの場合
        if 'docs' in [intent["type"] for intent in context.get("intents", [])]:
            agents["docs-manager"]["base_score"] *= 1.3

        # エラー修正でドキュメントがある場合
        if primary_intent and primary_intent["type"] == "error" and docs_count > 0:
            agents["error-fixer"]["base_score"] *= 1.15

    # スコアを正規化して返す
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

## 🎯 意図マッピング戦略

### Intent-Agent Mapping Matrix

| 意図タイプ | 最優先エージェント | 重み | 代替エージェント                      |
| ---------- | ------------------ | ---- | ------------------------------------- |
| error      | error-fixer        | 0.95 | orchestrator (0.3), researcher (0.3)  |
| implement  | orchestrator       | 0.9  | researcher (0.6), error-fixer (0.2)   |
| fix        | orchestrator       | 0.7  | error-fixer (0.6), researcher (0.5)   |
| analyze    | researcher         | 0.9  | serena (0.85), code-reviewer (0.4)    |
| review     | github-pr-reviewer | 0.98 | code-reviewer (0.9), researcher (0.3) |
| github_pr  | github-pr-reviewer | 0.99 | code-reviewer (0.3)                   |
| refactor   | serena             | 0.95 | orchestrator (0.8), error-fixer (0.3) |
| navigate   | serena             | 0.98 | researcher (0.6), orchestrator (0.2)  |
| docs       | docs-manager       | 0.95 | researcher (0.3)                      |

### スコア計算の流れ

```
1. 基礎スコア初期化 (全エージェント 0.0)
    ↓
2. 意図検出 (analyze_task_intent)
    ↓
3. 意図-エージェントマッピング適用
    base_score += weight * intent_confidence
    ↓
4. Context7統合チェック
    ↓ (has_documentation = True)
5. スコア調整
    - orchestrator: *1.2
    - researcher: *1.1
    - docs-manager: *1.3 (docs意図時)
    - error-fixer: *1.15 (error意図+docs利用可能時)
    ↓
6. 正規化 (max 1.0)
    ↓
7. 信頼度降順ソート
    ↓
8. 最適エージェント返却
```

## 🔄 信頼度ベース選択

### select_by_confidence(agent_scores)

最終的なエージェント選択と警告メッセージ生成。

```python
def select_by_confidence(agent_scores):
    """信頼度に基づいて最適なエージェントを選択"""

    if not agent_scores:
        # デフォルトはresearcher
        return {
            "name": "researcher",
            "confidence": 0.5,
            "reasoning": "明確な意図が検出されなかったため、汎用的な調査エージェントを選択"
        }

    top_agent = agent_scores[0]

    # 信頼度が低い場合の警告
    if top_agent["confidence"] < 0.5:
        top_agent["reasoning"] += " (信頼度が低いため、より具体的な指示が推奨されます)"

    return top_agent
```

### 信頼度基準

- **0.9-1.0**: 高信頼度（GitHub PR URL検出、明確な意図）
- **0.7-0.89**: 中信頼度（一般的なタスク）
- **0.5-0.69**: 低信頼度（曖昧な指示、警告付き）
- **0.0-0.49**: 最低信頼度（デフォルトresearcher選択）

## 📊 Context7統合によるスコア調整

### 調整係数

| エージェント | 基本係数 | 条件係数                        |
| ------------ | -------- | ------------------------------- |
| orchestrator | 1.2      | -                               |
| researcher   | 1.1      | -                               |
| docs-manager | 1.0      | 1.3 (docs意図時)                |
| error-fixer  | 1.0      | 1.15 (error意図+docs利用可能時) |

### 調整ロジック

```python
if context.get('has_documentation'):
    docs_count = len(context.get('documentation', {}))

    # 実装系エージェント強化
    agents["orchestrator"]["base_score"] *= 1.2
    agents["researcher"]["base_score"] *= 1.1

    # ドキュメントタスク強化
    if 'docs' in [intent["type"] for intent in context.get("intents", [])]:
        agents["docs-manager"]["base_score"] *= 1.3

    # エラー修正+ドキュメント利用可能
    if primary_intent and primary_intent["type"] == "error" and docs_count > 0:
        agents["error-fixer"]["base_score"] *= 1.15
```

## 🔗 関連リファレンス

- [Task Classification](task-classification.md) - 意図分析の詳細
- [Agent Capabilities](agent-capabilities.md) - 能力マトリックス
- [Context7 Integration](context7-integration.md) - Context7統合の詳細
