# データソース統合

Todo Orchestratorは**TodoWrite**と**.claude/TODO.md**の2つのデータソースを統合管理します。

## データソース比較

| 特徴           | TodoWrite               | .claude/TODO.md     |
| -------------- | ----------------------- | ------------------- |
| スコープ       | セッション内            | プロジェクト全体    |
| 永続性         | 一時的                  | 永続的              |
| 編集方法       | ツール経由              | 人間が直接編集可能  |
| バージョン管理 | なし                    | Git管理可能         |
| 主な用途       | 即座実行タスク（P1-P2） | 長期タスク（P3-P5） |
| 更新頻度       | リアルタイム            | 必要時に同期        |

## TodoWrite（セッション内）

### 特徴

```python
# セッション内で即座に利用可能
TodoWrite([
    {
        "content": "Fix validation bug",
        "priority": "high",
        "status": "pending"
    }
])

# リアルタイム更新
TodoWrite([
    {
        "content": "Fix validation bug",
        "priority": "high",
        "status": "completed"  # ステータス更新
    }
])
```

### 使用タイミング

- 即座実行タスク（P1-P2）: 会話中に生まれた短期タスク
- セッション固有タスク: 現在の会話コンテキストに依存
- 一時的なメモ: 実行後に削除しても良いタスク

### メリット

- ツール呼び出しで即座に利用可能
- セッション内で高速にアクセス
- 会話コンテキストと密結合

### デメリット

- セッション終了で消失
- バージョン管理不可
- 人間が直接編集不可

## .claude/TODO.md（永続的）

### 特徴

```markdown
# TODO

## 🟠 P3: Refactor auth module (1d)

**推定工数**: 8時間
**優先度**: P3 (慎重実行)
**ステータス**: pending

### 要件

- モジュール分割
- テストカバレッジ向上
- 依存関係整理

### 影響範囲

- auth/\*
- tests/auth/\*

## 🟦 P4: Implement SSO integration (2d)

**推定工数**: 16時間
**優先度**: P4 (統合実行)
**ステータス**: blocked
**依存**: Refactor auth module

### 要件

- OAuth2.0統合
- SAML対応
- 既存認証との統合
```

### 使用タイミング

- 長期タスク（P3-P5）: 複数セッションにまたがるタスク
- プロジェクト全体タスク: チーム全体で共有するタスク
- バックログ: 将来実行予定のタスク

### メリット

- セッション終了後も永続化
- Git管理でバージョン履歴保存
- 人間が直接編集可能（Markdown）
- プロジェクト全体で共有可能

### デメリット

- ファイル読み書きが必要
- 手動同期が必要な場合あり

## 統合表示

### 読み込み処理

```python
def load_integrated_tasks():
    """両データソースから統合タスク一覧を生成"""

    # 1. TodoWriteから取得
    session_tasks = TodoWrite.get_all()

    # 2. .claude/TODO.mdから取得
    persistent_tasks = []
    if os.path.exists('.claude/TODO.md'):
        persistent_tasks = parse_todo_md('.claude/TODO.md')

    # 3. 統合・重複排除
    merged = merge_tasks(session_tasks, persistent_tasks)

    # 4. 優先度ソート
    sorted_tasks = sort_by_priority(merged)

    return sorted_tasks
```

### 重複排除

```python
def merge_tasks(session_tasks, persistent_tasks):
    """タスクを統合し、重複を排除"""

    merged = []
    seen_ids = set()

    # 1. セッションタスク優先（最新）
    for task in session_tasks:
        task_id = task.get('id') or generate_id_from_content(task)
        if task_id not in seen_ids:
            task['source'] = 'TodoWrite'
            merged.append(task)
            seen_ids.add(task_id)

    # 2. 永続タスク追加（重複除外）
    for task in persistent_tasks:
        task_id = task.get('id') or generate_id_from_content(task)
        if task_id not in seen_ids:
            task['source'] = 'TODO.md'
            merged.append(task)
            seen_ids.add(task_id)

    return merged


def generate_id_from_content(task):
    """タスク内容からIDを生成（重複判定用）"""
    import hashlib

    # タイトル + 影響ファイルでハッシュ生成
    content = f"{task.get('title', task.get('content', ''))}"
    if 'files_affected' in task:
        content += '|' + '|'.join(sorted(task['files_affected']))

    return hashlib.md5(content.encode()).hexdigest()[:8]
```

### 優先度ソート

```python
def sort_by_priority(tasks):
    """優先度でソート（P1 → P5）"""

    priority_order = {
        'P1': 1,
        'P2': 2,
        'P3': 3,
        'P4': 4,
        'P5': 5
    }

    def get_priority_value(task):
        priority = task.get('priority', 'P3')
        return priority_order.get(priority, 3)

    return sorted(tasks, key=get_priority_value)
```

### 表示例

```
=== 統合タスク一覧 ===
Source: TodoWrite (4) + TODO.md (2)

[1] 🟢 P1 | Fix validation bug (1h) [TodoWrite]
[2] 🟢 P1 | Update error messages (30m) [TodoWrite]
[3] 🟡 P2 | Add profile page (4h) [TodoWrite]
[4] 🟠 P3 | Refactor auth module (1d) [TODO.md]
[5] 🟦 P4 | SSO integration (2d) [TODO.md] [blocked]
[6] 🔴 P5 | DB migration (1w) [TODO.md]
```

## 同期機能

### 手動同期

```bash
# TodoWrite → .claude/TODO.md にエクスポート
todo-orchestrator --sync export

# .claude/TODO.md → TodoWrite にインポート
todo-orchestrator --sync import

# 双方向同期（マージ）
todo-orchestrator --sync merge
```

### 自動同期

```python
def auto_sync_on_completion(task):
    """タスク完了時に自動同期"""

    if task.source == 'TodoWrite':
        # TodoWriteタスクが完了したら.claude/TODO.mdも更新
        update_todo_md(task, status='completed')

    elif task.source == 'TODO.md':
        # .claude/TODO.mdタスクが完了したらTodoWriteも更新
        TodoWrite.update(task, status='completed')


def auto_sync_on_add(task):
    """タスク追加時に自動同期"""

    # P3以上の長期タスクは.claude/TODO.mdにも記録
    if task.priority in ['P3', 'P4', 'P5']:
        append_to_todo_md(task)

    # P1-P2はTodoWriteのみ（セッション内で完結）
```

### 競合解決

```python
def resolve_conflict(task_todowrite, task_md):
    """同じタスクが両方に存在する場合の競合解決"""

    # 1. 更新日時で最新を判定
    if task_todowrite.updated_at > task_md.updated_at:
        print(f"⚠️  TodoWriteの方が新しいため、TODO.mdを上書きします")
        return task_todowrite

    elif task_md.updated_at > task_todowrite.updated_at:
        print(f"⚠️  TODO.mdの方が新しいため、TodoWriteを上書きします")
        return task_md

    # 2. 同じ更新日時の場合は手動マージ
    else:
        print(f"⚠️  競合検出: {task_todowrite.title}")
        print(f"[1] TodoWrite: {task_todowrite.status}")
        print(f"[2] TODO.md: {task_md.status}")
        choice = input("どちらを採用しますか? (1/2/merge): ")

        if choice == '1':
            return task_todowrite
        elif choice == '2':
            return task_md
        else:
            return merge_manually(task_todowrite, task_md)
```

## 使い分けガイドライン

### TodoWrite推奨

```
✓ 即座実行タスク（P1-P2）
✓ 会話中に生まれた短期タスク
✓ セッション内で完結するタスク
✓ 一時的なメモ・リマインダー
```

### .claude/TODO.md推奨

```
✓ 長期タスク（P3-P5）
✓ プロジェクト全体で共有するタスク
✓ バックログ・将来計画
✓ チーム全体で管理するタスク
✓ Git履歴として残したいタスク
```

### 両方利用

```
✓ P3以上の長期タスク → 両方に記録
✓ 段階的タスク → サブタスクはTodoWrite、親タスクは.claude/TODO.md
✓ プロジェクト移行中 → 一時的に両方で管理
```

## ベストプラクティス

### 1. 定期的な同期

```bash
# 週次でTodoWrite → .claude/TODO.mdにエクスポート
todo-orchestrator --sync export

# 完了タスクはアーカイブ
todo-orchestrator --archive completed
```

### 2. 優先度に応じた使い分け

```python
def choose_data_source(task):
    """優先度でデータソースを自動選択"""

    if task.priority in ['P1', 'P2']:
        # 即座実行 → TodoWrite
        return DataSource.TODO_WRITE

    elif task.priority in ['P3', 'P4', 'P5']:
        # 長期実行 → .claude/TODO.md
        return DataSource.TODO_MD

    else:
        # デフォルトはTodoWrite
        return DataSource.TODO_WRITE
```

### 3. 明確な命名規則

```markdown
# .claude/TODO.md

## Active Tasks（進行中）

### 🟢 P1-P2: 即座実行（セッション内）

（TodoWriteと同期）

### 🟠 P3: 慎重実行（1-2日）

- [ ] Refactor auth module

### 🟦 P4: 統合実行（2-4日）

- [ ] SSO integration

## Backlog（バックログ）

### 🔴 P5: 計画実行（1週間以上）

- [ ] Database migration
```

### 4. コメントで同期状態を記録

```markdown
<!-- TodoWrite Sync: 2024-01-15 10:30 -->

## Active Tasks

- [x] Fix validation bug (TodoWrite: completed)
- [ ] Refactor auth module (TODO.md: pending)
```

## トラブルシューティング

### 同期エラー

```bash
# 同期状態確認
todo-orchestrator --sync status

# 強制同期（競合を上書き）
todo-orchestrator --sync force-export  # TodoWrite優先
todo-orchestrator --sync force-import  # TODO.md優先

# バックアップ作成
todo-orchestrator --backup
```

### 重複タスク

```bash
# 重複検出
todo-orchestrator --check-duplicates

# 自動マージ
todo-orchestrator --merge-duplicates

# 手動確認
todo-orchestrator --list-duplicates
```

### データ整合性

```bash
# 整合性チェック
todo-orchestrator --validate

# 自動修復
todo-orchestrator --repair
```
