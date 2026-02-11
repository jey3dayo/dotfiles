# Agents Commands リファクタリング計画

## 📋 概要

エージェント関連コマンドのリファクタリングにより、以下を実現します：

1. **重複コードの排除**: プロジェクト判定、エージェント選択ロジックの共通化
2. **統合フレームワークの実装**: TaskContext、CommunicationBusなどの標準インターフェース
3. **保守性の向上**: モジュール化により変更の影響範囲を限定
4. **拡張性の確保**: 新しいエージェントやコマンドの追加が容易に

## 🏗️ アーキテクチャ

```
.claude/commands/
├── shared/                     # 共通ユーティリティ（新規）
│   ├── project-detector.md     # プロジェクト判定ロジック
│   ├── agent-selector.md       # エージェント選択ロジック
│   ├── task-context.md         # 統一タスクコンテキスト
│   └── communication-bus.md    # コミュニケーションバス（予定）
├── task.md                     # リファクタリング対象
├── review.md                   # リファクタリング対象
├── create-pr.md               # リファクタリング対象
└── ...

docs/
├── integration-framework-guide.md  # 既存（参照用）
└── ...
```

## 🔄 リファクタリング手順

### Phase 1: 共通ユーティリティの作成（完了）

✅ **project-detector.md**: プロジェクト判定ロジックの統一

- detect_project_type()
- detect_technology_stack()
- analyze_project_structure()
- detect_formatter()

✅ **agent-selector.md**: エージェント選択ロジックの統一

- select_optimal_agent()
- analyze_task_intent()
- calculate_agent_scores()

✅ **task-context.md**: 統一タスクコンテキスト

- TaskContext クラス
- コンテキスト共有機能
- 永続化機能

### Phase 2: 既存コマンドのリファクタリング

#### task.md の変更

```python
# Before: 重複したプロジェクト判定ロジック
def analyze_project_context():
    # 200行以上の重複コード...

# After: 共通ユーティリティを使用
def analyze_project_context():
    from .shared.project_detector import detect_project_type
    from .shared.task_context import TaskContext

    context = TaskContext(task_description, source="/task")
    return context
```

#### review.md の変更

```python
# Before: 独自のエージェント選択ロジック
def select_review_agent():
    # 重複した選択ロジック...

# After: 共通ユーティリティを使用
def select_review_agent(task_description):
    from .shared.agent_selector import select_optimal_agent

    result = select_optimal_agent(task_description)
    if result["agent"] != "code-reviewer":
        # review特有の処理
        result = enhance_for_review(result)
    return result
```

#### create-pr.md の変更

```python
# Before: 独自のフォーマッター検出
def detect_project_formatter():
    # 重複したフォーマッター検出...

# After: 共通ユーティリティを使用
def get_formatter():
    from .shared.project_detector import detect_formatter

    formatters = detect_formatter()
    return formatters[0] if formatters else None
```

### Phase 3: 統合テストの実装

1. **単体テスト**: 各共通ユーティリティの動作確認
2. **統合テスト**: リファクタリング後のコマンド動作確認
3. **回帰テスト**: 既存機能が正常に動作することを確認

## 📊 期待される効果

### コード削減

- task.md: 約150行削減（33%減）
- review.md: 約200行削減（32%減）
- create-pr.md: 約50行削減（25%減）

### 保守性向上

- プロジェクト判定ロジックの一元化
- エージェント選択ロジックの統一
- 新機能追加時の変更箇所が明確に

### パフォーマンス改善

- 重複した処理の排除
- コンテキストキャッシュによる高速化
- 並列実行の最適化

## ⚠️ 注意事項

1. **後方互換性**: 既存のインターフェースは維持
2. **段階的移行**: 一度に全てを変更せず、段階的に実施
3. **ドキュメント更新**: 変更に合わせてドキュメントも更新

## 🚀 実行スケジュール

1. **Week 1**: 共通ユーティリティの作成と単体テスト（完了）
2. **Week 2**: task.mdとreview.mdのリファクタリング
3. **Week 3**: その他のコマンドのリファクタリングと統合テスト
4. **Week 4**: ドキュメント更新と最終調整

## 📝 次のアクション

1. task.mdのリファクタリング開始
2. 共通ユーティリティのimport構造の確立
3. テストケースの作成

---

## 🎯 Skill Integration

このリファクタリング計画は以下のスキルと統合し、効率的なリファクタリング実行を支援します。

### integration-framework (必須)

- **理由**: リファクタリング計画の核心となるアーキテクチャ指針
- **タイミング**: リファクタリング計画立案時に自動参照
- **トリガー**: 共通ユーティリティ作成やコマンドリファクタリング時
- **提供内容**:
  - TaskContext標準化パターン
  - Communication Busアーキテクチャ
  - エージェント/コマンドアダプターインターフェース
  - 統合ベストプラクティス
  - Progressive Disclosure設計原則

### code-quality-improvement (オプション)

- **理由**: リファクタリング品質保証と段階的修正戦略
- **タイミング**: Phase 3（統合テスト）実行時
- **トリガー**: リファクタリング完了後の品質検証が必要な場合
- **提供内容**:
  - ESLintエラー修正戦略（Phase 1→2→3）
  - 型安全性改善パターン
  - コード品質評価基準
  - 段階的リファクタリング手法

### code-review (条件付き)

- **理由**: リファクタリング結果の包括的レビュー
- **タイミング**: 各Phaseの完了時またはWeek終了時
- **トリガー**: リファクタリング影響範囲が大きい場合
- **提供内容**:
  - ⭐️5段階品質評価
  - アーキテクチャ整合性検証
  - パフォーマンス影響分析
  - 保守性評価

### 統合フローの例

**Week 1: 共通ユーティリティ作成（integration-framework統合）**:

```
共通ユーティリティ作成開始
    ↓
integration-framework参照
    ↓ (TaskContext標準化)
project-detector.md作成
    ↓
agent-selector.md作成
    ↓
task-context.md作成
    ↓ (Progressive Disclosure適用)
必要な情報のみ段階的に公開
    ↓
単体テスト実行
    ↓ (code-quality-improvement統合)
ESLint/TypeScript型チェック
    ↓
Week 1完了
```

**Week 2: task.md/review.mdリファクタリング**:

```
リファクタリング開始
    ↓
既存コード読み込み
    ↓ (共通ユーティリティimport)
import from ./shared/project-detector
    ↓
import from ./shared/agent-selector
    ↓
import from ./shared/task-context
    ↓
重複コード削除（150行削減）
    ↓
統合テスト実行
    ↓ (code-review統合)
品質スコア評価
    ↓
スコア >= 80?
    ↓ Yes
Week 2完了
```

**Week 4: 最終調整とドキュメント更新**:

```
全コマンドリファクタリング完了
    ↓
包括的テスト実行
    ↓ (code-review統合)
⭐️5段階評価
    ↓
アーキテクチャ整合性検証
    ↓ (integration-framework準拠確認)
TaskContext標準化確認
    ↓
Communication Busパターン確認
    ↓
ドキュメント更新
    ↓
リファクタリング完了
```

### スキル連携の利点

1. **アーキテクチャ準拠**: integration-frameworkによる標準パターン適用
2. **品質保証**: code-quality-improvementによる段階的品質向上
3. **包括的評価**: code-reviewによる多角的品質評価
4. **保守性向上**: 共通ユーティリティ化により変更の影響範囲を最小化
5. **段階的移行**: 一度に全てを変更せず、確実にリファクタリング

---
