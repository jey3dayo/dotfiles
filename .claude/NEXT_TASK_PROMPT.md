# Next Task: Fix distributions Layer Deployment

## 背景

distributions-manager スキルのドキュメントは完成しましたが、`home-manager switch` 実行後も `~/.claude/skills/` にスキルが配布されていません。

## 現状

- ✅ `agents/skills-internal/distributions-manager/` - 完全なドキュメント
- ✅ `agents/distributions/default/skills/distributions-manager` - 有効な symlink
- ✅ `home.nix` - `distributionsPath = ./agents/distributions/default;` 有効化済み
- ❌ `~/.claude/skills/` - 空（スキルが配布されていない）

## タスク

distributions 層を機能させ、skills が正しく配布されるようにする。

## 調査手順

### 1. Nix 評価の確認

```bash
# discoverCatalog が distributions を認識しているか
nix eval --json --impure --expr '
  let
    pkgs = import <nixpkgs> {};
    lib = import ./agents/nix/lib.nix { inherit pkgs; nixlib = pkgs.lib; };
    catalog = lib.discoverCatalog {
      distributionsPath = ./agents/distributions/default;
      localPath = ./agents/skills-internal;
      sources = [];
    };
  in
    builtins.attrNames catalog.skills
' | jq
```

### 2. lib.nix の実装確認

```bash
# scanDistribution 関数が存在するか
grep -n "scanDistribution" agents/nix/lib.nix

# discoverCatalog の実装確認
grep -A 30 "discoverCatalog" agents/nix/lib.nix
```

### 3. module.nix の統合確認

```bash
# distributionsPath が discoverCatalog に渡されているか
grep -B 5 -A 10 "discoverCatalog" agents/nix/module.nix
```

### 4. Build 結果の確認

```bash
# Dry-run でエラー確認
home-manager build --flake ~/.config --impure --dry-run --show-trace 2>&1 | tee debug.log

# Build 結果の skills 確認
result=$(home-manager build --flake ~/.config --impure --print-out-paths)
ls -la $result/home-files/.claude/skills/
```

## 期待される修正

### 修正1: lib.nix に scanDistribution 実装

`agents/nix/lib.nix` に追加:

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

### 修正2: discoverCatalog に distributionsPath 統合

`agents/nix/lib.nix` の `discoverCatalog` を修正:

```nix
discoverCatalog = { sources, localPath, distributionsPath ? null }:
  let
    # 1. Distributions をスキャン（最低優先度）
    distributionSkills =
      if distributionsPath != null then
        scanDistribution (distributionsPath + "/skills")
      else
        {};

    # 2. External skills をスキャン
    externalSkills = foldl' scanSourceAutoDetect {} sources;

    # 3. Local skills をスキャン（最高優先度）
    localSkills = scanSource "local" localPath;
  in
    # Priority: Distribution < External < Local
    distributionSkills // externalSkills // localSkills;
```

### 修正3: module.nix で distributionsPath を渡す

`agents/nix/module.nix` の catalog 生成部分:

```nix
catalog = agentLib.discoverCatalog {
  inherit sources;
  localPath = cfg.localSkillsPath;
  distributionsPath = cfg.distributionsPath;  # この行を追加
};
```

## 検証コマンド

修正後:

```bash
# 1. Nix 評価確認
home-manager build --flake ~/.config --impure --dry-run

# 2. デプロイ
home-manager switch --flake ~/.config --impure

# 3. Skills 確認
ls -la ~/.claude/skills/ | grep distributions-manager
# 期待: lrwxrwxrwx distributions-manager -> /nix/store/.../distributions-manager

# 4. Skills 数確認
ls -1 ~/.claude/skills/ | wc -l
# 期待: 43以上（42 from distributions/default + 1 distributions-manager）
```

## 成功基準

- ✅ `~/.claude/skills/distributions-manager` が存在する
- ✅ `ls -1 ~/.claude/skills/ | wc -l` が 43 以上
- ✅ `mise run skills:list | jq '.skills[] | select(.id == "distributions-manager")'` が結果を返す

## 参考資料

- `.claude/DEPLOY_DEBUG.md` - 詳細なデバッグ手順
- `.claude/IMPLEMENTATION_SUMMARY.md` - 実装完了状況
- `agents/skills-internal/distributions-manager/references/architecture.md` - Nix 実装の詳細
- Git commits: `63f89500`, `4d1a1480` - distributions 層の実装例

---

**Priority**: High
**Complexity**: Medium（Nix 実装の理解が必要）
**Estimated Time**: 30-60 minutes
