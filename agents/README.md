# Agents ディレクトリ構造

このディレクトリには、Agent Skills のソース、Nix 実装、メンテナンススクリプトが含まれています。

## ディレクトリ構造

```text
agents/
├── src/               # バンドル済みアセットの source of truth
│   ├── skills/        # スキル定義
│   ├── agents/        # エージェント定義
│   ├── rules/         # プロジェクトルール
│   └── commands/      # 旧 bundled commands 置き場（現行 HM 配布では未使用）
├── nix/               # Nix 実装
│   ├── lib.nix        # スキャン、検出、選択、バンドル
│   ├── module.nix     # Home Manager モジュール
│   └── README.md      # Nix 実装の詳細
└── scripts/           # 検証・保守スクリプト
```

## Sources vs Distribution

### `agents/src/` (Distribution)

目的: このリポジトリが所有する bundled assets の source of truth

内容:

- `skills/`: このリポジトリで開発・管理する bundled skills
- `agents/`: bundled agent definitions
- `rules/`: bundled project rules
- `commands/`: 歴史的な bundled commands 置き場。現行の Home Manager モジュールはここを配布しない

### Flake Input Sources

目的: 外部リポジトリ由来の skills と top-level agents/commands

管理:

- `nix/agent-skills-sources.nix`
- `nix/sources.nix`
- `flake.nix`

## 使用方法

### 変更のデプロイ

```bash
home-manager switch --flake ~/.config --impure
```

### 検証

```bash
# agents/src の基本構造を検証
bash ./agents/scripts/validate-src.sh

# スキルカタログと bundle を検証
nix run .#validate
```

### 新しい bundled skill の追加

1. `agents/src/skills/<skill-name>/` を作成
2. `SKILL.md` を追加
3. `home-manager switch --flake ~/.config --impure` を実行

### 新しい external source の追加

1. `nix/agent-skills-sources.nix` に source 定義を追加
2. `flake.nix` に対応する input を追加
3. plugin root など skill 外の参照先が必要なら `homeLinks` を追加
4. 必要なら `selection.enable` に対象 skill を加える
5. `nix flake update && home-manager switch --flake ~/.config --impure` を実行

## アーキテクチャ

### カタログ検出

スキルは以下の優先順位で検出されます。

1. Distribution (`agents/src/`)
2. External (`sources` 経由の flake inputs)

同じ skill ID が衝突した場合は bundled distribution 側が勝ちます。

### 選択

- `skills.enable = null`: 発見された全 skill を選択
- `skills.enable = [ ... ]`: 指定 skill に加えて bundled distribution skills を常に含める
- top-level external agents/commands は、選択された skill source に応じて配布対象が決まる
- source-level `homeLinks` は、選択された external source に応じて `$HOME` 直下へ配布される

### バンドリング

選択された skills は Nix store に bundle され、Home Manager 経由で `~/.claude/skills/` へ per-skill symlink として配布されます。

bundled rules と bundled agents は `agents/src` から直接リンクされます。
plugin root のような source-level alias は `nix/agent-skills-sources.nix` の `homeLinks` に書きます。

## 参考資料

- `agents/nix/README.md`
- `.claude/rules/home-manager.md`
- `nix/agent-skills-sources.nix`

---

最終更新: 2026-03-29
