---
description: Maintain ~/.claude/ environment with skills field population and metadata validation
argument-hint: [--dry-run] [--apply] [--agents-only] [--skills-only] [--metadata-only] [--show-relations] [--detect-orphans]
---

# Maintain Claude - ~/.claude/ メンテナンスコマンド

`~/.claude/agents/`, `~/.claude/skills/`, `~/.claude/commands/` のメンテナンスを自動化するコマンドです。

## 🎯 主要機能

### 1. Skills自動補填

agentsに適切な`skills`フィールドを自動的に追加します。

**検出ロジック**:

- 技術スタック一致（typescript, golang, react等）
- Agent名に含まれる技術（terraform-operations → perman-aws-vault）
- コンテキスト関連性（レビュー系 → code-review, security）
- 既存パターン学習（他の類似Agentが参照）

### 2. 不要ファイル検出

孤立・重複・廃止済みファイルを検出し、報告します（削除は提案のみ）。

**検出カテゴリ**:

- **孤立ファイル**: 参照なし、空プロンプト、6ヶ月未使用
- **重複ファイル**: 名前・説明の類似度が高い
- **廃止済み**: deprecatedマーク、1年以上未更新

### 3. メタデータ検証

YAML frontmatter、参照整合性、命名規則をチェックします。

### 4. 関連性分析

Agent-Skill関連性マップを生成し、最適な組み合わせを提案します。

## 📋 使用方法

### 基本実行

```bash
# デフォルト（分析と報告のみ、変更なし）
/maintain-claude

# 変更を適用
/maintain-claude --apply
```

### スコープ制御

```bash
# Agentsのみメンテナンス
/maintain-claude --agents-only

# Skillsのみメンテナンス
/maintain-claude --skills-only

# メタデータ検証のみ
/maintain-claude --metadata-only
```

### 分析オプション

```bash
# Agent-Skill関連性マップを表示
/maintain-claude --show-relations

# 孤立ファイルの検出
/maintain-claude --detect-orphans
```

## 🔧 実装フロー

### Phase 1: Analysis（分析）

**タスク**: ファイルスキャン、メタデータ抽出、関連性グラフ構築

```typescript
// 1. ファイルスキャン
const structure = {
  agents: glob("~/.claude/agents/*.md"),
  skills: glob("~/.claude/skills/*/SKILL.md"),
  commands: glob("~/.claude/commands/*.md"),
};

// 2. メタデータ抽出（並列処理）
const metadata = await Promise.all([
  extractAgentMetadata(structure.agents),
  extractSkillMetadata(structure.skills),
  extractCommandMetadata(structure.commands),
]);

// 3. 関連性グラフ構築
const relationshipGraph = buildRelationshipGraph(metadata);

// 4. 問題検出
const issues = {
  missingSkills: detectMissingSkills(metadata.agents, relationshipGraph),
  orphanedFiles: detectOrphans(metadata, relationshipGraph),
  metadataErrors: validateMetadata(metadata),
  duplicates: detectDuplicates(metadata),
};
```

**実装**: `commands/shared/claude-metadata-analyzer.md` を使用

### Phase 2: Report（報告）

**タスク**: 現状サマリー、検出された問題、提案される変更

```markdown
# ~/.claude/ メンテナンスレポート

## 📊 現状サマリー

- Agents: 36個（うち5個にskillsフィールドなし）
- Skills: 34個（すべて有効）
- Commands: 20個（すべて有効）

## ⚠️ 検出された問題

### 1. Agents: Missing Skills Fields (5件)

| Agent        | 推奨Skills         | スコア | 理由             |
| ------------ | ------------------ | ------ | ---------------- |
| orchestrator | typescript, golang | 55     | 技術スタック一致 |

### 2. メタデータエラー (2件)

| ファイル       | エラー            | 修正方法         |
| -------------- | ----------------- | ---------------- |
| agents/test.md | descriptionが短い | 詳細な説明を追加 |

### 3. 孤立ファイル (0件)

（検出なし）

## 🔧 提案される変更

### Skills補填 (5件)

- orchestrator → typescript, golang, code-quality-improvement
- deployment → perman-aws-vault, asta-deployment, cicd-pipeline

### メタデータ修正 (2件)

- agents/test.md: description延長

💡 変更を適用するには --apply オプションを使用してください
```

### Phase 3: Confirmation（確認）

**タスク**: ユーザー確認、git status確認、変更前差分表示

```bash
# --applyモードの場合のみ実行

# 1. 現在のgit状態確認
git status

# 2. 未コミットの変更がある場合は警告
if [[ -n $(git status --porcelain) ]]; then
  echo "⚠️  未コミットの変更があります。続行しますか？"
fi

# 3. 変更内容の確認
echo "⚠️  以下の変更を適用します："
echo "  - Skills補填: 5件"
echo "  - メタデータ修正: 2件"
echo "  - 削除: 0件"
echo ""
read -p "続行しますか？ (y/n): " confirm
```

### Phase 4: Execution（実行）

**タスク**: メタデータ修正、Skills補填、ファイル削除

```typescript
// 1. Skills補填
for (const agent of proposedChanges.skillsToAdd) {
  const content = await read(agent.path);
  const updatedContent = addSkillsToFrontmatter(content, agent.skills);
  await write(agent.path, updatedContent);
}

// 2. メタデータ修正
for (const fix of proposedChanges.metadataFixes) {
  const content = await read(fix.path);
  const updatedContent = fixMetadata(content, fix.changes);
  await write(fix.path, updatedContent);
}

// 3. ファイル削除（ユーザー確認済みの場合のみ）
for (const removal of proposedChanges.filesToRemove) {
  if (removal.confirmed) {
    await remove(removal.path);
  }
}

// 4. 変更サマリー表示
console.log("✅ 変更サマリー:");
console.log(`  - Skills補填: ${proposedChanges.skillsToAdd.length}件`);
console.log(`  - メタデータ修正: ${proposedChanges.metadataFixes.length}件`);
console.log(`  - 削除: ${proposedChanges.filesToRemove.length}件`);
```

### Phase 5: Validation（検証）

**タスク**: YAML構文、参照整合性、変更サマリー

```typescript
// 1. YAML構文検証
const yamlErrors = await validateYAMLSyntax(changedFiles);

// 2. 参照整合性検証
const brokenReferences = await validateReferences(changedFiles);

// 3. 命名規則検証
const namingErrors = await validateNaming(changedFiles);

// 4. 結果表示
if (yamlErrors.length === 0 && brokenReferences.length === 0) {
  console.log("✅ すべての検証に合格");
} else {
  console.error("❌ 検証エラー:");
  yamlErrors.forEach((err) => console.error(`  - ${err}`));
  brokenReferences.forEach((err) => console.error(`  - ${err}`));
}

// 5. Git操作のガイダンス
console.log("\n💡 次のステップ:");
console.log("  - 変更を確認: git diff");
console.log("  - 問題があれば: git restore .claude/");
console.log("  - 問題なければ: git add .claude/ && git commit");
```

## 🔗 共有ライブラリ

このコマンドは以下の共有ライブラリを使用します：

### 1. claude-metadata-analyzer.md

**機能**:

- ファイルスキャン
- メタデータ抽出
- 関連性グラフ構築
- 問題検出

**使用方法**:

```typescript
import { analyzeClaudeDirectory } from "./shared/claude-metadata-analyzer";

const analysis = await analyzeClaudeDirectory({
  agentsOnly: false,
  skillsOnly: false,
  metadataOnly: false,
});
```

### 2. skill-mapping-engine.md

**機能**:

- Agent-Skill関連性スコアリング
- Skills自動補填推奨
- 既存パターン学習

**使用方法**:

```typescript
import { recommendSkills } from "./shared/skill-mapping-engine";

const recommendations = await recommendSkills(agent, availableSkills);
// スコア >= 50: 自動追加
// スコア >= 30: 提案
// スコア < 30: 除外
```

## 🔐 安全性保証

1. **デフォルト dry-run**: 明示的な `--apply` なしでは変更なし
2. **Git管理**: git statusとgit diffで変更内容を確認可能
3. **段階的確認**: 重要な変更は個別確認
4. **簡単な復元**: `git restore` または `git revert` でいつでも戻せる
5. **参照整合性**: 破壊的変更の防止

## 📊 出力例

### Dry-runモード（デフォルト）

```bash
$ /maintain-claude

🔍 分析中...

# ~/.claude/ メンテナンスレポート

## 📊 現状サマリー
- Agents: 36個（うち5個にskillsフィールドなし）
- Skills: 34個（すべて有効）
- Commands: 20個（すべて有効）

## ⚠️ 検出された問題

### 1. Agents: Missing Skills Fields (5件)
| Agent | 推奨Skills | スコア | 理由 |
|-------|-----------|--------|------|
| orchestrator | typescript, golang | 55 | 技術スタック一致 |
| deployment | perman-aws-vault, asta-deployment | 50 | 名前+コンテキスト一致 |

### 2. メタデータエラー (0件)
（検出なし）

### 3. 孤立ファイル (0件)
（検出なし）

## 🔧 提案される変更

### Skills補填 (5件)
- orchestrator → typescript, golang, code-quality-improvement
- deployment → perman-aws-vault, asta-deployment, cicd-pipeline
- code-reviewer → typescript, security, code-quality-improvement
- error-fixer → typescript, code-quality-improvement
- aws-operations → perman-aws-vault

💡 変更を適用するには --apply オプションを使用してください
```

### Applyモード

```bash
$ /maintain-claude --apply

🔍 分析中...

（同じレポート表示）

⚠️  5件の変更を適用します。続行しますか？ (y/n): y

📝 変更前の状態を確認:
   M .claude/agents/orchestrator.md
   M .claude/agents/deployment.md
   M .claude/agents/code-reviewer.md
   M .claude/agents/error-fixer.md
   M .claude/agents/aws-operations.md

[████████████████████] 100% | 5/5 | 完了

✅ 変更サマリー:
  - Skills補填: 5件
  - メタデータ修正: 0件
  - 削除: 0件

✅ すべての検証に合格

💡 次のステップ:
  - 変更を確認: git diff
  - 問題があれば: git restore .claude/
  - 問題なければ: git add .claude/ && git commit -m "chore: maintain-claude による自動メンテナンス"
```

## 🛠️ 技術詳細

### Agent-Skill関連性スコアリング

```typescript
interface RelationshipScore {
  technologyMatch: number; // 30点: typescript, golang, react等
  nameMatch: number; // 25点: agent名に技術名が含まれる
  contextMatch: number; // 20点: レビュー系 → code-review, security
  patternMatch: number; // 15点: 他の類似Agentが参照
  keywordMatch: number; // 10点: descriptionの共通キーワード
}

// 総合スコア判定
// >= 50: 自動追加（確信度高）
// >= 30: 提案（ユーザー確認推奨）
// < 30: 除外
```

### 不要ファイル検出基準

**孤立ファイル（HIGH優先度）**:

- どのAgent/Skillからも参照されていない
- システムプロンプトが空または100文字未満
- 最終更新から6ヶ月以上経過

**重複ファイル（MEDIUM優先度）**:

- 名前の類似度 > 80%
- 説明文の類似度 > 70%
- トリガー条件が完全一致

**廃止済みファイル（MEDIUM優先度）**:

- メタデータに "deprecated" マーク
- 移行先ドキュメントあり
- 最終更新から1年以上経過

### メタデータ検証ルール

**Agent検証**:

```yaml
required:
  name: kebab-case形式
  description: 20文字以上
  systemPrompt: 100文字以上
optional:
  skills: 参照先Skillが存在するか
  tools: "*" または "tool1, tool2"
  color: blue/red/green等
```

**Skill検証**:

```yaml
required:
  name: SKILL.md内に記載
  description: 50文字以上
  location: "user" | "project"
fileStructure:
  hasSKILLmd: 必須
  hasREADMEmd: 推奨
```

**Command検証**:

```yaml
required:
  description: 30文字以上
  syntax: 使用例
optional:
  argumentHint: 引数ヒント
  relatedSkills: 関連Skill
```

## 参考実装

- `/fix-docs` - 段階的実行パターン
- `/skill-up` - 分類アルゴリズム
- `docs-manager` skill - メタデータ検証

## 注意事項

- **読み取り専用モード**: `--dry-run`（デフォルト）では変更なし
- **Git管理**: 変更前に`git status`を確認推奨
- **復元**: 問題があれば`git restore .claude/`で復元可能
- **段階的適用**: 大量の変更がある場合は`--agents-only`等で部分適用推奨
