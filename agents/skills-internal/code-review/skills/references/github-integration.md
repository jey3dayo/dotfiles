# GitHub Integration ガイド

レビューで発見した問題をGitHub issueとして作成・管理するための統合ガイドです。

## 概要

コードレビューの発見事項を構造化されたGitHub issueに変換し、チーム全体で追跡可能にします。優先度に基づく自動ラベリング、テンプレート化された説明、署名なしポリシーの徹底により、プロフェッショナルなissue管理を実現します。

## 重要原則

### 署名なしポリシー

**CRITICAL**: すべてのGitHub issueは以下のポリシーを厳守：

- ❌ **NEVER** "Created by Claude" などのAI署名を含めない
- ❌ **NEVER** "Generated with Claude Code" などの生成ツール表記を含めない
- ❌ **NEVER** 絵文字をタイトルや本文に使用しない
- ❌ **NEVER** "Co-authored-by: Claude" を含めない
- ✅ **ALWAYS** 技術的な内容のみを記載
- ✅ **ALWAYS** 人間が書いたように見える形式

## Issue作成フロー

### Step 1: ユーザー確認

```python
def prompt_issue_creation(findings):
    """Issue作成の確認プロンプト"""

    high_priority_count = len(findings.get("high", []))
    total_count = sum(len(v) for v in findings.values())

    print(f"\n発見された問題: {total_count}件")
    print(f"  うち高優先度: {high_priority_count}件")
    print("\nGitHub issueを作成しますか?")
    print("  [y] はい - 高優先度の問題のみ")
    print("  [a] すべて - すべての問題")
    print("  [t] TODOのみ - ローカルTODOリスト作成")
    print("  [n] いいえ - サマリーのみ表示")

    choice = input("\n選択 [y/a/t/n]: ").lower()

    return {
        "y": "high_only",
        "a": "all",
        "t": "todo_only",
        "n": "none"
    }.get(choice, "none")
```

### Step 2: Issue内容生成

````python
def generate_issue_content(finding):
    """Issue内容の生成"""

    # タイトル生成（60文字以内、絵文字なし）
    title = f"{finding['category_plain']}: {finding['description'][:60]}"

    # 本文生成（署名なし、技術的内容のみ）
    body = f"""## Problem Description

{finding['description']}

## Location

File: `{finding['file']}`
Line: {finding['line']}

{generate_code_context(finding['file'], finding['line'])}

## Priority

{finding['severity'].upper()}

## Impact

{analyze_impact(finding)}

## Suggested Remediation

{finding.get('suggestion', 'Requires investigation and discussion')}

## Acceptance Criteria

{generate_acceptance_criteria(finding)}

## Additional Context

- Review Date: {datetime.now().strftime('%Y-%m-%d')}
- Review Mode: {'Detailed' if finding.get('detailed_mode') else 'Simple'}
- Project Type: {finding.get('project_type', 'Unknown')}
    """.strip()

    return {
        "title": title,
        "body": body
    }

def generate_code_context(file_path, line_num, context_lines=3):
    """コードコンテキストの生成"""

    try:
        with open(file_path) as f:
            lines = f.readlines()

        start = max(0, line_num - context_lines - 1)
        end = min(len(lines), line_num + context_lines)

        context = "```\n"
        for i in range(start, end):
            marker = " -> " if i == line_num - 1 else "    "
            context += f"{marker}{i+1:4d} | {lines[i]}"
        context += "```"

        return context
    except Exception as e:
        return f"Code context unavailable: {e}"

def analyze_impact(finding):
    """影響分析の生成"""

    impact_map = {
        "security": "Security vulnerability - potential data breach or unauthorized access",
        "performance": "Performance degradation - may affect user experience and scalability",
        "quality": "Code maintainability - increases technical debt and future modification cost",
        "architecture": "Architectural concern - may hinder future extensibility and testability"
    }

    category = finding['category_key']
    base_impact = impact_map.get(category, "Requires assessment")

    # 優先度に応じた影響度の調整
    severity_modifiers = {
        "high": "Critical - immediate attention required",
        "medium": "Moderate - should be addressed in next iteration",
        "low": "Minor - can be addressed during refactoring"
    }

    return f"{base_impact}\n\nSeverity: {severity_modifiers[finding['severity']]}"

def generate_acceptance_criteria(finding):
    """受け入れ基準の生成"""

    criteria_templates = {
        "security": [
            "- [ ] Input validation implemented",
            "- [ ] Security tests added",
            "- [ ] No vulnerabilities detected by security scanner"
        ],
        "performance": [
            "- [ ] Performance improvement verified (benchmark)",
            "- [ ] No regression in other areas",
            "- [ ] Load testing passed"
        ],
        "quality": [
            "- [ ] Code complexity reduced (CC < 10)",
            "- [ ] Code duplication eliminated",
            "- [ ] Code review passed"
        ],
        "architecture": [
            "- [ ] Layer separation maintained",
            "- [ ] Dependency rules followed",
            "- [ ] Architecture tests passed"
        ]
    }

    category = finding['category_key']
    criteria = criteria_templates.get(category, [
        "- [ ] Issue resolved",
        "- [ ] Tests added/updated",
        "- [ ] Code review passed"
    ])

    return "\n".join(criteria)
````

### Step 3: ラベル決定

```python
def determine_labels(finding):
    """Issue ラベルの決定"""

    labels = []

    # カテゴリラベル
    category_labels = {
        "security": "security",
        "performance": "performance",
        "quality": "code-quality",
        "architecture": "architecture"
    }
    labels.append(category_labels[finding['category_key']])

    # 優先度ラベル
    priority_labels = {
        "high": "priority-high",
        "medium": "priority-medium",
        "low": "priority-low"
    }
    labels.append(priority_labels[finding['severity']])

    # 技術スタックラベル（オプション）
    if finding.get('tech_stack'):
        for tech in finding['tech_stack']:
            labels.append(f"tech-{tech}")

    # 追加ラベル
    if finding.get('auto_fixable'):
        labels.append("good-first-issue")

    if finding.get('breaking_change'):
        labels.append("breaking-change")

    return labels
```

### Step 4: Issue作成実行

```python
def create_github_issue(finding):
    """GitHub issue の作成"""

    content = generate_issue_content(finding)
    labels = determine_labels(finding)

    # gh CLIを使用してissue作成
    cmd = [
        "gh", "issue", "create",
        "--title", content["title"],
        "--body", content["body"],
        "--label", ",".join(labels)
    ]

    # アサイニーの設定（オプション）
    if finding.get('assignee'):
        cmd.extend(["--assignee", finding['assignee']])

    # マイルストーンの設定（オプション）
    if finding.get('milestone'):
        cmd.extend(["--milestone", finding['milestone']])

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=True
        )

        # issue URLを抽出
        issue_url = result.stdout.strip()

        return {
            "success": True,
            "url": issue_url,
            "number": extract_issue_number(issue_url)
        }

    except subprocess.CalledProcessError as e:
        return {
            "success": False,
            "error": e.stderr
        }
```

## バッチ作成

複数のissueを効率的に作成：

```python
def batch_create_issues(findings, mode="high_only"):
    """複数issueのバッチ作成"""

    issues_to_create = []

    if mode == "high_only":
        issues_to_create = findings.get("high", [])
    elif mode == "all":
        for severity_list in findings.values():
            issues_to_create.extend(severity_list)

    if not issues_to_create:
        print("作成するissueがありません")
        return []

    print(f"\n{len(issues_to_create)}件のissueを作成します...")

    created_issues = []
    failed_issues = []

    for i, finding in enumerate(issues_to_create, 1):
        print(f"[{i}/{len(issues_to_create)}] {finding['description'][:50]}...")

        result = create_github_issue(finding)

        if result["success"]:
            created_issues.append(result)
            print(f"  ✅ Created: {result['url']}")
        else:
            failed_issues.append({
                "finding": finding,
                "error": result["error"]
            })
            print(f"  ❌ Failed: {result['error']}")

        # レート制限対策
        time.sleep(0.5)

    # サマリー表示
    print(f"\n完了: {len(created_issues)}件作成, {len(failed_issues)}件失敗")

    if failed_issues:
        print("\n失敗したissue:")
        for failed in failed_issues:
            print(f"  - {failed['finding']['description']}")
            print(f"    Error: {failed['error']}")

    return {
        "created": created_issues,
        "failed": failed_issues
    }
```

## Issue更新

既存issueの更新機能：

```python
def update_existing_issue(issue_number, updates):
    """既存issueの更新"""

    # コメント追加
    if updates.get("comment"):
        subprocess.run([
            "gh", "issue", "comment", str(issue_number),
            "--body", updates["comment"]
        ])

    # ラベル追加
    if updates.get("add_labels"):
        subprocess.run([
            "gh", "issue", "edit", str(issue_number),
            "--add-label", ",".join(updates["add_labels"])
        ])

    # ラベル削除
    if updates.get("remove_labels"):
        subprocess.run([
            "gh", "issue", "edit", str(issue_number),
            "--remove-label", ",".join(updates["remove_labels"])
        ])

    # クローズ
    if updates.get("close"):
        subprocess.run([
            "gh", "issue", "close", str(issue_number),
            "--comment", updates.get("close_comment", "Issue resolved")
        ])
```

## TODOリスト代替

GitHub issue作成を望まない場合のローカルTODO管理：

```python
def create_todo_list(findings):
    """ローカルTODOリストの作成"""

    todos = []

    # 高優先度
    for finding in findings.get("high", []):
        todos.append({
            "content": f"{finding['category_plain']}: {finding['description']}",
            "status": "pending",
            "activeForm": f"{finding['category_plain']}の問題を修正中"
        })

    # 中優先度
    for finding in findings.get("medium", []):
        todos.append({
            "content": f"{finding['category_plain']}: {finding['description']}",
            "status": "pending",
            "activeForm": f"{finding['category_plain']}の問題を修正中"
        })

    # TodoWriteツールで書き込み
    TodoWrite(todos=todos)

    print(f"\n✅ {len(todos)}件のTODOを作成しました")
```

## Issue テンプレート例

### セキュリティIssue

````markdown
## Problem Description

Unvalidated user input detected in API endpoint

## Location

File: `src/api/user.ts`
Line: 34

\```typescript
33 | export async function createUser(req: Request) {
34 | const userData = req.body; // No validation
35 | return await db.users.create(userData);
\```

## Priority

HIGH

## Impact

Security vulnerability - potential data breach or unauthorized access

Severity: Critical - immediate attention required

## Suggested Remediation

Implement input validation using zod or yup schema validation

Example:

\```typescript
const userSchema = z.object({
name: z.string().min(1).max(100),
email: z.string().email(),
age: z.number().int().positive().max(150)
});

const userData = userSchema.parse(req.body);
\```

## Acceptance Criteria

- [ ] Input validation implemented
- [ ] Security tests added
- [ ] No vulnerabilities detected by security scanner

## Additional Context

- Review Date: 2025-01-21
- Review Mode: Detailed
- Project Type: API
````

### パフォーマンスIssue

````markdown
## Problem Description

N+1 query detected in post retrieval

## Location

File: `src/repositories/post.ts`
Line: 78

\```typescript
77 | const posts = await db.posts.findAll();
78 | for (const post of posts) {
79 | post.author = await db.users.findById(post.authorId); // N+1
80 | }
\```

## Priority

MEDIUM

## Impact

Performance degradation - may affect user experience and scalability

Severity: Moderate - should be addressed in next iteration

## Suggested Remediation

Use eager loading with includes/joins

Example:

\```typescript
const posts = await db.posts.findAll({
include: [{ model: db.users, as: 'author' }]
});
\```

## Acceptance Criteria

- [ ] Performance improvement verified (benchmark)
- [ ] No regression in other areas
- [ ] Load testing passed

## Additional Context

- Review Date: 2025-01-21
- Review Mode: Simple
- Project Type: Fullstack
````

## 使用例

```python
# レビュー後のissue作成フロー
findings = {
    "high": [
        {
            "category_key": "security",
            "category_plain": "Security",
            "description": "Unvalidated user input",
            "file": "src/api/user.ts",
            "line": 34,
            "severity": "high",
            "suggestion": "Implement zod validation"
        }
    ],
    "medium": [...]
}

# ユーザー確認
mode = prompt_issue_creation(findings)

# バッチ作成
if mode in ["high_only", "all"]:
    result = batch_create_issues(findings, mode)
    print(f"\n作成されたissue: {len(result['created'])}件")
elif mode == "todo_only":
    create_todo_list(findings)
```

---

**重要**: すべてのGitHub issueは技術的内容のみを含み、AI署名や生成ツール表記を一切含めないこと。
