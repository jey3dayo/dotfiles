# Adaptation Patterns

Implementation Engineが元のコードをプロジェクトアーキテクチャに適応させるためのパターン集。依存関係解決、コード変換、リポジトリ分析戦略の詳細。

## 依存関係解決

### ライブラリマッピング戦略

### 1. 既存ライブラリの再利用:

```typescript
// Source code uses axios
import axios from "axios";

const response = await axios.get("/api/data");

// Project has custom fetch wrapper
import { apiFetch } from "@/lib/api";

// Map to existing implementation
const response = await apiFetch("/api/data");
```

### マッピングの例:

```markdown
| Source Library | Project Equivalent | Action                   |
| -------------- | ------------------ | ------------------------ |
| axios          | custom fetch       | Use apiFetch()           |
| lodash         | native ES6         | Use Array/Object methods |
| moment         | date-fns           | Use date-fns (existing)  |
| react-query    | SWR                | Use useSWR()             |
| redux          | zustand            | Adapt to zustand store   |
```

### 2. バージョン互換性の確認:

```typescript
// Source: React 18 features
import { useId, useTransition } from "react";

// Project: React 17
// Adapt to React 17 API
import { useState, useEffect } from "react";

// Implement useId polyfill
function useIdPolyfill() {
  const [id] = useState(() => `id-${Math.random()}`);
  return id;
}
```

### 3. 重複の回避:

```typescript
// Source: Custom utility function
function debounce(fn, delay) {
  let timeout;
  return (...args) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => fn(...args), delay);
  };
}

// Project: lodash already installed
import { debounce } from "lodash";
// Use existing implementation instead
```

### 4. 非推奨APIの更新:

```typescript
// Source: Old API
componentWillMount() {
  this.fetchData();
}

// Modern: useEffect
useEffect(() => {
  fetchData();
}, []);
```

## コード変換パターン

### 1. 命名規則の統一

### snake_case → camelCase:

```typescript
// Source
function user_authentication(user_name, pass_word) {
  const auth_token = generate_token(user_name);
  return auth_token;
}

// Target
function userAuthentication(userName, password) {
  const authToken = generateToken(userName);
  return authToken;
}
```

### kebab-case → camelCase (CSS modules):

```css
/* Source */
.user-profile-card {
  background-color: white;
}

/* Target */
.userProfileCard {
  background-color: white;
}
```

### 2. エラーハンドリングパターンの適応

### try-catch everywhere → Custom error boundary:

```typescript
// Source: try-catch everywhere
async function fetchUser(id) {
  try {
    const response = await fetch(`/api/users/${id}`);
    const data = await response.json();
    return data;
  } catch (error) {
    console.error(error);
    return null;
  }
}

// Target: Project's safeAsync pattern
async function fetchUser(id) {
  const { data, error } = await safeAsync(() =>
    fetch(`/api/users/${id}`).then((r) => r.json()),
  );

  if (error) {
    handleError(error);
    return null;
  }

  return data;
}
```

### Error classes:

```typescript
// Source: Generic Error
throw new Error("User not found");

// Target: Custom error classes
throw new UserNotFoundError(userId);
```

### 3. 状態管理アプローチの維持

### useState + useEffect → SWR:

```typescript
// Source: Manual state management
const [data, setData] = useState(null);
const [loading, setLoading] = useState(false);
const [error, setError] = useState(null);

useEffect(() => {
  setLoading(true);
  fetchData()
    .then(setData)
    .catch(setError)
    .finally(() => setLoading(false));
}, []);

// Target: Project uses SWR
const { data, error, isLoading } = useSWR("/api/data", fetcher);
```

### Redux → Zustand:

```typescript
// Source: Redux
const mapStateToProps = (state) => ({
  user: state.auth.user,
  isAuthenticated: state.auth.isAuthenticated,
});

// Target: Zustand
const { user, isAuthenticated } = useAuthStore();
```

### 4. テストスタイルの保持

### Mocha/Chai → Jest:

```typescript
// Source: Mocha + Chai
describe("User", () => {
  it("should authenticate with valid credentials", () => {
    const result = authenticate("user", "pass");
    expect(result).to.be.true;
  });
});

// Target: Jest
describe("User", () => {
  test("should authenticate with valid credentials", () => {
    const result = authenticate("user", "pass");
    expect(result).toBe(true);
  });
});
```

### Enzyme → Testing Library:

```typescript
// Source: Enzyme
const wrapper = shallow(<LoginForm />);
wrapper.find('input[name="email"]').simulate('change', { target: { value: 'test@test.com' } });

// Target: Testing Library
render(<LoginForm />);
const emailInput = screen.getByLabelText('Email');
fireEvent.change(emailInput, { target: { value: 'test@test.com' } });
```

### 5. モジュールシステムの変換

### CommonJS → ES Modules:

```javascript
// Source: CommonJS
const express = require("express");
const config = require("./config");

module.exports = function createApp() {
  const app = express();
  return app;
};

// Target: ES Modules
import express from "express";
import { config } from "./config";

export function createApp() {
  const app = express();
  return app;
}
```

## 大規模リポジトリ分析戦略

### スマートサンプリング

### 優先順位:

1. **最優先: エントリーポイントとコア機能**

```
Phase 1 Files:
- src/index.ts (entry point)
- src/main.ts (bootstrap)
- src/app.ts (application setup)
- src/routes/index.ts (routing)
- src/config/index.ts (configuration)
```

2. **高優先度: 主要機能モジュール**

```
Phase 2 Files:
- src/auth/ (authentication)
- src/api/ (API client)
- src/store/ (state management)
- src/lib/ (core utilities)
```

3. **中優先度: サポートコード**

```
Phase 3 Files:
- src/utils/ (helper functions)
- src/types/ (type definitions)
- src/hooks/ (custom hooks)
- src/components/ (UI components)
```

4. **低優先度: テストとドキュメント**

```
Phase 4 Files (as needed):
- __tests__/ (tests)
- docs/ (documentation)
- examples/ (examples)
```

### スキップすべきファイル:

```
Never Read:
- node_modules/
- dist/, build/, .next/
- coverage/
- .git/
- *.log, *.lock
- fixtures/, mocks/ (test data)
```

### 段階的ロードパターン

```python
def load_repository_incrementally(repo_path):
    # Phase 1: Entry points
    entry_files = load_entry_points(repo_path)
    analyze_structure(entry_files)

    # Phase 2: Trace dependencies
    core_modules = trace_imports(entry_files)
    load_files(core_modules)

    # Phase 3: Load supporting code as needed
    while has_unresolved_dependencies():
        missing = find_missing_dependencies()
        load_files(missing)

    # Phase 4: Skip tests unless explicitly needed
    if need_test_examples:
        load_test_files()
```

### ファイルサイズ制限

```python
def should_load_file(file_path):
    # Skip very large files (>1MB)
    if file_size(file_path) > 1_000_000:
        return False

    # Skip generated files
    if is_generated(file_path):
        return False

    # Skip minified files
    if file_path.endswith('.min.js'):
        return False

    return True
```

### 並列ロード

```python
async def load_files_in_parallel(file_paths):
    # Group files by priority
    high_priority = filter_high_priority(file_paths)
    low_priority = filter_low_priority(file_paths)

    # Load high priority first
    high_results = await asyncio.gather(*[load_file(f) for f in high_priority])

    # Then load low priority
    low_results = await asyncio.gather(*[load_file(f) for f in low_priority])

    return high_results + low_results
```

## プロジェクト固有パターンの検出

### アーキテクチャパターンの識別

```typescript
// Detect architecture pattern
function detectArchitecturePattern(projectStructure) {
  if (hasDirectory("pages/") && hasFile("next.config.js")) {
    return "Next.js";
  }

  if (hasDirectory("app/") && hasFile("remix.config.js")) {
    return "Remix";
  }

  if (hasDirectory("src/") && hasFile("vite.config.ts")) {
    return "Vite";
  }

  // ... more patterns
}
```

### コード規約の抽出

```typescript
// Extract code conventions from existing files
function extractConventions(codebase) {
  const conventions = {
    naming: detectNamingStyle(codebase),
    imports: detectImportStyle(codebase),
    errorHandling: detectErrorHandlingPattern(codebase),
    testing: detectTestingFramework(codebase),
    styling: detectStylingApproach(codebase),
  };

  return conventions;
}
```

### 命名スタイルの検出:

```typescript
function detectNamingStyle(files) {
  const samples = sampleFunctionNames(files);

  const camelCaseCount = samples.filter(isCamelCase).length;
  const snakeCaseCount = samples.filter(isSnakeCase).length;

  return camelCaseCount > snakeCaseCount ? "camelCase" : "snake_case";
}
```

### インポートスタイルの検出:

```typescript
function detectImportStyle(files) {
  const imports = extractImports(files);

  // Absolute imports (@/lib/...)
  const absoluteCount = imports.filter((i) => i.startsWith("@/")).length;

  // Relative imports (../../)
  const relativeCount = imports.filter((i) => i.startsWith(".")).length;

  return absoluteCount > relativeCount ? "absolute" : "relative";
}
```

## 適応戦略の選択

### 戦略マトリックス

| Source Pattern   | Project Pattern | Strategy                |
| ---------------- | --------------- | ----------------------- |
| Class components | Hooks           | Convert to functional   |
| Redux            | Zustand         | Map actions to store    |
| CSS-in-JS        | CSS Modules     | Extract styles          |
| Axios            | fetch           | Use fetch wrapper       |
| Moment.js        | date-fns        | Replace date operations |

### 変換の決定木

```
Is the source pattern compatible?
├─ Yes → Use as-is
└─ No
   ├─ Does project have equivalent?
   │  ├─ Yes → Map to equivalent
   │  └─ No → Can we add the dependency?
   │     ├─ Yes → Add dependency
   │     └─ No → Implement alternative
   └─ Is it deprecated/anti-pattern?
      └─ Yes → Update to modern approach
```

## パフォーマンス最適化

### バッチ処理

```typescript
// Bad: One file at a time
for (const file of files) {
  const content = await readFile(file);
  analyzeFile(content);
}

// Good: Batch processing
const contents = await Promise.all(files.map(readFile));
contents.forEach(analyzeFile);
```

### キャッシング

```typescript
// Cache analyzed patterns
const patternCache = new Map();

function getPattern(file) {
  if (patternCache.has(file)) {
    return patternCache.get(file);
  }

  const pattern = analyzePattern(file);
  patternCache.set(file, pattern);
  return pattern;
}
```

### 遅延ロード

```typescript
// Load details only when needed
class LazyModule {
  private _details: ModuleDetails | null = null;

  get details() {
    if (!this._details) {
      this._details = loadModuleDetails(this.path);
    }
    return this._details;
  }
}
```

## エッジケースの処理

### モノレポの処理

```typescript
// Detect monorepo structure
function isMonorepo(projectPath) {
  return (
    hasFile("lerna.json") ||
    hasFile("pnpm-workspace.yaml") ||
    hasFile("workspace.json")
  );
}

// Handle workspace packages
function loadWorkspacePackages(projectPath) {
  const workspaces = detectWorkspaces(projectPath);

  // Load each workspace incrementally
  for (const workspace of workspaces) {
    loadPackage(workspace);
  }
}
```

### レガシーコードの処理

```typescript
// Detect legacy patterns
function isLegacyCode(file) {
  const indicators = [
    'var ' in file.content,
    '$.ajax' in file.content,
    'componentWillMount' in file.content,
    'createClass' in file.content
  ];

  return indicators.some(Boolean);
}

// Modernize legacy code
function modernizeLegacyCode(code) {
  return code
    .replaceVar WithLet Or Const()
    .replaceAjax WithFetch()
    .replaceLifecycle WithHooks()
    .replaceCreateClass WithFunction();
}
```

### 型定義の処理

```typescript
// Handle missing types
function ensureTypes(code) {
  if (!hasTypeDefinitions(code)) {
    // Generate basic types from usage
    return generateTypes(code);
  }

  return code;
}
```

## ベストプラクティス

### 適応プロセス:

1. プロジェクトパターンを最優先
2. 既存のライブラリを再利用
3. 重複を避ける
4. 非推奨APIを更新
5. 一貫性を保つ

### 品質保証:

1. 変換後にテストを実行
2. 型チェックを確認
3. Lintを通す
4. パフォーマンスを検証
5. 既存機能が動作することを確認

### ドキュメント:

1. 重要な変換を記録
2. 決定の理由を文書化
3. 影響範囲を明確化
4. 移行手順を提供
