# 技術スタック別スキル

プロジェクトタイプに応じて自動統合される技術スタック別スキルの詳細です。

## プロジェクトタイプ判定

### 自動検出アルゴリズム

```python
def detect_project_type():
    """Detect project type from configuration files and dependencies"""

    # Check for Next.js
    if exists("next.config.js") or exists("next.config.mjs") or exists("next.config.ts"):
        return "nextjs"

    # Check for React SPA
    if exists("package.json"):
        pkg = read_json("package.json")
        deps = {**pkg.get("dependencies", {}), **pkg.get("devDependencies", {})}

        # React + Vite/CRA/etc
        if "react" in deps and not "next" in deps:
            return "react-spa"

        # Node.js API (Express, Fastify, NestJS)
        if any(fw in deps for fw in ["express", "fastify", "@nestjs/core"]):
            return "nodejs-api"

    # Check for Go
    if exists("go.mod"):
        return "go-api"

    # Default
    return "generic"
```

### 判定基準

| プロジェクトタイプ | 判定基準                                       | 統合スキル                           |
| ------------------ | ---------------------------------------------- | ------------------------------------ |
| Next.js            | `next.config.js/mjs/ts` が存在                 | typescript, react, security          |
| React SPA          | `package.json` に react、next なし             | typescript, react                    |
| Node.js API        | `package.json` に express/fastify/@nestjs/core | typescript, security                 |
| Go API             | `go.mod` が存在                                | golang, security, clean-architecture |
| Generic            | 上記のいずれにも該当しない                     | （基本スキルのみ）                   |

## プロジェクトタイプ別詳細

### Next.js プロジェクト

### 特徴

- SSR/SSG対応
- API Routes
- パフォーマンス最適化（Image、Font、Script）
- セキュリティ（CSRF、XSS）

### 統合スキル

### 評価重点

1. TypeScript: 型安全性、strict mode
2. React: Server Components、Client Components、Hooks
3. Security: API Routes認証、入力検証、CSP

### 評価基準

```python
evaluation_criteria = {
    "type_safety": {
        "weight": 0.25,
        "checks": [
            "no_any_types",
            "strict_mode_enabled",
            "proper_type_guards"
        ]
    },
    "react_patterns": {
        "weight": 0.25,
        "checks": [
            "server_client_separation",  # Next.js specific
            "hooks_usage",
            "performance_optimization"
        ]
    },
    "security": {
        "weight": 0.30,
        "checks": [
            "api_routes_auth",  # Next.js specific
            "input_validation",
            "csp_headers"  # Next.js specific
        ]
    },
    "performance": {
        "weight": 0.20,
        "checks": [
            "image_optimization",  # Next.js specific
            "font_optimization",   # Next.js specific
            "bundle_size"
        ]
    }
}
```

### レビュー例

````markdown
## Next.js プロジェクトレビュー結果

### 型安全性 ⭐️⭐️⭐️⭐️☆ (4/5)

- any 型の使用: 3 箇所検出
- strict mode: 有効

### React Patterns ⭐️⭐️⭐️☆☆ (3/5)

- 🔴 高優先度: Server/Client Component の分離が不十分
  - ファイル: `app/components/UserProfile.tsx`
  - 問題: "use client" ディレクティブがないが、useState を使用
  - 修正例:
    ```typescript
    "use client";
    import { useState } from "react";
    ```

### セキュリティ ⭐️⭐️⭐️⭐️☆ (4/5)

- API Routes: 認証実装済み
- 🟡 中優先度: CSP ヘッダーの追加を推奨
  - ファイル: `next.config.js`
  - 推奨: Content-Security-Policy ヘッダー追加

### パフォーマンス ⭐️⭐️⭐️⭐️⭐️ (5/5)

- Image 最適化: next/image 使用
- Font 最適化: next/font 使用
- Bundle サイズ: 問題なし
````

### React SPA プロジェクト

### 特徴

- クライアントサイドレンダリング
- 状態管理（Redux、Zustand、Context）
- バンドルサイズ最適化
- コンポーネント設計

### 統合スキル

### 評価重点

1. TypeScript: 型安全性、strict mode
2. React: コンポーネント設計、状態管理、パフォーマンス

### 評価基準

```python
evaluation_criteria = {
    "type_safety": {
        "weight": 0.30,
        "checks": [
            "no_any_types",
            "strict_mode_enabled",
            "proper_type_guards"
        ]
    },
    "react_patterns": {
        "weight": 0.40,
        "checks": [
            "component_design",
            "hooks_usage",
            "state_management",
            "performance_optimization"
        ]
    },
    "performance": {
        "weight": 0.20,
        "checks": [
            "bundle_size",
            "code_splitting",
            "lazy_loading"
        ]
    },
    "maintainability": {
        "weight": 0.10,
        "checks": [
            "component_structure",
            "prop_types"
        ]
    }
}
```

### レビュー例

````markdown
## React SPA プロジェクトレビュー結果

### 型安全性 ⭐️⭐️⭐️⭐️⭐️ (5/5)

- any 型の使用: なし
- strict mode: 有効

### React Patterns ⭐️⭐️⭐️☆☆ (3/5)

- 🔴 高優先度: prop drilling が深い
  - ファイル: `src/components/UserDashboard.tsx`
  - 問題: 5 階層の prop drilling
  - 修正提案: Context API または状態管理ライブラリの導入
- 🟡 中優先度: useEffect の依存配列が不正確
  - ファイル: `src/hooks/useUserData.ts:12`
  - 修正例:
    ```typescript
    // Before
    useEffect(() => {
      fetchUserData(userId);
    }, []); // Missing userId
    // After
    useEffect(() => {
      fetchUserData(userId);
    }, [userId]);
    ```

### パフォーマンス ⭐️⭐️⭐️⭐️☆ (4/5)

- Bundle サイズ: 250KB（良好）
- Code splitting: 実装済み
- 🟡 中優先度: React.memo の使用を推奨
  - ファイル: `src/components/ExpensiveComponent.tsx`
````

### Node.js API プロジェクト

### 特徴

- RESTful API 設計
- 認証・認可
- エラーハンドリング
- セキュリティ（SQL Injection、XSS、CSRF）

### 統合スキル

### 評価重点

1. TypeScript: 型安全性、strict mode
2. Security: 入力検証、認証・認可、データ保護

### 評価基準

```python
evaluation_criteria = {
    "type_safety": {
        "weight": 0.25,
        "checks": [
            "no_any_types",
            "strict_mode_enabled",
            "proper_type_guards"
        ]
    },
    "security": {
        "weight": 0.40,
        "checks": [
            "input_validation",
            "sql_injection_prevention",
            "auth_authorization",
            "data_protection"
        ]
    },
    "api_design": {
        "weight": 0.20,
        "checks": [
            "restful_conventions",
            "error_handling",
            "http_status_codes"
        ]
    },
    "performance": {
        "weight": 0.15,
        "checks": [
            "api_response_time",
            "database_queries",
            "caching"
        ]
    }
}
```

### レビュー例

````markdown
## Node.js API プロジェクトレビュー結果

### 型安全性 ⭐️⭐️⭐️⭐️☆ (4/5)

- any 型の使用: 2 箇所検出
- strict mode: 有効

### セキュリティ ⭐️⭐️☆☆☆ (2/5)

- 🔴 Critical: SQL Injection のリスク
  - ファイル: `src/api/users.ts:45`
  - 問題: ユーザー入力を直接クエリに使用
  - 修正例:
    ```typescript
    // Before
    const user = await db.query(
      `SELECT * FROM users WHERE id = ${req.params.id}`,
    );
    // After
    const user = await db.query("SELECT * FROM users WHERE id = $1", [
      req.params.id,
    ]);
    ```
- 🔴 Critical: 認証が不十分
  - ファイル: `src/api/posts.ts:78`
  - 問題: JWT 検証なし
  - 修正提案: 認証ミドルウェアの追加

### API 設計 ⭐️⭐️⭐️⭐️☆ (4/5)

- RESTful 設計: 良好
- エラーハンドリング: 実装済み
- 🟡 中優先度: HTTP ステータスコードの統一
````

### Go API プロジェクト

### 特徴

- イディオマティック Go
- 並行処理（goroutine、channel）
- エラーハンドリング（error wrapping）
- Clean Architecture

### 統合スキル

### 評価重点

1. Golang: エラーハンドリング、並行処理、イディオム
2. Security: 入力検証、認証・認証
3. Clean Architecture: 層分離、依存規則

### 評価基準

```python
evaluation_criteria = {
    "golang_idioms": {
        "weight": 0.30,
        "checks": [
            "error_handling",
            "concurrency_patterns",
            "idiomatic_code",
            "interface_design"
        ]
    },
    "security": {
        "weight": 0.30,
        "checks": [
            "input_validation",
            "auth_authorization",
            "data_protection"
        ]
    },
    "architecture": {
        "weight": 0.25,
        "checks": [
            "layer_separation",
            "dependency_rule",
            "domain_modeling"
        ]
    },
    "performance": {
        "weight": 0.15,
        "checks": [
            "goroutine_usage",
            "channel_patterns",
            "memory_efficiency"
        ]
    }
}
```

### レビュー例

````markdown
## Go API プロジェクトレビュー結果

### Golang Idioms ⭐️⭐️⭐️☆☆ (3/5)

- 🔴 高優先度: エラーラッピングが不十分
  - ファイル: `internal/service/user_service.go:45`
  - 問題: エラーをそのまま返している
  - 修正例:
    ```go
    // Before
    if err != nil {
        return err
    }
    // After
    if err != nil {
        return fmt.Errorf("failed to fetch user: %w", err)
    }
    ```
- 🟡 中優先度: context の伝播が不足
  - ファイル: `internal/repository/user_repo.go:78`
  - 推奨: context.Context を第一引数として追加

### セキュリティ ⭐️⭐️⭐️⭐️☆ (4/5)

- 入力検証: 実装済み
- 認証・認可: JWT 実装済み

### Clean Architecture ⭐️⭐️⭐️⭐️⭐️ (5/5)

- 層分離: 適切
- 依存規則: 遵守
- ドメインモデリング: 良好

### パフォーマンス ⭐️⭐️⭐️⭐️☆ (4/5)

- goroutine 使用: 適切
- 🟡 中優先度: channel バッファサイズの最適化
````

## スキル統合の実装

### スキルロード

```python
def load_skills_for_project(project_type):
    """Load tech-specific skills based on project type"""

    skills_map = {
        "nextjs": ["typescript", "react", "security"],
        "react-spa": ["typescript", "react"],
        "nodejs-api": ["typescript", "security"],
        "go-api": ["golang", "security", "clean-architecture"]
    }

    skills = skills_map.get(project_type, [])

    # Load skill modules
    loaded_skills = {}
    for skill_name in skills:
        skill_module = load_skill_module(skill_name)
        loaded_skills[skill_name] = skill_module

    return loaded_skills
```

### 評価基準統合

```python
def integrate_evaluation_criteria(base_criteria, loaded_skills):
    """Integrate tech-specific evaluation criteria"""

    integrated_criteria = {**base_criteria}

    for skill_name, skill_module in loaded_skills.items():
        skill_criteria = skill_module.get_evaluation_criteria()

        # Merge criteria
        for category, details in skill_criteria.items():
            if category in integrated_criteria:
                # Update existing category
                integrated_criteria[category]["checks"].extend(details["checks"])
            else:
                # Add new category
                integrated_criteria[category] = details

    # Normalize weights
    total_weight = sum(c["weight"] for c in integrated_criteria.values())
    for category in integrated_criteria:
        integrated_criteria[category]["weight"] /= total_weight

    return integrated_criteria
```

### レビュー実行

```python
def execute_review_with_skills(targets, project_type, loaded_skills):
    """Execute review with tech-specific skills"""

    # Integrate evaluation criteria
    base_criteria = get_base_evaluation_criteria()
    criteria = integrate_evaluation_criteria(base_criteria, loaded_skills)

    # Execute review
    results = {}
    for category, details in criteria.items():
        category_results = []

        for check in details["checks"]:
            # Find skill that provides this check
            skill = find_skill_for_check(check, loaded_skills)

            if skill:
                # Execute skill-specific check
                result = skill.execute_check(check, targets)
            else:
                # Execute default check
                result = execute_default_check(check, targets)

            category_results.append(result)

        results[category] = {
            "rating": calculate_rating(category_results),
            "details": category_results
        }

    return results
```

## トラブルシューティング

### プロジェクトタイプが誤検出される

```python
# デバッグログで判定結果を確認
print(f"Detected project type: {project_type}")
print(f"Loaded skills: {list(loaded_skills.keys())}")

# 手動でプロジェクトタイプを指定（将来機能）
/review --project-type nextjs
```

### スキルが見つからない

```bash
# スキルが存在するか確認
ls ~/.claude/skills/
ls ~/src/github.com/jey3dayo/claude-code-marketplace/plugins/dev-tools/

# Marketplace プラグインが追加されているか確認
cat .claude/config.json
```

### 評価基準が適用されない

```python
# デバッグログで評価基準を確認
print(f"Integrated criteria: {json.dumps(criteria, indent=2)}")

# 特定のスキルの評価基準を確認
for skill_name, skill_module in loaded_skills.items():
    print(f"{skill_name} criteria: {skill_module.get_evaluation_criteria()}")
```

## まとめ

技術スタック別スキル統合により：

1. プロジェクト適応: 技術スタックに最適化された評価基準
2. 自動化: 手動設定不要、プロジェクト検出で自動統合
3. 拡張性: 新しい技術スタック対応が容易
4. 一貫性: 統一されたレビュー品質
5. 効率性: Progressive Disclosure で必要な情報のみロード
