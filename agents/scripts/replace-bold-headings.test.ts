#!/usr/bin/env tsx

import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Test cases with expected behavior
const testCases = [
  {
    name: "Bold heading without suffix",
    input: "**Overview**",
    expected: "### Overview",
    shouldConvert: true,
  },
  {
    name: "Bold label with trailing colon (no content)",
    input: "**Phase 2関連（10ファイル）**:",
    expected: "#### Phase 2関連（10ファイル）",
    shouldConvert: true,
  },
  {
    name: "Bold label with parentheses and colon",
    input: "**セットアップ** (初回のみ):",
    expected: "#### セットアップ (初回のみ)",
    shouldConvert: true,
  },
  {
    name: "Bold label with content after colon (MUST preserve)",
    input: "**削除結果**: 16ファイル完全削除（廃止警告→削除への移行完了）",
    expected: "**削除結果**: 16ファイル完全削除（廃止警告→削除への移行完了）",
    shouldConvert: false,
  },
  {
    name: "Bold label with directional arrow suffix",
    input: "**Phase 3関連（6ファイル）** ← 既にPhase 4で廃止警告追加済み:",
    expected: "**Phase 3関連（6ファイル）** ← 既にPhase 4で廃止警告追加済み:",
    shouldConvert: false,
  },
  {
    name: "Ordered list with bold label and content (MUST preserve bold)",
    input: "1. **Read Guidelines**: 必ず最初に読む",
    expected: "1. **Read Guidelines**: 必ず最初に読む",
    shouldConvert: false,
  },
  {
    name: "Ordered list with bold label and Japanese content (MUST preserve bold)",
    input: "1. **フェーズ1**: 説明",
    expected: "1. **フェーズ1**: 説明",
    shouldConvert: false,
  },
  {
    name: "Ordered list with bold label and English content (MUST preserve bold)",
    input: "1. **Phase 1**: Description",
    expected: "1. **Phase 1**: Description",
    shouldConvert: false,
  },
  {
    name: "Ordered list with bold label and colon only",
    input: "1. **Phase 1**:",
    expected: "1. Phase 1:",
    shouldConvert: true,
  },
  {
    name: "Ordered list with bold label and arrow",
    input: "1. **Phase 1** → do something",
    expected: "1. Phase 1 → do something",
    shouldConvert: true,
  },
  {
    name: "Unordered list with bold label (colon only)",
    input: "- **Text**:",
    expected: "- Text:",
    shouldConvert: true,
  },
  {
    name: "Unordered list with bold label and content (MUST preserve bold)",
    input: "- **Text**: content here",
    expected: "- **Text**: content here",
    shouldConvert: false,
  },
  {
    name: "Unordered list with bold label and Japanese content (MUST preserve bold)",
    input: "- **メリット**: 初回ロード軽量",
    expected: "- **メリット**: 初回ロード軽量",
    shouldConvert: false,
  },
  {
    name: "Unordered list with bold label (no colon)",
    input: "- **OpenClaw関連（4ファイル）**",
    expected: "- OpenClaw関連（4ファイル）",
    shouldConvert: true,
  },
  {
    name: "Unordered list with bold label and right arrow (should remove bold)",
    input: "- **出力あり** → uncommitted changes モード",
    expected: "- 出力あり → uncommitted changes モード",
    shouldConvert: true,
  },
  {
    name: "Unordered list with bold label and right arrow, Japanese (should remove bold)",
    input: "- **critical issues あり** → 該当ファイルを Read し、Edit で修正を適用",
    expected: "- critical issues あり → 該当ファイルを Read し、Edit で修正を適用",
    shouldConvert: true,
  },
];

// Create test file
const testContent = testCases.map((tc) => tc.input).join("\n");
const testFile = path.join(__dirname, "test-input.md");
fs.writeFileSync(testFile, testContent, "utf8");

console.log("Running bold heading replacement tests...\n");

// Import the processing function (would need to export it from main script)
// For now, we'll run the script and check output

import { execSync } from "node:child_process";

try {
  const scriptPath = path.resolve(__dirname, "..", "..", "scripts", "replace-bold-headings.ts");

  // Run the script on test file
  execSync(`tsx "${scriptPath}" "${testFile}"`, {
    encoding: "utf8",
    stdio: "pipe",
  });

  const result = fs.readFileSync(testFile, "utf8");
  const resultLines = result.split("\n");

  let passCount = 0;
  let failCount = 0;

  testCases.forEach((tc, i) => {
    const actualLine = resultLines[i];
    const pass = actualLine === tc.expected;

    if (pass) {
      passCount++;
      console.log(`✅ ${tc.name}`);
    } else {
      failCount++;
      console.log(`❌ ${tc.name}`);
      console.log(`   Input:    "${tc.input}"`);
      console.log(`   Expected: "${tc.expected}"`);
      console.log(`   Actual:   "${actualLine}"`);
    }
  });

  console.log(`\nResults: ${passCount}/${testCases.length} passed`);

  // Cleanup
  fs.unlinkSync(testFile);

  if (failCount > 0) {
    process.exit(1);
  }
} catch (error) {
  console.error("Test execution failed:", error);
  if (fs.existsSync(testFile)) {
    fs.unlinkSync(testFile);
  }
  process.exit(1);
}

// ========================================
// Directory exclusion tests
// ========================================

console.log("\nRunning directory exclusion tests...\n");

import { execSync as execSyncNode } from "node:child_process";

const tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), "bold-headings-excl-"));

// Bold pattern that WOULD be changed if processed
const boldContent = "**Overview**\n";

// Directories that must be excluded
const excludedDirs = [
  "node_modules",
  ".worktrees",
  ".kiro",
  ".luarocks",
  "fisher",
  "result",
  "result-abc",
  path.join("tmux", "plugins"),
  path.join("zsh", ".zinit"),
  path.join("agents", "external"),
];

// Similar-looking but NOT excluded path (must still be processed)
const boundaryLikeDir = path.join("mytmux", "plugins");
const boundaryLikeFile = path.join(tmpRoot, boundaryLikeDir, "test.md");
fs.mkdirSync(path.dirname(boundaryLikeFile), { recursive: true });
fs.writeFileSync(boundaryLikeFile, boldContent, "utf8");

// Create test files inside each excluded directory
for (const dir of excludedDirs) {
  const fullDir = path.join(tmpRoot, dir);
  fs.mkdirSync(fullDir, { recursive: true });
  fs.writeFileSync(path.join(fullDir, "test.md"), boldContent, "utf8");
}

// Also create a normal file that SHOULD be processed
const normalFile = path.join(tmpRoot, "normal.md");
fs.writeFileSync(normalFile, boldContent, "utf8");

const scriptPath2 = path.resolve(__dirname, "..", "..", "scripts", "replace-bold-headings.ts");

try {
  execSyncNode(`tsx "${scriptPath2}" "${tmpRoot}"`, { encoding: "utf8", stdio: "pipe" });

  let exclPass = 0;
  let exclFail = 0;

  // Check excluded dirs: content must be UNCHANGED
  for (const dir of excludedDirs) {
    const filePath = path.join(tmpRoot, dir, "test.md");
    const content = fs.readFileSync(filePath, "utf8");
    if (content === boldContent) {
      exclPass++;
      console.log(`✅ Excluded: ${dir}/test.md (unchanged)`);
    } else {
      exclFail++;
      console.log(`❌ Excluded: ${dir}/test.md (was modified!)`);
      console.log(`   Expected: "${boldContent.trim()}"`);
      console.log(`   Actual:   "${content.trim()}"`);
    }
  }

  // Check normal file: content must be CHANGED (bold converted to heading)
  const normalContent = fs.readFileSync(normalFile, "utf8");
  if (normalContent !== boldContent) {
    exclPass++;
    console.log(`✅ Normal file was processed (bold converted)`);
  } else {
    exclFail++;
    console.log(`❌ Normal file was NOT processed (bold should have been converted)`);
  }

  // Check boundary-like dir: content must be CHANGED (must not be over-skipped)
  const boundaryLikeContent = fs.readFileSync(boundaryLikeFile, "utf8");
  if (boundaryLikeContent !== boldContent) {
    exclPass++;
    console.log(`✅ Boundary-like dir was processed (${boundaryLikeDir})`);
  } else {
    exclFail++;
    console.log(`❌ Boundary-like dir was skipped unexpectedly (${boundaryLikeDir})`);
  }

  // Check excluded root target: passing an excluded dir directly must still skip processing
  const excludedRoot = path.join(tmpRoot, "node_modules");
  execSyncNode(`tsx "${scriptPath2}" "${excludedRoot}"`, { encoding: "utf8", stdio: "pipe" });

  const excludedRootContent = fs.readFileSync(path.join(excludedRoot, "test.md"), "utf8");
  if (excludedRootContent === boldContent) {
    exclPass++;
    console.log(`✅ Excluded root target was skipped (node_modules)`);
  } else {
    exclFail++;
    console.log(`❌ Excluded root target was processed unexpectedly (node_modules)`);
  }

  const totalExcl = excludedDirs.length + 3;
  console.log(`\nExclusion results: ${exclPass}/${totalExcl} passed`);

  if (exclFail > 0) process.exit(1);
} finally {
  fs.rmSync(tmpRoot, { recursive: true, force: true });
}
