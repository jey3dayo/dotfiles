# インタラクティブ実行パターン集

実際の使用例とUIパターンを紹介します。

## パターン1: 単一タスク選択

### シナリオ

P1の簡単なバグ修正を即座に実行する

### 実行例

```
$ todo-orchestrator

=== 統合タスク一覧 ===
[1] 🟢 P1 | Fix login validation bug (1h)
[2] 🟢 P1 | Update error messages (30m)
[3] 🟡 P2 | Add user profile page (4h)
[4] 🟠 P3 | Refactor auth module (1d)

実行するタスク番号を選択: 1

=== 実行前確認 ===
タスク: Fix login validation bug
優先度: P1 🟢
推定: 1時間
依存: なし
影響: auth/login.ts, tests/auth.test.ts

実行しますか? (y/n/skip): y

[実行中] Fix login validation bug
[1/5] バリデーション修正... ✓ (18m)
[2/5] テスト追加... ✓ (22m)
[3/5] テスト実行... ✓ (8m)
[4/5] Lint/Format... ✓ (4m)
[5/5] 手動確認... ✓ (5m)

✓ タスク完了 (57m / 推定60m)
✓ TodoWrite更新済み
```

## パターン2: 範囲指定選択

### シナリオ

複数の関連タスクを連続実行する

### 実行例

```
$ todo-orchestrator

=== 統合タスク一覧 ===
[1] 🟢 P1 | Fix validation bug (1h)
[2] 🟢 P1 | Update error messages (30m)
[3] 🟢 P1 | Add loading indicators (45m)
[4] 🟡 P2 | Add profile page (4h)

実行するタスク番号を選択: 1-3

=== 選択されたタスク ===
[1] Fix validation bug (1h)
[2] Update error messages (30m)
[3] Add loading indicators (45m)

合計推定時間: 2h 15m

実行順序を確認:
  1. Fix validation bug
  2. Update error messages
  3. Add loading indicators

並列実行可能: タスク1, 2（ファイル競合なし）
順次実行必要: タスク3（タスク1完了後）

実行しますか? (y/n/edit): y

[並列実行] タスク1, 2
[1/3] Fix validation bug... ✓ (52m)
[2/3] Update error messages... ✓ (28m)
[順次実行] タスク3
[3/3] Add loading indicators... ✓ (40m)

✓ 全タスク完了 (1h 52m / 推定2h 15m)
```

## パターン3: 優先度一括選択

### シナリオ

高優先度タスクを一括実行する

### 実行例

```
$ todo-orchestrator

=== 統合タスク一覧 ===
[1] 🟢 P1 | Fix validation bug (1h)
[2] 🟢 P1 | Update error messages (30m)
[3] 🟢 P1 | Add loading indicators (45m)
[4] 🟡 P2 | Add profile page (4h)
[5] 🟠 P3 | Refactor auth (1d)

実行するタスク番号を選択: high

=== 高優先度タスク（P1） ===
[1] Fix validation bug (1h)
[2] Update error messages (30m)
[3] Add loading indicators (45m)

3タスクを実行します。続行しますか? (y/n): y

[実行計画]
最適化実行順序:
  並列グループ1: タスク1, 2
  順次グループ2: タスク3（タスク1完了後）

推定完了時間: 1h 40m

開始しますか? (y/n): y

[並列実行] タスク1, 2...
  ✓ Fix validation bug (52m)
  ✓ Update error messages (28m)

[順次実行] タスク3...
  ✓ Add loading indicators (40m)

✓ 全タスク完了 (1h 32m / 推定1h 40m)
```

## パターン4: タスクスキップ

### シナリオ

今は実行できないタスクをスキップする

### 実行例

```
$ todo-orchestrator

=== 統合タスク一覧 ===
[1] 🟢 P1 | Fix validation bug (1h)
[2] 🟡 P2 | Add profile page (4h) [依存: User API]
[3] 🟠 P3 | Refactor auth (1d)

実行するタスク番号を選択: 2

=== 実行前確認 ===
タスク: Add profile page
依存: User API (未完了)

⚠ 依存タスク「User API」が未完了です。

選択してください:
  y     - User APIを先に実行してから続行
  skip  - 次回まで延期
  n     - キャンセル

> skip

✓ タスクを延期しました（次回セッションで再表示）

次のタスクを選択しますか? (y/n): y

=== 統合タスク一覧 ===
[1] 🟢 P1 | Fix validation bug (1h)
[3] 🟠 P3 | Refactor auth (1d)

実行するタスク番号を選択: 1
```

## パターン5: 依存関係自動解決

### シナリオ

依存タスクを自動的に先に実行する

### 実行例

```
$ todo-orchestrator

=== 統合タスク一覧 ===
[1] 🟠 P3 | Refactor auth module (1d)
[2] 🟦 P4 | SSO integration (2d) [依存: タスク1]

実行するタスク番号を選択: 2

=== 依存関係検出 ===
タスク「SSO integration」は以下に依存:
  [1] Refactor auth module (未完了)

依存タスクを先に実行しますか? (y/n/manual):
  y      - 自動的に依存タスクを先に実行
  n      - 延期（依存完了後に実行）
  manual - 手動で実行順序を調整

> y

[実行計画]
1. [P3] Refactor auth module (1d) → 依存タスク
2. [P4] SSO integration (2d)  → 本タスク

合計推定時間: 3日

実行しますか? (y/n): y

[1/2] Refactor auth module...
  [Phase 1] 設計レビュー... ✓ (1h)
  [Phase 2] リファクタリング... ✓ (3h)
  [Phase 3] テスト更新... ✓ (2h)
  [Phase 4] 統合テスト... ✓ (1h)
  [Phase 5] 手動確認... ✓ (1h)
✓ 完了 (8h / 推定8h)

[2/2] SSO integration...
  [Phase 1] 技術設計レビュー... ✓ (2h)
  [Phase 2] SSO provider統合... ✓ (4h)
  [Phase 3] 既存認証統合... ✓ (4h)
  [Phase 4] テスト実装... ✓ (3h)
  [Phase 5] 統合テスト... ✓ (2h)
  [Phase 6] 本番環境検証... ✓ (1h)
✓ 完了 (16h / 推定16h)

✓ 全タスク完了 (24h / 推定24h)
✓ ブロックされていた後続タスクを解除しました
```

## パターン6: エラーハンドリング

### シナリオ

実行中にテストが失敗した場合の処理

### 実行例

```
$ todo-orchestrator

実行するタスク番号を選択: 1

[実行中] Fix validation bug

[1/5] バリデーション修正... ✓ (18m)
[2/5] テスト追加... ✓ (22m)
[3/5] テスト実行...
  ✗ 既存テスト失敗: auth.test.ts:45
    Expected: "Invalid email"
    Received: "Invalid email format"

⚠ テスト失敗を検出しました。

選択してください:
  fix   - エラーを修正してリトライ
  skip  - このステップをスキップ（非推奨）
  abort - タスクを中断

> fix

[修正中] テストエラーを分析...
  原因: エラーメッセージの文言変更による不一致
  修正: auth.test.ts の期待値を更新

[3/5] テスト実行... ✓ (10m)
[4/5] Lint/Format... ✓ (4m)
[5/5] 手動確認... ✓ (5m)

✓ タスク完了 (エラー修正込み: 1h 12m / 推定60m)

=== 学習データ記録 ===
- テストエラーパターン: メッセージ文言変更
- 修正時間: +12分
- 次回推定に反映: ✓
```

## パターン7: 編集モード

### シナリオ

実行前にタスク内容を編集する

### 実行例

```
$ todo-orchestrator

実行するタスク番号を選択: 1

=== 実行前確認 ===
タスク: Fix validation bug
推定: 1時間
影響: auth/login.ts, tests/

実行しますか? (y/n/skip/edit): edit

=== タスク編集モード ===
[1] タイトル: Fix validation bug
[2] 優先度: P1
[3] 推定工数: 1h
[4] 影響範囲: auth/login.ts, tests/
[5] 依存関係: なし
[6] メモ: -

編集する項目を選択: 3

現在の推定工数: 1h
新しい推定工数: 2h

理由（省略可）: バリデーションロジックが複雑

✓ 推定工数を更新しました: 1h → 2h

他に編集しますか? (y/n): n

=== 更新後の確認 ===
タスク: Fix validation bug
推定: 2時間 （更新済み）
影響: auth/login.ts, tests/

実行しますか? (y/n): y
```

## パターン8: 実行ログ詳細

### シナリオ

詳細な実行ログを表示する

### 実行例

```
$ todo-orchestrator --verbose

実行するタスク番号を選択: 1

[実行開始] 2024-01-15 10:00:00
タスクID: task-abc123
優先度: P1

[Phase 1/5] バリデーション修正
  ├─ [10:00:05] ファイル読み込み: auth/login.ts
  ├─ [10:00:08] バリデーションロジック分析
  │   └─ 検出: emailValidation(), passwordValidation()
  ├─ [10:00:12] パッチ適用
  │   ├─ 変更行: 45-52
  │   └─ 追加: null/undefined チェック
  ├─ [10:00:18] ファイル保存: auth/login.ts
  └─ ✓ 完了 (18分)

[Phase 2/5] テスト追加
  ├─ [10:18:05] ファイル読み込み: tests/auth.test.ts
  ├─ [10:18:10] 既存テストケース分析
  │   └─ 検出: 12件のテストケース
  ├─ [10:18:15] 新規テストケース作成
  │   ├─ 追加: testEmptyEmail()
  │   ├─ 追加: testInvalidFormat()
  │   └─ 追加: testBoundaryValues()
  ├─ [10:40:18] ファイル保存: tests/auth.test.ts
  └─ ✓ 完了 (22分)

[Phase 3/5] テスト実行
  ├─ [10:40:25] npm test auth 実行
  ├─ [10:42:30] 既存テスト結果
  │   ├─ ✓ 成功: 12/12
  │   └─ 経過時間: 1m 15s
  ├─ [10:43:45] 新規テスト結果
  │   ├─ ✓ 成功: 3/3
  │   └─ 経過時間: 48s
  └─ ✓ 完了 (8分)

[Phase 4/5] Lint/Format
  ├─ [10:48:30] npm run lint 実行
  │   ├─ ✓ ESLint: 0 errors, 0 warnings
  │   └─ 経過時間: 1m 30s
  ├─ [10:50:00] npm run format 実行
  │   ├─ ✓ Prettier: 2 files formatted
  │   └─ 経過時間: 30s
  └─ ✓ 完了 (4分)

[Phase 5/5] 手動確認
  ├─ [10:52:15] ブラウザで動作確認
  ├─ [10:54:30] 正常系テスト
  │   └─ ✓ ログイン成功
  ├─ [10:55:45] 異常系テスト
  │   ├─ ✓ 空メール: エラー表示
  │   └─ ✓ 不正形式: エラー表示
  └─ ✓ 完了 (5分)

[実行完了] 2024-01-15 10:57:30
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
合計時間:     57分
推定時間:     60分
精度:         95%

変更ファイル:  2
  - auth/login.ts (+15, -8)
  - tests/auth.test.ts (+42, -0)

テスト結果:
  既存: 12/12 ✓
  新規: 3/3 ✓

次回推奨タスク:
  [2] Update error messages (関連: auth/)
```

## パターン9: バッチ実行

### シナリオ

複数タスクを非対話的に一括実行する

### 実行例

```
$ todo-orchestrator batch 1,3,5

=== バッチ実行モード ===
選択タスク: 3件

[1] 🟢 P1 | Fix validation bug (1h)
[3] 🟡 P2 | Add profile page (4h)
[5] 🟠 P3 | Refactor auth (1d)

実行順序（依存関係最適化済み）:
  1. Fix validation bug
  2. Add profile page
  3. Refactor auth

合計推定時間: 13時間

全タスクを自動実行しますか? (y/n): y

[バッチ実行開始] 2024-01-15 10:00:00
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1/3] Fix validation bug
  ✓ 完了 (52m / 推定60m)

[2/3] Add profile page
  ✓ 完了 (3h 45m / 推定4h)

[3/3] Refactor auth
  ✓ 完了 (7h 30m / 推定8h)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[バッチ実行完了] 2024-01-15 22:07:00

成功: 3/3 (100%)
合計時間: 12h 7m
推定時間: 13h
精度: 93%

✓ TodoWrite更新済み
✓ 学習データ蓄積済み
```

## パターン10: スマート実行モード

### シナリオ

AI駆動で最適なタスク順序を自動決定する

### 実行例

```
$ todo-orchestrator --mode=smart

[AI分析中] 最適なタスク実行順序を計算...

=== スマート実行プラン ===
ROI（投資対効果）最適化に基づく実行順序:

優先度1: 🟢 P1 タスク（即座実行可能）
  [1] Fix validation bug (ROI: 9.2)
  [2] Update error messages (ROI: 8.0)

優先度2: 🟡 P2 タスク（標準実行）
  [3] Add loading indicators (ROI: 7.5)

ブロック解除: 🟠 P3 タスク（後続タスクをブロック中）
  [4] Refactor auth (ROI: 5.2)
      └─ ブロック解除: SSO integration

推奨実行順序:
  1 → 2 → 3 → 4

理由:
- タスク1, 2: 高ROI、即座実行可能
- タスク3: UX改善、ユーザー影響大
- タスク4: 後続タスク（SSO）のブロック解除

実行しますか? (y/n/edit): y

[スマート実行開始]
最適化戦略: ROI優先 + ブロック解除
```
