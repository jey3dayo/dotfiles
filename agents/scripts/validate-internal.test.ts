#!/usr/bin/env tsx

import * as assert from "node:assert/strict";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { describe, it } from "node:test";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const sourceScript = path.join(__dirname, "validate-internal.sh");

const setupRepo = (): { root: string; scriptPath: string; skillsDir: string } => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "validate-internal-test-"));
  const scriptDir = path.join(root, "agents", "scripts");
  const skillsDir = path.join(root, "agents", "internal", "skills");

  fs.mkdirSync(scriptDir, { recursive: true });
  fs.mkdirSync(skillsDir, { recursive: true });

  const scriptPath = path.join(scriptDir, "validate-internal.sh");
  fs.copyFileSync(sourceScript, scriptPath);
  fs.chmodSync(scriptPath, 0o755);

  return { root, scriptPath, skillsDir };
};

const runScript = (scriptPath: string) =>
  spawnSync("bash", [scriptPath], {
    encoding: "utf8",
  });

describe("agents/scripts/validate-internal.sh", () => {
  it("passes when skills directory has at least one valid skill", () => {
    const repo = setupRepo();
    fs.mkdirSync(path.join(repo.skillsDir, "good-skill"), { recursive: true });
    fs.writeFileSync(path.join(repo.skillsDir, "good-skill", "SKILL.md"), "# skill", "utf8");

    try {
      const result = runScript(repo.scriptPath);
      assert.equal(result.status, 0);
      assert.match(result.stdout, /Distribution validation passed/);
    } finally {
      fs.rmSync(repo.root, { recursive: true, force: true });
    }
  });

  it("fails when skills directory is missing", () => {
    const repo = setupRepo();
    fs.rmSync(repo.skillsDir, { recursive: true, force: true });

    try {
      const result = runScript(repo.scriptPath);
      assert.notEqual(result.status, 0);
      assert.match(result.stdout, /Missing skills directory/);
    } finally {
      fs.rmSync(repo.root, { recursive: true, force: true });
    }
  });

  it("fails when skill directory has no SKILL.md", () => {
    const repo = setupRepo();
    fs.mkdirSync(path.join(repo.skillsDir, "broken-skill"), { recursive: true });

    try {
      const result = runScript(repo.scriptPath);
      assert.notEqual(result.status, 0);
      assert.match(result.stdout, /Missing SKILL\.md/);
    } finally {
      fs.rmSync(repo.root, { recursive: true, force: true });
    }
  });

  it("fails when skills directory is empty", () => {
    const repo = setupRepo();

    try {
      const result = runScript(repo.scriptPath);
      assert.notEqual(result.status, 0);
      assert.match(result.stdout, /No skills found/);
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
      assert.notEqual(result.status, 0);
      assert.match(result.stdout, /Symlink is not allowed/);
    } finally {
      fs.rmSync(repo.root, { recursive: true, force: true });
    }
  });
});
