# Agent Selector - 共通エージェント選択ユーティリティ

タスクの意図とコンテキストに基づいて最適なエージェントを選択する共通ユーティリティです。

## 🎯 Core Functions

### select_optimal_agent()

```python
def select_optimal_agent(task_description, context=None):
    """タスクに最適なエージェントと起動すべきSkillsを返す"""

    task_type = classify_task(task_description, context)
    agent_type = select_agent(task_type, context)
    skills = detect_relevant_skills(task_description, context)

    return {
        "agent_type": agent_type.value,
        "task_type": task_type.value,
        "skills": [asdict(skill) for skill in skills],
        # スキル起動チェックリストを含んだプロンプトを生成
        "prompt": create_agent_prompt(task_description, agent_type, context, skills),
    }

# 返却例
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

- `skills`にはエージェント起動前に立ち上げるべきSkill候補が含まれる。`Task`ツールで`skill["name"]`を実行し、プレイブックを読み込んでからエージェントを開始する。
- `prompt`はSkillの起動チェックリストを含むため、そのままエージェント呼び出しに使用できる。

### detect_relevant_skills()

技術スタック検出と言語別キーワードから、エージェントが併走すべきSkillを推定する。

```python
skills = detect_relevant_skills(
    "Fix security bug in React TypeScript app",
    context={"project": {"language": "typescript", "frameworks": ["react"], "tools": ["eslint"]}}
)

# skills -> [
#   SkillSuggestion(name="typescript", reason="TypeScript 型安全性とリンティング指針を適用", ...),
#   SkillSuggestion(name="react", reason="React/Next.js のコンポーネント設計と最適化パターンを先読み", ...),
#   SkillSuggestion(name="security", reason="認証/認可・入力検証などのセキュリティ強化を組み込む", ...)
# ]

# Skillの起動例
for skill in skills:
    Task(skill=skill.name, description=skill.reason)
```

検出ロジックの主なトリガー:

**技術スタック別スキル**:

- **言語/フレームワーク**: TypeScript → `typescript`、React/Next.js → `react`、Go → `golang`
- **横断関心事**: `security` (auth/jwt/csrf等のキーワード)、`semantic-analysis` (refactor/impact/dependency)
- **品質改善**: Lint/format/品質系のキーワードや検出ツールで `code-quality-improvement`
- **ドキュメント**: docs/markdown系のキーワードで `markdown-docs`

**統合フレームワークスキル（新規）**:

- **integration-framework**: TaskContext、Communication Bus、フレームワークパターン、エージェント/コマンド開発
- **agents-and-commands**: エージェント/コマンド選択、使い分け、ツール選択ガイダンス
- **mcp-tools**: MCPサーバー、claude_desktop_config.json、MCP設定、外部ツール統合
- **docs-index**: ドキュメント発見、ガイド検索、ナビゲーション

#### 詳細な検出ロジック

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

### analyze_task_intent()

```python
def analyze_task_intent(task_description):
    """タスクの意図を多層的に分析"""

    intents = []
    description_lower = task_description.lower()

    # エラー・品質系
    if any(keyword in description_lower for keyword in [
        "エラー", "error", "型", "type", "eslint", "lint",
        "品質", "quality", "any型", "型安全"
    ]):
        intents.append({"type": "error", "confidence": 0.9})

    # 実装・構築系
    if any(keyword in description_lower for keyword in [
        "実装", "implement", "作成", "create", "追加", "add",
        "機能", "feature", "開発", "develop"
    ]):
        intents.append({"type": "implement", "confidence": 0.85})

    # 修正系
    if any(keyword in description_lower for keyword in [
        "修正", "fix", "直", "バグ", "bug", "問題", "issue"
    ]):
        intents.append({"type": "fix", "confidence": 0.8})

    # 調査・分析系
    if any(keyword in description_lower for keyword in [
        "調査", "investigate", "分析", "analyze", "原因", "cause",
        "なぜ", "why", "理解", "understand"
    ]):
        intents.append({"type": "analyze", "confidence": 0.85})

    # レビュー系
    if any(keyword in description_lower for keyword in [
        "レビュー", "review", "確認", "check", "評価", "evaluate",
        "品質", "quality"
    ]):
        intents.append({"type": "review", "confidence": 0.9})

    # Git/ブランチ関連のレビュー（origin/develop, main, HEAD等）
    if any(keyword in description_lower for keyword in [
        "origin/", "develop", "main", "master", "branch",
        "diff", "commit", "head", "staging", "pr", "pull request"
    ]):
        # レビューコンテキストのキーワードがあれば、レビュー意図として判定
        if "レビュー" in description_lower or "review" in description_lower:
            intents.append({"type": "review", "confidence": 0.95})
        # 明示的なレビューキーワードがなくても、ブランチ名のみでレビューと推測
        elif any(branch in description_lower for branch in ["origin/develop", "origin/main", "origin/master"]):
            intents.append({"type": "review", "confidence": 0.85})

    # GitHub PR URL検出（github-pr-reviewerに最高優先度を付与）
    if any(keyword in description_lower for keyword in [
        "github.com", "pull/", "/pr", "#pr", "pr #"
    ]):
        intents.append({"type": "github_pr", "confidence": 0.99})

    # リファクタリング系
    if any(keyword in description_lower for keyword in [
        "リファクタ", "refactor", "改善", "improve", "整理", "organize",
        "名前変更", "rename", "移動", "move"
    ]):
        intents.append({"type": "refactor", "confidence": 0.85})

    # ナビゲーション系
    if any(keyword in description_lower for keyword in [
        "探", "find", "検索", "search", "どこ", "where",
        "参照", "reference", "使用", "usage"
    ]):
        intents.append({"type": "navigate", "confidence": 0.8})

    # ドキュメント系
    if any(keyword in description_lower for keyword in [
        "ドキュメント", "document", "doc", "リンク", "link",
        "markdown", "md"
    ]):
        intents.append({"type": "docs", "confidence": 0.85})

    return sorted(intents, key=lambda x: x["confidence"], reverse=True)
```

### calculate_agent_scores()

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

### select_by_confidence()

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

## 🎯 Agent Capability Matrix

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

## 📊 使用例

```python
# 基本的な使用
result = select_optimal_agent("TypeScriptのエラーを修正して")
print(f"選択されたエージェント: {result['agent']} (信頼度: {result['confidence']:.2f})")

# コンテキスト付きの使用
context = {
    "project_type": "typescript-react",
    "recent_changes": ["src/components/Button.tsx"],
    "has_tests": True
}
result = select_optimal_agent("新しいユーザー認証機能を実装", context)

# 複数の選択肢を確認
if result["alternatives"]:
    print("代替エージェント:")
    for alt in result["alternatives"][:3]:
        print(f"  - {alt['name']}: {alt['confidence']:.2f}")
```

このユーティリティにより、エージェント選択ロジックが統一され、各コマンドで一貫した動作が保証されます。

## 🎯 Skill Integration

このユーティリティは以下のスキルと統合し、エージェント選択の精度を向上させます。

### agents-and-commands (必須)

- **理由**: エージェント能力マトリックスと選択ロジックの公式ガイド
- **タイミング**: エージェント選択時に自動参照
- **トリガー**: `select_optimal_agent()` や `calculate_agent_scores()` 実行時
- **提供内容**:
  - 全エージェントの能力定義（AGENT_CAPABILITIES）
  - タスク意図分析パターン
  - エージェント選択の意思決定ツリー
  - ベストプラクティスと選択基準

### integration-framework (オプション)

- **理由**: TaskContext標準化とCommunication Busパターンの仕様
- **タイミング**: TaskContextとの統合が必要な場合
- **トリガー**: `share_context_between_agents()` や複雑なワークフロー構築時
- **提供内容**:
  - TaskContextインターフェース仕様
  - エージェント間通信パターン
  - Communication Busイベント駆動設計
  - 統合アーキテクチャのベストプラクティス

### mcp-tools (条件付き)

- **理由**: MCPサーバー統合パターンとContext7活用ガイダンス
- **タイミング**: Context7統合や外部MCP連携が必要な場合
- **トリガー**: `detect_library_references()` によるライブラリ検出時
- **提供内容**:
  - Context7 MCPサーバー統合パターン
  - ライブラリドキュメント取得戦略
  - エラーハンドリングとフォールバック
  - セキュリティベストプラクティス

### 統合フローの例

```
タスク受信
    ↓
TaskContext作成
    ↓
analyze_task_intent() 実行
    ↓ (agents-and-commands参照)
意図分類（error/implement/review等）
    ↓
calculate_agent_scores() 実行
    ↓ (AGENT_CAPABILITIESマトリックス参照)
エージェントスコア計算
    ↓
Context7統合あり？
    ↓ Yes (mcp-toolsガイダンス適用)
エージェントスコア調整（+20%）
    ↓
select_by_confidence() 実行
    ↓
最適エージェント決定
```

### スキル連携の利点

1. **精度向上**: 公式ガイダンスに基づく一貫した選択ロジック
2. **拡張性**: 新しいエージェント追加時の自動統合
3. **コンテキスト豊富化**: ライブラリドキュメントによるスコア最適化
4. **保守性**: 能力マトリックス更新時の自動反映

## 🔗 Context7統合

このユーティリティはContext7 MCPサーバーと連携して、ライブラリドキュメントの可用性に基づいてエージェント選択を最適化します：

### 統合による利点

1. **自動スコア調整**: ドキュメントが利用可能な場合、実装系エージェントのスコアを自動的に向上
2. **コンテキスト強化**: 最新のAPIドキュメントによりエージェントの精度向上
3. **エラー修正支援**: エラー関連タスクで関連ドキュメントがある場合、error-fixerエージェントを優先

### Context7情報の活用

```python
# Context7情報を含むコンテキスト例
context = {
    "intents": [{"type": "implement", "confidence": 0.85}],
    "has_documentation": True,
    "documentation": {
        "react": {...},  # React関連のドキュメント
        "typescript": {...}  # TypeScript関連のドキュメント
    }
}

# この場合、orchestratorエージェントのスコアが1.2倍に調整される
result = calculate_agent_scores(context)
```
