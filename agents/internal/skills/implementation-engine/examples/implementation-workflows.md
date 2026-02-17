# Implementation Workflows

Implementation Engineの実装ワークフロー実例集。単一ソース、複数ソース、セッションレジューム、Deep Validationの実際の使用例。

## 単一ソース実装

### URL from GitHub

```bash
/implement https://github.com/user/awesome-feature
```

### 実行フロー

```
1. URL検出 → GitHub repository
2. WebFetchでリポジトリ分析
3. プロジェクト構造の理解
4. plan.md作成
5. 計画提示 → ユーザー承認待ち
6. 段階的実装
7. 品質チェック
8. 完了報告
```

### 生成ファイル

```
implement/
├── plan.md
├── state.json
└── source-analysis.md (Deep Validation時)
```

### ローカルディレクトリ

```bash
/implement ./legacy-code/auth-system/
```

### 実行フロー

```
1. ローカルパス検出 → directory
2. ファイルリストの取得
3. コードファイルの段階的読み込み
4. アーキテクチャパターンの抽出
5. plan.md作成
6. 適応戦略の決定
7. 実装実行
8. テスト実行
9. 完了報告
```

### 機能説明文

```bash
/implement "Stripeのような決済処理システム。クレジットカード、サブスクリプション、請求書管理をサポート"
```

### 実行フロー

```
1. 説明文検出 → feature description
2. キーフレーズ抽出
3. 類似実装のリサーチ
4. ベストプラクティスの収集
5. 要件定義の作成
6. plan.md作成
7. 実装実行
8. 完了報告
```

## 複数ソース統合

### URL + ローカルコード

```bash
/implement https://github.com/stripe/stripe-js ./local-examples/payment-flow/
```

### 実行フロー

```
1. 複数ソース検出
   - Source 1: GitHub repository
   - Source 2: Local directory

2. 各ソースを並列分析
   - Stripe公式実装パターン
   - ローカルプロジェクトの既存コード

3. 統合計画の作成
   - Stripeパターン + ローカル規約
   - 競合解決戦略
   - 統合ポイント定義

4. plan.md作成（統合版）

5. 段階的実装
   - Phase 1: Stripe SDK統合
   - Phase 2: ローカルパターン適応
   - Phase 3: テスト作成

6. 統合テスト

7. 完了報告
```

### 複数GitHub repos

```bash
/implement https://github.com/auth-provider/sdk https://github.com/example/auth-integration
```

### 実行フロー

```
1. 複数URL検出

2. 各リポジトリ分析
   - SDK実装の理解
   - 統合例の研究

3. 統合計画
   - SDKの最新バージョン使用
   - 統合例からベストプラクティス抽出
   - プロジェクトへの適応

4. 実装実行

5. 完了報告
```

## セッションレジューム

### 自動レジューム

```bash
# 初回実行
/implement https://github.com/user/feature

# ... 途中で中断 ...

# 次回セッション
/implement
# → 自動的に既存セッションを検出してレジューム
```

### レジューム時の表示

```markdown
## Session Resume

Session ID: impl-2024-01-15-1234
Started: 2024-01-15 10:00:00
Last Updated: 2024-01-15 12:30:00

Progress: 8/15 tasks completed (53%)
Current Phase: Execution
Current Task: Add API integration layer

Recent Checkpoints:

- Create base module structure (10:30)
- Implement core business logic (11:45)
- Integrate with existing auth system (12:30)

Next Steps:

1. Complete API integration layer
2. Add UI components
3. Write tests

Continue? [Y/n]
```

### 明示的レジューム

```bash
/implement resume
```

### エラー時

```
Error: No active implementation session found

Options:

1. Start new session: /implement [source]
2. Check for session files in implement/ directory
```

### ステータス確認

```bash
/implement status
```

### 表示内容

```markdown
## Implementation Status

Session ID: impl-2024-01-15-1234
Source: https://github.com/user/awesome-feature
Started: 2024-01-15 10:00:00

Progress: ████████░░ 80% (12/15 tasks)

Phase Breakdown:

- [x] Phase 1: Initial Setup & Analysis (100%)
- [x] Phase 2: Strategic Planning (100%)
- [x] Phase 3: Intelligent Adaptation (100%)
- [⏳] Phase 4: Implementation Execution (75%)
- [ ] Phase 5: Quality Assurance (0%)
- [ ] Phase 6: Implementation Validation (0%)

Current Task: Write integration tests (Phase 4)

Quality Checks:

- Lint: Passing
- Tests: 10/15 passing
- Type Check: Passing
- Build: Passing

Recent Activity:

- 12:45 - Completed UI components
- 12:30 - Integrated with auth system
- 11:45 - Implemented core business logic
```

## Deep Validation実行

### finish コマンド

```bash
# 実装完了後
/implement finish
```

### 実行プロセス

```
Step 1: Deep Original Source Analysis
  - Analyzing GitHub repository...
  - Extracting all implementation patterns...
  - Creating source-analysis.md...
  ✓ Complete (2 minutes)

Step 2: Requirements Verification
  - Mapping features...
  - Checking coverage...
  - Identifying gaps...
  ✓ 24/25 features implemented (96%)

Step 3: Comprehensive Testing
  - Creating test suite...
  - Running all tests...
  - Checking coverage...
  ✓ 87% test coverage

Step 4: Deep Code Analysis
  - Scanning for TODOs...
  - Finding hardcoded values...
  - Checking error handling...
  - Analyzing security...
  - Checking accessibility...
  ✓ 2 minor issues found

Step 5: Automatic Refinement
  - Fixing test failures...
  - Completing partial implementations...
  - Adding missing error handling...
  ✓ All issues resolved

Step 6: Integration Analysis
  - Verifying integration points...
  - Checking API contracts...
  - Validating UI/UX flows...
  ✓ 8/10 integration points complete

Step 7: Completeness Report
  - Generating final report...
  ✓ Report created
```

### 完了レポート

```markdown
# Implementation Completeness Report

Status: 95% Complete - Production Ready with Minor Fixes

## Summary

Implementation successfully adapts GitHub repository to project
architecture. All critical features complete and tested.

## Feature Coverage: 24/25 (96%)

- User Authentication ✓
- Data Management ✓
- API Integration ✓
- UI Components ✓
- OAuth (partial - Google/GitHub only)

## Quality Metrics

- Test Coverage: 87%
- Lint Violations: 0
- Type Errors: 0
- Security Score: A- (95/100)
- Accessibility: WCAG 2.1 AA (98%)

## Remaining Work

### Important (2 items)

1. Fix dashboard redirect (30 min)
2. Add security headers (1 hour)

### Nice-to-have (3 items)

1. Improve ARIA labels (2 hours)
2. Add performance guide (3 hours)
3. Implement telemetry (4 hours)

## Deployment

Ready for production after completing 2 important items (1.5 hours).

Deployment checklist:

- ✓ All tests passing
- ✓ Build succeeds
- ✓ No console errors
- ⚠️ 2 minor fixes pending
```

### verify コマンド

```bash
/implement verify
```

同じ7ステッププロセスを実行。Deep Validationの検証を強調。

### complete コマンド

```bash
/implement complete
```

100%の完全性を保証するための徹底的な検証。

### enhance コマンド

```bash
/implement enhance
```

実装を洗練・最適化。パフォーマンス改善、コード品質向上を含む。

## 実践的なワークフロー例

### ケース1: 新機能の追加

### シナリオ

```bash
# Step 1: 実装開始
/implement https://github.com/auth-provider/sdk

# → plan.md が作成され、計画が提示される
# → 承認後、実装が開始される

# Step 2: 進捗確認（途中で確認したい場合）
/implement status

# Step 3: 中断（必要に応じて）
# → 自動的にstate.jsonに保存される

# Step 4: 再開（別のセッション）
/implement resume

# Step 5: 完了と検証
/implement finish

# → 完全性レポートが生成される
# → 残りの作業があれば明示される
```

### ケース2: レガシーコードの移行

### シナリオ

```bash
# Step 1: レガシーコード分析
/implement ./legacy/auth-system/

# → レガシーパターンの検出
# → 現代的な実装への変換計画

# Step 2: 段階的実装
# → 自動的にモダンなパターンに変換
# → プロジェクトの規約に適応

# Step 3: 品質チェック
/implement status

# Step 4: 完了
/implement finish
```

### ケース3: 複数ソースからの統合

### シナリオ

```bash
# Step 1: 複数ソース指定
/implement \
  https://github.com/official/sdk \
  https://github.com/community/best-practices \
  ./local-examples/

# → すべてのソースを分析
# → 統合計画を作成
# → 最適なパターンを選択

# Step 2: 統合実装
# → 競合を自動解決
# → 最良のパターンを統合

# Step 3: 検証
/implement verify

# → すべてのソースの要件を満たすか検証
# → 統合ポイントを確認
```

## トラブルシューティング

### セッションが見つからない

```bash
# 確認
ls implement/
pwd

# 解決
cd <project-root>
/implement resume
```

### 計画が古くなった

```bash
# 新規セッション開始
/implement new [source]

# → 既存セッションを無視
# → 新しい計画を作成
```

### Deep Validationが時間かかりすぎる

```bash
# 軽量なステータス確認のみ
/implement status

# → Deep Validationなし
# → 現在の進捗のみ表示
```

### 実装を完全にやり直したい

```bash
# セッションファイルを削除
rm -rf implement/

# 新規開始
/implement [source]
```

## ベストプラクティス

### セッション管理

1. 定期的に `/implement status` で進捗確認
2. 大きな変更前にgit checkpoint作成
3. 重要なマイルストーンでDeep Validation実行
4. セッションファイルをgitで管理（.gitignore除外）

### 品質保証

1. 各フェーズ完了後にテスト実行
2. `/implement finish` で最終検証
3. 本番デプロイ前に必ず検証実行
4. 完全性レポートを保存してドキュメント化

### 効率化

1. 複数ソース指定で重複作業を削減
2. セッションレジュームで中断・再開を自由に
3. スマートサンプリングで大規模リポジトリを効率的に処理
4. 並列処理で時間短縮
