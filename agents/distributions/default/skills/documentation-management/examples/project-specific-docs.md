# プロジェクト固有ドキュメント

プロジェクトタイプ別のドキュメント作成例。

## React Application

### 推奨ドキュメント構成

```
docs/
├── getting-started.md      # 開発環境セットアップ
├── components/             # コンポーネントドキュメント
│   ├── overview.md
│   └── button.md
├── state-management.md     # 状態管理
├── styling.md              # スタイリングガイド
└── testing.md              # テストガイド
```

### コンポーネントドキュメント例

```markdown
# Button Component

シンプルで再利用可能なボタンコンポーネント。

## Usage

\`\`\`tsx
import { Button } from '@/components/Button';

<Button variant="primary" onClick={handleClick}>
  Click me
</Button>
\`\`\`

## Props

| Prop    | Type                     | Default   | Description      |
| ------- | ------------------------ | --------- | ---------------- |
| variant | 'primary' \| 'secondary' | 'primary' | ボタンスタイル   |
| onClick | () => void               | -         | クリックハンドラ |
```

## Node.js API

### 推奨ドキュメント構成

```
docs/
├── api/                    # APIリファレンス
│   ├── endpoints.md
│   └── authentication.md
├── database/               # データベース
│   └── schema.md
└── deployment.md           # デプロイガイド
```

### APIエンドポイント例

```markdown
# API Endpoints

## GET /users

ユーザー一覧を取得。

### Parameters

- `page` (number, optional): ページ番号
- `limit` (number, optional): 取得件数

### Response

\`\`\`json
{
"users": [...],
"total": 100
}
\`\`\`
```

## CLI Tool

### 推奨ドキュメント構成

```
docs/
├── commands/               # コマンドリファレンス
│   ├── init.md
│   └── deploy.md
├── configuration.md        # 設定
└── examples.md             # 使用例
```

## Library/Framework

### 推奨ドキュメント構成

```
docs/
├── getting-started.md
├── api/                    # API詳細
│   ├── classes.md
│   └── functions.md
├── guides/                 # ガイド
└── migration/              # マイグレーション
```

詳細な生成手法は [references/ai-driven-analysis.md](../references/ai-driven-analysis.md) を参照。
