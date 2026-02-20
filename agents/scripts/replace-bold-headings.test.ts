#!/usr/bin/env tsx

import * as fs from "node:fs";
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
    name: "Ordered list with bold label",
    input: "1. **Read Guidelines**: 必ず最初に読む",
    expected: "1. Read Guidelines: 必ず最初に読む",
    shouldConvert: true, // Should remove bold but keep content
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
