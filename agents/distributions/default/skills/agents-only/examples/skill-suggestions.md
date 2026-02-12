# Skill Suggestions - スキル自動提案パターン

技術スタック検出と自動スキル提案ロジックの詳細と実例です。

## 🎯 detect_relevant_skills() 詳細

### 完全な検出ロジック

```python
def detect_relevant_skills(task_description, context):
    """タスクに対して自動ロードすべきスキルを検出"""

    skills = []
    description_lower = task_description.lower()

    # 1. 統合フレームワークスキル（最優先）
    if requires_framework_knowledge(description_lower):
        skills.append({
            "name": "integration-framework",
            "reason": "コンポーネント統合、TaskContext、フレームワークパターンを含むタスク",
            "confidence": 0.9
        })

    if requires_tool_selection_guidance(description_lower):
        skills.append({
            "name": "agents-and-commands",
            "reason": "エージェント/コマンド選択のガイダンスが必要",
            "confidence": 0.9
        })

    if mentions_mcp_servers(description_lower):
        skills.append({
            "name": "mcp-tools",
            "reason": "MCPサーバーセットアップまたは設定を含むタスク",
            "confidence": 0.9
        })

    if needs_documentation_guidance(description_lower):
        skills.append({
            "name": "docs-index",
            "reason": "ドキュメント発見とナビゲーションのガイダンス",
            "confidence": 0.85
        })

    # 2. 技術スタック別スキル（既存ロジック）
    skills.extend(detect_tech_stack_skills(description_lower, context))

    return skills
```

## 🔍 統合フレームワークスキル検出

### requires_framework_knowledge()

統合フレームワークスキルが必要かチェックします。

```python
def requires_framework_knowledge(description_lower):
    """統合フレームワークスキルが必要かチェック"""

    framework_keywords = [
        # 日本語
        "統合フレームワーク", "taskcontext", "communication bus",
        "エージェント開発", "コマンド開発", "アダプター",
        # 英語
        "integration framework", "task context", "communication bus",
        "develop agent", "develop command", "adapter pattern",
        "orchestration", "event driven"
    ]

    return any(keyword in description_lower for keyword in framework_keywords)
```

### 使用例

```python
# パターン1: TaskContext統合
detect_relevant_skills("TaskContextを使ってエージェント間でデータを共有")
# -> [{"name": "integration-framework", "confidence": 0.9}]

# パターン2: エージェント開発
detect_relevant_skills("新しいエージェントを開発してCommunication Busと統合")
# -> [{"name": "integration-framework", "confidence": 0.9}]

# パターン3: オーケストレーション
detect_relevant_skills("複数のコマンドをorchestrationパターンで連携")
# -> [{"name": "integration-framework", "confidence": 0.9}]
```

### requires_tool_selection_guidance()

エージェント/コマンド選択ガイダンスが必要かチェックします。

```python
def requires_tool_selection_guidance(description_lower):
    """エージェント/コマンド選択ガイダンスが必要かチェック"""

    selection_keywords = [
        # 日本語
        "エージェント", "コマンド", "使い分け", "どちらを使う",
        "ツール選択", "どのツール",
        # 英語
        "agent", "command", "which tool", "how to use",
        "tool selection", "agent vs command", "choose between"
    ]

    # キーワードが複数含まれる場合に高信頼度
    matches = sum(1 for keyword in selection_keywords if keyword in description_lower)
    return matches >= 2
```

### 使用例

```python
# パターン1: ツール選択相談
detect_relevant_skills("このタスクにはエージェントとコマンドどちらを使うべき?")
# -> [{"name": "agents-and-commands", "confidence": 0.9}]

# パターン2: 使い分け質問
detect_relevant_skills("どのエージェントが最適?")
# -> [] (キーワード1つのみ、閾値未満)

# パターン3: 複数キーワード
detect_relevant_skills("エージェント選択のツールはどれ?")
# -> [{"name": "agents-and-commands", "confidence": 0.9}]
```

### mentions_mcp_servers()

MCPサーバー関連のキーワードをチェックします。

```python
def mentions_mcp_servers(description_lower):
    """MCPサーバー関連のキーワードをチェック"""

    mcp_keywords = [
        # 日本語
        "mcp", "mcpサーバー", "mcp設定",
        # 英語
        "mcp server", "mcp setup", "claude_desktop_config",
        "external tool integration", "mcp configuration"
    ]

    return any(keyword in description_lower for keyword in mcp_keywords)
```

### 使用例

```python
# パターン1: MCPセットアップ
detect_relevant_skills("MCPサーバーをセットアップ")
# -> [{"name": "mcp-tools", "confidence": 0.9}]

# パターン2: 設定ファイル
detect_relevant_skills("claude_desktop_config.jsonを編集")
# -> [{"name": "mcp-tools", "confidence": 0.9}]

# パターン3: 外部ツール統合
detect_relevant_skills("external tool integrationのベストプラクティス")
# -> [{"name": "mcp-tools", "confidence": 0.9}]
```

### needs_documentation_guidance()

ドキュメント発見ガイダンスが必要かチェックします。

```python
def needs_documentation_guidance(description_lower):
    """ドキュメント発見ガイダンスが必要かチェック"""

    docs_keywords = [
        # 日本語
        "ドキュメント", "ガイド", "どこにあるか", "どこにある",
        # 英語
        "documentation", "guide", "where is", "find guide",
        "locate documentation"
    ]

    return any(keyword in description_lower for keyword in docs_keywords)
```

### 使用例

```python
# パターン1: ドキュメント検索
detect_relevant_skills("このプロジェクトのドキュメントはどこにある?")
# -> [{"name": "docs-index", "confidence": 0.85}]

# パターン2: ガイド検索
detect_relevant_skills("TypeScriptのガイドを探す")
# -> [{"name": "docs-index", "confidence": 0.85}]

# パターン3: 場所確認
detect_relevant_skills("README.mdはどこにあるか")
# -> [{"name": "docs-index", "confidence": 0.85}]
```

## 🛠️ 技術スタック別スキル検出

### detect_tech_stack_skills()

既存の技術スタック検出ロジックです。

```python
def detect_tech_stack_skills(description_lower, context):
    """既存の技術スタック検出ロジック"""

    skills = []

    # TypeScript
    if any(kw in description_lower for kw in ["typescript", "ts", "type", "型"]):
        skills.append({
            "name": "typescript",
            "reason": "TypeScript 型安全性とリンティング指針を適用",
            "confidence": 0.86
        })

    # React
    if any(kw in description_lower for kw in ["react", "jsx", "tsx", "component", "next.js"]):
        skills.append({
            "name": "react",
            "reason": "React/Next.js のコンポーネント設計と最適化パターンを適用",
            "confidence": 0.8
        })

    # Go
    if any(kw in description_lower for kw in ["go", "golang", "goroutine"]):
        skills.append({
            "name": "golang",
            "reason": "Go言語のベストプラクティスとイディオムを適用",
            "confidence": 0.85
        })

    # Security
    if any(kw in description_lower for kw in [
        "security", "セキュリティ", "auth", "認証", "jwt", "csrf", "xss"
    ]):
        skills.append({
            "name": "security",
            "reason": "認証/認可・入力検証などのセキュリティ強化を組み込む",
            "confidence": 0.9
        })

    # Semantic Analysis
    if any(kw in description_lower for kw in [
        "refactor", "リファクタ", "impact", "影響", "dependency", "依存"
    ]):
        skills.append({
            "name": "semantic-analysis",
            "reason": "コード構造の意味解析と影響範囲評価を実施",
            "confidence": 0.85
        })

    # Code Quality
    if any(kw in description_lower for kw in [
        "lint", "format", "quality", "品質", "eslint"
    ]):
        skills.append({
            "name": "code-quality-improvement",
            "reason": "コード品質向上の体系的アプローチを適用",
            "confidence": 0.8
        })

    # Markdown Documentation
    if any(kw in description_lower for kw in [
        "markdown", "md", "readme", "documentation"
    ]):
        skills.append({
            "name": "markdown-docs",
            "reason": "Markdownドキュメント品質とベストプラクティスを適用",
            "confidence": 0.8
        })

    return skills
```

## 📊 複合スキル提案パターン

### TypeScript + React

```python
detect_relevant_skills("Fix security bug in React TypeScript app", context)
# -> [
#   {"name": "typescript", "confidence": 0.86},
#   {"name": "react", "confidence": 0.8},
#   {"name": "security", "confidence": 0.9}
# ]
```

### リファクタリング + 品質改善

```python
detect_relevant_skills("Refactor code and improve quality with ESLint", context)
# -> [
#   {"name": "semantic-analysis", "confidence": 0.85},
#   {"name": "code-quality-improvement", "confidence": 0.8}
# ]
```

### ドキュメント + Markdown

```python
detect_relevant_skills("Update README.md documentation", context)
# -> [
#   {"name": "markdown-docs", "confidence": 0.8}
# ]
```

### 統合フレームワーク + MCP

```python
detect_relevant_skills("Develop agent with MCP server integration", context)
# -> [
#   {"name": "integration-framework", "confidence": 0.9},
#   {"name": "mcp-tools", "confidence": 0.9}
# ]
```

## 🎯 スキル起動例

### Task ツールでの起動

```python
skills = detect_relevant_skills(
    "Fix security bug in React TypeScript app",
    context
)

# 各スキルを順次起動
for skill in skills:
    Task(skill=skill["name"], description=skill["reason"])

# 起動されるスキル:
# 1. typescript (型安全性とリンティング指針)
# 2. react (コンポーネント設計と最適化パターン)
# 3. security (認証/認可・入力検証)
```

### プロンプトへの統合

```python
result = select_optimal_agent("Fix security bug in React TypeScript app", context)

# result["prompt"] には以下が含まれる:
"""
推奨スキル:
- [x] typescript (型安全性とリンティング指針)
- [x] react (コンポーネント設計と最適化パターン)
- [x] security (認証/認可・入力検証)

エージェント起動前に上記スキルを確認してください。
"""
```

## 🔗 関連リファレンス

- [Agent Capabilities](../references/agent-capabilities.md) - エージェントとスキルの連携
- [Selection Algorithm](../references/selection-algorithm.md) - スキル提案の統合フロー
- [Routing Patterns](routing-patterns.md) - エージェント選択とスキル提案の実例
