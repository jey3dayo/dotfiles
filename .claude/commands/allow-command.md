# allow-command - コマンド許可設定追加ツール

## 概要
コマンドを分析して共通の設定ファイル claude/settings.jsonに許可設定を自動追加するツール
.claude/settings.jsonではありません

## 動作フロー
1. **コマンドを貼り付け** - 実行したいコマンドを指定
2. **分析結果を確認** - どの許可が必要かを表示
3. **追記前に最終確認** - 設定追加前の確認プロンプト
4. **claude/settings.jsonに自動追記** - 許可設定を追加

## 使用例

### 基本的な使い方
```bash
allow-command "find . -name '*.js' | xargs grep -l 'console.log'"
```

### 事前確認（dry-run）
```bash
allow-command --dry-run "git status && git diff"
```

### 詳細表示
```bash
allow-command --verbose "npm run build"
```

### 確認スキップ
```bash
allow-command --yes "docker ps | grep running"
```

## 分析パターン

### 基本コマンド
```
git status → "Bash(git:*)"
```

### パイプコマンド
```
find . -name "*.js" | xargs grep "test" →
- "Bash(find:*)"
- "Bash(*| xargs*)"
```

### 複合コマンド
```
git add . && git commit →
- "Bash(git:*)"
```

### 複雑なコマンド例
```
find . -type f \( -name "*.ts" -o -name "*.js" \) | xargs grep -l "console.log" | sort
```
↓ 分析結果
```
- "Bash(find:*)"
- "Bash(*| xargs*)"
- "Bash(*| sort*)"
```

## オプション

| オプション | 説明 |
|-----------|------|
| `--dry-run`, `-d` | 実際の追記なしで結果確認 |
| `--verbose`, `-v` | 詳細な分析結果表示 |
| `--yes`, `-y` | 確認をスキップして直接追記 |
| `--help`, `-h` | ヘルプ表示 |

## 設定例

以下のような許可設定が claude/settings.json に追加されます：

```json
{
  "permissions": {
    "allow": [
      "Bash(find:*)",
      "Bash(*| xargs*)",
      "Bash(*| grep*)",
      "Bash(*| sort*)"
    ]
  }
}
```

## 注意事項

- 既存の許可設定は重複チェックされます
- パイプの最初のコマンドは `Bash(command:*)` 形式
- パイプ後のコマンドは `Bash(*| command*)` 形式
- 複合コマンド（&&, ||）は個別に分析されます
