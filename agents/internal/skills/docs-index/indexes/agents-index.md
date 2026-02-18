# Agents Index

Claude Codeで利用可能なエージェント一覧。

## 主要エージェント

| エージェント           | 用途                       | 主要能力                                 |
| ---------------------- | -------------------------- | ---------------------------------------- |
| **orchestrator**       | タスクオーケストレーション | 複数エージェントの統合、ワークフロー管理 |
| **code-reviewer**      | コードレビュー             | 包括的なコード品質評価、セキュリティ分析 |
| **github-pr-reviewer** | GitHub PRレビュー          | PR自動レビュー、コメント処理             |
| **error-fixer**        | エラー修正                 | 自動エラー診断と修正提案                 |
| **docs-manager**       | ドキュメント管理           | ドキュメント整合性チェック、自動更新     |
| **researcher**         | 技術調査                   | 最新技術情報の収集と分析                 |
| **task-router**        | タスクルーティング         | 最適なエージェント/コマンドの自動選択    |

## エージェント選択ガイド

### コード品質関連

- コードレビューが必要: `code-reviewer` または `/review` コマンド
- PRレビュー対応: `github-pr-reviewer` または `/review --fix-pr`
- エラー修正: `error-fixer` または `/polish`
- コード整形: `/polish` コマンド（自動エージェント選択）

### ドキュメント関連

- ドキュメント管理: `docs-manager` または `/docs`
- ドキュメント修正: `/fix-docs` コマンド
- README作成: `docs-manager` + `markdown-docs` スキル

### タスク実行関連

- 自動タスク判定: `/task` コマンド（task-router連携）
- 複雑なワークフロー: `orchestrator`
- ToDo管理: `/todos` コマンド

### 開発支援関連

- 実装支援: `/implement` コマンド
- リファクタリング: `refactoring-agent`
- 技術調査: `researcher` + o3-search MCP

## エージェント統合パターン

### コマンド → エージェント

多くのコマンドは内部で適切なエージェントを自動選択します:

```
/review → code-reviewer, github-pr-reviewer
/polish → error-fixer, code-quality-agent
/task → task-router → 最適なエージェント
/implement → implementation-agent
```

### スキル → エージェント

スキルはエージェントに専門知識を提供します:

```
code-review skill → code-reviewer agent
integration-framework skill → orchestrator agent
cc-sdd skill → spec-driven-agent
```

### エージェント連携

複雑なタスクでは複数エージェントが連携:

```
orchestrator
  ├─ task-router (タスク分析)
  ├─ code-reviewer (品質評価)
  ├─ error-fixer (問題修正)
  └─ docs-manager (ドキュメント更新)
```

## カスタムエージェント作成

新しいエージェントを作成する場合:

1. 設計: `agent-creator` スキルで構造設計
2. 実装: `~/.config/agents/internal/agents/` に配置
3. 統合: `integration-framework` に基づいた実装
4. テスト: 小規模タスクで検証

詳細は `agent-creator` スキルと `integration-framework` を参照。

---

### 更新日

### 注
