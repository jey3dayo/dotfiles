# ⚡ Performance Monitoring & Optimization

最終更新: 2026-09-23
対象: 開発者・運用担当者
タグ: `category/performance`, `layer/support`, `environment/cross-platform`, `audience/developer`, `audience/ops`

パフォーマンス測定、監視、最適化のための包括的ガイドです。
測定手順・改善履歴・トラブルシュートの単一情報源は本書で管理し、実行スケジュールは [Workflows and Maintenance](tools/workflows.md) を参照します。

## 📊 Current Performance Metrics

### 主要コンポーネント

| Component       | Current                 | Industry Avg | Target | Status |
| --------------- | ----------------------- | ------------ | ------ | ------ |
| Zsh startup     | ~72ms (avg)             | 2-5s         | <100ms | ✅     |
| Neovim startup  | ~65ms (warm)            | 200-500ms    | <200ms | ✅     |
| WezTerm startup | 800ms（未再計測・旧値） | 1-2s         | <1s    | ✅     |

### 詳細ベンチマーク（開発機。Neovim は 2026-09-19 実測条件を Neovim 起動分析に記載）

#### Zsh起動分析

測定条件（2026-09-23、Mac16,6、`zsh/bin/zsh-benchmark --runs 8 --mode <mode>`、Shell: `/opt/homebrew/bin/zsh`）:

| mode              | avg    | min    | max    |
| ----------------- | ------ | ------ | ------ |
| interactive       | 0.072s | 0.062s | 0.085s |
| interactive-login | 0.071s | 0.059s | 0.079s |

Zsh <100ms 目標は達成済み。

##### 改善履歴

- 2025-01: 1.8s → 1.1s (43%高速化)
  - mise即座初期化による最適化
  - PATH管理の効率化
- 2026-09: 1.1s → ~72ms（`zsh-benchmark --runs 8` 実測、上表参照）

#### Neovim起動分析

測定条件（2026-09-19、Mac16,6、NVIM v0.12.5、`nvim --startuptime` + `-c qa`）:

- 設定: 本リポジトリ root（`XDG_CONFIG_HOME=<repo>/`、計測時 branch `docs/nvim-startup-metrics`）
- warm: 1 回ウォームアップ後に 12 試行（`--- NVIM STARTED ---` 行の累積 ms）
- cold: 上記 warm 系列の前に 1 回計測（キャッシュ冷えた初回）

| 区分 | 中央値 | 最小 | 最大 | 各試行 (ms)                                                            |
| ---- | ------ | ---- | ---- | ---------------------------------------------------------------------- |
| warm | 64.7   | 61.6 | 69.9 | 66.9, 65.9, 69.9, 63.1, 63.8, 65.2, 67.4, 68.1, 63.9, 64.2, 61.6, 64.2 |
| cold | —      | —    | —    | 153.4（1 回）                                                          |

```
Total Startup Time: ~65ms (warm 中央値; cold 初回 ~153ms)

最適化手法：
- lazy.nvim遅延読み込み
- 未使用プロバイダー無効化
- 大ファイル対策（>2MB Treesitter無効）
- プラグイン条件付き読み込み
```

##### 特徴

- 業界目標(200ms)を大幅に上回る
- 15+言語LSP対応でこの速度を維持

## 🔍 Monitoring Tools

### コマンド一覧

```bash
# Zsh パフォーマンス
zsh-benchmark              # 起動時間測定
ZSH_PROFILE_STARTUP=1 zsh -ic 'zprof'  # プロファイリング（関数別の負荷内訳）

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

### 定期測定コマンド

```bash
# Zsh
zsh/bin/zsh-benchmark --runs 8 --mode interactive

# Neovim
nvim --startuptime /tmp/nvim-startup.log +q && tail -1 /tmp/nvim-startup.log
```

## ⚡ Optimization Strategies

### Zsh最適化

#### 現在の実装

1. カテゴリ順の lib 読み込み
   - `.zshrc` が `zsh/lib/*.zsh` をカテゴリ順（core shell state → completion → agent integrations → key bindings → interactive input → platform-specific → prompt/decorators）で `source`
   - 非必須なプラグイン・ウィジェットは初回 `precmd`（`add-zsh-hook`）まで読み込みを遅延

2. mise即座初期化
   - macOS path_helper対応
   - ツール即座利用可能

3. PATH最適化
   - 重複自動除去 (`typeset -gaU path`)
   - 存在確認による無駄削除
   - 優先度制御（mise > Homebrew > system）

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

- 実測 warm 中央値 ~65ms（2026-09-19）を維持し、cold 初回 ~150ms 台も許容範囲として監視する
- プラグイン追加時の影響測定
- 四半期ごとのプロファイリング

## 📈 Performance History

### 改善記録

| 日付       | 変更内容                    | Zsh起動  | Neovim起動 | 備考                                                       |
| ---------- | --------------------------- | -------- | ---------- | ---------------------------------------------------------- |
| 2026-09-23 | Zsh起動時間の実測反映       | avg 72ms | warm ~65ms | Mac16,6; `zsh-benchmark --runs 8 --mode interactive`       |
| 2026-09-19 | Neovim 起動時間の実測反映   | 1.1s     | warm ~65ms | Mac16,6; warm 12 回・cold 1 回; `XDG_CONFIG_HOME`=worktree |
| 2025-10-16 | ドキュメント整理            | 1.1s     | <100ms     | 変更なし                                                   |
| 2025-09    | AIコマンドシステム統合      | 1.1s     | <100ms     | 影響なし                                                   |
| 2025-07    | パフォーマンス目標達成      | 1.1s     | <95ms      | 大幅改善                                                   |
| 2025-01    | mise即座初期化・PATH最適化  | 1.1s     | <100ms     | 1.8s→1.1s達成                                              |
| 2024-12    | 6段階プラグイン読み込み導入 | 1.5s     | <100ms     | 基盤構築                                                   |

## 🎯 Performance Targets

- ✅ Zsh <100ms: **達成（avg 0.072s、2026-09-23 実測、`zsh-benchmark --runs 8 --mode interactive`）**
- Neovim: 目標・達成状況は [Neovim起動分析](#neovim起動分析) を参照（2026-09-19 実測、以降更新なし）

## 🔧 Troubleshooting

### 起動時間の突然の増加

#### 診断手順

1. `zsh-benchmark` で起動時間を測定
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
| 起動時間       | 72ms   | 50ms        | 3-5s      | 1-2s   |
| プラグイン数   | 12+    | 0           | 20+       | 15+    |
| メモリ使用量   | 25MB   | 8MB         | 40MB      | 30MB   |
| 機能豊富度     | 高     | 低          | 最高      | 高     |
| カスタマイズ性 | 高     | 最高        | 中        | 高     |
| メンテナンス性 | 高     | 最高        | 低        | 中     |

評価: 機能性と速度のバランスが取れた最適構成

## 🔗 関連ドキュメント

- [Zsh Configuration](tools/zsh.md) - 詳細な最適化戦略
- [Neovim Configuration](tools/nvim.md) - プラグイン最適化
- [Workflows and Maintenance](tools/workflows.md) - 定期メンテナンス
- [Documentation Governance](documentation.md) - ドキュメント管理

---

_Performance is not just about speed, but about maintaining productivity without compromises._
