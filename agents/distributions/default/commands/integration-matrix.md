# Command → Skill → Agent Integration Matrix

Command、Skill、Agentの関係性を文書化し、統合フローを明確化します。

## 📋 目次

1. [Commands → Skills マッピング](#commands--skills-マッピング)
2. [Skills → Agents マッピング](#skills--agents-マッピング)
3. [統合フローの実例](#統合フローの実例)
4. [自動検出ロジックの説明](#自動検出ロジックの説明)

---

## Commands → Skills マッピング

各Commandが必要とするSkillsと自動検出されるSkillsの関係性。

### 主要Commandsのスキルマッピング

| Command      | Required Skills                            | Optional Skills                             | Auto-Detected Skills                                          |
| ------------ | ------------------------------------------ | ------------------------------------------- | ------------------------------------------------------------- |
| `/task`      | integration-framework, agents-and-commands | docs-index                                  | typescript, react, golang, security, code-quality-improvement |
| `/review`    | code-review                                | semantic-analysis, docs-index               | typescript, react, golang, security                           |
| `/refactor`  | integration-framework                      | semantic-analysis, code-quality-improvement | typescript, react, golang                                     |
| `/implement` | integration-framework                      | typescript, react, golang                   | code-quality-improvement                                      |
| `/todos`     | integration-framework                      | -                                           | typescript, react, golang                                     |
| `/learnings` | -                                          | docs-index                                  | -                                                             |

### 詳細マッピング

#### /task コマンド

**目的**: タスクの意図を解析し、最適なエージェントを選択・実行

**Required Skills**:

- `integration-framework`: TaskContext、Communication Busパターンの理解
- `agents-and-commands`: エージェント選択ロジックの公式ガイド

**Optional Skills**:

- `docs-index`: ドキュメント参照が必要な場合

**Auto-Detected Skills** (タスク内容に基づく):

- `typescript`: TypeScript関連キーワード検出時
- `react`: React/Next.js関連キーワード検出時
- `golang`: Go言語関連キーワード検出時
- `security`: セキュリティ関連キーワード検出時
- `code-quality-improvement`: 品質改善キーワード検出時

#### /review コマンド

**目的**: コード品質評価と包括的レビュー

**Required Skills**:

- `code-review`: 評価基準、プロジェクト標準、品質指標

**Optional Skills**:

- `semantic-analysis`: コード構造の意味解析が必要な場合
- `docs-index`: ドキュメント標準確認が必要な場合

**Auto-Detected Skills**:

- `typescript`: TypeScript プロジェクト検出時
- `react`: React プロジェクト検出時
- `golang`: Go プロジェクト検出時
- `security`: セキュリティ重視レビュー時

#### /refactor コマンド

**目的**: セッション管理付きリファクタリング支援

**Required Skills**:

- `integration-framework`: セッション管理、TaskContext統合

**Optional Skills**:

- `semantic-analysis`: 影響範囲分析、依存関係追跡
- `code-quality-improvement`: 体系的品質改善

**Auto-Detected Skills**:

- `typescript`: TypeScript プロジェクト検出時
- `react`: React プロジェクト検出時
- `golang`: Go プロジェクト検出時

---

## Skills → Agents マッピング

各Skillがどのエージェントに対してコンテキストを提供するか。

### スキル別エージェントマッピング

| Skill                    | Primary Agents              | Secondary Agents            | Context Provided                                     |
| ------------------------ | --------------------------- | --------------------------- | ---------------------------------------------------- |
| integration-framework    | orchestrator                | error-fixer, researcher     | TaskContext、Communication Bus、統合パターン         |
| agents-and-commands      | orchestrator                | researcher                  | エージェント能力マトリックス、選択ロジック           |
| mcp-tools                | researcher                  | orchestrator                | MCP統合パターン、セキュリティベストプラクティス      |
| docs-index               | researcher                  | docs-manager                | ドキュメント配置原則、ナビゲーション戦略             |
| code-review              | code-reviewer               | orchestrator, error-fixer   | 評価基準、プロジェクト標準、品質指標                 |
| typescript               | error-fixer, code-reviewer  | orchestrator                | 型安全性パターン、コンパイラ設定、ベストプラクティス |
| react                    | code-reviewer, orchestrator | error-fixer                 | コンポーネント設計、パフォーマンス最適化             |
| golang                   | code-reviewer, orchestrator | error-fixer                 | イディオム、並行処理パターン、エラーハンドリング     |
| security                 | code-reviewer               | researcher, orchestrator    | OWASP Top 10、認証/認可パターン、脆弱性対策          |
| semantic-analysis        | serena                      | researcher, orchestrator    | シンボル解析、依存関係追跡、影響範囲評価             |
| code-quality-improvement | error-fixer                 | orchestrator, code-reviewer | 段階的改善フロー、ESLint修正、型安全性向上           |

### 詳細マッピング

#### integration-framework スキル

**Primary Agents**: orchestrator

- **理由**: 複雑なタスク分解、体系的実装に統合パターンが必須
- **提供コンテキスト**:
  - TaskContext標準インターフェース
  - Communication Busイベント駆動設計
  - アダプターパターン実装ガイド
  - エージェント間通信プロトコル

**Secondary Agents**: error-fixer, researcher

- **理由**: エラー修正や調査でも統合パターンを参照
- **提供コンテキスト**:
  - TaskContextからのエラー情報取得
  - Communication Busへのイベント発行

#### code-review スキル

**Primary Agents**: code-reviewer

- **理由**: レビュー専門エージェントの中核知識
- **提供コンテキスト**:
  - 5段階評価基準
  - プロジェクト特化型評価軸
  - セキュリティチェックリスト
  - パフォーマンス評価指標

**Secondary Agents**: orchestrator, error-fixer

- **理由**: 実装・修正時にも品質基準を適用
- **提供コンテキスト**:
  - コード品質ゲート
  - ベストプラクティス

#### typescript スキル

**Primary Agents**: error-fixer, code-reviewer

- **理由**: TypeScriptエラー修正とレビューに特化
- **提供コンテキスト**:
  - 型安全性向上パターン
  - any型排除戦略
  - tsconfig.json最適化
  - 型ガードとアサーション

**Secondary Agents**: orchestrator

- **理由**: TypeScript実装時の設計ガイダンス
- **提供コンテキスト**:
  - インターフェース設計
  - ジェネリクス活用パターン

---

## 統合フローの実例

### シナリオ 1: TypeScriptエラー修正

```
User: "/task Fix TypeScript errors in src/components"
  ↓
commands/task.md (タスク解析)
  ↓
commands/shared/agent-selector.md (エージェント選択)
  ↓ (analyze_task_intent)
意図分類: error (confidence: 0.9)
  ↓ (detect_relevant_skills)
Skills検出:
  - integration-framework (理由: TaskContext統合)
  - agents-and-commands (理由: エージェント選択ガイダンス)
  - typescript (理由: TypeScript関連キーワード検出)
  - code-quality-improvement (理由: エラー修正品質向上)
  ↓ (calculate_agent_scores)
エージェントスコア:
  - error-fixer: 0.95 (最適)
  - orchestrator: 0.3
  - researcher: 0.3
  ↓ (select_by_confidence)
選択: error-fixer
  ↓
エージェント起動（Skillコンテキスト付与）
  - TaskContext: エラー情報、プロジェクト構成
  - TypeScriptパターン: 型安全性向上、any型排除
  - 品質改善フロー: 段階的修正、検証手順
  ↓
エラー修正実行
  ↓
Communication Bus: 修正完了イベント発行
```

### シナリオ 2: コードレビュー

```
User: "/review src/services/auth"
  ↓
commands/review.md (レビュー解析)
  ↓
commands/shared/agent-selector.md (エージェント選択)
  ↓ (analyze_task_intent)
意図分類: review (confidence: 0.9)
  ↓ (detect_relevant_skills)
Skills検出:
  - code-review (理由: レビュー専門知識)
  - typescript (理由: プロジェクト検出)
  - security (理由: auth関連キーワード)
  ↓ (calculate_agent_scores)
エージェントスコア:
  - code-reviewer: 0.9 (最適)
  - researcher: 0.3
  ↓
選択: code-reviewer
  ↓
エージェント起動（Skillコンテキスト付与）
  - 評価基準: 5段階評価、プロジェクト標準
  - TypeScript基準: 型安全性、any型使用状況
  - セキュリティ基準: OWASP Top 10、認証パターン
  ↓
包括的レビュー実行
  ↓
レビューレポート生成（評価結果、改善提案）
```

### シナリオ 3: 新機能実装

```
User: "/task Implement user authentication with JWT"
  ↓
commands/task.md (タスク解析)
  ↓
commands/shared/agent-selector.md (エージェント選択)
  ↓ (analyze_task_intent)
意図分類: implement (confidence: 0.85)
  ↓ (detect_relevant_skills)
Skills検出:
  - integration-framework (理由: 実装パターン統合)
  - agents-and-commands (理由: エージェント選択ガイダンス)
  - typescript (理由: プロジェクト検出)
  - security (理由: JWT、authentication検出)
  ↓ (calculate_agent_scores)
エージェントスコア:
  - orchestrator: 0.9 (最適)
  - researcher: 0.6
  - error-fixer: 0.2
  ↓
選択: orchestrator
  ↓
エージェント起動（Skillコンテキスト付与）
  - TaskContext: タスク分解、進捗管理
  - TypeScript実装パターン: インターフェース設計
  - セキュリティパターン: JWT検証、トークン管理
  ↓
タスク分解:
  1. JWT認証ミドルウェア実装
  2. ユーザー認証エンドポイント作成
  3. トークン検証ロジック実装
  4. テスト作成
  ↓
段階的実装実行（各ステップで品質チェック）
  ↓
Communication Bus: 実装完了イベント発行
```

### シナリオ 4: MCPサーバーセットアップ

```
User: "MCP サーバーの設定方法を教えて"
  ↓
commands/shared/agent-selector.md (エージェント選択)
  ↓ (analyze_task_intent)
意図分類: analyze (confidence: 0.85)
  ↓ (detect_relevant_skills)
Skills検出:
  - mcp-tools (理由: MCPキーワード検出)
  - docs-index (理由: ガイド検索)
  ↓ (calculate_agent_scores)
エージェントスコア:
  - researcher: 0.9 (最適)
  - orchestrator: 0.2
  ↓
選択: researcher
  ↓
エージェント起動（Skillコンテキスト付与）
  - MCP統合パターン: サーバー設定、セキュリティ
  - ドキュメント配置: セットアップガイド場所
  ↓
調査・解説実行
  - claude_desktop_config.json設定例
  - セキュリティベストプラクティス
  - 主要MCPサーバー紹介
```

### シナリオ 5: エージェント/コマンド選択相談

```
User: "コードレビューしたいけど、エージェントとコマンドどちらを使うべき?"
  ↓
commands/shared/agent-selector.md (エージェント選択)
  ↓ (analyze_task_intent)
意図分類: review + tool_selection (confidence: 0.9, 0.9)
  ↓ (detect_relevant_skills)
Skills検出:
  - agents-and-commands (理由: ツール選択キーワード検出)
  - code-review (理由: レビュー関連)
  ↓ (calculate_agent_scores)
エージェントスコア:
  - researcher: 0.9 (最適)
  - code-reviewer: 0.4
  ↓
選択: researcher
  ↓
エージェント起動（Skillコンテキスト付与）
  - エージェント vs コマンド使い分けガイド
  - レビューシナリオ別推奨ツール
  ↓
解説実行
  - コマンド: /review（詳細モード）、/review --simple（クイックモード）
  - エージェント: code-reviewerスキル（カスタムレビュー）
  - 推奨: 初回は/reviewコマンド、カスタム基準が必要ならスキル
```

---

## 自動検出ロジックの説明

### 統合フレームワークスキルの自動検出

#### integration-framework

**検出条件**:

```python
framework_keywords = [
    # 日本語
    "統合フレームワーク", "taskcontext", "communication bus",
    "エージェント開発", "コマンド開発", "アダプター",
    # 英語
    "integration framework", "task context", "communication bus",
    "develop agent", "develop command", "adapter pattern",
    "orchestration", "event driven"
]
```

**検出タイミング**: キーワードが1つ以上含まれる場合

**信頼度**: 0.9（高）

#### agents-and-commands

**検出条件**:

```python
selection_keywords = [
    # 日本語
    "エージェント", "コマンド", "使い分け", "どちらを使う",
    "ツール選択", "どのツール",
    # 英語
    "agent", "command", "which tool", "how to use",
    "tool selection", "agent vs command", "choose between"
]
```

**検出タイミング**: キーワードが2つ以上含まれる場合

**信頼度**: 0.9（高）

#### mcp-tools

**検出条件**:

```python
mcp_keywords = [
    # 日本語
    "mcp", "mcpサーバー", "mcp設定",
    # 英語
    "mcp server", "mcp setup", "claude_desktop_config",
    "external tool integration", "mcp configuration"
]
```

**検出タイミング**: キーワードが1つ以上含まれる場合

**信頼度**: 0.9（高）

#### docs-index

**検出条件**:

```python
docs_keywords = [
    # 日本語
    "ドキュメント", "ガイド", "どこにあるか", "どこにある",
    # 英語
    "documentation", "guide", "where is", "find guide",
    "locate documentation"
]
```

**検出タイミング**: キーワードが1つ以上含まれる場合

**信頼度**: 0.85（高）

### 技術スタックスキルの自動検出

#### typescript

**検出条件**: `["typescript", "ts", "type", "型"]`

**信頼度**: 0.86

#### react

**検出条件**: `["react", "jsx", "tsx", "component", "next.js"]`

**信頼度**: 0.8

#### golang

**検出条件**: `["go", "golang", "goroutine"]`

**信頼度**: 0.85

#### security

**検出条件**: `["security", "セキュリティ", "auth", "認証", "jwt", "csrf", "xss"]`

**信頼度**: 0.9

#### semantic-analysis

**検出条件**: `["refactor", "リファクタ", "impact", "影響", "dependency", "依存"]`

**信頼度**: 0.85

#### code-quality-improvement

**検出条件**: `["lint", "format", "quality", "品質", "eslint"]`

**信頼度**: 0.8

#### markdown-docs

**検出条件**: `["markdown", "md", "readme", "documentation"]`

**信頼度**: 0.8

### 検出優先順位

1. **統合フレームワークスキル（最優先）**: integration-framework、agents-and-commands、mcp-tools、docs-index
2. **技術スタックスキル**: typescript、react、golang、security等

**理由**: 統合フレームワークスキルは横断的な知識を提供し、すべてのエージェント/コマンドで活用できるため。

---

## 関連ファイル

- `commands/shared/agent-selector.md`: エージェント選択ロジックの実装
- `commands/shared/skill-mapping-engine.md`: スキルマッピングエンジンの詳細
- `commands/shared/task-context.md`: TaskContext仕様
- `skills/integration-framework/SKILL.md`: 統合フレームワークスキル
- `skills/agents-and-commands/SKILL.md`: エージェント/コマンド選択ガイド
- `skills/mcp-tools/SKILL.md`: MCPツール統合ガイド
- `skills/docs-index/SKILL.md`: ドキュメントナビゲーションガイド
