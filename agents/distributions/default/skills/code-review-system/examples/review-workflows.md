# レビューワークフロー実例

code-review-systemを使った5つの実践的なワークフローです。

## 例1: 日常的なレビュー

### シナリオ

コミット前に素早く問題をチェックしたい。

### ワークフロー

#### ステップ1: ステージされた変更をクイックレビュー

```bash
/review --simple --staged
```

### 期待される出力

```markdown
# クイックレビュー結果

## 対象

- src/api/users.ts (変更: 45 行)
- src/components/UserProfile.tsx (変更: 23 行)

## 🔴 高優先度 (2 件)

### 1. セキュリティ: 入力検証が不十分

- ファイル: src/api/users.ts:45
- 問題: ユーザー入力を直接クエリに使用
- 修正提案: パラメータ化クエリを使用

### 2. パフォーマンス: useEffect の依存配列が不正確

- ファイル: src/components/UserProfile.tsx:15
- 問題: userId が依存配列に含まれていない
- 修正提案: 依存配列に userId を追加

## 🟡 中優先度 (3 件)

...

## 🟢 低優先度 (5 件)

...

## 推奨アクション

1. 高優先度の問題を修正
2. 自動修正を試す: /review --simple --fix
```

#### ステップ2: 問題発見 → 自動修正

```bash
/review --simple --fix
```

### 期待される動作

1. 上記の問題を検出
2. 自動修正可能な問題を修正
3. 修正不可能な問題を報告
4. lint/test を実行して検証

### 期待される出力

```markdown
# 自動修正結果

## 修正完了 (4 件)

✅ src/api/users.ts:45 - パラメータ化クエリに修正
✅ src/components/UserProfile.tsx:15 - 依存配列に userId を追加
✅ src/utils/helpers.ts:78 - 未使用変数を削除
✅ src/styles/theme.ts:12 - フォーマット修正

## 手動修正が必要 (1 件)

🔴 src/api/posts.ts:89 - N+1 クエリ問題
理由: ビジネスロジックの変更が必要

## 品質保証

✅ Lint: 成功
✅ Test: 成功
✅ Build: 成功

## 次のステップ

1. 手動修正が必要な問題を確認
2. コミット: git commit -m "Fix review issues"
```

### 所要時間

- クイックレビュー: 30 秒 〜 1 分
- 自動修正: 1 〜 2 分

### ユースケース

- 日常的なコード変更
- コミット前のクイックチェック
- PR 作成前の事前チェック

## 例2: リリース前の包括的レビュー

### シナリオ

開発ブランチをリリースする前に、徹底的なレビューを実施したい。

### ワークフロー

#### ステップ1: 開発ブランチとの差分を詳細レビュー

```bash
/review --branch develop
```

### 期待される出力

```markdown
# 包括的レビュー結果

## プロジェクト情報

- タイプ: Next.js
- 統合スキル: TypeScript, React, Security
- 対象: 125 ファイル、3,450 行の変更

## 評価結果

### 型安全性 ⭐️⭐️⭐️⭐️☆ (4/5)

- any 型の使用: 8 箇所検出
- strict mode: 有効
- 推奨: any 型の削減

### React Patterns ⭐️⭐️⭐️⭐️⭐️ (5/5)

- Hooks 使用: 適切
- パフォーマンス最適化: 良好
- コンポーネント設計: 優れている

### セキュリティ ⭐️⭐️⭐️☆☆ (3/5)

- 🔴 Critical: SQL Injection のリスク (2 箇所)
- 🟡 High: 認証チェックが不十分 (3 箇所)
- 推奨: セキュリティ問題の優先的な修正

### パフォーマンス ⭐️⭐️⭐️⭐️☆ (4/5)

- API 応答時間: 良好
- バンドルサイズ: 適切
- 🟡 Medium: 画像最適化の余地あり

### 保守性 ⭐️⭐️⭐️⭐️☆ (4/5)

- コードの可読性: 良好
- ドキュメント: 適切
- テストカバレッジ: 82%

## 総合評価 ⭐️⭐️⭐️⭐️☆ (4/5)

リリース可能だが、セキュリティ問題の修正を推奨。

## アクションプラン

### Phase 1: Critical 問題（必須）

1. SQL Injection 修正 (2 箇所、30 分)
2. 認証チェック追加 (3 箇所、45 分)

### Phase 2: High 問題（推奨）

1. any 型の削減 (8 箇所、1 時間)
2. 画像最適化 (3 箇所、30 分)

### Phase 3: Medium/Low 問題（オプション）

1. コメント追加 (10 箇所、30 分)
2. テストカバレッジ向上 (1 時間)
```

#### ステップ2: 影響分析を含む詳細レビュー

```bash
/review --with-impact --create-issues
```

### 期待される動作

1. Serena を使って API 変更の影響範囲を分析
2. 各問題を GitHub issue として作成
3. 優先度ラベルを自動付与

### 期待される出力

```markdown
# 影響分析結果

## API 変更の影響

### 変更: getUserById の戻り値型変更

- ファイル: src/api/users.ts:45
- 影響範囲: 15 ファイル、23 箇所
- 影響度: 🔴 High
- 推奨: Breaking Change として扱う

#### 影響を受けるファイル

1. src/components/UserProfile.tsx:12
2. src/pages/dashboard.tsx:45
3. src/hooks/useUser.ts:23
   ...

## GitHub Issues 作成

✅ Issue #123: [Security] SQL Injection risk in users API
✅ Issue #124: [Security] Missing auth check in posts API
✅ Issue #125: [Performance] N+1 query in comments
✅ Issue #126: [TypeScript] Reduce any type usage
✅ Issue #127: [Performance] Image optimization needed

## 推奨アクション

1. Breaking Change のマイグレーションガイド作成
2. Critical/High issue を優先的に修正
3. チームレビュー後、リリース
```

### 所要時間

- 詳細レビュー: 5 〜 10 分
- 影響分析: 3 〜 5 分
- Issue 作成: 1 〜 2 分

### ユースケース

- リリース前のレビュー
- 大規模な機能追加後
- チームレビュー前の事前チェック

## 例3: 学習と改善

### シナリオ

レビュー結果から学習し、将来の開発に活かしたい。

### ワークフロー

#### ステップ1: レビュー結果を学習データとして記録

```bash
/review --learn
```

### 期待される動作

1. レビューを実施
2. よく見つかる問題パターンを記録
3. 改善提案を生成

### 期待される出力

````markdown
# レビュー & 学習結果

## レビュー結果

[通常のレビュー結果]

## 学習データ記録

### よく見つかる問題パターン

1. **SQL Injection**: 過去 3 回、src/api/\*.ts で検出
   - パターン: 直接的な文字列連結
   - 推奨: パラメータ化クエリの使用
   - 関連: learnings/security/sql-injection.md

2. **useEffect 依存配列**: 過去 5 回検出
   - パターン: 外部変数を依存配列に含めていない
   - 推奨: ESLint react-hooks/exhaustive-deps の有効化
   - 関連: learnings/react/useeffect-deps.md

3. **any 型の使用**: 過去 10 回検出
   - パターン: 外部ライブラリの型定義不足
   - 推奨: @types/\* パッケージのインストール
   - 関連: learnings/typescript/any-types.md

## 改善提案

### 1. プロジェクトルールの追加

`.claude/review-guidelines.md` に以下を追加することを推奨：

```markdown
## SQL クエリ

- 必ずパラメータ化クエリを使用
- 文字列連結によるクエリ構築禁止
```
````

### 2. ESLint ルールの追加

`.eslintrc.js` に以下を追加することを推奨：

```javascript
rules: {
  'react-hooks/exhaustive-deps': 'error',
  '@typescript-eslint/no-explicit-any': 'error'
}
```

### 3. チーム教育

- SQL Injection 対策の勉強会を推奨
- React Hooks のベストプラクティス共有

## 学習ファイル作成

✅ learnings/security/sql-injection-prevention.md
✅ learnings/react/useeffect-best-practices.md
✅ learnings/typescript/avoiding-any-types.md

````

#### ステップ2: 継続的な品質向上

```bash
/review --fix --learn
````

### 期待される動作

1. レビュー実施
2. 自動修正
3. 学習データ記録
4. 改善提案の更新

### 所要時間

- レビュー & 学習: 3 〜 5 分
- 継続的改善: 2 〜 3 分

### ユースケース

- チーム全体のスキル向上
- プロジェクトルールの最適化
- 繰り返し発生する問題の削減

## 例4: CI 診断

### シナリオ

GitHub Actions CI が失敗しているので、原因を特定して修正したい。

### ワークフロー

#### ステップ1: CI 診断のみ

```bash
/review --fix-ci --dry-run
```

### 期待される出力

```markdown
# CI 診断結果

## PR 情報

- PR 番号: #123
- ブランチ: feature/new-api

## 失敗チェック

### 1. Lint Check (失敗)

- エラー: 15 件
- 主な問題:
  - unused variable: 8 件
  - missing type: 5 件
  - formatting: 2 件
- 影響ファイル:
  - src/api/users.ts
  - src/utils/helpers.ts

### 2. Test Check (失敗)

- エラー: 3 テスト失敗
- 主な問題:
  - TypeError: Cannot read property 'id' of undefined
- 影響ファイル:
  - tests/api/users.test.ts

### 3. Build Check (成功)

- 問題なし

## 修正計画

### Phase 1: Lint 修正 (10 分)

1. 未使用変数の削除 (8 箇所)
2. 型注釈の追加 (5 箇所)
3. フォーマット実行 (2 箇所)

### Phase 2: Test 修正 (20 分)

1. null/undefined チェック追加
2. テストデータの修正

## 推奨スキル

- typescript: 型安全性の改善
- testing: テスト修正パターン

## 次のステップ

1. ドライランを確認
2. 実際の修正: /review --fix-ci 123
```

#### ステップ2: PR 番号指定で診断・修正

```bash
/review --fix-ci 123
```

### 期待される動作

1. CI 失敗ログを取得
2. 失敗分類とエラーログ解析
3. 自動修正実行
4. lint/test を実行して検証
5. 修正完了を報告

### 期待される出力

```markdown
# CI 修正完了

## 修正結果

### Lint 修正

✅ src/api/users.ts: 未使用変数 8 件削除
✅ src/utils/helpers.ts: 型注釈 5 件追加
✅ フォーマット実行: 2 ファイル

### Test 修正

✅ tests/api/users.test.ts: null チェック追加
✅ テストデータ修正: 3 箇所

## 品質保証

✅ Lint: 成功
✅ Test: 成功
✅ Build: 成功

## 次のステップ

1. コミット: git commit -m "Fix CI issues"
2. プッシュ: git push
3. CI 再実行を確認
```

### 所要時間

- CI 診断: 1 〜 2 分
- 修正実行: 2 〜 5 分

### ユースケース

- CI 失敗時の迅速な修正
- 自動修正可能な問題の処理
- CI ログの分析

## 例5: CI 診断 + PRコメント修正

### シナリオ

CI が失敗し、PR にレビューコメントも多数ついているので、両方を一度に修正したい。

### ワークフロー

#### ステップ1: 両方を一度に実行

```bash
/review --fix-ci --fix-pr
```

### 期待される出力

```markdown
# CI + PR コメント統合診断結果

## PR 情報

- PR 番号: #123
- ブランチ: feature/new-api

## CI 診断結果

### 失敗チェック

1. Lint Check (失敗): 15 件
2. Test Check (失敗): 3 テスト失敗

## PRコメント分類結果

### Critical (2 件)

1. [Security] SQL Injection risk
2. [Bug] Null pointer exception

### High (3 件)

1. [Performance] N+1 query
2. [Bug] Race condition
3. [Security] Missing auth check

## 統合修正計画

### Phase 1: Critical 問題（最優先）

1. [CI + PR] セキュリティ問題の修正 (30 分)
   - SQL Injection 修正
   - 認証チェック追加
2. [PR] Null pointer exception 修正 (15 分)

### Phase 2: High 問題（高優先度）

1. [CI] Test 修正 (20 分)
2. [PR] Performance 改善 (25 分)
3. [PR] Race condition 修正 (20 分)

### Phase 3: Medium/Low 問題（通常優先度）

1. [CI] Lint 修正 (10 分)
2. [PR] その他コメント対応 (30 分)

## 統合優先度

1. 🔴 Critical: CI 失敗 + セキュリティ
2. 🔴 Critical: PR コメント（バグ）
3. 🟡 High: CI 失敗 + テスト
4. 🟡 High: PR コメント（パフォーマンス、バグ）
5. 🟢 Medium/Low: Lint、スタイル

## 次のステップ

1. Phase 1 の修正を実行
2. Phase 2 の修正を実行
3. Phase 3 の修正を実行
4. 全体の品質保証
5. プッシュして CI 再実行
```

#### ステップ2: PR 番号を指定

```bash
/review --fix-ci 123 --fix-pr
```

### 期待される動作

1. 指定された PR の CI 失敗を診断
2. 同じ PR のレビューコメントを取得・分類
3. 統合修正計画を作成
4. 優先度順に自動修正実行
5. トラッキングドキュメント生成

### 期待される出力

```markdown
# CI + PR コメント修正完了

## 修正結果

### Phase 1: Critical 問題

✅ [CI + PR] SQL Injection 修正: src/api/users.ts
✅ [CI + PR] 認証チェック追加: src/api/posts.ts
✅ [PR] Null pointer exception 修正: src/utils/helpers.ts

### Phase 2: High 問題

✅ [CI] Test 修正: tests/api/users.test.ts
✅ [PR] N+1 クエリ修正: src/api/posts.ts
✅ [PR] Race condition 修正: src/utils/cache.ts

### Phase 3: Medium/Low 問題

✅ [CI] Lint 修正: 15 ファイル
✅ [PR] スタイル改善: 8 ファイル

## 品質保証

✅ Lint: 成功
✅ Test: 成功
✅ Build: 成功

## トラッキングドキュメント

✅ .review-tracking/pr-123-fixes.md

## 次のステップ

1. 修正内容を確認
2. コミット: git commit -m "Fix CI and PR review issues"
3. プッシュ: git push
4. CI 再実行とレビュー完了を確認
```

### 所要時間

- 統合診断: 2 〜 3 分
- 統合修正: 5 〜 10 分

### ユースケース

- CI 失敗 + PR レビューコメント多数
- 効率的な一括修正
- 統合的な問題解決

## まとめ

| ワークフロー         | 所要時間 | ユースケース                 | コマンド            |
| -------------------- | -------- | ---------------------------- | ------------------- |
| 日常的なレビュー     | 1-3 分   | コミット前のクイックチェック | `--simple --staged` |
| リリース前レビュー   | 8-15 分  | 徹底的なレビュー、影響分析   | `--branch develop`  |
| 学習と改善           | 5-8 分   | 継続的品質向上、パターン記録 | `--learn`           |
| CI 診断              | 3-7 分   | CI 失敗の迅速な修正          | `--fix-ci`          |
| CI + PR コメント修正 | 7-13 分  | 統合的な問題解決             | `--fix-ci --fix-pr` |
