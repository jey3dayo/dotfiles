# Detailed Mode 実行ガイド

包括的な品質評価を実施する詳細モードの実行方法を定義します。

## 概要

Detailed Modeは、⭐️5段階評価体系を用いて複数の次元から総合的にコードを評価します。プロジェクトタイプを自動検出し、適切な技術スタック別スキルと評価基準を組み合わせることで、文脈に即した精緻なレビューを実現します。

## 実行フロー

### Step 1: 初期化とチェックポイント作成

```python
def initialize_detailed_review():
    """詳細レビューの初期化"""

    # チェックポイント作成
    result = subprocess.run(
        ["git", "add", "-A"],
        capture_output=True
    )

    commit_result = subprocess.run(
        ["git", "commit", "-m", "Pre-review checkpoint"],
        capture_output=True
    )

    if commit_result.returncode != 0:
        print("チェックポイント作成: 変更なし")
    else:
        print(f"チェックポイント作成: {commit_result.stdout.decode()}")

    # モード検出
    mode = "detailed"
    serena_enabled = detect_serena_options(sys.argv)

    return {
        "mode": mode,
        "serena_enabled": serena_enabled,
        "timestamp": datetime.now()
    }
```

### Step 2: 対象ファイル決定

優先順位に基づいて自動的にレビュー対象を決定：

```python
def determine_review_targets():
    """レビュー対象ファイルの決定"""

    # 1. ステージされた変更を最優先
    staged_files = get_git_diff_files("--cached")
    if staged_files:
        return {
            "files": staged_files,
            "source": "git diff --cached (ステージされた変更)",
            "count": len(staged_files)
        }

    # 2. 直前のコミットとの差分
    recent_files = get_git_diff_files("HEAD~1")
    if recent_files:
        return {
            "files": recent_files,
            "source": "git diff HEAD~1 (直前のコミット)",
            "count": len(recent_files)
        }

    # 3. 開発ブランチとの差分
    dev_branch = detect_dev_branch()
    if dev_branch:
        dev_files = get_git_diff_files(dev_branch)
        if dev_files:
            return {
                "files": dev_files,
                "source": f"git diff {dev_branch} (ブランチ差分)",
                "count": len(dev_files)
            }

    # 4. 最近変更されたファイル
    recent_modified = get_recently_modified_files(limit=10)
    return {
        "files": recent_modified,
        "source": "最近変更されたファイル (git log)",
        "count": len(recent_modified)
    }

def get_git_diff_files(diff_target):
    """git diffでファイル一覧を取得"""
    result = subprocess.run(
        ["git", "diff", "--name-only", diff_target],
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        return []

    files = [f.strip() for f in result.stdout.split('\n') if f.strip()]
    return [f for f in files if is_reviewable_file(f)]

def is_reviewable_file(filepath):
    """レビュー対象ファイルかどうか判定"""
    exclude_patterns = [
        "*.min.js", "*.min.css", "*.map",
        "node_modules/", "vendor/", ".git/",
        "*.generated.*", "*.lock", "*.log",
        "dist/", "build/", ".next/", "out/"
    ]

    for pattern in exclude_patterns:
        if fnmatch.fnmatch(filepath, pattern):
            return False

    reviewable_extensions = {
        ".go", ".js", ".ts", ".tsx", ".jsx",
        ".py", ".java", ".kt", ".swift",
        ".c", ".cpp", ".h", ".hpp",
        ".rs", ".php", ".rb", ".cs",
        ".md", ".yaml", ".yml", ".json"
    }

    _, ext = os.path.splitext(filepath)
    return ext.lower() in reviewable_extensions
```

### Step 3: プロジェクト分析

プロジェクト構造を分析し、適切な評価基準を決定：

```python
def analyze_project():
    """プロジェクト分析"""

    project_info = {
        "type": None,         # api, frontend, fullstack, library
        "stack": [],          # go, typescript, react, python, etc.
        "structure": {},      # clean_architecture, mvc, etc.
        "has_tests": False,
        "has_ci": False
    }

    # ファイル構造から判定
    if os.path.exists("go.mod"):
        project_info["stack"].append("go")

        # Go APIプロジェクトの判定
        if glob.glob("**/*_handler.go", recursive=True):
            project_info["type"] = "api"

        # Clean Architectureの判定
        if (os.path.exists("domain") and
            os.path.exists("usecase") and
            os.path.exists("infrastructure")):
            project_info["structure"]["clean_architecture"] = True

    if os.path.exists("package.json"):
        with open("package.json") as f:
            pkg = json.load(f)
            deps = {**pkg.get("dependencies", {}), **pkg.get("devDependencies", {})}

            if "typescript" in deps or os.path.exists("tsconfig.json"):
                project_info["stack"].append("typescript")

            if "react" in deps or "next" in deps:
                project_info["stack"].append("react")

            if "next" in deps:
                project_info["stack"].append("next")
                project_info["type"] = "fullstack"
            elif "react" in deps:
                project_info["type"] = "frontend"

    # テスト存在確認
    test_patterns = ["**/*_test.*", "**/test/**", "**/tests/**", "**/*.test.*", "**/*.spec.*"]
    for pattern in test_patterns:
        if glob.glob(pattern, recursive=True):
            project_info["has_tests"] = True
            break

    # CI設定確認
    if os.path.exists(".github/workflows") or os.path.exists(".gitlab-ci.yml"):
        project_info["has_ci"] = True

    return project_info
```

### Step 4: 技術スタック別スキル統合

```python
def integrate_tech_skills(project_info):
    """技術スタック別スキルの統合"""

    skills_to_invoke = []

    # 言語・フレームワークスキル
    if "typescript" in project_info["stack"]:
        skills_to_invoke.append({
            "name": "typescript",
            "priority": "high",
            "focus": ["type_safety", "strict_mode", "type_guards"]
        })

    if "react" in project_info["stack"]:
        skills_to_invoke.append({
            "name": "react",
            "priority": "high",
            "focus": ["hooks", "performance", "component_design"]
        })

    if "golang" in project_info["stack"] or "go" in project_info["stack"]:
        skills_to_invoke.append({
            "name": "golang",
            "priority": "high",
            "focus": ["error_handling", "concurrency", "idioms"]
        })

    # アーキテクチャパターンスキル
    if project_info["structure"].get("clean_architecture"):
        skills_to_invoke.append({
            "name": "clean-architecture",
            "priority": "medium",
            "focus": ["layer_separation", "dependency_rule", "domain_modeling"]
        })

    # 横断的関心事スキル
    if project_info["type"] in ["api", "backend", "fullstack"]:
        skills_to_invoke.append({
            "name": "security",
            "priority": "high",
            "focus": ["input_validation", "auth", "data_protection"]
        })

    # セマンティック解析（オプション）
    if project_info.get("needs_semantic_analysis"):
        skills_to_invoke.append({
            "name": "semantic-analysis",
            "priority": "medium",
            "focus": ["symbol_tracking", "impact_analysis"]
        })

    return skills_to_invoke
```

### Step 5: 評価基準の統合

```python
def merge_criteria_files(project_info, tech_skills):
    """評価基準ファイルの統合"""

    criteria_parts = []

    # 1. デフォルト評価基準（必須）
    with open(expand_path("~/.claude/skills/code-review/references/default-criteria.md")) as f:
        criteria_parts.append({
            "source": "default",
            "priority": "base",
            "content": f.read()
        })

    # 2. 技術スタック別評価基準
    for skill in tech_skills:
        skill_path = expand_path(f"~/.claude/skills/{skill['name']}/SKILL.md")
        if os.path.exists(skill_path):
            with open(skill_path) as f:
                criteria_parts.append({
                    "source": skill['name'],
                    "priority": skill['priority'],
                    "content": f.read()
                })

    # 3. プロジェクト固有評価基準（最優先）
    project_criteria_paths = [
        "./.claude/review-criteria.md",
        "./docs/review-criteria.md",
        "./docs/guides/review-criteria.md"
    ]

    for path in project_criteria_paths:
        if os.path.exists(path):
            with open(path) as f:
                criteria_parts.append({
                    "source": "project-specific",
                    "priority": "highest",
                    "content": f.read()
                })
            break

    # 統合
    combined = "\n\n---\n\n".join([
        f"## {part['source'].upper()} 評価基準\n\n{part['content']}"
        for part in sorted(criteria_parts, key=lambda x: {
            "highest": 0, "high": 1, "medium": 2, "base": 3
        }[x['priority']])
    ])

    return combined
```

### Step 6: 包括的レビュー実行

```python
def execute_detailed_review(targets, criteria, project_info, options):
    """包括的レビューの実行"""

    # code-reviewerエージェントを使用
    prompt = f"""
プロジェクト特化型の包括的コードレビューを実施してください。
**必ず日本語で回答してください。**

## プロジェクト情報
- タイプ: {project_info['type']}
- 技術スタック: {', '.join(project_info['stack'])}
- アーキテクチャ: {', '.join(project_info['structure'].keys())}

## 評価基準
{criteria}

## レビュー対象
対象決定方法: {targets['source']}
ファイル数: {targets['count']}件

{format_target_files(targets['files'])}

## 要求事項
1. **必ず日本語で回答**
2. 各評価次元について⭐️5段階で評価
3. 具体的なfile:line参照を含める
4. 改善提案は優先度付き（高・中・低）
5. プロジェクト特性を考慮した実践的アドバイス
6. 総合評価と優先度付きアクションプラン
"""

    if options.get("with_impact"):
        prompt += "\n\n## 追加分析\nSerenaを使用してAPI変更の影響範囲を分析してください。"

    # エージェント実行
    from claude_code import Task

    result = Task(
        subagent_type="code-reviewer",
        description=f"包括的コードレビュー ({targets['count']}ファイル)",
        prompt=prompt
    )

    return result
```

### Step 7: 評価と結果生成

```python
def generate_ratings_and_actions(review_result, project_type):
    """⭐️評価とアクションプランの生成"""

    # 評価抽出（レビュー結果から）
    ratings = extract_ratings(review_result)

    # 総合評価算出
    weights = get_weights_for_project_type(project_type)
    overall_rating = calculate_weighted_average(ratings, weights)

    # アクションプラン生成
    actions = {
        "high": [],
        "medium": [],
        "low": []
    }

    for dimension, rating in ratings.items():
        if rating <= 2:
            actions["high"].extend(get_actions_for_dimension(dimension, rating))
        elif rating == 3:
            actions["medium"].extend(get_actions_for_dimension(dimension, rating))
        elif rating == 4:
            actions["low"].extend(get_actions_for_dimension(dimension, rating))

    return {
        "overall": overall_rating,
        "dimensions": ratings,
        "actions": actions
    }

def get_weights_for_project_type(project_type):
    """プロジェクトタイプ別の重み"""

    weights_map = {
        "api": {
            "security": 0.25,
            "performance": 0.20,
            "code_quality": 0.20,
            "error_handling": 0.15,
            "architecture": 0.15,
            "testing": 0.05
        },
        "frontend": {
            "code_quality": 0.25,
            "performance": 0.20,
            "testing": 0.20,
            "architecture": 0.15,
            "error_handling": 0.10,
            "security": 0.10
        },
        "fullstack": {
            "security": 0.20,
            "code_quality": 0.20,
            "performance": 0.15,
            "testing": 0.15,
            "architecture": 0.15,
            "error_handling": 0.15
        }
    }

    return weights_map.get(project_type, weights_map["fullstack"])
```

## Serena統合（オプション）

`--with-impact`, `--deep-analysis`, `--verify-spec`フラグ使用時のセマンティック解析：

```python
def perform_serena_analysis(targets, options):
    """Serenaによるセマンティック解析"""

    analysis_results = {}

    if "--with-impact" in options:
        # API変更の影響分析
        for file in targets['files']:
            symbols = get_symbols_overview(file)

            for symbol in symbols.get("symbols", []):
                refs = find_referencing_symbols(
                    name_path=symbol["name"],
                    relative_path=file
                )

                if refs:
                    analysis_results.setdefault("impact", []).append({
                        "symbol": symbol["name"],
                        "file": file,
                        "references": refs,
                        "breaking": is_breaking_change(symbol, refs)
                    })

    if "--deep-analysis" in options:
        # 深いシンボルレベル解析
        for file in targets['files']:
            symbols = find_symbol(
                name_path="/",  # すべてのトップレベルシンボル
                relative_path=file,
                depth=2,
                include_body=False
            )

            analysis_results.setdefault("symbols", []).extend(symbols)

    if "--verify-spec" in options:
        # 仕様検証エージェント実行
        spec_result = Task(
            subagent_type="spec-verifier",
            description="仕様との整合性確認",
            prompt=f"対象ファイル: {targets['files']}。**必ず日本語で回答してください。**"
        )

        analysis_results["spec_verification"] = spec_result

    return analysis_results
```

## 出力フォーマット

詳細モードの標準出力：

```markdown
# コードレビュー結果

## 総合評価: ⭐️⭐️⭐️⭐️☆ (4/5) 良好

レビュー対象: git diff --cached (ステージされた変更)
ファイル数: 12件
プロジェクト: Next.js Fullstack

## 次元別評価

| 次元               | 評価       | コメント                                     |
| ------------------ | ---------- | -------------------------------------------- |
| コード品質         | ⭐️⭐️⭐️⭐️⭐️ | 優れた可読性、TypeScript型安全性が徹底       |
| セキュリティ       | ⭐️⭐️⭐️⭐️☆  | 主要な対策済み、CSRF対策の追加を推奨         |
| パフォーマンス     | ⭐️⭐️⭐️⭐️☆  | 効率的、一部のN+1クエリ解消を推奨            |
| テスト             | ⭐️⭐️⭐️☆☆   | カバレッジ向上が必要（現状60%、目標80%）     |
| エラーハンドリング | ⭐️⭐️⭐️⭐️☆  | Result型パターン使用、一部エッジケース対応を |
| アーキテクチャ     | ⭐️⭐️⭐️⭐️⭐️ | Clean Architectureに準拠、優れた層分離       |

## 優先度付きアクションプラン

### 🔴 高優先度

なし

### 🟡 中優先度

1. **テストカバレッジ向上** (src/services/user.ts:45-120)
   - 現状: 60% → 目標: 80%+
   - エッジケース追加が必要（境界値、異常系）
   - 推定工数: 4時間

2. **CSRF対策追加** (src/middleware/auth.ts:23)
   - csrfトークン検証の実装を推奨
   - 推定工数: 2時間

### 🟢 低優先度

1. **N+1クエリ解消** (src/repositories/post.ts:78)
   - eager loadingの適用を推奨
   - 推定工数: 1時間

2. **型アサーション削減** (src/utils/transform.ts:34)
   - type guardによる安全な型絞り込みへの置き換え
   - 推定工数: 0.5時間

## 詳細な発見事項

[具体的なコード参照と改善提案...]
```

### Step 8: PR コメント自動チェック

レビュー結果出力後、`--no-comments` が指定されていなければ
PR コメントチェックを実行。

詳細は [PR Comment Integration](pr-comment-integration.md) を参照。

## 使用例

```bash
# 基本的な詳細レビュー
/review

# Serena統合による影響分析
/review --with-impact

# 深いセマンティック解析
/review --deep-analysis

# 仕様検証を含む
/review --verify-spec

# 自動修正を含む
/review --fix

# すべての機能を組み合わせ
/review --with-impact --deep-analysis --fix
```

---

### 目標
