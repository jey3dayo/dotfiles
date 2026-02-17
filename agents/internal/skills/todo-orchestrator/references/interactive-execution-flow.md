# インタラクティブ実行フロー

Todo Orchestratorの中核となる3段階の実行フローを解説します。

## Phase 1: タスク表示・選択

### 統合データ読み込み

```python
def load_integrated_tasks():
    """TodoWriteと.claude/TODO.mdから統合タスク一覧を生成"""

    # 1. TodoWriteから取得
    session_tasks = TodoWrite.get_all()

    # 2. .claude/TODO.mdから取得
    persistent_tasks = read_todo_md()

    # 3. 統合処理
    merged_tasks = merge_and_deduplicate(
        session_tasks,
        persistent_tasks
    )

    # 4. 優先度ソート
    return sort_by_priority(merged_tasks)
```

### 番号付き一覧表示

```
=== 統合タスク一覧 ===
Source: TodoWrite (4) + TODO.md (2)

[1] 🟢 P1 | Fix login validation bug
    推定: 1h | 影響: auth/login.ts, tests/
    依存: なし

[2] 🟢 P1 | Update error messages
    推定: 30m | 影響: i18n/, components/
    依存: なし

[3] 🟡 P2 | Add user profile page
    推定: 4h | 影響: pages/, api/, db/
    依存: なし

[4] 🟠 P3 | Refactor auth module
    推定: 1d | 影響: auth/*, tests/auth/
    依存: なし | ブロック: [5]

[5] 🟦 P4 | Implement SSO integration
    推定: 2d | 影響: auth/, config/, api/
    依存: [4] | ステータス: ブロック中

[6] 🔴 P5 | Database migration to PostgreSQL
    推定: 1w | 影響: db/*, models/*, migrations/
    依存: なし | リスク: 高
```

### ユーザー選択

```
実行するタスク番号を選択:
  番号指定: 1, 3, 1-5, 1,3,5
  優先度: high (P1-P2), medium (P3), low (P4-P5)
  スキップ: skip, s

> 1
```

### 実行前確認

```
=== 実行前確認 ===
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

タスク:     Fix login validation bug
優先度:     P1 (即座実行) 🟢
推定工数:   1時間
実績工数:   類似タスク平均 52分

【依存関係】
  前提タスク: なし
  ブロック:   なし

【影響範囲】
  変更ファイル:
    - auth/login.ts (core)
    - tests/auth.test.ts (test)

  影響コンポーネント:
    - LoginForm component
    - AuthService
    - ValidationService

【リスク評価】
  複雑度:   低 ⭐️⭐️☆☆☆
  影響範囲: 限定的 (2ファイル)
  テスト:   既存テスト有り

  総合リスク: 低 🟢

【実行計画】
  1. バリデーションロジック修正 (20m)
  2. テストケース追加 (20m)
  3. テスト実行・確認 (10m)
  4. Lint/Format (5m)
  5. 手動確認 (5m)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

実行しますか? (y/n/skip/edit):
  y     - 実行開始
  n     - キャンセル
  skip  - 次回まで延期
  edit  - タスク編集
> y
```

### 承認処理

```python
def confirm_execution(task):
    """実行前確認と承認処理"""

    # 1. 依存関係チェック
    if task.has_blocking_dependencies():
        print(f"⚠️  依存タスクがブロック中: {task.blocked_by}")
        print("ブロックタスクを先に実行しますか? (y/n)")
        if input() == 'y':
            return execute_dependencies_first(task)
        else:
            return False

    # 2. リスク評価表示
    risk_level = assess_risk(task)
    print_risk_assessment(risk_level)

    # 3. 実行計画表示
    print_execution_plan(task)

    # 4. ユーザー承認
    response = input("実行しますか? (y/n/skip/edit): ")

    if response == 'y':
        return True
    elif response == 'skip':
        task.status = 'deferred'
        TodoWrite.update(task)
        return False
    elif response == 'edit':
        return edit_task_interactive(task)
    else:
        return False
```

## Phase 2: 自動タスク実行

### 依存関係チェック

```python
def check_dependencies(task):
    """依存関係の確認と解決"""

    # 1. 前提タスクチェック
    if task.depends_on:
        unfinished = [
            dep for dep in task.depends_on
            if not is_completed(dep)
        ]

        if unfinished:
            print(f"⚠️  未完了の前提タスク: {unfinished}")
            return False

    # 2. ファイル競合チェック
    conflicts = check_file_conflicts(task)
    if conflicts:
        print(f"⚠️  ファイル競合検出: {conflicts}")
        print("並列実行を無効化し、順次実行します。")
        task.parallel_safe = False

    return True
```

### 実行順序決定

```python
def determine_execution_order(tasks):
    """トポロジカルソートで実行順序を決定"""

    # 1. 依存グラフ構築
    graph = build_dependency_graph(tasks)

    # 2. トポロジカルソート
    ordered = topological_sort(graph)

    # 3. 並列実行グループ化
    parallel_groups = group_parallel_tasks(ordered)

    return parallel_groups

# 例:
# Input:  [Task1, Task2, Task3, Task4]
# Graph:  Task3 -> Task1
#         Task4 -> Task2, Task3
# Output: [[Task1, Task2], [Task3], [Task4]]
#         (グループ1を並列実行 → グループ2 → グループ3)
```

### 段階的実行

```
[実行中] Fix login validation bug (1/1)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[ステップ 1/5] バリデーションロジック修正
  ├─ auth/login.ts を読み込み中...
  ├─ バリデーションルール分析中...
  ├─ 修正パッチ適用中...
  └─ ✓ 完了 (18分)

[ステップ 2/5] テストケース追加
  ├─ tests/auth.test.ts を読み込み中...
  ├─ 既存テストケース分析中...
  ├─ 新規テストケース作成中...
  │   - 空の入力値
  │   - 不正な形式
  │   - 境界値テスト
  └─ ✓ 完了 (22分)

[ステップ 3/5] テスト実行・確認
  ├─ npm test auth を実行中...
  ├─ ✓ 既存テスト: 12/12 passed
  ├─ ✓ 新規テスト: 3/3 passed
  └─ ✓ 完了 (8分)

[ステップ 4/5] Lint/Format
  ├─ npm run lint を実行中...
  ├─ ✓ ESLint: 0 errors, 0 warnings
  ├─ npm run format を実行中...
  ├─ ✓ Prettier: 2 files formatted
  └─ ✓ 完了 (4分)

[ステップ 5/5] 手動確認
  ├─ ブラウザで確認中...
  ├─ ✓ 正常系: ログイン成功
  ├─ ✓ 異常系: エラーメッセージ表示
  └─ ✓ 完了 (5分)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ タスク完了 (合計: 57分 / 推定: 60分)
```

### リアルタイム進捗

```python
def execute_task_with_progress(task):
    """進捗表示付きタスク実行"""

    steps = task.execution_plan
    total_steps = len(steps)

    for i, step in enumerate(steps, 1):
        print(f"\n[ステップ {i}/{total_steps}] {step.name}")

        # ステップ実行
        start_time = time.time()

        try:
            result = execute_step(step)
            elapsed = time.time() - start_time

            # 進捗サブステップ表示
            for substep in step.substeps:
                print(f"  ├─ {substep.description}")
                if substep.completed:
                    print(f"  └─ ✓ 完了")

            print(f"  └─ ✓ 完了 ({format_time(elapsed)})")

        except Exception as e:
            print(f"  └─ ✗ 失敗: {e}")
            return handle_step_failure(step, e)

    return TaskResult(success=True)
```

### エラーハンドリング

```python
def handle_step_failure(step, error):
    """ステップ失敗時の処理"""

    print(f"\n⚠️  ステップ失敗: {step.name}")
    print(f"エラー: {error}")

    # 1. ロールバック可否確認
    if step.rollback_available:
        print("\n変更をロールバックしますか? (y/n): ")
        if input() == 'y':
            rollback_step(step)
            print("✓ ロールバック完了")

    # 2. リトライ可否確認
    if step.retry_available:
        print("\nリトライしますか? (y/n): ")
        if input() == 'y':
            return retry_step(step)

    # 3. スキップ可否確認
    if step.optional:
        print("\nスキップして続行しますか? (y/n): ")
        if input() == 'y':
            return TaskResult(skipped=True)

    # 4. タスク中断
    print("\nタスクを中断します。")
    return TaskResult(
        success=False,
        error=error,
        completed_steps=get_completed_steps()
    )
```

## Phase 3: 結果管理・更新

### 実行結果記録

```python
def record_execution_result(task, result):
    """実行結果を記録"""

    execution_record = {
        'task_id': task.id,
        'start_time': task.start_time,
        'end_time': time.time(),
        'elapsed_time': time.time() - task.start_time,
        'estimated_time': task.estimated_time,
        'success': result.success,
        'completed_steps': result.completed_steps,
        'files_changed': result.files_changed,
        'tests_passed': result.tests_passed,
        'error': result.error if not result.success else None
    }

    # 実行履歴に追加
    append_to_history(execution_record)

    return execution_record
```

### TodoWrite更新

```python
def update_todowrite(task, result):
    """TodoWriteを更新"""

    if result.success:
        # 完了マーク
        task.status = 'completed'
        task.completed_at = time.time()

        # 依存タスクのブロック解除
        for dependent in task.blocks:
            dependent.remove_blocker(task.id)
            print(f"✓ タスク {dependent.id} のブロック解除")

    else:
        # 失敗マーク
        task.status = 'failed'
        task.error = result.error
        task.retry_count += 1

    TodoWrite.update(task)
```

### 影響分析

```python
def analyze_impact(task, result):
    """タスク実行の影響を分析"""

    analysis = {
        'changed_files': result.files_changed,
        'affected_components': identify_affected_components(
            result.files_changed
        ),
        'dependent_tasks': find_dependent_tasks(task),
        'suggested_next': suggest_next_tasks(task, result)
    }

    print("\n=== 影響分析 ===")
    print(f"変更ファイル: {len(analysis['changed_files'])}")
    print(f"影響コンポーネント: {len(analysis['affected_components'])}")
    print(f"後続タスク: {len(analysis['dependent_tasks'])}")

    return analysis
```

### 次回推奨

```python
def suggest_next_tasks(completed_task, result):
    """次に実行すべきタスクを推奨"""

    candidates = []

    # 1. ブロックが解除されたタスク
    unblocked = [
        task for task in all_tasks
        if completed_task.id in task.blocked_by
    ]
    candidates.extend(unblocked)

    # 2. 関連ファイルを変更するタスク
    related = [
        task for task in all_tasks
        if has_file_overlap(task, result.files_changed)
    ]
    candidates.extend(related)

    # 3. 優先度スコアで並び替え
    scored = [
        (task, calculate_priority_score(task, completed_task))
        for task in candidates
    ]
    scored.sort(key=lambda x: x[1], reverse=True)

    # 上位3つを推奨
    return [task for task, score in scored[:3]]
```

### 学習データ蓄積

```python
def accumulate_learning_data(task, result, execution_record):
    """学習データを蓄積"""

    learning_data = {
        'task_type': task.type,
        'priority': task.priority,
        'estimated_time': task.estimated_time,
        'actual_time': execution_record['elapsed_time'],
        'accuracy': calculate_time_accuracy(
            task.estimated_time,
            execution_record['elapsed_time']
        ),
        'success': result.success,
        'complexity': task.complexity,
        'files_count': len(result.files_changed)
    }

    # 学習データベースに追加
    append_to_learning_db(learning_data)

    # 推定精度を更新
    update_estimation_model(learning_data)
```

## UI例

### 番号選択

```
=== タスク一覧 ===
[1] 🟢 P1 | Fix validation bug (1h)
[2] 🟢 P1 | Update messages (30m)
[3] 🟡 P2 | Add profile page (4h)
[4] 🟠 P3 | Refactor auth (1d)
[5] 🟦 P4 | SSO integration (2d) [blocked]

選択: 1
```

### 確認プロンプト

```
=== 実行前確認 ===
タスク: Fix validation bug
優先度: P1 🟢
推定: 1時間
影響: auth/login.ts, tests/

実行しますか? (y/n/skip/edit): y
```

### 実行ログ

```
[実行中] Fix validation bug
[1/5] バリデーション修正... ✓ (18m)
[2/5] テスト追加... ✓ (22m)
[3/5] テスト実行... ✓ (8m)
[4/5] Lint/Format... ✓ (4m)
[5/5] 手動確認... ✓ (5m)

✓ 完了 (57m / 推定60m)

次の推奨タスク:
  [2] Update messages (関連: auth/)
```
