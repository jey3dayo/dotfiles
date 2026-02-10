# Distributions

統合配布パッケージの管理ディレクトリ。

## 目的

複数のコンポーネント（skills、commands、config等）を論理的にグループ化し、
一元的に配布するためのディレクトリ。

## 構造

```
distributions/
  ├── README.md           # このファイル
  ├── default/            # デフォルト配布パッケージ
  │   ├── skills/         # スキル群（skills-internalからのsymlink）
  │   ├── commands/       # コマンド群（commands-internalからのsymlink）
  │   └── config/         # 設定ファイル群
  └── custom-bundle/      # カスタム配布パッケージ（オプション）
      └── ...
```

## 使用方法

### 1. デフォルトパッケージ

`distributions/default/` は skills-internal と commands-internal を統合したパッケージ：

```nix
programs.agent-skills = {
  enable = true;
  distributionsPath = ./agents/distributions/default;
};
```

### 2. カスタムパッケージ

プロジェクト固有のパッケージを作成：

```bash
mkdir -p distributions/my-bundle/{skills,commands,config}
ln -s ../../skills-internal/my-skill distributions/my-bundle/skills/
```

## 設計原則

1. **Symlinkベース**: distributions/内はsymlinkで構成（実体は元のディレクトリ）
2. **バンドル単位の配布**: ディレクトリ単位で配布パッケージを定義
3. **循環参照の回避**: distributionsは静的パス、sources統合前に定義

## 既存実装との関係

- **skills-internal/**: Internal skills（42スキル）
- **commands-internal/**: Commands（43ファイル、subdirectories）
- **distributions/**: 上記を統合した配布パッケージ

distributions/を使用しない場合、既存の個別配布フローが使用されます。
