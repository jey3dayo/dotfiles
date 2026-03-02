# Simple Mode 実行ガイド

迅速で実用的な問題発見に特化したシンプルモードの実行方法を定義します。

## 概要

Simple Modeは、専門サブエージェントを並列実行することで、セキュリティ、パフォーマンス、コード品質、アーキテクチャの各観点から迅速に問題を発見します。日常的な開発ワークフローやCI/CD統合に最適化されています。

## 実行フロー

### Step 1: 初期化とチェックポイント

```python
def initialize_simple_review():
    """シンプルレビューの初期化"""

    # チェックポイント作成
    subprocess.run(
        ["git", "add", "-A"],
        capture_output=True
    )

    commit_result = subprocess.run(
        ["git", "commit", "-m", "Pre-review checkpoint"],
        capture_output=True
    )

    # 対象ファイル決定（詳細モードと同じロジック）
    targets = determine_review_targets()

    return {
        "mode": "simple",
        "targets": targets,
        "timestamp": datetime.now()
    }
```

### Step 2: サブエージェント並列実行

4つの専門サブエージェントを同時に起動：

```python
def launch_sub_agents(targets):
    """サブエージェントの並列起動"""

    # 並列実行用のタスクリスト
    tasks = []

    # 1. セキュリティサブエージェント
    security_task = Task(
        subagent_type="researcher",
        description="セキュリティ分析",
        prompt=f"""
セキュリティ観点でコードを分析してください。**必ず日本語で回答してください。**

対象ファイル: {targets['files']}

重点項目:
- 入力検証の有無
- SQLインジェクション、XSS対策
- 認証・認可の実装
- 機密情報の扱い
- 既知の脆弱性パターン

問題発見時の出力形式:
[優先度] 問題の説明: ファイル名:行番号
        """
    )

    # 2. パフォーマンスサブエージェント
    performance_task = Task(
        subagent_type="researcher",
        description="パフォーマンス分析",
        prompt=f"""
パフォーマンス観点でコードを分析してください。**必ず日本語で回答してください。**

対象ファイル: {targets['files']}

重点項目:
- N+1クエリ問題
- 非効率なループ
- メモリリーク
- 不要な再計算
- ボトルネックの特定

問題発見時の出力形式:
[優先度] 問題の説明: ファイル名:行番号
        """
    )

    # 3. コード品質サブエージェント
    quality_task = Task(
        subagent_type="researcher",
        description="コード品質分析",
        prompt=f"""
コード品質観点で分析してください。**必ず日本語で回答してください。**

対象ファイル: {targets['files']}

重点項目:
- 複雑度が高い関数（CC > 10）
- 重複コード
- マジックナンバー
- 命名規則違反
- コードの臭い

問題発見時の出力形式:
[優先度] 問題の説明: ファイル名:行番号
        """
    )

    # 4. アーキテクチャサブエージェント
    architecture_task = Task(
        subagent_type="researcher",
        description="アーキテクチャ分析",
        prompt=f"""
アーキテクチャ観点で分析してください。**必ず日本語で回答してください。**

対象ファイル: {targets['files']}

重点項目:
- 層の混在
- 循環依存
- 責任分離の問題
- 依存関係の方向性
- スケーラビリティの懸念

問題発見時の出力形式:
[優先度] 問題の説明: ファイル名:行番号
        """
    )

    # すべてのタスクを並列実行
    results = {
        "security": security_task,
        "performance": performance_task,
        "quality": quality_task,
        "architecture": architecture_task
    }

    return results
```

### Step 3: 発見事項の集約

```python
def aggregate_findings(agent_results):
    """サブエージェント結果の集約"""

    findings = {
        "security": [],
        "performance": [],
        "quality": [],
        "architecture": []
    }

    severity_map = {
        "高": "high",
        "中": "medium",
        "低": "low"
    }

    # 各エージェントの結果をパース
    for category, result in agent_results.items():
        issues = parse_agent_output(result)

        for issue in issues:
            findings[category].append({
                "severity": severity_map.get(issue["priority"], "medium"),
                "description": issue["description"],
                "location": issue["location"],
                "suggestion": issue.get("suggestion", "")
            })

    return findings

def parse_agent_output(output):
    """エージェント出力のパース"""

    issues = []
    pattern = r'\[([高中低])\]\s*(.+?):\s*(.+)'

    for match in re.finditer(pattern, output, re.MULTILINE):
        issues.append({
            "priority": match.group(1),
            "description": match.group(2),
            "location": match.group(3)
        })

    return issues
```

### Step 4: 優先度付けとフィルタリング

```python
def prioritize_findings(findings):
    """発見事項の優先度付け"""

    prioritized = {
        "high": [],
        "medium": [],
        "low": []
    }

    # セキュリティ問題は優先度を引き上げ
    for issue in findings["security"]:
        if issue["severity"] == "medium":
            issue["severity"] = "high"
        prioritized[issue["severity"]].append({
            **issue,
            "category": "🔴 セキュリティ"
        })

    # その他の問題
    for category in ["performance", "quality", "architecture"]:
        for issue in findings[category]:
            prioritized[issue["severity"]].append({
                **issue,
                "category": category_icon_map[category]
            })

    # 各優先度内でソート（カテゴリ別）
    for severity in ["high", "medium", "low"]:
        prioritized[severity].sort(key=lambda x: (x["category"], x["location"]))

    return prioritized

category_icon_map = {
    "security": "🔴 セキュリティ",
    "performance": "🟡 パフォーマンス",
    "quality": "🟢 コード品質",
    "architecture": "🔵 アーキテクチャ"
}
```

### Step 5: 即座の修正提案

```python
def generate_quick_fixes(findings):
    """即座の修正提案生成"""

    quick_fixes = []

    # パターンマッチングによる自動修正提案
    fix_patterns = {
        "N+1クエリ": {
            "pattern": r"N\+1",
            "fix": "eager loading（includes/joins）の使用",
            "auto_fixable": False
        },
        "マジックナンバー": {
            "pattern": r"マジックナンバー",
            "fix": "定数として定義",
            "auto_fixable": True
        },
        "重複コード": {
            "pattern": r"重複",
            "fix": "共通関数への抽出",
            "auto_fixable": False
        },
        "複雑度が高い": {
            "pattern": r"複雑度|CC",
            "fix": "関数分割とリファクタリング",
            "auto_fixable": False
        }
    }

    all_issues = []
    for severity_list in findings.values():
        all_issues.extend(severity_list)

    for issue in all_issues:
        for pattern_name, pattern_info in fix_patterns.items():
            if re.search(pattern_info["pattern"], issue["description"]):
                quick_fixes.append({
                    "issue": issue["description"],
                    "location": issue["location"],
                    "fix": pattern_info["fix"],
                    "auto_fixable": pattern_info["auto_fixable"]
                })

    return quick_fixes
```

### Step 6: 結果出力

```python
def format_simple_results(findings, quick_fixes):
    """シンプルモード結果のフォーマット"""

    output = []
    output.append("# コードレビュー結果（シンプルモード）\n")

    # サマリー
    total_issues = sum(len(issues) for issues in findings.values())
    output.append(f"発見された問題: **{total_issues}件**\n")

    # 優先度別の問題一覧
    for severity in ["high", "medium", "low"]:
        severity_name = {"high": "🔴 高優先度", "medium": "🟡 中優先度", "low": "🟢 低優先度"}[severity]
        issues = findings[severity]

        if not issues:
            continue

        output.append(f"## {severity_name} ({len(issues)}件)\n")

        for issue in issues:
            output.append(f"### {issue['category']}\n")
            output.append(f"- **{issue['description']}**")
            output.append(f"  - 場所: `{issue['location']}`")
            if issue.get('suggestion'):
                output.append(f"  - 提案: {issue['suggestion']}")
            output.append("")

    # 即座の修正提案
    if quick_fixes:
        output.append("## 🔧 即座の修正提案\n")

        auto_fixable = [f for f in quick_fixes if f["auto_fixable"]]
        manual_fixes = [f for f in quick_fixes if not f["auto_fixable"]]

        if auto_fixable:
            output.append("### 自動修正可能\n")
            for fix in auto_fixable:
                output.append(f"- {fix['location']}: {fix['fix']}")

        if manual_fixes:
            output.append("\n### 手動修正推奨\n")
            for fix in manual_fixes:
                output.append(f"- {fix['location']}: {fix['fix']}")

    # 推奨アクション
    output.append("\n## 推奨アクション\n")
    if findings["high"]:
        output.append("1. 🔴 高優先度の問題を優先的に対処")
    if any("セキュリティ" in i["category"] for i in findings.get("high", [])):
        output.append("2. ⚠️ セキュリティ問題は即座に修正")
    if findings["medium"]:
        output.append("3. 🟡 中優先度の問題を次回のリファクタリング時に対処")

    return "\n".join(output)
```

## GitHub Issue連携

```python
def create_github_issues_from_findings(findings):
    """発見事項からGitHub issueを作成"""

    # ユーザーに確認
    print("\nGitHub issueを作成しますか?")
    print("  [y] はい - 高優先度の問題をissue化")
    print("  [a] すべて - すべての問題をissue化")
    print("  [n] いいえ - TODOリストのみ")

    choice = input("選択: ").lower()

    if choice == "n":
        return create_todo_list(findings)

    issues_to_create = []

    if choice == "y":
        issues_to_create = findings.get("high", [])
    elif choice == "a":
        for severity_list in findings.values():
            issues_to_create.extend(severity_list)

    # GitHub issue作成
    for issue in issues_to_create:
        title = f"{issue['category']}: {issue['description'][:60]}"
        body = f"""
## 問題の説明

{issue['description']}

## 場所

`{issue['location']}`

## 優先度

{issue['severity'].upper()}

## 提案される修正

{issue.get('suggestion', '要検討')}

---
レビュー日時: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
        """.strip()

        labels = [
            issue['category'].split()[1].lower(),  # カテゴリラベル
            f"priority-{issue['severity']}"         # 優先度ラベル
        ]

        # gh コマンドでissue作成
        subprocess.run([
            "gh", "issue", "create",
            "--title", title,
            "--body", body,
            "--label", ",".join(labels)
        ])

    print(f"\n✅ {len(issues_to_create)}件のGitHub issueを作成しました")
```

## 自動修正機能

`--fix`フラグ使用時の自動修正：

```python
def apply_auto_fixes(quick_fixes):
    """自動修正の適用"""

    auto_fixable = [f for f in quick_fixes if f["auto_fixable"]]

    if not auto_fixable:
        print("自動修正可能な問題はありません")
        return

    print(f"\n🔧 {len(auto_fixable)}件の問題を自動修正します...")

    for fix in auto_fixable:
        # ファイル読み込み
        file_path, line_num = parse_location(fix["location"])

        # 修正適用（パターンに応じて）
        if "マジックナンバー" in fix["issue"]:
            apply_magic_number_fix(file_path, line_num)

    # 再検証
    print("\n再検証中...")
    re_verify_result = run_quick_verification()

    if re_verify_result["passed"]:
        print("✅ 自動修正完了、問題解消を確認")
    else:
        print(f"⚠️ 自動修正後も{re_verify_result['remaining']}件の問題が残っています")
```

### Step 7: PR コメント自動チェック

結果出力後、`--no-comments` が指定されていなければ
PR コメントチェックを実行。

詳細は [PR Comment Integration](pr-comment-integration.md) を参照。

## 出力例

```markdown
# コードレビュー結果（シンプルモード）

発見された問題: **10件**

レビュー対象: git diff --cached
ファイル数: 5件

## 🔴 高優先度 (3件)

### 🔴 セキュリティ

- **未検証のユーザー入力**
  - 場所: `src/api/user.ts:34`
  - 提案: バリデーション追加（zod/yup使用推奨）

### 🔴 セキュリティ

- **CSRF対策なし**
  - 場所: `src/middleware/auth.ts:23`
  - 提案: CSRFトークン検証の実装

## 🟡 中優先度 (4件)

### 🟡 パフォーマンス

- **N+1クエリ検出**
  - 場所: `src/repositories/post.ts:78`
  - 提案: eager loading（includes）の使用

### 🟢 コード品質

- **複雑度が高い関数（CC=15）**
  - 場所: `src/services/order.ts:45`
  - 提案: 関数分割によるリファクタリング

## 🟢 低優先度 (3件)

### 🟢 コード品質

- **重複コード検出**
  - 場所: `src/components/Button.tsx`, `src/components/Link.tsx`
  - 提案: 共通コンポーネントへの抽出

## 🔧 即座の修正提案

### 自動修正可能

- src/utils/calc.ts:12: マジックナンバーを定数として定義
- src/config/env.ts:8: 未使用の変数を削除

### 手動修正推奨

- src/repositories/post.ts:78: eager loadingの適用
- src/services/order.ts:45: 関数分割とリファクタリング

## 推奨アクション

1. 🔴 高優先度の問題を優先的に対処
2. ⚠️ セキュリティ問題は即座に修正
3. 🟡 中優先度の問題を次回のリファクタリング時に対処

---

GitHub issueを作成しますか? [y/n/a]
```

## 使用例

```bash
# 基本的なシンプルレビュー
/review --simple

# 自動修正を含む
/review --simple --fix

# GitHub issue作成
/review --simple --create-issues

# すべての機能を組み合わせ
/review --simple --fix --create-issues
```

## パフォーマンス最適化

シンプルモードは高速実行を重視：

- サブエージェント並列実行（4エージェント同時）
- 軽量なパターンマッチング
- ⭐️評価計算のスキップ
- 最小限のファイルI/O

目標実行時間:

- 小規模（~10ファイル）: 30秒以内
- 中規模（~50ファイル）: 2分以内
- 大規模（~100ファイル）: 5分以内

---

### 目標
