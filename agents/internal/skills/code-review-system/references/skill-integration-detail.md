# スキル統合詳細

code-review-systemが統合するスキルの詳細仕様です。

## 必須スキル

### code-review (必須)

### 目的

### トリガー

### 統合タイミング

### 提供内容

- ⭐️5段階評価システム（1〜5の星評価）
- プロジェクトタイプ自動判定（Next.js, React SPA, Node.js API, Go API等）
- 技術スタック別スキル自動統合
- code-reviewerエージェント連携

### 統合フロー

```
/review コマンド
    ↓
code-review スキル起動
    ↓
プロジェクト判定 (project-detector)
    ↓
技術スキル自動ロード (typescript, react, golang, etc.)
    ↓
評価基準統合
    ↓
code-reviewer エージェント実行
    ↓
⭐️評価レポート生成（日本語）
```

### 統合例

```python
# Invoke code-review skill
skill_result = execute_skill("code-review", {
    "mode": mode,  # "detailed" or "simple"
    "options": {
        "fix": "--fix" in args,
        "create_issues": "--create-issues" in args,
        "learn": "--learn" in args,
        "with_impact": "--with-impact" in args,
        "deep_analysis": "--deep-analysis" in args,
        "verify_spec": "--verify-spec" in args
    },
    "targets": determine_review_targets(args),
    "project_type": detect_project_type(),
    "tech_skills": load_skills_for_project(project_type)
})
```

## 条件付きスキル

### ci-diagnostics (CI診断モード)

### 目的

### トリガー

### 統合タイミング

### 提供内容

- 失敗チェックの収集と分類（lint, test, build, deploy等）
- エラーログ解析と影響ファイル特定
- 修正計画と推奨スキルの提示
- gh-fix-ciスキルとの連携

### 統合フロー

```
/review --fix-ci 123
    ↓
PR番号取得（自動検出 or 引数）
    ↓
ci-diagnostics スキル起動
    ↓
gh-fix-ci でログ取得
    ↓
失敗分類とエラーログ解析
    ↓
影響ファイル特定
    ↓
修正計画生成（日本語）
```

### 統合例

```python
# Get PR number
pr_number = get_pr_number_from_args_or_branch(args)

# Invoke ci-diagnostics skill
skill_result = execute_skill("ci-diagnostics", {
    "pr_number": pr_number,
    "options": {
        "dry_run": "--dry-run" in args,
        "verbose": "--verbose" in args
    }
})

# Result includes:
# - failed_checks: List[FailedCheck]
# - fix_plan: FixPlan
# - recommended_skills: List[str]
```

### gh-fix-review (PRレビューモード)

### 目的

### トリガー

### 統合タイミング

### 提供内容

- コメント優先度分類（Critical/High/Major/Minor）
- ボット別コメント分類（coderabbitai, github-actions等）
- カテゴリ別分類（security, bug, style, performance等）
- 自動修正戦略と実行
- トラッキングドキュメント生成
- TodoWrite統合

### 統合フロー

```
/review --fix-pr 123
    ↓
PR番号取得（自動検出 or 引数）
    ↓
gh-fix-review スキル起動
    ↓
PR情報取得（gh CLI）
    ↓
コメント分類（優先度・ボット・カテゴリ）
    ↓
自動修正実行（優先度順）
    ↓
品質保証（lint/test）
    ↓
トラッキングドキュメント生成
```

### 統合例

```python
# Get PR number
pr_number = get_pr_number_from_args_or_branch(args)

# Invoke gh-fix-review skill
skill_result = execute_skill("gh-fix-review", {
    "pr_number": pr_number,
    "options": {
        "priority": get_arg_value("--priority", args),  # critical/high/major/minor
        "bot_filter": get_arg_value("--bot", args),     # coderabbitai/github-actions
        "category_filter": get_arg_value("--category", args),  # security/bug/style
        "dry_run": "--dry-run" in args
    }
})

# Result includes:
# - classified_comments: Dict[Priority, List[Comment]]
# - fix_results: List[FixResult]
# - tracking_doc: TrackingDocument
```

## オプショナルスキル

### semantic-analysis (詳細モード・Serenaフラグ)

### 目的

### トリガー

### 統合タイミング

### 提供内容

- シンボル検索と参照追跡
- 影響範囲分析（API変更の影響を受けるファイル特定）
- API契約整合性検証
- 依存関係グラフ生成
- Serena MCPツール統合

### 統合フロー

```
/review --with-impact
    ↓
Serenaオプション検出
    ↓
semantic-analysis スキル起動
    ↓
Serena MCPツール使用:
  - find_symbol
  - find_referencing_symbols
  - search_for_pattern
    ↓
影響範囲分析
    ↓
詳細レポート生成（日本語）
```

### 統合例

```python
# Detect Serena options
serena_options = {
    "enabled": any(opt in args for opt in ['--with-impact', '--deep-analysis', '--verify-spec']),
    "with_impact": "--with-impact" in args,
    "deep_analysis": "--deep-analysis" in args,
    "verify_spec": "--verify-spec" in args
}

if serena_options["enabled"]:
    # Invoke semantic-analysis skill
    semantic_result = execute_skill("semantic-analysis", {
        "options": serena_options,
        "targets": determine_review_targets(args)
    })

    # Integrate with code-review
    skill_result["semantic_analysis"] = semantic_result
```

## プロジェクト特化スキル（自動検出）

### 自動統合の仕組み

プロジェクトタイプ検出に基づいて、技術スタック別スキルを自動ロード：

```python
def detect_project_type():
    """Detect project type from configuration files"""
    if exists("next.config.js") or exists("next.config.mjs"):
        return "nextjs"
    elif exists("package.json"):
        pkg = read_json("package.json")
        if "react" in pkg.get("dependencies", {}):
            return "react-spa"
        else:
            return "nodejs-api"
    elif exists("go.mod"):
        return "go-api"
    else:
        return "generic"

def load_skills_for_project(project_type):
    """Load tech-specific skills based on project type"""
    skills_map = {
        "nextjs": ["typescript", "react", "security"],
        "react-spa": ["typescript", "react"],
        "nodejs-api": ["typescript", "security"],
        "go-api": ["golang", "security", "clean-architecture"]
    }
    return skills_map.get(project_type, [])
```

### プロジェクトタイプ別統合

| プロジェクトタイプ | 統合スキル                           | 評価重点                                     |
| ------------------ | ------------------------------------ | -------------------------------------------- |
| **Next.js**        | typescript, react, security          | SSR/SSG、API Routes、パフォーマンス          |
| **React SPA**      | typescript, react                    | コンポーネント設計、状態管理、バンドルサイズ |
| **Node.js API**    | typescript, security                 | RESTful設計、認証・認可、エラーハンドリング  |
| **Go API**         | golang, security, clean-architecture | イディオマティックGo、並行処理、レイヤー分離 |

### 技術スキル詳細

#### typescript スキル

### 評価観点

- 型安全性（any型排除、strict mode、type guards）
- TypeScript best practices
- 型推論の活用
- genericsの適切な使用

### 統合例

```python
if "typescript" in tech_skills:
    evaluation_criteria["type_safety"] = {
        "weight": 0.25,
        "checks": [
            "no_any_types",
            "strict_mode_enabled",
            "proper_type_guards",
            "generic_usage"
        ]
    }
```

#### react スキル

### 評価観点

- Hooks使用パターン（useEffect cleanup、依存配列）
- パフォーマンス最適化（useMemo、useCallback、React.memo）
- コンポーネント設計（単一責任、prop drilling回避）
- 状態管理（useState vs useReducer、Context適切使用）

### 統合例

```python
if "react" in tech_skills:
    evaluation_criteria["react_patterns"] = {
        "weight": 0.20,
        "checks": [
            "hooks_usage",
            "performance_optimization",
            "component_design",
            "state_management"
        ]
    }
```

#### golang スキル

### 評価観点

- エラーハンドリング（error wrapping、context伝播）
- 並行処理（goroutine、channel、sync package）
- イディオマティックGo（naming、package structure）
- インターフェース設計（小さいインターフェース、依存性逆転）

### 統合例

```python
if "golang" in tech_skills:
    evaluation_criteria["golang_idioms"] = {
        "weight": 0.25,
        "checks": [
            "error_handling",
            "concurrency_patterns",
            "idiomatic_code",
            "interface_design"
        ]
    }
```

#### security スキル

### 評価観点

- 入力検証（SQL injection、XSS、CSRF）
- 認証・認可（JWT、OAuth、RBAC）
- データ保護（暗号化、sensitive data handling）
- セキュアコーディング（OWASP Top 10）

### 統合例

```python
if "security" in tech_skills:
    evaluation_criteria["security"] = {
        "weight": 0.30,
        "checks": [
            "input_validation",
            "auth_authorization",
            "data_protection",
            "owasp_compliance"
        ]
    }
```

#### clean-architecture スキル

### 評価観点

- 層分離（presentation、application、domain、infrastructure）
- 依存規則（内側層への単方向依存）
- ドメインモデリング（エンティティ、値オブジェクト、集約）
- インターフェース分離（境界での抽象化）

### 統合例

```python
if "clean-architecture" in tech_skills:
    evaluation_criteria["architecture"] = {
        "weight": 0.20,
        "checks": [
            "layer_separation",
            "dependency_rule",
            "domain_modeling",
            "interface_segregation"
        ]
    }
```

## 統合フローの実例

### 例1: 詳細モード（Next.jsプロジェクト）

```
/review
    ↓
code-review スキル起動
    ↓
プロジェクト判定: Next.js
    ↓
スキル自動ロード: ["typescript", "react", "security"]
    ↓
評価基準統合:
  - 型安全性: 25%
  - React patterns: 20%
  - セキュリティ: 30%
  - パフォーマンス: 15%
  - 保守性: 10%
    ↓
code-reviewer エージェント実行
    ↓
⭐️評価レポート生成:
  - 型安全性: ⭐️⭐️⭐️⭐️☆ (4/5)
  - React patterns: ⭐️⭐️⭐️⭐️⭐️ (5/5)
  - セキュリティ: ⭐️⭐️⭐️☆☆ (3/5)
  - ...
```

### 例2: シンプルモード（並列エージェント）

```
/review --simple
    ↓
code-review スキル起動
    ↓
プロジェクト判定 + スキルロード
    ↓
並列エージェント実行:
  - security エージェント (security スキル適用)
  - performance エージェント
  - quality エージェント (typescript + react スキル適用)
  - architecture エージェント
    ↓
結果集約:
  - 🔴 高優先度: 5件
  - 🟡 中優先度: 8件
  - 🟢 低優先度: 12件
    ↓
問題リスト生成（優先度順）
```

### 例3: PRレビュー修正モード

```
/review --fix-pr 123
    ↓
gh-fix-review スキル起動
    ↓
PR情報取得（gh CLI）
    ↓
コメント分類:
  - Critical: 2件
  - High: 5件
  - Major: 8件
  - Minor: 15件
    ↓
自動修正実行（優先度順）:
  1. [Critical] SQL Injection修正 (typescript + security)
  2. [Critical] Null pointer exception修正 (typescript)
  3. [High] N+1クエリ修正 (performance)
  ...
    ↓
品質保証（lint/test）
    ↓
トラッキングドキュメント生成
```

### 例4: CI診断 + PRコメント修正モード

```
/review --fix-ci --fix-pr 123
    ↓
並列実行:
  - ci-diagnostics スキル
  - gh-fix-review スキル
    ↓
結果統合:
  CI失敗:
    - Lint: 15件
    - Test: 3件
  PRコメント:
    - Critical: 2件
    - High: 5件
    ↓
統合優先度:
  1. 🔴 CI失敗 + セキュリティ
  2. 🔴 PRコメント（Critical）
  3. 🟡 CI失敗 + テスト
  4. 🟡 PRコメント（High）
  ...
    ↓
統合修正計画生成:
  Phase 1: Critical問題
  Phase 2: High問題
  Phase 3: Medium/Low問題
```

## スキル連携の利点

1. プロジェクト適応: 技術スタックに最適化された評価基準
2. 一貫性: 統一されたレビュー品質
3. 拡張性: 新しい技術スタック対応が容易
4. 効率性: Progressive Disclosureで必要な情報のみロード
5. 自動化: 手動設定不要、プロジェクト検出で自動統合

## トラブルシューティング

### スキルが見つからない

```bash
# スキルが存在するか確認
ls ~/.claude/skills/
ls ~/src/github.com/jey3dayo/claude-code-marketplace/plugins/dev-tools/

# Marketplace プラグインが追加されているか確認
# .claude/config.json 確認
```

### プロジェクト判定が間違っている

```python
# デバッグログで判定結果を確認
print(f"Detected project type: {project_type}")
print(f"Loaded skills: {tech_skills}")

# 手動でプロジェクトタイプを指定（将来機能）
/review --project-type nextjs
```

### Serena MCPツールが動作しない

```bash
# Serena MCPサーバーが設定されているか確認
cat ~/.claude/mcp.json

# Serena MCPサーバーが起動しているか確認
# Claude Code の起動ログを確認
```
