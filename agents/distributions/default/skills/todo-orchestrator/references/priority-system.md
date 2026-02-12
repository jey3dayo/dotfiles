# 優先度システム (P1-P5)

AI駆動の優先度システムは、タスクの複雑度、影響範囲、依存関係を自動評価し、最適な実行戦略を提案します。

## 優先度レベル一覧

| レベル | アイコン | 名称     | 推定工数  | 特徴                                         |
| ------ | -------- | -------- | --------- | -------------------------------------------- |
| P1     | 🟢       | 即座実行 | 1-2時間   | 簡単、安全、即座に着手可能                   |
| P2     | 🟡       | 標準実行 | 半日      | 中程度、検証必要、標準的な作業フロー         |
| P3     | 🟠       | 慎重実行 | 1-2日     | 複雑、テスト必要、慎重な計画と実装           |
| P4     | 🟦       | 統合実行 | 2-4日     | 複数コンポーネント、統合テスト、依存関係考慮 |
| P5     | 🔴       | 計画実行 | 1週間以上 | 設計検討、高リスク、大規模変更               |

## P1: 即座実行 🟢

### 特徴

- **工数**: 1-2時間
- **複雑度**: 低（単一ファイル、明確な修正）
- **影響範囲**: 限定的（1-2ファイル）
- **依存関係**: なし
- **リスク**: 低（既存機能への影響最小）
- **テスト**: 既存テスト活用可能

### 判定基準

```python
def is_p1(task):
    """P1判定基準"""
    return (
        task.estimated_hours <= 2 and
        task.files_affected <= 2 and
        task.complexity == 'low' and
        len(task.dependencies) == 0 and
        task.has_existing_tests and
        task.risk_level == 'low'
    )
```

### 実行戦略

```yaml
実行前確認: 簡略化（5分以内）
テスト戦略: 既存テスト流用
レビュー: 自動レビュー + 目視確認
ロールバック: 必須（Git revert準備）
承認プロセス: セルフ承認可
```

### 典型例

```markdown
✓ バグ修正（バリデーション、表示崩れ）
✓ エラーメッセージ修正
✓ 軽微なUI調整
✓ ドキュメント更新
✓ 定数・設定値変更
```

### 実行例

```
[P1] Fix login validation bug

推定: 1h
影響: auth/login.ts (1ファイル)
依存: なし
リスク: 低

[実行計画]
1. バリデーション修正 (30m)
2. 既存テスト実行 (10m)
3. 手動確認 (10m)
4. コミット (10m)

自動承認 → 即座実行
```

## P2: 標準実行 🟡

### 特徴

- **工数**: 半日（3-5時間）
- **複雑度**: 中（複数ファイル、既存パターン踏襲）
- **影響範囲**: 中程度（3-5ファイル）
- **依存関係**: 1-2個
- **リスク**: 中（既存機能への影響あり）
- **テスト**: 新規テスト追加必要

### 判定基準

```python
def is_p2(task):
    """P2判定基準"""
    return (
        2 < task.estimated_hours <= 5 and
        2 < task.files_affected <= 5 and
        task.complexity in ['low', 'medium'] and
        len(task.dependencies) <= 2 and
        task.risk_level in ['low', 'medium']
    )
```

### 実行戦略

```yaml
実行前確認: 標準（10-15分）
テスト戦略: 新規テスト追加必須
レビュー: 自動 + ペアレビュー
ロールバック: 必須
承認プロセス: セルフまたはピアレビュー
並列実行: 可能（ファイル競合なし）
```

### 典型例

```markdown
✓ 新機能追加（小規模）
✓ API endpoint追加
✓ 既存機能の拡張
✓ パフォーマンス改善
✓ リファクタリング（小規模）
```

### 実行例

```
[P2] Add user profile page

推定: 4h
影響: pages/, api/, components/ (4ファイル)
依存: User API (完了済み)
リスク: 中（新規ページ追加）

[実行計画]
1. ページコンポーネント作成 (1h)
2. API統合 (1h)
3. スタイリング (1h)
4. テスト作成・実行 (1h)

承認確認 → 標準実行
```

## P3: 慎重実行 🟠

### 特徴

- **工数**: 1-2日（6-16時間）
- **複雑度**: 高（複雑なロジック、新規パターン）
- **影響範囲**: 大（6-10ファイル）
- **依存関係**: 3-5個
- **リスク**: 高（既存機能への影響大）
- **テスト**: 包括的テスト必要

### 判定基準

```python
def is_p3(task):
    """P3判定基準"""
    return (
        5 < task.estimated_hours <= 16 and
        5 < task.files_affected <= 10 and
        task.complexity in ['medium', 'high'] and
        3 <= len(task.dependencies) <= 5 and
        task.risk_level in ['medium', 'high']
    )
```

### 実行戦略

```yaml
実行前確認: 詳細（30分以上）
テスト戦略: TDD推奨、E2Eテスト追加
レビュー: 必須ペアレビュー + コードレビュー
ロールバック: 必須 + バックアップ
承認プロセス: 必ずレビュー承認
段階的実装: 推奨（フェーズ分割）
```

### 典型例

```markdown
✓ モジュールリファクタリング
✓ 認証・認可システム変更
✓ データベーススキーマ変更
✓ 複雑なビジネスロジック実装
✓ サードパーティ統合
```

### 実行例

```
[P3] Refactor auth module

推定: 1d (8h)
影響: auth/*, tests/auth/ (8ファイル)
依存: なし | ブロック: SSO integration
リスク: 高（認証は重要機能）

[実行計画]
Phase 1: 設計レビュー (1h)
Phase 2: コア機能リファクタリング (3h)
Phase 3: テスト更新 (2h)
Phase 4: 統合テスト (1h)
Phase 5: 手動確認 (1h)

詳細レビュー → 段階的実行 → ペアレビュー
```

## P4: 統合実行 🟦

### 特徴

- **工数**: 2-4日（16-32時間）
- **複雑度**: 非常に高（複数モジュール統合）
- **影響範囲**: 非常に大（10-20ファイル）
- **依存関係**: 6-10個
- **リスク**: 非常に高（システム全体への影響）
- **テスト**: 統合テスト・E2Eテスト必須

### 判定基準

```python
def is_p4(task):
    """P4判定基準"""
    return (
        16 < task.estimated_hours <= 32 and
        10 < task.files_affected <= 20 and
        task.complexity == 'high' and
        6 <= len(task.dependencies) <= 10 and
        task.risk_level == 'high' and
        task.requires_integration_tests
    )
```

### 実行戦略

```yaml
実行前確認: 非常に詳細（1時間以上）
テスト戦略: TDD必須、統合テスト、E2Eテスト
レビュー: 複数レビュアー、アーキテクトレビュー
ロールバック: 必須 + フィーチャーフラグ
承認プロセス: チームレビュー + PM承認
段階的実装: 必須（週次リリース）
依存管理: 依存タスク完了後に実行
```

### 典型例

```markdown
✓ SSO統合
✓ 決済システム統合
✓ マイクロサービス分割
✓ アーキテクチャ変更
✓ 大規模機能追加
```

### 実行例

```
[P4] Implement SSO integration

推定: 2d (16h)
影響: auth/*, config/*, api/* (15ファイル)
依存: [P3] Auth module refactor (必須)
リスク: 非常に高（認証システム変更）

[実行計画]
Phase 1: 技術設計レビュー (2h)
Phase 2: SSO provider統合 (4h)
Phase 3: 既存認証との統合 (4h)
Phase 4: テスト実装 (3h)
Phase 5: 統合テスト (2h)
Phase 6: 本番環境検証 (1h)

[依存関係]
前提: Auth module refactor (P3) → 完了待ち

アーキテクトレビュー → 承認待ち → 段階的実行
```

## P5: 計画実行 🔴

### 特徴

- **工数**: 1週間以上（40時間以上）
- **複雑度**: 極めて高（システム根幹変更）
- **影響範囲**: 極めて大（20ファイル以上）
- **依存関係**: 10個以上
- **リスク**: 極めて高（ビジネスクリティカル）
- **テスト**: 全テスト種別必須

### 判定基準

```python
def is_p5(task):
    """P5判定基準"""
    return (
        task.estimated_hours > 32 and
        task.files_affected > 20 and
        task.complexity == 'very_high' and
        len(task.dependencies) > 10 and
        task.risk_level == 'critical' and
        task.requires_design_review
    )
```

### 実行戦略

```yaml
実行前確認: RFC・設計ドキュメント作成
テスト戦略: TDD必須、全テスト種別、カナリアリリース
レビュー: 複数チームレビュー、設計レビュー
ロールバック: 必須 + ブルーグリーンデプロイ
承認プロセス: ステークホルダー全体承認
段階的実装: 必須（月次スプリント）
依存管理: プロジェクト計画必須
リスク管理: リスク評価・軽減策立案
```

### 典型例

```markdown
✓ データベースマイグレーション（MySQL → PostgreSQL）
✓ モノリスからマイクロサービスへ移行
✓ フレームワーク大幅バージョンアップ
✓ レガシーコード全面リライト
✓ 新規プロダクト機能（MVP）
```

### 実行例

```
[P5] Database migration to PostgreSQL

推定: 1w (40h)
影響: db/*, models/*, migrations/*, api/* (30+ファイル)
依存: 10+ (全DBアクセス箇所)
リスク: 極めて高（データ損失リスク）

[実行計画]
Sprint 1: RFC作成・設計レビュー (8h)
Sprint 2: 移行スクリプト作成 (8h)
Sprint 3: ステージング環境移行 (8h)
Sprint 4: データ整合性検証 (8h)
Sprint 5: 本番環境移行計画 (4h)
Sprint 6: カナリアリリース (4h)

[リスク評価]
- データ損失: 高 → 完全バックアップ必須
- ダウンタイム: 中 → ブルーグリーンデプロイ
- パフォーマンス: 中 → ロードテスト必須

RFC作成 → 設計レビュー → ステークホルダー承認 →
段階的実装 → カナリアリリース → 本番リリース
```

## 優先度評価アルゴリズム

```python
def calculate_priority(task):
    """AI駆動優先度評価"""

    # 1. 基礎スコア計算
    complexity_score = assess_complexity(task)
    impact_score = assess_impact(task)
    dependency_score = assess_dependencies(task)
    risk_score = assess_risk(task)

    # 2. 重み付け合計
    total_score = (
        complexity_score * 0.3 +
        impact_score * 0.3 +
        dependency_score * 0.2 +
        risk_score * 0.2
    )

    # 3. 優先度レベル判定
    if total_score <= 20:
        return Priority.P1
    elif total_score <= 40:
        return Priority.P2
    elif total_score <= 60:
        return Priority.P3
    elif total_score <= 80:
        return Priority.P4
    else:
        return Priority.P5


def assess_complexity(task):
    """複雑度評価（0-100）"""
    factors = [
        task.lines_of_code / 1000 * 20,      # コード量
        task.cyclomatic_complexity / 10 * 20, # 循環的複雑度
        task.new_patterns_count * 15,         # 新規パターン数
        task.external_deps_count * 10,        # 外部依存数
        task.algorithm_complexity * 15,       # アルゴリズム複雑度
    ]
    return min(sum(factors), 100)


def assess_impact(task):
    """影響範囲評価（0-100）"""
    factors = [
        task.files_affected / 20 * 25,        # 影響ファイル数
        task.components_affected / 10 * 25,   # 影響コンポーネント数
        task.users_affected / 1000 * 25,      # 影響ユーザー数
        task.api_changes_count * 12.5,        # API変更数
    ]
    return min(sum(factors), 100)


def assess_dependencies(task):
    """依存関係評価（0-100）"""
    factors = [
        len(task.depends_on) * 10,            # 前提タスク数
        len(task.blocks) * 10,                # ブロックタスク数
        task.cross_team_deps * 20,            # 他チーム依存
    ]
    return min(sum(factors), 100)


def assess_risk(task):
    """リスク評価（0-100）"""
    factors = [
        task.business_critical * 30,          # ビジネスクリティカル
        task.data_loss_risk * 25,             # データ損失リスク
        task.security_risk * 20,              # セキュリティリスク
        task.performance_impact * 15,         # パフォーマンス影響
        task.backward_compatibility * 10,     # 後方互換性
    ]
    return min(sum(factors), 100)
```

## 優先度調整ルール

### 自動昇格

以下の条件でP1に自動昇格:

- **重大バグ**: プロダクション障害、データ損失
- **セキュリティ**: 脆弱性対応
- **ブロッカー**: 他タスクをブロック中

### 自動降格

以下の条件で優先度降格:

- **依存ブロック**: 前提タスク未完了
- **リソース不足**: 必要スキルセット不在
- **期限延期**: スプリント外に移動

### 手動調整

ユーザーは優先度を手動調整可能:

```bash
# 優先度変更
todo-orchestrator update [task-id] --priority=P1

# 理由付き変更
todo-orchestrator update [task-id] --priority=P5 --reason="大規模変更のため設計レビュー必要"
```
