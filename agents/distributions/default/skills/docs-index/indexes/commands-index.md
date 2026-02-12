# Commands Index

⚠️ **重要**: Commandsシステムは廃止予定です。現在、Skills移行作業が進行中です。

**移行状況**:

- Phase 1: Foundation（完了）
- Phase 2: Core Workflows（進行中）- learnings, polish, implement, todos, task, review等をSkills化
- Phase 3: 移行完了後、Commandsシステムを段階的に廃止

**推奨**: 新規機能はSkillsとして実装してください。

---

全コマンド一覧。`~/.config/agents/distributions/default/commands/`配下のすべてのコマンドを含む。

## メインコマンド

| コマンド                    | 説明                                                                                                                                                                                          |
| --------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/agent-selector`           | タスクの意図とコンテキストに基づいて最適なエージェントを選択する共通ユーティリティです。...                                                                                                   |
| `/claude-metadata-analyzer` | `/maintain-claude`コマンドで使用する共有ライブラリです。~/.claude/配下のファイルをスキャンし、メタデータを抽出・分析します。...                                                               |
| `/commit`                   | I'll analyze your changes and create a meaningful commit message....                                                                                                                          |
| `/context7-integration`     | Context7 MCPサーバーと連携して、最新のライブラリドキュメントを取得・活用する共通ユーティリティです。...                                                                                       |
| `/contributing`             | I'll analyze everything needed for your successful contribution based on your current context and wo...                                                                                       |
| `/create-pr`                | プロジェクトのフォーマッターを自動検出し、コード整形・適切なコミット分割・GitHub PR作成を一括実行する統合コマンドです。...                                                                    |
| `/create-todos`             | I'll analyze recent operations and create contextual TODO comments in your code....                                                                                                           |
| `/debug-chrome`             | `chrome-debug` スキルを参照してデバッグセッションを実行する。...                                                                                                                              |
| `/docs`                     | I'll intelligently manage your project documentation by analyzing what actually happened and updatin...                                                                                       |
| `/error-handler`            | すべてのコマンドで一貫したエラー処理を提供する共通ユーティリティです。...                                                                                                                     |
| `/files`                    | I'll help clean up development artifacts while preserving your working code....                                                                                                               |
| `/find-todos`               | I'll locate all TODO comments and unfinished work markers in your codebase....                                                                                                                |
| `/fix-docs`                 | プロジェクトの全ドキュメントを自動解析し、リンク修正、フォーマット最適化、構造改善を実行する次世代コマンドです。...                                                                           |
| `/fix-todos`                | I'll systematically find and resolve TODO comments in your codebase with intelligent understanding a...                                                                                       |
| `/full`                     | プロジェクト全体を包括的にクリーンアップし、不要なコード、コメント、ファイル、ドキュメントの重複を整理します。MCP Serenaのセマンティック解析を活用した高精度なクリーンアップを提供します。... |
| `/implement`                | I'll intelligently implement features from any source - adapting them perfectly to your project's ar...                                                                                       |
| `/integration-matrix`       | Command、Skill、Agentの関係性を文書化し、統合フローを明確化します。...                                                                                                                        |
| `/learnings`                | ## 概要...                                                                                                                                                                                    |
| `/maintain-claude`          | `~/.claude/agents/`, `~/.claude/skills/`, `~/.claude/commands/` のメンテナンスを自動化するコマンドです。...                                                                                   |
| `/make-it-pretty`           | I'll improve code readability while preserving exact functionality....                                                                                                                        |

<details>
<summary>その他のメインコマンド（展開）</summary>

| コマンド                | 説明                                                                                                                                    |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `/polish`               | コードをlint/format/testで磨き上げ、エラーが出なくなるまで自動修正を繰り返します。...                                                   |
| `/predict-issues`       | I'll analyze your codebase to predict potential problems before they impact your project....                                            |
| `/project-detector`     | プロジェクトの技術スタックと構造を自動判定する共通ユーティリティです。...                                                               |
| `/refactoring-plan`     | ## 📋 概要...                                                                                                                           |
| `/refactoring-summary`  | ## 📊 実行サマリー...                                                                                                                   |
| `/review`               | 包括的なコードレビューを実行するコマンドです。`code-review`スキルを呼び出し、プロジェクトに最適化されたレビューを提供します。...        |
| `/skill-mapping-engine` | `/maintain-claude`コマンドで使用する共有ライブラリです。Agent-Skill関連性を分析し、適切なスキルを推奨します。...                        |
| `/skill-up`             | docs/配下のドキュメントを精査し、適切なものを`~/.claude/agents/`, `~/.claude/skills/`, または`~/.claude/commands/`に変換するコマンド... |
| `/skill_integration`    | ## 概要...                                                                                                                              |
| `/spec-design`          | ## Parse Arguments...                                                                                                                   |
| `/spec-impl`            | ## Parse Arguments...                                                                                                                   |
| `/spec-init`            | <background_information>...                                                                                                             |
| `/spec-quick`           | <background_information>...                                                                                                             |
| `/spec-requirements`    | ## Parse Arguments...                                                                                                                   |
| `/spec-status`          | <background_information>...                                                                                                             |
| `/spec-tasks`           | ## Parse Arguments...                                                                                                                   |
| `/steering`             | ## Mode Detection...                                                                                                                    |
| `/steering-custom`      | ## Interactive Workflow...                                                                                                              |
| `/task`                 | 自然言語でタスクを指定すると、最適なエージェントを自動選択して実行する次世代統合コマンドです。...                                       |
| `/task-context`         | エージェントとコマンド間で共有される統一されたタスクコンテキスト構造です。...                                                           |
| `/todos`                | ## 概要...                                                                                                                              |
| `/validate-design`      | ## Parse Arguments...                                                                                                                   |
| `/validate-gap`         | ## Parse Arguments...                                                                                                                   |
| `/validate-impl`        | ## Parse Arguments...                                                                                                                   |

</details>

## Kiroコマンド（Spec-Driven Development）

| コマンド                  | 説明                        |
| ------------------------- | --------------------------- |
| `/kiro:spec-design`       | ## Parse Arguments...       |
| `/kiro:spec-impl`         | ## Parse Arguments...       |
| `/kiro:spec-init`         | <background_information>... |
| `/kiro:spec-quick`        | <background_information>... |
| `/kiro:spec-requirements` | ## Parse Arguments...       |
| `/kiro:spec-status`       | <background_information>... |
| `/kiro:spec-tasks`        | ## Parse Arguments...       |
| `/kiro:steering`          | ## Mode Detection...        |
| `/kiro:steering-custom`   | ## Interactive Workflow...  |
| `/kiro:validate-design`   | ## Parse Arguments...       |
| `/kiro:validate-gap`      | ## Parse Arguments...       |
| `/kiro:validate-impl`     | ## Parse Arguments...       |

---

**更新日**: 2025-02-12
**コマンド数**: 56件（Main: 44件、Kiro: 12件）
