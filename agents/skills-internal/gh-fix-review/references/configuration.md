# PR Review Automation - Configuration Reference

## 設定ファイルの詳細

### 設定ファイルの読み込み順序

PR Review Automationスキルは以下の順序で設定ファイルを探します：

1. **プロジェクトルート**: `./.pr-review-config.json`
2. **ホームディレクトリ**: `~/.pr-review-config.json`
3. **デフォルト設定**: 設定ファイルが見つからない場合

最初に見つかった設定ファイルが使用されます。

### 設定ファイルのスキーマ

#### 完全な設定ファイル例

```json
{
  "priorities": {
    "critical": {
      "keywords": ["critical", "bug", "security", "vulnerability"],
      "emoji": "🔴"
    },
    "high": {
      "keywords": ["important", "major", "should fix", "必須"],
      "emoji": "🟠"
    },
    "major": {
      "keywords": ["consider", "recommend", "推奨", "improvement"],
      "emoji": "🟡"
    },
    "minor": {
      "keywords": ["nit", "style", "formatting", "typo"],
      "emoji": "🟢"
    }
  },
  "categories": {
    "security": {
      "keywords": ["security", "vulnerability", "auth", "permission"],
      "description": "Security-related issues"
    },
    "performance": {
      "keywords": ["performance", "slow", "optimization", "cache"],
      "description": "Performance optimization"
    },
    "bug": {
      "keywords": ["bug", "error", "broken", "fail"],
      "description": "Bug fixes"
    },
    "style": {
      "keywords": ["style", "format", "naming", "convention"],
      "description": "Code style and formatting"
    },
    "refactor": {
      "keywords": ["refactor", "clean", "simplify", "duplication"],
      "description": "Code refactoring"
    },
    "test": {
      "keywords": ["test", "coverage", "mock", "assertion"],
      "description": "Testing improvements"
    },
    "docs": {
      "keywords": ["documentation", "comment", "readme"],
      "description": "Documentation updates"
    },
    "accessibility": {
      "keywords": ["accessibility", "a11y", "aria", "screen reader"],
      "description": "Accessibility improvements"
    },
    "i18n": {
      "keywords": ["i18n", "internationalization", "localization"],
      "description": "Internationalization"
    }
  },
  "bots": {
    "coderabbitai": {
      "username": "coderabbitai",
      "trusted": true,
      "priority_boost": 0
    },
    "github-actions": {
      "username": "github-actions",
      "trusted": true,
      "priority_boost": 0
    },
    "dependabot": {
      "username": "dependabot",
      "trusted": true,
      "priority_boost": 0
    },
    "sonarcloud": {
      "username": "sonarcloud",
      "trusted": true,
      "priority_boost": 1
    }
  },
  "paths": {
    "tracking_file": "docs/_review-fixes.md"
  },
  "quality_gates": {
    "type_check": true,
    "lint": true,
    "test": false,
    "auto_rollback": true
  },
  "output": {
    "language": "ja",
    "verbose": false
  }
}
```

### 設定項目の説明

#### `priorities` (必須)

レビューコメントの優先度分類ルールを定義します。

| フィールド | 型         | 説明                             |
| ---------- | ---------- | -------------------------------- |
| `keywords` | `string[]` | この優先度を示すキーワードリスト |
| `emoji`    | `string`   | 表示用の絵文字                   |

**注意事項**:

- キーワードは大文字小文字を区別しません
- 日本語と英語のキーワードを混在可能
- より高い優先度から順に評価されます

#### `categories` (必須)

レビューコメントのカテゴリ分類ルールを定義します。

| フィールド    | 型         | 説明                               |
| ------------- | ---------- | ---------------------------------- |
| `keywords`    | `string[]` | このカテゴリを示すキーワードリスト |
| `description` | `string`   | カテゴリの説明（オプション）       |

**デフォルトカテゴリ**:

- `security` - セキュリティ関連
- `performance` - パフォーマンス最適化
- `bug` - バグ修正
- `style` - コードスタイル
- `refactor` - リファクタリング
- `test` - テスト改善
- `docs` - ドキュメント更新
- `accessibility` - アクセシビリティ
- `i18n` - 国際化

#### `bots` (オプション)

既知のレビューボットの設定を定義します。

| フィールド       | 型        | 説明                        |
| ---------------- | --------- | --------------------------- |
| `username`       | `string`  | GitHubユーザー名            |
| `trusted`        | `boolean` | 信頼できるボットかどうか    |
| `priority_boost` | `number`  | 優先度を調整する値（-2～2） |

**priority_boost の動作**:

- `1`: 優先度を1段階上げる（minor → major）
- `-1`: 優先度を1段階下げる（high → major）
- `0`: 優先度変更なし（デフォルト）

#### `paths` (オプション)

ファイルパスの設定を定義します。

| フィールド      | 型       | デフォルト              | 説明                               |
| --------------- | -------- | ----------------------- | ---------------------------------- |
| `tracking_file` | `string` | `docs/_review-fixes.md` | トラッキングドキュメントの出力パス |

#### `quality_gates` (オプション)

品質チェックの設定を定義します。

| フィールド      | 型        | デフォルト | 説明                                 |
| --------------- | --------- | ---------- | ------------------------------------ |
| `type_check`    | `boolean` | `true`     | 型チェックを実行                     |
| `lint`          | `boolean` | `true`     | リンターを実行                       |
| `test`          | `boolean` | `false`    | テストを実行                         |
| `auto_rollback` | `boolean` | `true`     | 品質チェック失敗時に自動ロールバック |

#### `output` (オプション)

出力形式の設定を定義します。

| フィールド | 型        | デフォルト | 説明                         |
| ---------- | --------- | ---------- | ---------------------------- |
| `language` | `string`  | `ja`       | 出力言語（`ja` または `en`） |
| `verbose`  | `boolean` | `false`    | 詳細なログ出力               |

## 設定ファイルの作成方法

### 1. デフォルト設定をコピー

```bash
# プロジェクト固有の設定
cp ~/.claude/skills/gh-fix-review/.pr-review-config.default.json .pr-review-config.json

# グローバル設定
cp ~/.claude/skills/gh-fix-review/.pr-review-config.default.json ~/.pr-review-config.json
```

### 2. 必要に応じてカスタマイズ

```bash
# エディタで編集
vim .pr-review-config.json
```

### 3. 設定ファイルの検証

```bash
# JSON形式の検証
jq '.' .pr-review-config.json

# スキーマ検証（オプション）
ajv validate -s .pr-review-config.schema.json -d .pr-review-config.json
```

## プロジェクト固有の設定例

### セキュリティ重視プロジェクト

```json
{
  "priorities": {
    "critical": {
      "keywords": [
        "security",
        "vulnerability",
        "exploit",
        "injection",
        "xss",
        "csrf",
        "authentication",
        "authorization"
      ],
      "emoji": "🔴"
    },
    "high": {
      "keywords": ["data leak", "permission", "sensitive"],
      "emoji": "🟠"
    }
  },
  "quality_gates": {
    "type_check": true,
    "lint": true,
    "test": true,
    "auto_rollback": true
  }
}
```

### パフォーマンス重視プロジェクト

```json
{
  "priorities": {
    "critical": {
      "keywords": ["memory leak", "cpu spike", "crash"],
      "emoji": "🔴"
    },
    "high": {
      "keywords": ["performance", "slow", "optimization", "bottleneck"],
      "emoji": "🟠"
    }
  },
  "categories": {
    "performance": {
      "keywords": [
        "performance",
        "optimization",
        "cache",
        "lazy load",
        "bundle size",
        "render",
        "reflow"
      ],
      "description": "Performance critical issues"
    }
  }
}
```

### 最小限の設定

```json
{
  "priorities": {
    "critical": {
      "keywords": ["critical", "bug", "error"],
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

## トラブルシューティング

### 設定ファイルが読み込まれない

**症状**: デフォルト設定が使用される

**確認事項**:

1. ファイル名が正しいか（`.pr-review-config.json`）
2. JSON形式が正しいか（`jq '.' .pr-review-config.json`で確認）
3. ファイルの配置場所が正しいか

### 優先度分類が期待通りに動作しない

**症状**: コメントが意図しない優先度に分類される

**確認事項**:

1. キーワードの順序（より高い優先度から評価）
2. キーワードの大文字小文字（自動的に小文字変換される）
3. 部分一致の考慮（"security"は"security issue"にマッチ）

### カスタムカテゴリが認識されない

**症状**: カスタムカテゴリが "other" に分類される

**確認事項**:

1. `categories` オブジェクトに正しく定義されているか
2. `keywords` 配列が空でないか
3. キーワードが適切か

## ベストプラクティス

1. **プロジェクト固有の設定はプロジェクトルートに配置**
   - `.pr-review-config.json` をプロジェクトルートに作成
   - `.gitignore` に追加してチーム共有するかを検討

2. **個人設定はホームディレクトリに配置**
   - `~/.pr-review-config.json` を作成
   - 複数プロジェクトで共通の設定を定義

3. **段階的なカスタマイズ**
   - まずデフォルト設定で試す
   - 必要に応じて少しずつカスタマイズ
   - 過度に複雑な設定は避ける

4. **定期的な見直し**
   - プロジェクトの進化に合わせて設定を更新
   - 新しいボットやパターンを追加
   - 使用頻度の低いルールを削除
