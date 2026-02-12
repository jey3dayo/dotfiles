# Source Detection

Implementation Engineのソース検出ロジック。Web URL、ローカルパス、実装プラン、機能説明文の判定と処理方法。

## ソースタイプ

Implementation Engineは4種類のソースを認識します:

1. **Web URLs** - オンラインのコードリポジトリやドキュメント
2. **Local Paths** - ローカルファイルシステムのファイルやディレクトリ
3. **Implementation Plans** - 既存の実装計画ファイル
4. **Feature Descriptions** - 自然言語での機能説明

## Web URLs

### 対応サイト

### GitHub:

```
https://github.com/user/repo
https://github.com/user/repo/tree/main/path/to/code
https://github.com/user/repo/blob/main/file.ts
```

### GitLab:

```
https://gitlab.com/user/repo
https://gitlab.com/user/repo/-/tree/main/path
https://gitlab.com/user/repo/-/blob/main/file.ts
```

### CodePen:

```
https://codepen.io/user/pen/abc123
https://codepen.io/user/full/abc123
```

### JSFiddle:

```
https://jsfiddle.net/user/abc123/
```

### CodeSandbox:

```
https://codesandbox.io/s/abc123
```

### StackBlitz:

```
https://stackblitz.com/edit/abc123
```

### ドキュメントサイト:

```
https://docs.example.com/guide/feature
https://developer.mozilla.org/en-US/docs/Web/API
```

### 検出ロジック

```typescript
function detectWebURL(input: string): boolean {
  const urlPattern = /^https?:\/\//;
  return urlPattern.test(input);
}

function categorizeWebURL(url: string): WebSourceType {
  if (url.includes("github.com")) return "github";
  if (url.includes("gitlab.com")) return "gitlab";
  if (url.includes("codepen.io")) return "codepen";
  if (url.includes("jsfiddle.net")) return "jsfiddle";
  if (url.includes("codesandbox.io")) return "codesandbox";
  if (url.includes("stackblitz.com")) return "stackblitz";
  return "documentation";
}
```

### 処理方法

### GitHub/GitLab リポジトリ:

```typescript
async function processGitHubRepo(url: string) {
  // Extract repo info
  const { owner, repo, path, branch } = parseGitHubURL(url);

  // Use WebFetch to get content
  const content = await WebFetch({
    url,
    prompt: "Extract all code and implementation details",
  });

  // Analyze structure
  const structure = analyzeRepoStructure(content);

  // Download key files
  const keyFiles = identifyKeyFiles(structure);
  for (const file of keyFiles) {
    await downloadFile(file);
  }
}
```

### Code Playgrounds:

```typescript
async function processCodePen(url: string) {
  // Fetch pen content
  const content = await WebFetch({
    url,
    prompt: "Extract HTML, CSS, and JavaScript code",
  });

  // Parse into components
  const { html, css, js } = parseCodePenContent(content);

  // Save as files
  await saveFile("index.html", html);
  await saveFile("styles.css", css);
  await saveFile("script.js", js);
}
```

### ドキュメントサイト:

```typescript
async function processDocumentation(url: string) {
  // Fetch documentation
  const content = await WebFetch({
    url,
    prompt: "Extract implementation guide and code examples",
  });

  // Extract code examples
  const examples = extractCodeExamples(content);

  // Extract requirements
  const requirements = extractRequirements(content);

  return { examples, requirements };
}
```

## Local Paths

### 対応パス

### 単一ファイル:

```
./src/auth/login.ts
/absolute/path/to/file.tsx
../legacy/auth-system.js
```

### ディレクトリ:

```
./legacy-code/
/path/to/feature/
../old-implementation/
```

### 実装プラン:

```
./implement/plan.md
./docs/feature-plan.md
```

### 検出ロジック

```typescript
function detectLocalPath(input: string): boolean {
  // Absolute path
  if (input.startsWith("/")) return true;

  // Relative path
  if (input.startsWith("./") || input.startsWith("../")) return true;

  // Check if file exists
  return fs.existsSync(input);
}

function categorizeLocalPath(path: string): LocalSourceType {
  const stats = fs.statSync(path);

  if (stats.isDirectory()) return "directory";

  if (path.endsWith(".md") && containsChecklist(path)) {
    return "implementation-plan";
  }

  return "file";
}
```

### 処理方法

### 単一ファイル:

```typescript
async function processFile(filePath: string) {
  // Read file content
  const content = await readFile(filePath);

  // Analyze file type
  const fileType = detectFileType(filePath);

  // Extract implementation details
  const details = analyzeCode(content, fileType);

  return details;
}
```

### ディレクトリ:

```typescript
async function processDirectory(dirPath: string) {
  // List all files
  const files = await listFilesRecursively(dirPath);

  // Filter code files
  const codeFiles = files.filter(isCodeFile);

  // Analyze structure
  const structure = analyzeDirectoryStructure(codeFiles);

  // Load files incrementally
  for (const file of prioritizeFiles(codeFiles)) {
    await processFile(file);
  }
}
```

### 実装プラン:

```typescript
async function processImplementationPlan(planPath: string) {
  // Read plan
  const plan = await readFile(planPath);

  // Parse sections
  const sections = parsePlanSections(plan);

  // Extract tasks
  const tasks = extractTasks(sections);

  // Resume from checkpoint
  const currentTask = findCurrentTask(tasks);

  return { plan, tasks, currentTask };
}
```

## Implementation Plans

### プランファイルの識別

```typescript
function isImplementationPlan(filePath: string): boolean {
  if (!filePath.endsWith(".md")) return false;

  const content = fs.readFileSync(filePath, "utf-8");

  // Check for plan indicators
  const indicators = [
    "## Implementation Tasks",
    "## Validation Checklist",
    "- [ ]", // Checkbox
    "## Source Analysis",
    "## Target Integration",
  ];

  return indicators.some((indicator) => content.includes(indicator));
}
```

### プランの解析

```typescript
function parsePlan(content: string) {
  const sections = {
    sourceAnalysis: extractSection(content, "## Source Analysis"),
    targetIntegration: extractSection(content, "## Target Integration"),
    tasks: extractTasks(content, "## Implementation Tasks"),
    validation: extractChecklist(content, "## Validation Checklist"),
    risks: extractSection(content, "## Risk Mitigation"),
  };

  return sections;
}
```

### 進捗の追跡

```typescript
function trackProgress(tasks: Task[]): Progress {
  const total = tasks.length;
  const completed = tasks.filter((t) => t.completed).length;
  const percentage = Math.round((completed / total) * 100);

  return {
    total,
    completed,
    percentage,
    currentTask: tasks.find((t) => !t.completed),
  };
}
```

## Feature Descriptions

### 説明文の識別

```typescript
function isFeatureDescription(input: string): boolean {
  // Not a URL
  if (detectWebURL(input)) return false;

  // Not a path
  if (detectLocalPath(input)) return false;

  // Natural language description
  return input.length > 20 && /[a-zA-Z\s]{10,}/.test(input);
}
```

### 説明の解析

```typescript
function parseDescription(description: string) {
  // Extract key phrases
  const phrases = extractKeyPhrases(description);

  // Identify technologies
  const technologies = identifyTechnologies(description);

  // Extract requirements
  const requirements = extractRequirementsFromText(description);

  // Identify similar implementations
  const examples = findSimilarImplementations(phrases);

  return {
    phrases,
    technologies,
    requirements,
    examples,
  };
}
```

### リサーチの実行

```typescript
async function researchFeature(description: string) {
  // Search for implementations
  const searchResults = await searchCodeExamples(description);

  // Find documentation
  const docs = await findDocumentation(description);

  // Extract best practices
  const bestPractices = extractBestPractices(searchResults, docs);

  return {
    implementations: searchResults,
    documentation: docs,
    bestPractices,
  };
}
```

## 統合検出フロー

```typescript
async function detectAndProcessSource(input: string) {
  // Step 1: Detect source type
  const sourceType = detectSourceType(input);

  // Step 2: Process based on type
  switch (sourceType) {
    case "web-url":
      return await processWebURL(input);

    case "local-file":
      return await processFile(input);

    case "local-directory":
      return await processDirectory(input);

    case "implementation-plan":
      return await processImplementationPlan(input);

    case "feature-description":
      return await researchFeature(input);

    default:
      throw new Error(`Unknown source type: ${input}`);
  }
}
```

### 検出の優先順位

```typescript
function detectSourceType(input: string): SourceType {
  // 1. Check for web URL (highest priority)
  if (detectWebURL(input)) {
    return categorizeWebURL(input);
  }

  // 2. Check for existing implementation plan
  if (fs.existsSync(input) && isImplementationPlan(input)) {
    return "implementation-plan";
  }

  // 3. Check for local path
  if (detectLocalPath(input)) {
    return categorizeLocalPath(input);
  }

  // 4. Default to feature description
  return "feature-description";
}
```

## 複数ソースの処理

### 複数ソースの検出

```typescript
function detectMultipleSources(args: string[]): Source[] {
  return args.map((arg) => ({
    input: arg,
    type: detectSourceType(arg),
  }));
}
```

### 統合処理

```typescript
async function processMultipleSources(sources: Source[]) {
  const results = await Promise.all(
    sources.map((source) => detectAndProcessSource(source.input)),
  );

  // Merge implementations
  const merged = mergeImplementations(results);

  // Resolve conflicts
  const resolved = resolveConflicts(merged);

  return resolved;
}
```

## エラーハンドリング

### 無効なソース

```typescript
function validateSource(input: string): ValidationResult {
  if (!input || input.trim().length === 0) {
    return {
      valid: false,
      error: "Source cannot be empty",
    };
  }

  if (detectWebURL(input) && !isReachable(input)) {
    return {
      valid: false,
      error: "URL is not reachable",
    };
  }

  if (detectLocalPath(input) && !fs.existsSync(input)) {
    return {
      valid: false,
      error: "File or directory does not exist",
    };
  }

  return { valid: true };
}
```

### フォールバック戦略

```typescript
async function processSourceWithFallback(input: string) {
  try {
    // Try primary method
    return await detectAndProcessSource(input);
  } catch (error) {
    // Try alternative method
    console.warn("Primary method failed, trying alternative...");

    if (detectWebURL(input)) {
      // Try manual fetch
      return await manualFetch(input);
    }

    if (detectLocalPath(input)) {
      // Try alternative file reading
      return await alternativeFileRead(input);
    }

    // Give up
    throw new Error(`Cannot process source: ${input}`);
  }
}
```

## ベストプラクティス

### ソース検出:

1. 明示的なタイプより推論を優先
2. エラーハンドリングを常に実装
3. 複数ソースをサポート
4. フォールバック戦略を用意

### 処理最適化:

1. 大きなソースは段階的にロード
2. 不要なファイルをスキップ
3. 並列処理を活用
4. キャッシュを利用

### ユーザー体験:

1. ソースタイプを明確に報告
2. 処理進捗を表示
3. エラーメッセージを分かりやすく
4. 推奨事項を提供
