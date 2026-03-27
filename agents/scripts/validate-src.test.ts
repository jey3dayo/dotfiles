#!/usr/bin/env bun

import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { describe, expect, it } from "bun:test";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const sourceScript = path.join(__dirname, "validate-src.sh");

const setupRepo = (): { root: string; scriptPath: string; skillsDir: string } => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "validate-src-test-"));
  const scriptDir = path.join(root, "agents", "scripts");
  const skillsDir = path.join(root, "agents", "src", "skills");

  fs.mkdirSync(scriptDir, { recursive: true });
  fs.mkdirSync(skillsDir, { recursive: true });

  const scriptPath = path.join(scriptDir, "validate-src.sh");
  fs.copyFileSync(sourceScript, scriptPath);
  fs.chmodSync(scriptPath, 0o755);

  return { root, scriptPath, skillsDir };
};

const runScript = (scriptPath: string) =>
  spawnSync("bash", [scriptPath], {
    encoding: "utf8",
  });

describe("agents/scripts/validate-src.sh", () => {
  it("passes when skills directory has at least one valid skill", () => {
    const repo = setupRepo();
    fs.mkdirSync(path.join(repo.skillsDir, "good-skill"), { recursive: true });
    fs.writeFileSync(path.join(repo.skillsDir, "good-skill", "SKILL.md"), "# skill", "utf8");

    try {
      const result = runScript(repo.scriptPath);
      expect(result.status).toBe(0);
      expect(result.stdout).toMatch(/Distribution validation passed/);
    } finally {
      fs.rmSync(repo.root, { recursive: true, force: true });
    }
  });

  it("fails when skills directory is missing", () => {
    const repo = setupRepo();
    fs.rmSync(repo.skillsDir, { recursive: true, force: true });

    try {
      const result = runScript(repo.scriptPath);
      expect(result.status).not.toBe(0);
      expect(result.stdout).toMatch(/Missing skills directory/);
    } finally {
      fs.rmSync(repo.root, { recursive: true, force: true });
    }
  });

  it("fails when skill directory has no SKILL.md", () => {
    const repo = setupRepo();
    fs.mkdirSync(path.join(repo.skillsDir, "broken-skill"), { recursive: true });

    try {
      const result = runScript(repo.scriptPath);
      expect(result.status).not.toBe(0);
      expect(result.stdout).toMatch(/Missing SKILL\.md/);
    } finally {
      fs.rmSync(repo.root, { recursive: true, force: true });
    }
  });

  it("fails when skills directory is empty", () => {
    const repo = setupRepo();

    try {
      const result = runScript(repo.scriptPath);
      expect(result.status).not.toBe(0);
      expect(result.stdout).toMatch(/No skills found/);
    } finally {
      fs.rmSync(repo.root, { recursive: true, force: true });
    }
  });

  it("fails when a symlink exists under default skills", () => {
    const repo = setupRepo();
    const realSkill = path.join(repo.root, "real-skill");
    fs.mkdirSync(realSkill, { recursive: true });
    fs.writeFileSync(path.join(realSkill, "SKILL.md"), "# real", "utf8");
    fs.symlinkSync(realSkill, path.join(repo.skillsDir, "linked-skill"), "dir");

    try {
      const result = runScript(repo.scriptPath);
      expect(result.status).not.toBe(0);
      expect(result.stdout).toMatch(/Symlink is not allowed/);
    } finally {
      fs.rmSync(repo.root, { recursive: true, force: true });
    }
  });
});
