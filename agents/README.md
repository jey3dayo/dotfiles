# Agents ディレクトリ構造

このディレクトリには、内部アセットと外部アセットに整理された Claude Code のエージェントスキル、コマンド、設定が含まれています。

## ディレクトリ構造

```
agents/
├── internal/          # 内部アセット（信頼できる唯一の情報源）
│   ├── skills/       # バンドルされたスキル
│   ├── commands/     # スラッシュコマンド
│   ├── agents/       # エージェント定義
│   └── rules/        # プロジェクトルール
├── external/         # マーケットプレイスからの外部スキル
├── nix/              # Nix 実装
│   ├── lib.nix       # コアロジック（スキャン、検出、バンドル）
│   ├── module.nix    # Home Manager モジュール
│   └── README.md     # Nix 実装の詳細
└── scripts/          # メンテナンススクリプト
```

## Internal vs External

### agents/internal/

**目的**: 内部アセットの信頼できる唯一の情報源

#### 内容

- **skills/**: このリポジトリで開発・管理されているコアスキル
- **commands/**: インタラクティブ操作用のスラッシュコマンド
- **agents/**: 特殊タスク用のサブエージェント定義
- **rules/**: プロジェクト固有のルールとガイドライン

**配布**: すべてのコンテンツは Home Manager を介して自動的に `~/.claude/` に配布されます

### agents/external/

**目的**: マーケットプレイスおよびサードパーティソースからの外部スキル

#### 内容

- Claude Code Marketplace のスキル
- OpenAI キュレーションコレクションのスキル
- Vercel、Heyvhuang、その他プロバイダーのスキル

**管理**: `nix/agent-skills-sources.nix` および `flake.nix` の inputs で設定

## 使用方法

### 変更のデプロイ

```bash
# すべての変更を ~/.claude/ に適用
home-manager switch --flake ~/.config --impure

# デプロイ確認
ls ~/.claude/skills/ | wc -l
```

### 検証

```bash
# 内部アセット構造の検証
bash ./agents/scripts/validate-internal.sh

# スキルカタログの検証
nix run .#validate
```

### 新しいスキルの追加

**内部スキル**（このリポジトリで開発）:

1. `agents/internal/skills/<skill-name>/` 配下にスキルディレクトリを作成
2. スキル定義を含む `SKILL.md` を追加
3. `home-manager switch --flake ~/.config --impure` を実行

**外部スキル**（マーケットプレイスから）:

1. `nix/agent-skills-sources.nix` に追加
2. `flake.nix` に flake input を追加
3. `nix flake update && home-manager switch --flake ~/.config --impure` を実行

## アーキテクチャ

### カタログ検出

スキルは以下の優先順位で検出されます：

1. **Local** (`localPath` - 非推奨、レガシー互換性のため)
2. **Distribution** (`agents/internal/` - 主要ソース)
3. **External** (`sources` 経由の flake inputs)

### 選択

- Distribution スキル: 常に含まれる
- External スキル: `nix/agent-skills-sources.nix` の `selection.enable` でフィルタリング
- 結果: 一意のスキル ID を持つマージされたカタログ

### バンドリング

選択されたスキルは Nix ストアにバンドルされ、Home Manager を介してスキルごとのシンボリックリンクとして `~/.claude/skills/` に配布されます。

## 参考資料

- **Nix 実装**: `agents/nix/README.md`
- **Home Manager ルール**: `.claude/rules/home-manager.md`
- **Agent Skills ソース**: `nix/agent-skills-sources.nix`

---

**最終更新**: 2026-02-17
