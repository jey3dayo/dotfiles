# 🏗️ CAAD Loca Next プロジェクト固有ガイド

## 🎯 プロジェクト固有の統一規約

- **Result<T,E>パターン**: 全層で統一使用（[詳細](.claude/essential/result-pattern.md)）
- **型安全性**: `as`型アサーション完全排除、any型排除
- **バリデーション**: Zodスキーマ統一管理
- **CMX API接続**: `NODE_TLS_REJECT_UNAUTHORIZED=0` 必須

## 🏆 品質保証コマンド

```bash
# 必須実行（作業完了時）
pnpm test && pnpm type-check && pnpm lint:fix && pnpm format:prettier

# 開発中の確認
pnpm test:quick  # 高速テスト
pnpm test:fix    # テスト修正
pnpm test:e2e    # E2Eテスト
```

## 📚 重要ドキュメント（優先度順）

### 🔴 必須参照（日常開発）
1. **[⚡統合開発ガイド](.claude/essential/integration-guide.md)** - 日常開発の要点集約
2. **[🎯Result<T,E>パターン](.claude/essential/result-pattern.md)** - エラーハンドリング基本
3. **[🔧コマンド選択ガイド](docs/development/command-selection-guide.md)** - 効率的な実行

### 🟡 実装時参照
- **[マップ実装パターン](docs/development/map-implementation-patterns.md)** - マップ機能修正時
- **[CMX Konva座標系ガイド](docs/technical-specs/CMX_KONVA_COORDINATE_SYSTEM.md)** - 座標変換実装時
- **[Vitestタイムアウト対策](.claude/troubleshoot/vitest-optimization.md)** - テストエラー時

### 📋 アーキテクチャ層別ガイド
- **[レイヤー概要](docs/layers/layer-overview.md)** - アーキテクチャ全体像
- **[コア層ガイド](docs/layers/core-layers.md)** - Service/Action/Transform/Repository層
- **[コンポーネント層ガイド](docs/layers/component-layers.md)** - Server/Client Component層

## 🔧 プロジェクト固有の実装制約

### Prisma使用制限
- Server Component層: Service層経由必須
- Client Component層: 使用不可
- Service層: 直接使用OK

### Server Actions統合
- FormData検証: Zodスキーマ使用
- エラーハンドリング: `localizeServiceError()`
- 型変換: `toServerActionResult()`

## 🚀 実装順序（新機能追加時）

1. Schema層 → 2. Database層 → 3. Transform層 → 4. Service層 → 5. Action層
→ 6. Server Component層 → 7. Client Component層 → 8. Test層

## 📊 プロジェクトステータス
- **現在**: 🎯 機能完成・🔧 保守性改善フェーズ
- **品質**: 全テスト成功 / 型エラー0件 / any型完全排除

## 🤖 技術サポート

### o3 MCP技術相談（英語）
複雑なエラーや技術的問題は o3 MCP に相談可能。相談後は日本語で要約報告。

---

**その他**:
- 一時ファイルは`./tmp`フォルダに出力
- プロジェクト詳細: [README.md](./README.md)
