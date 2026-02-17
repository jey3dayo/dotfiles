# Nix Home Manager メンテナンス運用ポリシー

このドキュメントは、Nix Home Managerの定期メンテナンスと運用ポリシーを定義します。

## 目次

- [Generations保持ポリシー](#generations保持ポリシー)
- [Garbage Collection運用](#garbage-collection運用)
- [ディスク使用量監視](#ディスク使用量監視)
- [実行頻度とタイミング](#実行頻度とタイミング)
- [トラブルシューティング](#トラブルシューティング)

---

## Generations保持ポリシー

### 保持基準

#### 90日または20世代（いずれか先に到達した方）を保持

理由:

- 90日：約3ヶ月分の履歴を保持し、長期的なロールバックに対応
- 20世代：頻繁に変更する場合でも、十分な世代数を確保
- ディスク容量と復旧柔軟性のバランスを考慮

### 削除対象

以下の基準を**両方とも**満たすgenerationsを削除：

1. **90日以前**に作成された
2. または、**最新から21世代以上前**のgeneration

**現在のgenerationは常に保持**（削除されない）

### 除外ルール

以下のgenerationsは**保持期間に関わらず保持**：

- 現在アクティブなgeneration（`current`）
- 手動でマーク した重要なgeneration（将来的な機能）

---

## Garbage Collection運用

### GC（Garbage Collection）とは

Nixの`/nix/store`には、過去にインストールしたパッケージやビルド成果物が蓄積されます。GCは、どのgenerationからも参照されていない不要なstoreオブジェクトを削除する処理です。

### GC実行タイミング

**必須**: 月次メンテナンス時（毎月1回）

**推奨**: 以下の状況でも実行

- generations削除後（`home-manager remove-generations`実行後）
- `/nix/store`のディスク使用量が50%を超えた場合
- 大規模なflake updateの後

### GC実行手順

#### 標準クリーンアップ（月次メンテナンス）

```bash
# 1. 古いgenerationsを削除
echo "=== Removing old Home Manager generations ==="
home-manager remove-generations 90d

# 2. 参照されていないstoreパスを削除
echo "=== Running garbage collection ==="
nix-collect-garbage -d

# 3. ディスク使用量を確認
echo "=== Disk usage after cleanup ==="
df -h /nix/store
```

#### オプション説明

- `home-manager remove-generations 90d`: 90日以前のgenerationsを削除
- `nix-collect-garbage -d`: 古いprofilesと未使用のstoreパスを削除
- `df -h /nix/store`: ディスク使用量を人間が読める形式で表示

#### アグレッシブなクリーンアップ（緊急時）

ディスク容量が逼迫している場合のみ実施：

```bash
# 警告: 現在のgeneration以外すべて削除
home-manager remove-generations all

# 徹底的なGC
nix-collect-garbage -d

# さらに徹底的に（古いprofiles、derivations、GC rootsも削除）
nix-collect-garbage --delete-old

# ディスク使用量確認
df -h /nix/store
```

#### 注意

- ロールバック不可能になる（現在のgenerationのみ残る）
- 緊急時のみ実施
- 実行前に重要な設定変更をgit commitする

#### 保守的なクリーンアップ（より多くの世代を保持）

```bash
# 20世代以前のみ削除
home-manager remove-generations +20

# GC実行
nix-collect-garbage -d

# ディスク使用量確認
df -h /nix/store
```

#### 使用ケース

- 頻繁に設定を変更する期間
- 実験的な変更を試している場合
- ディスク容量に余裕がある場合

---

## ディスク使用量監視

### 監視閾値

| 使用率 | 状態 | アクション                            |
| ------ | ---- | ------------------------------------- |
| < 50%  | 正常 | 定期メンテナンスのみ                  |
| 50-70% | 注意 | 早めにGC実行を検討                    |
| 70-85% | 警告 | 即座にGC実行、不要なgenerationsを削除 |
| > 85%  | 危険 | アグレッシブなクリーンアップ実施      |

### ディスク使用量確認コマンド

```bash
# /nix/storeの使用量
df -h /nix/store

# 詳細な使用量分析
du -sh /nix/store/*

# 最大のstoreパスを特定
du -sh /nix/store/* | sort -rh | head -20
```

### ディスク使用量削減のベストプラクティス

1. 定期的なGC: 月次メンテナンスでgenerationsとGCを実行
2. 不要なflake inputsの削除: 使用していないflake inputsを`flake.nix`から削除
3. flake update頻度の調整: 必要な時のみflake updateを実行
4. ビルドキャッシュの活用: `substituters`を設定してバイナリキャッシュを活用

---

## 実行頻度とタイミング

### 定期メンテナンススケジュール

| 頻度       | タスク                     | コマンド                                                        |
| ---------- | -------------------------- | --------------------------------------------------------------- |
| **月次**   | Generations削除 + GC       | `home-manager remove-generations 90d && nix-collect-garbage -d` |
| **月次**   | ディスク使用量確認         | `df -h /nix/store`                                              |
| **四半期** | 保守的なクリーンアップ検証 | generations数、ディスク使用量推移の確認                         |
| **年次**   | 運用ポリシーの見直し       | 保持期間、閾値の調整検討                                        |

### 推奨実行タイミング

#### 月次メンテナンス

- 毎月第一日曜日（または第一週末）
- `workflows-and-maintenance.md`の月次メンテナンスセクションを参照
- 他のツール（Homebrew、mise）のメンテナンスと同時実施

#### 即座に実行すべきケース

- ディスク使用量が70%を超えた場合
- Home Managerの適用が"No space left on device"エラーで失敗した場合
- 大規模なflake updateを実施した後

---

## トラブルシューティング

### Q: GC実行後もディスク使用量が減らない

#### 原因

- まだ参照されているstoreパスが多い
- 最近のgenerationsが大量のパッケージを参照している

#### 解決策

```bash
# 現在のgenerations数を確認
home-manager generations | wc -l

# より多くのgenerationsを削除
home-manager remove-generations 30d

# 再度GC実行
nix-collect-garbage -d

# ディスク使用量確認
df -h /nix/store
```

### Q: "cannot delete path ... because it is in use" エラー

**原因**: 削除しようとしているstoreパスが、現在実行中のプロセスで使用されている

#### 解決策

```bash
# すべてのnix関連プロセスを確認
ps aux | grep nix

# nix-daemonを再起動（macOS）
sudo launchctl stop org.nixos.nix-daemon
sudo launchctl start org.nixos.nix-daemon

# 再度GC実行
nix-collect-garbage -d
```

### Q: Generations削除が "Permission denied" エラー

**原因**: プロファイルのパーミッション問題

#### 解決策

```bash
# ホームディレクトリのnix-profilesを確認
ls -la ~/.local/state/nix/profiles/

# パーミッション修正（必要に応じて）
chmod -R u+w ~/.local/state/nix/profiles/

# 再度generations削除を試行
home-manager remove-generations 90d
```

### Q: GC後にHome Manager適用が失敗する

**原因**: 必要なstoreパスが削除された可能性

#### 解決策

```bash
# flakeをクリーンビルド
cd ~/.config
nix flake update
home-manager switch --flake . --impure

# それでも失敗する場合は、flake.lockを削除
rm flake.lock
nix flake update
home-manager switch --flake . --impure
```

---

## メトリクス収集（将来的な改善）

### 推奨監視項目

以下のメトリクスを定期的に記録することで、運用ポリシーの最適化に役立ちます：

```bash
# Generations数の推移
echo "$(date +%Y-%m-%d): $(home-manager generations | wc -l) generations"

# /nix/storeのディスク使用量
echo "$(date +%Y-%m-%d): $(df -h /nix/store | tail -1 | awk '{print $5}')"

# 最古generationの年齢
echo "$(date +%Y-%m-%d): Oldest generation: $(home-manager generations | tail -1 | awk '{print $1, $2}')"
```

これらのメトリクスを`~/.config/logs/nix-metrics.log`などに記録し、四半期ごとに分析することで、保持ポリシーの調整が可能になります。

---

## 参考資料

- [Nix Package Management - Garbage Collection](https://nixos.org/manual/nix/stable/package-management/garbage-collection.html)
- [Home Manager Manual - Generations](https://nix-community.github.io/home-manager/index.html#sec-usage-generations)
- プロジェクト内ドキュメント:
  - `.claude/rules/workflows-and-maintenance.md` - 全体的なメンテナンスワークフロー
  - `docs/disaster-recovery.md` - ディザスタリカバリ手順
  - `.claude/rules/troubleshooting.md` - スキル配布問題の対処法

---

**最終更新**: 2026-02-13
**次回レビュー予定**: 2026-05-13（四半期後）
