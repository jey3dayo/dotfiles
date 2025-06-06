# Neovim設定管理

## フェーズ1 (完了)
- [x] 重複プラグイン定義の削除
- [x] 共通定義の統一 (`utils/filetypes.lua`, `utils/dependencies.lua`)
- [x] 設定読み込みパターンの標準化 (config vs opts)
- [x] プラグイン構成の最適化

## フェーズ2 (2025年計画)

### 高優先度
- [x] パフォーマンス最適化 (遅延読み込み、起動時間測定)
- [ ] 設定構造の改善 (ディレクトリ再編成、ファイル分割)

### 中優先度
- [ ] 開発体験向上 (DAP統合、テスト環境構築)
- [ ] 自動化 (テスト、依存関係可視化)

### 低優先度
- [ ] 新機能 (AI補完代替、ワークスペース管理)

## 主要指標
- 起動時間: 目標 <100ms
- コード重複: 既に30%削減
- プラグイン数: ~80個 (さらに最適化)

## テストコマンド
```bash
# 起動時間測定
./measure_startup.sh

# プラグイン状態確認
:Lazy
```

## 最適化内容 (完了)
- 無効プラグインの削除 (4個削除)
- 遅延読み込み追加: 25+ プラグイン
- イベント最適化: InsertEnter, BufReadPost, VeryLazy
- コマンドベース読み込み: Telescope, Mason, Trouble等

