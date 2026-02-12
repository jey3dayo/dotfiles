# Agent Selection Logic - エージェント選択アルゴリズム

このドキュメントは、task-routerの多層意図分析とエージェント選択アルゴリズムの詳細を説明します。

## 多層意図分析

### 9種類の意図タイプ

タスクの意図を以下の9つのタイプに分類します。

```python
INTENT_TYPES = {
    "error": {
        "keywords": ["エラー", "error", "修正", "fix", "バグ", "bug", "型", "type"],
        "weight": 1.0,
        "description": "エラー修正、型エラー、コンパイルエラー"
    },
    "implement": {
        "keywords": ["実装", "implement", "作成", "create", "追加", "add", "新規", "new"],
        "weight": 0.9,
        "description": "新機能実装、機能追加"
    },
    "fix": {
        "keywords": ["バグ", "bug", "不具合", "直す", "fix", "修正", "correct"],
        "weight": 0.95,
        "description": "バグ修正、不具合対応"
    },
    "analyze": {
        "keywords": ["分析", "analyze", "調査", "investigate", "なぜ", "why", "原因", "cause"],
        "weight": 0.85,
        "description": "分析、調査、問題究明"
    },
    "review": {
        "keywords": ["レビュー", "review", "確認", "check", "品質", "quality"],
        "weight": 0.9,
        "description": "コードレビュー、品質確認"
    },
    "github_pr": {
        "keywords": ["PR", "pull request", "プルリクエスト", "origin/", "ブランチ", "branch"],
        "weight": 1.0,
        "description": "GitHub PRレビュー"
    },
    "refactor": {
        "keywords": ["リファクタ", "refactor", "改善", "improve", "整理", "cleanup"],
        "weight": 0.8,
        "description": "リファクタリング、コード改善"
    },
    "navigate": {
        "keywords": ["探す", "find", "見つける", "locate", "検索", "search", "全て", "all"],
        "weight": 0.95,
        "description": "コードナビゲーション、シンボル検索"
    },
    "docs": {
        "keywords": ["ドキュメント", "document", "docs", "README", "リンク", "link"],
        "weight": 0.9,
        "description": "ドキュメント管理、リンク検証"
    }
}
```

## 意図分析アルゴリズム

### Phase 1: キーワードマッチング

```python
def analyze_task_intent(task_description):
    """タスクの意図を分析"""

    description_lower = task_description.lower()
    intent_scores = {}

    # 各意図タイプのスコアを計算
    for intent_type, config in INTENT_TYPES.items():
        score = 0.0

        # キーワードマッチング
        for keyword in config["keywords"]:
            if keyword in description_lower:
                # キーワードの位置によるウェイト調整
                position_weight = calculate_position_weight(
                    keyword, description_lower
                )
                score += config["weight"] * position_weight

        # 正規化 (0.0-1.0)
        intent_scores[intent_type] = min(score / max_score, 1.0)

    return intent_scores
```

### Phase 2: 主要意図と副次的意図の抽出

```python
def extract_primary_and_secondary_intents(intent_scores):
    """主要意図と副次的意図を抽出"""

    # スコアでソート
    sorted_intents = sorted(
        intent_scores.items(),
        key=lambda x: x[1],
        reverse=True
    )

    # 主要意図 (最高スコア)
    primary_intent = {
        "type": sorted_intents[0][0],
        "score": sorted_intents[0][1]
    }

    # 副次的意図 (閾値0.5以上)
    secondary_intents = [
        {"type": intent_type, "score": score}
        for intent_type, score in sorted_intents[1:]
        if score >= 0.5
    ]

    return {
        "primary": primary_intent,
        "secondary": secondary_intents
    }
```

### Phase 3: コンテキスト強化

プロジェクト情報や実行履歴を使用してスコアを調整します。

```python
def enhance_intent_with_context(intents, context):
    """コンテキストで意図スコアを強化"""

    enhanced_intents = intents.copy()

    # プロジェクトタイプによる調整
    project_type = context.project["type"]
    if project_type == "typescript-react":
        # TypeScriptプロジェクトでは型エラー修正の優先度を上げる
        if "error" in enhanced_intents:
            enhanced_intents["error"] *= 1.15

    # 実行履歴による調整
    if hasattr(context, 'history') and context.history:
        recommended_agent = context.history.get("recommended_agent")
        if recommended_agent == "error-fixer":
            enhanced_intents["error"] *= 1.1

    # Context7ドキュメントの有無による調整
    if hasattr(context, 'documentation') and context.documentation:
        # ドキュメントがある場合、実装や分析の確信度を上げる
        enhanced_intents["implement"] *= 1.1
        enhanced_intents["analyze"] *= 1.1

    return enhanced_intents
```

## エージェント能力マッピング

### エージェント能力マトリックス

```python
AGENT_CAPABILITIES = {
    "error-fixer": {
        "error": 0.95,
        "fix": 0.90,
        "refactor": 0.75,
        "analyze": 0.70,
        "quality_score": 95,
        "speed_score": 85
    },
    "orchestrator": {
        "implement": 0.95,
        "refactor": 0.90,
        "analyze": 0.85,
        "fix": 0.75,
        "quality_score": 98,
        "speed_score": 70
    },
    "code-reviewer": {
        "review": 0.98,
        "analyze": 0.90,
        "fix": 0.80,
        "refactor": 0.75,
        "quality_score": 96,
        "speed_score": 80
    },
    "researcher": {
        "analyze": 0.95,
        "implement": 0.80,
        "review": 0.75,
        "fix": 0.70,
        "quality_score": 94,
        "speed_score": 75
    },
    "github-pr-reviewer": {
        "github_pr": 1.00,
        "review": 0.95,
        "analyze": 0.85,
        "fix": 0.75,
        "quality_score": 97,
        "speed_score": 85
    },
    "docs-manager": {
        "docs": 0.98,
        "fix": 0.80,
        "review": 0.70,
        "refactor": 0.65,
        "quality_score": 88,
        "speed_score": 95
    },
    "serena": {
        "navigate": 1.00,
        "analyze": 0.90,
        "refactor": 0.85,
        "review": 0.75,
        "quality_score": 96,
        "speed_score": 90
    }
}
```

## 確信度スコアリング

### 基本スコア計算

```python
def calculate_base_confidence_score(intent_scores, agent_capabilities):
    """基本確信度スコアを計算"""

    total_score = 0.0
    matched_intents = 0

    for intent_type, intent_score in intent_scores.items():
        if intent_type in agent_capabilities:
            capability_score = agent_capabilities[intent_type]
            total_score += intent_score * capability_score
            matched_intents += 1

    # 正規化 (0.0-1.0)
    if matched_intents == 0:
        return 0.0

    normalized_score = total_score / matched_intents
    return normalized_score
```

### Context7調整

Context7によるライブラリドキュメントの有無でスコアを調整します。

```python
def apply_context7_adjustment(base_score, context):
    """Context7によるスコア調整"""

    if not hasattr(context, 'documentation') or not context.documentation:
        return base_score

    # ドキュメントが利用可能な場合、確信度を10%向上
    adjusted_score = base_score * 1.1

    # 最大値1.0を超えないように
    return min(adjusted_score, 1.0)
```

### 実行履歴による調整

過去の実行履歴から成功率を考慮してスコアを調整します。

```python
def apply_history_adjustment(base_score, agent_name, context):
    """実行履歴によるスコア調整"""

    if not hasattr(context, 'history') or not context.history:
        return base_score

    # 推奨エージェントの場合、確信度を5%向上
    if context.history.get("recommended_agent") == agent_name:
        adjusted_score = base_score * 1.05
        return min(adjusted_score, 1.0)

    # 成功率が低い場合、確信度を低下
    success_rate = context.history.get("success_rate", 1.0)
    if success_rate < 0.7:
        adjusted_score = base_score * 0.95
        return adjusted_score

    return base_score
```

## エージェント選択プロセス

### 単一エージェント選択

```python
def select_optimal_agent(task_description, context):
    """最適なエージェントを選択"""

    # 意図分析
    intent_scores = analyze_task_intent(task_description)
    enhanced_intents = enhance_intent_with_context(intent_scores, context)

    # 各エージェントのスコアを計算
    agent_scores = {}
    for agent_name, capabilities in AGENT_CAPABILITIES.items():
        # 基本スコア
        base_score = calculate_base_confidence_score(
            enhanced_intents,
            capabilities
        )

        # Context7調整
        score_with_context7 = apply_context7_adjustment(base_score, context)

        # 履歴調整
        final_score = apply_history_adjustment(
            score_with_context7,
            agent_name,
            context
        )

        agent_scores[agent_name] = final_score

    # 最高スコアのエージェントを選択
    best_agent = max(agent_scores.items(), key=lambda x: x[1])

    return {
        "agent": best_agent[0],
        "confidence": best_agent[1],
        "reasoning": generate_selection_reasoning(
            best_agent[0],
            enhanced_intents,
            agent_scores
        )
    }
```

### 複数エージェント選択

複雑度が0.8以上の場合、複数エージェントによる協調実行を計画します。

```python
def select_multi_agent_strategy(task_description, context, complexity):
    """複数エージェント戦略を選択"""

    if complexity < 0.8:
        # 単純タスク: 単一エージェント
        return select_optimal_agent(task_description, context)

    # タスクを分解
    subtasks = decompose_into_subtasks(task_description, context)

    # 各サブタスクにエージェントを割り当て
    agent_assignments = []
    for subtask in subtasks:
        agent_selection = select_optimal_agent(subtask, context)
        agent_assignments.append({
            "subtask": subtask,
            "agent": agent_selection["agent"],
            "confidence": agent_selection["confidence"]
        })

    # 主要エージェントを決定
    primary_agent = determine_primary_agent(agent_assignments)

    return {
        "strategy": "multi_agent",
        "primary_agent": primary_agent,
        "agent_assignments": agent_assignments,
        "overall_confidence": calculate_overall_confidence(agent_assignments)
    }
```

## 選択推論の生成

```python
def generate_selection_reasoning(selected_agent, intents, all_scores):
    """選択理由を生成"""

    reasoning = []

    # 主要意図とのマッチング
    primary_intent = max(intents.items(), key=lambda x: x[1])
    reasoning.append(
        f"主要意図 '{primary_intent[0]}' に最適 (スコア: {primary_intent[1]:.2f})"
    )

    # エージェント能力
    capabilities = AGENT_CAPABILITIES[selected_agent]
    primary_capability = max(capabilities.items(), key=lambda x: x[1])
    reasoning.append(
        f"'{primary_capability[0]}' 能力が高い (能力スコア: {primary_capability[1]:.2f})"
    )

    # 確信度
    confidence = all_scores[selected_agent]
    reasoning.append(
        f"確信度: {confidence:.1%}"
    )

    # 次点エージェントとの比較
    sorted_scores = sorted(all_scores.items(), key=lambda x: x[1], reverse=True)
    if len(sorted_scores) > 1:
        second_best = sorted_scores[1]
        diff = confidence - second_best[1]
        reasoning.append(
            f"次点 '{second_best[0]}' より {diff:.1%} 高いスコア"
        )

    return " | ".join(reasoning)
```

## 特殊ケースの処理

### GitHub PR検出

```python
def detect_github_pr_intent(task_description):
    """GitHub PR意図を検出"""

    pr_patterns = [
        r"origin/[\w-]+",
        r"pull\s+request",
        r"\bPR\b",
        r"ブランチ.*(レビュー|確認)",
        r"(main|develop|master).*差分"
    ]

    for pattern in pr_patterns:
        if re.search(pattern, task_description, re.IGNORECASE):
            return True

    return False
```

### セマンティック分析検出

```python
def detect_semantic_analysis_intent(task_description):
    """セマンティック分析意図を検出"""

    semantic_patterns = [
        r"(全て|すべて|全部).*(実装|参照|呼び出し)",
        r"(見つけ|探し|検索).*(クラス|メソッド|関数|インターフェース)",
        r"(依存|参照).*(分析|追跡|調査)",
        r"(リネーム|名前.*変更).*全(て|部|体)"
    ]

    for pattern in semantic_patterns:
        if re.search(pattern, task_description, re.IGNORECASE):
            return True

    return False
```

## エージェント選択フローチャート

```
Task Description
    ↓
[特殊ケース検出]
    ├─ GitHub PR検出? → YES → github-pr-reviewer (確信度: 1.0)
    ├─ セマンティック分析? → YES → serena (確信度: 1.0)
    └─ NO → 続行
    ↓
[意図分析]
    ├─ キーワードマッチング
    ├─ 主要/副次的意図抽出
    └─ コンテキスト強化
    ↓
[確信度スコアリング]
    ├─ 基本スコア計算
    ├─ Context7調整 (+10%)
    ├─ 履歴調整 (±5%)
    └─ プロジェクトタイプ調整 (±15%)
    ↓
[複雑度判定]
    ├─ < 0.8 → 単一エージェント選択
    └─ ≥ 0.8 → 複数エージェント計画
    ↓
[最終選択]
    └─ 選択理由の生成
```

## パフォーマンス最適化

### キャッシング戦略

```python
# エージェント能力マトリックスは静的キャッシュ
@lru_cache(maxsize=1)
def get_agent_capabilities():
    return AGENT_CAPABILITIES

# 意図タイプ設定も静的キャッシュ
@lru_cache(maxsize=1)
def get_intent_types():
    return INTENT_TYPES

# タスク意図分析結果のキャッシュ (最大100件)
@lru_cache(maxsize=100)
def cached_analyze_task_intent(task_description):
    return analyze_task_intent(task_description)
```

### 早期リターン

```python
def select_optimal_agent_fast(task_description, context):
    """高速エージェント選択 (特殊ケース優先)"""

    # GitHub PR検出 (最高優先度)
    if detect_github_pr_intent(task_description):
        return {
            "agent": "github-pr-reviewer",
            "confidence": 1.0,
            "reasoning": "GitHub PR関連タスクを検出"
        }

    # セマンティック分析検出
    if detect_semantic_analysis_intent(task_description):
        return {
            "agent": "serena",
            "confidence": 1.0,
            "reasoning": "セマンティック分析タスクを検出"
        }

    # 通常の選択フロー
    return select_optimal_agent(task_description, context)
```

## メトリクス収集

```python
def collect_selection_metrics(agent, confidence, execution_time):
    """エージェント選択のメトリクスを収集"""

    metrics = {
        "selected_agent": agent,
        "confidence": confidence,
        "execution_time": execution_time,
        "timestamp": timestamp()
    }

    # メトリクスストレージに保存
    save_metrics(metrics)

    # 学習システムに記録
    learning_system.record_selection(metrics)
```

## 関連リソース

- [エージェント詳細プロファイル](agent-profiles.md)
- [処理アーキテクチャ詳細](processing-architecture.md)
- [agents-onlyスキル](../../agents-only/SKILL.md)
