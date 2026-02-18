# ドキュメント戦略

ドキュメント管理における戦略的アプローチと構造化手法。

## Progressive Disclosure戦略

Progressive Disclosure（段階的開示）は、読者の理解レベルと目的に応じて情報を階層的に提供する手法です。

### 原則

1. コンテキストに応じた情報提供: 読者が必要とする情報だけを提示
2. 段階的な深化: 基礎 → 詳細 → 高度な内容へと自然に誘導
3. 認知負荷の軽減: 一度に提示する情報量を最適化
4. 発見可能性: 詳細情報への明確なパスを提供

### 3層アーキテクチャ

#### レイヤー1: 概要層（SKILL.md / README.md）

### 目的

### コンテンツ比率

### 含むべき内容

- 明確な目的と価値提案（2-3行）
- 主要機能の箇条書き（5-7項目）
- 基本的な使用例（1-2例）
- クイックスタートガイド
- 詳細ドキュメントへのリンク

### 例

```markdown
# Project Name

短い説明文（1-2行）

## 主要機能

- 機能1: 簡潔な説明
- 機能2: 簡潔な説明
- 機能3: 簡潔な説明

## クイックスタート

\`\`\`bash
npm install project-name
npm start
\`\`\`

詳細: [Getting Started Guide](docs/getting-started.md)
```

### 目標読了時間

#### レイヤー2: 詳細仕様層（references/ / docs/）

### 目的

### コンテンツ比率

### 含むべき内容

- 詳細なAPI仕様
- アーキテクチャ設計
- 実装ガイド
- 設定オプション詳細
- トラブルシューティング

### 構造例

```
references/
├── architecture.md        # システム設計
├── api-reference.md      # API詳細
├── configuration.md      # 設定詳細
├── implementation-guide.md  # 実装手順
└── troubleshooting.md    # 問題解決
```

### 目標読了時間

#### レイヤー3: 実用例層（examples/ / docs/examples/）

### 目的

### コンテンツ比率

### 含むべき内容

- プロジェクト固有の実装例
- ユースケース別ワークフロー
- パターンとアンチパターン
- 最適化テクニック
- 統合例

### 構造例

```
examples/
├── basic-usage/          # 基本的な使用例
├── advanced-patterns/    # 高度なパターン
├── integration-examples/ # 統合例
└── real-world-cases/     # 実際の事例
```

### 階層間ナビゲーション

### トップダウン

```markdown
## 詳細情報

- [API仕様](references/api-reference.md)
- [実装例](examples/basic-usage.md)
```

### ボトムアップ

```markdown
## 関連リソース

- [戻る: API仕様](../references/api-reference.md)
- [戻る: README](../README.md)
```

### クロスリファレンス

```markdown
## 関連トピック

- [関連する設定](./configuration.md)
- [アーキテクチャ設計](./architecture.md)
```

## 構造化アプローチ

### ドキュメント種別と役割

#### 1. README.md（エントリポイント）

### 目的

### 構造

```markdown
# Project Name

## 概要

[2-3行の簡潔な説明]

## 主要機能

[5-7項目の箇条書き]

## クイックスタート

[最小限のセットアップと実行例]

## ドキュメント

[詳細ドキュメントへのリンク]

## ライセンス

[ライセンス情報]
```

### 推奨長

#### 2. CHANGELOG.md（変更履歴）

### 目的

### 構造

```markdown
# Changelog

## [Unreleased]

### Added

- 新機能

### Changed

- 変更点

### Fixed

- 修正内容

## [1.0.0] - 2024-01-15

### Added

- 初回リリース機能
```

### 原則

- [Keep a Changelog](https://keepachangelog.com/)に従う
- セマンティックバージョニング（SemVer）を使用
- 各エントリに日付を記載
- Added/Changed/Deprecated/Removed/Fixed/Securityで分類

#### 3. CONTRIBUTING.md（コントリビューションガイド）

### 目的

### 構造

```markdown
# Contributing

## Development Setup

[開発環境のセットアップ]

## Code Style

[コーディング規約]

## Testing

[テスト実行方法]

## Submission Guidelines

[プルリクエストのガイドライン]
```

#### 4. docs/（詳細ドキュメント）

### 推奨構造

```
docs/
├── getting-started.md      # 初学者向けガイド
├── guides/                 # チュートリアル
│   ├── installation.md
│   ├── configuration.md
│   └── deployment.md
├── api/                    # APIリファレンス
│   ├── endpoints.md
│   └── authentication.md
├── architecture/           # アーキテクチャ
│   ├── overview.md
│   └── components.md
├── examples/               # 実用例
│   └── use-cases/
└── reference/              # リファレンス
    ├── configuration.md
    └── cli.md
```

### ドキュメントタイプ別ガイドライン

#### チュートリアル（guides/）

### 特徴

### 構造

1. 目標の明示
2. 前提条件
3. ステップごとの手順
4. 検証ポイント
5. 次のステップへのリンク

### 例

```markdown
# Installation Guide

## Goal

このガイドでは、プロジェクトをローカル環境にインストールする方法を学びます。

## Prerequisites

- Node.js 18+
- npm 8+

## Steps

### 1. Install dependencies

\`\`\`bash
npm install
\`\`\`

### 2. Configure environment

\`\`\`bash
cp .env.example .env
\`\`\`

### 3. Start development server

\`\`\`bash
npm run dev
\`\`\`

## Verification

ブラウザで http://localhost:3000 にアクセスし、正常に起動することを確認してください。

## Next Steps

- [Configuration Guide](./configuration.md)
- [API Documentation](../api/endpoints.md)
```

#### ハウツーガイド（guides/）

### 特徴

### 構造

1. 問題/タスクの説明
2. 解決方法
3. コード例
4. 注意点

### 例

```markdown
# How to Configure Authentication

## Problem

APIにアクセスするための認証を設定する必要があります。

## Solution

### 1. Generate API key

\`\`\`bash
npm run generate-key
\`\`\`

### 2. Add to environment

\`\`\`bash
echo "API_KEY=your_key_here" >> .env
\`\`\`

### 3. Use in code

\`\`\`javascript
import { authenticate } from './auth';

const client = authenticate(process.env.API_KEY);
\`\`\`

## Notes

- API keyは.gitignoreに追加されたファイルに保存してください
- 本番環境では環境変数を使用してください
```

#### リファレンス（reference/）

### 特徴

### 構造

1. 概要
2. パラメータ/オプション一覧
3. 詳細説明
4. 例

### 例

```markdown
# Configuration Reference

## Overview

すべての設定オプションの完全なリファレンス。

## Options

### `server`

- **Type**: `object`
- **Required**: Yes
- **Description**: サーバー設定

#### `server.port`

- **Type**: `number`
- **Default**: `3000`
- **Description**: サーバーポート番号

### `database`

- **Type**: `object`
- **Required**: Yes
- **Description**: データベース設定

## Example

\`\`\`json
{
"server": {
"port": 8080
},
"database": {
"host": "localhost",
"port": 5432
}
}
\`\`\`
```

#### 説明（architecture/）

### 特徴

### 構造

1. 概念の紹介
2. なぜそのように設計されているか
3. コンポーネント間の関係
4. トレードオフ

### 例

```markdown
# Architecture Overview

## System Design

本プロジェクトは3層アーキテクチャを採用しています。

### Presentation Layer

ユーザーインターフェースを担当。React + TypeScriptで実装。

### Business Logic Layer

ビジネスロジックを実装。Domain-Driven Designパターンを採用。

### Data Layer

データ永続化を担当。PostgreSQL + Prismaで実装。

## Design Decisions

### Why 3-tier architecture?

- **関心の分離**: 各層が独立した責務を持つ
- **テスト容易性**: 層ごとに独立してテスト可能
- **拡張性**: 層単位での置き換えが可能

### Trade-offs

- **利点**: 保守性、テスト容易性、拡張性
- **欠点**: 初期の複雑性、小規模プロジェクトではオーバーヘッド
```

## セクション標準化

### 共通セクション構造

すべてのドキュメントに含めるべき標準セクション:

```markdown
# Title

## Overview

[2-3段落の概要]

## Table of Contents

[自動生成または手動リンク]

## [Main Content]

[メインコンテンツ]

## Related Documentation

[関連ドキュメントへのリンク]

## Additional Resources

[外部リソースへのリンク]

## Feedback

[フィードバック方法]
```

### セクション命名規則

### 統一された命名

- `Overview` / `概要`: 導入と概要
- `Prerequisites` / `前提条件`: 必要な前提知識
- `Installation` / `インストール`: インストール手順
- `Configuration` / `設定`: 設定方法
- `Usage` / `使用方法`: 基本的な使い方
- `Examples` / `例`: 具体例
- `API Reference` / `APIリファレンス`: API詳細
- `Troubleshooting` / `トラブルシューティング`: 問題解決
- `FAQ` / `よくある質問`: よくある質問と回答
- `Contributing` / `コントリビューション`: 貢献方法
- `License` / `ライセンス`: ライセンス情報

### 見出しレベルの使い方

```markdown
# H1: ドキュメントタイトル（1つのみ）

## H2: 主要セクション

### H3: サブセクション

#### H4: 詳細項目

##### H5: 補足項目（可能な限り避ける）
```

### 原則

- H1は1つのみ（ドキュメントタイトル）
- 見出しレベルをスキップしない（H2 → H4は避ける）
- H5以降は可能な限り避ける（ドキュメント分割を検討）

## ドキュメントメンテナンス

### 更新トリガー

ドキュメント更新が必要なタイミング:

1. 新機能追加
   - README.mdの機能一覧
   - API documentationの新エンドポイント
   - CHANGELOG.mdのAddedセクション

2. 既存機能変更
   - 影響を受けるすべてのドキュメント
   - CHANGELOG.mdのChangedセクション
   - Migration guideが必要な場合

3. バグ修正
   - CHANGELOG.mdのFixedセクション
   - Troubleshooting guide（該当する場合）

4. 廃止予定機能
   - CHANGELOG.mdのDeprecatedセクション
   - Migration guide

5. 機能削除
   - 関連ドキュメントの削除または更新
   - CHANGELOG.mdのRemovedセクション

### 鮮度チェック

### 定期レビュー項目

- [ ] READMEの機能一覧は最新か
- [ ] APIドキュメントは現在のコードと一致するか
- [ ] インストール手順は正確か
- [ ] 設定オプションは完全か
- [ ] 例は動作するか
- [ ] リンクは切れていないか
- [ ] 依存関係のバージョンは最新か

### ステール判定基準

- コミット後90日以上更新されていない
- 参照している機能が変更されている
- 報告された問題が未対応

### カスタムコンテンツ保護

ユーザーが手動で追加したコンテンツを保護するマーカー:

```markdown
<!-- CUSTOM:START -->

この部分はユーザーが手動で追加した内容です。
自動更新時もこのセクションは保持されます。

<!-- CUSTOM:END -->
```

### 使用場面

- プロジェクト固有の注意事項
- 社内向け情報
- カスタマイズされた手順

## 品質基準

### ドキュメント品質チェックリスト

### 明確性

- [ ] 目的が明確に記述されている
- [ ] ターゲット読者が明示されている
- [ ] 専門用語が適切に説明されている

### 完全性

- [ ] すべての主要機能がドキュメント化されている
- [ ] コード例が動作する
- [ ] エラーハンドリングが説明されている

### 正確性

- [ ] コードと一致している
- [ ] 最新バージョンに対応している
- [ ] 例が検証されている

### 使いやすさ

- [ ] 適切な見出し構造
- [ ] 目次が提供されている
- [ ] 関連ドキュメントへのリンク

### 一貫性

- [ ] 用語が統一されている
- [ ] フォーマットが統一されている
- [ ] トーンが一貫している

### ライティングガイドライン

### スタイル

- 簡潔で明確な文章
- アクティブボイス（能動態）を優先
- 現在形を使用
- 短い段落（3-5文）

### 例

```markdown
❌ The server can be started by running the command.
✅ Run the command to start the server.

❌ It is recommended that users should configure...
✅ Configure the settings before starting.
```

### 用語の一貫性

- プロジェクト固有の用語は最初に定義
- 同じ概念には同じ用語を使用
- 略語は初出時に展開

### コード例の品質

- 実行可能な完全な例
- コメントで重要な部分を説明
- エラーハンドリングを含む
- 出力例を提供

```markdown
✅ 良い例:
\`\`\`javascript
// APIクライアントを初期化
const client = new ApiClient({
apiKey: process.env.API_KEY
});

try {
// データを取得
const data = await client.fetchData();
console.log(data); // { items: [...], total: 100 }
} catch (error) {
console.error('Failed to fetch data:', error);
}
\`\`\`

❌ 悪い例:
\`\`\`javascript
const client = new ApiClient();
const data = client.fetchData();
\`\`\`
```

## ツールとオートメーション

### 自動生成の活用

### 適切な自動生成

- API仕様からのAPIドキュメント生成
- テストからの使用例生成
- 型定義からのパラメータドキュメント
- 目次の自動生成

### 手動維持が必要

- アーキテクチャ説明
- デザイン決定の理由
- チュートリアル
- トラブルシューティングガイド

### バージョン管理

### ドキュメントのバージョニング

- コードとドキュメントを同じリポジトリで管理
- ブランチごとにドキュメントを維持
- メジャーバージョンごとにドキュメントを分岐

### 例

```
docs/
├── v1/           # Version 1.x documentation
├── v2/           # Version 2.x documentation
└── latest/       # Latest version (symlink to current)
```

## まとめ

Progressive Disclosure戦略により:

- 読者: 必要な情報に迅速にアクセス
- 貢献者: 詳細な実装ガイドを参照
- メンテナー: 体系的なドキュメント更新

構造化アプローチにより:

- 一貫性: 予測可能なドキュメント構造
- 発見可能性: 情報が見つけやすい
- 保守性: 更新が容易

この戦略を適用することで、トークン効率を保ちながら包括的なドキュメントを提供できます。
