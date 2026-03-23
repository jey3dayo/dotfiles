#!/usr/bin/env bun

import { afterEach, beforeEach, describe, expect, it } from "bun:test";
import { execSync } from "node:child_process";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const scriptPath = path.join(__dirname, "replace-bold-headings.ts");

const runScript = (target: string) => execSync(`tsx "${scriptPath}" "${target}"`, { encoding: "utf8", stdio: "pipe" });

// ============================================================
// Bold heading conversion
// ============================================================
describe("replace-bold-headings: conversion rules", () => {
  let tmpFile: string;

  const check = (input: string, expected: string) => {
    fs.writeFileSync(tmpFile, `${input}\n`, "utf8");
    runScript(tmpFile);
    expect(fs.readFileSync(tmpFile, "utf8").trimEnd()).toBe(expected);
  };

  beforeEach(() => {
    tmpFile = path.join(os.tmpdir(), `rbh-test-${Date.now()}.md`);
  });

  afterEach(() => {
    if (fs.existsSync(tmpFile)) fs.unlinkSync(tmpFile);
  });

  it("converts standalone bold heading", () => check("**Overview**", "### Overview"));

  it("converts bold label with trailing colon (no content)", () =>
    check("**Phase 2関連（10ファイル）**:", "#### Phase 2関連（10ファイル）"));

  it("converts bold label with parentheses and colon", () =>
    check("**セットアップ** (初回のみ):", "#### セットアップ (初回のみ)"));

  it("strips bold from label with content after colon", () =>
    check(
      "**削除結果**: 16ファイル完全削除（廃止警告→削除への移行完了）",
      "削除結果: 16ファイル完全削除（廃止警告→削除への移行完了）",
    ));

  it("preserves bold when directional arrow suffix follows", () =>
    check(
      "**Phase 3関連（6ファイル）** ← 既にPhase 4で廃止警告追加済み:",
      "**Phase 3関連（6ファイル）** ← 既にPhase 4で廃止警告追加済み:",
    ));

  it("strips bold from ordered list label with content", () =>
    check("1. **Read Guidelines**: 必ず最初に読む", "1. Read Guidelines: 必ず最初に読む"));

  it("strips bold from ordered list label with Japanese content", () =>
    check("1. **フェーズ1**: 説明", "1. フェーズ1: 説明"));

  it("strips bold from ordered list label with English content", () =>
    check("1. **Phase 1**: Description", "1. Phase 1: Description"));

  it("strips bold from ordered list label with colon only", () => check("1. **Phase 1**:", "1. Phase 1:"));

  it("strips bold from ordered list label with arrow", () =>
    check("1. **Phase 1** → do something", "1. Phase 1 → do something"));

  it("strips bold from unordered list label (colon only)", () => check("- **Text**:", "- Text:"));

  it("strips bold from unordered list label with content", () =>
    check("- **Text**: content here", "- Text: content here"));

  it("strips bold from unordered list label with Japanese content", () =>
    check("- **メリット**: 初回ロード軽量", "- メリット: 初回ロード軽量"));

  it("strips bold from unordered list label (no colon)", () =>
    check("- **OpenClaw関連（4ファイル）**", "- OpenClaw関連（4ファイル）"));

  it("strips bold from unordered list label with right arrow", () =>
    check("- **出力あり** → uncommitted changes モード", "- 出力あり → uncommitted changes モード"));

  it("strips bold from unordered list label with right arrow (Japanese)", () =>
    check(
      "- **critical issues あり** → 該当ファイルを Read し、Edit で修正を適用",
      "- critical issues あり → 該当ファイルを Read し、Edit で修正を適用",
    ));

  it("strips bold when colon is inside bold markers", () =>
    check("**責務:** Valibotスキーマ定義", "責務: Valibotスキーマ定義"));

  it("strips bold when colon inside bold, English content", () => check("**現状:** 未実装", "現状: 未実装"));

  it("strips bold when colon inside bold, backtick content", () =>
    check("**返り値の型:** `v.BaseSchema` + 推論型", "返り値の型: `v.BaseSchema` + 推論型"));

  it("preserves all bold in ordered list navigation path", () =>
    check(
      "2. **Workers & Pages** → **keep-on** → **Metrics** タブ",
      "2. **Workers & Pages** → **keep-on** → **Metrics** タブ",
    ));

  it("preserves all bold in unordered list navigation path", () =>
    check("- **File** → **Edit** → **Preferences**", "- **File** → **Edit** → **Preferences**"));

  // Table cell bold stripping
  it("strips bold from table cell label", () => check("| **スキル名** | 説明 |", "| スキル名 | 説明 |"));

  it("strips bold from table cell value", () => check("| metric | **1.1s** |", "| metric | 1.1s |"));

  it("strips bold from multiple table cells", () => check("| **A** | **B** | **C** |", "| A | B | C |"));

  it("preserves table separator row", () => check("| --- | --- |", "| --- | --- |"));

  it("preserves table separator row with colons", () => check("| :--- | :---: | ---: |", "| :--- | :---: | ---: |"));

  it("strips bold from row with dashes in first cell", () => check("| --- | **value** |", "| --- | value |"));

  it("does not treat colon-only cells as separator", () => check("| : | **text** |", "| : | text |"));
});

// ============================================================
// Directory exclusion
// ============================================================
describe("replace-bold-headings: directory exclusion", () => {
  const boldContent = "**Overview**\n";
  let tmpRoot: string;

  beforeEach(() => {
    tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), "rbh-excl-"));
  });

  afterEach(() => {
    fs.rmSync(tmpRoot, { recursive: true, force: true });
  });

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

  it.each(excludedDirs)("skips %s/", (dir) => {
    const file = path.join(tmpRoot, dir, "test.md");
    fs.mkdirSync(path.dirname(file), { recursive: true });
    fs.writeFileSync(file, boldContent, "utf8");
    runScript(tmpRoot);
    expect(fs.readFileSync(file, "utf8")).toBe(boldContent);
  });

  it("processes files outside excluded dirs", () => {
    const file = path.join(tmpRoot, "normal.md");
    fs.writeFileSync(file, boldContent, "utf8");
    runScript(tmpRoot);
    expect(fs.readFileSync(file, "utf8")).not.toBe(boldContent);
  });

  it("processes boundary-like dir (mytmux/plugins)", () => {
    const file = path.join(tmpRoot, "mytmux", "plugins", "test.md");
    fs.mkdirSync(path.dirname(file), { recursive: true });
    fs.writeFileSync(file, boldContent, "utf8");
    runScript(tmpRoot);
    expect(fs.readFileSync(file, "utf8")).not.toBe(boldContent);
  });

  it("skips when excluded dir is passed as direct target", () => {
    const dir = path.join(tmpRoot, "node_modules");
    const file = path.join(dir, "test.md");
    fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(file, boldContent, "utf8");
    runScript(dir);
    expect(fs.readFileSync(file, "utf8")).toBe(boldContent);
  });
});
