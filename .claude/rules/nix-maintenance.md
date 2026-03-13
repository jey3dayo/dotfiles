---
paths: nix/**, flake.nix, flake.lock, docs/tools/nix.md
source: docs/tools/nix.md
---

# Nix Maintenance Rules

Purpose: Nix Home Manager のメンテナンス運用ポリシー。
Detailed Reference: [docs/tools/nix.md](../../docs/tools/nix.md)

## Generations 保持ポリシー

- 保持基準: **90日または20世代**（いずれか先に到達した方）
- 現在の generation は常に保持

## 月次メンテナンス（必須）

```bash
home-manager remove-generations 90d && nix-collect-garbage -d
df -h /nix/store
```

## ディスク使用量アクション

| 使用率 | アクション                              |
| ------ | --------------------------------------- |
| < 50%  | 定期メンテナンスのみ                    |
| 50-70% | 早めに GC 実行を検討                    |
| 70-85% | 即座に GC 実行、不要な generations 削除 |
| > 85%  | アグレッシブなクリーンアップ実施        |

## 緊急時（ディスク逼迫）

```bash
# 警告: 現在の generation 以外すべて削除。ロールバック不可。
# 実行前に重要な設定変更を git commit すること。
home-manager remove-generations all && nix-collect-garbage -d
```

## トラブルシューティング

詳細は [docs/tools/nix.md](../../docs/tools/nix.md) を参照。

- GC 後もディスクが減らない: `home-manager remove-generations 30d` でより短い期間で削除
- GC 後に HM 適用失敗: `nix flake update && home-manager switch --flake ~/.config --impure`
- Permission denied: `chmod -R u+w ~/.local/state/nix/profiles/`
