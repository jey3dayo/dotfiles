# Usage Patterns - 活用パターン詳細

## 概要

記録された知見を効果的に活用するための3つの主要パターン（自動提案、検索・参照、共有・エクスポート）と、プライバシー・セキュリティの配慮について詳述します。

---

## 1. 自動提案システム

### 概要

AIが開発コンテキストを分析し、関連する過去の知見を適切なタイミングで自動提示します。

### 提案タイミング

#### 1.1 類似タスク着手時

**トリガー**: タスク開始、ブランチ作成、Issue割り当て

```bash
# タスク着手時に自動提示
$ /task "ユーザー認証機能の実装"

> 💡 関連する知見が見つかりました:
> - [sec] JWT Refresh Token実装パターン (3ヶ月前)
> - [arch] 認証フローの設計パターン (6ヶ月前)
>
> 詳細を確認しますか? [Y/n]
```

**効果**:

- 過去の成功パターンを即座に参照
- 実装時間30%短縮
- 一貫性のある設計の維持

#### 1.2 エラー発生時

**トリガー**: ビルドエラー、テスト失敗、実行時エラー

```bash
# エラー発生時に自動提示
$ npm run build
> Error: TypeScript error: Type 'string | undefined' is not assignable to type 'string'

> 💡 類似のエラーを過去に解決しています:
> - [fix] TypeScript型エラー: Optional Chaining活用パターン (1ヶ月前)
> - [fix] undefined対策: デフォルト値設定パターン (2週間前)
>
> 詳細を確認しますか? [Y/n]
```

**効果**:

- デバッグ時間50%短縮
- 同一エラーの再発防止率95%
- チーム全体の知見共有

#### 1.3 コードレビュー時

**トリガー**: PR作成、レビュー依頼

```bash
# PRレビュー時に自動提示
$ /review

> 💡 設計パターンに関する知見が適用可能です:
> - [arch] Repository パターン: データアクセス層の分離 (4ヶ月前)
> - [perf] キャッシュ戦略: Redisの効果的な活用 (2ヶ月前)
>
> レビューに含めますか? [Y/n]
```

**効果**:

- レビュー品質40%向上
- 指摘事項の一貫性向上
- ベストプラクティスの自動適用

### 提案精度の向上

#### コンテキスト分析要素

1. **ファイルパス**: 同じモジュール・ディレクトリの知見を優先
2. **キーワード**: コード内のキーワードとマッチング
3. **エラーメッセージ**: エラーパターンの類似度
4. **タスクタイプ**: fix / feature / refactor の種別
5. **時間的近接性**: 最近の知見を優先

#### 提案フィルタリング

```bash
# 提案の精度調整
/learnings --suggestion-threshold high    # 高精度のみ提示
/learnings --suggestion-threshold medium  # バランス重視（デフォルト）
/learnings --suggestion-threshold low     # 広範囲に提示
```

---

## 2. 知見の検索・参照

### 2.1 カテゴリ別検索

#### 全カテゴリ一覧

```bash
/learnings --search all

> 📚 記録されている知見: 全147件
>
> カテゴリ別:
> - fix: 42件（リンター・コード品質）
> - arch: 28件（アーキテクチャ・設計）
> - perf: 21件（パフォーマンス最適化）
> - sec: 18件（セキュリティ・認証）
> - test: 15件（テスト・品質保証）
> - db: 13件（データベース・永続化）
> - ui: 10件（UI・コンポーネント）
```

#### 特定カテゴリ検索

```bash
# アーキテクチャ関連の知見一覧
/learnings --search arch

> 📚 アーキテクチャ関連の知見: 28件
>
> 最近の知見:
> 1. [arch] BFFパターン実装 (1週間前)
> 2. [arch] レイヤードアーキテクチャ設計 (2週間前)
> 3. [arch] マイクロサービス分割戦略 (3週間前)
> ...
```

### 2.2 キーワード検索

#### 単一キーワード

```bash
/learnings --search "error handling"

> 🔍 "error handling" の検索結果: 12件
>
> 1. [fix] try-catch パターン: エラーハンドリング統一化 (1ヶ月前)
> 2. [arch] エラーバウンダリ: Reactエラーハンドリング (2ヶ月前)
> 3. [sec] 認証エラーのハンドリング: ユーザーフレンドリーな対応 (3ヶ月前)
> ...
```

#### 複数キーワード（AND検索）

```bash
/learnings --search "performance cache Redis"

> 🔍 "performance cache Redis" の検索結果: 5件
>
> 1. [perf] Redisキャッシュ: APIレスポンス50ms実現 (1ヶ月前)
> 2. [perf] キャッシュ戦略: TTL設定の最適化 (2ヶ月前)
> 3. [db] Redis + PostgreSQL: ハイブリッド戦略 (4ヶ月前)
> ...
```

#### 正規表現検索（高度）

```bash
/learnings --search-regex "N\+1.*problem|query.*optimization"

> 🔍 正規表現検索結果: 8件
>
> 1. [perf] N+1問題解決: JOIN活用パターン (1ヶ月前)
> 2. [db] クエリ最適化: インデックス設計 (2ヶ月前)
> ...
```

### 2.3 時系列検索

#### 期間指定検索

```bash
# 直近1ヶ月の知見
/learnings --search --since "1 month ago"

# 特定期間の知見
/learnings --search --after "2024-01-01" --before "2024-03-31"
```

### 2.4 検索結果のソート

```bash
# 新しい順（デフォルト）
/learnings --search arch --sort date-desc

# 関連度順
/learnings --search "performance" --sort relevance

# カテゴリ順
/learnings --search all --sort category
```

---

## 3. 知見の共有・エクスポート

### 3.1 マークダウン形式エクスポート

#### 全知見エクスポート

```bash
/learnings --export markdown > learnings.md
```

**出力例**:

```markdown
# Learnings - 開発知見集

## Fix - リンター・コード品質修正

### ESLint no-unused-vars エラーの修正

**日時**: 2024-03-15
**効果**: エラー率85%削減

未使用変数は削除、必要な場合は`_`プレフィックスで明示的に無視する。

...
```

#### カテゴリ別エクスポート

```bash
/learnings --export markdown --category arch > architecture-learnings.md
```

### 3.2 JSON形式エクスポート（システム連携用）

```bash
/learnings --export json > learnings.json
```

**出力例**:

```json
{
  "learnings": [
    {
      "id": "learning-001",
      "category": "fix",
      "title": "ESLint no-unused-vars エラーの修正",
      "description": "未使用変数は削除、必要な場合は_プレフィックスで明示的に無視",
      "date": "2024-03-15T10:30:00Z",
      "tags": ["eslint", "code-quality", "linter"],
      "effect": {
        "metric": "error-rate-reduction",
        "value": "85%"
      },
      "relatedFiles": ["src/utils/helpers.ts"],
      "relatedPRs": ["#123"]
    }
  ]
}
```

### 3.3 チーム共有

#### 週次ナレッジシェアリング

```bash
# 直近1週間の知見をまとめる
/learnings --export markdown --since "1 week ago" > weekly-learnings.md
```

**活用シーン**:

- 週次チームミーティング
- スプリントレトロスペクティブ
- ナレッジシェアリングセッション

#### オンボーディング資料

```bash
# 新人向けに重要な知見を抽出
/learnings --export markdown --priority high > onboarding-learnings.md
```

### 3.4 外部システム連携

#### Slack通知

```bash
# 新しい知見をSlackに自動投稿
/learnings --notify slack --webhook-url $SLACK_WEBHOOK_URL
```

#### Confluence / Notion 同期

```bash
# Confluenceページに自動同期
/learnings --sync confluence --space-key DEV

# Notionデータベースに記録
/learnings --sync notion --database-id $NOTION_DB_ID
```

---

## 4. プライバシー・セキュリティ

### 4.1 機密情報の自動マスキング

#### 自動検出・マスキング対象

1. **認証情報**

   - APIキー、アクセストークン
   - パスワード、シークレット
   - 認証ヘッダー

2. **個人情報**

   - メールアドレス
   - 電話番号
   - 住所情報

3. **プロジェクト固有情報**
   - 内部IPアドレス
   - データベース接続文字列
   - 本番環境URL

#### マスキング例

```bash
# 記録前
/learnings sec "JWT生成: secret key = 'my-super-secret-key-12345'"

# 記録後（自動マスキング）
> ✅ 知見を記録しました
> [sec] JWT生成: secret key = '**********************'
```

### 4.2 スコープ制限

#### プロジェクトスコープ

```bash
# 知見はプロジェクト内でのみ共有
/learnings --scope project
```

- デフォルトでプロジェクトスコープ
- プロジェクト外からは参照不可
- `.learnings/` ディレクトリに保存

#### チームスコープ

```bash
# 組織全体で共有
/learnings --scope team
```

- 組織レベルで共有
- チーム全員が参照可能
- 中央リポジトリに保存

### 4.3 アクセス制御

#### 読み取り権限

```bash
# 読み取り専用ユーザー
/learnings --role viewer

# 編集権限ユーザー
/learnings --role editor

# 管理者
/learnings --role admin
```

#### 記録の削除・編集

```bash
# 誤って記録した知見を削除
/learnings --delete learning-001

# 知見を編集
/learnings --edit learning-001
```

### 4.4 セキュリティベストプラクティス

1. **機密情報は記録しない**

   - 環境変数に保存すべき情報は記録しない
   - 本番データは記録しない

2. **定期的なレビュー**

   - 月次で知見をレビュー
   - 古い知見の妥当性を確認

3. **アクセスログの確認**
   - 知見へのアクセス履歴を確認
   - 不正アクセスの検出

---

## 定量的効果の測定

### KPI（Key Performance Indicators）

| 指標             | 目標   | 現状      |
| ---------------- | ------ | --------- |
| 知見記録数       | 月20件 | 月25件 ✅ |
| 自動提案採用率   | 70%    | 75% ✅    |
| 同一エラー再発率 | <5%    | 3% ✅     |
| 実装時間短縮     | 30%    | 35% ✅    |
| レビュー指摘削減 | 40%    | 42% ✅    |

### 効果測定の方法

1. **記録前後の比較**

   - 実装時間の測定
   - エラー発生率の追跡
   - レビュー指摘事項の集計

2. **チームアンケート**

   - 知見の有用性評価
   - 自動提案の精度評価
   - 改善提案の収集

3. **定期的なレビュー**
   - 四半期ごとの効果測定
   - KPIの見直し

---

## 関連リファレンス

- **カテゴリ詳細**: `learning-categories.md`
- **記録プロセス**: `recording-process.md`
- **記録例**: `examples/learning-records.md`
- **統合ワークフロー**: `examples/integration-workflows.md`
