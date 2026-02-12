# Skill Integration Guide - スキル統合ガイド

このドキュメントは、task-routerが他のスキルと統合する方法と自動検出ロジックを説明します。

## 統合フレームワーク

### integration-framework

### 統合理由

### 統合タイミング

### トリガー条件

- TaskContextの使用
- エージェント選択
- ワークフローオーケストレーション

### 提供内容

```yaml
TaskContextインターフェース:
  - id: ユニークなタスクID
  - intent: 意図分析結果
  - project: プロジェクト情報
  - metrics: 実行メトリクス
  - documentation: Context7ドキュメント

Communication Bus:
  - イベント駆動パターン
  - コンポーネント間通信
  - 非同期メッセージング

エージェント/コマンドアダプター:
  - 統一インターフェース
  - アダプターパターン
  - エラーハンドリング統合
```

### 統合例

```python
from .shared.task_context import TaskContext
from .shared.communication_bus import CommunicationBus

# TaskContextの作成
context = TaskContext(task_description, source="/task")

# Communication Busでイベント発行
bus = CommunicationBus()
bus.publish("task.started", {
    "task_id": context.id,
    "agent": selected_agent
})
```

## エージェント選択

### agents-only

### 統合理由

### 統合タイミング

### トリガー条件

- 自然言語タスクがエージェント選択を必要とする場合
- 複数エージェント協調実行時
- エージェント能力の確認時

### 提供内容

```yaml
エージェント能力マトリックス:
  AGENT_CAPABILITIES:
    error-fixer: { error: 0.95, fix: 0.90, ... }
    orchestrator: { implement: 0.95, refactor: 0.90, ... }
    code-reviewer: { review: 0.98, analyze: 0.90, ... }
    researcher: { analyze: 0.95, implement: 0.80, ... }
    github-pr-reviewer: { github_pr: 1.00, review: 0.95, ... }
    docs-manager: { docs: 0.98, fix: 0.80, ... }
    serena: { navigate: 1.00, analyze: 0.90, ... }

タスク意図分析パターン:
  - キーワードマッチング
  - 確信度スコアリング
  - コンテキスト強化

意思決定ツリー:
  - 特殊ケース検出
  - 単一/複数エージェント判定
  - フォールバック戦略
```

### 統合例

```python
from .shared.agent_selector import (
    select_optimal_agent,
    AGENT_CAPABILITIES
)

# エージェント選択
selection_result = select_optimal_agent(
    task_description,
    context
)

# 能力マトリックス参照
capabilities = AGENT_CAPABILITIES[selection_result["agent"]]
```

## MCP統合

### mcp-tools

### 統合理由

### 統合タイミング

### トリガー条件

- MCP統合エラー発生時
- Context7セットアップが必要な場合
- 外部ツール連携が必要な場合

### 提供内容

```yaml
Context7統合パターン:
  - ライブラリ検出ロジック
  - ドキュメント取得API
  - トークン効率化

セキュリティベストプラクティス:
  - 環境変数管理
  - APIキー保護
  - 権限管理

サーバーカタログ:
  - Context7 (ライブラリドキュメント)
  - Serena (セマンティック分析)
  - MySQL (データベース)
  - Chrome (ブラウザ自動化)

トラブルシューティング:
  - 接続エラー対処
  - 認証問題の解決
  - パフォーマンス最適化
```

### 統合例

```python
from .shared.context7_integration import (
    detect_library_references,
    enhance_context_with_docs
)

# ライブラリ検出
detected_libraries = detect_library_references(task_description)
# ["react", "typescript", "next.js"]

# ドキュメント強化
context = enhance_context_with_docs(context, detected_libraries)
# context.documentation に最新API情報が追加
```

## 技術スタック別スキル

### TypeScript - typescript スキル

### 自動検出条件

- プロジェクトタイプが "typescript" を含む
- タスクに "TypeScript", "型", "type" を含む
- `.ts`, `.tsx` ファイルが対象

### 提供内容

```yaml
型安全性パターン:
  - any型排除戦略
  - 厳格な型定義
  - Result<T,E>パターン

TypeScriptベストプラクティス:
  - ジェネリック型の活用
  - 型ガード
  - discriminated unions

品質基準:
  - tsconfig.json厳格設定
  - 静的解析優先
  - 型推論の活用
```

### 統合フロー

```
Task: "TypeScript型エラーを修正"
    ↓
プロジェクト検出: TypeScript
    ↓
スキル自動ロード: typescript
    ↓
エージェント選択: error-fixer
    ↓ (スキルコンテキスト提供)
TypeScript型安全性パターン適用
    ↓
3層修正戦略実行
```

### React - react スキル

### 自動検出条件

- プロジェクトタイプが "react" を含む
- タスクに "React", "コンポーネント", "Hooks" を含む
- `.jsx`, `.tsx` ファイルが対象

### 提供内容

```yaml
コンポーネント設計パターン:
  - 関数コンポーネント優先
  - Props型定義
  - コンポーネント分割基準

Hooksベストプラクティス:
  - useState, useEffect適切な使用
  - カスタムHooks設計
  - 依存配列管理

パフォーマンス最適化:
  - useMemo, useCallback活用
  - 不要な再レンダリング防止
  - コード分割
```

### 統合フロー

```
Task: "Reactコンポーネントをリファクタリング"
    ↓
プロジェクト検出: React
    ↓
スキル自動ロード: react
    ↓
エージェント選択: orchestrator
    ↓ (スキルコンテキスト提供)
Reactコンポーネント設計パターン適用
    ↓
パフォーマンス最適化実行
```

### Go - golang スキル

### 自動検出条件

- プロジェクトタイプが "go" を含む
- タスクに "Go", "golang" を含む
- `.go` ファイルが対象

### 提供内容

```yaml
イディオマティックGo:
  - 構造体設計
  - インターフェース活用
  - 命名規則

エラーハンドリング:
  - error型の適切な使用
  - パニック処理
  - defer活用

並行処理:
  - goroutine設計
  - channel活用
  - sync.Mutex適切な使用
```

### 統合フロー

```
Task: "Go言語でREST APIを実装"
    ↓
プロジェクト検出: Go
    ↓
スキル自動ロード: golang
    ↓
エージェント選択: orchestrator
    ↓ (スキルコンテキスト提供)
イディオマティックGoパターン適用
    ↓
Clean Architecture実装
```

### セキュリティ - security スキル

### 自動検出条件

- タスクに "セキュリティ", "security", "脆弱性" を含む
- API/バックエンドプロジェクト
- 認証・認可関連タスク

### 提供内容

```yaml
OWASP Top 10チェック:
  - インジェクション攻撃防止
  - 認証・認可の適切な実装
  - 機密データ保護

入力検証:
  - バリデーションパターン
  - サニタイゼーション
  - ホワイトリスト方式

認証・認可:
  - JWT実装パターン
  - OAuth 2.0
  - RBAC設計
```

### 統合フロー

```
Task: "セキュリティ脆弱性をチェック"
    ↓
タスク分析: セキュリティ関連
    ↓
スキル自動ロード: security
    ↓
エージェント選択: code-reviewer
    ↓ (スキルコンテキスト提供)
OWASP Top 10チェック実行
    ↓
脆弱性レポート生成
```

### セマンティック分析 - semantic-analysis スキル

### 自動検出条件

- タスクに "探す", "見つける", "全て", "検索" を含む
- シンボル検索が必要
- 影響分析が必要

### 提供内容

```yaml
シンボル検索:
  - クラス/メソッド/インターフェース検索
  - パターンマッチング
  - スコープ制限

影響分析:
  - 依存関係追跡
  - 参照元検索
  - 変更影響範囲特定

依存関係追跡:
  - コールグラフ生成
  - データフロー分析
  - アーキテクチャ可視化
```

### 統合フロー

```
Task: "AuthServiceの全実装を見つけて"
    ↓
タスク分析: セマンティック分析
    ↓
スキル自動ロード: semantic-analysis
    ↓
エージェント選択: serena
    ↓ (スキルコンテキスト提供)
シンボル検索実行
    ↓
依存関係可視化
```

## 自動検出ロジック

### プロジェクトタイプ検出

```python
def detect_project_stack(project_path):
    """プロジェクトの技術スタックを検出"""

    stack = []

    # package.json チェック
    if exists("package.json"):
        package_json = read_json("package.json")
        if "typescript" in package_json.get("devDependencies", {}):
            stack.append("typescript")
        if "react" in package_json.get("dependencies", {}):
            stack.append("react")
        if "next" in package_json.get("dependencies", {}):
            stack.append("next.js")

    # go.mod チェック
    if exists("go.mod"):
        stack.append("go")

    # requirements.txt チェック
    if exists("requirements.txt"):
        stack.append("python")

    return stack
```

### タスク分析によるスキル選択

```python
def select_skills_for_task(task_description, project_stack):
    """タスクとプロジェクトから必要なスキルを選択"""

    skills = []

    # 基本統合スキル (常にロード)
    skills.append("integration-framework")
    skills.append("agents-only")

    # プロジェクトスタックに基づくスキル
    if "typescript" in project_stack:
        skills.append("typescript")
    if "react" in project_stack:
        skills.append("react")
    if "go" in project_stack:
        skills.append("golang")

    # タスク内容に基づくスキル
    description_lower = task_description.lower()

    if any(keyword in description_lower for keyword in [
        "セキュリティ", "security", "脆弱性", "vulnerability"
    ]):
        skills.append("security")

    if any(keyword in description_lower for keyword in [
        "探す", "find", "見つける", "locate", "全て", "all"
    ]):
        skills.append("semantic-analysis")

    if any(keyword in description_lower for keyword in [
        "mcp", "context7", "外部ツール", "統合"
    ]):
        skills.append("mcp-tools")

    return list(set(skills))  # 重複削除
```

### スキルロードフロー

```
Task Description
    ↓
Project Type Detection
    ├─ package.json → TypeScript, React
    ├─ go.mod → Go
    └─ requirements.txt → Python
    ↓
Task Analysis
    ├─ Security keywords → security skill
    ├─ Semantic keywords → semantic-analysis skill
    └─ MCP keywords → mcp-tools skill
    ↓
Skill Selection
    ├─ Base: integration-framework, agents-only
    ├─ Stack: typescript, react, golang, python
    └─ Task: security, semantic-analysis, mcp-tools
    ↓
Progressive Loading
    ├─ Load SKILL.md first (~12KB)
    └─ Load references on-demand (~10-14KB)
```

## 統合の利点

### 1. コンテキスト豊富化

タスクに関連する専門知識を自動提供します。

```
Task: "TypeScript型エラーを修正"
    ↓
Context Enhancement:
  - TypeScript型安全性パターン
  - any型排除戦略
  - 3層修正戦略
    ↓
Agent Execution with Enhanced Context
```

### 2. 一貫性

統一された評価基準とパターン適用を保証します。

```
All TypeScript Tasks → typescript skill
    ↓
Consistent Type Safety Standards
Consistent Code Quality Criteria
Consistent Best Practices
```

### 3. 効率性

Progressive Disclosureで必要な情報のみロードします。

```
Initial Load: SKILL.md only (~12KB)
    ↓
On-Demand: references/*.md (~10-14KB per file)
    ↓
Total: 12KB (initial) + 0-50KB (on-demand)
vs Old: 658 lines (~50KB) all at once
```

### 4. 拡張性

新しいスキルを追加するだけで自動統合できます。

```
New Skill: rust
    ↓
Add to skill-mapping-engine:
  project_patterns: ["Cargo.toml"]
  task_keywords: ["rust", "cargo", "rustc"]
    ↓
Automatic Integration
```

## パフォーマンス最適化

### キャッシング戦略

```python
# スキル設定のキャッシュ
@lru_cache(maxsize=50)
def get_skill_config(skill_name):
    return load_skill_config(skill_name)

# プロジェクトスタック検出結果のキャッシュ
@lru_cache(maxsize=10)
def cached_detect_project_stack(project_path):
    return detect_project_stack(project_path)
```

### 遅延ロード

```python
def load_skill_progressively(skill_name, needed_sections):
    """スキルを段階的にロード"""

    # SKILL.md を先にロード (必須)
    skill_overview = load_file(f"{skill_name}/SKILL.md")

    # 必要なセクションのみロード
    references = {}
    for section in needed_sections:
        if section in ["architecture", "patterns"]:
            references[section] = load_file(
                f"{skill_name}/references/{section}.md"
            )

    return {
        "overview": skill_overview,
        "references": references
    }
```

### 並列ロード

```python
async def load_multiple_skills_parallel(skill_names):
    """複数スキルを並列ロード"""

    tasks = [
        load_skill_async(skill_name)
        for skill_name in skill_names
    ]

    results = await asyncio.gather(*tasks)

    return dict(zip(skill_names, results))
```

## エラーハンドリング

### スキルロードエラー

```python
def load_skill_with_fallback(skill_name):
    """フォールバック付きスキルロード"""

    try:
        return load_skill(skill_name)
    except SkillNotFoundError:
        warn(f"Skill '{skill_name}' not found, using default")
        return load_default_skill()
    except SkillLoadError as e:
        error(f"Failed to load skill '{skill_name}': {e}")
        return None
```

### 部分的なスキル適用

```python
def apply_skills_partially(skills, context):
    """一部のスキルが失敗しても続行"""

    applied_skills = []
    failed_skills = []

    for skill in skills:
        try:
            apply_skill(skill, context)
            applied_skills.append(skill)
        except Exception as e:
            failed_skills.append((skill, e))
            warn(f"Failed to apply skill '{skill}': {e}")

    return {
        "applied": applied_skills,
        "failed": failed_skills
    }
```

## 統合検証

### スキル統合テスト

```python
def test_skill_integration():
    """スキル統合のテスト"""

    # TypeScriptプロジェクトでのテスト
    context = create_test_context(
        project_type="typescript-react",
        task="TypeScript型エラーを修正"
    )

    skills = select_skills_for_task(
        context.intent['original_request'],
        context.project['stack']
    )

    assert "typescript" in skills
    assert "integration-framework" in skills
    assert "agents-only" in skills
```

## 関連リソース

- [処理アーキテクチャ詳細](processing-architecture.md)
- [エージェント詳細プロファイル](agent-profiles.md)
- [integration-frameworkスキル](../../integration-framework/SKILL.md)
- [agents-onlyスキル](../../agents-only/SKILL.md)
- [mcp-toolsスキル](../../mcp-tools/SKILL.md)
