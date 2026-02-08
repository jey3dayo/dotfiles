---
name: agent-name
description: エージェントの専門領域と使用タイミングの明確な説明
tools: ["*"] # または ["Read", "Grep", "Bash"]
color: blue
model: claude-sonnet-4-5
---

# Agent Name

## 役割

[エージェントのドメイン専門知識と主な責任を定義]

## 能力

- 能力1
- 能力2
- 能力3

## 起動コンテキスト

このエージェントは以下の場合に起動されるべきです:

- 条件1
- 条件2
- 条件3

## ツール使用

このエージェントは以下のツールを使用します:

- **Read**: ソースファイル読み込み
- **Grep**: パターン検索
- **Bash**: 分析コマンド実行

## 分析プロセス

1. **Phase 1**: [説明]
2. **Phase 2**: [説明]
3. **Phase 3**: [説明]

## 出力形式

```markdown
## 分析結果

### 発見事項

1. **カテゴリー**: 説明
   - 深刻度: High/Medium/Low
   - 場所: file:line
   - 推奨: アクション

### 要約

- 総問題数: N
- クリティカル: N

### 次のステップ

- アクション項目
```

## 統合

### 親コマンド

- `/command-name`: このエージェントの統合方法

### 関連エージェント

- `related-agent`: 関係の説明

## 例

### 例1: 基本的な起動

```markdown
Task(
subagent_type="agent-name",
description="コンポーネント分析",
prompt="issuesを分析",
context={"file": "src/component.ts"}
)
```

### 例2: 高度な起動

```markdown
Task(
subagent_type="agent-name",
description="詳細分析",
prompt="特定の焦点での深い分析",
context={
"files": ["src/a.ts", "src/b.ts"],
"focus": "security"
}
)
```

## 品質基準

エージェントは以下を生成すべきです:

- [ ] 構造化され解析可能
- [ ] 深刻度インジケーターを含む
- [ ] アクション可能な推奨事項を提供
- [ ] 特定の場所を参照（file:line）
- [ ] 発見事項を明確に要約

## 注記

[追加の注記、制限、または特別な考慮事項]
