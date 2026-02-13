#!/usr/bin/env tsx

import * as fs from "node:fs";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// ========================================
// Type Definitions
// ========================================

interface ParsedArgs {
  targetDir: string | null;
  dryRun: boolean;
  verbose: boolean;
  showHelp: boolean;
}

interface FileResult {
  path: string;
  replacements: number;
  error?: Error;
}

// ========================================
// Argument Parsing
// ========================================

function parseArguments(): ParsedArgs {
  const args = process.argv.slice(2);
  const result: ParsedArgs = {
    targetDir: null,
    dryRun: false,
    verbose: false,
    showHelp: false,
  };

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];

    if (arg === "--help" || arg === "-h") {
      result.showHelp = true;
    } else if (arg === "--dry-run") {
      result.dryRun = true;
    } else if (arg === "--verbose" || arg === "-v") {
      result.verbose = true;
    } else if (!arg.startsWith("-")) {
      // 位置引数（ディレクトリパス）
      result.targetDir = arg;
    } else {
      console.error(`Unknown option: ${arg}`);
      process.exit(1);
    }
  }

  return result;
}

// ========================================
// Path Resolution
// ========================================

function resolveTargetDirectory(userInput: string | null): string {
  // デフォルト値（引数なしの場合）
  if (!userInput) {
    const repoRoot = path.resolve(__dirname, "../..");
    return path.join(repoRoot, "agents", "distributions", "default", "skills");
  }

  // ユーザー指定のパスを解決
  const resolved = path.resolve(process.cwd(), userInput);

  // 存在チェック
  if (!fs.existsSync(resolved)) {
    console.error(`Directory not found: ${resolved}`);
    process.exit(1);
  }

  // ディレクトリチェック
  if (!fs.statSync(resolved).isDirectory()) {
    console.error(`Not a directory: ${resolved}`);
    process.exit(1);
  }

  return resolved;
}

// ========================================
// File Processing
// ========================================

function processFile(
  filePath: string,
  dryRun: boolean,
  verbose: boolean,
): FileResult {
  try {
    const original = fs.readFileSync(filePath, "utf8");
    const eol = original.includes("\r\n") ? "\r\n" : "\n";
    const lines = original.split(eol);

    const fenceOpen = /^\s*(`{3,}|~{3,})/;
    const boldOnly = /^(\s*)\*\*([^*][\s\S]*?)\*\*(.*)$/;

    let inFence = false;
    let fenceChar = "";
    let fenceLen = 0;
    let fileReplacements = 0;

    const updated = lines.map((line) => {
      const fenceMatch = line.match(fenceOpen);
      if (fenceMatch) {
        const marker = fenceMatch[1];
        const char = marker[0];
        const len = marker.length;
        if (!inFence) {
          inFence = true;
          fenceChar = char;
          fenceLen = len;
        } else if (char === fenceChar && len >= fenceLen) {
          inFence = false;
          fenceChar = "";
          fenceLen = 0;
        }
        return line;
      }

      if (inFence) {
        return line;
      }

      const boldMatch = line.match(boldOnly);
      if (!boldMatch) {
        return line;
      }

      const indent = boldMatch[1];
      if (boldMatch[2].includes("**")) {
        return line;
      }
      const text = boldMatch[2].trim();
      fileReplacements += 1;
      return `${indent}### ${text}`;
    });

    if (fileReplacements > 0) {
      if (verbose) {
        console.log(`  ${filePath}: ${fileReplacements} replacement(s)`);
      }

      if (!dryRun) {
        fs.writeFileSync(filePath, updated.join(eol), "utf8");
      }
    }

    return { path: filePath, replacements: fileReplacements };
  } catch (error) {
    return {
      path: filePath,
      replacements: 0,
      error: error as Error,
    };
  }
}

// ========================================
// Directory Walking
// ========================================

function collectMarkdownFiles(dir: string): string[] {
  const markdownFiles: string[] = [];

  const walk = (currentDir: string) => {
    for (const entry of fs.readdirSync(currentDir, { withFileTypes: true })) {
      const fullPath = path.join(currentDir, entry.name);
      if (entry.isDirectory()) {
        walk(fullPath);
        continue;
      }
      if (entry.isFile() && fullPath.endsWith(".md")) {
        markdownFiles.push(fullPath);
      }
    }
  };

  walk(dir);
  return markdownFiles;
}

// ========================================
// Help Message
// ========================================

function showUsage() {
  console.log(`
Usage:
  replace-bold-headings [directory] [options]

Arguments:
  directory               Target directory to process (default: agents/distributions/default/skills)
                         Use "." for current directory

Options:
  --dry-run              Show changes without modifying files
  --verbose, -v          Show detailed processing information
  --help, -h             Show this help message

Examples:
  # Process default directory
  tsx replace-bold-headings.ts

  # Process current directory
  tsx replace-bold-headings.ts .

  # Process specific directory
  tsx replace-bold-headings.ts /path/to/docs

  # Dry run mode
  tsx replace-bold-headings.ts . --dry-run

  # Verbose output
  tsx replace-bold-headings.ts . --verbose

  # With mise
  mise run skills:fix:bold-headings
  mise run format:markdown:bold-headings
  mise run format:markdown:bold-headings -- /path/to/docs --dry-run
`);
}

// ========================================
// Main Function
// ========================================

function main() {
  const args = parseArguments();

  if (args.showHelp) {
    showUsage();
    process.exit(0);
  }

  const targetDir = resolveTargetDirectory(args.targetDir);

  console.log(`Target directory: ${targetDir}`);
  if (args.dryRun) {
    console.log("(Dry run mode - no files will be modified)");
  }

  // ディレクトリ走査
  const markdownFiles = collectMarkdownFiles(targetDir);

  if (markdownFiles.length === 0) {
    console.log("No markdown files found.");
    process.exit(0);
  }

  // ファイル処理
  const results: FileResult[] = [];
  for (const filePath of markdownFiles) {
    const result = processFile(filePath, args.dryRun, args.verbose);
    results.push(result);
  }

  // 統計情報の集計
  const successCount = results.filter(
    (r) => !r.error && r.replacements > 0,
  ).length;
  const errorCount = results.filter((r) => r.error).length;
  const totalReplacements = results.reduce((sum, r) => sum + r.replacements, 0);

  // 結果表示
  if (totalReplacements === 0) {
    console.log("No bold-only headings found.");
  } else {
    const verb = args.dryRun ? "Found" : "Replaced";
    console.log(
      `${verb} ${totalReplacements} bold-only heading(s) across ${successCount} file(s) in ${targetDir}.`,
    );
  }

  if (errorCount > 0) {
    console.error(`\n${errorCount} file(s) failed to process:`);
    results
      .filter((r) => r.error)
      .forEach((r) => {
        console.error(`  ${r.path}: ${r.error!.message}`);
      });
    process.exit(1);
  }
}

main();
