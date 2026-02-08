# cc-sdd コマンドリファレンス

このドキュメントは、cc-sdd で利用可能なすべてのコマンドの簡潔なリファレンスです。

## Steeringコマンド

### `/kiro:steering`

**目的**: コアステアリングファイルを作成または更新

**使用タイミング**:

- プロジェクト初期設定時
- 重要な技術変更後
- アーキテクチャの大幅な変更後

**処理内容**:

- `product.md` - プロダクトコンテキストとビジネス目標
- `tech.md` - テクノロジースタックと技術的決定
- `structure.md` - ファイル構成とコードパターン

**動作**:

- 新規ファイル: 包括的な初期コンテンツを生成
- 既存ファイル: ユーザーのカスタマイズを保持しつつ事実情報を更新

**出力先**: `.kiro/steering/`

**例**:

```
/kiro:steering
```

---

### `/kiro:steering-custom`

**目的**: カスタムステアリングファイルを作成

**使用タイミング**:

- 専門的なコンテキスト（API、テスト、セキュリティなど）が必要な時
- プロジェクト固有のガイドラインを追加したい時

**対話的プロセス**:

1. ドキュメント名の入力
2. トピック/目的の説明
3. インクルージョンモードの選択（Always/Conditional/Manual）
4. Conditionalの場合、ファイルパターンの指定

**一般的な用途**:

- `api-standards.md` - API規約
- `testing.md` - テストアプローチ
- `security.md` - セキュリティポリシー
- `database.md` - データベース規約
- `performance.md` - パフォーマンス基準

**出力先**: `.kiro/steering/[custom-name].md`

**例**:

```
/kiro:steering-custom
```

---

## Specificationコマンド

### `/kiro:spec-init [詳細な説明]`

**目的**: 新しい仕様の初期化

**引数**:

- `[詳細な説明]` - プロジェクトの詳細な説明（必須）

**処理内容**:

1. プロジェクト説明から機能名を生成
2. `.kiro/specs/[feature-name]/` ディレクトリを作成
3. `spec.json` メタデータファイルを作成
4. `requirements.md` テンプレートを作成

**次のステップ**: `/kiro:spec-requirements [feature-name]`

**例**:

```
/kiro:spec-init ユーザー認証機能の追加。メール/パスワード認証、JWT トークン、セッション管理を含む
```

---

### `/kiro:spec-requirements [feature-name]`

**目的**: 要件定義ドキュメントの生成

**引数**:

- `[feature-name]` - 機能名（spec-init で生成されたもの）

**処理内容**:

1. プロジェクト説明とステアリングコンテキストを読み込み
2. EARS形式の要件定義を生成
3. ユーザーとイテレーションして要件を完成

**生成内容**:

- 機能概要とビジネス価値
- ユーザーストーリー
- EARS形式の受入基準
- 機能要件と非機能要件

**次のステップ**: 要件をレビュー後、`/kiro:spec-design [feature-name] -y`

**例**:

```
/kiro:spec-requirements user-authentication
```

---

### `/kiro:spec-design [feature-name] [-y]`

**目的**: 技術設計ドキュメントの作成

**引数**:

- `[feature-name]` - 機能名（必須）
- `[-y]` - 要件を自動承認（オプショナル）

**前提条件**:

- 要件が承認済みであること（または `-y` フラグ使用）

**ファイル処理**:

- design.md が存在しない: 新規作成
- design.md が存在する: [o]verwrite/[m]erge/[c]ancel の選択

**処理内容**:

1. 発見と分析フェーズ（要件マッピング、既存実装分析、技術調査）
2. 設計ドキュメント生成（アーキテクチャ、コンポーネント、データモデル）

**次のステップ**: 設計をレビュー後、`/kiro:spec-tasks [feature-name] -y`

**例**:

```
/kiro:spec-design user-authentication
/kiro:spec-design user-authentication -y   # 要件を自動承認
```

---

### `/kiro:spec-tasks [feature-name] [-y]`

**目的**: 実装タスクの生成

**引数**:

- `[feature-name]` - 機能名（必須）
- `[-y]` - 要件と設計を自動承認（オプショナル）

**前提条件**:

- 要件と設計が承認済みであること（または `-y` フラグ使用）

**ファイル処理**:

- tasks.md が存在しない: 新規作成
- tasks.md が存在する: [o]verwrite/[m]erge/[c]ancel の選択

**処理内容**:

1. 要件、設計、ステアリングを読み込み
2. 実装タスクを生成（自然言語、適切なサイズ、要件マッピング）
3. すべての要件がカバーされていることを確認

**タスクルール**:

- メジャータスク: 1, 2, 3...（連番）
- サブタスク: 1.1, 1.2, 2.1, 2.2...
- 最大2レベルの階層
- 各サブタスク: 1-3時間

**次のステップ**: タスクをレビュー後、実装を開始

**例**:

```
/kiro:spec-tasks user-authentication
/kiro:spec-tasks user-authentication -y   # 要件と設計を自動承認
```

---

### `/kiro:spec-status [feature-name]`

**目的**: 仕様の現在のステータスと進捗を表示

**引数**:

- `[feature-name]` - 機能名（必須）

**表示内容**:

1. 仕様概要（機能名、作成日、フェーズ、完了率）
2. フェーズステータス（Requirements/Design/Tasks の完了状況）
3. 実装進捗（タスク完了内訳、ブロッカー、推定時間）
4. 品質メトリクス（要件カバレッジ、設計完全性）
5. 推奨事項（次のステップ、潜在的な問題）
6. ステアリング整合性（アーキテクチャ、技術スタック）

**使用タイミング**:

- 進捗を確認したい時
- 次のアクションを決定したい時
- 品質をチェックしたい時

**例**:

```
/kiro:spec-status user-authentication
```

---

## 検証コマンド

### `/kiro:validate-gap [feature-name]`

**目的**: 要件と既存コードベース間の実装ギャップを分析

**引数**:

- `[feature-name]` - 機能名（必須）

**処理内容**:

1. 現在の状態調査（既存コードベース分析）
2. 要件実現可能性分析
3. 実装アプローチオプション（拡張/新規/ハイブリッド）
4. 技術調査要件（外部依存関係、未知の技術）
5. 実装複雑度評価（S/M/L/XL）

**出力**:

- 分析サマリー
- 既存コードベースの洞察
- 実装戦略オプション
- 技術調査ニーズ
- 設計フェーズへの推奨事項

**使用タイミング**:

- 要件生成後、設計前
- 実装アプローチを決定したい時

**次のステップ**: `/kiro:spec-design [feature-name]`

**例**:

```
/kiro:validate-gap user-authentication
```

---

### `/kiro:validate-design [feature-name]`

**目的**: 設計ドキュメントの検証

**引数**:

- `[feature-name]` - 機能名（必須）

**処理内容**:
設計ドキュメントを検証し、品質、完全性、整合性をチェック

**使用タイミング**:

- 設計生成後
- タスク生成前
- 設計の品質を確認したい時

**例**:

```
/kiro:validate-design user-authentication
```

---

## コマンド使用パターン

### 基本的なワークフロー

```bash
# 1. ステアリング作成（オプショナル、新規プロジェクトや大規模変更時）
/kiro:steering

# 2. 仕様初期化
/kiro:spec-init [詳細な説明]

# 3. 要件生成
/kiro:spec-requirements [feature-name]

# 4. 設計生成（要件承認後）
/kiro:spec-design [feature-name] -y

# 5. タスク生成（設計承認後）
/kiro:spec-tasks [feature-name] -y

# 6. 進捗確認
/kiro:spec-status [feature-name]
```

### 高速ワークフロー（自動承認使用）

```bash
# 仕様初期化
/kiro:spec-init [詳細な説明]

# 要件生成とレビュー
/kiro:spec-requirements [feature-name]
# ※ レビューして問題なければ次へ

# 設計生成（要件を自動承認）
/kiro:spec-design [feature-name] -y
# ※ レビューして問題なければ次へ

# タスク生成（要件と設計を自動承認）
/kiro:spec-tasks [feature-name] -y
# ※ レビューして問題なければ実装開始
```

### カスタムステアリング追加

```bash
# カスタムステアリング作成
/kiro:steering-custom
# ※ 対話的に名前、モード、パターンを指定

# 例: APIガイドライン追加後
/kiro:spec-init API認証機能の追加
/kiro:spec-requirements api-auth
# ※ api-standards.md が自動的に読み込まれる（Conditional設定の場合）
```

### ギャップ分析を含むワークフロー

```bash
# 要件生成
/kiro:spec-requirements [feature-name]

# ギャップ分析
/kiro:validate-gap [feature-name]
# ※ 実装アプローチを確認

# 設計生成（分析結果を踏まえて）
/kiro:spec-design [feature-name] -y

# 設計検証
/kiro:validate-design [feature-name]

# タスク生成
/kiro:spec-tasks [feature-name] -y
```

---

## トラブルシューティング

### 要件が不明確な場合

```bash
# 要件を再生成
/kiro:spec-requirements [feature-name]
# ※ より詳細な情報を提供して再生成
```

### 設計が複雑すぎる場合

```bash
# ギャップ分析で確認
/kiro:validate-gap [feature-name]

# 機能を分割することを検討
/kiro:spec-init [小さな機能1の説明]
/kiro:spec-init [小さな機能2の説明]
```

### タスクが大きすぎる場合

```bash
# タスクを再生成（より細かく）
/kiro:spec-tasks [feature-name]
# ※ より細かいサブタスクへの分割を要求
```

---

## コマンド実行のベストプラクティス

1. **ステアリング**: プロジェクト開始時または大規模変更時に実行
2. **要件レビュー**: 生成された要件を必ずレビュー
3. **設計レビュー**: アーキテクチャと技術選択を検証
4. **タスクレビュー**: タスクサイズと依存関係を確認
5. **進捗追跡**: 定期的に spec-status で確認
6. **ステータス更新**: tasks.md のチェックボックスを更新

---

## まとめ

cc-sdd コマンドは、要件定義から設計、実装タスクまでの一貫したワークフローを提供します。各コマンドを適切なタイミングで使用し、各フェーズでレビューと承認を行うことで、品質の高い開発プロセスを実現できます。

詳細なワークフローや概念については、他のリファレンスドキュメントを参照してください：

- `@workflow.md` - 完全なワークフロー詳細
- `@steering-system.md` - Steeringシステムの詳細
- `@specification-system.md` - Specificationシステムの詳細
