# Distributions Layer Deployment Debug

## 問題の概要

distributions-manager スキルが作成され、`distributions/default/skills/` に symlink が追加されましたが、`home-manager switch` 実行後も `~/.claude/skills/` にスキルが配布されていません。

## 現状

### ✅ 完了した作業

1. **distributions-manager スキル作成**
   - 場所: `agents/skills-internal/distributions-manager/`
   - 構成: SKILL.md + references/ (4 files) + resources/ (3 files)
   - 状態: 完全に文書化済み

2. **distributions/default/ への追加**
   - Symlink: `agents/distributions/default/skills/distributions-manager -> ../../../skills-internal/distributions-manager`
   - 検証: `test -e` で確認済み（有効なリンク）

3. **home.nix での有効化**
   - `distributionsPath = ./agents/distributions/default;` のコメント解除済み

4. **既存スキルの更新**
   - command-creator: 配布セクション追加済み
   - knowledge-creator: 分類表とルーティング追加済み

### ❌ 未解決の問題

**症状**: `home-manager switch --flake ~/.config --impure` 実行後、`~/.claude/skills/` が空

```bash
# 確認コマンド
ls -1 ~/.claude/skills/ | wc -l
# 出力: 0
```

## 調査ポイント

### 1. Nix 評価の確認

distributions 層が正しく評価されているか:

```bash
# Flake metadata 確認
nix flake metadata ~/.config

# discoverCatalog の評価
nix eval --json --impure --expr '
  let
    pkgs = import <nixpkgs> {};
    lib = import ~/agents/nix/lib.nix { inherit pkgs; nixlib = pkgs.lib; };
    catalog = lib.discoverCatalog {
      distributionsPath = ~/agents/distributions/default;
      localPath = ~/agents/skills-internal;
      sources = [];
    };
  in
    builtins.attrNames catalog.skills
' | jq
```

### 2. scanDistribution 実装の確認

`agents/nix/lib.nix` の `scanDistribution` 関数が正しく動作しているか:

```bash
# lib.nix の該当部分を確認
grep -A 30 "scanDistribution" agents/nix/lib.nix
```

**期待される実装**:

```nix
scanDistribution = distributionPath:
  if !pathExists distributionPath then
    {}
  else
    let
      processSkillEntry = name: type:
        let entryPath = distributionPath + "/${name}";
        in
          if type == "directory" || type == "symlink" then
            if pathExists (entryPath + "/SKILL.md") then
              { ${name} = { id = name; path = entryPath; source = "distribution"; }; }
            else
              scanSource "distribution" entryPath
          else {};
      entries = readDir distributionPath;
      scannedResults = mapAttrsToList processSkillEntry entries;
    in
      foldl' (a: b: a // b) {} scannedResults;
```

### 3. module.nix の統合確認

`agents/nix/module.nix` で distributionsPath が正しく渡されているか:

```bash
# module.nix の該当部分を確認
grep -B 5 -A 10 "distributionsPath" agents/nix/module.nix
```

**期待される呼び出し**:

```nix
catalog = agentLib.discoverCatalog {
  inherit sources;
  localPath = cfg.localSkillsPath;
  distributionsPath = cfg.distributionsPath;  # この行が存在するか確認
};
```

### 4. Home Manager generation の確認

実際に生成された Nix store の内容を確認:

```bash
# 最新 generation の確認
home-manager generations | head -3

# Generation の home-files 内容確認
ls -la $(home-manager generations | head -1 | awk '{print $NF}')/home-files/.claude/skills/
```

### 5. mkBundle の確認

選択されたスキルが正しくバンドルされているか:

```bash
# module.nix の mkBundle 実装確認
grep -A 20 "mkBundle" agents/nix/module.nix
```

## デバッグコマンド

```bash
# 1. Dry-run で Nix 評価エラーを確認
home-manager build --flake ~/.config --impure --dry-run --show-trace 2>&1 | tee debug.log

# 2. Build 結果の確認
result=$(home-manager build --flake ~/.config --impure --print-out-paths)
ls -la $result/home-files/.claude/skills/

# 3. distributionsPath の存在確認
test -d agents/distributions/default && echo "✅ Path exists" || echo "❌ Path missing"

# 4. Symlink の検証
find agents/distributions/default/skills/ -type l -exec sh -c '
  target=$(readlink -f "$1")
  test -f "$target/SKILL.md" || echo "❌ Missing SKILL.md: $1"
' _ {} \;
```

## 想定される原因

### 原因 1: scanDistribution が実装されていない

**確認方法**:

```bash
grep -n "scanDistribution" agents/nix/lib.nix
```

**対策**: lib.nix に scanDistribution 関数を実装

### 原因 2: distributionsPath が discoverCatalog に渡されていない

**確認方法**:

```bash
grep "discoverCatalog" agents/nix/module.nix | grep -o "distributionsPath"
```

**対策**: module.nix の discoverCatalog 呼び出しに `distributionsPath = cfg.distributionsPath;` を追加

### 原因 3: selection.enable に distributions-manager が含まれていない

**確認方法**:

```bash
grep -A 10 "selection.enable" nix/agent-skills.nix
```

**対策**: Local skills (skills-internal) は selection に関係なく常に含まれるべき

### 原因 4: mkBundle が distributions からのスキルを含んでいない

**確認方法**:

```bash
# module.nix の mkBundle 実装を確認
grep -B 5 -A 15 "mkBundle.*=" agents/nix/module.nix
```

**対策**: mkBundle が catalog 全体（distribution + external + local）を処理していることを確認

## 参考資料

### 実装計画書

元の実装計画では以下が既に実装済みとされていました:

- 84個のsymlinks（42 skills + 42 commands）in `distributions/default/`
- 優先度: Local > External > Distribution
- 循環参照回避（静的パス、sources前にスキャン）

### 関連ファイル

- `agents/nix/lib.nix` - scanDistribution, discoverCatalog 実装
- `agents/nix/module.nix` - Home Manager 統合、mkBundle
- `home.nix` - distributionsPath 設定
- `agents/distributions/default/` - デフォルトバンドル

### distributions-manager ドキュメント

作成済みのドキュメントは以下にあります:

- `agents/skills-internal/distributions-manager/SKILL.md`
- `agents/skills-internal/distributions-manager/references/architecture.md`
- `agents/skills-internal/distributions-manager/references/creating-bundles.md`
- `agents/skills-internal/distributions-manager/references/symlink-patterns.md`
- `agents/skills-internal/distributions-manager/references/priority-mechanism.md`

## 次のステップ

1. **Nix 実装の検証**: 上記のデバッグコマンドを実行し、どこで失敗しているか特定
2. **lib.nix の修正**: scanDistribution 実装の追加または修正
3. **module.nix の修正**: distributionsPath の統合確認
4. **テスト**: 修正後に `home-manager switch` を再実行して配布確認

---

**Last Updated**: 2026-02-11
**Status**: 未解決（Nix 実装の調査が必要）
