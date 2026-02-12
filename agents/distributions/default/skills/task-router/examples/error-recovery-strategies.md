# Error Recovery Strategies - エラー回復戦略

このドキュメントは、task-routerのエラーハンドリングと回復戦略の詳細を説明します。

## Error Handling & Recovery

### エラー分析プロセス

```python
def handle_execution_error(error, context):
    """実行エラーを処理"""

    # 1. エラータイプの分類
    error_type = classify_error(error)

    # 2. 重要度の評価
    severity = evaluate_severity(error, context)

    # 3. 根本原因の分析
    root_cause = analyze_root_cause(error, context)

    # 4. リカバリー戦略の選択
    recovery_strategy = select_recovery_strategy(
        error_type,
        severity,
        root_cause,
        context
    )

    # 5. リカバリーの試行
    if recovery_strategy:
        try:
            return recovery_strategy.execute(context)
        except Exception as recovery_error:
            log_error(recovery_error)
            return fallback_strategy(context)

    return None
```

## エラー分類

### 1. 認証エラー (AuthenticationError)

### 症状

- APIキーが無効
- トークンが期限切れ
- 権限不足

### 検出方法

```python
def is_authentication_error(error):
    """認証エラーの検出"""

    auth_patterns = [
        "authentication failed",
        "invalid api key",
        "unauthorized",
        "401",
        "403"
    ]

    error_message = str(error).lower()
    return any(pattern in error_message for pattern in auth_patterns)
```

### リカバリー戦略

```python
class AuthenticationRecoveryStrategy:
    """認証エラーのリカバリー"""

    def execute(self, context):
        # Strategy 1: 資格情報の再取得
        if self.can_refresh_credentials():
            new_credentials = self.refresh_credentials()
            return retry_with_credentials(context, new_credentials)

        # Strategy 2: 代替APIへのフォールバック
        if self.has_alternative_api():
            return fallback_to_alternative_api(context)

        # Strategy 3: ユーザーに通知
        notify_user("認証情報を更新してください")
        return None
```

### 実例

```
Error: Context7 authentication failed
    ↓
Recovery Strategy: Authentication
    ├─ Attempt 1: Refresh API token
    ├─ Attempt 2: Use cached documentation
    └─ Fallback: Proceed without Context7
    ↓
Result: Partial Success (without Context7)
```

### 2. リソース制限エラー (ResourceLimitError)

### 症状

- API レート制限
- メモリ不足
- タイムアウト

### 検出方法

```python
def is_resource_limit_error(error):
    """リソース制限エラーの検出"""

    limit_patterns = [
        "rate limit",
        "quota exceeded",
        "too many requests",
        "timeout",
        "memory limit"
    ]

    error_message = str(error).lower()
    return any(pattern in error_message for pattern in limit_patterns)
```

### リカバリー戦略

```python
class ResourceLimitRecoveryStrategy:
    """リソース制限エラーのリカバリー"""

    def execute(self, context):
        # Strategy 1: タスクの分割
        if self.is_large_task(context):
            subtasks = self.split_task(context)
            return self.execute_with_backoff(subtasks)

        # Strategy 2: レート制限の実装
        if self.is_rate_limit_error():
            wait_time = self.calculate_backoff_time()
            time.sleep(wait_time)
            return retry_execution(context)

        # Strategy 3: リソース制限の調整
        if self.can_adjust_limits():
            self.reduce_resource_usage()
            return retry_execution(context)
```

### 実例

```
Error: API rate limit exceeded (429)
    ↓
Recovery Strategy: Resource Limit
    ├─ Calculate backoff time: 30 seconds
    ├─ Wait 30 seconds
    └─ Retry with exponential backoff
    ↓
Result: Success (after 2 retries)
```

### 3. パースエラー (ParseError)

### 症状

- JSONパースエラー
- 構文エラー
- 不正なフォーマット

### 検出方法

```python
def is_parse_error(error):
    """パースエラーの検出"""

    parse_patterns = [
        "json parse error",
        "syntax error",
        "invalid format",
        "unexpected token"
    ]

    error_message = str(error).lower()
    return any(pattern in error_message for pattern in parse_patterns)
```

### リカバリー戦略

```python
class ParseRecoveryStrategy:
    """パースエラーのリカバリー"""

    def execute(self, context):
        # Strategy 1: 代替パーサーの使用
        if self.has_alternative_parser():
            return try_alternative_parser(context)

        # Strategy 2: ファジーマッチング
        if self.can_fuzzy_match():
            return fuzzy_parse(context)

        # Strategy 3: 部分的なパース
        if self.can_partial_parse():
            partial_result = partial_parse(context)
            warn_user("部分的な結果のみ取得可能")
            return partial_result
```

### 実例

```
Error: JSON parse error in response
    ↓
Recovery Strategy: Parse
    ├─ Attempt 1: Repair JSON with regex
    ├─ Attempt 2: Extract valid JSON subset
    └─ Attempt 3: Fuzzy matching
    ↓
Result: Partial Success (80% data recovered)
```

### 4. 実行タイムアウト (TimeoutError)

### 症状

- 処理時間超過
- 応答なし
- デッドロック

### 検出方法

```python
def is_timeout_error(error):
    """タイムアウトエラーの検出"""

    timeout_patterns = [
        "timeout",
        "timed out",
        "deadline exceeded",
        "no response"
    ]

    error_message = str(error).lower()
    return any(pattern in error_message for pattern in timeout_patterns)
```

### リカバリー戦略

```python
class TimeoutRecoveryStrategy:
    """タイムアウトエラーのリカバリー"""

    def execute(self, context):
        # Strategy 1: タイムアウト制限の増加
        if context.retry_count < 2:
            context.timeout *= 1.5
            return retry_execution(context)

        # Strategy 2: 実行計画の最適化
        if self.can_optimize_plan():
            optimized_plan = optimize_execution_plan(context)
            return execute_with_plan(optimized_plan)

        # Strategy 3: タスクの分割
        if self.can_split_task():
            subtasks = split_into_subtasks(context)
            return execute_subtasks_parallel(subtasks)
```

### 実例

```
Error: Execution timeout (2 min exceeded)
    ↓
Recovery Strategy: Timeout
    ├─ Attempt 1: Increase timeout to 3 min
    ├─ Attempt 2: Optimize execution plan
    └─ Attempt 3: Split into 3 parallel subtasks
    ↓
Result: Success (completed in 4 min total)
```

## 自動再試行システム

### Exponential Backoff

```python
class ExponentialBackoff:
    """指数バックオフ再試行"""

    def __init__(self, base_delay=1.0, max_delay=60.0, max_retries=5):
        self.base_delay = base_delay
        self.max_delay = max_delay
        self.max_retries = max_retries

    def execute(self, func, context):
        """関数を指数バックオフで再試行"""

        for attempt in range(self.max_retries):
            try:
                return func(context)
            except Exception as e:
                if attempt == self.max_retries - 1:
                    raise e

                delay = min(
                    self.base_delay * (2 ** attempt),
                    self.max_delay
                )

                log(f"Retry {attempt + 1}/{self.max_retries} after {delay}s")
                time.sleep(delay)
```

### 使用例

```python
backoff = ExponentialBackoff()
result = backoff.execute(execute_task, context)
```

### Circuit Breaker

```python
class CircuitBreaker:
    """サーキットブレーカーパターン"""

    def __init__(self, failure_threshold=5, timeout=60):
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.failure_count = 0
        self.last_failure_time = None
        self.state = "closed"  # closed, open, half-open

    def execute(self, func, context):
        """サーキットブレーカー付き実行"""

        # Open状態: 失敗が続いている
        if self.state == "open":
            if self.should_attempt_reset():
                self.state = "half-open"
            else:
                raise CircuitBreakerOpenError()

        try:
            result = func(context)
            self.on_success()
            return result
        except Exception as e:
            self.on_failure()
            raise e

    def on_success(self):
        """成功時の処理"""
        self.failure_count = 0
        self.state = "closed"

    def on_failure(self):
        """失敗時の処理"""
        self.failure_count += 1
        self.last_failure_time = time.time()

        if self.failure_count >= self.failure_threshold:
            self.state = "open"
```

## フォールバック戦略

### 代替手段への切り替え

```python
class FallbackChain:
    """フォールバックチェーン"""

    def __init__(self, strategies):
        self.strategies = strategies

    def execute(self, context):
        """戦略を順次試行"""

        errors = []

        for strategy in self.strategies:
            try:
                result = strategy.execute(context)
                if result:
                    return result
            except Exception as e:
                errors.append((strategy, e))
                continue

        # 全て失敗
        raise AllStrategiesFailedError(errors)
```

### 使用例

```python
fallback = FallbackChain([
    PrimaryStrategy(),      # Context7でドキュメント取得
    SecondaryStrategy(),    # キャッシュからドキュメント取得
    TertiaryStrategy(),     # ドキュメントなしで実行
])

result = fallback.execute(context)
```

### 部分的な成功

```python
def handle_partial_success(context, partial_result):
    """部分的な成功を処理"""

    # 成功した部分を特定
    successful_parts = identify_successful_parts(partial_result)

    # 失敗した部分を特定
    failed_parts = identify_failed_parts(partial_result)

    # 失敗した部分のみ再試行
    for part in failed_parts:
        try:
            retry_result = retry_part(part, context)
            partial_result.merge(retry_result)
        except Exception as e:
            log_warning(f"Part {part} failed: {e}")

    return partial_result
```

## Continuous Learning System

### 実行記録

```python
class ExecutionRecorder:
    """実行記録システム"""

    def record_execution(self, context, result):
        """実行結果を記録"""

        execution_record = {
            "task_id": context.id,
            "task_description": context.intent['original_request'],
            "project_type": context.project["type"],
            "agent_used": result.get("agent"),
            "success": result.get("status") == "success",
            "execution_time": context.metrics.get("execution_time"),
            "quality_score": context.metrics.get("quality_score"),
            "errors": result.get("errors", []),
            "timestamp": timestamp()
        }

        self.save_to_database(execution_record)
        self.update_statistics(execution_record)
```

### パターン学習

```python
class PatternLearner:
    """パターン学習システム"""

    def learn_from_executions(self):
        """実行履歴からパターンを学習"""

        # 類似タスクのグループ化
        task_groups = self.group_similar_tasks()

        for group in task_groups:
            # 成功パターンの抽出
            success_patterns = self.extract_success_patterns(group)

            # 失敗パターンの抽出
            failure_patterns = self.extract_failure_patterns(group)

            # 推奨事項の生成
            recommendations = self.generate_recommendations(
                success_patterns,
                failure_patterns
            )

            # 推奨事項を保存
            self.save_recommendations(group, recommendations)
```

### 推奨事項生成

```python
def generate_recommendations(task_description, project_type):
    """類似タスクから推奨事項を生成"""

    # 類似タスクを検索
    similar_tasks = find_similar_tasks(task_description, project_type)

    if not similar_tasks:
        return None

    # 統計を計算
    stats = calculate_statistics(similar_tasks)

    recommendations = {
        "success_rate": stats["success_rate"],
        "expected_time": stats["avg_time"],
        "recommended_agent": stats["best_agent"],
        "common_issues": stats["common_errors"],
        "best_practices": stats["success_factors"]
    }

    return recommendations
```

### 推奨事項の例

```markdown
## 📊 Recommendations

Based on 35 similar tasks:

**Success Rate**: 87% (30/35)
**Expected Time**: 18m (±5m)
**Recommended Agent**: researcher

**Common Issues**:

- Missing error handling (12%)
- Incomplete tests (8%)
- Documentation gaps (5%)

**Best Practices**:

- Include Clean Architecture context
- Pre-load project conventions
- Use typescript skill for type safety
```

## エラーレポート

### 詳細エラーレポート

```markdown
## ❌ Error Report

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
**Task**: "TypeScript型エラーを修正"
**Agent**: error-fixer
**Status**: Failed

**Error Details**:

- Type: ParseError
- Message: "Invalid JSON in response"
- Severity: Medium
- Timestamp: 2025-01-15 14:30:45

**Recovery Attempts**:

1. Attempt 1: Repair JSON → Failed
2. Attempt 2: Partial parse → Partial Success
3. Attempt 3: Fuzzy match → Success

**Final Result**: Partial Success (80% complete)

**Recommendations**:

- Review remaining 20% manually
- Update parser for better resilience
- Add validation for API responses
```

## モニタリングとアラート

### リアルタイムモニタリング

```python
class ExecutionMonitor:
    """実行モニタリングシステム"""

    def monitor_execution(self, context):
        """実行をモニタリング"""

        metrics = {
            "task_id": context.id,
            "start_time": context.metrics["start_time"],
            "estimated_time": context.estimated_time,
            "current_phase": context.current_phase,
            "resource_usage": get_resource_usage()
        }

        # 異常検出
        if self.detect_anomaly(metrics):
            self.trigger_alert(metrics)

        # メトリクス記録
        self.log_metrics(metrics)
```

### アラートシステム

```python
class AlertSystem:
    """アラートシステム"""

    def trigger_alert(self, metrics):
        """アラートをトリガー"""

        alert = {
            "type": self.classify_alert(metrics),
            "severity": self.evaluate_severity(metrics),
            "message": self.generate_message(metrics),
            "timestamp": timestamp()
        }

        # ユーザーに通知
        self.notify_user(alert)

        # ログに記録
        self.log_alert(alert)
```

## ベストプラクティス

### 1. エラーの早期検出

```python
# 事前検証で早期エラー検出
def validate_before_execution(context):
    """実行前の検証"""

    issues = []

    if not has_required_resources(context):
        issues.append("Required resources not available")

    if not compatible_with_project(context):
        issues.append("Incompatible with project type")

    if issues:
        raise PreExecutionError(issues)
```

### 2. グレースフルデグラデーション

```python
# 機能を段階的に縮退
def execute_with_degradation(context):
    """段階的機能縮退"""

    try:
        return full_execution(context)
    except Context7Error:
        warn("Context7 unavailable, using cached docs")
        return execution_without_context7(context)
    except CacheError:
        warn("Cache unavailable, proceeding without docs")
        return execution_without_docs(context)
```

### 3. 詳細なログ

```python
# 詳細なログで原因分析を容易に
def log_execution_details(context, result):
    """実行詳細をログ"""

    log.info(f"Task: {context.intent['original_request']}")
    log.info(f"Agent: {result.get('agent')}")
    log.info(f"Duration: {result.get('duration')}s")
    log.debug(f"Full context: {context}")
    log.debug(f"Full result: {result}")
```

## 関連リソース

- [使用パターン集](usage-patterns.md)
- [処理アーキテクチャ詳細](../references/processing-architecture.md)
- [エージェント選択ロジック](../references/agent-selection-logic.md)
