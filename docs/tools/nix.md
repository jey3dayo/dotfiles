# Nix / Home Manager リファレンス

最終更新: 2026-03-23
対象: macOS ユーザー（dotfiles 管理者）
タグ: `category/infra`, `tool/nix`, `tool/home-manager`, `layer/system`, `environment/macos`, `audience/developer`

> **Status: legacy** — Home Manager による dotfiles 配布は mise bootstrap へ移管し、
> flake / HM コードはリポジトリから撤去済み。本ドキュメントは、マシンに残る
> Nix ランタイムと generation / nix store の掃除手順のためだけに残している。

## 配布アーキテクチャ（historical）

Home Manager / flake による dotfiles 配布は撤去済み。現在の配布は `docs/setup.md` の
`mise bootstrap` / `mise dotfiles apply` を参照。以下の GC / generations 手順は、
マシンに `home-manager` バイナリと Nix profiles が**まだ残っている場合のみ**適用する。

### GitHub rate limit 対策（廃止済み）

`mise run hm:*` / `mise run nix:*` という task family は Home Manager 撤去に伴い削除済みで、
`gh auth token` を使った `NIX_CONFIG` への `access-tokens` 自動注入という仕組みも現在は存在しない
（`mise/` 配下に該当タスク定義なし。代替の仕組みは未導入）。
GitHub rate limit 対策が必要な場合は、手動で `NIX_CONFIG` に `access-tokens = github.com=...` を設定すること。

### スキル優先度

| 優先度 | ソース       | パス                      |
| ------ | ------------ | ------------------------- |
| 高     | distribution | `~/.apm/catalog/skills/`  |
| 低     | external     | flake inputs 経由バンドル |

---

## Generations 保持ポリシー

### 保持基準

90日または20世代（いずれか先に到達した方）を保持。

理由:

- 90日：約3ヶ月分の履歴を保持し、長期的なロールバックに対応
- 20世代：頻繁に変更する場合でも、十分な世代数を確保
- ディスク容量と復旧柔軟性のバランスを考慮

### 削除対象

以下の基準を**両方とも**満たす generations を削除：

1. 90日以前に作成された
2. または、**最新から21世代以上前**の generation

**現在の generation は常に保持**（削除されない）

### 除外ルール

以下の generations は保持期間に関わらず保持：

- 現在アクティブな generation（`current`）
- 手動でマークした重要な generation（将来的な機能）

---

## Garbage Collection 運用

### GC とは

Nix の `/nix/store` には過去にインストールしたパッケージやビルド成果物が蓄積されます。GC は、どの generation からも参照されていない不要な store オブジェクトを削除する処理です。

### GC 実行タイミング

必須: 月次メンテナンス時（毎月1回）

推奨実行ケース:

- generations 削除後
- `/nix/store` のディスク使用量が50%を超えた場合
- 大規模な Nix store 変更の後（`home-manager` が残っている場合）

### 3パターンの使い分け

#### 標準クリーンアップ（月次）

```bash
home-manager remove-generations 90d
nix-collect-garbage -d
df -h /nix/store
```

#### 保守的なクリーンアップ（頻繁に変更する期間）

```bash
home-manager remove-generations +20
nix-collect-garbage -d
df -h /nix/store
```

#### アグレッシブなクリーンアップ（緊急時のみ）

```bash
# 警告: 現在の generation 以外すべて削除。ロールバック不可。
# 実行前に重要な設定変更を git commit すること。
home-manager remove-generations all
nix-collect-garbage -d
nix-collect-garbage --delete-old
df -h /nix/store
```

---

## ディスク使用量監視

### 監視閾値

| 使用率 | 状態 | アクション                              |
| ------ | ---- | --------------------------------------- |
| < 50%  | 正常 | 定期メンテナンスのみ                    |
| 50-70% | 注意 | 早めに GC 実行を検討                    |
| 70-85% | 警告 | 即座に GC 実行、不要な generations 削除 |
| > 85%  | 危険 | アグレッシブなクリーンアップ実施        |

### 確認コマンド

```bash
df -h /nix/store                           # 使用量確認
du -sh /nix/store/* | sort -rh | head -20  # 最大の store パスを特定
home-manager generations | wc -l           # generations 数確認
```

### ベストプラクティス

1. 月次 GC で generations と store を同時クリーンアップ（`home-manager` が存在する場合）
2. `substituters` でバイナリキャッシュを活用
3. dotfiles 配布の更新は `mise dotfiles apply` / `docs/setup.md` を参照（flake apply は廃止）

---

## 定期メンテナンススケジュール

| 頻度   | タスク                | コマンド                                                        |
| ------ | --------------------- | --------------------------------------------------------------- |
| 月次   | Generations 削除 + GC | `home-manager remove-generations 90d && nix-collect-garbage -d` |
| 月次   | ディスク使用量確認    | `df -h /nix/store`                                              |
| 四半期 | クリーンアップ検証    | generations 数・ディスク使用量推移の確認                        |
| 年次   | 運用ポリシーの見直し  | 保持期間・閾値の調整検討                                        |

推奨タイミング: 毎月第一日曜日。Homebrew・mise のメンテナンスと同時実施。

---

## トラブルシューティング

### Q: GC 実行後もディスク使用量が減らない

原因: まだ参照されている store パスが多い、最近の generations が大量パッケージを参照。

```bash
home-manager generations | wc -l
home-manager remove-generations 30d   # より短い期間で削除
nix-collect-garbage -d
df -h /nix/store
```

### Q: "cannot delete path ... because it is in use" エラー

原因: 削除しようとしている store パスが実行中プロセスで使用されている。

```bash
ps aux | grep nix
sudo launchctl stop org.nixos.nix-daemon
sudo launchctl start org.nixos.nix-daemon
nix-collect-garbage -d
```

### Q: Generations 削除が "Permission denied" エラー

原因: プロファイルのパーミッション問題。

```bash
ls -la ~/.local/state/nix/profiles/
chmod -R u+w ~/.local/state/nix/profiles/
home-manager remove-generations 90d
```

### Q: GC 後に `home-manager` コマンドが失敗する

`home-manager` バイナリと Nix profiles がまだマシンに残っている場合のみ該当する。
flake apply は廃止済みのため、`home-manager switch --flake` や `nix flake update` は実行しない。

原因: 必要な store パスが GC で削除された可能性。

```bash
# home-manager がインストールされている場合のみ
home-manager generations
home-manager remove-generations 90d   # または +20
nix-collect-garbage -d
df -h /nix/store
```

dotfiles の再適用が必要な場合は `mise dotfiles apply` を使う。

---

## 参考資料

- [Nix Package Management - Garbage Collection](https://nixos.org/manual/nix/stable/package-management/garbage-collection.html)
- [Home Manager Manual - Generations](https://nix-community.github.io/home-manager/index.html#sec-usage-generations)
- `docs/tools/workflows.md` - 全体的なメンテナンスワークフロー
- `docs/disaster-recovery.md` - ディザスタリカバリ手順
