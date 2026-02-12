# Skills Index

全スキル一覧。Local skills（~/.claude/skills）とMarketplace skills（~/src/github.com/jey3dayo/claude-code-marketplace）を含む。

## Local Skills (~/.claude/skills)

### Foundation Skills（Phase 1）

| スキル名                | 説明                                                                                                                                                                                                                       |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `agents-only`           | Agent selection framework with capability matrix and task classification. Use when routing tasks, selecting optimal agents, or understanding agent capabilities. Focuses exclusively on agent orchestration via Task tool. |
| `docs-index`            | Documentation index and navigation hub. Quick reference for skills, commands, agents, and guides.                                                                                                                          |
| `integration-framework` | Claude Code統合アーキテクチャガイド。TaskContext標準化、Communication Busパターン、エージェント/コマンドアダプター、エラーハンドリング、ワークフローオーケストレーションを提供します。                                     |

### Core Workflow Skills（Phase 2）

| スキル名                  | 説明                                                                                                                                                                                                                                                      |
| ------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `learnings-knowledge`     | AI-driven knowledge recording with categorization and auto-suggestion. Use when capturing insights, documenting fixes, or recording architectural decisions. 7-category system (fix, arch, perf, sec, test, db, ui) with 3-stage recording process.       |
| `code-quality-automation` | Automated lint/format/test execution with iterative fixing. Use when ensuring code quality, fixing lint errors, or running full quality checks. Supports 6 languages with mise.toml/package.json auto-detection.                                          |
| `implementation-engine`   | Smart feature implementation with session persistence. Use when implementing features, resuming work, or verifying implementations. 6-phase workflow with Deep Validation support.                                                                        |
| `todo-orchestrator`       | Unified task management system. Shows TODO list, allows selection, executes tasks. Use when managing tasks, checking progress, or executing planned work. P1-P5 priority system with TodoWrite integration.                                               |
| `task-router`             | Intelligent task router. Analyzes natural language requests, selects optimal agents, and orchestrates execution. Use when user provides task descriptions like "review this code" or "improve performance". 4-phase processing with Context7 integration. |
| `code-review-system`      | Comprehensive code review with multiple modes - detailed (⭐️5-star evaluation), simple (parallel agents), PR review, CI diagnostics. Use when reviewing code quality, fixing PR comments, or diagnosing CI failures.                                     |

### Secondary Skills（Phase 3）

| スキル名                   | 説明                                                                                                                                                                                                                          |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `git-automation`           | Smart Git workflow automation - intelligent commits with quality gates and automatic PR creation with existing PR detection. Use when committing code or creating pull requests. Format→Commit→Push→PR integrated flow.       |
| `predictive-analysis`      | Predictive code analysis for identifying potential risks, anti-patterns, and future maintenance issues. Use when assessing code health or planning refactoring. 4-quadrant risk matrix with scoring formula.                  |
| `documentation-management` | Intelligent project documentation manager with AI-driven content generation and link validation. Use when creating/updating documentation or fixing documentation issues. Progressive Disclosure strategy with smart updates. |
| `project-maintenance`      | Project cleanup and maintenance automation with Serena semantic analysis and safety checks. Use when cleaning up unused code or maintaining project health. Full/targeted cleanup with 3-layer safety checks.                 |

## Marketplace Skills

### Dev-Tools

| スキル名                          | 説明                                                                                                                                                                                                                                    |
| --------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `agent-creator`                   | [What] サブエージェント定義の作成ガイド。構造、設計パターン、ツールアクセス管理、統合ポイントを提供します。 [When] Use when: 新規エージェントの作成、既存エージェントの改善、ツールアクセス設計や統合方法の検討を行う時...              |
| `browser-testing`                 | [What] Automate browser-based testing using Chrome MCP for login flows, UI interactions, and localhost verification [Whe...                                                                                                             |
| `cc-sdd`                          | [What] Claude Code Spec-Driven Development (cc-sdd) plugin. Kiro形式のスペック駆動開発を実現する。設定可能なディレクトリ構造とカスタマイズ可能なワークフローを提供。 [When...                                                           |
| `chrome-extension-best-practices` | [What] Chrome Extension (Manifest V3) development expert for secure, performant, and Web Store policy-compliant implemen...                                                                                                             |
| `ci-diagnostics`                  | [What] Diagnose GitHub Actions CI failures and generate fix plans [When] Use when: /review --fix-ci or CI failure diagno...                                                                                                             |
| `code-quality-improvement`        | [What] Specialized skill for systematic code quality improvement. Provides Phase 1→2→3 workflow for ESLint error fixing,...                                                                                                             |
| `code-review`                     | [What] Configurable code review and quality assessment skill with project detection system. [When] Use when: code review...                                                                                                             |
| `command-creator`                 | [What] 効果的なslashコマンドの作成ガイド。コマンド構造、デザインパターン、統合ポイント、ベストプラクティスを提供します。新しいコマンドを作成したい、既存コマンドを改善したい、コマンド設計パターンを理解したい場合に使用してください... |
| `doc-standards`                   | [What] >- [When] Use when: doc-standards を使う時 [Keywords] doc standards Generic documentation standards framework. Valida...                                                                                                         |
| `docs-manager`                    | [What] Validate and manage documentation. Check metadata (date, audience, tags), verify tag system compliance, enforce s...                                                                                                             |
| `dotfiles-integration`            | [What] Specialized skill for reviewing dotfiles cross-tool integration patterns. Evaluates layer interactions (Shell/Edi...                                                                                                             |
| `gh-fix-review`                   | [What] Automated skill for GitHub PR review comment processing. Automatically classifies review comments (from CodeRabbi...                                                                                                             |
| `golang`                          | [What] Specialized skill for reviewing Go (Golang) projects. Evaluates idiomatic Go code, error handling patterns, concu...                                                                                                             |
| `knowledge-creator`               | [What] Intelligent knowledge classification and creation system. Analyzes knowledge descriptions to automatically determ...                                                                                                             |
| `markdown-docs`                   | [What] Specialized skill for reviewing and improving Markdown documentation (README, technical guides, documentation). E...                                                                                                             |
| `marketplace-manager`             | Claude Code プラグインマーケットプレイスの構成検証と管理。 [What] marketplace.json、plugin.json、SKILL.md の妥当性検証、新規プラグイン追加支援 [When] Use when: マーケ...                                                               |
| `mise`                            | [What] Specialized skill for mise (mise-en-place) task runner, tool version manager, and package manager. Provides best ...                                                                                                             |
| `nvim`                            | [What] Specialized skill for reviewing Neovim configurations. Evaluates LSP integration, plugin management, startup perf...                                                                                                             |
| `react`                           | [What] Specialized skill for reviewing React projects. Evaluates component design, Hooks usage, performance optimization...                                                                                                             |
| `react-grid-layout`               | [What] React grid layout implementation with Context7 integration and ASTA-specific patterns. Combines latest react-grid...                                                                                                             |
| `rules-creator`                   | [What] ルール・steering・hookifyの作成ガイド。4種類のルールタイプの使い分けと作成手順を提供します。 [When] Use when: プロジェクト標準を強制したい、AIの動作をガイドしたい、ルール/steering/...                                          |
| `security`                        | [What] Specialized skill for conducting security-focused code reviews. Evaluates OWASP Top 10 compliance, input validati...                                                                                                             |
| `semantic-analysis`               | [What] Advanced skill for performing semantic code analysis using Serena MCP tools. Evaluates API contract integrity, ar...                                                                                                             |
| `similarity`                      | [What] Specialized skill for detecting code duplication and analyzing code similarity in TypeScript/JavaScript projects....                                                                                                             |
| `tsr`                             | [What] Specialized skill for detecting and removing unused TypeScript/React code (dead code). Leverages TSR (TypeScript ...                                                                                                             |
| `typescript`                      | [What] Specialized skill for reviewing TypeScript projects. Evaluates type safety, TypeScript best practices, type defin...                                                                                                             |
| `wezterm`                         | [What] Specialized skill for reviewing WezTerm configurations. Evaluates GPU acceleration settings, keybinding design, t...                                                                                                             |
| `zsh`                             | [What] Specialized skill for reviewing Zsh configurations. Evaluates startup performance, plugin management, PATH optimi...                                                                                                             |

### Docs

| スキル名     | 説明                                                                                                                                                                                                                |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `deckset`    | Use this skill when working with Deckset presentations. Provides Deckset-specific syntax guidance, image modifiers, meta...                                                                                         |
| `docs-write` | このリポジトリのMarkdownドキュメント作成・更新・整形の手順を提供する。`mise` の `docs:fix` / `docs:format` / `format` タスク運用、`.prettierrc.json` と `.markd...                                                  |
| `drawio`     | Create professional draw.io diagrams (AWS architecture, flowcharts, sequence diagrams, ER diagrams) with proper XML stru...                                                                                         |
| `mcp-tools`  | [What] MCP（Model Context Protocol）サーバーのセットアップとセキュリティガイド。設定ファイルの場所、主要サーバーのインストール、環境変数管理、トラブルシューティング、セキュリティベストプラクティスを提供します... |
| `slide-docs` | [What] Specialized skill for reviewing and creating presentation slides. Evaluates slide structure, storytelling, visual...                                                                                         |

### Utils

| スキル名                  | 説明                                                                                                                                                                                  |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `claude-marketplace-sync` | [What] Claude Code marketplace のプラグイン/スキル同期を管理するスキル。同期スクリプトと設定ファイルの使い方を整理します。 [When] Use when: marketplace の更新、プラグイン追加、同... |
| `dotenvx`                 | Secure environment variable management with AES-256 encryption for safe Git commits. Use when managing .env files (creat...                                                           |
| `marketplace-manager`     | Claude Code プラグインマーケットプレイスの構成検証と管理。 [What] marketplace.json、plugin.json、SKILL.md の妥当性検証、新規プラグイン追加支援 [When] Use when: マーケ...             |

---

**更新日**: 2026-02-12
**スキル数**: 49件（Local: 13件、Marketplace: 36件）

**Local Skills内訳**:

- Foundation（Phase 1）: 3件
- Core Workflow（Phase 2）: 6件
- Secondary（Phase 3）: 4件
