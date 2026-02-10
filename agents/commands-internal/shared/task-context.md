# Task Context - 統一タスクコンテキスト

エージェントとコマンド間で共有される統一されたタスクコンテキスト構造です。

## 🎯 Core Interface

### TaskContext Structure

```python
class TaskContext:
    """統一されたタスクコンテキスト"""

    def __init__(self, task_description, source="user"):
        self.id = generate_task_id()
        self.type = "command" if source.startswith("/") else "agent"
        self.source = source
        self.created_at = timestamp()

        # プロジェクト情報
        self.project = self._detect_project_info()

        # 実行環境
        self.execution = self._create_execution_context()

        # タスク意図
        self.intent = self._analyze_intent(task_description)

        # コミュニケーション
        self.communication = {
            "parent_task": None,
            "child_tasks": [],
            "shared_data": {},
            "messages": []
        }

        # メトリクス
        self.metrics = {
            "start_time": None,
            "end_time": None,
            "status": "pending",
            "quality_score": None,
            "resource_usage": {}
        }

    def _detect_project_info(self):
        """プロジェクト情報を検出"""
        from .project_detector import detect_project_type

        project_info = detect_project_type()
        return {
            "root": get_project_root(),
            "type": project_info["type"],
            "stack": project_info["stack"],
            "structure": project_info["structure"],
            "conventions": self._load_conventions()
        }

    def _create_execution_context(self):
        """実行コンテキストを作成"""
        return {
            "working_directory": os.getcwd(),
            "target_files": [],
            "git_status": self._get_git_status(),
            "environment": {
                "os": platform.system(),
                "python_version": sys.version,
                "node_version": get_node_version() if exists("package.json") else None,
                "available_tools": self._detect_available_tools()
            }
        }

    def _analyze_intent(self, task_description):
        """タスクの意図を分析"""
        from .agent_selector import analyze_task_intent

        intents = analyze_task_intent(task_description)
        return {
            "primary": intents[0] if intents else None,
            "secondary": intents[1:] if len(intents) > 1 else [],
            "confidence": intents[0]["confidence"] if intents else 0.0,
            "original_request": task_description
        }

    def _load_conventions(self):
        """プロジェクトコンベンションを読み込み"""
        conventions = {}

        # CLAUDE.mdから読み込み
        if exists(".claude/CLAUDE.md"):
            claude_md = read_file(".claude/CLAUDE.md")
            conventions["claude_md"] = parse_conventions_from_claude_md(claude_md)

        # プロジェクト固有の設定
        if exists(".claude/conventions.json"):
            conventions["custom"] = read_json(".claude/conventions.json")

        return conventions

    def _get_git_status(self):
        """Git状態を取得"""
        try:
            return {
                "branch": execute_command("git branch --show-current").strip(),
                "has_changes": bool(execute_command("git status --porcelain")),
                "staged_files": execute_command("git diff --cached --name-only").splitlines(),
                "modified_files": execute_command("git diff --name-only").splitlines()
            }
        except:
            return None

    def _detect_available_tools(self):
        """利用可能なツールを検出"""
        tools = []

        # 基本ツール
        for tool in ["git", "npm", "pnpm", "yarn", "python", "go", "cargo"]:
            if command_exists(tool):
                tools.append(tool)

        # エージェント
        tools.extend([
            "error-fixer", "orchestrator", "researcher",
            "code-reviewer", "docs-manager", "serena"
        ])

        return tools
```

### Context Enhancement Functions

```python
def enhance_context_with_history(context, history_manager):
    """実行履歴でコンテキストを強化"""

    # 類似タスクの検索
    similar_tasks = history_manager.find_similar_tasks(
        context.intent["original_request"],
        limit=5
    )

    if similar_tasks:
        context.communication["shared_data"]["similar_tasks"] = similar_tasks

        # 成功パターンの抽出
        success_patterns = [
            task for task in similar_tasks
            if task["metrics"]["status"] == "success"
        ]

        if success_patterns:
            # 最も成功率の高いアプローチを推奨
            best_approach = max(
                success_patterns,
                key=lambda x: x["metrics"].get("quality_score", 0)
            )
            context.communication["shared_data"]["recommended_approach"] = best_approach

    return context
```

### Context Sharing Functions

```python
def share_context_between_agents(parent_context, child_agent):
    """親タスクから子タスクへコンテキストを共有"""

    child_context = TaskContext(
        task_description=child_agent["prompt"],
        source=f"{parent_context.source}/{child_agent['name']}"
    )

    # 親タスクの情報を継承
    child_context.project = parent_context.project
    child_context.execution = parent_context.execution.copy()
    child_context.communication["parent_task"] = parent_context.id

    # 親タスクに子タスクを登録
    parent_context.communication["child_tasks"].append(child_context.id)

    # 共有データの継承
    child_context.communication["shared_data"] = parent_context.communication["shared_data"].copy()

    return child_context
```

### Context Persistence

```python
def save_context(context, storage_path=".claude/contexts"):
    """コンテキストを永続化"""

    ensure_directory(storage_path)

    context_file = f"{storage_path}/{context.id}.json"
    context_data = {
        "id": context.id,
        "type": context.type,
        "source": context.source,
        "created_at": context.created_at,
        "project": context.project,
        "execution": context.execution,
        "intent": context.intent,
        "communication": context.communication,
        "metrics": context.metrics
    }

    write_json(context_file, context_data)
    return context_file
```

### Context Retrieval

```python
def load_context(context_id, storage_path=".claude/contexts"):
    """保存されたコンテキストを読み込み"""

    context_file = f"{storage_path}/{context_id}.json"
    if not exists(context_file):
        return None

    context_data = read_json(context_file)

    # TaskContextオブジェクトを再構築
    context = TaskContext.__new__(TaskContext)
    for key, value in context_data.items():
        setattr(context, key, value)

    return context
```

## 🔧 Utility Functions

### generate_task_id()

```python
def generate_task_id():
    """一意のタスクIDを生成"""
    import uuid
    from datetime import datetime

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    unique_id = str(uuid.uuid4())[:8]
    return f"task_{timestamp}_{unique_id}"
```

### merge_contexts()

```python
def merge_contexts(contexts):
    """複数のコンテキストをマージ"""

    if not contexts:
        return None

    # 最初のコンテキストをベースに
    merged = contexts[0]

    for context in contexts[1:]:
        # 共有データをマージ
        merged.communication["shared_data"].update(
            context.communication["shared_data"]
        )

        # 子タスクを統合
        merged.communication["child_tasks"].extend(
            context.communication["child_tasks"]
        )

        # メッセージを統合
        merged.communication["messages"].extend(
            context.communication["messages"]
        )

    return merged
```

## 📊 使用例

```python
# 新しいタスクコンテキストの作成
context = TaskContext(
    task_description="TypeScriptのエラーを修正してください",
    source="/task"
)

# コンテキストの強化
context = enhance_context_with_history(context, history_manager)

# エージェント間でのコンテキスト共有
child_context = share_context_between_agents(
    parent_context=context,
    child_agent={
        "name": "error-fixer",
        "prompt": "TypeScriptエラーを検出して修正"
    }
)

# コンテキストの永続化
save_context(context)

# メトリクスの更新
context.metrics["start_time"] = timestamp()
context.metrics["status"] = "in_progress"

# 完了時
context.metrics["end_time"] = timestamp()
context.metrics["status"] = "success"
context.metrics["quality_score"] = 0.92
```

このTaskContextにより、エージェントとコマンド間で一貫した情報共有が可能になり、より高度な協調動作が実現されます。

---

## 🎯 Skill Integration

このユーティリティは以下のスキルと統合し、タスクコンテキスト管理を最適化します。

### integration-framework (必須)

- **理由**: TaskContextの公式仕様とアーキテクチャガイダンス
- **タイミング**: TaskContext作成時に自動参照
- **トリガー**: 全コマンドでのTaskContext初期化時
- **提供内容**:
  - TaskContextインターフェース完全仕様
  - Communication Busパターン
  - エージェント/コマンドアダプターインターフェース
  - コンテキスト共有ベストプラクティス
  - Progressive Disclosure原則

### agents-and-commands (オプション)

- **理由**: エージェント選択と能力マトリックス統合
- **タイミング**: タスク意図分析時
- **トリガー**: `_analyze_intent()` 実行時
- **提供内容**:
  - タスク意図分析パターン
  - エージェント能力マッピング
  - 意思決定ツリー
  - エージェント選択基準

### mcp-tools (条件付き)

- **理由**: Context7統合とライブラリドキュメント強化
- **タイミング**: ライブラリ参照が検出された場合
- **トリガー**: タスク説明にライブラリキーワードが含まれる場合
- **提供内容**:
  - Context7統合パターン
  - ドキュメント取得戦略
  - コンテキスト強化手法
  - トークン管理ベストプラクティス

### 統合フローの例

**TaskContext作成フロー（全スキル統合）**:

```
TaskContext(task_description, source) 呼び出し
    ↓ (integration-framework参照)
標準インターフェース適用
    ↓
_detect_project_info() 実行
    ↓ (project-detector.md使用)
プロジェクト情報検出
    ↓
_create_execution_context() 実行
    ↓
Git状態、利用可能ツール検出
    ↓
_analyze_intent() 実行
    ↓ (agents-and-commands統合)
タスク意図分類
    ↓
ライブラリ参照検出？
    ↓ Yes (mcp-tools統合)
Context7からドキュメント取得
    ↓
context.documentation に保存
    ↓
TaskContext完成
```

**コンテキスト強化フロー（実行履歴統合）**:

```
enhance_context_with_history() 実行
    ↓ (integration-framework)
Communication Busで履歴アクセス
    ↓
類似タスク検索
    ↓
成功パターン抽出
    ↓
context.communication["shared_data"]["similar_tasks"] 更新
    ↓
最適アプローチ推奨
    ↓
context.communication["shared_data"]["recommended_approach"] 設定
    ↓
強化されたコンテキスト返却
```

**エージェント間コンテキスト共有**:

```
share_context_between_agents() 実行
    ↓ (integration-framework)
Communication Busパターン適用
    ↓
子TaskContext作成
    ↓
親コンテキスト情報継承:
  - project
  - execution
  - shared_data
    ↓
parent_context.communication["child_tasks"] 登録
    ↓
child_context.communication["parent_task"] 設定
    ↓
双方向リンク確立
```

### TaskContextフィールド別スキル統合

| フィールド      | 統合スキル            | 提供機能                   |
| --------------- | --------------------- | -------------------------- |
| `project`       | integration-framework | プロジェクト情報標準化     |
| `intent`        | agents-and-commands   | タスク意図分析             |
| `documentation` | mcp-tools             | ライブラリドキュメント強化 |
| `communication` | integration-framework | Communication Busパターン  |
| `metrics`       | integration-framework | メトリクス収集標準化       |

### スキル連携の利点

1. **標準化**: integration-frameworkによる統一インターフェース
2. **意図理解**: agents-and-commandsによる正確なタスク分類
3. **コンテキスト豊富化**: mcp-toolsによる最新ドキュメント統合
4. **コミュニケーション**: Communication Busによる効率的な情報共有
5. **永続化**: 統一フォーマットでのコンテキスト保存

---
