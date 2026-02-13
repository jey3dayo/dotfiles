---
name: premortem
description: |
  Planning/requirements/design段階でプロジェクト失敗原因を事前予測。
  Premortem手法を用い、プロジェクト特性に応じて3-5個の質問を動的生成し、
  未考慮の業界標準、技術リスク、アーキテクチャ欠陥を明らかにする。
  Use when: "premortem", "what could go wrong", "what am I missing", "failure prediction",
  "planning review", "design validation"を要求された時。cc-sdd、task-routerとの連携に対応。
---

# Premortem Analysis

## Overview

Premortem Analysisは、プロジェクトマネジメント手法の「Premortem（事前検死）」に基づき、計画段階で失敗原因を予測するスキルです。

### 核心的な価値

- 計画段階での盲点を早期発見（実装前に問題を特定）
- 業界標準のベストプラクティスの見落とし防止
- 専門家の暗黙知を質問形式で可視化
- 後工程でのトラブル（障害、コスト増）の予防

### 既存スキルとの差別化

| スキル                  | タイミング   | 焦点                               |
| ----------------------- | ------------ | ---------------------------------- |
| **predictive-analysis** | 実装後       | コードパターンからの将来リスク予測 |
| **code-review-system**  | 実装後       | コード品質の4視点検査              |
| **cc-sdd validation**   | 各段階終了時 | 形式的妥当性の検証                 |
| **premortem**           | 計画段階     | 「専門家の暗黙知」を質問で喚起     |

## Quick Start

### 基本的な呼び出し

#### 自動推察モード（プロジェクト説明なし）

```bash
/premortem
```

### 動作

- README.md、CLAUDE.md、AGENTS.md等を自動読み込み
- プロジェクトの性質（ドメイン、技術スタック、成熟度）を推察
- 推察結果に基づいて3-5個の関連質問を提示

### 推奨

#### 明示的なプロジェクト説明

```bash
/premortem "Next.js + PostgreSQLでブログプラットフォームを構築する計画"
```

### 期待される動作

1. コンテキスト解析（ドメイン: web-development、成熟度: mvp）
2. 3-5個の質問が提示される（認証アーキテクチャ、DB設計、APIレート制限等）
3. 各質問に対話的に回答
4. 発見された盲点をリスクレベル別にレポート

### 典型的な使用パターン

#### パターン1: 単独使用（計画レビュー）

```bash
/premortem "マイクロサービスでECサイトを構築。
注文、在庫、決済の3サービスに分割予定。
技術スタック: Node.js, MongoDB, RabbitMQ"
```

→ 分散トランザクション、サービス間通信、障害復旧戦略等の質問が提示される

#### パターン2: cc-sdd連携（設計検証）

```bash
/spec-design user-authentication
→ design.md 生成完了
/premortem "設計の盲点をチェック"
```

→ `.kiro/design/user-authentication.md`を読み込み、認証フローの脆弱性を質問

#### パターン3: task-router連携（複雑タスク分析）

```bash
/task "リアルタイムチャット機能を実装"
→ task-router が要求分析
→ premortem で技術選択の妥当性を検証
→ WebSocket vs SSE、スケール戦略等の質問
```

## 3-Layer Question Generation Logic

### Layer 1: Context Analysis（コンテキスト解析）

ユーザー入力とプロジェクトファイルから`ProjectContext`を生成：

```python
@dataclass
class ProjectContext:
    domain: str              # "web-development", "mobile-apps", etc.
    maturity: str            # "poc", "mvp", "production"
    tech_stack: List[str]    # ["React", "Node.js", "PostgreSQL"]
    scale: str               # "small", "medium", "large"
    description: str         # プロジェクト説明
```

### 解析要素

1. **ドメイン判定**: 技術スタック、キーワードから推定
   - "React", "API" → web-development
   - "Swift", "iOS" → mobile-apps
   - "Spark", "ETL" → data-systems
2. **成熟度推定**: スコープ、タイムラインから判断
   - "POC", "prototype" → poc
   - "MVP", "beta" → mvp
   - "production", "enterprise" → production
3. **スケール判定**: ユーザー数、データ量見積もりから
   - ~1K users → small
   - 1K-100K users → medium
   - 100K+ users → large

詳細: `references/frameworks/domain-detection.md`

### Layer 2: Question Selection（質問選択）

### 質問プール構成

- `references/questions/generic.yaml` (35問) - 全ドメイン共通
- `references/questions/web-development.yaml` (20問)
- `references/questions/mobile-apps.yaml` (18問)
- `references/questions/data-systems.yaml` (22問)
- `references/questions/infrastructure.yaml` (19問)
- `references/questions/security.yaml` (25問)

### スコアリングロジック

```python
def score_question(question: Dict, context: ProjectContext) -> float:
    score = 0.0

    # トリガーキーワードマッチ: +0.3
    if any(t in context.description.lower() for t in question["triggers"]):
        score += 0.3

    # ドメイン適合: +0.2
    if context.domain in question.get("relevance_boost", {}).get("domains", []):
        score += 0.2

    # 成熟度適合: +0.2
    if context.maturity in question.get("relevance_boost", {}).get("maturity", []):
        score += 0.2

    # 技術スタックマッチ: +0.3
    if any(tech.lower() in question["text"].lower() for tech in context.tech_stack):
        score += 0.3

    return min(score, 1.0)
```

### 選択基準

- スコア0.5以上の質問のみ選択
- 上位3-5問を抽出（優先度でソート）
- 重複カテゴリは排除（Architectureから最大2問等）

詳細: `references/frameworks/analysis-flow.md`

### Layer 3: Interactive Review（対話的レビュー）

各質問を1つずつ提示し、ユーザー回答を分析：

### 質問フォーマット

```markdown
## Q1: 認証・認可アーキテクチャ（Priority: Critical）

このシステムの認証・認可戦略は明確ですか？

- OAuth2.0 / JWT / セッションベース、どの方式を選択しますか？
- リフレッシュトークンのローテーション戦略は？
- パスワードハッシュアルゴリズム（bcrypt、argon2）の選定は？
- 多要素認証（MFA）の実装計画は？

**なぜ重要か**: 認証の脆弱性は後から修正が困難で、セキュリティインシデントに直結します。
```

### 回答分析

- 不足概念の検出（例: "JWT使う" → "リフレッシュトークンは？"と深堀り）
- 最大2回の深堀り質問（コンテキスト過負荷を防ぐ）
- 次の質問へ遷移

## 4-Phase Workflow

### Phase 1: Context Gathering

```markdown
1. ユーザー入力を解析
   - プロジェクト説明が提供された場合: その説明を使用
   - プロジェクト説明が未提供の場合: 自動推察モード

2. 自動推察モード（説明未提供時）
   優先順位でプロジェクトドキュメントを読み込み:
   - README.md - プロジェクト概要
   - CLAUDE.md - プロジェクト方針・技術スタック
   - AGENTS.md - エージェント設定・開発方針
   - .kiro/steering/\*.md - プロジェクト知識ベース
   - package.json, requirements.txt, Cargo.toml - 依存関係
   - docs/\*.md - 追加ドキュメント

3. コンテキスト統合
   - 収集した情報を統合してプロジェクト説明を生成
   - 技術スタック、ドメイン、成熟度を推定

4. ProjectContext生成
   scripts/analyze_context.py を実行
```

### Phase 2: Question Generation

```markdown
1. 質問プールロード
   - generic.yaml (35問)
   - {domain}.yaml (18-25問)

2. 各質問にスコア付与
   score_question() で0.0-1.0のスコア

3. トップ5質問を選択
   スコア降順でソート、0.5未満は除外

4. 質問を優先度順に整形
```

### Phase 3: Interactive Review

```markdown
1. 質問を1つずつ提示（マークダウン形式）

2. ユーザー回答を分析
   - 回答内容から不足概念を検出
   - 必要に応じて深堀り質問（最大2回）

3. 次の質問へ（全5問繰り返し）
```

### Phase 4: Report Generation

```markdown
1. 発見された盲点をリスクレベル別に分類
   🔴 Critical: 即対応必須
   🟡 Medium: 優先度高
   🟢 Low: 余裕があれば対応
   ✅ Covered: 既に考慮済み

2. 推奨アクション提示
   - 優先度順の対応リスト
   - 参考リソース（記事、ドキュメント）
   - 次のステップ提案

3. セッション保存（オプション）
   .premortem-sessions/YYYY-MM-DD-HHMMSS.yaml
```

## Domain Coverage

| ドメイン        | 質問数 | 重点領域                                      |
| --------------- | ------ | --------------------------------------------- |
| Generic         | 35問   | Architecture, Security, Reliability, Cost     |
| Web Development | 20問   | API Design, Security, Performance, Data       |
| Mobile Apps     | 18問   | Platform, Performance, Offline, Push          |
| Data Systems    | 22問   | Schema, ETL, Scaling, Consistency             |
| Infrastructure  | 19問   | Deployment, Monitoring, Disaster Recovery     |
| Security        | 25問   | Authentication, Encryption, Compliance, OWASP |

各ドメインの詳細は対応する`references/questions/{domain}.yaml`を参照。

## Integration Points

### cc-sdd との連携

設計完了後に自動でpremortemを実行：

```bash
# 設計フェーズ
/spec-design feature-name
→ .kiro/design/feature-name.md 生成

# 自動トリガー（cc-sddの設定で有効化可能）
→ premortem が設計内容を解析
→ 盲点を発見
→ /validate-design に結果反映
```

### 連携メリット

- 設計の形式的妥当性（validate-design）と概念的完全性（premortem）を両方チェック
- 設計の手戻りを最小化

### task-router との連携

複雑なタスク受領時に自動で盲点分析：

```bash
/task "複雑な要求（例: 認証システム実装）"

→ task-router が要求分析
→ premortem で技術選択の妥当性を検証
→ サブタスク生成前に盲点を解消
```

### 連携メリット

- タスク分解前に見落としを防止
- 実装フェーズでの手戻り削減

### 単独使用のシナリオ

プロジェクト企画段階での早期検証：

```bash
/premortem "新規プロジェクトの計画概要"
```

### 使用タイミング

- プロジェクト企画書作成後
- 技術選定前のリスク洗い出し
- 見積もり前の課題特定

## Scripts

### analyze_context.py

プロジェクトコンテキストを解析し、適切な質問を選択：

```bash
python3 scripts/analyze_context.py \
  --input "プロジェクト説明" \
  --files "package.json,README.md" \
  --output context.json
```

### 出力例

```json
{
  "domain": "web-development",
  "maturity": "mvp",
  "tech_stack": ["React", "Node.js", "PostgreSQL"],
  "scale": "medium",
  "selected_questions": [
    { "id": "WEB-001", "score": 0.92, "text": "..." },
    { "id": "GEN-003", "score": 0.88, "text": "..." }
  ]
}
```

### format_report.py

レポートを整形し、アクションアイテムを生成：

```bash
python3 scripts/format_report.py \
  --session session.yaml \
  --output report.md
```

### 出力例

```markdown
# Premortem Analysis Report

## Critical Issues (🔴)

1. **認証アーキテクチャの未定義**
   - OAuth2.0のスコープ設計が不明確
   - 推奨: Auth0のドキュメント参照

## Medium Issues (🟡)

2. **APIレート制限の未考慮**
   - DoS対策が計画に含まれていない
   - 推奨: Redis + Sliding Windowアルゴリズム
```

## Examples

実際のセッション例:

- `references/examples/session-web-api.yaml` - Web API設計のPremortem
- `references/examples/session-ml-pipeline.yaml` - MLパイプラインのPremortem

各例にはコンテキスト、提示された質問、ユーザー回答、発見された盲点が含まれます。

## Best Practices

1. **早期実行**: 設計フェーズ開始直後に実行
2. **正直な回答**: 「分からない」は重要な情報
3. **深堀りを恐れない**: 追加質問は盲点発見のチャンス
4. **結果を記録**: セッション結果を設計ドキュメントに統合
5. **定期的な再実行**: プロジェクトスコープ変更時は再実行

## Limitations

- 質問プールは定期的に更新が必要（新技術、新ベストプラクティス）
- ドメイン外のプロジェクト（組み込み、ゲーム開発等）はカバレッジが限定的
- 質問の関連度はヒューリスティック（完璧ではない）

## Progressive Disclosure Efficiency

- **初回ロード**: metadata + SKILL.md = 15.5KB
- **質問生成時**: + questions/\*.yaml = 13KB
- **フルロード**: + scripts/ + frameworks/ = 49.5KB
- **削減率**: 15.5KB / 49.5KB = **31.3%**

## References

- `references/frameworks/analysis-flow.md` - 質問生成フローの詳細
- `references/frameworks/domain-detection.md` - ドメイン判定ロジックの詳細
- `references/questions/*.yaml` - 全質問プール
- `references/examples/*.yaml` - 実践例
