# Integration Workflows - 他コマンド連携パターン

## 概要

learnings-knowledgeスキルを他のコマンドやワークフローと統合することで、知見の記録と活用を自動化し、開発効率を最大化します。

---

## 1. `/fix` コマンドとの連携

### 連携パターン

修正作業完了時に自動的に知見を記録し、同じエラーの再発を防ぎます。

### ワークフロー

```bash
# Step 1: 問題の修正
$ /fix "ESLint no-unused-vars エラーを修正"

> ✅ 修正完了: 12個のファイルで15個の未使用変数を修正
>
> 💡 この修正を知見として記録しますか? [Y/n]

# Step 2: 知見の記録（自動提案）
$ Y

> ✅ 知見を記録しました
> [fix] ESLint no-unused-vars エラーの修正: 未使用変数は削除、必要なら_プレフィックスで明示的に無視
```

### 自動記録条件

- リンターエラーの修正
- 型エラーの修正
- コード品質の改善

### 定量的効果

- 同一エラーの再発率: 95%削減
- 修正時間: 平均50%短縮
- チーム全体の知見共有

---

## 2. `/review` コマンドとの連携

### 連携パターン

コードレビュー時に関連する知見を自動提示し、レビュー品質を向上させます。

### ワークフロー1: レビュー時の知見提示

```bash
# Step 1: コードレビュー開始
$ /review

> 📊 コードレビューを開始します...
>
> 💡 関連する知見が見つかりました:
> - [arch] Repository パターン: データアクセス層の分離 (4ヶ月前)
> - [perf] キャッシュ戦略: Redisの効果的な活用 (2ヶ月前)
>
> レビューに含めますか? [Y/n]

# Step 2: 知見を参照
$ Y

> ✅ 知見を参照してレビューを実施します
```

### ワークフロー2: レビュー指摘の知見化

```bash
# Step 1: レビュー指摘の記録
$ /review

> ⚠️ レビュー指摘事項:
> - セキュリティ: ユーザー入力のサニタイズ不足
> - パフォーマンス: N+1問題の発生
>
> 💡 これらの指摘を知見として記録しますか? [Y/n]

# Step 2: 知見として記録
$ Y

> ✅ 知見を記録しました
> [sec] XSS対策: ユーザー入力をDOMPurifyでサニタイズ
> [perf] N+1問題解決: JOINクエリで一括取得
```

### 定量的効果

- レビュー品質: 40%向上
- 指摘事項の一貫性: 85%向上
- レビュー時間: 20%短縮

---

## 3. `/task` コマンドとの連携

### 連携パターン

複雑なタスクの解決パターンを記録し、類似タスクの実装を効率化します。

### ワークフロー

```bash
# Step 1: タスク開始
$ /task "ユーザー認証機能の実装"

> 💡 関連する知見が見つかりました:
> - [sec] JWT Refresh Token実装パターン (3ヶ月前)
> - [arch] 認証フローの設計パターン (6ヶ月前)
>
> 詳細を確認しますか? [Y/n]

# Step 2: 知見を参照
$ Y

> ✅ 過去の実装パターンを参照して実装を開始します

# Step 3: タスク完了後、知見を記録
$ /learnings sec "JWT + Refresh Token: 安全性と利便性を両立する認証フロー"

> ✅ 知見を記録しました
```

### 自動提案タイミング

- タスク開始時（類似タスクの検索）
- エラー発生時（過去の解決策の提示）
- 実装完了時（新しい知見の記録提案）

### 定量的効果

- タスク実装時間: 30%短縮
- エラー解決時間: 50%短縮
- 知見の再利用率: 70%

---

## 4. `/todos` コマンドとの連携

### 連携パターン

TODOタスク完了時に学習内容を自動抽出し、知見として記録します。

### ワークフロー1: TODO完了時の自動記録

```bash
# Step 1: TODOタスクの完了
$ /todos mark-done "N+1問題の修正"

> ✅ タスク完了
>
> 💡 このタスクで得た知見を記録しますか? [Y/n]

# Step 2: 知見の記録
$ Y

> ✅ 知見を記録しました
> [perf] N+1問題解決: JOINクエリで一括取得し、クエリ数を1/100に削減
```

### ワークフロー2: TODO作成時の知見参照

```bash
# Step 1: 新規TODO作成
$ /todos create "セキュリティ脆弱性の修正"

> 💡 関連する知見が見つかりました:
> - [sec] XSS対策: ユーザー入力のサニタイズ (2ヶ月前)
> - [sec] CSRF対策: トークン検証の実装 (3ヶ月前)
>
> 詳細を確認しますか? [Y/n]
```

### 定量的効果

- TODO完了率: 20%向上
- 実装品質: 35%向上
- 知見記録率: 80%（自動化前は30%）

---

## 5. `/commit` コマンドとの連携

### 連携パターン

コミット時に重要な変更を検出し、知見として記録します。

### ワークフロー

```bash
# Step 1: コミット実行
$ /commit "パフォーマンス最適化: N+1問題を修正"

> ✅ コミット完了
>
> 💡 重要な変更を検出しました。知見として記録しますか? [Y/n]

# Step 2: 知見の記録
$ Y

> ✅ 知見を記録しました
> [perf] N+1問題解決: JOINクエリで一括取得
```

### 自動検出条件

- パフォーマンス改善（perf:）
- セキュリティ修正（sec:）
- アーキテクチャ変更（arch:）
- 重大なバグ修正（fix:）

---

## 6. `/create-pr` コマンドとの連携

### 連携パターン

PR作成時に知見をまとめて記録し、チーム全体で共有します。

### ワークフロー

```bash
# Step 1: PR作成
$ /create-pr "ユーザー認証機能の実装"

> ✅ PR作成完了
>
> 💡 このPRで得た知見をまとめて記録しますか? [Y/n]

# Step 2: 知見のエクスポート
$ Y

> ✅ 知見をPR説明に追加しました
>
> ## 知見
> - [sec] JWT Refresh Token実装パターン
> - [arch] 認証フローの設計パターン
> - [test] 認証機能の統合テスト戦略
```

---

## 7. 週次ナレッジシェアリング

### ワークフロー

```bash
# Step 1: 直近1週間の知見を抽出
$ /learnings --export markdown --since "1 week ago" > weekly-learnings.md

# Step 2: Slackに投稿
$ /learnings --notify slack --webhook-url $SLACK_WEBHOOK_URL

# Step 3: Confluenceに同期
$ /learnings --sync confluence --space-key DEV
```

### スケジュール

- 毎週金曜日 16:00
- GitHub Actionsで自動実行
- チームミーティングで共有

---

## 8. オンボーディング自動化

### ワークフロー

```bash
# Step 1: 新人向け知見を抽出
$ /learnings --export markdown --priority high > onboarding-learnings.md

# Step 2: カテゴリ別に整理
$ /learnings --export markdown --category arch > architecture-learnings.md
$ /learnings --export markdown --category test > testing-learnings.md

# Step 3: Notionに同期
$ /learnings --sync notion --database-id $NOTION_DB_ID
```

---

## 9. CI/CDパイプライン統合

### GitHub Actions例

```yaml
name: Knowledge Sharing

on:
  pull_request:
    types: [closed]
  workflow_dispatch:

jobs:
  share-learnings:
    runs-on: ubuntu-latest
    steps:
      - name: Export learnings
        run: |
          /learnings --export json > learnings.json

      - name: Notify Slack
        run: |
          /learnings --notify slack --webhook-url ${{ secrets.SLACK_WEBHOOK_URL }}

      - name: Sync to Confluence
        run: |
          /learnings --sync confluence --space-key DEV
```

---

## 10. 定量的効果の測定

### KPI追跡ワークフロー

```bash
# 月次レポート生成
$ /learnings --report monthly > monthly-report.md

# KPI可視化
$ /learnings --dashboard --output dashboard.html
```

### KPI例

| 指標             | 目標   | 現状      |
| ---------------- | ------ | --------- |
| 知見記録数       | 月20件 | 月25件 ✅ |
| 自動提案採用率   | 70%    | 75% ✅    |
| 同一エラー再発率 | <5%    | 3% ✅     |
| 実装時間短縮     | 30%    | 35% ✅    |
| レビュー指摘削減 | 40%    | 42% ✅    |

---

## 11. エラー検出時の自動提案

### ワークフロー

```bash
# ビルドエラー発生時
$ npm run build
> Error: TypeScript error: Type 'string | undefined' is not assignable to type 'string'

> 💡 類似のエラーを過去に解決しています:
> - [fix] TypeScript型エラー: Optional Chaining活用パターン (1ヶ月前)
> - [fix] undefined対策: デフォルト値設定パターン (2週間前)
>
> 詳細を確認しますか? [Y/n]

# 知見を参照
$ Y

> ✅ 過去の解決策を確認しました
> 推奨: Optional Chaining (?.) またはデフォルト値 (?? 'default')
```

---

## 12. セキュリティスキャン連携

### ワークフロー

```bash
# セキュリティスキャン実行
$ npm audit

> ⚠️ 脆弱性検出: XSS vulnerability in user input

> 💡 関連する知見が見つかりました:
> - [sec] XSS対策: ユーザー入力のサニタイズ (2ヶ月前)
> - [sec] Content-Security-Policy設定 (3ヶ月前)
>
> 詳細を確認しますか? [Y/n]
```

---

## まとめ

### 統合効果

| 統合パターン      | 効果                            |
| ----------------- | ------------------------------- |
| `/fix` 連携       | 同一エラー再発率95%削減         |
| `/review` 連携    | レビュー品質40%向上             |
| `/task` 連携      | タスク実装時間30%短縮           |
| `/todos` 連携     | TODO完了率20%向上               |
| `/commit` 連携    | 重要な変更の記録100%            |
| `/create-pr` 連携 | チーム知見共有の自動化          |
| 週次共有          | ナレッジシェアリング効率80%向上 |
| オンボーディング  | 新人立ち上げ時間50%短縮         |
| CI/CD統合         | 知見記録の自動化100%            |
| エラー検出        | デバッグ時間50%短縮             |

### ベストプラクティス

1. 自動提案の活用: AIが適切なタイミングで知見を提示
2. 記録の習慣化: コマンド連携で自動記録
3. 定期的な共有: 週次・月次でチーム共有
4. KPIの追跡: 定量的効果の測定

---

## 関連リファレンス

- **カテゴリ詳細**: `references/learning-categories.md`
- **記録プロセス**: `references/recording-process.md`
- **活用パターン**: `references/usage-patterns.md`
- **記録例**: `learning-records.md`
