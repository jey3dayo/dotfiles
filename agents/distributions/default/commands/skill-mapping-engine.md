# Skill Mapping Engine - Skills自動補填エンジン

`/maintain-claude`コマンドで使用する共有ライブラリです。Agent-Skill関連性を分析し、適切なスキルを推奨します。

## 🎯 主要機能

### 1. 関連性スコアリング

Agent-Skill間の関連性を多次元で評価します。

### 2. Skills自動補填推奨

スコアに基づいて自動追加・提案・除外を判定します。

### 3. 既存パターン学習

他の類似Agentが参照しているSkillsを学習します。

## 📋 使用方法

```typescript
import { recommendSkills } from "./shared/skill-mapping-engine";

const recommendations = await recommendSkills(
  agent,
  availableSkills,
  existingAgents,
);

// 結果の分類
const autoAdd = recommendations.filter((r) => r.score >= 50);
const suggestions = recommendations.filter(
  (r) => r.score >= 30 && r.score < 50,
);
const excluded = recommendations.filter((r) => r.score < 30);
```

## 🔧 実装詳細

### スコアリング方式

**5つの評価軸**:

```typescript
interface RelationshipScore {
  technologyMatch: number; // 30点: typescript, golang, react等
  nameMatch: number; // 25点: agent名に技術名が含まれる
  contextMatch: number; // 20点: レビュー系 → code-review, security
  patternMatch: number; // 15点: 他の類似Agentが参照
  keywordMatch: number; // 10点: descriptionの共通キーワード
}

// 総合スコア = 各軸のスコアの合計
// >= 50: 自動追加（確信度高）
// >= 30: 提案（ユーザー確認推奨）
// < 30: 除外
```

### Phase 1: 技術スタック一致（30点）

**目的**: Agentの説明文やシステムプロンプトから技術スタックを抽出し、Skillと照合

```python
def calculate_technology_match(agent, skill):
    """技術スタック一致度を計算（最大30点）"""

    # 技術スタックキーワードマップ
    technology_keywords = {
        "typescript": ["typescript", "ts", "type safety", "type check"],
        "golang": ["go", "golang", "goroutine", "channel"],
        "react": ["react", "jsx", "tsx", "component", "hook"],
        "python": ["python", "py", "pip", "venv"],
        "security": ["security", "owasp", "vulnerability", "xss", "sql injection"],
        "docker": ["docker", "container", "dockerfile", "image"],
        "terraform": ["terraform", "hcl", "infrastructure as code", "iac"],
    }

    agent_text = (
        agent["description"] + " " +
        agent["systemPrompt"]
    ).lower()

    skill_name = skill["name"].lower()

    # Skillに対応するキーワードを取得
    keywords = technology_keywords.get(skill_name, [skill_name])

    # キーワード一致数をカウント
    matches = sum(1 for keyword in keywords if keyword in agent_text)

    # スコア計算（最大30点）
    if matches >= 3:
        return 30  # 複数の強い一致
    elif matches == 2:
        return 20  # 中程度の一致
    elif matches == 1:
        return 10  # 弱い一致
    else:
        return 0   # 一致なし
```

**実装ガイド**:

- 技術スタックキーワードマップを定義
- Agent の description + systemPrompt から検索
- 複数キーワード一致で高得点

### Phase 2: Agent名一致（25点）

**目的**: Agent名に技術名が含まれる場合、関連Skillsを高く評価

```python
def calculate_name_match(agent, skill):
    """Agent名一致度を計算（最大25点）"""

    agent_name = agent["name"].lower()
    skill_name = skill["name"].lower()

    # 完全一致
    if skill_name in agent_name:
        return 25

    # 部分一致（ハイフン区切り）
    agent_parts = agent_name.split("-")
    skill_parts = skill_name.split("-")

    common_parts = set(agent_parts) & set(skill_parts)

    if len(common_parts) >= 2:
        return 20  # 複数パーツ一致
    elif len(common_parts) == 1:
        return 10  # 1パーツ一致
    else:
        return 0
```

**実装例**:

- `terraform-operations` → `perman-aws-vault` (terraform関連)
- `deployment` → `asta-deployment` (deployment関連)
- `code-reviewer` → `code-quality-improvement` (code関連)

### Phase 3: コンテキスト一致（20点）

**目的**: Agentのカテゴリーに応じた推奨Skillsを評価

```python
def calculate_context_match(agent, skill):
    """コンテキスト一致度を計算（最大20点）"""

    # Agentカテゴリー別の推奨Skillsマップ
    context_map = {
        "implementation": ["integration-framework", "typescript", "golang", "react", "code-quality-improvement"],
        "review": ["code-review", "security", "typescript", "code-quality-improvement"],
        "deployment": ["perman-aws-vault", "asta-deployment", "cicd-pipeline", "terraform"],
        "database": ["database-operations", "mysql"],
        "quality": ["code-quality-improvement", "typescript", "security"],
        "debug": ["debug-operations", "quality-validation"],
        "orchestration": ["integration-framework", "agents-and-commands", "code-quality-improvement"],
        "tool_selection": ["agents-and-commands", "docs-index"],
        "documentation": ["docs-index", "markdown-docs"],
        "integration": ["mcp-tools", "integration-framework"],
    }

    # Agentのカテゴリーを推定
    category = infer_agent_category(agent)

    # 推奨Skillsリストを取得
    recommended_skills = context_map.get(category, [])

    skill_name = skill["name"]

    if skill_name in recommended_skills:
        # リストの順位に応じてスコア
        index = recommended_skills.index(skill_name)
        if index == 0:
            return 20  # 最推奨
        elif index <= 2:
            return 15  # 高推奨
        else:
            return 10  # 推奨
    else:
        return 0


def infer_agent_category(agent):
    """Agentのカテゴリーを推定"""

    name = agent["name"].lower()
    description = agent["description"].lower()

    # キーワードベース分類（優先度順）

    # 統合・オーケストレーション系
    if any(kw in name or kw in description for kw in [
        "orchestrator", "orchestration", "task orchestrator",
        "integration", "coordination", "workflow"
    ]):
        return "orchestration"

    # ツール選択・ガイダンス系
    if any(kw in name or kw in description for kw in [
        "tool selection", "agent selection", "choose tool",
        "guidance", "router", "selector"
    ]):
        return "tool_selection"

    # ドキュメンテーション系
    if any(kw in name or kw in description for kw in [
        "documentation", "docs", "markdown", "guide",
        "navigator", "index"
    ]):
        return "documentation"

    # MCP統合系
    if any(kw in name or kw in description for kw in [
        "mcp", "external tool", "mcp server", "mcp integration"
    ]):
        return "integration"

    # 実装系
    if any(kw in name or kw in description for kw in [
        "implement", "spec-tdd", "builder", "creator"
    ]):
        return "implementation"

    # レビュー系
    if any(kw in name or kw in description for kw in [
        "review", "code-reviewer", "error-fixer", "evaluator"
    ]):
        return "review"

    # デプロイメント系
    if any(kw in name or kw in description for kw in [
        "deploy", "cicd", "terraform", "aws", "infrastructure"
    ]):
        return "deployment"

    # データベース系
    if any(kw in name or kw in description for kw in [
        "database", "db", "mysql", "postgres", "data"
    ]):
        return "database"

    # 品質系
    if any(kw in name or kw in description for kw in [
        "quality", "lint", "test", "validation"
    ]):
        return "quality"

    # デバッグ系
    if any(kw in name or kw in description for kw in [
        "debug", "monitor", "troubleshoot"
    ]):
        return "debug"

    return "general"
```

**実装ガイド**:

- Agentの名前・説明からカテゴリーを推定
- カテゴリー別の推奨Skillsマップを定義
- 推奨度に応じてスコアを調整

### Phase 4: 既存パターン学習（15点）

**目的**: 他の類似Agentが参照しているSkillsを学習

```python
def calculate_pattern_match(agent, skill, existing_agents):
    """既存パターン一致度を計算（最大15点）"""

    # 類似Agentを検索
    similar_agents = find_similar_agents(agent, existing_agents)

    if not similar_agents:
        return 0

    # 類似Agentが参照しているSkills
    referenced_skills = []
    for similar_agent in similar_agents:
        referenced_skills.extend(similar_agent.get("skills", []))

    # 参照頻度をカウント
    reference_count = referenced_skills.count(skill["name"])

    # スコア計算
    if reference_count >= 3:
        return 15  # 多数の類似Agentが参照
    elif reference_count == 2:
        return 10  # 複数の類似Agentが参照
    elif reference_count == 1:
        return 5   # 1つの類似Agentが参照
    else:
        return 0


def find_similar_agents(target_agent, existing_agents):
    """類似Agentを検索"""

    similar = []

    target_category = infer_agent_category(target_agent)

    for agent in existing_agents:
        # 自分自身は除外
        if agent["name"] == target_agent["name"]:
            continue

        # カテゴリーが一致
        if infer_agent_category(agent) == target_category:
            similar.append(agent)

    return similar
```

**実装ガイド**:

- Agentのカテゴリーが同じものを「類似」と判定
- 類似Agentが参照しているSkillsを集計
- 参照頻度に応じてスコアを調整

### Phase 5: キーワード一致（10点）

**目的**: Agent・Skill双方の説明文から共通キーワードを抽出

```python
def calculate_keyword_match(agent, skill):
    """キーワード一致度を計算（最大10点）"""

    # ストップワードを除外
    stop_words = {
        "the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for",
        "with", "by", "from", "up", "about", "into", "through", "during",
    }

    # Agent側のキーワード
    agent_keywords = extract_keywords(
        agent["description"],
        stop_words
    )

    # Skill側のキーワード
    skill_keywords = extract_keywords(
        skill["description"],
        stop_words
    )

    # 共通キーワード
    common_keywords = agent_keywords & skill_keywords

    # スコア計算
    if len(common_keywords) >= 5:
        return 10  # 多数の共通キーワード
    elif len(common_keywords) >= 3:
        return 7   # 中程度
    elif len(common_keywords) >= 1:
        return 3   # 少数
    else:
        return 0


def extract_keywords(text, stop_words):
    """テキストからキーワードを抽出"""

    # 小文字化 + 単語分割
    words = text.lower().split()

    # ストップワード除外 + 短すぎる単語除外
    keywords = {
        word
        for word in words
        if word not in stop_words and len(word) >= 3
    }

    return keywords
```

**実装ガイド**:

- ストップワードリストを定義（冠詞・前置詞等）
- 説明文から意味のある単語を抽出
- 共通キーワード数に応じてスコア調整

### 総合スコア計算

**目的**: 5つの軸のスコアを合計し、最終判定

```python
def recommend_skills(agent, available_skills, existing_agents):
    """Skillsを推奨"""

    recommendations = []

    for skill in available_skills:
        # 5つの軸でスコア計算
        tech_score = calculate_technology_match(agent, skill)
        name_score = calculate_name_match(agent, skill)
        context_score = calculate_context_match(agent, skill)
        pattern_score = calculate_pattern_match(agent, skill, existing_agents)
        keyword_score = calculate_keyword_match(agent, skill)

        # 総合スコア
        total_score = (
            tech_score +
            name_score +
            context_score +
            pattern_score +
            keyword_score
        )

        # 判定
        if total_score >= 50:
            action = "auto_add"  # 自動追加
        elif total_score >= 30:
            action = "suggest"   # 提案
        else:
            action = "exclude"   # 除外

        recommendations.append({
            "skill": skill["name"],
            "score": total_score,
            "action": action,
            "breakdown": {
                "technology": tech_score,
                "name": name_score,
                "context": context_score,
                "pattern": pattern_score,
                "keyword": keyword_score,
            },
            "reason": generate_reason(
                tech_score,
                name_score,
                context_score,
                pattern_score,
                keyword_score
            ),
        })

    # スコア降順でソート
    recommendations.sort(key=lambda r: r["score"], reverse=True)

    return recommendations


def generate_reason(tech, name, context, pattern, keyword):
    """推奨理由を生成"""

    reasons = []

    if tech > 0:
        reasons.append("技術スタック一致")
    if name > 0:
        reasons.append("名前一致")
    if context > 0:
        reasons.append("コンテキスト一致")
    if pattern > 0:
        reasons.append("既存パターン")
    if keyword > 0:
        reasons.append("キーワード一致")

    return " + ".join(reasons) if reasons else "一致なし"
```

**実装ガイド**:

- 5軸のスコアを合計
- スコアに基づいて action を決定
- 推奨理由を明確に提示
- 結果をスコア降順でソート

## 📊 出力例

```typescript
interface SkillRecommendation {
  skill: string;
  score: number;
  action: "auto_add" | "suggest" | "exclude";
  breakdown: {
    technology: number;
    name: number;
    context: number;
    pattern: number;
    keyword: number;
  };
  reason: string;
}

// 例: orchestrator agent（統合フレームワークスキル追加）
const recommendations = [
  {
    skill: "integration-framework",
    score: 65,
    action: "auto_add",
    breakdown: {
      technology: 30, // "integration", "orchestration"言及あり
      name: 0, // 名前一致なし
      context: 20, // orchestration系Agentに最推奨
      pattern: 15, // 複数の類似Agentが参照
      keyword: 0, // キーワード少ない
    },
    reason: "技術スタック一致 + コンテキスト一致 + 既存パターン",
  },
  {
    skill: "agents-and-commands",
    score: 60,
    action: "auto_add",
    breakdown: {
      technology: 20, // "agent selection"言及あり
      name: 10, // "agent"という語が含まれる
      context: 20, // orchestration系Agentに最推奨
      pattern: 10, // 類似Agentが参照
      keyword: 0,
    },
    reason: "技術スタック一致 + 名前一致 + コンテキスト一致 + 既存パターン",
  },
  {
    skill: "typescript",
    score: 55,
    action: "auto_add",
    breakdown: {
      technology: 30, // TypeScript言及あり
      name: 0, // 名前一致なし
      context: 15, // 実装系Agentに推奨
      pattern: 10, // 類似Agentが参照
      keyword: 0, // キーワード少ない
    },
    reason: "技術スタック一致 + コンテキスト一致 + 既存パターン",
  },
  {
    skill: "golang",
    score: 50,
    action: "auto_add",
    breakdown: {
      technology: 30, // Go言及あり
      name: 0,
      context: 15, // 実装系Agentに推奨
      pattern: 5, // 一部が参照
      keyword: 0,
    },
    reason: "技術スタック一致 + コンテキスト一致 + 既存パターン",
  },
  {
    skill: "code-quality-improvement",
    score: 45,
    action: "suggest",
    breakdown: {
      technology: 10, // code quality言及あり
      name: 0,
      context: 20, // 実装系Agentに強く推奨
      pattern: 10, // 類似Agentが参照
      keyword: 5, // 共通キーワードあり
    },
    reason:
      "技術スタック一致 + コンテキスト一致 + 既存パターン + キーワード一致",
  },
  {
    skill: "react",
    score: 25,
    action: "exclude",
    breakdown: {
      technology: 0, // React言及なし
      name: 0,
      context: 15, // 実装系には推奨されるが
      pattern: 5, // 一部が参照
      keyword: 5, // 共通キーワード少ない
    },
    reason: "コンテキスト一致 + 既存パターン + キーワード一致",
  },
];
```

## 🛠️ 実装Tips

### 技術スタックキーワードの拡張

```python
# より包括的なキーワードマップ
extended_keywords = {
    "typescript": [
        "typescript", "ts", "type safety", "type check",
        "type annotation", "interface", "type guard"
    ],
    "react": [
        "react", "jsx", "tsx", "component", "hook",
        "usestate", "useeffect", "usememo", "next.js"
    ],
    "security": [
        "security", "owasp", "vulnerability", "xss", "sql injection",
        "csrf", "authentication", "authorization", "encryption"
    ],
}
```

### カテゴリー推定の精度向上

```python
def infer_agent_category_advanced(agent):
    """より高度なカテゴリー推定"""

    # 複数カテゴリーの可能性をスコアリング
    category_scores = {
        "implementation": 0,
        "review": 0,
        "deployment": 0,
        # ...
    }

    # 名前ベーススコア
    for category, keywords in category_keywords.items():
        for keyword in keywords:
            if keyword in agent["name"].lower():
                category_scores[category] += 10

    # 説明ベーススコア
    for category, keywords in category_keywords.items():
        for keyword in keywords:
            if keyword in agent["description"].lower():
                category_scores[category] += 5

    # 最高スコアのカテゴリーを返す
    return max(category_scores, key=category_scores.get)
```

### パフォーマンス最適化

```python
# キャッシュを活用
@lru_cache(maxsize=128)
def extract_keywords_cached(text, stop_words_tuple):
    """キーワード抽出（キャッシュ付き）"""
    return extract_keywords(text, set(stop_words_tuple))

# 並列処理
from concurrent.futures import ThreadPoolExecutor

def recommend_skills_parallel(agent, available_skills, existing_agents):
    """並列でSkills推奨を計算"""

    with ThreadPoolExecutor(max_workers=4) as executor:
        futures = [
            executor.submit(calculate_single_recommendation, agent, skill, existing_agents)
            for skill in available_skills
        ]

        recommendations = [f.result() for f in futures]

    recommendations.sort(key=lambda r: r["score"], reverse=True)
    return recommendations
```

## 🌟 新規スキル（統合フレームワーク）のマッピング例

### integration-framework スキル

**推奨対象Agent**:

- orchestrator（スコア: 65）
- task-orchestrator（スコア: 70）
- researcher（スコア: 45 - suggest）

**スコア内訳**:

- **技術スタック一致（30点）**: "integration", "orchestration", "task context"等のキーワード
- **コンテキスト一致（20点）**: orchestration系Agentの最推奨スキル
- **既存パターン（15点）**: 複数の類似Agentが参照
- **名前一致（0点）**: 名前に直接的な一致なし
- **キーワード一致（0点）**: 共通キーワード少ない

### agents-and-commands スキル

**推奨対象Agent**:

- task-orchestrator（スコア: 60）
- researcher（スコア: 50）
- orchestrator（スコア: 45 - suggest）

**スコア内訳**:

- **技術スタック一致（20点）**: "agent selection", "tool selection"等のキーワード
- **コンテキスト一致（20点）**: tool_selection系Agentの最推奨スキル
- **名前一致（10点）**: "agent"という語が含まれる
- **既存パターン（10点）**: 類似Agentが参照
- **キーワード一致（0点）**: 共通キーワード少ない

### mcp-tools スキル

**推奨対象Agent**:

- researcher（スコア: 55）
- orchestrator（スコア: 40 - suggest）

**スコア内訳**:

- **技術スタック一致（30点）**: "mcp", "external tool", "integration"等のキーワード
- **コンテキスト一致（20点）**: integration系Agentの最推奨スキル
- **既存パターン（5点）**: 一部のAgentが参照
- **名前一致（0点）**: 名前に直接的な一致なし
- **キーワード一致（0点）**: 共通キーワード少ない

### docs-index スキル

**推奨対象Agent**:

- researcher（スコア: 60）
- docs-manager（スコア: 70）

**スコア内訳**:

- **技術スタック一致（30点）**: "documentation", "guide", "index"等のキーワード
- **コンテキスト一致（20点）**: documentation系Agentの最推奨スキル
- **名前一致（10点）**: "docs"という語が含まれる
- **既存パターン（10点）**: 類似Agentが参照
- **キーワード一致（0点）**: 共通キーワード少ない

---

## 参考実装

- `/skill-up` - 分類アルゴリズムのスコアリング
- `code-review` skill - カテゴリー別推奨パターン
- `semantic-analysis` skill - 関連性分析手法
- `commands/shared/integration-matrix.md` - Command→Skill→Agent統合マトリックス
- `commands/shared/agent-selector.md` - スキル自動検出ロジック
