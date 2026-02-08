---
name: marketplace-builder
description: Claude Code Marketplace構築支援。カテゴリバンドル管理、プラグイン追加、構造検証の自動化
---

# Marketplace Builder - Claude Code Marketplace構築支援

## いつ使うか

以下のキーワードを検出した場合、このスキルを自動的にロードします：

- **日本語**: "marketplace", "マーケットプレイス", "プラグイン追加", "バンドル", "plugin.json", "marketplace.json"
- **English**: "marketplace", "plugin", "bundle", "category bundle", "marketplace.json"

## スキルの目的

Claude Code Marketplaceの構築と管理を効率化します：

1. **カテゴリバンドル管理**: カテゴリレベルでのプラグイン一括管理
2. **プラグイン追加ワークフロー**: 新規プラグイン追加の標準化
3. **marketplace.json管理**: シンプルで保守しやすい構造
4. **構造検証**: ディレクトリ構造とメタデータの整合性確認

## カテゴリバンドル構造の基本

### 2つのアプローチ

#### アプローチA: カテゴリレベルのバンドル（推奨）

```
plugins/
├── {category}/
│   ├── .claude-plugin/
│   │   └── plugin.json          # カテゴリ全体をバンドル化
│   ├── {plugin1}/
│   │   └── skills/
│   ├── {plugin2}/
│   │   └── skills/
│   └── {plugin3}/
│       └── skills/
```

**メリット**:

- ✅ シンプルな管理（カテゴリ = バンドル）
- ✅ 自動包含（新規プラグイン追加時、1ファイルのみ更新）
- ✅ marketplace.jsonがコンパクト
- ✅ シンボリックリンク不要

**marketplace.json**:

```json
{
  "name": "your-name",
  "plugins": [
    {
      "name": "{category}-bundle",
      "source": "./plugins/{category}",
      "description": "{category}カテゴリの全スキル（N個）"
    }
  ]
}
```

#### アプローチB: 個別プラグイン登録（従来型）

```
plugins/
├── {category}/
│   ├── {plugin1}/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   └── skills/
│   └── {plugin2}/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       └── skills/
```

**メリット**:

- ✅ 個別プラグインの独立性が高い
- ✅ バージョン管理が細かく可能

**デメリット**:

- ⚠️ marketplace.jsonが肥大化
- ⚠️ プラグイン追加時、2ファイル更新が必要

**marketplace.json**:

```json
{
  "name": "your-name",
  "plugins": [
    {
      "name": "{plugin1}",
      "source": "./plugins/{category}/{plugin1}",
      "description": "説明"
    },
    {
      "name": "{plugin2}",
      "source": "./plugins/{category}/{plugin2}",
      "description": "説明"
    }
  ]
}
```

### どちらを選ぶべきか

| 基準         | カテゴリバンドル | 個別プラグイン     |
| ------------ | ---------------- | ------------------ |
| プラグイン数 | 多い（10+）      | 少ない（<10）      |
| 更新頻度     | 高い             | 低い               |
| 管理者       | 単一             | 複数               |
| 配布方法     | 一括インストール | 選択的インストール |

**推奨**: プラグイン数が多く、頻繁に更新する場合は**カテゴリバンドル**

## 新規プラグイン追加ワークフロー

### カテゴリバンドル形式の場合

#### Step 1: カテゴリ選択

プラグインの性質に応じてカテゴリを決定：

```
例:
- dev-tools: 開発ツール、コード品質、レビュー
- docs: ドキュメント作成、図表、プレゼン
- utils: ユーティリティ、環境管理
- infra: インフラ操作、デプロイ、監視
```

#### Step 2: ディレクトリ作成

```bash
# プラグインディレクトリを作成
mkdir -p plugins/{category}/{plugin_name}/skills

# または直下にSKILL.mdを配置する場合
mkdir -p plugins/{category}/{plugin_name}
```

#### Step 3: SKILL.md作成

```markdown
---
name: your-skill-name
description: スキルの説明
---

# スキル名

スキルの詳細な説明と使用方法。
```

#### Step 4: カテゴリバンドルに追加

`plugins/{category}/.claude-plugin/plugin.json` を編集:

```json
{
  "name": "{category}-bundle",
  "version": "1.0.0",
  "description": "{category}カテゴリの全スキル",
  "author": { "name": "your-name" },
  "skills": [
    "./existing-plugin/skills/",
    "./your-plugin-name/skills/" // ← 追加
  ]
}
```

**重要**: marketplace.jsonへの登録は不要！

#### Step 5: 検証

```bash
# カテゴリバンドルのplugin.json確認
cat plugins/{category}/.claude-plugin/plugin.json | jq '.skills | length'

# プラグイン数をカウント
ls -1 plugins/{category}/ | grep -v ".claude-plugin" | wc -l

# 整合性確認（plugin.jsonのエントリ数 = 実際のプラグイン数）
```

### 個別プラグイン形式の場合

#### Step 1-3: 同上

#### Step 4: プラグインのplugin.json作成

`plugins/{category}/{plugin_name}/.claude-plugin/plugin.json`:

```json
{
  "name": "{plugin_name}",
  "version": "1.0.0",
  "description": "プラグインの説明",
  "author": { "name": "your-name" },
  "skills": ["./skills/"]
}
```

#### Step 5: marketplace.jsonに登録

`.claude-plugin/marketplace.json`:

```json
{
  "plugins": [
    {
      "name": "{plugin_name}",
      "source": "./plugins/{category}/{plugin_name}",
      "description": "説明",
      "version": "1.0.0",
      "author": { "name": "your-name" }
    }
  ]
}
```

## skills/構造パターン

### パターンA: skills/サブディレクトリ（推奨）

```
plugins/{category}/{plugin}/
└── skills/
    ├── SKILL.md
    ├── references/
    └── resources/
```

**利点**: 構造が明確、スケーラビリティが高い

**plugin.jsonのパス**: `"./{plugin}/skills/"`

### パターンB: 直下にSKILL.md

```
plugins/{category}/{plugin}/
├── SKILL.md
└── references/
```

**利点**: シンプル、小規模プラグインに適している

**plugin.jsonのパス**: `"./{plugin}/"`

### どちらを選ぶべきか

- **パターンA**: references/resources/が多い、将来的に拡張予定
- **パターンB**: 小規模、シンプルな構造で十分

## 構造検証

### 基本検証コマンド

```bash
# プラグイン数確認
ls -1 plugins/{category}/ | grep -v ".claude-plugin" | wc -l

# skills/構造確認
for dir in plugins/{category}/*/; do
  name=$(basename "$dir")
  if [ -d "$dir/skills" ]; then
    echo "$name -> ./skills/"
  elif [ -f "$dir/SKILL.md" ]; then
    echo "$name -> ./ (直下)"
  fi
done

# カテゴリバンドルのエントリ数確認
cat plugins/{category}/.claude-plugin/plugin.json | jq '.skills | length'
```

### 整合性チェックスクリプト

```bash
#!/bin/bash
# validate-marketplace.sh

category=$1

# 実際のプラグイン数
actual=$(ls -1 plugins/$category/ | grep -v ".claude-plugin" | wc -l)

# plugin.jsonのエントリ数
declared=$(cat plugins/$category/.claude-plugin/plugin.json | jq '.skills | length')

echo "実際のプラグイン数: $actual"
echo "plugin.jsonのエントリ数: $declared"

if [ "$actual" -eq "$declared" ]; then
  echo "✅ 整合性OK"
else
  echo "❌ 不整合: $(($actual - $declared))個のプラグインが未登録"
fi
```

## トラブルシューティング

### 問題: プラグインがバンドルに含まれない

**症状**: プラグインディレクトリは存在するが、インストール時に見つからない

**原因**: カテゴリの`plugin.json`にパスが追加されていない

**解決策**:

```bash
# plugin.jsonを確認
cat plugins/{category}/.claude-plugin/plugin.json | jq '.skills'

# パスを追加
vim plugins/{category}/.claude-plugin/plugin.json
```

### 問題: skills/構造のパスが間違っている

**症状**: プラグインはリストに表示されるが、スキルがロードされない

**原因**: パターンA（`./plugin/skills/`）とパターンB（`./plugin/`）の混在

**解決策**:

```bash
# 実際の構造を確認
ls -la plugins/{category}/{plugin_name}/

# plugin.jsonのパスを修正
# パターンA: "./plugin/skills/"
# パターンB: "./plugin/"
```

### 問題: marketplace.jsonが肥大化

**症状**: marketplace.jsonが数百行になり、管理が困難

**原因**: 個別プラグインを登録している

**解決策**:

```bash
# カテゴリバンドル形式に移行
# 1. カテゴリレベルのplugin.json作成
# 2. marketplace.jsonをカテゴリバンドルのみに変更
# 3. 個別プラグインのplugin.jsonを削除（任意）
```

## ベストプラクティス

### 1. カテゴリ設計

```
良い例:
- dev-tools（開発ツール全般）
- docs（ドキュメント作成全般）
- infra（インフラ操作全般）

悪い例:
- tools（抽象的すぎる）
- misc（その他・雑多）
- temp（一時的）
```

### 2. プラグイン命名

```
良い例:
- mise（ツール名）
- react-grid-layout（技術スタック+機能）
- code-review（機能）

悪い例:
- plugin1（意味不明）
- my-tool（曖昧）
- test（用途不明）
```

### 3. descriptionの書き方

```json
{
  "description": "{機能}。{詳細}、{具体例}"
}
```

```
良い例:
"開発ツールカテゴリの全スキル（27プラグイン）。React、TypeScript、Go、コードレビュー等"

悪い例:
"いろいろなツール"
"便利なスキル集"
```

### 4. バージョン管理

```json
{
  "version": "1.0.0" // セマンティックバージョニング
}
```

- **MAJOR**: 破壊的変更
- **MINOR**: 機能追加（後方互換性あり）
- **PATCH**: バグ修正

## 自動化スクリプト例

### プラグイン追加スクリプト

```bash
#!/bin/bash
# add-plugin.sh

category=$1
plugin=$2

# 1. ディレクトリ作成
mkdir -p plugins/$category/$plugin/skills

# 2. SKILL.mdテンプレート生成
cat > plugins/$category/$plugin/skills/SKILL.md <<EOF
---
name: $plugin
description: TODO: スキルの説明
---

# $plugin

TODO: スキルの詳細な説明
EOF

# 3. カテゴリバンドルに追加
# （JSON編集ツールが必要: jq等）
echo "✅ プラグインディレクトリ作成完了"
echo "次のステップ:"
echo "1. SKILL.mdを編集"
echo "2. plugins/$category/.claude-plugin/plugin.jsonにパスを追加"
```

### バンドル検証スクリプト

```bash
#!/bin/bash
# validate-bundle.sh

for category in plugins/*/; do
  if [ -f "$category/.claude-plugin/plugin.json" ]; then
    name=$(basename "$category")
    echo "=== $name ==="

    actual=$(ls -1 "$category" | grep -v ".claude-plugin" | wc -l)
    declared=$(cat "$category/.claude-plugin/plugin.json" | jq '.skills | length')

    echo "実際: $actual, 登録: $declared"

    if [ "$actual" -ne "$declared" ]; then
      echo "❌ 不整合"
    else
      echo "✅ OK"
    fi
  fi
done
```

## 関連リンク

- [公式ドキュメント: プラグインマーケットプレイス](https://code.claude.com/docs/en/plugin-marketplaces)
- [公式ドキュメント: プラグインリファレンス](https://code.claude.com/docs/en/plugins-reference)
- [公式ドキュメント: スキル作成](https://code.claude.com/docs/en/skills)

## まとめ

このスキルを使うことで：

1. ✅ **2つのアプローチを理解**: カテゴリバンドル vs 個別プラグイン
2. ✅ **適切な選択**: プロジェクトの規模と要件に応じた構造選択
3. ✅ **標準化されたワークフロー**: 新規プラグイン追加の手順統一
4. ✅ **構造検証**: 整合性チェックと自動化

**重要な原則**: シンプルで保守しやすい構造を維持すること！
