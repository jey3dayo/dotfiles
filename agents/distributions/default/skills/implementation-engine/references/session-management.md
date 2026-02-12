# Session Management

Implementation Engineのセッション管理システム。`implement/` ディレクトリ構造、`plan.md`/`state.json` フォーマット、自動レジューム機能の詳細。

## ディレクトリ構造

### セッションファイルの配置:

```
<project-root>/
└── implement/
    ├── plan.md              # 実装計画と進捗
    ├── state.json           # セッション状態とチェックポイント
    └── source-analysis.md   # 元のソース詳細分析（Deep Validation時に作成）
```

### 重要:

### 禁止:

- `$HOME/implement/` - HOMEディレクトリには作成しない
- `../implement/` - 親ディレクトリには作成しない
- 絶対パス以外の場所 - 必ず現在の作業ディレクトリ内

## plan.md フォーマット

### 基本構造

```markdown
# Implementation Plan - [timestamp]

## Source Analysis

- **Source Type**: [URL/Local/Description]
- **Source Location**: [actual path/URL]
- **Core Features**: [list of features to implement]
- **Dependencies**: [required libraries/frameworks]
- **Complexity**: [Simple/Medium/Complex/Very Complex]
- **Estimated Time**: [hours]

## Target Integration

- **Integration Points**: [where it connects in project]
- **Affected Files**: [files to modify/create]
- **Pattern Matching**: [how to adapt to project style]
- **Architecture Compatibility**: [alignment with project architecture]

## Implementation Tasks

### Phase 1: Setup

- [ ] Create base directory structure
- [ ] Initialize configuration files
- [ ] Set up type definitions

### Phase 2: Core Logic

- [ ] Implement main business logic
- [ ] Add data layer integration
- [ ] Create utility functions

### Phase 3: Integration

- [ ] Connect to authentication
- [ ] Wire up state management
- [ ] Add routing configuration

### Phase 4: UI/UX

- [ ] Create base components
- [ ] Add styling
- [ ] Implement interactions

### Phase 5: Testing

- [ ] Write unit tests
- [ ] Add integration tests
- [ ] Perform manual testing

### Phase 6: Documentation

- [ ] Update README
- [ ] Add inline documentation
- [ ] Create usage examples

## Validation Checklist

- [ ] All features implemented
- [ ] Tests written and passing
- [ ] No broken functionality
- [ ] Documentation updated
- [ ] Integration points verified
- [ ] Performance acceptable
- [ ] Security reviewed
- [ ] Accessibility checked

## Risk Mitigation

- **Potential Issues**:

  - [Issue 1]: [Description and impact]
  - [Issue 2]: [Description and impact]

- **Rollback Strategy**:
  - Git checkpoints at each phase
  - Backup of modified files
  - Revert plan if tests fail

## Progress Tracking

- **Started**: [timestamp]
- **Last Updated**: [timestamp]
- **Current Phase**: [phase number and name]
- **Completion**: [X/Y tasks] ([percentage]%)
```

### セクション詳細

### Source Analysis:

元のソースに関する完全な情報。実装の基礎となる分析。

- **Source Type**: URL, Local Path, Description, Implementation Plan
- **Source Location**: 正確なパスまたはURL
- **Core Features**: 実装する機能のリスト（優先順位付き）
- **Dependencies**: 必要なライブラリとバージョン
- **Complexity**: 実装の複雑さ評価
- **Estimated Time**: 推定所要時間

### Target Integration:

プロジェクトへの統合方法。

- **Integration Points**: 既存システムとの接続箇所
- **Affected Files**: 変更または作成するファイルのリスト
- **Pattern Matching**: プロジェクトスタイルへの適応方法
- **Architecture Compatibility**: プロジェクトアーキテクチャとの整合性

### Implementation Tasks:

フェーズ別のタスクリスト。チェックボックスで進捗を追跡。

```markdown
- [ ] Pending task
- [x] Completed task
- [⏳] In-progress task (optional)
```

### Validation Checklist:

完了基準。すべてチェックされるまで実装は完了とみなされない。

### Risk Mitigation:

潜在的な問題とロールバック戦略。

### Progress Tracking:

セッションのメタデータと進捗。

## state.json フォーマット

### 基本構造

```json
{
  "session_id": "impl-2024-01-15-1234",
  "started": "2024-01-15T10:00:00Z",
  "last_updated": "2024-01-15T14:30:00Z",
  "current_phase": "execution",
  "current_task": "Add API integration layer",
  "completed_tasks": [
    "Create base module structure",
    "Implement core business logic",
    "Integrate with existing auth system"
  ],
  "total_tasks": 15,
  "completion_percentage": 53,
  "checkpoints": [
    {
      "timestamp": "2024-01-15T10:30:00Z",
      "phase": "setup",
      "task": "Create base module structure",
      "git_commit": "abc123def456",
      "note": "Initial structure with TypeScript setup"
    },
    {
      "timestamp": "2024-01-15T11:45:00Z",
      "phase": "execution",
      "task": "Implement core business logic",
      "git_commit": "def456ghi789",
      "note": "Core functionality with error handling"
    }
  ],
  "source": {
    "type": "URL",
    "location": "https://github.com/user/repo",
    "analyzed": true
  },
  "project": {
    "type": "Next.js",
    "language": "TypeScript",
    "patterns_analyzed": true
  },
  "quality_checks": {
    "lint_passing": true,
    "tests_passing": true,
    "type_check_passing": true,
    "last_check": "2024-01-15T14:30:00Z"
  }
}
```

### フィールド説明

### session_id:

セッションの一意識別子。フォーマット: `impl-YYYY-MM-DD-HHMM`

### started / last_updated:

ISO 8601形式のタイムスタンプ。

### current_phase:

現在のフェーズ:

- `setup` - Phase 1: Initial Setup & Analysis
- `planning` - Phase 2: Strategic Planning
- `adaptation` - Phase 3: Intelligent Adaptation
- `execution` - Phase 4: Implementation Execution
- `qa` - Phase 5: Quality Assurance
- `validation` - Phase 6: Implementation Validation

### current_task:

現在実行中のタスクの説明。

### completed_tasks:

完了したタスクのリスト。

### total_tasks:

計画された全タスク数。

### completion_percentage:

進捗率（0-100）。

### checkpoints:

各チェックポイントの詳細:

- `timestamp` - チェックポイント作成時刻
- `phase` - フェーズ名
- `task` - 完了したタスク
- `git_commit` - Gitコミットハッシュ（あれば）
- `note` - 追加のメモ

### source:

ソース情報:

- `type` - URL, Local, Description, Plan
- `location` - パスまたはURL
- `analyzed` - 分析完了フラグ

### project:

プロジェクト情報:

- `type` - プロジェクトタイプ（Next.js, React, Express等）
- `language` - 主要言語
- `patterns_analyzed` - パターン分析完了フラグ

### quality_checks:

品質チェック状態:

- `lint_passing` - Lintチェックパス
- `tests_passing` - テストパス
- `type_check_passing` - 型チェックパス
- `last_check` - 最後のチェック時刻

## 自動レジューム機能

### レジューム判定ロジック

```python
def should_resume_session():
    """セッションを自動的にレジュームすべきか判定"""
    # 1. implement ディレクトリの存在確認
    if not os.path.exists('implement/'):
        return False

    # 2. 必須ファイルの存在確認
    has_plan = os.path.exists('implement/plan.md')
    has_state = os.path.exists('implement/state.json')

    if not (has_plan and has_state):
        return False

    # 3. ユーザーが明示的に新規セッションを要求していないか
    if user_specified_new_session():
        return False

    # 4. state.json が有効か確認
    try:
        with open('implement/state.json') as f:
            state = json.load(f)
        return bool(state.get('session_id'))
    except (json.JSONDecodeError, FileNotFoundError):
        return False
```

### レジュームプロセス

### ステップ1: セッションファイルのロード

```python
# state.json をロード
with open('implement/state.json') as f:
    state = json.load(f)

# plan.md をロード
with open('implement/plan.md') as f:
    plan = f.read()
```

### ステップ2: 進捗サマリーの生成

```markdown
## Session Resume

Session ID: impl-2024-01-15-1234
Started: 2024-01-15 10:00:00
Last Checkpoint: 2024-01-15 14:30:00

Progress: 8/15 tasks completed (53%)
Current Phase: Execution
Current Task: Add API integration layer

Recent Checkpoints:

- Create base module structure (10:30)
- Implement core business logic (11:45)
- Integrate with existing auth system (14:30)

Next Steps:

1. Complete API integration layer
2. Add UI components
3. Write tests
```

### ステップ3: コンテキストの復元

```python
# 前回の決定を復元
previous_decisions = extract_decisions_from_plan(plan)

# プロジェクト分析結果を復元
project_context = state['project']

# 品質チェック状態を復元
quality_status = state['quality_checks']
```

### ステップ4: 継続実行

最後のチェックポイントから次のタスクに進む。

### セッション操作コマンド

### 自動検出とレジューム:

```bash
/implement
# → 自動的に既存セッションを検出してレジューム
```

### 明示的レジューム:

```bash
/implement resume
# → 必ず既存セッションをレジューム（ない場合はエラー）
```

### ステータス確認:

```bash
/implement status
# → 現在のセッション状態を表示（実装は開始しない）
```

### 新規セッション開始:

```bash
/implement new [source]
# → 既存セッションを無視して新規開始
```

## セッション更新パターン

### タスク完了時の更新

```python
def complete_task(task_name):
    """タスク完了時の更新処理"""
    # 1. state.json を更新
    state['completed_tasks'].append(task_name)
    state['completion_percentage'] = calculate_percentage(state)
    state['last_updated'] = current_timestamp()

    # 2. plan.md のチェックボックスを更新
    update_checkbox_in_plan(task_name, checked=True)

    # 3. チェックポイントを記録
    checkpoint = {
        'timestamp': current_timestamp(),
        'phase': state['current_phase'],
        'task': task_name,
        'git_commit': get_last_commit_hash(),
        'note': f"Completed {task_name}"
    }
    state['checkpoints'].append(checkpoint)

    # 4. 次のタスクを設定
    state['current_task'] = get_next_task(state)

    # 5. ファイルに書き込み
    save_state(state)
    save_plan(plan)
```

### フェーズ遷移時の更新

```python
def transition_phase(from_phase, to_phase):
    """フェーズ遷移時の更新処理"""
    # 1. 現在のフェーズが完了しているか確認
    if not is_phase_complete(from_phase):
        raise ValueError(f"Phase {from_phase} is not complete")

    # 2. state.json を更新
    state['current_phase'] = to_phase
    state['last_updated'] = current_timestamp()

    # 3. チェックポイントを記録
    checkpoint = {
        'timestamp': current_timestamp(),
        'phase': to_phase,
        'task': f"Phase transition: {from_phase} → {to_phase}",
        'note': f"Completed {from_phase}, starting {to_phase}"
    }
    state['checkpoints'].append(checkpoint)

    # 4. Git checkpoint を作成
    git_commit(f"checkpoint: complete {from_phase} phase")

    # 5. ファイルに書き込み
    save_state(state)
```

### 品質チェック後の更新

```python
def update_quality_checks():
    """品質チェック実行後の更新処理"""
    # 1. 各チェックを実行
    lint_result = run_lint()
    test_result = run_tests()
    typecheck_result = run_typecheck()

    # 2. state.json を更新
    state['quality_checks'] = {
        'lint_passing': lint_result.success,
        'tests_passing': test_result.success,
        'type_check_passing': typecheck_result.success,
        'last_check': current_timestamp()
    }

    # 3. 失敗がある場合は記録
    if not all([lint_result.success, test_result.success, typecheck_result.success]):
        state['quality_issues'] = {
            'lint_errors': lint_result.errors,
            'test_failures': test_result.failures,
            'type_errors': typecheck_result.errors
        }

    # 4. ファイルに書き込み
    save_state(state)
```

## セッション永続化

### ファイル書き込みタイミング

### 必ず書き込むタイミング:

1. タスク完了時
2. フェーズ遷移時
3. 品質チェック実行後
4. エラー発生時
5. ユーザーがセッションを中断する前

### 書き込み頻度:

- 最小間隔: 5分（自動保存）
- 推奨間隔: タスク単位

### エラーハンドリング

### state.json が破損している場合:

```python
try:
    with open('implement/state.json') as f:
        state = json.load(f)
except json.JSONDecodeError:
    # plan.md から状態を再構築
    state = reconstruct_state_from_plan('implement/plan.md')
    save_state(state)
```

### plan.md が破損している場合:

```python
try:
    with open('implement/plan.md') as f:
        plan = f.read()
    # 基本的なMarkdown構造を検証
    validate_plan_structure(plan)
except (FileNotFoundError, ValueError):
    # state.json から計画を再構築
    plan = reconstruct_plan_from_state(state)
    save_plan(plan)
```

### 両方が破損している場合:

```bash
Error: Session files are corrupted

Options:
1. Start a new session: /implement new [source]
2. Manually fix files in implement/ directory
3. Delete implement/ and restart
```

## セッションのクリーンアップ

### 完了時のクリーンアップ

```python
def cleanup_on_completion():
    """実装完了時のクリーンアップ"""
    # 1. 最終チェックポイントを記録
    final_checkpoint = {
        'timestamp': current_timestamp(),
        'phase': 'completed',
        'task': 'Implementation completed',
        'note': 'All tasks completed and validated'
    }
    state['checkpoints'].append(final_checkpoint)

    # 2. 完了フラグを設定
    state['completed'] = True
    state['completion_percentage'] = 100

    # 3. ファイルに書き込み
    save_state(state)

    # 4. アーカイブ（オプション）
    archive_session('implement/', 'implement-archive/')
```

### 中断時の保存

```python
def save_on_interrupt():
    """中断時の保存処理"""
    # 1. 現在の状態を保存
    state['last_updated'] = current_timestamp()
    state['interrupted'] = True
    save_state(state)

    # 2. plan.md を保存
    save_plan(plan)

    # 3. メッセージ表示
    print("Session saved. Resume with: /implement resume")
```

## ベストプラクティス

### セッション管理:

1. 頻繁にチェックポイントを作成（タスク単位）
2. 意味のあるコミットメッセージを使用
3. state.json と plan.md を常に同期
4. 品質チェックを定期的に実行

### ファイル構造:

1. `implement/` は必ず現在のディレクトリに作成
2. 追加ファイルは `implement/` 内に配置
3. 一時ファイルは `.gitignore` に追加

### エラー対策:

1. 定期的なバックアップ（Git経由）
2. state.json の検証
3. plan.md の構造チェック
4. 破損時の再構築ロジック

### パフォーマンス:

1. 大きなファイルは `implement/` に含めない
2. state.json は軽量に保つ（<10KB推奨）
3. チェックポイントは過去100個まで保持

## トラブルシューティング

### 問題: セッションが見つからない

```bash
# 確認
pwd                    # プロジェクトルートにいるか？
ls -la implement/      # ディレクトリは存在するか？

# 解決
cd <project-root>      # プロジェクトルートに移動
/implement resume      # レジューム
```

### 問題: state.json が破損

```bash
# 確認
cat implement/state.json | jq .   # JSON構文チェック

# 解決
# plan.md から再構築
/implement rebuild-state
```

### 問題: plan.md とstate.jsonが不一致

```bash
# 確認
/implement status      # 不一致を検出

# 解決
/implement sync-files  # 同期
```
