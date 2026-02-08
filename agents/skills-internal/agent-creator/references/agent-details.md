# Agent Creator 詳細リファレンス

## 5つのデザインパターン

### 1. Domain Expert Agent（ドメイン専門家）

### 適している場合:

- 特定知識ドメインに特化
- 包括的な分析能力が必要
- 構造化された出力が重要

**例:** `security`, `performance`, `typescript`

### 特徴:

- ドメインに深い専門知識
- 包括的な評価フレームワーク
- 優先度付きの発見リスト
- 通常は full tool access (`tools: ["*"]`)

### 実装パターン:

```yaml
---
name: security
description: セキュリティ分析と脆弱性検出の専門家
tools: ["*"]
color: red
model: claude-sonnet-4-5
---
## 分析フレームワーク

- OWASP Top 10評価
- 認証/認可パターン検証
- データ保護チェック
- 入力バリデーション確認
```

### 2. Project-Specific Agent（プロジェクト特化）

### 適している場合:

- プロジェクト固有のルール・パターン
- アーキテクチャ準拠の検証
- プロジェクトコンテキストの活用

**例:** `cygate-api`, `asta-page-analyzer`, `caad-loca`

### 特徴:

- Steeringドキュメントからコンテキスト読み込み
- プロジェクト固有のパターン検証
- アーキテクチャ境界の強制
- 通常は full tool access (`tools: ["*"]`)

### 実装パターン:

```yaml
---
name: cygate-api
description: CyGate API専門エージェント（Clean Architecture準拠）
tools: ["*"]
color: blue
---
## プロジェクトコンテキスト

- Clean Architecture層境界
- Go idiom validation
- Business rule integrity
- Testing Trophy approach
```

### 3. Utility Agent（ユーティリティ）

### 適している場合:

- 単一目的の集中タスク
- 決定的で反復可能な処理
- 最小限のツール要件

**例:** フォーマッター、バリデーター、コンバーター

### 特徴:

- 単一責任
- 高速実行
- 明示的なツールリスト
- ステートレス

### 実装パターン:

```yaml
---
name: format-validator
description: コードフォーマット検証専門
tools: ["Read", "Bash", "Glob"]
color: magenta
model: claude-sonnet-4-5
---
## 処理フロー

1. ファイル読み込み
2. フォーマットルール適用
3. 違反報告
```

### 4. Orchestrator Agent（オーケストレーター）

### 適している場合:

- 複数のサブエージェント調整
- ワークフロー管理
- 結果の集約と統合

**例:** `code-reviewer`, `orchestrator`

### 特徴:

- Task toolを含むツールアクセス
- サブエージェントへの委譲ロジック
- 結果の統合と報告
- 意思決定フレームワーク

### 実装パターン:

```yaml
---
name: code-reviewer
description: 包括的コードレビューオーケストレーター
tools: ["*"] # Task tool含む
color: green
---

## オーケストレーション戦略

1. 変更分析
2. 専門エージェント選択
3. 並列実行:
   - security agent
   - performance agent
   - quality agent
4. 結果集約
5. 統一レポート生成
```

### 5. Autonomous Agent（自律エージェント）

### 適している場合:

- 探索的な分析
- 反復的な改善
- 自己修正能力

**例:** アーキテクチャ発見、パターン分析

### 特徴:

- 自己主導的な探索
- 反復的な洗練
- 適応的アプローチ
- 通常は full tool access

### 実装パターン:

```yaml
---
name: architecture-discoverer
description: コードベースアーキテクチャの自律探索
tools: ["*"]
color: cyan
---
## 探索戦略

1. エントリーポイント発見
2. 依存関係マッピング
3. パターン識別
4. 関係性グラフ構築
5. アーキテクチャドキュメント生成
```

## ツールアクセスモード

### Mode 1: Full Access (`tools: ["*"]`)

### 使用すべき時:

- 包括的な探索能力が必要
- 予測不可能なツール要件
- 柔軟性が重要

### 最適なエージェント:

- ドメイン専門家
- プロジェクト特化
- オーケストレーター
- 自律エージェント

### 例:

```yaml
tools: ["*"]
```

### Mode 2: Explicit List (`tools: ["Tool1", "Tool2"]`)

### 使用すべき時:

- ツール要件が明確で限定的
- セキュリティ境界が重要
- パフォーマンス最適化

### 最適なエージェント:

- ユーティリティエージェント
- 単一目的エージェント
- 高頻度実行エージェント

### 例:

```yaml
tools: ["Read", "Grep", "Bash", "Glob"]
```

### Mode 3: Inherited (`tools: "inherit"`)

### 使用すべき時:

- 親エージェントから委譲される
- 委譲チェーンの一部
- ツールセットの共有が必要

**注意:** 現在の実装では実験的機能

### ツール選択ガイドライン

### 必須ツール:

- **Read**: ファイル内容の読み込み
- **Glob**: ファイルパターンマッチング
- **Grep**: コンテンツ検索

### 任意ツール:

- **Bash**: コマンド実行、テスト、ビルド
- **Edit/Write**: ファイル変更（read-only原則に注意）
- **Task**: サブエージェント呼び出し（オーケストレーター用）

### MCP統合:

- **mcp**serena**\***: セマンティックコード分析
- **mcp**typescript**\***: TypeScript固有機能
- **mcp**o3**\***: 専門家コンサルテーション
- **mcp**context7**\***: ライブラリドキュメント参照

## エージェント構成

### ファイル構造

```
agents/
├── security.md              # ドメイン専門家
├── performance.md
├── typescript.md
├── kiro/                    # コンテキスト別グループ化
│   ├── validate-design.md
│   ├── validate-gap.md
│   └── validate-impl.md
└── project-specific/
    ├── cygate-api.md
    └── asta-page-analyzer.md
```

### 命名規則

- **kebab-case**: `agent-name.md`
- **説明的**: 名前がドメイン/目的を反映
- **一般的すぎない**: `helper` ではなく `import-resolver`
- **グループ化**: 関連エージェントはサブディレクトリに

### 配置場所

- **グローバル**: `/Users/t00114/.claude/agents/`
- **プロジェクト固有**: `.claude/agents/`

## 統合ポイント

### コマンドからの起動

コマンドはTask tool経由でエージェントを起動します:

```markdown
Task(
subagent_type="security",
description="セキュリティ分析",
prompt="認証実装の脆弱性を分析してください",
context={"files": security_files}
)
```

### スキルからの参照

スキルは特定の能力のためにエージェントを参照できます:

```markdown
セキュリティ固有の分析には、このスキルは `security` エージェントに委譲します。
```

### エージェント間の委譲

エージェントは他のエージェントを起動できます:

```markdown
Task(
subagent_type="type-analyzer",
description="型安全性分析",
prompt="関数の型安全性を分析",
context=context
)
```

## 品質基準

### 必須要素チェックリスト

- [ ] 明確な役割定義とドメイン専門知識
- [ ] 必須フィールドをすべて含むYAMLフロントマター
- [ ] 明示的な能力リスト
- [ ] 起動コンテキストの文書化（使用タイミング）
- [ ] 出力形式の仕様
- [ ] 役割に適したツールアクセス

### ベストプラクティス

- [ ] 単一責任原則に従う
- [ ] 出力が構造化され解析可能
- [ ] 既存エージェントエコシステムと統合
- [ ] 類似エージェントの確立されたパターンを使用
- [ ] 起動例を提供
- [ ] 期待される入出力を文書化
- [ ] read-only原則を尊重

### アンチパターン（避けるべきこと）

- ❌ 汎用的な"すべてを行う"エージェント（広すぎる）
- ❌ 既存エージェント機能の重複
- ❌ 過剰なツールアクセス権限（必要なものだけ要求）
- ❌ 明示的なユーザーリクエストなしのファイル変更
- ❌ 統合ガイダンスの欠如
- ❌ 不明確な起動基準

## Agent vs Skill vs Command 判断基準

| 観点         | Agent                     | Skill                      | Command                |
| ------------ | ------------------------- | -------------------------- | ---------------------- |
| **起動**     | Task tool経由             | 自動トリガー               | ユーザーが `/cmd` 入力 |
| **自律性**   | 自律実行                  | コンテキスト認識ガイダンス | ユーザー主導           |
| **スコープ** | 集中的サブタスク          | ドメイン専門知識           | ワークフロー調整       |
| **状態**     | 起動毎にステートレス      | 会話を跨ぐコンテキスト     | セッションベース       |
| **例**       | `security`, `performance` | `typescript`, `react`      | `/review`, `/refactor` |

### Agentを選ぶべき時:

- タスクが大きなワークフローの委譲可能なサブコンポーネント
- ユーザーインタラクションなしの自律実行が必要
- 出力が親プロセスに戻される
- 専門知識が集中的で反復可能

### Skillを選ぶべき時:

- ドメイン専門知識が複数のインタラクションに跨る
- コンテキストが会話を通じて構築される
- キーワードベースの自動起動が価値ある
- ガイダンスが実行より重要

### Commandを選ぶべき時:

- ユーザーが明示的にワークフローを開始
- 複数フェーズの調整が必要
- セッション管理が必要
- 直接的なユーザーインタラクションが必須

## エージェントの出力形式

### 構造化出力

エージェントは構造化され解析可能な結果を返すべきです:

```markdown
## 分析結果

### 発見事項

1. **[カテゴリー]**: 説明
   - 深刻度: High/Medium/Low
   - 場所: file:line
   - 推奨: アクション項目

### 要約

- 総問題数: N
- クリティカル: N
- アクション可能: N

### 次のステップ

1. アクション項目
2. アクション項目
```

### 統合に優しい形式

- 解析用の一貫した見出し
- 深刻度/優先度インジケーター
- file:line参照を提供
- 発見事項と推奨事項を分離

## モデル選択

### claude-sonnet-4-5（デフォルト）

### 使用すべき時:

- ほとんどの分析タスク
- パターン認識
- コスト効率が重要
- 高速実行が必要

### 最適なエージェント:

- ユーティリティエージェント
- 標準的なドメイン専門家
- 高頻度実行エージェント

### claude-opus-4-5

### 使用すべき時:

- 複雑な推論が必要
- 微妙な意思決定
- 深いアーキテクチャ分析
- トレードオフ評価

### 最適なエージェント:

- アーキテクチャレビュー
- 設計検証
- 複雑な問題解決

## テンプレートとリソース

### スターターテンプレート

`resources/templates/agent-template.md` に基本構造があります。

### 実例

以下の実例を参照してください:

- `resources/examples/domain-expert-agent.md` - セキュリティエージェント例
- `resources/examples/project-specific-agent.md` - プロジェクト特化例
- `resources/examples/validator-agent.md` - 検証エージェント例

### 品質チェックリスト

`resources/checklist.md` に包括的なチェックリストがあります。

## エージェントのテスト

### 起動テスト

```python
# Task tool経由で起動
result = Task(
  subagent_type="your-agent",
  description="テスト説明",
  prompt="テストタスク",
  context={"test": "data"}
)
```

### 検証項目

1. **ツールアクセス**: 宣言されたツールにアクセス可能か
2. **出力形式**: 文書化された通りに構造化されているか
3. **統合**: 親コマンド/ワークフローと正しく動作するか
4. **エッジケース**: 欠落/無効な入力を処理できるか

## 高度なパターン

### マルチエージェントワークフロー

```markdown
1. 親コマンドがニーズを特定
2. コマンドがAgent Aを起動（分析）
3. Agent Aが構造化された発見事項を返す
4. コマンドがAgent Aの出力と共にAgent Bを起動（検証）
5. コマンドが結果を集約
```

### 条件付きエージェント選択

```markdown
プロジェクトタイプに基づいて:

- TypeScriptプロジェクト → `typescript` エージェント起動
- Goプロジェクト → `golang` エージェント起動
- Pythonプロジェクト → `python` エージェント起動
```

### 並列エージェント実行

```python
# 同時実行（single message, multiple Task calls）
results = await parallel_execute([
  Task(subagent_type="security", ...),
  Task(subagent_type="performance", ...),
  Task(subagent_type="quality", ...)
])

# すべて完了後に結果を集約
```

## 次のステップ

エージェント作成後:

1. Task tool経由での起動をテスト
2. ツールアクセスが期待通りに動作するか検証
3. 出力形式を検証
4. 親コマンド/スキルで統合を文書化
5. エージェントドキュメントに例を追加
6. より広いスコープが必要な場合はskillへの変換を検討

## 関連リソース

- **command-creator skill**: エージェントを使用するコマンドの作成方法
- **rules-creator skill**: エージェントが検証するルールの作成方法
- **skill-creator skill**: より広いドメインエコシステムの場合
- **agents-and-commands skill**: エージェントとコマンドの違い
- **integration-framework skill**: 統合パターン

---

このskillを使用して、一貫性があり、よく統合された高品質なサブエージェントを作成してください。
