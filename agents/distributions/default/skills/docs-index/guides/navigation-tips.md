# Navigation Tips - ドキュメント検索のベストプラクティス

Claude Codeのドキュメントを効率的に検索・ナビゲートするためのTips集。

## キーワード検索戦略

### 技術スタック別

特定の技術スタックに関連するスキルを探す場合:

| 技術       | キーワード                          | 該当スキル                   |
| ---------- | ----------------------------------- | ---------------------------- |
| TypeScript | `typescript`, `ts`, `type checking` | `typescript`, `code-review`  |
| React      | `react`, `hooks`, `jsx`             | `react`, `react-grid-layout` |
| Go         | `golang`, `go`                      | `golang`                     |
| Neovim     | `nvim`, `neovim`, `LSP`             | `nvim`                       |
| Zsh        | `zsh`, `shell`, `startup time`      | `zsh`                        |
| Mise       | `mise`, `mise-en-place`             | `mise`                       |

### タスク別

やりたいことからスキル/コマンドを探す:

| タスク           | キーワード                           | 推奨ツール                                  |
| ---------------- | ------------------------------------ | ------------------------------------------- |
| コードレビュー   | `code review`, `レビュー`            | `/review`, `code-review` skill              |
| コード品質改善   | `quality`, `lint`, `format`          | `/polish`, `code-quality-improvement` skill |
| セキュリティ     | `security`, `OWASP`, `vulnerability` | `security` skill                            |
| ドキュメント作成 | `docs`, `markdown`, `README`         | `markdown-docs`, `docs-write` skill         |
| 重複コード検出   | `duplicate`, `similarity`            | `similarity` skill                          |
| 未使用コード削除 | `dead code`, `unused code`           | `tsr` skill                                 |
| 環境変数管理     | `env`, `dotenv`, `encryption`        | `dotenvx` skill                             |

## 階層的ナビゲーション

### Top-Down アプローチ

```
1. CLAUDE.md（グローバル/プロジェクト）
   ├─ スキルシステム概要
   ├─ コマンドシステム概要
   └─ 主要機能リファレンス
      ↓
2. docs-index スキル
   ├─ indexes/skills-index.md    # 全スキル一覧
   ├─ indexes/commands-index.md  # 全コマンド一覧
   └─ indexes/agents-index.md    # 全エージェント一覧
      ↓
3. 個別スキル/コマンドドキュメント
   └─ 詳細仕様・使用例
```

### Bottom-Up アプローチ

```
1. 具体的な問題/タスク
   ↓
2. キーワード検索（docs-index）
   ↓
3. 関連スキル/コマンド特定
   ↓
4. Progressive Disclosure で詳細確認
```

## Progressive Disclosure の活用

### レベル1: 概要（SKILL.md）

最初は概要だけを確認:

```
"code-reviewスキルの概要を教えて"
→ SKILL.mdの[What][When][Keywords]セクションを読む
```

### レベル2: クイックリファレンス

もう少し詳しく知りたい場合:

```
"code-reviewスキルのクイックリファレンスを見せて"
→ 主要機能・使い方の要約を確認
```

### レベル3: 詳細ドキュメント

実装時に必要な詳細:

```
"code-reviewスキルの評価基準を詳しく教えて"
→ references/配下の詳細ドキュメントをロード
```

## キーワードマッピング（日本語↔英語）

### コマンド系

| 日本語   | 英語            | コマンド     |
| -------- | --------------- | ------------ |
| レビュー | review          | `/review`    |
| 品質改善 | polish, quality | `/polish`    |
| コミット | commit          | `/commit`    |
| タスク   | task            | `/task`      |
| 学習記録 | learnings       | `/learnings` |

### スキル系

| 日本語             | 英語                  | スキル                  |
| ------------------ | --------------------- | ----------------------- |
| 統合フレームワーク | integration framework | `integration-framework` |
| コードレビュー     | code review           | `code-review`           |
| スペック駆動       | spec-driven           | `cc-sdd`                |
| セキュリティ       | security              | `security`              |
| セマンティック解析 | semantic analysis     | `semantic-analysis`     |

### 技術スタック系

| 日本語           | 英語                 | スキル       |
| ---------------- | -------------------- | ------------ |
| タイプスクリプト | typescript, ts       | `typescript` |
| リアクト         | react                | `react`      |
| ゴー言語         | golang, go           | `golang`     |
| シェル最適化     | shell optimization   | `zsh`        |
| エディタ設定     | editor configuration | `nvim`       |

## クロスリファレンス活用

### スキル → コマンド

スキルから関連コマンドを探す:

```
code-review スキル → /review コマンド
cc-sdd スキル → /kiro:* コマンドファミリー
integration-framework スキル → /task, /implement コマンド
```

### コマンド → スキル

コマンドが使用するスキルを確認:

```
/review → code-review, security, typescript スキル
/polish → code-quality-improvement スキル
/kiro:spec-init → cc-sdd スキル
```

### スキル → エージェント

スキルが支援するエージェント:

```
code-review スキル → code-reviewer, github-pr-reviewer エージェント
integration-framework スキル → orchestrator エージェント
cc-sdd スキル → spec-driven-agent
```

## トラブルシューティングへのリンク

### ドキュメントが見つからない

1. **インデックスを確認**

   - `indexes/skills-index.md`
   - `indexes/commands-index.md`
   - `indexes/agents-index.md`

2. **キーワード検索**

   - 日本語/英語両方のキーワードを試す
   - 類義語・関連語でも検索

3. **カテゴリから探す**
   - Dev-Tools, Docs, Utils のカテゴリ別に探索

### スキルが動作しない

`~/.config/.claude/rules/troubleshooting.md` を参照:

- Nix Home Manager でのスキル配布問題
- シンボリックリンクの確認
- generation の検証方法

### コマンドが実行されない

1. コマンド名のスペルミスを確認
2. `/help` でコマンド一覧を確認
3. `commands-index.md` で正しい構文を確認

## 検索パターン集

### パターン1: 機能から探す

```
"〇〇したい" → キーワード抽出 → インデックス検索
例: "TypeScriptの型エラーを直したい"
  → "typescript", "type error"
  → typescript スキル, /polish コマンド
```

### パターン2: エラーから探す

```
エラーメッセージ → 関連キーワード → スキル/コマンド検索
例: "ESLintエラーがたくさん出る"
  → "eslint", "質的改善", "大量修正"
  → code-quality-improvement スキル, /polish コマンド
```

### パターン3: プロジェクトタイプから探す

```
プロジェクトタイプ → 技術スタック → 関連スキル
例: "React + TypeScript プロジェクト"
  → react, typescript
  → react, typescript, code-review スキル
```

## ベストプラクティス

### DO

- キーワードは日本語・英語両方で試す
- Progressive Disclosure を活用する（概要→詳細）
- インデックスから探索する（Top-Down）
- クロスリファレンスで関連ツールを確認する

### DON'T

- いきなり詳細ドキュメントを読まない（トークン効率悪い）
- 単一キーワードだけで諦めない（類義語も試す）
- カテゴリ横断的な検索を忘れない（スキル/コマンド/エージェント）

## 定期更新の確認

インデックスは定期的に更新されます。最新情報の確認方法:

```bash
# skills-index.md の更新日を確認
ls -l ~/.claude/skills/docs-index/indexes/skills-index.md

# Marketplace の同期状態を確認
claude-marketplace-sync スキルを参照
```

---

### 更新日
### 関連
