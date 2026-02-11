# Distributions

統合配布パッケージの管理ディレクトリ。

## 目的

複数のコンポーネント（skills、commands、config等）を論理的にグループ化し、
一元的に配布するためのディレクトリ。

## 構造

```
distributions/
  ├── README.md           # このファイル
  ├── default/            # デフォルト配布パッケージ（SSoT）
  │   ├── skills/         # スキル群（実体ファイル）
  │   ├── commands/       # コマンド群（実体ファイル）
  │   ├── rules/          # ルール群
  │   ├── agents/         # エージェント群
  │   └── config/         # 設定ファイル群
  └── custom-bundle/      # カスタム配布パッケージ（オプション）
      └── ...
```

## 使用方法

### 1. デフォルトパッケージ

`distributions/default/` は internal skills/commands の単一ソースです：

```nix
programs.agent-skills = {
  enable = true;
  distributionsPath = ./agents/distributions/default;
};
```

### 2. カスタムパッケージ

プロジェクト固有のパッケージを作成（実体ファイルを配置）：

```bash
mkdir -p distributions/my-bundle/{skills,commands,config}
cp -r distributions/default/skills/<skill-id> distributions/my-bundle/skills/
```

## 設計原則

1. **SSoTベース**: `distributions/default/` 配下の実体ファイルを正本とする
2. **バンドル単位の配布**: ディレクトリ単位で配布パッケージを定義
3. **Nix統合**: `distributionsPath` を基点に skills/commands/rules/agents を配布

## 既存実装との関係

- **distributions/default/**: Internal assets の単一ソース
- **sources (flake inputs)**: External skills を追加する入力レイヤー
