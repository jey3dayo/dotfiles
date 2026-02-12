# Task Classification - タスク意図分析

タスクの意図を多層的に分析し、エージェント選択の基礎となる分類ロジックです。

## 🔍 意図分析アルゴリズム

### analyze_task_intent(task_description)

タスク記述から複数の意図を検出し、信頼度付きで返します。

```python
def analyze_task_intent(task_description):
    """タスクの意図を多層的に分析"""

    intents = []
    description_lower = task_description.lower()

    # エラー・品質系
    if any(keyword in description_lower for keyword in [
        "エラー", "error", "型", "type", "eslint", "lint",
        "品質", "quality", "any型", "型安全"
    ]):
        intents.append({"type": "error", "confidence": 0.9})

    # 実装・構築系
    if any(keyword in description_lower for keyword in [
        "実装", "implement", "作成", "create", "追加", "add",
        "機能", "feature", "開発", "develop"
    ]):
        intents.append({"type": "implement", "confidence": 0.85})

    # 修正系
    if any(keyword in description_lower for keyword in [
        "修正", "fix", "直", "バグ", "bug", "問題", "issue"
    ]):
        intents.append({"type": "fix", "confidence": 0.8})

    # 調査・分析系
    if any(keyword in description_lower for keyword in [
        "調査", "investigate", "分析", "analyze", "原因", "cause",
        "なぜ", "why", "理解", "understand"
    ]):
        intents.append({"type": "analyze", "confidence": 0.85})

    # レビュー系
    if any(keyword in description_lower for keyword in [
        "レビュー", "review", "確認", "check", "評価", "evaluate",
        "品質", "quality"
    ]):
        intents.append({"type": "review", "confidence": 0.9})

    # Git/ブランチ関連のレビュー（origin/develop, main, HEAD等）
    if any(keyword in description_lower for keyword in [
        "origin/", "develop", "main", "master", "branch",
        "diff", "commit", "head", "staging", "pr", "pull request"
    ]):
        # レビューコンテキストのキーワードがあれば、レビュー意図として判定
        if "レビュー" in description_lower or "review" in description_lower:
            intents.append({"type": "review", "confidence": 0.95})
        # 明示的なレビューキーワードがなくても、ブランチ名のみでレビューと推測
        elif any(branch in description_lower for branch in ["origin/develop", "origin/main", "origin/master"]):
            intents.append({"type": "review", "confidence": 0.85})

    # GitHub PR URL検出（github-pr-reviewerに最高優先度を付与）
    if any(keyword in description_lower for keyword in [
        "github.com", "pull/", "/pr", "#pr", "pr #"
    ]):
        intents.append({"type": "github_pr", "confidence": 0.99})

    # リファクタリング系
    if any(keyword in description_lower for keyword in [
        "リファクタ", "refactor", "改善", "improve", "整理", "organize",
        "名前変更", "rename", "移動", "move"
    ]):
        intents.append({"type": "refactor", "confidence": 0.85})

    # ナビゲーション系
    if any(keyword in description_lower for keyword in [
        "探", "find", "検索", "search", "どこ", "where",
        "参照", "reference", "使用", "usage"
    ]):
        intents.append({"type": "navigate", "confidence": 0.8})

    # ドキュメント系
    if any(keyword in description_lower for keyword in [
        "ドキュメント", "document", "doc", "リンク", "link",
        "markdown", "md"
    ]):
        intents.append({"type": "docs", "confidence": 0.85})

    return sorted(intents, key=lambda x: x["confidence"], reverse=True)
```

## 📊 意図タイプ定義

### error (エラー・品質系)

**信頼度**: 0.9

**キーワード**:

- 日本語: エラー、型、品質、any型、型安全
- 英語: error, type, eslint, lint, quality

**最適エージェント**: error-fixer (0.95)

**使用例**:

- "TypeScriptのエラーを修正"
- "ESLint違反を解消"
- "any型を排除して型安全性を向上"

### implement (実装・構築系)

**信頼度**: 0.85

**キーワード**:

- 日本語: 実装、作成、追加、機能、開発
- 英語: implement, create, add, feature, develop

**最適エージェント**: orchestrator (0.9)

**使用例**:

- "新しいユーザー認証機能を実装"
- "ダッシュボードコンポーネントを作成"
- "APIエンドポイントを追加"

### fix (修正系)

**信頼度**: 0.8

**キーワード**:

- 日本語: 修正、直、バグ、問題
- 英語: fix, bug, issue

**最適エージェント**: orchestrator (0.7), error-fixer (0.6)

**使用例**:

- "ログイン画面のバグを修正"
- "パフォーマンス問題を解決"
- "メモリリークを直す"

### analyze (調査・分析系)

**信頼度**: 0.85

**キーワード**:

- 日本語: 調査、分析、原因、なぜ、理解
- 英語: investigate, analyze, cause, why, understand

**最適エージェント**: researcher (0.9), serena (0.85)

**使用例**:

- "パフォーマンス問題の原因を調査"
- "コードベースを分析して依存関係を把握"
- "バグの再現条件を理解"

### review (レビュー系)

**信頼度**: 0.9 (明示的) / 0.95 (Git関連)

**キーワード**:

- 日本語: レビュー、確認、評価、品質
- 英語: review, check, evaluate, quality
- Git関連: origin/, develop, main, branch, pr

**最適エージェント**: code-reviewer (0.9), github-pr-reviewer (0.98)

**使用例**:

- "コード品質をレビュー"
- "origin/developとの差分を確認"
- "PRをレビュー"

### github_pr (GitHub PR専用)

**信頼度**: 0.99 (最高優先度)

**キーワード**:

- URL: github.com, pull/, /pr
- 記法: #pr, pr #

**最適エージェント**: github-pr-reviewer (0.99)

**使用例**:

- "https://github.com/org/repo/pull/123 をレビュー"
- "PR #456 を確認"
- "/pr/789 の品質評価"

### refactor (リファクタリング系)

**信頼度**: 0.85

**キーワード**:

- 日本語: リファクタ、改善、整理、名前変更、移動
- 英語: refactor, improve, organize, rename, move

**最適エージェント**: serena (0.95), orchestrator (0.8)

**使用例**:

- "コンポーネントをリファクタリング"
- "関数名をより明確に改善"
- "ディレクトリ構造を整理"

### navigate (ナビゲーション系)

**信頼度**: 0.8

**キーワード**:

- 日本語: 探、検索、どこ、参照、使用
- 英語: find, search, where, reference, usage

**最適エージェント**: serena (0.98), researcher (0.6)

**使用例**:

- "この関数の使用箇所を探す"
- "シンボル定義がどこにあるか検索"
- "依存関係を参照"

### docs (ドキュメント系)

**信頼度**: 0.85

**キーワード**:

- 日本語: ドキュメント、リンク
- 英語: document, doc, link, markdown, md

**最適エージェント**: docs-manager (0.95)

**使用例**:

- "READMEを更新"
- "ドキュメントのリンク切れを修正"
- "Markdownフォーマットを最適化"

## 🎯 意図重複時の優先順位

複数の意図が検出された場合、信頼度降順でソートされます：

```python
# 例: "GitHub PRをレビューしてエラーを修正"
intents = [
    {"type": "github_pr", "confidence": 0.99},  # 最優先
    {"type": "review", "confidence": 0.9},
    {"type": "error", "confidence": 0.9}
]
# -> github-pr-reviewer が選択される
```

### 優先順位ルール

1. **github_pr (0.99)** - GitHub PR URL検出時は常に最優先
2. **review (0.95)** - Git関連レビュー
3. **error (0.9)** - エラー・品質系
4. **review (0.9)** - 一般レビュー
5. **analyze (0.85)** - 調査・分析
6. **implement (0.85)** - 実装・構築
7. **refactor (0.85)** - リファクタリング
8. **docs (0.85)** - ドキュメント
9. **fix (0.8)** - 修正系
10. **navigate (0.8)** - ナビゲーション

## 🔗 関連リファレンス

- [Selection Algorithm](selection-algorithm.md) - 意図からエージェント選択へのマッピング
- [Agent Capabilities](agent-capabilities.md) - 各エージェントの能力と適性
- [Context7 Integration](context7-integration.md) - ドキュメント統合による精度向上
