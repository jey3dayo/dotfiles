# PR Review Automation - References

## 参照ドキュメント一覧

### 設定関連

- **[configuration.md](configuration.md)** - 設定ファイルの詳細リファレンス
  - 設定ファイルのスキーマ
  - 各設定項目の説明
  - プロジェクト固有の設定例
  - トラブルシューティング

### 実装ガイド

このスキルはClaude Codeのコマンドシステムと統合されています。

#### 関連する共通ユーティリティ

- `commands/shared/git_operations.py` - Git/GitHub操作
- `commands/shared/quality_gates.py` - 品質チェック
- `commands/shared/agent_selector.py` - エージェント選択
- `commands/shared/todo_integration.py` - Todo管理

## クイックリファレンス

### 設定ファイルの場所

1. プロジェクトルート: `./.pr-review-config.json` (優先)
2. ホームディレクトリ: `~/.pr-review-config.json`
3. デフォルト設定 (組み込み)

### 基本コマンド

```bash
# PR レビュー修正を開始
/review --fix-pr

# PR番号を指定
/review --fix-pr 123

# 優先度フィルタ
/review --fix-pr --priority critical,high

# ドライラン
/review --fix-pr --dry-run
```

### 最小限の設定ファイル

```json
{
  "priorities": {
    "critical": {
      "keywords": ["critical", "bug", "security"],
      "emoji": "🔴"
    },
    "high": {
      "keywords": ["important", "should fix"],
      "emoji": "🟠"
    },
    "major": {
      "keywords": ["consider", "recommend"],
      "emoji": "🟡"
    },
    "minor": {
      "keywords": ["nit", "style"],
      "emoji": "🟢"
    }
  },
  "categories": {}
}
```

## 一般化のポイント

このスキルは元々CAAD固有のプロジェクトで開発されましたが、以下の点で一般化されています：

### 1. 設定可能な優先度分類

ハードコードされたキーワードを設定ファイルに外部化：

- プロジェクト固有のキーワードを定義可能
- 優先度レベルのカスタマイズ
- 多言語対応（日本語/英語キーワード）

### 2. 柔軟なカテゴリシステム

カテゴリを動的に定義可能：

- デフォルトカテゴリ（security, performance, bug等）
- カスタムカテゴリの追加
- プロジェクト特有の分類

### 3. ボット設定の外部化

レビューボットの動作を設定可能：

- 信頼できるボットのリスト
- 優先度調整（priority_boost）
- ボット固有の処理ルール

### 4. パス設定のカスタマイズ

ファイルパスを柔軟に設定：

- トラッキングファイルの配置
- プロジェクト構造に合わせた調整

### 5. 品質ゲート設定

品質チェックをプロジェクトに合わせて調整：

- 型チェック、リント、テストの有効/無効
- 自動ロールバックの制御

## 移行ガイド

### ~/.claude/ から marketplace への移行

元のスキルは `~/.claude/skills/gh-fix-review/` に配置されていましたが、一般化されたバージョンは以下に配置されます：

```
~/src/github.com/jey3dayo/claude-code-marketplace/plugins/dev-tools/gh-fix-review/
├── SKILL.md                           # スキル定義
├── .pr-review-config.schema.json     # 設定ファイルスキーマ
├── .pr-review-config.default.json    # デフォルト設定
└── references/
    ├── index.md                       # このファイル
    └── configuration.md               # 設定詳細
```

### プロジェクト固有設定の作成

既存のCAADプロジェクトで使用していた設定を移行する場合：

```bash
# 1. デフォルト設定をコピー
cd /path/to/your/project
cp ~/src/github.com/jey3dayo/claude-code-marketplace/plugins/dev-tools/gh-fix-review/.pr-review-config.default.json .pr-review-config.json

# 2. プロジェクト固有のルールを追加
vim .pr-review-config.json

# 3. .gitignore に追加（チーム共有しない場合）
echo ".pr-review-config.json" >> .gitignore
```

## 今後の拡張予定

- [ ] 複数レビューボットの統合処理
- [ ] 優先度の自動調整（機械学習ベース）
- [ ] PRコメントのテンプレート機能
- [ ] カスタムフィルタ条件の追加
- [ ] レポート生成機能の強化

## サポート

問題が発生した場合は、以下を確認してください：

1. [configuration.md](configuration.md) の「トラブルシューティング」セクション
2. 設定ファイルのJSON形式が正しいか（`jq`で検証）
3. GitHub CLIが正しく認証されているか（`gh auth status`）

## 関連リソース

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [CodeRabbit Documentation](https://docs.coderabbit.ai/)
