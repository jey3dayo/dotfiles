# 類似度分析コマンド - Dotfiles設定重複検出

dotfiles内の重複した設定やコードパターンを検出し、設定ファイルを最適化します。

## 使用方法

```bash
/similarity [options]
```

オプション:

- `--threshold <percentage>`: 類似度の閾値設定（デフォルト: 80%）
- `--auto`: 安全な重複（90%以上）を自動除去
- `--type <filetype>`: 特定のファイルタイプのみ分析 (zsh, lua, toml)

## 基本的な使い方

### 1. 全設定ファイルの重複検出

```bash
/similarity
```

### 2. 高い類似度のみ検出

```bash
/similarity --threshold 90
```

### 3. Zsh設定のみ分析

```bash
/similarity --type zsh
```

### 4. 明らかな重複を自動除去

```bash
/similarity --threshold 90 --auto
```

## 検出対象パターン

### Zsh設定 (.zsh)

- 重複した関数定義
- 類似したalias設定
- 繰り返されるPATH設定
- 同じようなexportパターン

### Lua設定 (WezTerm/Neovim)

- 重複したキーバインド設定
- 類似した設定テーブル
- 繰り返されるイベントハンドラ
- 同じようなプラグイン設定

### TOML設定 (Sheldon/Starship/Mise)

- 重複したプラグイン定義
- 類似したプロンプト設定
- 繰り返される依存関係

## 出力例

```
🔍 Dotfiles重複検出結果
━━━━━━━━━━━━━━━━━━━━
✓ 95%以上: 3件
  - zsh/config/tools/git.zsh:15-25 ≈ zsh/functions/git-helpers.zsh:8-18 (96%)
  - wezterm/keybinds.lua:45-60 ≈ wezterm/win.lua:12-27 (95%)

✓ 80-95%: 8件
  [詳細は reports/similarity.md 参照]

💡 推奨アクション:
  - Zsh関数を共通ヘルパーに統合
  - WezTermキーバインドをconfig.luaに集約
```

## 自動除去の仕組み

`--auto`オプション使用時は、以下の条件で安全に重複を除去します：

1. **90%以上の類似度**がある場合のみ対象
2. **設定ファイルの構造**を保ちながら統合
3. **パフォーマンス最適化**を考慮した統合
4. **動作確認**（zsh -n, lua -l等）を実行

## 最適化パターン

### Zsh最適化

```bash
# Before: 複数ファイルに散在
# zsh/config/tools/git.zsh
alias gst='git status'
alias gco='git checkout'

# zsh/config/core/aliases.zsh
alias gst='git status'  # 重複！

# After: 統合済み
# zsh/config/core/aliases.zsh
[[ -f "$ZDOTDIR/aliases/git.zsh" ]] && source "$ZDOTDIR/aliases/git.zsh"
```

### Lua最適化

```lua
-- Before: 重複したキーバインド
-- wezterm/keybinds.lua
{ key = 'n', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' }

-- wezterm/win.lua
{ key = 'n', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' } -- 重複！

-- After: 共通設定に統合
-- wezterm/config.lua
local common_keys = require('keybinds').get_common_keys()
```

## レポートファイル

実行結果は `reports/similarity.md` に出力されます：

```markdown
# Dotfiles重複分析レポート

## サマリー

- 総ファイル数: 52
- 分析対象: 48 (.zsh: 24, .lua: 15, .toml: 9)
- 検出された重複: 12件

## パフォーマンスインパクト

- Zsh起動時間への影響: 約50ms（重複source）
- メモリ使用量: 約2MB（重複定義）

## 詳細

### 96% - Git alias重複

- ファイル1: zsh/config/tools/git.zsh:15-25
- ファイル2: zsh/functions/git-helpers.zsh:8-18
- 推奨: 共通aliasファイルに統合
- 期待効果: 起動時間 -15ms
```

## 統合後の検証

自動統合後は以下を実行して動作確認：

```bash
# Zsh設定の検証
zsh -n ~/.zshrc
zsh-benchmark  # 起動時間確認

# Lua設定の検証
lua -l wezterm.lua -e "print('Config OK')"

# 設定リロード
exec zsh  # Zsh再起動
```

## 注意事項

- **パフォーマンス優先**: 統合時は起動時間への影響を最優先
- **モジュラー性維持**: 機能別の分離は保ちつつ重複を除去
- **段階的実施**: Tool別（Zsh/WezTerm/Neovim）に分けて実行
- **バックアップ推奨**: 自動統合前にGitコミット推奨

## 関連コマンド

- **/refactoring** - Tool別の高度な設定改善
- **/learnings** - 統合パターンを層別知見として記録

---

**🎯 ゴール**: Dotfiles内の重複を検出し、起動パフォーマンスを維持しながら設定を最適化
