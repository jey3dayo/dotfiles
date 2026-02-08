# mise Best Practices - 2025 Field-Tested Guide

This document contains comprehensive best practices for mise (mise-en-place) task runner, based on real-world usage patterns converged in 2025. All examples assume mise v2025.x, whose syntax has been stable since 2024-09.

## 1. File-System & Top-Level Layout

### Project Structure

- **Single mise.toml at project root**
  - Only introduce per-package mise.toml files in a monorepo when those packages can be built/tested in isolation
- **Deterministic ordering**: Place `[settings]`, `[env]`, `[tools]` first, then `[tasks]` in alphabetical order
- **External scripts**: Put long scripts in `mise-tasks/` or `scripts/` and call them from tasks rather than embedding >3 lines of shell in the run array
- **Lockfile**: Check in `mise.lock` if you enable the experimental lockfile feature so CI matches local dev

### Typical Skeleton

```toml
# mise.toml
[settings]           # global mise settings
jobs   = 8
paranoid = true

[env]                # project-wide env vars
RUST_BACKTRACE = "1"

[tools]              # tool versions
node = "22"
rust = "stable"

[tasks]              # everything below here are tasks
```

## 2. "run" vs "depends" - The Mental Model

### run – WHAT THIS TASK DOES

### Characteristics:

- Mandatory key for every task
- Can be a single string, an array of strings, or an array mixing scripts and task objects
- Executes in the order written, serially, **inside the task's shell**
- Tasks referenced with `{ task = "x" }` (or `{ tasks=[...] }`) are _inline_ steps
- They are **not deduplicated** across the whole DAG
- Won't run in parallel with siblings

**Use Case:** A "build-then-package" meta-task

### Example:

```toml
[tasks.release]
run = [
  "cargo build --release",
  { task = "package" },
  "echo 'Release complete'"
]
```

### depends – WHAT MUST FINISH _BEFORE_ THIS TASK CAN START

### Characteristics:

- Pure declarative prerequisites
- Accepts a list of task names (optionally with args)
- mise builds a **global DAG**
- Dependencies that appear more than once run exactly once
- Unrelated branches run in parallel up to `--jobs` or `settings.jobs`
- Great for fan-out/fan-in graphs such as "test depends on lint & build"
- Cannot encode post-steps; use `depends_post` for that

**Use Case:** Fan-out parallelism with proper prerequisites

### Example:

```toml
[tasks.test]
depends = ["lint", "build"]  # These run in parallel
run = "cargo test"
```

### Key Takeaway

- Use `depends` for _ordering/parallelism_
- Use `run` for _the actual commands_ that constitute the task

The official docs describe this separation under Task Configuration → run/depends

## 3. When Should I Prefer One Over the Other?

### ✓ Use depends …

- When you need proper prerequisite semantics
- When many tasks need a common setup task (e.g. "setup-db")
- In CI to maximise parallelism and avoid duplicate work

### ✗ Don't put long shell pipelines in depends

Put them in a separate task and depend on it.

### ✓ Use run …

- For the core logic of the task (e.g. `cargo build`)
- To glue a few tasks/scripts in a very specific order that should _not_ be parallelised (e.g. generate-code → fmt-code → commit-lint)

### Edge Cases

- **Need something to run after the main body no matter what?**
  - Use `depends_post`
- **Need to wait for a long-running task if it happens to be running, but not trigger it otherwise?**
  - Use `wait_for`

## 4. Task Block Best Practices

### Example Task Block

Common properties used:

```toml
[tasks.test]
description = "Unit + integration tests"
alias       = ["t"]          # shortcut: `mise t`
depends     = ["build"]      # prerequisite
run         = [
  "cargo test --all-features",
  { task = "post-test-metrics" }   # inline sub-task
]
retry       = 2              # rerun on flake
timeout     = "10m"
```

### Recommendations

1. **Lower-case kebab for names; 1-2 char aliases**
   - Short aliases (`b` for build, `t` for test) speed up CLI use
2. **Always give description**
   - It feeds `mise tasks` and shell completions
3. **Group meta-tasks under a "+" prefix**
   - `+ci`, `+all` so they sort to the top and are obviously not leaf commands
4. **Keep shell in check**
   - If the run array grows past ~5 lines, move it to a standalone script or a file task

## 5. Organising Aliases

### Alias Property

- The `alias` property accepts a string or array
- Choose single-letter aliases for the 3–5 tasks you run dozens of times a day
- Reserve two-letter combos for the rest (e.g. `cb` for "clean-build")
- Avoid aliases that collide with future mise sub-commands

### Best Practice

- Always call them with `mise run` (or your own shell alias like `mr`) inside docs and CI scripts to avoid ambiguity

## 6. Command-Composition Patterns

### Pattern A – Parallel Fan-Out, Serial Fan-In

```toml
[tasks.build]      # heavy CPU work
run = "cargo build --release"

[tasks.lint]       # quick
run = "eslint ."

[tasks.test]
depends = ["build", "lint"]
run     = "cargo test"
```

- `build` & `lint` run in parallel
- `test` waits for both

### Pattern B – Meta-Task That Orchestrates Fine-Grained Order

```toml
[tasks.release]
description = "Build, sign and publish a release"
run = [
  { task = "build" },
  { task = "sign" },
  { tasks = ["publish-github", "publish-s3"] },  # these two in parallel
]
```

### Pattern C – File Task as First-Class Citizen

`mise-tasks/migrate` (shebang file)

```bash
#!/usr/bin/env bash
#MISE description="Apply database migrations"
#MISE alias=["dbm"]
#MISE depends=["setup-db"]
prisma migrate deploy
```

- Shows up exactly like any TOML task
- Code lives next to script

## 7. CI Integration Tips

### Best Practices

- In GitHub Actions, `mise ci bootstrap` (or your own task) should be the _only_ shell block in the workflow
- Let mise orchestrate the rest
- Pin mise version (`mise use -g mise@2025.10`) so new releases don't surprise your build
- Export `MISE_JOBS=$(nproc)` to fully exploit depends-based parallelism

### Example GitHub Actions

```yaml
steps:
  - uses: actions/checkout@v4
  - name: Setup mise
    uses: jdx/mise-action@v2
    with:
      version: 2025.10.0
  - name: Run CI
    run: mise run +ci
    env:
      MISE_JOBS: ${{ nproc }}
```

## 8. Common Pitfalls to Avoid

### ✗ Calling mise Inside run Strings

### Problem:

```toml
[tasks.bad]
run = "mise build && mise test"  # ❌ Nested mise process
```

This launches a nested mise process without DAG awareness.

**Solution:** Use the structured `{ task = "x" }` form instead:

```toml
[tasks.good]
run = [
  { task = "build" },
  { task = "test" }
]
```

### ✗ Circular Dependencies

mise will detect and error, but it's often quicker to run `mise task deps <task>` to visualise before committing.

### Example:

```bash
mise task deps test
```

### ✗ Conflicting Aliases

Remember they are global within one mise.toml.

### Problem:

```toml
[tasks.test]
alias = ["t"]

[tasks.typescript]
alias = ["t"]  # ❌ Conflict
```

## 9. Advanced Features

### Additional Dependencies

### depends_post:

```toml
[tasks.test]
depends = ["build"]
depends_post = ["cleanup"]  # Runs after test completes
run = "pytest"
```

### wait_for:

```toml
[tasks.integration-test]
wait_for = ["database"]  # Only waits if database task is running
run = "pytest tests/integration"
```

### Task Properties

### Complete Example:

```toml
[tasks.e2e]
description = "End-to-end tests"
alias = ["e"]
depends = ["build", "start-server"]
depends_post = ["stop-server"]
retry = 3
timeout = "15m"
dir = "./e2e"
env = { BASE_URL = "http://localhost:3000" }
run = "playwright test"
```

## 10. Performance Optimization

### Parallel Execution

- Use `depends` instead of sequential `run` when tasks don't have ordering requirements
- Set appropriate `jobs` in `[settings]` to match CPU cores
- Monitor execution with `mise run --timing`

### Task Granularity

- Break large tasks into smaller, composable units
- Create shared setup tasks that multiple tasks can depend on
- Avoid duplicate work across task definitions

## Cheat-Sheet

| Property       | Purpose                                          |
| -------------- | ------------------------------------------------ |
| `run`          | The commands of _this_ task (serial, imperative) |
| `depends`      | Tasks that must succeed _before_ this one        |
| `depends_post` | Tasks that run _after_ this task completes       |
| `wait_for`     | "Soft" dependency; only waits if already running |
| `alias`        | Shorthand(s) for humans                          |
| `description`  | Human-readable one-liner                         |
| `retry`        | Number of retry attempts on failure              |
| `timeout`      | Maximum execution time                           |
| `dir`          | Working directory override                       |
| `env`          | Task-specific environment variables              |

## Summary

With this structure your mise.toml stays:

- **Readable**: Clear separation of concerns
- **Parallel-friendly**: Optimal use of depends for concurrency
- **Maintainable**: Easy to extend and modify as project grows

---

**Source:** Field-tested practices from 2025, synthesized from real-world mise usage patterns.
**Documentation:** [mise.jdx.dev](https://mise.jdx.dev/tasks/)
