#!/usr/bin/env bun

import { afterEach, beforeEach, describe, expect, it } from "bun:test";
import { execSync, spawnSync } from "node:child_process";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { repoFile } from "./repo-file.ts";

const scriptPath = repoFile("scripts", "replace-bold-headings.ts");

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

  it("converts bold label with trailing colon into a heading", () =>
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

  it("strips bold from unordered list label (colon only)", () => check("- **Text**:", "- Text:"));

  it("strips bold from unordered list label (no colon)", () =>
    check("- **関連ファイル（4ファイル）**", "- 関連ファイル（4ファイル）"));

  it("strips bold when colon is inside bold markers", () =>
    check("**責務:** Valibotスキーマ定義", "責務: Valibotスキーマ定義"));

  it("strips bold when colon inside bold, backtick content", () =>
    check("**返り値の型:** `v.BaseSchema` + 推論型", "返り値の型: `v.BaseSchema` + 推論型"));

  it("preserves all bold in ordered list navigation path", () =>
    check(
      "2. **Workers & Pages** → **keep-on** → **Metrics** タブ",
      "2. **Workers & Pages** → **keep-on** → **Metrics** タブ",
    ));

  // Table cell bold stripping
  it("strips bold from table cell label", () => check("| **スキル名** | 説明 |", "| スキル名 | 説明 |"));

  it("strips bold from multiple table cells", () => check("| **A** | **B** | **C** |", "| A | B | C |"));

  it("preserves table separator row", () => check("| --- | --- |", "| --- | --- |"));

  it("strips bold from row with dashes in first cell", () => check("| --- | **value** |", "| --- | value |"));
});

// ============================================================
// Dry-run gate
// ============================================================
describe("replace-bold-headings: dry-run gate", () => {
  let tmpRoot: string;

  beforeEach(() => {
    tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), "rbh-dry-"));
  });

  afterEach(() => {
    fs.rmSync(tmpRoot, { recursive: true, force: true });
  });

  const runDryRun = (target: string) =>
    spawnSync("tsx", [scriptPath, target, "--dry-run"], { encoding: "utf8", stdio: "pipe" });

  it("fails when patterns remain and leaves the file untouched", () => {
    const file = path.join(tmpRoot, "dirty.md");
    fs.writeFileSync(file, "**Overview**\n", "utf8");

    const result = runDryRun(tmpRoot);

    expect(result.status).toBe(1);
    expect(fs.readFileSync(file, "utf8")).toBe("**Overview**\n");
  });

  it("passes when no patterns remain", () => {
    fs.writeFileSync(path.join(tmpRoot, "clean.md"), "### Overview\n", "utf8");

    expect(runDryRun(tmpRoot).status).toBe(0);
  });
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
    path.join("catalog", ".apm", "skills"),
    path.join(".claude", "skills"),
    path.join(".claude", "worktrees"),
    path.join(".codex", "skills"),
    ".kiro",
    ".luarocks",
    "fisher",
    "result",
    "result-abc",
    path.join("zsh", ".zinit"),
    path.join("agents", "external"),
    "tmp",
    path.join("opencode", "skills"),
    path.join("opencode", "agents"),
    path.join("opencode", "commands"),
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

  it("processes boundary-like dir (my-agents/external)", () => {
    const file = path.join(tmpRoot, "my-agents", "external", "test.md");
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

// ============================================================
// Workspace-aware target resolution
// ============================================================
describe("replace-bold-headings: workspace-aware resolution", () => {
  const boldContent = "**Overview**\n";
  let tmpRoot: string;

  beforeEach(() => {
    tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), "rbh-prov-"));
  });

  afterEach(() => {
    fs.rmSync(tmpRoot, { recursive: true, force: true });
  });

  it("only rewrites catalog/skills when the target is an ~/.apm-style workspace root", () => {
    const personalFile = path.join(tmpRoot, "catalog", "skills", "personal-skill", "SKILL.md");
    const legacyCatalogFile = path.join(tmpRoot, "catalog", ".apm", "skills", "external-skill", "SKILL.md");

    fs.mkdirSync(path.dirname(personalFile), { recursive: true });
    fs.mkdirSync(path.dirname(legacyCatalogFile), { recursive: true });
    fs.writeFileSync(personalFile, boldContent, "utf8");
    fs.writeFileSync(legacyCatalogFile, boldContent, "utf8");
    fs.writeFileSync(path.join(tmpRoot, "apm.yml"), "name: tmp\n", "utf8");

    execSync(`cd "${tmpRoot}" && tsx "${scriptPath}" .`, { encoding: "utf8", stdio: "pipe" });

    expect(fs.readFileSync(personalFile, "utf8")).toBe("### Overview\n");
    expect(fs.readFileSync(legacyCatalogFile, "utf8")).toBe(boldContent);
  });
});
