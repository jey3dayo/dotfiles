# ⚡ Performance Monitoring & Optimization

最終更新: 2025-12-01
対象: 開発者・運用担当者
タグ: `category/performance`, `layer/support`, `environment/cross-platform`, `audience/developer`, `audience/ops`

パフォーマンス測定、監視、最適化のための包括的ガイドです。
測定手順・改善履歴・トラブルシュートの単一情報源は本書で管理し、実行スケジュールは [Workflows and Maintenance](../.claude/rules/workflows-and-maintenance.md) を参照します。

## 📊 Current Performance Metrics

### 主要コンポーネント

| Component           | Current    | Industry Avg | Target | Status |
| ------------------- | ---------- | ------------ | ------ | ------ |
| **Zsh startup**     | **1.1s**   | 2-5s         | <100ms | 🟡     |
| **Neovim startup**  | **<100ms** | 200-500ms    | <200ms | ✅     |
| **WezTerm startup** | **800ms**  | 1-2s         | <1s    | ✅     |

### 詳細ベンチマーク（M3 MacBook Pro基準）

#### Zsh起動分析

```
Total Startup Time: 1,100ms ± 50ms

内訳：
├── Shell initialization: ~200ms  (18%)
├── Plugin loading:       ~600ms  (55%)
├── Tool integration:     ~250ms  (23%)
└── Prompt rendering:     ~50ms   (5%)

Memory Usage: 24.8MB ± 2MB
├── Base zsh:       ~8MB   (32%)
├── Plugins:        ~12MB  (48%)
├── History/Cache:  ~3MB   (12%)
└── Functions:      ~2MB   (8%)
```

##### 改善履歴

- 2025-01: 1.8s → 1.1s (43%高速化)
  - mise即座初期化による最適化
  - PATH管理の効率化
  - 6段階プラグイン読み込み導入

#### Neovim起動分析

```
Total Startup Time: <100ms

最適化手法：
- lazy.nvim遅延読み込み
- 未使用プロバイダー無効化
- 大ファイル対策（>2MB Treesitter無効）
- プラグイン条件付き読み込み
```

##### 特徴

- 業界目標(200ms)を大幅に上回る
- 15+言語LSP対応でこの速度を維持
- AI統合(Supermaven)込みでの測定値

## 🔍 Monitoring Tools

### コマンド一覧

```bash
# Zsh パフォーマンス
zsh-help                   # 総合ヘルプシステム
zsh-help tools             # インストール済みツール確認

# システム監視
btop                       # Modern system monitor
htop                       # Traditional process viewer
top                        # Built-in process viewer

# Neovim プロファイリング
nvim --startuptime startup.log    # 起動時間詳細測定
:Lazy profile                      # プラグイン読み込み時間
:LspInfo                           # LSP状態確認
:checkhealth                       # 総合ヘルスチェック
```

### 定期測定スクリプト

```bash
#!/bin/zsh
# ~/.config/scripts/performance-monitor.sh

echo "=== Performance Report $(date) ==="

echo "\n📊 Zsh Performance"
time zsh -lic exit

echo "\n💻 Neovim Performance"
nvim --startuptime /tmp/nvim-startup.log +q
tail -1 /tmp/nvim-startup.log

echo "\n🖥️  System Resources"
echo "Memory: $(ps aux | awk '{sum+=$6} END {print sum/1024 "MB"}')"
echo "Processes: $(ps aux | wc -l)"
```

## ⚡ Optimization Strategies

### Zsh最適化

#### 現在の実装

1. 6段階プラグイン読み込み

   ```toml
   # sheldon/plugins.toml
   [plugins.tier1-essential]
   # 即座に必要なコアプラグイン

   [plugins.tier2-completion]
   # 補完システム

   [plugins.tier6-theme]
   # 視覚要素（最後）
   ```

2. mise即座初期化
   - macOS path_helper対応
   - ツール即座利用可能
   - 1.1s起動を維持

3. PATH最適化
   - 重複自動除去 (`typeset -gaU path`)
   - 存在確認による無駄削除
   - 優先度制御（mise > Homebrew > system）

#### 今後の最適化案

##### Phase 1: 即効性（-200ms目標）

- Instant Prompt実装
- 静的バンドル導入検討
- 補完キャッシュ最適化

##### Phase 2: 構造改善（-300ms目標）

- 日次compinit（現在は起動毎）
- コマンドトリガー遅延ローディング
- プラグイン依存関係最適化

##### Phase 3: 目標達成（<100ms）

- 継続的プロファイリング
- ボトルネック特定・排除
- 自動化された性能監視

### Neovim最適化

#### 現在の実装

1. lazy.nvim活用

   ```lua
   defaults = { lazy = true }  -- デフォルト遅延
   ```

2. 大ファイル対策

   ```lua
   -- Treesitter無効化（>2MB）
   disable = function(_, buf)
     local ok, stats = pcall(vim.uv.fs_stat,
       vim.api.nvim_buf_get_name(buf))
     return ok and stats and stats.size > 1024 * 1024 * 2
   end
   ```

3. 不要プロバイダー無効化

   ```lua
   vim.g.loaded_python3_provider = 0
   vim.g.loaded_ruby_provider = 0
   ```

#### 維持戦略

- 現在の<100msを維持
- プラグイン追加時の影響測定
- 四半期ごとのプロファイリング

## 📈 Performance History

### 2025年改善記録

| 日付       | 変更内容                    | Zsh起動 | Neovim起動 | 備考          |
| ---------- | --------------------------- | ------- | ---------- | ------------- |
| 2025-10-16 | ドキュメント整理            | 1.1s    | <100ms     | 変更なし      |
| 2025-09    | AIコマンドシステム統合      | 1.1s    | <100ms     | 影響なし      |
| 2025-07    | パフォーマンス目標達成      | 1.1s    | <95ms      | 大幅改善      |
| 2025-01    | mise即座初期化・PATH最適化  | 1.1s    | <100ms     | 1.8s→1.1s達成 |
| 2024-12    | 6段階プラグイン読み込み導入 | 1.5s    | <100ms     | 基盤構築      |

## 🎯 Performance Targets

### 短期目標（2025 Q4）

- ✅ Neovim <200ms: **達成（<100ms）**
- 🟡 Zsh <100ms: **進行中（現在1.1s、Phase 1-3計画済み）**
- ✅ WezTerm <1s: **達成（800ms）**

### 中期目標（2026 Q1-Q2）

- Zsh <100ms達成
- メモリ使用量 <20MB
- 全ツール統合での起動 <2s

## 🔧 Troubleshooting

### 起動時間の突然の増加

#### 診断手順

1. `zsh-help tools` でツール状態確認
2. プラグイン個別無効化テスト
3. `nvim --startuptime startup.log` で詳細分析

#### よくある原因

- プラグイン更新による非互換性
- PATH重複の蓄積
- キャッシュ破損

#### 解決策

```bash
# Zsh
rm -rf ~/.zcompdump*
exec zsh

# Neovim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
nvim  # 再初期化
```

### メモリ使用量の増加

#### 診断

```bash
# プロセス別メモリ
ps aux | grep -E "(zsh|nvim|wezterm)" | awk '{print $4, $11}'

# 総メモリ使用量
top -l 1 | grep PhysMem
```

#### 対策

- 履歴サイズ制限
- 未使用プラグイン削除
- キャッシュ定期クリア

## 📊 Benchmark Comparison

### 同等構成との比較

| 項目           | 本構成 | Minimal Zsh | Oh-My-Zsh | Prezto |
| -------------- | ------ | ----------- | --------- | ------ |
| 起動時間       | 1.1s   | 50ms        | 3-5s      | 1-2s   |
| プラグイン数   | 12+    | 0           | 20+       | 15+    |
| メモリ使用量   | 25MB   | 8MB         | 40MB      | 30MB   |
| 機能豊富度     | 高     | 低          | 最高      | 高     |
| カスタマイズ性 | 高     | 最高        | 中        | 高     |
| メンテナンス性 | 高     | 最高        | 低        | 中     |

評価: 機能性と速度のバランスが取れた最適構成

## 🔗 関連ドキュメント

- [Zsh Configuration](tools/zsh.md) - 詳細な最適化戦略
- [Neovim Configuration](tools/nvim.md) - プラグイン最適化
- [Workflows and Maintenance](../.claude/rules/workflows-and-maintenance.md) - 定期メンテナンス
- [Documentation Rules](../.claude/rules/documentation-rules.md) - ドキュメント管理

---

_Performance is not just about speed, but about maintaining productivity without compromises._
