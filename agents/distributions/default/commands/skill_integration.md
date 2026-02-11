# Skill Integration - 共通スキル統合ライブラリ

## 概要

既存code-reviewと公式code-reviewerの両方で使用可能なスキル統合の共通処理を提供します。

## 主要機能

### 1. スキル検出（detect_skills）

プロジェクト情報から必要な技術スキルを自動検出します。

**入力**:

```python
project_info = {
    "type": "fullstack",  # api, frontend, fullstack
    "stack": ["typescript", "react", "next"],
    "structure": {"domain": True, "usecase": True, "infrastructure": True},
    "needs_semantic_analysis": True
}
```

**出力**:

```python
["typescript", "react", "security", "clean-architecture", "semantic-analysis"]
```

**検出ロジック**:

| 条件                                    | 検出されるスキル     |
| --------------------------------------- | -------------------- |
| `typescript` in stack                   | `typescript`         |
| `go` or `golang` in stack               | `golang`             |
| `react` or `next.js` in stack           | `react`              |
| Clean Architecture構造                  | `clean-architecture` |
| type in ["api", "backend", "fullstack"] | `security`           |
| needs_semantic_analysis = True          | `semantic-analysis`  |

### 2. スキルガイドラインロード（load_skill_guidelines）

指定されたスキルの評価ガイドライン（SKILL.md）を読み込みます。

**入力**:

```python
skill_name = "typescript"
```

**出力**:

```python
# ~/.claude/skills/typescript/SKILL.md の内容
```

**探索パス**:

1. `~/.claude/skills/{skill_name}/SKILL.md`
2. 存在しない場合は `None` を返す

### 3. 評価ガイドライン統合（merge_evaluation_guidelines）

複数の評価ガイドラインを優先順位に基づいて統合します。

**優先順位**:

```
project_guidelines (最優先)
  ↓
skill_guidelines_list (技術スタック別)
  ↓
base_guidelines (デフォルト)
```

**入力**:

```python
base_guidelines = "# デフォルト評価ガイドライン\n..."
skill_guidelines_list = ["# TypeScriptガイドライン\n...", "# Reactガイドライン\n..."]
project_guidelines = "# プロジェクト固有ガイドライン\n..."
```

**出力**:

```markdown
# デフォルト評価ガイドライン

...

---

# TypeScriptガイドライン

...

---

# Reactガイドライン

...

---

# プロジェクト固有ガイドライン

...
```

## 使用方法（疑似コード）

### 既存code-reviewでの使用

```python
# Step 3: プロジェクト分析
project_info = analyze_project()

# Step 4: 技術スキル検出
skills = detect_skills(project_info)

# Step 5: 評価ガイドライン統合
base = load_default_guidelines()
skill_guidelines = [load_skill_guidelines(s) for s in skills]
project = load_project_guidelines()
combined = merge_evaluation_guidelines(base, skill_guidelines, project)
```

### 公式code-reviewerでの使用

公式エージェントは統合されたガイドラインをプロンプトに含めることで活用：

```python
# 統合ガイドラインを取得
combined_guidelines = get_combined_guidelines(project_info)

# プロンプトに含める
prompt = f"""
## 統合評価ガイドライン
{combined_guidelines}

## レビュー対象
...
"""
```

## Clean Architecture検出

Clean Architectureパターンの自動検出ロジック：

**検出条件**:

```python
required_layers = {"domain", "usecase", "infrastructure"}
detected_layers = set(os.listdir("."))

if required_layers.issubset(detected_layers):
    return True  # Clean Architecture検出
```

**代替パターン**:

- `domain/`, `application/`, `infrastructure/` (DDD)
- `entities/`, `use_cases/`, `interface_adapters/`, `frameworks/` (Clean Architecture完全版)

## 公式スキル一覧

このライブラリが認識する公式スキル：

```python
OFFICIAL_SKILLS = [
    "typescript",           # TypeScript型安全性
    "react",                # Reactパターン
    "golang",               # Goイディオム
    "security",             # セキュリティ
    "clean-architecture",   # Clean Architecture
    "semantic-analysis"     # セマンティック解析
]
```

## 実装の注意点

### ファイルパス展開

```python
from pathlib import Path

skill_dir = Path("~/.claude/skills").expanduser()
skill_path = skill_dir / skill_name / "SKILL.md"
```

### エラーハンドリング

```python
try:
    with open(skill_path) as f:
        return f.read()
except FileNotFoundError:
    return None  # スキルが存在しない場合
```

### None値のフィルタリング

```python
parts = [base_guidelines] + skill_guidelines_list

if project_guidelines:
    parts.append(project_guidelines)

# Noneをフィルタリングして結合
return "\n\n---\n\n".join(filter(None, parts))
```

## 将来の拡張

### カスタムスキルパス

```python
# 環境変数でカスタムスキルディレクトリを指定可能
custom_skill_dir = os.getenv("CLAUDE_CUSTOM_SKILLS_DIR")
if custom_skill_dir:
    additional_paths.append(Path(custom_skill_dir))
```

### スキルメタデータ

```python
# SKILL.mdからメタデータを抽出
metadata = {
    "priority": "high",  # high, medium, low
    "focus": ["type_safety", "strict_mode"],
    "conflicts_with": []  # 競合するスキル
}
```

### スキルバージョニング

```python
# スキルのバージョン管理
skill_version = "1.2.0"
compatibility = check_skill_compatibility(skill_name, skill_version)
```

## 関連ドキュメント

- `skills/code-review/references/system-architecture.md`（未インストールの場合あり） - レビューシステム全体
- `skills/code-review/references/detailed-mode.md`（未インストールの場合あり） - 詳細モード実装

---

**目標**: スキル統合ロジックを共通化し、既存と公式の両方で一貫した評価基準統合を実現すること。
