# Golang 詳細リファレンス

## Core Evaluation Areas

### 1. Idiomatic Go (Go Idioms)

Assess adherence to Go community conventions and idiomatic patterns:

#### Naming Conventions

- Use MixedCaps or mixedCaps (not snake_case)
- Short, concise names for local variables (`i`, `r`, `buf`)
- Descriptive names for package-level declarations
- Interface names: `-er` suffix convention (`Reader`, `Writer`)

### ⭐️5

### ⭐️4

### ⭐️3

### ⭐️2

### ⭐️1

#### Code Organization

- Package structure follows standard layout
- Appropriate use of internal packages
- Clear separation of concerns
- Minimal cyclic dependencies

#### Common Idioms

```go
// ✅ Good: Check error immediately
if err := doSomething(); err != nil {
    return err
}

// ❌ Bad: Deferred error check
err := doSomething()
// ... other code
if err != nil {
    return err
}
```

```go
// ✅ Good: Empty struct for signal channel
done := make(chan struct{})

// ❌ Bad: Using bool
done := make(chan bool)
```

### 2. Error Handling

Evaluate Go's explicit error handling patterns:

#### Error Checking

- All errors checked immediately
- No silent error discarding
- Appropriate error wrapping with context
- Custom error types when beneficial

### Pattern: Error Wrapping (Go 1.13+)

```go
// ✅ Good: Error wrapping with context
if err := processFile(filename); err != nil {
    return fmt.Errorf("failed to process %s: %w", filename, err)
}

// ❌ Bad: Lost error context
if err := processFile(filename); err != nil {
    return errors.New("process failed")
}
```

#### Custom Errors

```go
// ✅ Good: Custom error type
type ValidationError struct {
    Field string
    Value interface{}
    Msg   string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("%s: %v - %s", e.Field, e.Value, e.Msg)
}

// Usage with errors.As
var valErr *ValidationError
if errors.As(err, &valErr) {
    // Handle validation error specifically
}
```

### ⭐️5

### ⭐️4

### ⭐️3

### ⭐️2

### ⭐️1

### 3. Concurrency

Assess goroutine and channel usage:

#### Goroutine Safety

- No race conditions (verified with `go run -race`)
- Proper synchronization (mutexes, channels, sync package)
- Goroutine lifecycle management
- Leak prevention

```go
// ✅ Good: Goroutine with context cancellation
func worker(ctx context.Context) {
    for {
        select {
        case <-ctx.Done():
            return
        case work := <-workChan:
            process(work)
        }
    }
}

// ❌ Bad: Uncancellable goroutine
func worker() {
    for work := range workChan {
        process(work)
    }
}
```

#### Channel Patterns

- Appropriate channel direction (`chan<-`, `<-chan`)
- Proper channel closing
- Select statement usage
- Buffered vs unbuffered choice

```go
// ✅ Good: Sender closes channel
func produce(out chan<- int) {
    defer close(out)
    for i := 0; i < 10; i++ {
        out <- i
    }
}

// ❌ Bad: Receiver closes channel
func consume(in <-chan int) {
    for v := range in {
        process(v)
    }
    close(in) // Wrong! Receiver shouldn't close
}
```

#### sync Package Usage

- Appropriate use of `sync.Mutex`, `sync.RWMutex`
- `sync.WaitGroup` for goroutine coordination
- `sync.Once` for one-time initialization
- `sync.Pool` for object reuse

### ⭐️5

### ⭐️4

### ⭐️3

### ⭐️2

### ⭐️1

### 4. Memory Management

Evaluate memory efficiency and GC impact:

#### Allocation Patterns

- Minimize unnecessary allocations
- Reuse buffers and objects
- Appropriate use of pointers vs values
- Slice capacity pre-allocation

```go
// ✅ Good: Pre-allocate with known size
items := make([]Item, 0, expectedSize)

// ❌ Bad: Grow slice incrementally
var items []Item
for i := 0; i < 1000; i++ {
    items = append(items, Item{})  // Reallocates multiple times
}
```

#### Pointer vs Value

```go
// ✅ Good: Small struct by value
type Point struct {
    X, Y int
}

func distance(p1, p2 Point) float64 {
    // ...
}

// ❌ Bad: Unnecessary pointer for small struct
func distance(p1, p2 *Point) float64 {
    // ...
}
```

#### Resource Cleanup

- Proper use of `defer` for cleanup
- Context cancellation for goroutines
- Connection pooling
- File handle management

### ⭐️5

### ⭐️4

### ⭐️3

### ⭐️2

### ⭐️1

### 5. Interface Design

Assess interface usage and design:

#### Interface Size

- Prefer small, focused interfaces
- "Accept interfaces, return structs" principle
- Interface segregation

```go
// ✅ Good: Small, focused interface
type Reader interface {
    Read(p []byte) (n int, err error)
}

// ❌ Bad: Large, unfocused interface
type DataStore interface {
    Read(id string) ([]byte, error)
    Write(id string, data []byte) error
    Delete(id string) error
    List() ([]string, error)
    Backup() error
    Restore(path string) error
}
```

#### Implicit Implementation

- Interfaces defined by consumer, not provider
- Structs implement implicitly
- Clear interface purpose

### ⭐️5

### ⭐️4

### ⭐️3

### ⭐️2

### ⭐️1

### 6. Standard Library Usage

Evaluate effective use of Go standard library:

#### Common Packages

- `context` for cancellation and deadlines
- `fmt` for formatted I/O
- `errors` for error handling
- `io` and `io/ioutil` for I/O operations
- `net/http` for HTTP services
- `encoding/json` for JSON handling

#### Best Practices

```go
// ✅ Good: Use context for timeout
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()

resp, err := httpGetWithContext(ctx, url)

// ❌ Bad: No timeout
resp, err := http.Get(url)
```

### ⭐️5

### ⭐️4

### ⭐️3

### ⭐️2

### ⭐️1

## Go-Specific Anti-Patterns

### Common Issues

### 1. Goroutine Leaks

```go
// ❌ Bad: Goroutine never exits
go func() {
    for {
        doWork()
    }
}()

// ✅ Good: Goroutine with exit condition
go func() {
    for {
        select {
        case <-ctx.Done():
            return
        default:
            doWork()
        }
    }
}()
```

### 2. Race Conditions

```go
// ❌ Bad: Concurrent map access
var cache = make(map[string]string)

func get(key string) string {
    return cache[key]  // Race if concurrent with set()
}

// ✅ Good: Protected with mutex
var (
    cache = make(map[string]string)
    mu    sync.RWMutex
)

func get(key string) string {
    mu.RLock()
    defer mu.RUnlock()
    return cache[key]
}
```

### 3. Inefficient String Concatenation

```go
// ❌ Bad: String concatenation in loop
var result string
for _, s := range strings {
    result += s  // Creates new string each iteration
}

// ✅ Good: Use strings.Builder
var builder strings.Builder
for _, s := range strings {
    builder.WriteString(s)
}
result := builder.String()
```

## Context7 Integration for Up-to-date Documentation

### When to Use Context7

Use `mcp__plugin_context7_context7__query-docs` when:

- Reviewing code using recent Go features (Go 1.20+)
- Checking latest standard library APIs and best practices
- Verifying current Go idioms and conventions
- Consulting Effective Go guidance
- Resolving uncertainties about Go patterns

### Available Libraries

1. Go Standard Library (`/websites/pkg_go_dev_std_go1_25_3`)
   - Latest standard library APIs (Go 1.25.3)
   - 3,636 code snippets, benchmark score 82.8
   - Use for: API usage, package documentation

2. Effective Go (`/websites/go_dev_doc`)
   - Official Go best practices guide
   - 3,861 code snippets, benchmark score 69.8
   - Use for: idiomatic patterns, conventions

3. Go Language (`/golang/go`)
   - Core Go language documentation
   - 5,743 code snippets, benchmark score 80.8
   - Use for: language features, compiler behavior

### Usage Examples

```
Query: "How to use context.WithTimeout in Go 1.25"
Library: /websites/pkg_go_dev_std_go1_25_3

Query: "Go error wrapping best practices"
Library: /websites/go_dev_doc

Query: "goroutine leak prevention patterns"
Library: /golang/go
```

### Note

## Go Tools Integration

### Required Checks

Run these tools as part of review:

```bash
# Format check
gofmt -s -d .

# Linting
golangci-lint run

# Race detection
go test -race ./...

# Vet for suspicious constructs
go vet ./...

# Static analysis
staticcheck ./...
```

### go.mod Management

- Appropriate module versioning
- Minimal dependencies
- Regular dependency updates
- No indirect dependencies as direct

## Evaluation Guidelines

### ⭐️⭐️⭐️⭐️⭐️ (5/5) Excellent

- Perfect Go idioms throughout
- Comprehensive error handling with wrapping
- Safe, efficient concurrency
- Optimal memory usage
- Excellent interface design
- Effective standard library usage
- Passes all Go tools without warnings

### ⭐️⭐️⭐️⭐️☆ (4/5) Good

- Mostly idiomatic Go code
- Good error handling, minor gaps
- Safe concurrency with minor improvements possible
- Good memory management
- Reasonable interface design
- Good standard library usage
- Few linter warnings

### ⭐️⭐️⭐️☆☆ (3/5) Standard

- Mix of idiomatic and non-idiomatic code
- Basic error handling, some improvements needed
- Mostly safe concurrency, potential issues
- Acceptable memory usage
- Some interface over-specification
- Basic standard library usage
- Multiple linter warnings

### ⭐️⭐️☆☆☆ (2/5) Needs Improvement

- Frequent non-idiomatic patterns
- Inconsistent error handling
- Unsafe concurrency patterns
- Poor memory management
- Interface misuse
- Reinventing standard library
- Many linter errors

### ⭐️☆☆☆☆ (1/5) Requires Overhaul

- Non-Go-like code
- Poor error handling
- Dangerous concurrency
- Memory leaks
- Interface anti-patterns
- Ignoring standard library
- Fails basic Go tools

## Review Workflow

When reviewing Go code:

1. Run Go tools first: gofmt, golangci-lint, go vet
2. Check concurrency: Scan for goroutines, channels, mutexes
3. Verify error handling: Every error checked and handled
4. Assess idioms: Code follows Go conventions
5. Review interfaces: Small, focused, consumer-defined
6. Check memory usage: Appropriate allocations, cleanup
7. Test race detector: `go test -race`
8. Evaluate standard library usage: Not reinventing wheels

## 🤖 Agent Integration

このスキルはGo（Golang）プロジェクトを扱うエージェントに専門知識を提供します:

### Code-Reviewer Agent

- 提供内容: Go慣用句評価、並行処理安全性検証、エラーハンドリング評価
- タイミング: Goコードレビュー時
- コンテキスト:
  - ⭐️5段階評価（Go慣用句、エラー処理、並行処理、インターフェース設計）
  - goroutine安全性チェック
  - channelパターン評価
  - 標準ライブラリ活用度評価

### Orchestrator Agent

- 提供内容: Goプロジェクト構造、Clean Architecture実装
- タイミング: Go機能実装・リファクタリング時
- コンテキスト:
  - 標準プロジェクトレイアウト
  - パッケージ設計パターン
  - 並行処理設計（goroutine, channel, sync）
  - テスト戦略（unit, integration, race detector）

### Error-Fixer Agent

- 提供内容: Goエラーハンドリング修正、並行処理バグ修正
- タイミング: Goエラー修正時
- コンテキスト: エラーチェック実装、defer/panic/recover修正、raceコンディション修正

### 自動ロード条件

- "Go"、"Golang"、"goroutine"、"channel"に言及
- .goファイル操作時
- go.mod、go.sumファイル存在
- プロジェクト検出: Goプロジェクト

### 統合例

```
ユーザー: "Goの並行処理コードをレビューしてraceコンディションを修正"
    ↓
TaskContext作成
    ↓
プロジェクト検出: Go API
    ↓
スキル自動ロード: golang, security
    ↓
エージェント選択: code-reviewer → error-fixer
    ↓ (スキルコンテキスト提供)
Go並行処理パターン + race detector実行
    ↓
実行完了（goroutine安全性向上、mutexまたはchannel適用）
```

## Integration with Related Skills

- security skill: Go-specific security concerns (SQL injection, etc.)
- clean-architecture skill: Go project structure patterns
- code-review skill: General code quality with Go-specific additions

---

### Note
