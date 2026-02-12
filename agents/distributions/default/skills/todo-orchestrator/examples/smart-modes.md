# スマート実行モード

高度な実行モードとバッチ処理機能を解説します。

## 実行モード一覧

| モード   | 説明           | 用途                   |
| -------- | -------------- | ---------------------- |
| auto     | AI駆動で最適化 | デフォルト、自動最適化 |
| smart    | ROI優先実行    | ビジネス価値最大化     |
| parallel | 並列実行       | 時間短縮優先           |
| estimate | 工数推定のみ   | 計画立案               |
| batch    | バッチ実行     | 非対話的一括実行       |

## autoモード: 自動最適化

### 特徴

- 依存関係を自動解決
- 実行順序を最適化
- 並列実行を自動判定
- リスクに応じた実行戦略

### 使用例

```bash
$ todo-orchestrator --mode=auto

[AI分析中] 最適な実行戦略を計算...

=== 自動最適化プラン ===

実行戦略: 依存関係優先 + 並列実行

グループ1（並列実行可能）:
  [1] 🟢 P1 | Fix validation bug (1h)
  [2] 🟢 P1 | Update error messages (30m)

グループ2（グループ1完了後）:
  [3] 🟢 P1 | Add loading indicators (45m)

グループ3（独立実行）:
  [4] 🟡 P2 | Add profile page (4h)

合計推定時間: 5h 15m
並列化による短縮: 30分

実行しますか? (y/n): y

[グループ1 並列実行]
  ✓ Fix validation bug (52m)
  ✓ Update error messages (28m)
合計: 52m（並列実行）

[グループ2 順次実行]
  ✓ Add loading indicators (40m)

[グループ3 独立実行]
  ✓ Add profile page (3h 45m)

✓ 全タスク完了 (4h 47m / 推定5h 15m)
```

### 最適化アルゴリズム

```python
def auto_optimize(tasks):
    """自動最適化プラン生成"""

    # 1. 依存関係グラフ構築
    graph = build_dependency_graph(tasks)

    # 2. トポロジカルソート
    sorted_tasks = topological_sort(graph)

    # 3. 並列実行グループ化
    groups = []
    current_group = []

    for task in sorted_tasks:
        # ファイル競合チェック
        has_conflict = any(
            has_file_overlap(task, other)
            for other in current_group
        )

        if not has_conflict:
            current_group.append(task)
        else:
            # 競合あり → 新グループ
            groups.append(current_group)
            current_group = [task]

    if current_group:
        groups.append(current_group)

    return groups
```

## smartモード: ROI優先実行

### 特徴

- ビジネス価値を最大化
- 投資対効果（ROI）で優先順位付け
- 高価値・低コストタスクを優先
- ブロック解除を考慮

### 使用例

```bash
$ todo-orchestrator --mode=smart

[AI分析中] ROI最適化...

=== スマート実行プラン ===
ROI（投資対効果）順:

優先度A: 高ROI（即座実行推奨）
  [1] 🟢 P1 | Fix validation bug
      ROI: 9.2 → 高価値(8)・低コスト(1h)・低リスク(1)
      理由: ユーザー影響大、簡単、安全

  [2] 🟢 P1 | Update error messages
      ROI: 8.0 → 高価値(7)・超低コスト(30m)・低リスク(1)
      理由: UX改善、即座実行可能

優先度B: 中ROI（標準実行）
  [3] 🟡 P2 | Add loading indicators
      ROI: 7.5 → 中価値(6)・低コスト(45m)・低リスク(2)
      理由: UX改善、既存パターン利用

  [4] 🟡 P2 | Add profile page
      ROI: 6.0 → 高価値(7)・中コスト(4h)・中リスク(3)
      理由: ビジネス要件、標準的実装

優先度C: ブロック解除（戦略的実行）
  [5] 🟠 P3 | Refactor auth module
      ROI: 5.2 → 中価値(5)・高コスト(1d)・高リスク(5)
      理由: 技術的負債削減、後続タスク（SSO）のブロック解除

推奨実行順序: 1 → 2 → 3 → 4 → 5

実行しますか? (y/n/edit): y
```

### ROI計算式

```python
def calculate_roi(task):
    """ROI（投資対効果）を計算"""

    # 1. ビジネス価値スコア（0-10）
    value = calculate_value_score(task)

    # 2. コスト（工数）
    cost = task.estimated_hours

    # 3. リスク係数（0-1）
    risk_factor = 1 - (task.risk_level / 10)

    # 4. ROI計算
    roi = (value / cost) * risk_factor

    # 5. ブロック解除ボーナス
    if task.blocks:
        unblock_bonus = len(task.blocks) * 0.5
        roi += unblock_bonus

    return roi


def calculate_value_score(task):
    """ビジネス価値スコア（0-10）"""

    score = 0

    # ユーザー影響
    score += task.user_impact * 3  # 最大3点

    # ビジネス価値
    score += task.business_value * 3  # 最大3点

    # 技術的負債削減
    score += task.tech_debt_reduction * 2  # 最大2点

    # 緊急度
    score += task.urgency * 2  # 最大2点

    return min(score, 10)
```

## parallelモード: 並列実行

### 特徴

- 時間短縮を最優先
- 最大並列度で実行
- ファイル競合を自動検出
- リソース使用率を最適化

### 使用例

```bash
$ todo-orchestrator --mode=parallel

[並列実行プラン生成中]

=== 並列実行プラン ===
最大並列度: 4（CPUコア数）

並列グループ1（4タスク同時実行）:
  [1] 🟢 P1 | Fix validation bug (1h)
      ファイル: auth/login.ts
  [2] 🟢 P1 | Update error messages (30m)
      ファイル: i18n/
  [3] 🟡 P2 | Add loading indicators (45m)
      ファイル: components/Loading.tsx
  [4] 🟡 P2 | Add profile page (4h)
      ファイル: pages/profile.tsx, api/profile.ts

ファイル競合: なし ✓
並列実行可能: ✓

推定完了時間: 4h（並列実行）
順次実行の場合: 6h 15m
短縮時間: 2h 15m（36%短縮）

実行しますか? (y/n): y

[並列実行開始] 4プロセス起動

[1/4] Fix validation bug... ✓ (52m)
[2/4] Update error messages... ✓ (28m)
[3/4] Add loading indicators... ✓ (40m)
[4/4] Add profile page... ✓ (3h 45m)

✓ 全タスク完了 (3h 45m / 推定4h)
✓ 順次実行より2h 30m短縮
```

### 並列実行制約

```python
def check_parallel_constraints(tasks):
    """並列実行可否を判定"""

    constraints = []

    # 1. ファイル競合チェック
    for i, task1 in enumerate(tasks):
        for task2 in tasks[i+1:]:
            if has_file_overlap(task1, task2):
                constraints.append({
                    'type': 'file_conflict',
                    'tasks': [task1, task2],
                    'files': get_overlapping_files(task1, task2)
                })

    # 2. 依存関係チェック
    for task in tasks:
        if task.depends_on:
            unfinished = [
                dep for dep in task.depends_on
                if not is_completed(dep)
            ]
            if unfinished:
                constraints.append({
                    'type': 'dependency',
                    'task': task,
                    'blocked_by': unfinished
                })

    # 3. リソース制約チェック
    total_memory = sum(task.estimated_memory for task in tasks)
    if total_memory > available_memory():
        constraints.append({
            'type': 'memory',
            'required': total_memory,
            'available': available_memory()
        })

    return constraints
```

## estimateモード: 工数推定のみ

### 特徴

- 実行せずに推定のみ
- 計画立案に最適
- リソース配分の参考
- スプリント計画に活用

### 使用例

```bash
$ todo-orchestrator --mode=estimate

=== 工数推定レポート ===

タスク別推定:
  [1] 🟢 P1 | Fix validation bug
      推定: 1h (最小45m / 最大1h 15m)
      精度: 95% (類似タスク実績あり)

  [2] 🟢 P1 | Update error messages
      推定: 30m (最小25m / 最大40m)
      精度: 92%

  [3] 🟡 P2 | Add profile page
      推定: 4h (最小3h / 最大5h)
      精度: 85%

  [4] 🟠 P3 | Refactor auth module
      推定: 1d (最小6h / 最大10h)
      精度: 70% (類似タスクなし)

合計推定:
  期待値: 13h 30m
  最小: 10h 10m
  最大: 16h 55m

リソース配分推奨:
  1日目: タスク1, 2, 3 (5h 30m)
  2日目: タスク4 (8h)

スプリント容量: 16h / 週
余裕: 2h 30m（緊急対応用）
```

### 推定アルゴリズム

```python
def estimate_effort(task, historical_data):
    """機械学習ベースの工数推定"""

    # 1. 類似タスク検索
    similar_tasks = find_similar_tasks(
        task,
        historical_data,
        top_k=10
    )

    if similar_tasks:
        # 2. 類似タスクの実績から推定
        base_estimate = weighted_average([
            (t.actual_hours, calculate_similarity(task, t))
            for t in similar_tasks
        ])

        # 3. 精度スコア
        accuracy = calculate_estimation_accuracy(similar_tasks)

    else:
        # 4. ルールベース推定（類似タスクなし）
        base_estimate = estimate_by_rules(task)
        accuracy = 0.5  # 低精度

    # 5. 調整係数適用
    adjustment = 1.0

    # 新規パターン
    if task.has_new_patterns:
        adjustment *= 1.3

    # 外部依存
    if task.external_dependencies:
        adjustment *= 1.2

    # 複雑度
    complexity_factor = task.complexity / 5  # 正規化
    adjustment *= (1 + complexity_factor * 0.2)

    # 6. 最終推定
    expected = base_estimate * adjustment
    minimum = expected * 0.75
    maximum = expected * 1.25

    return EffortEstimate(
        minimum=minimum,
        expected=expected,
        maximum=maximum,
        accuracy=accuracy
    )
```

## batchモード: バッチ実行

### 特徴

- 非対話的実行
- CI/CD統合
- 自動化スクリプト
- 定期実行

### 使用例

#### 1. 優先度指定

```bash
# 高優先度タスク一括実行
$ todo-orchestrator batch high

=== バッチ実行: 高優先度（P1-P2） ===
対象タスク: 4件

[1] Fix validation bug (1h)
[2] Update error messages (30m)
[3] Add loading indicators (45m)
[4] Add profile page (4h)

合計推定: 6h 15m

[バッチ実行開始]
  ✓ Fix validation bug (52m)
  ✓ Update error messages (28m)
  ✓ Add loading indicators (40m)
  ✓ Add profile page (3h 45m)

✓ 全タスク完了 (4/4成功)
```

#### 2. 範囲指定

```bash
# タスク番号範囲指定
$ todo-orchestrator batch 1-5,8

=== バッチ実行: タスク1-5, 8 ===
対象タスク: 6件

[バッチ実行開始]
  ✓ タスク1 (52m)
  ✓ タスク2 (28m)
  ✓ タスク3 (40m)
  ✓ タスク4 (3h 45m)
  ✓ タスク5 (1h 30m)
  ✗ タスク8 失敗（依存タスクが未完了）

✓ 完了 (5/6成功, 1失敗)
```

#### 3. クイック実行

```bash
# P1のみ高速実行
$ todo-orchestrator batch quick

=== バッチ実行: クイック（P1のみ） ===
対象タスク: 3件

[高速実行モード]
  ✓ Fix validation bug (52m)
  ✓ Update error messages (28m)
  ✓ Add loading indicators (40m)

✓ 全タスク完了 (2h / 推定2h 15m)
```

#### 4. CI/CD統合

```yaml
# .github/workflows/todo-batch.yml
name: Todo Batch Execution

on:
  schedule:
    - cron: "0 1 * * *" # 毎日深夜1時
  workflow_dispatch:

jobs:
  batch-execute:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Claude Code
        run: |
          npm install -g @anthropic/claude-code

      - name: Execute High Priority Tasks
        run: |
          todo-orchestrator batch high --yes --ci-mode

      - name: Report Results
        if: always()
        run: |
          todo-orchestrator --report > batch-report.md

      - name: Upload Report
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: batch-report
          path: batch-report.md
```

### バッチ実行オプション

```bash
# 自動承認（非対話）
todo-orchestrator batch high --yes

# CI/CDモード（詳細ログ）
todo-orchestrator batch high --ci-mode

# 失敗時継続
todo-orchestrator batch 1-10 --continue-on-error

# タイムアウト設定
todo-orchestrator batch all --timeout=3600

# 並列実行数指定
todo-orchestrator batch all --parallel=4

# ドライラン（実行せず計画のみ）
todo-orchestrator batch high --dry-run
```

## 品質チェックリスト

### 計画段階

- [ ] 実行モードが適切に選択されている
- [ ] 依存関係が確認されている
- [ ] リソース制約が考慮されている
- [ ] 推定工数が妥当である

### 実行段階

- [ ] 並列実行時のファイル競合がない
- [ ] 依存タスクが順次実行されている
- [ ] エラーハンドリングが適切である
- [ ] 実行ログが記録されている

### 完了段階

- [ ] 全タスクが成功している
- [ ] 推定精度が記録されている
- [ ] 学習データが蓄積されている
- [ ] レポートが生成されている

## パフォーマンス最適化

### 並列実行の最大化

```python
def maximize_parallelism(tasks):
    """並列度を最大化"""

    # 1. 依存関係グラフ
    graph = build_dependency_graph(tasks)

    # 2. 各タスクのレベル計算
    levels = calculate_task_levels(graph)

    # 3. 同レベルタスクを並列実行
    parallel_groups = group_by_level(levels)

    return parallel_groups


def calculate_task_levels(graph):
    """タスクのレベル（深さ）を計算"""

    levels = {}

    def dfs(task, level=0):
        if task in levels:
            levels[task] = max(levels[task], level)
        else:
            levels[task] = level

        for dep in task.depends_on:
            dfs(dep, level + 1)

    for task in graph.nodes:
        if not task.blocked_by:
            dfs(task)

    return levels
```

### リソース使用率の最適化

```python
def optimize_resource_usage(tasks, max_memory, max_cpu):
    """リソース制約下での最適化"""

    # 1. タスクをリソース使用量でソート
    sorted_tasks = sorted(
        tasks,
        key=lambda t: t.estimated_memory + t.estimated_cpu,
        reverse=True
    )

    # 2. ビンパッキング問題として解決
    bins = []
    current_bin = []
    current_memory = 0
    current_cpu = 0

    for task in sorted_tasks:
        if (current_memory + task.estimated_memory <= max_memory and
            current_cpu + task.estimated_cpu <= max_cpu):
            # 現在のビンに追加可能
            current_bin.append(task)
            current_memory += task.estimated_memory
            current_cpu += task.estimated_cpu
        else:
            # 新しいビンを作成
            bins.append(current_bin)
            current_bin = [task]
            current_memory = task.estimated_memory
            current_cpu = task.estimated_cpu

    if current_bin:
        bins.append(current_bin)

    return bins
```
