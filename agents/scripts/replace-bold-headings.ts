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
  targetPaths: string[];
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
    targetPaths: [],
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
      // 位置引数（ファイル/ディレクトリパス）
      result.targetPaths.push(arg);
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

function resolveTargetPaths(userInputs: string[]): string[] {
  // デフォルト値（引数なしの場合）
  if (userInputs.length === 0) {
    const repoRoot = path.resolve(__dirname, "../..");
    return [path.join(repoRoot, "agents", "internal")];
  }

  // ユーザー指定のパスを解決
  return userInputs.map((input) => path.resolve(process.cwd(), input));
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
    // Standalone bold-only lines are treated as pseudo headings.
    // Example: "**Overview**" -> "### Overview"
    const boldOnlyHeading = /^(\s*)\*\*([^*][\s\S]*?)\*\*\s*$/;

    // Bold labels in ordered list items are normalized to plain text.
    // Example: "1. **Read Guidelines**:" -> "1. Read Guidelines:"
    const boldOrderedListLabel =
      /^(\s*\d+\.\s+)\*\*([^*][\s\S]*?)\*\*(\s*[:\-]\s*.*)?$/;

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

      const listLabelMatch = line.match(boldOrderedListLabel);
      if (listLabelMatch) {
        const prefix = listLabelMatch[1];
        const text = listLabelMatch[2];
        const suffix = listLabelMatch[3] ?? "";
        if (!text.includes("**")) {
          fileReplacements += 1;
          return `${prefix}${text}${suffix}`;
        }
      }

      const headingMatch = line.match(boldOnlyHeading);
      if (!headingMatch) {
        return line;
      }

      const indent = headingMatch[1];
      if (headingMatch[2].includes("**")) {
        return line;
      }
      const text = headingMatch[2].trim();
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

function collectMarkdownFiles(targets: string[]): string[] {
  const markdownFiles = new Set<string>();

  const walk = (currentDir: string) => {
    for (const entry of fs.readdirSync(currentDir, { withFileTypes: true })) {
      const fullPath = path.join(currentDir, entry.name);
      if (entry.isDirectory()) {
        walk(fullPath);
        continue;
      }
      if (entry.isFile() && fullPath.endsWith(".md")) {
        markdownFiles.add(fullPath);
      }
    }
  };

  for (const target of targets) {
    if (!fs.existsSync(target)) {
      console.error(`Path not found: ${target}`);
      process.exit(1);
    }

    const stat = fs.statSync(target);
    if (stat.isDirectory()) {
      walk(target);
      continue;
    }

    if (stat.isFile() && target.endsWith(".md")) {
      markdownFiles.add(target);
    }
  }

  return Array.from(markdownFiles).sort();
}

// ========================================
// Help Message
// ========================================

function showUsage() {
  console.log(`
Usage:
  replace-bold-headings [paths...] [options]

Arguments:
  paths                   Target file/directory paths to process
                         Default: agents/internal (skills, agents, rules, commands)
                         Can specify multiple paths

Options:
  --dry-run              Show changes without modifying files
  --verbose, -v          Show detailed processing information
  --help, -h             Show this help message

Examples:
  # Process default directory (internal assets)
  tsx replace-bold-headings.ts
  mise run skills:fix:bold-headings

  # Process other directories
  tsx replace-bold-headings.ts .
  tsx replace-bold-headings.ts .claude
  tsx replace-bold-headings.ts docs README.md
  mise run format:markdown:bold-headings -- docs

  # Dry run mode
  tsx replace-bold-headings.ts . --dry-run
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

  const targetPaths = resolveTargetPaths(args.targetPaths);

  console.log("Target path(s):");
  for (const targetPath of targetPaths) {
    console.log(`- ${targetPath}`);
  }
  if (args.dryRun) {
    console.log("(Dry run mode - no files will be modified)");
  }

  // ファイル収集
  const markdownFiles = collectMarkdownFiles(targetPaths);

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
    console.log("No bold heading/label patterns found.");
  } else {
    const verb = args.dryRun ? "Found" : "Replaced";
    console.log(
      `${verb} ${totalReplacements} bold heading/label pattern(s) across ${successCount} file(s).`,
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
