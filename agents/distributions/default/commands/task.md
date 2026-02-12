---
description: Intelligent task router with automatic agent selection
argument-hint: <task-description> [--interactive] [--dry-run] [--verbose] [--deep-think]
---

# Task - インテリジェント・タスク・ルーター

自然言語でタスクを指定すると、最適なエージェントを自動選択して実行する次世代統合コマンドです。

## 🎯 Core Mission

自然言語タスクを解析し、プロジェクトコンテキストを理解した上で、最適なエージェント・コマンド・ツールチェーンを選択・実行し、実用的な成果を提供する。

## 🔧 Enhanced Integration Framework

このコマンドは新しい統合フレームワークを使用して、以下の高度な機能を提供します：

- **統合オーケストレーター**: 全システムコンポーネントの協調動作
- **強化されたタスクルーター**: 機械学習ベースの最適エージェント選択
- **標準化インターフェース**: エージェント・コマンド間の seamless な連携
- **自動エラー回復**: 高度なエラー処理と回復戦略
- **パフォーマンス最適化**: コンテキストキャッシュと並列実行

## 🚀 Framework Integration

このコマンドは、統合フレームワークを通じて以下のコンポーネントと連携します：

- **統合オーケストレーター**: タスクの分析と最適なエージェントへのルーティング
- **エージェントアダプター**: 各エージェントとの統一されたインターフェース
- **コンテキストマネージャー**: プロジェクト情報と実行履歴の管理
- **エラーハンドラー**: インテリジェントなエラー回復とフォールバック処理

## 🚀 実装された機能

このコマンドは以下のインテリジェント機能を提供します：

1. **深層自然言語解析**: 多層的なタスク意図理解
2. **動的コンテキスト統合**: プロジェクト・履歴・環境の総合判断
3. **インテリジェントルーティング**: 確信度ベースの最適選択
4. **実行結果の最適化**: メトリクス駆動の継続改善

## 📋 Task Processing Architecture

### Phase 1: Multi-Layer Task Analysis

タスクを複数の観点から分析し、実行戦略を決定：

```python
# 共通ユーティリティを使用
from .shared.task_context import TaskContext
from .shared.agent_selector import analyze_task_intent, select_optimal_agent
from .shared.project_detector import detect_project_type
from .shared.context7_integration import detect_library_references, enhance_context_with_docs

def analyze_task(task_description, options={}):
    """タスクを分析し、実行計画を作成"""

    # 統一されたタスクコンテキストの作成
    context = TaskContext(task_description, source="/task")

    # Context7統合: ライブラリ参照の検出とドキュメント強化
    if not options.get('skip_documentation'):
        detected_libraries = detect_library_references(task_description)
        if detected_libraries:
            context = enhance_context_with_docs(context, detected_libraries)

    # タスク分析レポートの生成
    report = generate_task_analysis_report(context)

    return {
        "context": context,
        "report": report,
        "execution_plan": create_execution_plan(context)
    }

def generate_task_analysis_report(context):
    """タスク分析レポートを生成"""

    # ドキュメント情報のフォーマット
    doc_info = ""
    if hasattr(context, 'documentation') and context.documentation:
        doc_info = "\n📚 **Referenced Libraries**: " + ", ".join(context.documentation.keys())
        doc_info += f"\n📖 **Documentation Status**: Available ({len(context.documentation)} libraries)"

    return f"""
🎯 **Task Analysis Report**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 **Original Request**: "{context.intent['original_request']}"
🔍 **Interpreted Intent**: {context.intent['primary']['type'] if context.intent['primary'] else 'unknown'}
🎯 **Task Category**: {get_task_category(context)}
📊 **Complexity**: {calculate_complexity(context)}
⏱️ **Estimated Time**: {estimate_time(context)}{doc_info}
🔧 **Required Capabilities**: {get_required_capabilities(context)}

**Decomposed Actions**:
{format_decomposed_actions(context)}
"""
```

タスクの意図分析は共通の `analyze_task_intent()` 関数を使用します。

#### 🏗️ **Structural Layer** (Task Decomposition)

タスクを構造的に分解し、実行可能な単位に変換します：

```python
def decompose_task(context):
    """タスクを実行可能な単位に分解"""

    components = {
        "targets": identify_targets(context),
        "constraints": extract_constraints(context),
        "scope": determine_scope(context),
        "dependencies": analyze_dependencies(context)
    }

    complexity = calculate_task_complexity(components)

    if complexity < 0.8:
        return create_simple_task_plan(context, components)
    else:
        return create_complex_task_plan(context, components)
```

### Phase 2: Dynamic Context Integration

プロジェクト情報と実行履歴を統合して最適な実行戦略を決定します：

```python
def integrate_dynamic_context(context):
    """動的コンテキストを統合"""

    # プロジェクト情報は既にTaskContextに含まれている
    # context.project に以下が含まれる:
    # - type: プロジェクトタイプ
    # - stack: 技術スタック
    # - structure: プロジェクト構造
    # - conventions: プロジェクトコンベンション

    # 実行履歴との統合
    from .shared.task_context import enhance_context_with_history
    context = enhance_context_with_history(context, history_manager)

    # 制約検証
    validate_constraints(context)

    return context
```

### Phase 3: Intelligent Agent Selection

確信度ベースの多段階エージェント選択を行います：

```python
def select_agent_for_task(context):
    """タスクに最適なエージェントを選択（必ずエージェントを選択）"""

    # 共通のエージェント選択ロジックを使用
    from .shared.agent_selector import select_optimal_agent

    selection_result = select_optimal_agent(
        context.intent['original_request'],
        context
    )

    # 実行戦略の決定（必ずエージェントベース実行）
    complexity = calculate_complexity(context)

    if complexity < 0.8:
        # 単純タスク: 単一エージェントで実行（必須）
        return {
            "strategy": "single_agent",
            "primary_agent": selection_result["agent"],
            "confidence": selection_result["confidence"],
            "reasoning": selection_result["reasoning"]
        }
    else:
        # 複雑タスク: 複数エージェントによる協調実行
        return create_multi_agent_plan(context, selection_result)
```

エージェント能力マトリックスとマッピングロジックは `shared/agent-selector.md` に統一されています。

### Phase 4: Execution & Optimization

実行とリアルタイムの最適化を行います：

```python
def execute_task(context, execution_plan):
    """タスクを実行し、最適化を行う"""

    # 実行計画の表示
    display_execution_plan(execution_plan)

    # メトリクスの初期化
    context.metrics["start_time"] = timestamp()
    context.metrics["status"] = "in_progress"

    # Context7ドキュメントの適用
    if hasattr(context, 'documentation') and context.documentation:
        from .shared.context7_integration import apply_documentation_to_task
        context = apply_documentation_to_task(context, execution_plan["primary_agent"])

    try:
        # 必ずエージェントベース実行を行う
        if execution_plan["strategy"] == "single_agent":
            result = execute_single_agent(context, execution_plan)
        else:
            result = execute_multi_agent(context, execution_plan)

        # 結果の強化
        result = enhance_result(result, context)

        # メトリクスの更新
        context.metrics["end_time"] = timestamp()
        context.metrics["status"] = "success"
        context.metrics["quality_score"] = calculate_quality_score(result)

    except Exception as e:
        # エラーハンドリングとリカバリー
        result = handle_execution_error(e, context)
        context.metrics["status"] = "partial_success" if result else "failed"

    # コンテキストの永続化
    from .shared.task_context import save_context
    save_context(context)

    return result

def display_execution_plan(plan):
    """実行計画を表示"""

    # Context7情報のフォーマット
    doc_info = ""
    if plan.get('context') and hasattr(plan['context'], 'documentation'):
        docs = plan['context'].documentation
        if docs:
            doc_info = f"\n📚 **Library Docs**: {', '.join(docs.keys())}"

    print(f"""
🚀 **Task Execution Plan** (Agent-Based)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 **Strategy**: {plan['strategy']} (エージェント必須実行)
🤖 **Primary Agent**: {plan['primary_agent']}
🎯 **Confidence**: {plan['confidence']:.1%}
⏱️  **Estimated Time**: {plan.get('estimated_time', 'calculating...')}{doc_info}
""")
```

## 📊 Advanced Features

### Continuous Learning System

タスク実行から学習し、将来の精度を向上させるシステム：

```python
class LearningSystem:
    """継続的学習システム"""

    def record_execution(self, context, result):
        """実行結果を記録"""
        # TaskContextのメトリクスが既に実行情報を含んでいる
        execution_record = {
            "task_id": context.id,
            "intent": context.intent,
            "project_type": context.project["type"],
            "agent_used": result.get("agent"),
            "metrics": context.metrics,
            "timestamp": timestamp()
        }

        self.save_to_database(execution_record)
        self.update_agent_performance(execution_record)

    def generate_recommendations(self, task_description):
        """類似タスクから推奨事項を生成"""
        similar_tasks = self.find_similar_tasks(task_description)

        if similar_tasks:
            success_rate = self.calculate_success_rate(similar_tasks)
            avg_time = self.calculate_average_time(similar_tasks)
            best_agent = self.find_best_performing_agent(similar_tasks)

            return {
                "success_rate": success_rate,
                "expected_time": avg_time,
                "recommended_agent": best_agent
            }
        return None
```

### Error Handling & Recovery

インテリジェントなエラーリカバリーシステム：

**エラー分析**

- エラータイプの分類
- 重要度の評価
- 根本原因の分析

**リカバリー戦略**

- **認証エラー**: 資格情報の再取得、代替APIへのフォールバック
- **リソース制限**: タスクの分割、レート制限の実装
- **パースエラー**: 代替パーサーの使用、ファジーマッチング
- **実行タイムアウト**: タイムアウト制限の増加、実行計画の最適化

## 🎯 Main Entry Point

```python
def execute_task_command(task_description, options={}):
    """タスクコマンドのメインエントリーポイント"""

    # 共通ユーティリティをインポート
    from .shared.task_context import TaskContext
    from .shared.agent_selector import select_optimal_agent
    from .shared.project_detector import detect_project_type

    # Deep Thinking モードの検出
    enable_deep_thinking = options.get('deep_think', False) or options.get('thinking', False)

    # Deep Thinking が有効な場合、コンテキストに追加
    if enable_deep_thinking:
        options['deep_thinking_enabled'] = True
        print("🧠 Deep Thinking モードが有効になりました")

    # タスク分析
    analysis_result = analyze_task(task_description, options)
    context = analysis_result["context"]

    # Deep Thinking コンテキストの設定
    if enable_deep_thinking:
        context.thinking_mode = {
            "enabled": True,
            "complexity_threshold": 0.7,  # 複雑なタスクでより深い思考
            "focus_areas": determine_thinking_focus(task_description)
        }

    # エージェント選択
    agent_selection = select_agent_for_task(context)

    # 実行計画の作成
    execution_plan = {
        **agent_selection,
        "estimated_time": estimate_execution_time(context),
        "context": context,  # Context7情報を含む
        "deep_thinking": enable_deep_thinking
    }

    # タスク実行
    result = execute_task(context, execution_plan)

    # 学習システムへの記録
    learning_system.record_execution(context, result)

    return result

def determine_thinking_focus(task_description):
    """Deep Thinking の焦点領域を決定"""

    focus_areas = []
    description_lower = task_description.lower()

    # 技術的判断が必要な領域
    if any(keyword in description_lower for keyword in [
        "なぜ", "why", "原因", "cause", "理由", "reason"
    ]):
        focus_areas.append("root_cause_analysis")

    if any(keyword in description_lower for keyword in [
        "設計", "design", "アーキテクチャ", "architecture", "パターン", "pattern"
    ]):
        focus_areas.append("design_decisions")

    if any(keyword in description_lower for keyword in [
        "最適", "optimal", "改善", "improve", "パフォーマンス", "performance"
    ]):
        focus_areas.append("optimization_strategies")

    if any(keyword in description_lower for keyword in [
        "実装", "implement", "方法", "method", "アプローチ", "approach"
    ]):
        focus_areas.append("implementation_strategies")

    return focus_areas if focus_areas else ["general_analysis"]
```

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
/task "最新のコミットをレビュー"
/task "ステージされた変更をレビュー"
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
/task "UserRepositoryクラスの名前を変更して全ての参照を更新"
/task "このクラスの依存関係を分析して図にして"

# Context7統合によるライブラリドキュメント活用
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

# Deep Thinking モード
/task --deep-think "複雑な技術判断が必要なタスク"
/task --thinking "なぜこのエラーが発生するか調査"
```

## 📈 Metrics & Monitoring

### Execution Metrics

```markdown
## 📊 Task Execution Report

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
**Task**: "ユーザー認証機能を実装"
**Agent**: researcher
**Execution Time**: 12m 34s (estimated: 15m)
**Quality Score**: 92/100

**Performance Breakdown**:

- Analysis: 15s
- Context Loading: 8s
- Execution: 11m 42s
- Result Processing: 29s

**Resource Usage**:

- API Calls: 23
- File Operations: 17
- Memory Peak: 125MB

**Outcome**: ✅ Success
```

### Learning Insights

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

**Common Issues**:

- Missing error handling (12%)
- Incomplete tests (8%)
```

## 🔄 Integration Points

### TodoWrite Integration

実行後のフォローアップタスクを自動的にTodoリストに追加：

- 抽出されたタスクの内容
- 優先度の設定
- ステータスの初期化

### Learnings Integration

実行から得られた知見を自動的に記録：

- タスクの概要
- 発見された洞察
- 改善提案

### Review Integration

実装タスク完了後の自動レビュー起動：

- 最近の変更に焦点
- 自動修正オプション
- 品質保証

## 🚦 Quality Assurance

### Pre-execution Validation

- [ ] Task clarity and completeness check
- [ ] Resource availability verification
- [ ] Constraint compatibility validation
- [ ] Risk assessment and mitigation planning

### During Execution

- [ ] Progress checkpointing
- [ ] Resource usage monitoring
- [ ] Error detection and recovery
- [ ] Performance tracking

### Post-execution Verification

- [ ] Result completeness check
- [ ] Quality metrics evaluation
- [ ] Side effect assessment
- [ ] Documentation updates

## 🎭 Agent Profiles

エージェントの詳細なプロファイルは `shared/agent-selector.md` のAGENT_CAPABILITIESマトリックスを参照してください。

主要なエージェント：

- **error-fixer**: エラー修正、型安全性、コード品質
- **orchestrator**: 実装、リファクタリング、タスク分解
- **code-reviewer**: コードレビュー、品質評価、セキュリティ
- **researcher**: 調査、分析、問題究明
- **docs-manager**: ドキュメント管理、リンク検証
- **serena**: セマンティック分析、シンボル検索

---

## 🔗 Integration with Shared Utilities

このコマンドは以下の共通ユーティリティを使用しています：

- **`shared/task-context.md`**: 統一されたタスクコンテキスト
- **`shared/agent-selector.md`**: エージェント選択ロジック
- **`shared/project-detector.md`**: プロジェクト判定ロジック
- **`shared/context7-integration.md`**: Context7 MCPサーバー統合 (New!)

これにより、他のコマンドと一貫した動作を保証し、コードの重複を排除しています。

### Context7統合の特徴

- 自動的なライブラリ検出とドキュメント取得
- 最新のAPI情報に基づいた正確な実装支援
- エラー修正時の関連ドキュメント参照
- トークン効率的なトピック指定

---

## 🎯 Skill Integration

このコマンドは以下のスキルと統合し、タスクの性質に応じて自動的にロードします。

### integration-framework

- **理由**: TaskContext標準化とCommunication Busパターンを提供
- **タイミング**: フレームワーク理解のために自動ロード
- **トリガー**: TaskContext、エージェント選択、ワークフローオーケストレーション使用時
- **提供内容**:
  - TaskContextインターフェース仕様
  - Communication Busイベント駆動パターン
  - エージェント/コマンドアダプターパターン

### agents-and-commands

- **理由**: エージェント選択ロジックと能力マッチング
- **タイミング**: エージェントルーティング判断時に自動参照
- **トリガー**: 自然言語タスクがエージェント選択を必要とする場合
- **提供内容**:
  - エージェント能力マトリックス（AGENT_CAPABILITIES）
  - タスク意図分析パターン
  - 意思決定ツリーと選択基準

### mcp-tools

- **理由**: Context7やその他MCPサーバー統合の設定ガイダンス
- **タイミング**: MCPサーバーエラーやセットアップが必要な場合
- **トリガー**: MCP統合、外部ツール連携が必要な場合
- **提供内容**:
  - Context7統合パターン
  - セキュリティベストプラクティス
  - サーバーカタログとトラブルシューティング

### 技術スタック別スキル（自動検出）

**自動検出**: プロジェクトタイプとタスク分析に基づいて以下のスキルを自動ロード

| 検出条件               | スキル                | 提供内容                                           |
| ---------------------- | --------------------- | -------------------------------------------------- |
| TypeScriptプロジェクト | **typescript**        | 型安全性、any型排除、Result<T,E>パターン           |
| Reactプロジェクト      | **react**             | コンポーネント設計、Hooks、パフォーマンス最適化    |
| Go言語プロジェクト     | **golang**            | イディオマティックGo、エラーハンドリング、並行処理 |
| API/バックエンド       | **security**          | OWASP Top 10、入力検証、認証・認可                 |
| セマンティック解析必要 | **semantic-analysis** | シンボル検索、影響分析、依存関係追跡               |

**統合フロー**:

```
/task "TypeScript型エラーを修正"
    ↓
TaskContext作成（プロジェクト検出）
    ↓
技術スタック検出: TypeScript
    ↓
スキル自動ロード: ["typescript", "code-quality-improvement"]
    ↓
エージェント選択: error-fixer
    ↓ (スキルコンテキスト提供)
TypeScript型安全性パターン + 3層修正戦略
    ↓
実行完了
```

### スキル連携の利点

1. **コンテキスト豊富化**: タスクに関連する専門知識を自動提供
2. **一貫性**: 統一された評価基準とパターン適用
3. **効率性**: Progressive Disclosureで必要な情報のみロード
4. **拡張性**: 新しいスキルを追加するだけで自動統合

---

**目標**: エージェントの存在を意識することなく、自然な言葉でどんな開発タスクでも実行できる、真のインテリジェント開発アシスタント
