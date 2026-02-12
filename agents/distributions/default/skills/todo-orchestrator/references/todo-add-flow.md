# Todo追加フロー（AI駆動分析）

Todo Orchestratorの`add`機能は、単純なタスク記録ではなく、AI駆動の包括的な分析を実行します。

## AI駆動分析の5要素

```
タスク説明
    ↓
[AI分析エンジン]
    ↓
    ├─ 1. 要件抽出
    ├─ 2. 影響範囲特定
    ├─ 3. 優先度評価
    ├─ 4. 依存関係特定
    └─ 5. 工数推定
    ↓
[Todo記録] → TodoWrite + .claude/TODO.md
```

## Phase 1: タスク分析

### 1. 要件抽出

```python
def extract_requirements(description):
    """タスク説明から具体的要件を抽出"""

    # 1. 自然言語解析
    parsed = nlp_parse(description)

    # 2. 要件要素の抽出
    requirements = {
        'functional': extract_functional_reqs(parsed),
        'non_functional': extract_non_functional_reqs(parsed),
        'constraints': extract_constraints(parsed),
        'acceptance_criteria': generate_acceptance_criteria(parsed)
    }

    return requirements
```

**例**:

```
入力: "パスワードリセット機能の実装"

出力:
【機能要件】
- ユーザーがメールアドレスでパスワードリセットを要求
- リセットトークンの生成と有効期限管理
- メール送信（リセットリンク含む）
- 新パスワードの設定

【非機能要件】
- トークン有効期限: 1時間
- セキュア通信（HTTPS）
- メール送信遅延: 5秒以内

【制約】
- 既存認証システムと統合
- SMTP設定が必要

【受け入れ基準】
✓ リセットメールが届く
✓ トークンが正しく検証される
✓ パスワードが変更できる
✓ 古いパスワードでログイン不可
```

### 2. 影響範囲特定

```python
def identify_impact_scope(requirements):
    """要件から影響範囲を特定"""

    # 1. ファイル影響分析
    files_affected = analyze_file_impact(requirements)

    # 2. コンポーネント影響分析
    components_affected = analyze_component_impact(requirements)

    # 3. API影響分析
    api_changes = analyze_api_impact(requirements)

    # 4. データベース影響分析
    db_changes = analyze_db_impact(requirements)

    return ImpactScope(
        files=files_affected,
        components=components_affected,
        api_changes=api_changes,
        db_changes=db_changes
    )
```

**例**:

```
【影響ファイル】
新規作成:
  - auth/password-reset.ts
  - pages/reset-password.tsx
  - api/auth/reset-password.ts

変更:
  - auth/email-service.ts
  - auth/token-service.ts
  - config/email.ts

【影響コンポーネント】
- AuthService (変更)
- EmailService (変更)
- TokenService (新規メソッド)
- ResetPasswordForm (新規)

【API変更】
新規エンドポイント:
  POST /api/auth/request-reset
  POST /api/auth/reset-password
  GET  /api/auth/verify-token

【データベース変更】
新規テーブル:
  password_reset_tokens (token, user_id, expires_at, used)
```

### 3. 優先度評価

```python
def evaluate_priority(requirements, impact_scope):
    """優先度を自動評価（P1-P5）"""

    # 1. 複雑度スコア
    complexity = calculate_complexity_score(requirements)

    # 2. 影響範囲スコア
    impact = calculate_impact_score(impact_scope)

    # 3. リスクスコア
    risk = calculate_risk_score(requirements, impact_scope)

    # 4. 緊急度スコア
    urgency = calculate_urgency_score(requirements)

    # 5. 総合スコアで優先度決定
    total_score = (
        complexity * 0.3 +
        impact * 0.3 +
        risk * 0.2 +
        urgency * 0.2
    )

    priority = determine_priority_level(total_score)

    return PriorityEvaluation(
        priority=priority,
        complexity=complexity,
        impact=impact,
        risk=risk,
        urgency=urgency,
        reasoning=generate_reasoning(priority, total_score)
    )
```

**例**:

```
【優先度評価】
優先度: P2 (標準実行)

スコア内訳:
  複雑度:   40/100 (中程度)
  影響範囲: 50/100 (中程度)
  リスク:   30/100 (低)
  緊急度:   40/100 (中程度)

総合スコア: 42/100 → P2

【理由】
- 標準的な機能追加
- 既存パターン（トークン生成・検証）踏襲可能
- セキュリティ要件あるが既存実装参照可能
- 複数ファイル変更だが影響範囲は限定的
```

### 4. 依存関係特定

```python
def identify_dependencies(requirements, impact_scope):
    """依存関係を特定"""

    # 1. 技術的依存関係
    tech_deps = analyze_tech_dependencies(requirements)

    # 2. タスク依存関係
    task_deps = analyze_task_dependencies(impact_scope)

    # 3. ブロック関係
    blocks = identify_blocking_tasks(requirements)

    return Dependencies(
        prerequisites=tech_deps + task_deps,
        blocks=blocks
    )
```

**例**:

```
【依存関係】
前提条件:
  ✓ メール送信機能 (EmailService) → 実装済み
  ✓ トークン生成機能 (TokenService) → 実装済み
  ⚠ SMTP設定 → 未設定（要対応）

タスク依存:
  なし（独立した機能追加）

ブロック:
  このタスクは他タスクをブロックしていません

後続タスク候補:
  - 2要素認証の実装
  - ソーシャルログインの追加
```

### 5. 工数推定

```python
def estimate_effort(requirements, impact_scope, priority):
    """工数を推定"""

    # 1. ベース工数
    base_effort = calculate_base_effort(
        files_count=len(impact_scope.files),
        complexity=priority.complexity
    )

    # 2. 調整係数
    adjustment = 1.0

    # 学習曲線（新規パターン）
    if requirements.has_new_patterns:
        adjustment *= 1.3

    # 外部依存
    if requirements.external_dependencies:
        adjustment *= 1.2

    # テスト工数
    test_effort = base_effort * 0.25

    # 最終推定
    estimated_hours = (base_effort + test_effort) * adjustment

    return EffortEstimate(
        min_hours=estimated_hours * 0.8,
        max_hours=estimated_hours * 1.2,
        expected_hours=estimated_hours,
        breakdown=generate_breakdown(requirements, impact_scope)
    )
```

**例**:

```
【工数推定】
推定時間: 4-6時間 (期待値: 5時間)

内訳:
  メール送信設定: 1h
    - SMTP設定ファイル作成
    - テンプレート作成

  トークン生成・検証: 2h
    - トークンサービス拡張
    - データベーステーブル作成
    - トークン有効期限管理

  UI実装: 1-2h
    - リセット要求フォーム
    - 新パスワード設定フォーム
    - エラーハンドリング

  テスト: 1h
    - ユニットテスト
    - 統合テスト
    - E2Eテスト

調整係数:
  × 1.0 (既存パターン利用)
  × 1.0 (外部依存なし)
```

## Phase 2: Todo記録

### データソース選択

```python
def select_data_source(task, user_preference=None):
    """適切なデータソースを選択"""

    # 1. ユーザー設定を確認
    if user_preference:
        return user_preference

    # 2. タスク特性で自動判定
    if task.priority in ['P1', 'P2']:
        # 即座実行タスクはTodoWrite（セッション内）
        return DataSource.TODO_WRITE

    if task.estimated_hours > 8:
        # 長期タスクは.claude/TODO.md（永続的）
        return DataSource.TODO_MD

    if task.is_project_wide:
        # プロジェクト全体タスクは.claude/TODO.md
        return DataSource.TODO_MD

    # デフォルトはTodoWrite
    return DataSource.TODO_WRITE
```

### フォーマット統一

```python
def format_todo(task, analysis_result):
    """統一フォーマットでTodo作成"""

    todo = {
        'id': generate_id(),
        'title': task.title,
        'priority': analysis_result.priority.priority,
        'estimated_hours': analysis_result.effort.expected_hours,
        'status': 'pending',
        'created_at': now(),

        # AI分析結果
        'requirements': analysis_result.requirements,
        'impact_scope': analysis_result.impact_scope,
        'dependencies': analysis_result.dependencies,

        # メタデータ
        'tags': extract_tags(task),
        'assigned_to': None,
        'notes': []
    }

    return todo
```

**TodoWriteフォーマット例**:

```python
TodoWrite([
    {
        "content": "🟡 P2 | パスワードリセット機能の実装 (5h)",
        "priority": "medium",
        "status": "pending",
        "metadata": {
            "estimated_hours": 5,
            "files_affected": 6,
            "components": ["AuthService", "EmailService"],
            "dependencies": ["SMTP設定"]
        }
    }
])
```

**.claude/TODO.mdフォーマット例**:

```markdown
## 🟡 P2: パスワードリセット機能の実装 (5h)

**推定工数**: 4-6時間（期待値: 5時間）
**優先度**: P2 (標準実行)
**ステータス**: pending

### 要件

- ユーザーがメールアドレスでパスワードリセットを要求
- リセットトークンの生成と有効期限管理（1時間）
- メール送信（リセットリンク含む）
- 新パスワードの設定

### 影響範囲

**新規作成**:

- auth/password-reset.ts
- pages/reset-password.tsx
- api/auth/reset-password.ts

**変更**:

- auth/email-service.ts
- auth/token-service.ts

### 依存関係

- SMTP設定（未設定 → 要対応）

### 工数内訳

1. メール送信設定 (1h)
2. トークン生成・検証 (2h)
3. UI実装 (1-2h)
4. テスト (1h)
```

### 重複チェック

```python
def check_duplicate(new_task, existing_tasks):
    """重複タスクをチェック"""

    for existing in existing_tasks:
        # 1. タイトル類似度
        title_similarity = calculate_similarity(
            new_task.title,
            existing.title
        )

        # 2. 影響範囲重複
        scope_overlap = calculate_scope_overlap(
            new_task.impact_scope,
            existing.impact_scope
        )

        # 3. 重複判定
        if title_similarity > 0.8 or scope_overlap > 0.7:
            return DuplicateResult(
                is_duplicate=True,
                existing_task=existing,
                similarity=max(title_similarity, scope_overlap),
                suggestion='merge_or_update'
            )

    return DuplicateResult(is_duplicate=False)
```

## Phase 3: 自動候補提案

### パターン学習

```python
def learn_from_history(task, analysis_result, execution_result):
    """過去実行結果から学習"""

    learning_data = {
        'task_type': task.type,
        'estimated_hours': analysis_result.effort.expected_hours,
        'actual_hours': execution_result.elapsed_time,
        'accuracy': calculate_accuracy(
            analysis_result.effort.expected_hours,
            execution_result.elapsed_time
        ),
        'complexity_score': analysis_result.priority.complexity,
        'impact_score': analysis_result.priority.impact,
        'success': execution_result.success
    }

    # 学習モデル更新
    update_estimation_model(learning_data)
    update_priority_model(learning_data)
```

### 類似度計算

```python
def calculate_task_similarity(task1, task2):
    """タスク間の類似度を計算"""

    # 1. タイトル類似度（TF-IDF）
    title_sim = calculate_tfidf_similarity(
        task1.title,
        task2.title
    )

    # 2. 影響ファイル重複度
    file_overlap = len(
        set(task1.files) & set(task2.files)
    ) / max(len(task1.files), len(task2.files))

    # 3. コンポーネント重複度
    component_overlap = len(
        set(task1.components) & set(task2.components)
    ) / max(len(task1.components), len(task2.components))

    # 4. 総合類似度
    similarity = (
        title_sim * 0.4 +
        file_overlap * 0.3 +
        component_overlap * 0.3
    )

    return similarity
```

### ROI最適化

```python
def suggest_next_tasks(current_state):
    """ROI（投資対効果）最適化でタスク候補提案"""

    candidates = get_pending_tasks()

    scored = []
    for task in candidates:
        # 1. 価値スコア
        value = calculate_value_score(task)

        # 2. コストスコア
        cost = task.estimated_hours

        # 3. リスクスコア
        risk = task.risk_level

        # 4. ROIスコア
        roi = (value / cost) * (1 - risk)

        scored.append((task, roi))

    # ROI降順でソート
    scored.sort(key=lambda x: x[1], reverse=True)

    # 上位5つを推奨
    return [task for task, roi in scored[:5]]


def calculate_value_score(task):
    """タスクの価値スコアを計算"""

    score = 0

    # ビジネス価値
    score += task.business_value * 30

    # ユーザー影響
    score += task.user_impact * 25

    # 技術的負債削減
    score += task.tech_debt_reduction * 20

    # ブロック解除
    score += len(task.blocks) * 15

    # 依存関係の少なさ
    score += (10 - len(task.dependencies)) * 10

    return score
```

## 実行例

### 基本的な追加

```bash
$ todo-orchestrator add "パスワードリセット機能の実装"

[分析中] タスク要件を分析しています...
  ├─ 要件抽出... ✓
  ├─ 影響範囲特定... ✓
  ├─ 優先度評価... ✓
  ├─ 依存関係特定... ✓
  └─ 工数推定... ✓

=== AI分析結果 ===
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

【優先度】
🟡 P2 (標準実行)

理由:
- 標準的な機能追加
- 既存パターン踏襲可能
- 複数ファイル変更だが影響範囲は限定的

【推定工数】
4-6時間 (期待値: 5時間)

内訳:
  - メール送信設定: 1h
  - トークン生成・検証: 2h
  - UI実装: 1-2h
  - テスト: 1h

【影響範囲】
新規作成: 3ファイル
変更: 3ファイル
影響コンポーネント: AuthService, EmailService, TokenService

【依存関係】
前提: SMTP設定 (未設定 → 要対応)
ブロック: なし

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

追加しますか? (y/n/edit):
  y     - そのまま追加
  n     - キャンセル
  edit  - 編集してから追加
> y

✓ TodoWriteに追加しました
```

### 優先度指定で追加

```bash
$ todo-orchestrator add "緊急バグ修正" --priority=P1

[分析中] タスク要件を分析しています...

⚠ 指定優先度(P1)とAI推定(P2)が異なります。

AI推定: P2 (標準実行)
理由: 影響範囲が中程度、既存テストあり

指定通りP1で追加しますか? (y/n/auto):
  y    - P1で追加
  n    - P2で追加
  auto - AI推定を採用
> y

✓ P1として追加しました
```

### 候補提案

```bash
$ todo-orchestrator --suggest

[分析中] 最適なタスク候補を提案しています...

=== おすすめタスク（ROI順） ===

[1] 🟢 P1 | Fix validation bug (1h)
    ROI: 9.2 → 高価値・低コスト・低リスク
    理由: 簡単・安全・ユーザー影響大

[2] 🟡 P2 | Add loading states (2h)
    ROI: 7.5 → UX改善・標準実装
    理由: ユーザー体験向上、既存パターン利用

[3] 🟡 P2 | パスワードリセット機能 (5h)
    ROI: 6.8 → ビジネス価値高
    理由: セキュリティ強化、ユーザー要望

[4] 🟠 P3 | Refactor auth module (1d)
    ROI: 5.2 → 技術的負債削減
    理由: 後続タスク(SSO)のブロック解除

[5] 🟢 P1 | Update error messages (30m)
    ROI: 8.0 → 高速・高価値
    理由: ユーザー体験改善、即座実行可能

実行したいタスク番号: 1
```
