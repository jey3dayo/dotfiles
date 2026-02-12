# Context7 Integration - ライブラリドキュメント統合ユーティリティ

Context7 MCPサーバーと連携して、最新のライブラリドキュメントを取得・活用する共通ユーティリティです。

## 🎯 Core Functions

### detect_library_references()

タスクの説明からライブラリ参照を検出します。

```python
def detect_library_references(task_description):
    """タスク説明からライブラリ参照を検出"""

    # よく使われるライブラリのパターン
    library_patterns = {
        'react': [
            r'\breact\b', r'\bhooks?\b', r'\buseState\b', r'\buseEffect\b',
            r'\bcomponent\b', r'\bjsx\b', r'\btsx\b'
        ],
        'next': [
            r'\bnext\.?js\b', r'\bapp router\b', r'\bpages router\b',
            r'\bgetServerSideProps\b', r'\bgetStaticProps\b'
        ],
        'vue': [
            r'\bvue\b', r'\bcomposition api\b', r'\boptions api\b',
            r'\bref\b', r'\breactive\b', r'\bcomputed\b'
        ],
        'typescript': [
            r'\btypescript\b', r'\bts\b', r'\btype\b', r'\binterface\b',
            r'\benum\b', r'\bgeneric\b'
        ],
        'tailwind': [
            r'\btailwind\b', r'\btw\b', r'\bclassName\b', r'\bcss\b'
        ],
        'node': [
            r'\bnode\.?js\b', r'\bexpress\b', r'\bfastify\b',
            r'\bnpm\b', r'\bpackage\.json\b'
        ]
    }

    detected_libraries = []
    description_lower = task_description.lower()

    for library, patterns in library_patterns.items():
        for pattern in patterns:
            if re.search(pattern, description_lower, re.IGNORECASE):
                detected_libraries.append({
                    'name': library,
                    'confidence': calculate_pattern_confidence(pattern, description_lower)
                })
                break

    # バージョン情報の抽出
    version_matches = re.findall(r'(\w+)\s*(?:v|version)?\s*(\d+(?:\.\d+)*)', description_lower)
    for lib, version in version_matches:
        update_library_version(detected_libraries, lib, version)

    return sorted(detected_libraries, key=lambda x: x['confidence'], reverse=True)
```

### fetch_context7_documentation()

Context7からドキュメントを取得します。

```python
def fetch_context7_documentation(library_name, topic=None, tokens=5000):
    """Context7からライブラリドキュメントを取得"""

    try:
        # まずライブラリIDを解決
        resolve_result = mcp__context7__resolve_library_id(library_name)

        if not resolve_result:
            return None

        # 最も関連性の高いライブラリを選択
        selected_library = select_best_library_match(resolve_result, library_name)

        if not selected_library:
            return None

        # ドキュメントを取得
        docs = mcp__context7__get_library_docs(
            context7CompatibleLibraryID=selected_library['id'],
            topic=topic,
            tokens=tokens
        )

        return {
            'library': selected_library,
            'documentation': docs,
            'timestamp': timestamp()
        }

    except Exception as e:
        # エラーログを記録
        log_context7_error(e, library_name, topic)
        return None
```

### enhance_context_with_docs()

タスクコンテキストをドキュメント情報で強化します。

```python
def enhance_context_with_docs(context, detected_libraries):
    """タスクコンテキストをドキュメント情報で強化"""

    # 優先度の高いライブラリから処理
    documentation_cache = {}

    for library in detected_libraries[:3]:  # 上位3つまで
        if library['confidence'] < 0.5:
            continue

        # トピックを推測
        topic = infer_documentation_topic(context, library['name'])

        # ドキュメントを取得
        docs = fetch_context7_documentation(
            library['name'],
            topic=topic,
            tokens=calculate_token_budget(context)
        )

        if docs:
            documentation_cache[library['name']] = docs

    # コンテキストを更新
    context.documentation = documentation_cache
    context.has_documentation = bool(documentation_cache)

    return context
```

### infer_documentation_topic()

タスクからドキュメントのトピックを推測します。

```python
def infer_documentation_topic(context, library_name):
    """タスクコンテキストからドキュメントトピックを推測"""

    task_description = context.intent['original_request'].lower()

    # ライブラリ別のトピックマッピング
    topic_mappings = {
        'react': {
            'hooks': ['hook', 'use', 'state', 'effect', 'memo', 'callback'],
            'components': ['component', 'render', 'props', 'children'],
            'routing': ['route', 'router', 'navigation', 'link'],
            'forms': ['form', 'input', 'submit', 'validation'],
            'performance': ['performance', 'optimize', 'memo', 'lazy']
        },
        'next': {
            'app-router': ['app router', 'app directory', 'layout', 'page'],
            'api-routes': ['api', 'route', 'handler', 'endpoint'],
            'data-fetching': ['fetch', 'ssr', 'ssg', 'isr', 'getServerSideProps'],
            'optimization': ['image', 'font', 'script', 'optimize']
        },
        'typescript': {
            'types': ['type', 'interface', 'generic', 'union', 'intersection'],
            'classes': ['class', 'constructor', 'inheritance', 'abstract'],
            'modules': ['module', 'import', 'export', 'namespace'],
            'advanced': ['decorator', 'reflect', 'metadata', 'conditional']
        }
    }

    # デフォルトのトピック
    library_topics = topic_mappings.get(library_name, {})

    for topic, keywords in library_topics.items():
        if any(keyword in task_description for keyword in keywords):
            return topic

    return None  # トピックなしで全般的なドキュメントを取得
```

### apply_documentation_to_task()

取得したドキュメントをタスク実行に活用します。

```python
def apply_documentation_to_task(context, agent_type):
    """ドキュメントをタスク実行に適用"""

    if not context.get('documentation'):
        return context

    # エージェントタイプに応じた活用方法
    if agent_type in ['researcher', 'orchestrator', 'error-fixer']:
        # 実装・調査系エージェント: APIリファレンスを重視
        context.enhanced_prompt = generate_api_aware_prompt(context)

    elif agent_type == 'code-reviewer':
        # レビュー系: ベストプラクティスを重視
        context.review_guidelines = extract_best_practices(context.documentation)

    elif agent_type == 'docs-manager':
        # ドキュメント系: 正確なAPI情報を重視
        context.api_references = extract_api_signatures(context.documentation)

    return context
```

## 📊 Integration Points

### /taskコマンドとの統合

```python
# task.mdでの使用例
def analyze_task(task_description, options={}):
    """タスクを分析し、実行計画を作成"""

    # 基本的なタスク分析
    context = TaskContext(task_description, source="/task")

    # ライブラリ参照の検出
    detected_libraries = detect_library_references(task_description)

    if detected_libraries and not options.get('skip_documentation'):
        # Context7統合を適用
        context = enhance_context_with_docs(context, detected_libraries)

    # タスク分析レポートの生成
    report = generate_task_analysis_report(context)

    return {
        "context": context,
        "report": report,
        "execution_plan": create_execution_plan(context)
    }
```

### エージェント選択での活用

```python
# agent-selector.mdでの使用例
def calculate_agent_scores(context):
    """コンテキストに基づいてエージェントスコアを計算"""

    scores = base_agent_scoring(context)

    # ドキュメントが利用可能な場合のスコア調整
    if context.get('has_documentation'):
        # 実装系エージェントのスコアを上げる
        scores['orchestrator'] *= 1.2
        scores['researcher'] *= 1.1

        # ドキュメント参照タスクの場合
        if 'docs' in context.intent.get('types', []):
            scores['docs-manager'] *= 1.3

    return scores
```

## 🔧 Configuration

### キャッシュ設定

```python
CONTEXT7_CACHE_CONFIG = {
    "enabled": True,
    "ttl": 3600,  # 1時間
    "max_size": 100,  # 最大100エントリ
    "storage": "memory"  # or "file"
}
```

### トークン管理

```python
def calculate_token_budget(context):
    """ドキュメント取得のトークン予算を計算"""

    base_tokens = 5000

    # タスクの複雑さに応じて調整
    complexity = context.get('complexity', 0.5)

    if complexity > 0.8:
        return base_tokens * 2  # 複雑なタスクは多めに
    elif complexity < 0.3:
        return base_tokens // 2  # 単純なタスクは少なめに

    return base_tokens
```

## 🚨 Error Handling

### Context7利用不可時の処理

```python
def handle_context7_unavailable(context, error):
    """Context7が利用できない場合のフォールバック"""

    # ローカルキャッシュを確認
    cached_docs = check_local_cache(context)

    if cached_docs:
        context.documentation = cached_docs
        context.documentation_source = "cache"
    else:
        # 基本的なヘルプテキストを生成
        context.fallback_hints = generate_library_hints(context)
        context.documentation_source = "fallback"

    return context
```

## 📈 Metrics & Monitoring

### 使用状況の追跡

```python
CONTEXT7_METRICS = {
    "total_requests": 0,
    "successful_requests": 0,
    "cache_hits": 0,
    "average_response_time": 0,
    "popular_libraries": {},
    "error_count": 0
}

def track_context7_usage(library, success, response_time):
    """Context7使用状況を記録"""
    CONTEXT7_METRICS["total_requests"] += 1

    if success:
        CONTEXT7_METRICS["successful_requests"] += 1

    # 応答時間の更新
    update_average_response_time(response_time)

    # 人気ライブラリの追跡
    CONTEXT7_METRICS["popular_libraries"][library] = \
        CONTEXT7_METRICS["popular_libraries"].get(library, 0) + 1
```

## 🎯 Best Practices

1. **選択的ドキュメント取得**: 全てのタスクでContext7を使用せず、必要な場合のみ
2. **トピック最適化**: 具体的なトピックを指定して関連性の高い情報を取得
3. **キャッシュ活用**: 同じライブラリへの繰り返しリクエストを避ける
4. **エラーハンドリング**: Context7が利用できない場合の適切なフォールバック
5. **トークン管理**: タスクの複雑さに応じた適切なトークン割り当て

---

このユーティリティにより、/taskコマンドは最新のライブラリドキュメントを活用して、より正確で効率的なタスク実行が可能になります。

---

## 🎯 Skill Integration

このユーティリティは以下のスキルと統合し、Context7活用を最適化します。

### mcp-tools (必須)

- **理由**: Context7 MCPサーバーの公式統合ガイド
- **タイミング**: Context7機能使用時に自動参照
- **トリガー**: ライブラリドキュメント取得時
- **提供内容**:
  - Context7セットアップ手順
  - MCPサーバーセキュリティベストプラクティス
  - エラーハンドリングパターン
  - サーバーカタログとトラブルシューティング
  - トークン管理戦略

### integration-framework (必須)

- **理由**: TaskContext統合とドキュメント標準化
- **タイミング**: コンテキスト強化時
- **トリガー**: `enhance_context_with_docs()` 実行時
- **提供内容**:
  - TaskContextインターフェース仕様
  - ドキュメント情報の標準化フォーマット
  - Communication Busでのドキュメント共有
  - Progressive Disclosure原則の適用

### agents-and-commands (オプション)

- **理由**: エージェントスコア調整とドキュメント活用戦略
- **タイミング**: エージェント選択時
- **トリガー**: Context7ドキュメント利用可能時のスコア調整
- **提供内容**:
  - ドキュメント利用可能時のエージェント選択基準
  - スコア調整係数（+20%等）
  - 実装系エージェント優先戦略
  - エラー修正時のドキュメント活用パターン

### 統合フローの例

**ライブラリドキュメント取得（全スキル統合）**:

```
detect_library_references() 実行
    ↓
ライブラリ検出: "react", "typescript"
    ↓ (mcp-tools統合)
MCPサーバー接続確認
    ↓
fetch_context7_documentation() 実行
    ↓ (セキュリティチェック)
認証状態確認
    ↓
mcp__context7__resolve_library_id() 実行
    ↓
ライブラリID解決
    ↓
mcp__context7__get_library_docs() 実行
    ↓ (トークン管理)
トークン予算内でドキュメント取得
    ↓ (integration-framework)
TaskContext.documentation に保存
    ↓
context.has_documentation = true
```

**コンテキスト強化フロー**:

```
enhance_context_with_docs() 実行
    ↓
優先度順にライブラリ処理（上位3つ）
    ↓ (integration-framework)
TaskContext参照
    ↓
infer_documentation_topic() 実行
    ↓ (タスク説明からトピック推測)
"react" + "hooks" → topic: "hooks"
    ↓
fetch_context7_documentation() 実行
    ↓
documentation_cache["react"] = docs
    ↓ (Progressive Disclosure)
必要な情報のみ取得
    ↓
context.documentation = documentation_cache
    ↓
強化されたコンテキスト返却
```

**エージェント選択への影響（agents-and-commands統合）**:

```
calculate_agent_scores() 実行
    ↓
基本スコア計算
    ↓
context.has_documentation == true?
    ↓ Yes (agents-and-commands統合)
スコア調整:
  - orchestrator: ×1.2
  - researcher: ×1.1
  - error-fixer: ×1.15 (エラー修正時)
    ↓
調整されたスコア返却
    ↓
最適エージェント選択
```

### Context7統合モード

| モード       | 統合スキル            | トークン予算 | 用途                   |
| ------------ | --------------------- | ------------ | ---------------------- |
| 基本取得     | mcp-tools             | 5000         | 一般的なライブラリ情報 |
| トピック指定 | mcp-tools             | 5000         | 特定機能に特化         |
| 複雑タスク   | integration-framework | 10000        | 高複雑度タスク         |
| 単純タスク   | integration-framework | 2500         | 低複雑度タスク         |

### エラーハンドリング統合

**Context7利用不可時のフォールバック**:

```
fetch_context7_documentation() エラー
    ↓ (mcp-tools統合)
MCPサーバー接続エラー
    ↓
handle_context7_unavailable() 実行
    ↓ (integration-framework)
ローカルキャッシュ確認
    ↓
キャッシュあり？
    ↓ Yes
context.documentation = cached_docs
    ↓
context.documentation_source = "cache"
    ↓ No
基本ヘルプテキスト生成
    ↓
context.fallback_hints = hints
    ↓
context.documentation_source = "fallback"
```

### スキル連携の利点

1. **公式ガイダンス**: mcp-toolsによるContext7ベストプラクティス適用
2. **標準化**: integration-frameworkによるドキュメント情報の統一管理
3. **エージェント最適化**: agents-and-commandsによるスコア調整
4. **セキュリティ**: mcp-toolsによるセキュアなMCP連携
5. **エラー回復**: 包括的なフォールバック戦略

---
