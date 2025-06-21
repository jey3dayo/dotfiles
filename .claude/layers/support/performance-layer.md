# Performance Layer - System Optimization & Monitoring

このレイヤーでは、dotfiles全体のパフォーマンス測定、最適化手法、ボトルネック特定に関する知見を体系化します。

## 🎯 責任範囲

- **Startup Performance**: シェル、エディタ、ターミナルの起動時間最適化
- **Runtime Performance**: 実行時レスポンス、メモリ使用量最適化
- **Monitoring**: パフォーマンス測定、継続監視、レポート生成
- **Optimization**: ボトルネック特定、最適化戦略立案・実行

## 📊 測定パターン

### シェル起動時間測定

```zsh
# ベンチマーク関数
zsh-benchmark() {
    local times=${1:-5}
    local total=0
    echo "Measuring Zsh startup time ($times runs)..."

    for i in {1..$times}; do
        local start=$(gdate +%s.%N)
        zsh -i -c exit
        local end=$(gdate +%s.%N)
        local time=$(echo "$end - $start" | bc -l)
        total=$(echo "$total + $time" | bc -l)
        echo "Run $i: ${time}s"
    done

    local average=$(echo "scale=3; $total / $times" | bc -l)
    echo "Average startup time: ${average}s"
}

# プロファイリング
zsh-profile() {
    zsh -i -c 'zmodload zsh/zprof; source ~/.zshrc; zprof | head -20'
}
```

### Neovim起動時間測定

```lua
-- Neovim起動時間測定
local M = {}

function M.benchmark_startup()
    local times = {}
    local iterations = 10

    for i = 1, iterations do
        local start = vim.fn.reltime()
        -- プラグイン読み込みのシミュレーション
        vim.cmd('source ~/.config/nvim/init.lua')
        local elapsed = vim.fn.reltimefloat(vim.fn.reltime(start))
        table.insert(times, elapsed)
    end

    local total = 0
    for _, time in ipairs(times) do
        total = total + time
    end

    local average = total / iterations
    print(string.format('Average startup time: %.2fms', average * 1000))
end

-- 個別プラグイン測定
function M.profile_plugins()
    vim.cmd('profile start ~/.config/nvim/profile.log')
    vim.cmd('profile func *')
    vim.cmd('profile file *')

    -- 通常の使用をシミュレート
    vim.defer_fn(function()
        vim.cmd('profile pause')
        print('Profile saved to ~/.config/nvim/profile.log')
    end, 5000)
end

return M
```

### システムリソース監視

```zsh
# メモリ使用量監視
monitor-memory() {
    while true; do
        echo "=== Memory Usage $(date) ==="
        ps aux | head -1
        ps aux | grep -E "(zsh|nvim|wezterm|tmux)" | grep -v grep
        echo ""
        sleep 5
    done
}

# CPU使用率監視
monitor-cpu() {
    iostat -c 1 | while read line; do
        echo "$(date): $line"
    done
}
```

## ⚡ 最適化戦略

### 遅延読み込みパターン

```zsh
# 重いツールの遅延読み込みテンプレート
lazy_load_tool() {
    local tool_name="$1"
    local init_command="$2"

    # プレースホルダー関数作成
    eval "${tool_name}() {
        unfunction ${tool_name}
        eval \"\$(${init_command})\"
        ${tool_name} \"\$@\"
    }"
}

# 使用例
lazy_load_tool "mise" "mise activate zsh"
lazy_load_tool "kubectl" "kubectl completion zsh"
```

### プラグイン最適化

```zsh
# Sheldon プラグイン優先度設定
# ~/.config/sheldon/plugins.toml

# 1. Critical (即座に必要)
[plugins.zsh-syntax-highlighting]
priority = 1
github = "zsh-users/zsh-syntax-highlighting"

# 2. Performance (パフォーマンス向上)
[plugins.zsh-autosuggestions]
priority = 2
github = "zsh-users/zsh-autosuggestions"

# 3. Navigation (ナビゲーション)
[plugins.fzf-tab]
priority = 3
github = "Aloxaf/fzf-tab"

# 4. Git (Git統合)
[plugins.git-extras]
priority = 4
github = "tj/git-extras"

# 5. Tools (開発ツール)
[plugins.docker-compose]
priority = 5
github = "docker/compose"
use = ["completion/zsh/_docker-compose"]

# 6. Optional (オプション機能)
[plugins.zsh-completions]
priority = 6
github = "zsh-users/zsh-completions"
```

## 📈 パフォーマンス指標

### 現在の測定値

```bash
# 2025-06-20 時点のベンチマーク結果
# Zsh起動時間: 1.2s (目標: 1.0s)
# Neovim起動時間: 95ms (目標: 100ms以下) ✅
# WezTerm起動時間: 800ms (目標: 500ms)
# Git操作レスポンス: 平均200ms (目標: 150ms)
```

### 改善履歴

```markdown
## 2025-06-09: Zsh最適化

- **改善前**: 2.0s
- **改善後**: 1.2s
- **削減率**: 40%
- **主な対策**: Sheldon 6段階優先度設定、mise遅延読み込み(-39.88ms)
- **技術**: 条件分岐読み込み、モジュラー構成

## 2025-06-08: Neovim最適化

- **改善前**: 250ms
- **改善後**: 95ms
- **削減率**: 62%
- **主な対策**: lazy.nvim導入、不要プラグイン削除、LSP最適化
- **技術**: Lua-based設定、遅延読み込み最適化

## 2025-06-07: Git統合強化

- **改善前**: 煩雑なGit操作
- **改善後**: 50%時間短縮
- **主な対策**: Zsh略語展開、FZF統合、ghq管理
- **技術**: Widget作成、ブランチ・リポジトリ選択自動化

## 2025-06-05: Terminal環境統一

- **改善前**: 不整合なターミナル設定
- **改善後**: 一貫したターミナル体験
- **主な対策**: 共通カラーパレット、フォント統一、キーバインド標準化
- **技術**: Gruvbox + JetBrains Mono統一、Nerd Fonts活用
```

## 🔧 診断ツール

### 総合診断スクリプト

```zsh
# パフォーマンス総合診断
perf-check() {
    echo "=== Dotfiles Performance Check ==="
    echo "Date: $(date)"
    echo ""

    # Zsh起動時間
    echo "📊 Zsh Startup Time:"
    zsh-benchmark 3
    echo ""

    # Neovim起動時間
    echo "📊 Neovim Startup Time:"
    nvim --startuptime /tmp/nvim-startup.log +qa
    tail -1 /tmp/nvim-startup.log
    echo ""

    # システムリソース
    echo "📊 System Resources:"
    echo "Memory: $(free -h | grep '^Mem:' | awk '{print $3 "/" $2}')"
    echo "CPU Load: $(uptime | awk -F'load average:' '{print $2}')"
    echo ""

    # ディスク使用量
    echo "📊 Dotfiles Size:"
    du -sh ~/.config ~/.local/share/nvim ~/.tmux 2>/dev/null | sort -hr
}

# ボトルネック特定
find-bottlenecks() {
    echo "=== Performance Bottleneck Analysis ==="

    # 遅いコマンドの特定
    echo "🔍 Slow commands in history:"
    fc -l -100 | awk '{print $2}' | sort | uniq -c | sort -nr | head -10

    # 大きなファイルの特定
    echo "🔍 Large files in dotfiles:"
    find ~ -name ".*rc" -o -name ".*profile" -o -name ".config" -type f -size +1k 2>/dev/null | head -10

    # プロセス使用量
    echo "🔍 Resource-heavy processes:"
    ps aux --sort=-%cpu | head -10
}
```

## 🎯 最適化ターゲット

### 短期目標 (1-2週間)

- [ ] Zsh起動時間: 1.2s → 1.0s (17%削減)
- [ ] WezTerm起動時間: 800ms → 600ms (25%削減)
- [ ] Git操作レスポンス: 200ms → 150ms (25%削減)

### 中期目標 (1-2ヶ月)

- [ ] 全体的なメモリ使用量10%削減
- [ ] プラグイン数を現在の30%削減
- [ ] 設定ファイルサイズの最適化

### 長期目標 (3-6ヶ月)

- [ ] 自動最適化システムの構築
- [ ] パフォーマンス回帰防止機能
- [ ] ベンチマーク継続監視システム

## 💡 最適化知見

### 成功パターン

- **遅延読み込み**: 30-50%の起動時間短縮効果
- **プラグイン整理**: 不要機能削除で20-30%改善
- **設定分割**: モジュール化で保守性と性能両立

### 失敗パターン

- **過度の最適化**: 可読性・保守性を犠牲にした微最適化
- **測定不備**: 体感速度と実測値の乖離
- **依存関係無視**: 最適化による機能破綻

### 測定の重要性

- **定期測定**: 週1回のベンチマーク実行
- **環境依存**: 異なるマシンでの一貫性確認
- **回帰検出**: 設定変更後の性能確認

## 🔗 関連層との連携

- **Shell Layer**: Zsh起動時間最適化、プラグイン管理
- **Editor Layer**: Neovim起動時間、プラグイン最適化
- **Terminal Layer**: 描画性能、GPU最適化
- **Tools Layer**: 各ツールの個別最適化

---

_最終更新: 2025-06-20_
_現在の状態: Zsh 1.2s, Neovim 95ms, 継続最適化中_
_次回見直し: 2025-07-01_
