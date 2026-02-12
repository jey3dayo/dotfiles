# Error Handler - 統一エラーハンドリングユーティリティ

すべてのコマンドで一貫したエラー処理を提供する共通ユーティリティです。

## 🎯 Core Functions

### handle_command_error()

```python
def handle_command_error(error, context, options={}):
    """コマンド実行時のエラーを統一的に処理

    Args:
        error: 発生したエラー（Exception）
        context: TaskContext オブジェクト
        options: エラー処理オプション

    Returns:
        dict: {
            "handled": bool,
            "recovery_action": str,
            "user_message": str,
            "should_retry": bool
        }
    """

    # エラータイプの判定
    error_type = classify_error(error)

    # コンテキストへの記録
    context.metrics["error"] = {
        "type": error_type,
        "message": str(error),
        "timestamp": timestamp(),
        "stack_trace": get_stack_trace(error)
    }

    # エラータイプ別の処理
    if error_type == "network":
        return handle_network_error(error, context)
    elif error_type == "authentication":
        return handle_auth_error(error, context)
    elif error_type == "file_not_found":
        return handle_file_error(error, context)
    elif error_type == "permission":
        return handle_permission_error(error, context)
    elif error_type == "validation":
        return handle_validation_error(error, context)
    else:
        return handle_generic_error(error, context)
```

### classify_error()

```python
def classify_error(error):
    """エラータイプを分類"""

    error_str = str(error).lower()
    error_class = type(error).__name__

    # ネットワークエラー
    if any(keyword in error_str for keyword in [
        "connection", "timeout", "network", "unreachable"
    ]):
        return "network"

    # 認証エラー
    if any(keyword in error_str for keyword in [
        "authentication", "unauthorized", "forbidden", "token"
    ]):
        return "authentication"

    # ファイルエラー
    if "FileNotFoundError" in error_class or "no such file" in error_str:
        return "file_not_found"

    # 権限エラー
    if "PermissionError" in error_class or "permission denied" in error_str:
        return "permission"

    # バリデーションエラー
    if any(keyword in error_str for keyword in [
        "invalid", "validation", "malformed"
    ]):
        return "validation"

    # その他
    return "generic"
```

### Error Type Handlers

```python
def handle_network_error(error, context):
    """ネットワークエラーの処理"""
    return {
        "handled": True,
        "recovery_action": "retry_with_backoff",
        "user_message": "⚠️ ネットワークエラーが発生しました。再試行します...",
        "should_retry": True,
        "retry_delay": 5,
        "max_retries": 3
    }

def handle_auth_error(error, context):
    """認証エラーの処理"""
    return {
        "handled": True,
        "recovery_action": "request_credentials",
        "user_message": "❌ 認証エラー: 認証情報を確認してください\n" +
                       "💡 ヒント: gh auth login を実行してください",
        "should_retry": False,
        "help_command": "gh auth login"
    }

def handle_file_error(error, context):
    """ファイルエラーの処理"""
    missing_file = extract_filename_from_error(error)

    return {
        "handled": True,
        "recovery_action": "suggest_alternative",
        "user_message": f"❌ ファイルが見つかりません: {missing_file}\n" +
                       "💡 類似ファイルを検索しています...",
        "should_retry": False,
        "search_alternatives": True
    }

def handle_permission_error(error, context):
    """権限エラーの処理"""
    return {
        "handled": True,
        "recovery_action": "suggest_permission_fix",
        "user_message": "❌ 権限エラー: ファイル/ディレクトリへのアクセス権限がありません\n" +
                       "💡 ヒント: sudo や chmod で権限を確認してください",
        "should_retry": False
    }

def handle_validation_error(error, context):
    """バリデーションエラーの処理"""
    return {
        "handled": True,
        "recovery_action": "provide_guidance",
        "user_message": f"❌ 入力エラー: {str(error)}\n" +
                       "💡 正しい形式で再入力してください",
        "should_retry": False,
        "validation_help": True
    }

def handle_generic_error(error, context):
    """汎用エラーの処理"""
    return {
        "handled": False,
        "recovery_action": "log_and_fail",
        "user_message": f"❌ エラーが発生しました: {str(error)}\n" +
                       "詳細はログを確認してください",
        "should_retry": False,
        "log_details": True
    }
```

## 🔄 Retry Logic

```python
def execute_with_retry(func, context, max_retries=3, backoff_factor=2):
    """リトライロジック付きで関数を実行"""

    retry_count = 0
    last_error = None

    while retry_count <= max_retries:
        try:
            result = func()

            # 成功時のメトリクス記録
            if retry_count > 0:
                context.metrics["retries"] = retry_count

            return result

        except Exception as e:
            last_error = e
            error_info = handle_command_error(e, context)

            if not error_info["should_retry"]:
                raise

            retry_count += 1
            if retry_count <= max_retries:
                delay = error_info.get("retry_delay", 1) * (backoff_factor ** (retry_count - 1))
                print(f"⏱️ {delay}秒後に再試行します... ({retry_count}/{max_retries})")
                time.sleep(delay)
            else:
                raise Exception(f"最大リトライ回数({max_retries})を超えました") from last_error
```

## 📊 Error Logging

```python
def log_error(error, context, severity="error"):
    """エラーをログに記録"""

    log_entry = {
        "timestamp": timestamp(),
        "severity": severity,
        "command": context.source,
        "error_type": classify_error(error),
        "error_message": str(error),
        "context": {
            "task_id": context.id,
            "project_type": context.project.get("type"),
            "user_intent": context.intent.get("primary")
        }
    }

    # ログファイルへの書き込み
    log_file = ".claude/logs/errors.jsonl"
    ensure_directory(os.path.dirname(log_file))

    with open(log_file, "a") as f:
        f.write(json.dumps(log_entry, ensure_ascii=False) + "\n")

    # 重大なエラーの場合は追加アクション
    if severity == "critical":
        notify_critical_error(log_entry)
```

## 🛡️ Graceful Degradation

```python
def fallback_to_safe_mode(context, error):
    """エラー発生時の安全なフォールバック"""

    print("⚠️ エラーが発生したため、セーフモードで続行します")

    # 最小限の機能で続行
    return {
        "mode": "safe",
        "features_disabled": identify_broken_features(error),
        "fallback_strategy": "manual_intervention",
        "user_guidance": generate_recovery_steps(error, context)
    }
```

## 🎯 Usage Examples

### 基本的な使用

```python
from .shared.error_handler import handle_command_error, execute_with_retry

def execute_task_command(task_description, options={}):
    try:
        context = TaskContext(task_description, source="/task")

        # リトライ付き実行
        result = execute_with_retry(
            lambda: perform_task(context),
            context,
            max_retries=3
        )

        return result

    except Exception as e:
        error_info = handle_command_error(e, context)

        if error_info["recovery_action"] == "suggest_alternative":
            # 代替手段の提示
            alternatives = find_alternatives(context)
            print(f"💡 代替方法: {alternatives}")

        # エラーログ記録
        log_error(e, context, severity="error")

        # ユーザーへのメッセージ表示
        print(error_info["user_message"])

        raise
```

### コマンド固有のエラー処理

```python
def execute_create_pr(options):
    try:
        context = TaskContext("PR作成", source="/create-pr")

        # フォーマット実行
        formatter_result = execute_formatting(context)

        # PR作成
        pr_url = create_pull_request(context, options)

        return pr_url

    except Exception as e:
        error_info = handle_command_error(e, context, options)

        # create-pr固有のリカバリー
        if error_info["error_type"] == "authentication":
            print("GitHub認証が必要です")
            print("実行コマンド: gh auth login")

        elif error_info["error_type"] == "network":
            print("ネットワークエラー: オフラインで作業を継続しますか？")

        raise
```

## 📈 Error Metrics

```python
def get_error_statistics():
    """エラー統計の取得"""

    log_file = ".claude/logs/errors.jsonl"

    if not os.path.exists(log_file):
        return {"total_errors": 0}

    errors = []
    with open(log_file, "r") as f:
        for line in f:
            errors.append(json.loads(line))

    # 統計計算
    stats = {
        "total_errors": len(errors),
        "by_type": count_by_type(errors),
        "by_command": count_by_command(errors),
        "most_common": find_most_common_errors(errors, top=5),
        "recent_24h": filter_recent_errors(errors, hours=24)
    }

    return stats
```

## 🔗 Integration with Commands

すべてのコマンドでこのユーティリティを使用することで、一貫したエラー体験を提供します。

```python
# task.mdでの使用例
from .shared.error_handler import handle_command_error, execute_with_retry

# review.mdでの使用例
from .shared.error_handler import handle_command_error, log_error

# create-pr.mdでの使用例
from .shared.error_handler import handle_command_error, fallback_to_safe_mode
```

---

このユーティリティにより、すべてのコマンドで統一されたエラーハンドリングが可能になり、ユーザーエクスペリエンスが大幅に向上します。

---

## 🎯 Skill Integration

このユーティリティは以下のスキルと統合し、高度なエラー処理を実現します。

### integration-framework (必須)

- **理由**: エラーハンドリングの標準化とTaskContext統合
- **タイミング**: エラーハンドラー初期化時に自動参照
- **トリガー**: 全コマンドでのエラー発生時
- **提供内容**:
  - TaskContextへのエラー記録パターン
  - Communication Busエラー伝播機能
  - 統一エラー処理インターフェース
  - メトリクス収集標準化

### mcp-tools (オプション)

- **理由**: MCP関連エラーの特殊処理
- **タイミング**: MCPサーバーエラー発生時
- **トリガー**: Context7やその他MCPサーバーとの通信エラー時
- **提供内容**:
  - MCPサーバー接続エラー処理
  - 認証エラーリカバリー
  - フォールバック戦略
  - セキュリティベストプラクティス

### code-quality-improvement (条件付き)

- **理由**: エラー修正の自動化
- **タイミング**: エラー修正が自動化可能な場合
- **トリガー**: TypeScript型エラー、ESLintエラー等の検出時
- **提供内容**:
  - 自動修正戦略（Phase 1→2→3）
  - 型安全性改善パターン
  - エラー原因分析
  - 修正提案生成

### 統合フローの例

**基本エラーハンドリング（integration-framework統合）**:

```
エラー発生
    ↓
handle_command_error() 実行
    ↓
classify_error() でエラータイプ判定
    ↓ (integration-framework)
TaskContext.metrics["error"] に記録
    ↓
エラータイプ別処理:
  - network → リトライ戦略
  - authentication → 認証ガイダンス
  - validation → 入力支援
    ↓
Communication Bus でエラー伝播
    ↓
親タスクにエラー通知
```

**MCPエラーハンドリング（mcp-tools統合）**:

```
Context7通信エラー発生
    ↓
classify_error() → "mcp_connection"
    ↓ (mcp-tools統合)
MCPサーバー接続状態確認
    ↓
接続不可？
    ↓ Yes
ローカルキャッシュ確認
    ↓
キャッシュあり？
    ↓ Yes
キャッシュからドキュメント取得
    ↓
context.documentation_source = "cache"
    ↓
処理継続
```

**自動修正フロー（code-quality-improvement統合）**:

```
TypeScriptエラー検出
    ↓
classify_error() → "validation"
    ↓
修正可能なエラー？
    ↓ Yes (code-quality-improvement統合)
Phase 1: 基本的な型エラー修正
    ↓
Phase 2: any型排除
    ↓
Phase 3: 高度な型安全性向上
    ↓
自動修正完了
    ↓
TaskContext.metrics["auto_fixed"] = true
```

### エラータイプ別スキル統合

| エラータイプ   | 統合スキル               | 提供機能                         |
| -------------- | ------------------------ | -------------------------------- |
| network        | integration-framework    | リトライロジック、バックオフ戦略 |
| authentication | mcp-tools                | 認証リカバリー、セキュリティ     |
| validation     | code-quality-improvement | 自動修正、型安全性向上           |
| mcp_connection | mcp-tools                | フォールバック、キャッシュ活用   |
| file_not_found | integration-framework    | 代替ファイル検索                 |

### スキル連携の利点

1. **統一エラー処理**: integration-frameworkによる標準化されたエラーハンドリング
2. **自動リカバリー**: code-quality-improvementによる自動修正
3. **MCPサーバー対応**: mcp-toolsによる高度なMCPエラー処理
4. **コンテキスト保持**: TaskContextへのエラー記録と伝播
5. **メトリクス収集**: エラー統計とパフォーマンス追跡

---
