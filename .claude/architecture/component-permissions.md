# Component-Specific Claude Permissions

このドキュメントでは、各コンポーネント固有のClaude権限設定について説明します。

## 🎯 権限管理の方針

### 分散設定の理由
- **最小権限の原則**: 各コンポーネントは必要最小限の権限のみ保持
- **セキュリティ境界**: コンポーネント間で権限を分離
- **保守性**: 権限変更時の影響範囲を限定

## 📂 コンポーネント別権限設定

### Zsh権限 (`zsh/.claude/settings.local.json`)
- **対象**: シェル設定、プラグイン管理、パフォーマンス最適化
- **主な権限**:
  - Sheldon操作 (`sheldon source`, `sheldon lock`)
  - Zsh設定診断 (`zsh -c`, `source ~/.zshrc`)
  - パフォーマンス測定 (`zsh-benchmark`, `zsh-profile`)
  - 設定ファイル操作 (`.config/zsh/` 内のファイル読み書き)
- **詳細権限**:
  ```json
  "Bash(sheldon source)", "Bash(sheldon lock:*)",
  "Bash(zsh -c:*)", "Bash(source:*)",
  "Bash(ls:*)", "Bash(grep:*)", "Bash(find:*)",
  "Bash(rm:*)", "Bash(cp:*)", "Bash(rg:*)"
  ```

### WezTerm権限 (`wezterm/.claude/settings.local.json`)
- **対象**: ターミナル設定、Lua設定管理
- **主な権限**:
  - WezTerm設定操作 (`wezterm`, `lua`)
  - 設定ファイル移動・変更 (`mv`)
- **詳細権限**:
  ```json
  "Bash(lua:*)", "Bash(mv:*)", "Bash(wezterm:*)"
  ```

### Vim/Neovim権限 (`.vim/.claude/settings.local.json`)
- **対象**: エディタ設定、プラグイン管理
- **主な権限**:
  - Neovim操作 (`nvim`)
  - ファイル検索・操作 (`find`, `grep`, `timeout`)
- **詳細権限**:
  ```json
  "Bash(find:*)", "Bash(nvim:*)", "Bash(timeout:*)",
  "Bash(ls:*)", "Bash(grep:*)"
  ```

## 🔧 権限設定パターン

### 基本テンプレート
```json
{
  "permissions": {
    "allow": [
      "Bash(tool-specific-command:*)",
      "Bash(ls -la specific-path)",
      "Bash(find specific-path -name pattern)"
    ],
    "deny": []
  }
}
```

### 段階的権限設定
1. **読み取り専用**: `ls`, `grep`, `find` のみ
2. **設定変更**: 上記 + `mv`, `cp`, ツール固有コマンド
3. **完全権限**: 上記 + `rm`, `install` コマンド

## 🚫 セキュリティ考慮事項

### 禁止されるパターン
- **全権限付与**: `"Bash(*)"` は使用禁止
- **システム操作**: `sudo`, `rm -rf /` 等の危険なコマンド
- **ネットワーク操作**: 不要な外部通信権限

### 推奨されるパターン
- **具体的パス指定**: ワイルドカードより具体的なパス
- **コマンド制限**: 必要なオプションのみ許可
- **定期レビュー**: 権限の定期的な見直し

## 📋 権限管理ワークフロー

### 新しい権限追加
1. **必要性確認**: 最小限の権限で目的達成可能か検証
2. **具体的定義**: 曖昧な権限設定を避け、具体的に定義
3. **テスト実行**: 権限変更後の動作確認
4. **ドキュメント更新**: この文書への記録

### 権限削除・変更
1. **影響範囲確認**: 削除・変更による機能への影響
2. **段階的変更**: 一度に大量の権限を変更しない
3. **バックアップ**: 変更前の設定をバックアップ

## 📝 具体的な権限設定例

### Zsh詳細権限（抜粋）
```json
{
  "permissions": {
    "allow": [
      "Bash(abbr list)",
      "Bash(brew install:*)",
      "Bash(brew search:*)",
      "Bash(pip3 install:*)",
      "Bash(sheldon init zsh)",
      "Bash(ZSH_DEBUG=1 zsh -i -c \"zsh-benchmark\")",
      "Bash(ZSH_DEBUG=1 zsh -i -c \"zsh-profile\" 2 > /dev/null)",
      "Bash(rg -l \"lazy-sources\" /Users/t00114/.config/zsh)",
      "Bash(zsh -c \"source ~/.zshrc && abbr list\")"
    ]
  }
}
```

## 💡 ベストプラクティス

### 成功パターン
- **コンポーネント分離**: 各ツール固有の権限を適切に分離
- **最小権限**: 必要最小限の権限のみ付与
- **明示的許可**: 必要な操作を明確に定義
- **パス制限**: 特定のディレクトリに限定した操作権限

### 避けるべきパターン
- **包括的権限**: `*` を使った広範囲な権限
- **重複権限**: 複数コンポーネントで同じ権限を重複設定
- **未使用権限**: 使用しない権限の放置

---

*最終更新: 2025-06-20*
*権限管理状態: コンポーネント分離完了*