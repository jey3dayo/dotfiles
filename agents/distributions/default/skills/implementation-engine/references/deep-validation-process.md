# Deep Validation Process

Implementation EngineのDeep Validation - すべての検証コマンド（finish, verify, complete, enhance）が実行する包括的な7ステッププロセス。

## 概要

### 統一検証プロセス

すべての検証コマンドは同じプロセスを実行します:

```bash
/implement finish      # 徹底的なテストと検証で完成
/implement verify      # 要件に対する深い検証
/implement complete    # 100%の機能完全性を保証
/implement enhance     # 実装を洗練・最適化
```

これらのコマンドはすべて、以下の7ステップを自動的に実行します。

## 7-Step Deep Validation Process

### Step 1: Deep Original Source Analysis

### 目的

### 実行内容

1. **完全なソース読み込み:**

   ```python
   # 元のソースを徹底的に読む
   if source_type == 'URL':
       original_code = fetch_and_analyze_repository(source_url)
   elif source_type == 'Local':
       original_code = read_all_files(source_path)
   elif source_type == 'Description':
       original_requirements = parse_description(source_text)
   ```

2. **実装パターンの研究:**

   ```markdown
   ## Implementation Patterns Analysis

   ### Architecture Patterns

   - Component structure
   - Data flow
   - State management approach
   - Error handling strategy

   ### Design Patterns

   - Factory pattern usage
   - Observer pattern implementation
   - Singleton instances
   - Dependency injection

   ### Code Organization

   - File structure
   - Module boundaries
   - Import/export patterns
   - Naming conventions
   ```

3. **機能性とビジネスロジックの文書化:**

   ```markdown
   ## Complete Functionality Map

   ### Core Features

   1. User Authentication
      - Login flow
      - Token management
      - Session handling
      - Password reset

   2. Data Management
      - CRUD operations
      - Validation rules
      - Data transformation
      - Persistence layer

   ### Business Logic

   - Calculation algorithms
   - Workflow processes
   - Validation rules
   - Edge case handling
   ```

4. **コード構造と依存関係のマッピング:**

   ```markdown
   ## Code Structure Map

   ### Entry Points

   - main.ts → Application bootstrap
   - routes/index.ts → Route definitions

   ### Core Modules

   - auth/ → Authentication system
   - api/ → API client
   - store/ → State management
   - utils/ → Utility functions

   ### Dependencies

   External:

   - react: UI framework
   - redux: State management
   - axios: HTTP client

   Internal:

   - @/lib/auth → auth/
   - @/utils/validation → utils/validation
   ```

5. **包括的分析ドキュメントの作成:**

   ```bash
   # 分析結果を保存
   write_file('implement/source-analysis.md', analysis)
   ```

### 出力

### Step 2: Requirements Verification

### 目的

### 実行内容

1. **機能マッピング:**

   ```markdown
   ## Feature Mapping

   | Original Feature  | New Implementation | Status      |
   | ----------------- | ------------------ | ----------- |
   | User login        | src/auth/login.ts  | ✅ Complete |
   | Token refresh     | src/auth/tokens.ts | ✅ Complete |
   | Password reset    | src/auth/reset.ts  | ⚠️ Partial  |
   | OAuth integration | -                  | ❌ Missing  |
   ```

2. **欠落機能の識別:**

   ```markdown
   ## Missing Features

   ### Critical

   - OAuth integration (Google, GitHub)
   - Two-factor authentication

   ### Important

   - Remember me functionality
   - Session timeout handling

   ### Nice-to-have

   - Social login buttons
   - Login history tracking
   ```

3. **エッジケースのチェック:**

   ```typescript
   // Original edge cases
   const originalEdgeCases = [
     "Empty email input",
     "Invalid email format",
     "Network timeout",
     "Server error response",
     "Token expiration during request",
     "Concurrent login attempts",
   ];

   // Check each edge case is handled
   for (const edgeCase of originalEdgeCases) {
     const isHandled = checkEdgeCaseHandling(edgeCase);
     reportEdgeCaseStatus(edgeCase, isHandled);
   }
   ```

4. **振る舞いの検証:**

   ```markdown
   ## Behavior Verification

   ### Expected Behaviors (from original)

   - [ ] Login redirects to dashboard on success
   - [ ] Error message shows for invalid credentials
   - [ ] Form clears after successful submission
   - [ ] Loading state displays during API call
   - [ ] Token stored in secure storage

   ### Actual Behaviors (in new implementation)

   - [x] Login redirects to dashboard on success
   - [x] Error message shows for invalid credentials
   - [x] Form clears after successful submission
   - [x] Loading state displays during API call
   - [⚠️] Token stored in localStorage (not secure!)
   ```

### 出力

### Step 3: Comprehensive Testing

### 目的

### 実行内容

1. **新機能のテスト作成:**

   ```typescript
   // 各新機能に対するテストを作成
   describe("Authentication", () => {
     describe("Login", () => {
       test("successful login with valid credentials", async () => {
         // Test implementation
       });

       test("failed login with invalid credentials", async () => {
         // Test implementation
       });

       test("handles network errors gracefully", async () => {
         // Test implementation
       });

       test("validates email format before submission", () => {
         // Test implementation
       });
     });

     describe("Token Management", () => {
       test("refreshes token before expiration", async () => {
         // Test implementation
       });

       test("clears token on logout", async () => {
         // Test implementation
       });
     });
   });
   ```

2. **既存テストスイートの実行:**

   ```bash
   npm run test
   ```

3. **統合テストの作成:**

   ```typescript
   // エンドツーエンドフローをテスト
   describe("Authentication Flow Integration", () => {
     test("complete login to dashboard flow", async () => {
       // Navigate to login
       // Enter credentials
       // Submit form
       // Verify redirect to dashboard
       // Verify user data loaded
     });

     test("login persistence across page refresh", async () => {
       // Login
       // Refresh page
       // Verify still logged in
     });
   });
   ```

4. **エラーシナリオのテスト:**

   ```typescript
   describe("Error Scenarios", () => {
     test("handles API timeout", async () => {
       // Mock timeout
       // Attempt login
       // Verify error message
       // Verify retry mechanism
     });

     test("handles malformed API response", async () => {
       // Mock bad response
       // Attempt login
       // Verify graceful degradation
     });

     test("handles expired token", async () => {
       // Set expired token
       // Make authenticated request
       // Verify token refresh
       // Verify request retry
     });
   });
   ```

5. **パフォーマンス要件の検証:**

   ```typescript
   describe("Performance Requirements", () => {
     test("login completes within 2 seconds", async () => {
       const start = Date.now();
       await login(credentials);
       const duration = Date.now() - start;
       expect(duration).toBeLessThan(2000);
     });

     test("handles 100 concurrent login attempts", async () => {
       const attempts = Array(100)
         .fill(null)
         .map(() => login(credentials));
       const results = await Promise.all(attempts);
       expect(results.every((r) => r.success)).toBe(true);
     });
   });
   ```

### 出力

### Step 4: Deep Code Analysis

### 目的

### 実行内容

1. **不完全なTODOのチェック:**

   ```bash
   # すべてのTODOを検索
   grep -r "TODO\|FIXME\|XXX\|HACK" src/

   # 各TODOを分類
   # - Critical: 機能が動作しない
   # - Important: 機能は動作するが改善必要
   # - Nice-to-have: 最適化や拡張
   ```

   ```markdown
   ## TODO Analysis

   ### Critical (must fix)

   - [ ] TODO: Implement token refresh logic (auth/tokens.ts:45)
   - [ ] FIXME: Handle concurrent login race condition (auth/login.ts:123)

   ### Important (should fix)

   - [ ] TODO: Add rate limiting (auth/middleware.ts:78)
   - [ ] TODO: Improve error messages (auth/errors.ts:34)

   ### Nice-to-have (can defer)

   - [ ] TODO: Add telemetry (auth/analytics.ts:12)
   - [ ] TODO: Optimize token storage (auth/storage.ts:56)
   ```

2. **ハードコード値の発見:**

   ```typescript
   // ハードコード値をスキャン
   const hardcodedValues = findHardcodedValues([
     "strings", // Magic strings
     "numbers", // Magic numbers
     "urls", // Hardcoded URLs
     "keys", // API keys
     "credentials", // Passwords
   ]);

   // 各値に対する推奨を生成
   for (const value of hardcodedValues) {
     suggestConfiguration(value);
   }
   ```

   ```markdown
   ## Hardcoded Values to Configure

   ### URLs

   - `https://api.example.com` (auth/client.ts:12)
     → Move to environment variable: `API_BASE_URL`

   ### Timeouts

   - `5000` ms timeout (auth/client.ts:34)
     → Move to config: `AUTH_TIMEOUT_MS`

   ### Limits

   - `3` max retry attempts (auth/retry.ts:23)
     → Move to config: `MAX_RETRY_ATTEMPTS`
   ```

3. **エラーハンドリング完全性の検証:**

   ```typescript
   // すべての非同期関数をチェック
   const asyncFunctions = findAsyncFunctions();

   for (const func of asyncFunctions) {
     // try-catchまたはエラーハンドリングがあるか？
     const hasErrorHandling = checkErrorHandling(func);

     if (!hasErrorHandling) {
       reportMissingErrorHandling(func);
     }
   }
   ```

   ```markdown
   ## Error Handling Analysis

   ### Missing Error Handling

   - `fetchUserProfile()` (api/users.ts:45)
     → Add try-catch for network errors

   - `saveTokenToStorage()` (auth/storage.ts:23)
     → Handle storage quota exceeded

   ### Incomplete Error Handling

   - `login()` (auth/login.ts:67)
     → Catches error but doesn't log it
     → Recommendation: Add error logging
   ```

4. **セキュリティの分析:**

   ```markdown
   ## Security Analysis

   ### Vulnerabilities Found

   - ⚠️ Token stored in localStorage (auth/storage.ts:12)
     → Use httpOnly cookies or secure storage

   - ⚠️ No CSRF protection (auth/middleware.ts)
     → Implement CSRF tokens

   - ⚠️ Password sent in query params (auth/reset.ts:34)
     → Use POST body instead

   ### Security Best Practices

   - ✅ Passwords hashed with bcrypt
   - ✅ HTTPS enforced
   - ✅ Input sanitization implemented
   - ⚠️ No rate limiting on login endpoint
   ```

5. **アクセシビリティ要件のチェック:**

   ```markdown
   ## Accessibility Analysis

   ### WCAG 2.1 Compliance

   - [ ] All form inputs have labels
   - [ ] Error messages announced to screen readers
   - [ ] Keyboard navigation supported
   - [ ] Focus indicators visible
   - [ ] Color contrast meets AA standards

   ### Issues Found

   - ⚠️ Login button has no aria-label
   - ⚠️ Error message not associated with input
   - ⚠️ Form submit only works with mouse click
   ```

### 出力

### Step 5: Automatic Refinement

### 目的

### 実行内容

1. **失敗したテストの修正:**

   ```python
   # テスト失敗を検出
   test_results = run_tests()

   for failure in test_results.failures:
       # 失敗の原因を分析
       root_cause = analyze_failure(failure)

       # 修正を適用
       apply_fix(root_cause)

       # 再テスト
       retest(failure.test)
   ```

2. **部分的実装の完成:**

   ```typescript
   // 不完全な関数を完成させる
   async function refreshToken(token: string) {
     // Before: 部分的実装
     // TODO: Implement token refresh

     // After: 完全実装
     try {
       const response = await api.post("/auth/refresh", { token });
       const newToken = response.data.token;
       await saveToken(newToken);
       return newToken;
     } catch (error) {
       logger.error("Token refresh failed", error);
       throw new AuthError("Failed to refresh token");
     }
   }
   ```

3. **欠落しているエラーハンドリングの追加:**

   ```typescript
   // Before: エラーハンドリングなし
   async function fetchUserProfile(userId: string) {
     const response = await api.get(`/users/${userId}`);
     return response.data;
   }

   // After: 完全なエラーハンドリング
   async function fetchUserProfile(userId: string) {
     try {
       const response = await api.get(`/users/${userId}`);
       return response.data;
     } catch (error) {
       if (error.response?.status === 404) {
         throw new UserNotFoundError(userId);
       }
       if (error.response?.status === 403) {
         throw new UnauthorizedError("Cannot access user profile");
       }
       logger.error("Failed to fetch user profile", { userId, error });
       throw new APIError("Failed to fetch user profile");
     }
   }
   ```

4. **パフォーマンスボトルネックの最適化:**

   ```typescript
   // Before: 非効率的な実装
   function processUsers(users: User[]) {
     for (const user of users) {
       validateUser(user); // Expensive validation
       transformUser(user); // Heavy computation
       saveUser(user); // Database write
     }
   }

   // After: 最適化された実装
   async function processUsers(users: User[]) {
     // Batch validation
     const validUsers = await batchValidate(users);

     // Parallel transformation
     const transformed = await Promise.all(
       validUsers.map((user) => transformUser(user)),
     );

     // Bulk save
     await bulkSaveUsers(transformed);
   }
   ```

5. **コードドキュメントの改善:**

   ````typescript
   // Before: ドキュメントなし
   async function login(email: string, password: string) {
     // ...
   }

   // After: 完全なドキュメント
   /**
    * Authenticates a user with email and password.
    *
    * @param email - User's email address
    * @param password - User's password (will be hashed)
    * @returns Authentication token and user profile
    * @throws {InvalidCredentialsError} If email/password is incorrect
    * @throws {NetworkError} If API request fails
    * @throws {RateLimitError} If too many login attempts
    *
    * @example
    * ```typescript
    * const { token, user } = await login('user@example.com', 'password123');
    * ```
    */
   async function login(email: string, password: string) {
     // ...
   }
   ````

### 出力

### Step 6: Integration Analysis

### 目的

### 実行内容

1. **統合ポイントの徹底分析:**

   ```markdown
   ## Integration Points Analysis

   ### Authentication System

   - ✅ Login flow integrated
   - ✅ Token management connected
   - ⚠️ Session timeout handler needs wiring
   - ❌ Password reset flow not connected

   ### API Client

   - ✅ Base configuration set up
   - ✅ Error interceptors added
   - ✅ Request/response transformers configured
   - ✅ Retry logic implemented

   ### State Management

   - ✅ Auth state slice created
   - ✅ Actions and reducers defined
   - ⚠️ Selectors need memoization
   - ✅ Middleware configured

   ### Routing

   - ✅ Auth routes added
   - ✅ Protected routes configured
   - ⚠️ Redirect after login needs fixing
   - ❌ Route guards for admin pages missing
   ```

2. **APIコントラクトの検証:**

   ```typescript
   // 元のAPIコントラクトと新しい実装を比較
   const originalContract = {
     endpoint: "/auth/login",
     method: "POST",
     body: { email: string, password: string },
     response: { token: string, user: User },
   };

   const newImplementation = {
     endpoint: "/auth/login",
     method: "POST",
     body: { email: string, password: string },
     response: { token: string, user: User },
   };

   // コントラクトマッチングを検証
   verifyContractMatch(originalContract, newImplementation);
   ```

3. **データベーススキーマ互換性のチェック:**

   ```sql
   -- Original schema
   CREATE TABLE users (
     id SERIAL PRIMARY KEY,
     email VARCHAR(255) UNIQUE,
     password_hash VARCHAR(255),
     created_at TIMESTAMP
   );

   -- New schema (check compatibility)
   CREATE TABLE users (
     id SERIAL PRIMARY KEY,
     email VARCHAR(255) UNIQUE,
     password_hash VARCHAR(255),
     created_at TIMESTAMP,
     updated_at TIMESTAMP,  -- New field (backward compatible)
     last_login TIMESTAMP   -- New field (backward compatible)
   );
   ```

4. **UI/UXフローの検証:**

   ```markdown
   ## UI/UX Flow Validation

   ### Login Flow

   Original:

   1. User enters credentials
   2. Click login button
   3. Loading indicator shows
   4. Redirect to dashboard on success
   5. Show error message on failure

   New Implementation:

   1. ✅ User enters credentials
   2. ✅ Click login button
   3. ✅ Loading indicator shows
   4. ⚠️ Redirects to home instead of dashboard
   5. ✅ Shows error message on failure

   Issue: Redirect target mismatch
   Fix: Change redirect from '/' to '/dashboard'
   ```

5. **後方互換性の保証:**

   ```markdown
   ## Backward Compatibility Check

   ### API Changes

   - ✅ No breaking changes to existing endpoints
   - ✅ New fields are optional
   - ✅ Old token format still supported
   - ⚠️ New error format differs from old

   ### Migration Path

   - [ ] Add adapter for old error format
   - [ ] Document new error format
   - [ ] Provide migration guide for consumers
   ```

### 出力

### Step 7: Completeness Report

### 目的

### 実行内容

```markdown
# Implementation Completeness Report

Generated: 2024-01-15 15:30:00

## Executive Summary

Implementation is 95% complete with 2 minor issues remaining.
All critical features are implemented and tested.
Ready for production deployment with minor fixes.

## Feature Coverage

Total Features: 25
Implemented: 24/25 (96%)
Tested: 24/24 (100%)
Documented: 23/24 (96%)

### Implemented Features

- ✅ User Authentication (100%)
  - Login flow
  - Token management
  - Session handling
- ✅ Data Management (100%)
  - CRUD operations
  - Validation
  - Error handling
- ⚠️ OAuth Integration (80%)
  - Google login ✅
  - GitHub login ✅
  - Facebook login ❌ (deferred)

### Missing Features

- Facebook OAuth (low priority, deferred to v2)

## Test Coverage

Overall: 87%
Unit Tests: 92%
Integration Tests: 85%
E2E Tests: 80%

### Coverage by Module

- auth/: 95%
- api/: 90%
- store/: 85%
- components/: 82%
- utils/: 88%

### Untested Code

- Error boundary fallback UI (components/ErrorBoundary.tsx:45-60)
- Admin panel (components/Admin.tsx - deferred to v2)

## Performance Benchmarks

### Response Times

- Login: 450ms (target: <500ms) ✅
- Token refresh: 120ms (target: <200ms) ✅
- User profile load: 280ms (target: <300ms) ✅

### Load Testing

- Concurrent users: 500 (target: 500) ✅
- Requests per second: 1000 (target: 1000) ✅
- Error rate: 0.1% (target: <1%) ✅

## Security Audit

### Vulnerabilities Fixed

- ✅ Token storage now uses httpOnly cookies
- ✅ CSRF protection implemented
- ✅ Rate limiting added to login endpoint
- ✅ Input sanitization implemented

### Security Score: A- (95/100)

Deductions:

- -5: No security headers on some responses

### Recommendations

- Add security headers middleware
- Implement Content Security Policy
- Add rate limiting to password reset

## Accessibility Compliance

WCAG 2.1 Level: AA (98% compliant)

### Passing Criteria

- ✅ All form inputs have labels
- ✅ Error messages accessible
- ✅ Keyboard navigation works
- ✅ Focus indicators visible
- ✅ Color contrast meets AA

### Minor Issues

- ⚠️ Some ARIA labels could be more descriptive

## Code Quality

### Metrics

- Linter violations: 0
- Type errors: 0
- Cyclomatic complexity: Average 4.2 (Good)
- Maintainability index: 78/100 (Good)

### Technical Debt

- Low: 2 items (refactoring opportunities)
- Medium: 0 items
- High: 0 items

## Documentation

### Coverage

- API documentation: 100%
- Code comments: 85%
- Usage examples: 90%
- Migration guide: 100%

### Missing Documentation

- Performance tuning guide
- Advanced configuration options

## Remaining Work

### Critical (0 items)

None

### Important (2 items)

1. Fix dashboard redirect after login
   Estimate: 30 minutes
   File: auth/login.ts:123

2. Add security headers middleware
   Estimate: 1 hour
   File: middleware/security.ts (new)

### Nice-to-have (3 items)

1. Improve ARIA labels
   Estimate: 2 hours

2. Add performance tuning guide
   Estimate: 3 hours

3. Implement telemetry
   Estimate: 4 hours

## Deployment Readiness

### Checklist

- ✅ All tests passing
- ✅ Build succeeds
- ✅ No console errors
- ✅ Performance acceptable
- ✅ Security audit passed
- ✅ Accessibility compliant
- ⚠️ 2 minor fixes pending

### Recommendation

**Ready for production** after completing 2 important items (estimated 1.5 hours).

### Deployment Notes

- Run database migrations before deploying
- Update environment variables for new features
- Monitor error rates for first 24 hours
- Have rollback plan ready

## Conclusion

Implementation successfully adapts original features to project architecture
while maintaining high quality standards. Minor remaining work does not block
production deployment. All critical functionality is complete, tested, and
production-ready.

**Overall Status: 95% Complete - Production Ready with Minor Fixes**
```

### 出力

## Deep Validation実行フロー

```
User runs: /implement finish|verify|complete|enhance
          ↓
    Step 1: Deep Original Source Analysis
          ↓ (creates implement/source-analysis.md)
    Step 2: Requirements Verification
          ↓ (creates coverage report)
    Step 3: Comprehensive Testing
          ↓ (creates/runs tests)
    Step 4: Deep Code Analysis
          ↓ (finds issues)
    Step 5: Automatic Refinement
          ↓ (fixes issues)
    Step 6: Integration Analysis
          ↓ (verifies integration)
    Step 7: Completeness Report
          ↓ (generates final report)
    Present report to user
```

## 結果

### 100%完全で、テスト済み、本番環境対応の実装がすべての要件を満たします

### 特徴

- すべての機能が実装されている
- 包括的なテストカバレッジ
- セキュリティ監査済み
- アクセシビリティ準拠
- パフォーマンス検証済み
- ドキュメント完備
- 本番環境デプロイ準備完了

## 使用例

```bash
# 実装完了後、Deep Validationを実行
/implement finish

# → 7ステッププロセスが自動実行
# → 完全性レポートが生成される
# → 残りの作業があれば明示される
# → 本番環境デプロイ準備状況が報告される
```

## ベストプラクティス

### Deep Validation実行タイミング

1. **実装完了後:** すべてのタスクが完了したと思ったとき
2. **重要なマイルストーン後:** 大きな機能が完成したとき
3. **本番環境デプロイ前:** 最終確認として
4. **レビュー前:** コードレビューに提出する前

### 注意点

- Deep Validationは時間がかかる（10-30分程度）
- すべてのテストが実行される
- 自動修正が適用される
- Gitコミットが作成される可能性がある
- 本番環境デプロイの最終チェックとして使用
