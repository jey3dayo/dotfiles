# Phase-by-Phase Implementation Guide

Implementation Engineの6フェーズ詳細手順。各フェーズは厳密な順序で実行され、スキップは許可されません。

## Phase 1: Initial Setup & Analysis

### 必須の初期ステップ

### セッション検出と初期化

1. ディレクトリ確認: 現在の作業ディレクトリで `implement/` の存在を確認
2. セッションファイル検出:
   - `implement/state.json` を探す
   - `implement/plan.md` を探す
3. 分岐判定:
   - ファイルが見つかった場合: 既存セッションをレジューム
   - ファイルがない場合: 新規セッションを初期化
4. 実装前の完全分析: 実装を開始する前にすべての分析を完了

### 重要

### ソース検出ロジック

### Web URLs

- GitHub repositories (`github.com`)
- GitLab repositories (`gitlab.com`)
- Code playgrounds (CodePen, JSFiddle, CodeSandbox)
- Documentation sites (MDN, official docs)

### ローカルパス

- 単一ファイル (`.js`, `.ts`, `.py`, `.md` etc.)
- ディレクトリ (既存コードベース、レガシーシステム)
- 実装プラン (`.md` ファイルでチェックリスト付き)

### 機能説明文

- 自然言語での機能説明
- "Stripeのような決済処理" などの参照実装
- 技術要件の説明

### プロジェクト構造分析

### アーキテクチャパターンの理解

1. ディレクトリ構造: Globでプロジェクトレイアウトをスキャン

   ```bash
   # 例: Next.js, React, Express等のパターン検出
   src/, app/, pages/, components/, lib/, utils/
   ```

2. 既存依存関係: `package.json`, `requirements.txt`, `Cargo.toml`等を読む
   - バージョン確認
   - フレームワーク識別
   - ビルドツール検出

3. コード規約:
   - ESLint/Prettier設定
   - TypeScript設定
   - テストフレームワーク設定

4. 確立されたパターン:
   - ファイル命名規則
   - インポート構造
   - エラーハンドリングパターン
   - 状態管理アプローチ

## Phase 2: Strategic Planning

### 計画作成プロセス

### 1. ソース機能のマッピング

元のコードまたは要件をプロジェクトアーキテクチャにマッピング:

```
Original Feature          → Target Location
─────────────────────────   ───────────────────
Authentication module    → src/auth/
API integration          → lib/api/
UI components            → components/feature-name/
State management         → store/feature-name/
Tests                    → __tests__/feature-name/
```

### 2. 依存関係互換性の識別

```markdown
## Dependency Mapping

Original → Target

- axios → existing fetch wrapper (lib/fetch.ts)
- lodash → native ES6 methods
- moment → date-fns (already in project)
- react-query → existing SWR setup
```

### 3. 統合アプローチの設計

```markdown
## Integration Strategy

1. Create new feature module in src/features/feature-name/
2. Integrate with existing auth system (src/auth/)
3. Add routes to src/routes/index.ts
4. Update API client in lib/api/client.ts
5. Add UI components to components/
6. Wire up state management with existing store
```

### 4. タスク分割

実装を独立してテスト可能な単位に分割:

```markdown
## Implementation Tasks

### Core Functionality

- [ ] Create base module structure
- [ ] Implement core business logic
- [ ] Add API integration layer

### Integration

- [ ] Connect to authentication
- [ ] Wire up routing
- [ ] Integrate state management

### UI Layer

- [ ] Create base components
- [ ] Add styling (matching project theme)
- [ ] Implement user interactions

### Testing & Documentation

- [ ] Write unit tests
- [ ] Add integration tests
- [ ] Update documentation
- [ ] Add usage examples
```

### plan.md作成

### ファイルパス

### 必須セクション

1. **Source Analysis** - ソースの種類、機能、依存関係、複雑度
2. **Target Integration** - 統合ポイント、影響を受けるファイル、パターンマッチング
3. **Implementation Tasks** - 優先順位付きチェックリスト
4. **Validation Checklist** - 完了基準
5. **Risk Mitigation** - 潜在的問題とロールバック戦略

### 計画提示

実装を開始する前に、ユーザーに計画の概要を提示して承認を得る。

## Phase 3: Intelligent Adaptation

### 依存関係解決

### ライブラリマッピング戦略

1. 既存ライブラリの再利用:

   ```
   Source uses: axios
   Project has: custom fetch wrapper
   Action: Use existing wrapper instead of adding axios
   ```

2. バージョン互換性の確認:

   ```
   Source: React 18 features
   Project: React 17
   Action: Adapt code to React 17 API or propose upgrade
   ```

3. 重複の回避:

   ```
   Source: Custom utility functions
   Project: lodash already installed
   Action: Replace custom utils with lodash methods
   ```

4. 標準への更新:

   ```
   Source: Deprecated API usage
   Project: Modern standards
   Action: Update to current best practices
   ```

### コード変換パターン

### 1. 命名規則の統一

```typescript
// Source: snake_case
function user_authentication() {}

// Target: camelCase (project standard)
function userAuthentication() {}
```

### 2. エラーハンドリングパターンの適応

```typescript
// Source: try-catch everywhere
try {
  const data = await fetch();
} catch (error) {
  console.error(error);
}

// Target: Project's error boundary pattern
const { data, error } = await safeAsync(() => fetch());
if (error) return handleError(error);
```

### 3. 状態管理アプローチの維持

```typescript
// Source: useState + useEffect
const [data, setData] = useState(null);
useEffect(() => {
  fetchData().then(setData);
}, []);

// Target: Project uses SWR
const { data } = useSWR("/api/data", fetcher);
```

### 4. テストスタイルの保持

```typescript
// Source: Mocha + Chai
describe("feature", () => {
  it("should work", () => {
    expect(result).to.equal(expected);
  });
});

// Target: Jest + Testing Library (project standard)
describe("feature", () => {
  test("should work", () => {
    expect(result).toBe(expected);
  });
});
```

### 大規模リポジトリのスマートサンプリング

### サンプリング戦略

1. コア機能を優先:
   - エントリーポイント (main.js, index.ts)
   - 主要機能モジュール
   - クリティカルパス

2. 必要に応じてサポートコード:
   - ユーティリティ関数（実際に使用されているもののみ）
   - 型定義
   - 設定ファイル

3. スキップすべきもの:
   - 生成ファイル (`dist/`, `build/`, `.next/`)
   - テストデータ (`fixtures/`, `mocks/`)
   - ドキュメント（実装には不要）
   - node_modules、vendor

### 段階的アプローチ

```
Step 1: エントリーポイントとコア機能を読む
Step 2: 依存関係をトレースして必要なファイルを特定
Step 3: 必要に応じて追加ファイルをロード
Step 4: 実装コードに集中、テスト/ドキュメントは後回し
```

## Phase 4: Implementation Execution

### 実行プロセス

### 1. コア機能の実装

最も重要な機能から開始:

```
Priority 1: Essential business logic
Priority 2: API/data layer
Priority 3: Integration points
Priority 4: UI components
Priority 5: Helpers and utilities
```

### 2. サポートユーティリティの追加

コア機能をサポートするヘルパー関数:

```typescript
// Example: API helpers
export async function fetchUserData(userId: string) {}
export function transformUserData(raw: RawUser): User {}
export function validateUserData(data: unknown): boolean {}
```

### 3. 既存コードとの統合

```typescript
// Connect to existing systems
import { auth } from "@/lib/auth";
import { db } from "@/lib/database";
import { logger } from "@/lib/logger";

export async function newFeature() {
  // Use existing infrastructure
  const user = await auth.getCurrentUser();
  const data = await db.query("...");
  logger.info("Feature executed", { user, data });
}
```

### 4. テストの更新

新機能をカバーするテストを追加:

```typescript
describe("newFeature", () => {
  test("integrates with existing auth", async () => {
    // Test integration points
  });

  test("handles error scenarios", async () => {
    // Test error handling
  });

  test("maintains backward compatibility", async () => {
    // Test existing functionality still works
  });
});
```

### 5. 動作検証

各ステップ後に検証:

- コンパイル/ビルドエラーがないか
- 既存テストがパスするか
- 新機能が期待通り動作するか
- パフォーマンスに問題がないか

### 進捗トラッキング

### 1. plan.md の更新

各タスク完了時にチェックマークを付ける:

```markdown
## Implementation Tasks

### Core Functionality

- [x] Create base module structure
- [x] Implement core business logic
- [ ] Add API integration layer
```

### 2. state.json のチェックポイント

```json
{
  "session_id": "impl-2024-01-15-1234",
  "current_phase": "execution",
  "completed_tasks": [
    "Create base module structure",
    "Implement core business logic"
  ],
  "current_task": "Add API integration layer",
  "checkpoints": [
    {
      "timestamp": "2024-01-15T10:30:00Z",
      "task": "Create base module structure",
      "git_commit": "abc123"
    }
  ]
}
```

### 3. Gitコミットの作成

論理的なポイントで意味のあるコミットを作成:

```bash
# Good commit points:
git commit -m "feat: add base structure for feature-name"
git commit -m "feat: implement core business logic"
git commit -m "feat: integrate with existing auth system"
git commit -m "test: add unit tests for feature-name"
```

### 重要

## Phase 5: Quality Assurance

### 検証ステップ

### 1. Lintコマンドの実行

```bash
npm run lint
# または
pnpm lint
yarn lint
```

エラーがあれば自動修正を試みる:

```bash
npm run lint -- --fix
```

### 2. テストスイートの実行

```bash
npm run test
# または
npm run test:unit
npm run test:integration
```

すべてのテストがパスすることを確認。

### 3. 型エラーのチェック

```bash
npm run typecheck
# または
tsc --noEmit
```

型エラーをゼロにする。

### 4. 統合ポイントの検証

```typescript
// Verify all integration points work:
// - Authentication
// - API calls
// - State management
// - Routing
// - UI rendering
```

### 5. リグレッションテスト

既存機能が壊れていないことを確認:

```bash
# Run full test suite
npm run test

# Manual testing of critical paths
# - User authentication
# - Core workflows
# - Data persistence
```

### 品質基準

### すべての基準を満たす必要があります

- ✅ Lint violations: 0
- ✅ Type errors: 0
- ✅ Test failures: 0
- ✅ Build errors: 0
- ✅ Console errors: 0
- ✅ Performance regressions: None
- ✅ Accessibility issues: None

## Phase 6: Implementation Validation

### 統合分析

### 1. Coverage Check

計画されたすべての機能が実装されているか検証:

```markdown
## Feature Coverage

Original Features:

- [x] User authentication (100%)
- [x] Data persistence (100%)
- [x] API integration (100%)
- [ ] Offline support (0%) - Not in scope
- [x] Error handling (100%)

Status: 4/5 planned features (80%)
Note: Offline support deferred to future sprint
```

### 2. Integration Points

すべての接続が機能するか検証:

```markdown
## Integration Points

- [x] Authentication system
- [x] Database layer
- [x] API client
- [ ] WebSocket service (pending)
- [x] State management
- [x] Routing system

Status: 5/6 integration points (83%)
Pending: WebSocket integration (low priority)
```

### 3. Test Coverage

新しいコードがテストされているか確認:

```bash
# Generate coverage report
npm run test:coverage

# Check coverage thresholds
Statements   : 85% (target: 80%)
Branches     : 78% (target: 75%)
Functions    : 90% (target: 80%)
Lines        : 87% (target: 80%)
```

### 4. TODO Scan

残っているTODOを発見:

```bash
# Search for TODOs
grep -r "TODO\|FIXME\|XXX" src/

# Document each TODO with context
```

### 5. Documentation Check

ドキュメントが変更を反映しているか確認:

- README更新
- API documentationの更新
- 使用例の追加
- 変更ログの記録

### 検証レポート

### レポート形式

```
IMPLEMENTATION VALIDATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Features Implemented: 12/12 (100%)
Integration Points: 8/10 (2 pending)
Test Coverage: 87%
Build Status: Passing
Documentation: Updated

PENDING ITEMS:
- WebSocket integration incomplete (low priority)
- Performance monitoring not configured (nice-to-have)

ENHANCEMENT OPPORTUNITIES:
1. Add error boundary for new components
2. Implement caching for API calls
3. Add performance monitoring
4. Create additional usage examples

QUALITY METRICS:
- Lint violations: 0
- Type errors: 0
- Test failures: 0
- Security issues: 0
- Accessibility: WCAG 2.1 AA compliant
```

### 完了アクション

検証後のアクション:

1. 未完了項目の処理:
   - 優先度を決定
   - 今すぐ完了 vs 次のスプリント
   - TODOをissueトラッカーに記録

2. ドキュメント更新:
   - README.mdに新機能を追加
   - API documentationを更新
   - 変更ログを記録

3. マイグレーションガイド:
   - 破壊的変更がある場合
   - 移行手順の作成
   - 影響を受けるコードのリスト

4. ナレッジベース更新:
   - 学んだパターンを記録
   - 問題と解決策をドキュメント化
   - ベストプラクティスを共有

## セッション継続性

### レジューム処理

### ユーザーが `/implement` または `/implement resume` を実行したとき

1. 既存セッションのロード:

   ```bash
   # Check for implement directory
   ls implement/

   # Load state
   cat implement/state.json

   # Load plan
   cat implement/plan.md
   ```

2. 進捗サマリーの表示:

   ```markdown
   ## Session Resume

   Session ID: impl-2024-01-15-1234
   Started: 2024-01-15 10:00:00
   Last Checkpoint: 2024-01-15 12:30:00

   Progress: 8/15 tasks completed (53%)
   Current Phase: Execution
   Current Task: Add API integration layer

   Recent Checkpoints:

   - Create base module structure (10:30)
   - Implement core business logic (11:45)
   - Integrate with existing auth system (12:30)
   ```

3. 最後のチェックポイントから継続:
   - 前回の決定とコンテキストを維持
   - 中断した箇所から正確に再開
   - 計画に従って次のタスクに進む

### スマート検出

### 自動レジューム条件

```python
def should_resume():
    return (
        os.path.exists('implement/plan.md') and
        os.path.exists('implement/state.json') and
        not user_specified_new_session()
    )
```

### 新規セッション開始

```bash
/implement new [source]  # Force new session
```

### ステータス確認

```bash
/implement status        # Show current progress
```

## 実行保証

### このワークフローは常に以下の順序に従います

1. ✅ Setup session - 状態ファイルを最初に作成/ロード
2. ✅ Analyze source & target - 完全な理解
3. ✅ Write plan - `implement/plan.md` に完全な実装計画を記述
4. ✅ Show plan - 実装前に計画概要を提示
5. ✅ Execute systematically - 計画に従って更新しながら実行
6. ✅ Validate integration - 要求時に検証を実行

### 禁止事項

- ❌ 書面計画なしで実装を開始
- ❌ ソースまたはプロジェクト分析をスキップ
- ❌ セッションファイル作成をバイパス
- ❌ 計画を示す前にコーディングを開始
- ❌ コミット、PR、git関連コンテンツで絵文字を使用

## トラブルシューティング

### よくある問題

### 問題: セッションファイルが見つからない

```bash
# Verify you're in project root
pwd

# Check for implement directory
ls -la | grep implement

# If missing, create new session
/implement new [source]
```

### 問題: ステートとプランが不一致

```bash
# Check state
cat implement/state.json

# Check plan
cat implement/plan.md

# If corrupted, start fresh
rm -rf implement/
/implement new [source]
```

### 問題: Phase順序が守られていない

```
Error: Cannot execute Phase 4 before completing Phase 3

Action:
1. Check current phase in state.json
2. Complete current phase
3. Proceed to next phase
```
