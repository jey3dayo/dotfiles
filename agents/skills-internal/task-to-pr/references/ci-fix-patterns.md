# CI Fix Patterns

## Purpose

Provide strategies and patterns for automatically fixing CI failures. Use with `inspect_pr_checks.py`.

## inspect_pr_checks.py Usage

### Basic Usage

```bash
# Inspect PR checks for the current branch
python scripts/inspect_pr_checks.py

# Specify a PR number
python scripts/inspect_pr_checks.py --pr 123

# Output as JSON
python scripts/inspect_pr_checks.py --json

# Set max lines and context lines
python scripts/inspect_pr_checks.py --max-lines 200 --context 50
```

### Output Format

**Text output**:

```
PR #123: analyzed 2 failed checks.
------------------------------------------------------------
Check name: TypeScript Build
Details: https://github.com/.../runs/...
Run ID: 12345
Job ID: 67890
Status: ok
Workflow: CI (failure)
Branch/SHA: feat/auth 1a2b3c4d5e6f
Run URL: https://github.com/.../runs/12345
Failure snippet:
  src/auth.ts:45:12 - error TS2345: Argument of type 'string' is not assignable to parameter of type 'number'.
  45   validateToken(token);
                   ~~~~~
------------------------------------------------------------
```

**JSON output** (`--json`):

```json
{
  "pr": "123",
  "results": [
    {
      "name": "TypeScript Build",
      "detailsUrl": "https://github.com/.../runs/...",
      "runId": "12345",
      "jobId": "67890",
      "status": "ok",
      "run": {
        "conclusion": "failure",
        "workflowName": "CI",
        "headBranch": "feat/auth",
        "headSha": "1a2b3c4d5e6f"
      },
      "logSnippet": "src/auth.ts:45:12 - error TS2345: ...",
      "logTail": "..."
    }
  ]
}
```

### Error Detection Workflow

```bash
# Step 1: Detect CI failures
gh pr checks

# Step 2: Fetch error details
python scripts/inspect_pr_checks.py --json > /tmp/ci-errors.json

# Step 3: Determine error category (parse logSnippet)
# Step 4: Apply fix strategy (see patterns below)
# Step 5: Fix → commit → push
git add .
git commit -m "fix(ci): {category} - {short description}"
git push
```

## Error Categories and Fix Strategies

### 1. Type Errors (TypeScript)

**Detection keywords**:

- `TS2345`, `TS2339`, `TS2322`, `TS7006`, `TS2571`
- `error TS`, `Type 'X' is not assignable`, `Property 'X' does not exist`

**Fix strategies**:

#### A. Fix type mismatches

**Pattern**: Argument or return types do not match

```typescript
// Error example
validateToken(token); // error TS2345: Argument of type 'string' is not assignable to parameter of type 'number'

// Fix 1: Type assertion or conversion (when correct type is guaranteed)
validateToken(Number(token));

// Fix 2: Update function signature (when argument type is wrong)
function validateToken(token: string) { ... }

// Fix 3: Optional types (when nullable)
function validateToken(token: string | null) { ... }
```

#### B. Property does not exist

**Pattern**: Accessing a property that does not exist on the type

```typescript
// Error example
user.email; // error TS2339: Property 'email' does not exist on type 'User'

// Fix 1: Extend the type definition
interface User {
  email: string;
}

// Fix 2: Optional access
user.email ?? "default@example.com";

// Fix 3: Type guard
if ("email" in user) {
  user.email;
}
```

#### C. Implicit any

**Pattern**: Parameter has implicit any type

```typescript
// Error example
function processData(data) { ... } // error TS7006: Parameter 'data' implicitly has an 'any' type

// Fix: Specify a proper type
function processData(data: string) { ... }
function processData(data: unknown) { ... } // when type is unknown
```

### 2. Lint Errors (ESLint)

**Detection keywords**:

- `error`, `warning`, `eslint`, `Expected`, `Unexpected`
- File path and rule name (e.g., `no-unused-vars`, `@typescript-eslint/no-explicit-any`)

**Fix strategies**:

#### A. Unused variables

**Rules**: `no-unused-vars`, `@typescript-eslint/no-unused-vars`

```typescript
// Error example
const unused = 42; // error: 'unused' is assigned a value but never used

// Fix 1: Remove
// (delete the variable)

// Fix 2: _ prefix (only if unavoidable)
const _unused = 42; // when constrained (e.g., error handling)
```

#### B. Explicit any

**Rule**: `@typescript-eslint/no-explicit-any`

```typescript
// Error example
function process(data: any) { ... } // error: Unexpected any. Specify a different type

// Fix 1: Concrete type
function process(data: UserData) { ... }

// Fix 2: unknown type
function process(data: unknown) { ... }

// Fix 3: Generic type
function process<T>(data: T) { ... }
```

#### C. Unnecessary type assertions

**Rule**: `@typescript-eslint/no-unnecessary-type-assertion`

```typescript
// Error example
const value = someValue as string; // error: This assertion is unnecessary

// Fix: Remove the assertion
const value = someValue;
```

### 3. Test Failures

**Detection keywords**:

- `FAIL`, `FAILED`, `expected`, `received`, `AssertionError`
- `Test Suites:`, `Tests:`, `jest`, `vitest`, `mocha`

**Fix strategies**:

#### A. Assertion failures

**Pattern**: Expected value does not match actual value

```typescript
// Error example
expect(result).toBe(42);
// Expected: 42
// Received: "42"

// Fix 1: Type conversion
expect(Number(result)).toBe(42);

// Fix 2: Update expected value (if spec changed)
expect(result).toBe("42");

// Fix 3: Fix implementation
function calculate(): number {
  // Return a number
  return 42;
}
```

#### B. Missing mocks

**Pattern**: External dependency is not mocked properly

```typescript
// Error example
// Error: Cannot read property 'get' of undefined (axios)

// Fix: Add mock
vi.mock("axios", () => ({
  default: {
    get: vi.fn().mockResolvedValue({ data: [] }),
  },
}));
```

#### C. Missing await

**Pattern**: Missing `await` for async code

```typescript
// Error example
test("fetches data", () => {
  const result = fetchData(); // Promise unresolved
  expect(result).toEqual(expected); // fails
});

// Fix
test("fetches data", async () => {
  const result = await fetchData();
  expect(result).toEqual(expected);
});
```

### 4. Build Errors

**Detection keywords**:

- `Error: Cannot find module`, `Module not found`, `ENOENT`
- `Build failed`, `Compilation error`

**Fix strategies**:

#### A. Missing modules

**Pattern**: Dependency not installed

```bash
# Error example
Error: Cannot find module 'lodash'

# Fix: Install dependency
npm install lodash
# or
pnpm add lodash
```

#### B. Incorrect import paths

**Pattern**: File path is incorrect

```typescript
// Error example
import { helper } from "./utils/helper"; // Error: Cannot find module

// Fix: Correct the path
import { helper } from "../utils/helper";
// or
import { helper } from "@/utils/helper"; // using alias
```

#### C. Build config errors

**Pattern**: Issue in tsconfig.json or webpack config

```json
// Error example: "Cannot find name 'process'"

// Fix: Add type definitions in tsconfig.json
{
  "compilerOptions": {
    "types": ["node"]
  }
}
```

## Auto-Fix Priority

### 1. Safe to fix automatically

- Remove unused variables
- Remove unnecessary type assertions
- Sort imports
- Formatting violations

### 2. Requires inference (act carefully)

- Type mismatch fixes (assertion vs signature change)
- Property missing (extend types vs optional access)
- Test expectation changes

### 3. Requires manual intervention

- Logic errors
- Issues requiring architectural changes
- Breaking changes due to external API changes

## Fix Implementation Patterns

### Pattern 1: Single-file type error

```bash
# 1. Detect errors
python scripts/inspect_pr_checks.py --json > /tmp/ci-errors.json

# 2. Parse error
# from logSnippet:
#   - File path: src/auth.ts
#   - Line number: 45
#   - Error: TS2345

# 3. Read the file
Read src/auth.ts

# 4. Implement fix
Edit src/auth.ts (fix the relevant location)

# 5. Commit and push
git add src/auth.ts
git commit -m "fix(ci): type error - fix validateToken arg type"
git push
```

### Pattern 2: Multi-file lint errors

```bash
# 1. Run lint (locally)
npm run lint

# 2. Fix auto-fixable issues
npm run lint -- --fix

# 3. Manual fixes
# (e.g., no-unused-vars)

# 4. Commit and push
git add .
git commit -m "fix(ci): lint - remove unused variables"
git push
```

### Pattern 3: Test failures

```bash
# 1. Run tests (locally)
npm run test

# 2. Identify failing test
# from logSnippet:
#   - Test file: tests/auth.test.ts
#   - Test name: "should validate token"

# 3. Fix test code or implementation
Read tests/auth.test.ts
Read src/auth.ts
Edit tests/auth.test.ts

# 4. Re-run to confirm
npm run test

# 5. Commit and push
git add tests/auth.test.ts src/auth.ts
git commit -m "fix(ci): test - fix validateToken assertion"
git push
```

## Stop Conditions for the Fix Loop

### Continue auto-fixing

- 1st attempt: always continue
- 2nd attempt: continue if the error category differs from the previous attempt
- 3rd attempt: continue if the error category differs from the previous attempt

### Report to the user (stop)

Stop and report within 3 attempts if:

- The same error occurs 3 times in a row
- Error category is unknown (unclassified error)
- Logs are unavailable (status: "log_unavailable")
- External checks (status: "external")

### Report format when attempts are exceeded

```
Tried CI fixes 3 times, but failures persist.

Fixes attempted:
1. fix(ci): type error - fix validateToken arg type
2. fix(ci): lint - remove unused variables
3. fix(ci): type error - extend User type definition

Remaining errors:
- Check name: TypeScript Build
- Error category: type error
- File: src/auth.ts:67
- Details: error TS2339: Property 'role' does not exist on type 'User'

Recommended next steps:
1. Add role to the User type
2. Or change role access to optional chaining
3. Manually commit and push, then re-check
```

## Notes

- Fixes run automatically without confirmation, so apply carefully
- Always push after each fix to retrigger CI
- If the same error repeats, stop early
- If logs are incomplete (status: "log_pending"), wait a few seconds and retry
- External checks (e.g., GitHub Apps) cannot be auto-fixed; skip
