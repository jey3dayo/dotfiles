# プロジェクトカスタマイズ

code-review-systemのプロジェクト固有カスタマイズ方法です。

## ハイブリッド動作

code-review-systemは以下の優先順位で動作します：

### 優先順位

1. **プロジェクト固有コマンド** - `./.claude/commands/review.md` が存在する場合
2. **プロジェクト固有ガイドライン** - ガイドラインファイルが存在する場合
3. **汎用レビュー** - 上記がない場合、code-reviewスキルのデフォルト動作

### 動作フロー

```python
def execute_review(args):
    """Execute review with hybrid approach"""

    # 1. Check project-specific command
    if exists("./.claude/commands/review.md"):
        print("Using project-specific review command")
        return execute_project_command("./.claude/commands/review.md", args)

    # 2. Check project-specific guidelines
    guidelines = load_project_guidelines()
    if guidelines:
        print(f"Applying project guidelines: {guidelines['path']}")
        return execute_with_guidelines(guidelines, args)

    # 3. Use default code-review skill
    print("Using default code-review skill")
    return execute_default_review(args)
```

## ガイドラインファイル

### 配置場所

プロジェクト固有の評価ガイドラインを定義するには、以下のいずれかにファイルを配置：

- `./.claude/review-guidelines.md`
- `./docs/review-guidelines.md`
- `./docs/guides/review-guidelines.md`

### 検出ロジック

```python
def load_project_guidelines():
    """Load project-specific guidelines"""
    guideline_paths = [
        "./.claude/review-guidelines.md",
        "./docs/review-guidelines.md",
        "./docs/guides/review-guidelines.md"
    ]

    for path in guideline_paths:
        if exists(path):
            return {
                "path": path,
                "content": read_file(path)
            }

    return None
```

### ガイドラインファイル構造

```markdown
# プロジェクト固有レビューガイドライン

## プロジェクト情報

- プロジェクト名: My Awesome Project
- 技術スタック: Next.js, TypeScript, Prisma
- 重視する観点: セキュリティ、パフォーマンス

## 評価基準

### 型安全性（重要度: 高）

- any型の使用禁止（例外: 外部ライブラリの型定義不足）
- strict mode必須
- 明示的な型注釈を推奨

### セキュリティ（重要度: 最高）

- 入力検証は必ずサーバーサイドで実施
- JWT有効期限は15分以内
- APIキーは環境変数で管理

### パフォーマンス（重要度: 中）

- API応答時間200ms以内を目標
- 画像はNext.js Image最適化を使用
- バンドルサイズを監視

## プロジェクト固有ルール

### コンポーネント設計

- Page components: `app/` ディレクトリ
- Shared components: `components/` ディレクトリ
- Business logic: `lib/` ディレクトリ

### エラーハンドリング

- カスタムエラークラスを使用
- ユーザー向けメッセージと内部ログを分離
- エラーはSentryに送信

### テスト

- ユニットテスト: Jest + React Testing Library
- E2Eテスト: Playwright
- カバレッジ: 最低80%

## 除外ルール

### レビュー対象外

- `generated/` ディレクトリ
- `*.config.js` ファイル
- `prisma/migrations/` ディレクトリ

### 既知の問題（無視）

- `lib/legacy.ts` の any型使用（リファクタリング予定）
- `components/old/` の古いコンポーネント（非推奨）
```

## 自動統合ロジック

### ガイドライン統合

```python
def integrate_guidelines(default_criteria, guidelines):
    """Integrate project guidelines into default criteria"""

    # Parse guidelines
    custom_criteria = parse_guidelines(guidelines["content"])

    # Merge with defaults (project guidelines take precedence)
    merged_criteria = {
        **default_criteria,
        **custom_criteria
    }

    # Adjust weights based on project priorities
    if "priorities" in custom_criteria:
        merged_criteria = adjust_weights(merged_criteria, custom_criteria["priorities"])

    return merged_criteria
```

### 除外ルール統合

```python
def apply_exclusions(targets, guidelines):
    """Apply exclusion rules from guidelines"""

    exclusions = extract_exclusions(guidelines["content"])

    # Filter out excluded paths
    filtered_targets = [
        target for target in targets
        if not matches_exclusion(target, exclusions)
    ]

    return filtered_targets
```

## カスタマイズ例

### 例1: セキュリティ重視プロジェクト

**ガイドライン**: `./.claude/review-guidelines.md`

```markdown
# セキュリティ重視プロジェクト

## 評価基準

### セキュリティ（重要度: 最高、ウェイト: 50%）

- OWASP Top 10準拠必須
- SQL Injection対策必須
- XSS対策必須
- CSRF対策必須
- 認証・認可の厳格なチェック

### 型安全性（重要度: 高、ウェイト: 30%）

- any型使用禁止（例外なし）
- strict mode必須

### パフォーマンス（重要度: 中、ウェイト: 20%）

- API応答時間500ms以内
```

**統合後の評価基準**:

```python
evaluation_criteria = {
    "security": {
        "weight": 0.50,  # Project guideline overrides default
        "checks": [
            "owasp_top_10",
            "sql_injection",
            "xss_protection",
            "csrf_protection",
            "auth_authorization"
        ]
    },
    "type_safety": {
        "weight": 0.30,
        "checks": [
            "no_any_types_strict",  # Stricter than default
            "strict_mode_enabled"
        ]
    },
    "performance": {
        "weight": 0.20,
        "checks": [
            "api_response_time_500ms"  # Project-specific threshold
        ]
    }
}
```

### 例2: パフォーマンス重視プロジェクト

**ガイドライン**: `./.claude/review-guidelines.md`

```markdown
# パフォーマンス重視プロジェクト

## 評価基準

### パフォーマンス（重要度: 最高、ウェイト: 40%）

- API応答時間100ms以内
- バンドルサイズ200KB以内
- Lighthouse Performance Score 90以上
- Core Web Vitals: すべて Good

### 型安全性（重要度: 高、ウェイト: 30%）

- TypeScript strict mode必須
- any型の使用は許可（パフォーマンス優先）

### セキュリティ（重要度: 中、ウェイト: 30%）

- 基本的なセキュリティ対策
```

**統合後の評価基準**:

```python
evaluation_criteria = {
    "performance": {
        "weight": 0.40,  # High priority
        "checks": [
            "api_response_time_100ms",  # Stricter threshold
            "bundle_size_200kb",
            "lighthouse_score_90",
            "core_web_vitals"
        ]
    },
    "type_safety": {
        "weight": 0.30,
        "checks": [
            "strict_mode_enabled",
            "any_types_allowed"  # Exception for performance
        ]
    },
    "security": {
        "weight": 0.30,
        "checks": [
            "basic_security"  # Less strict
        ]
    }
}
```

### 例3: 既存コードベースの段階的改善

**ガイドライン**: `./.claude/review-guidelines.md`

```markdown
# 段階的改善プロジェクト

## 評価基準

### 型安全性（重要度: 高、ウェイト: 40%）

- any型の削減を優先
- 新規コードのみstrict mode適用

### 保守性（重要度: 高、ウェイト: 40%）

- コードの可読性
- ドキュメント充実

### パフォーマンス（重要度: 中、ウェイト: 20%）

- 既存の問題を悪化させない

## 除外ルール

### レビュー対象外

- `src/legacy/` ディレクトリ（段階的リファクタリング中）
- `*.old.ts` ファイル（削除予定）

### 既知の問題（無視）

- `src/utils/helpers.ts` の any型（次フェーズで修正）
```

**統合後の動作**:

```python
# Legacy code is excluded
targets = [
    "src/api/users.ts",
    "src/api/posts.ts",
    # "src/legacy/old-api.ts" - Excluded
    # "src/utils/helpers.old.ts" - Excluded
]

# Less strict criteria for gradual improvement
evaluation_criteria = {
    "type_safety": {
        "weight": 0.40,
        "checks": [
            "reduce_any_types",  # Gradual reduction
            "strict_mode_new_code"  # Only for new code
        ]
    },
    "maintainability": {
        "weight": 0.40,
        "checks": [
            "code_readability",
            "documentation"
        ]
    },
    "performance": {
        "weight": 0.20,
        "checks": [
            "no_regression"  # Don't make it worse
        ]
    }
}

# Known issues are ignored
ignored_issues = [
    "src/utils/helpers.ts:any_types"
]
```

## プロジェクトコマンドのカスタマイズ

### プロジェクト固有コマンド

`./.claude/commands/review.md` を作成することで、完全にカスタマイズされたレビューコマンドを定義できます。

**例**: `./.claude/commands/review.md`

````markdown
---
description: My Project specific code review
argument-hint: [--quick|--full]
---

# Project Review Command

## Custom Review Flow

1. Run project-specific linter
2. Run project-specific tests
3. Invoke code-review skill with custom criteria
4. Generate project-specific report

## Implementation

```bash
# Run custom linter
npm run lint:project

# Run custom tests
npm run test:project

# Invoke code-review with custom criteria
code-review --criteria ./docs/review-criteria.json

# Generate custom report
generate-report --format project-template
```
````

````

### 統合のベストプラクティス

1. **段階的な導入**: まずガイドラインファイルから始める
2. **チーム承認**: ガイドライン内容はチーム全体で合意
3. **定期的な見直し**: プロジェクトの進化に合わせて更新
4. **ドキュメント化**: ガイドラインの理由と背景を記述
5. **例外の明確化**: 除外ルールや既知の問題を明記

### トラブルシューティング

#### ガイドラインが適用されない

```bash
# ガイドラインファイルが存在するか確認
ls -la ./.claude/review-guidelines.md
ls -la ./docs/review-guidelines.md

# ファイルの内容が正しいか確認
cat ./.claude/review-guidelines.md
```

#### 除外ルールが効かない

```python
# デバッグログで除外ルールを確認
print(f"Exclusions: {exclusions}")
print(f"Filtered targets: {filtered_targets}")

# パターンマッチングの確認
for target in targets:
    for exclusion in exclusions:
        if matches_exclusion(target, exclusion):
            print(f"Excluded: {target} (matches {exclusion})")
```

#### プロジェクトコマンドが認識されない

```bash
# コマンドファイルが存在するか確認
ls -la ./.claude/commands/review.md

# パーミッションを確認
chmod +r ./.claude/commands/review.md
```

## まとめ

プロジェクトカスタマイズにより：

1. **柔軟性**: プロジェクト固有の要件に対応
2. **一貫性**: チーム全体で統一された基準
3. **段階的改善**: 既存コードベースの段階的な品質向上
4. **効率性**: プロジェクトに最適化されたレビューフロー
5. **拡張性**: プロジェクトの成長に合わせてカスタマイズ可能
````
