#!/usr/bin/env bun

import { describe, expect, it } from "bun:test";
import { spawnSync } from "node:child_process";
import * as fs from "node:fs";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, "..");
const scriptPath = path.join(repoRoot, "scripts", "apm-workspace.sh");
const powershellScriptPath = path.join(repoRoot, "scripts", "apm-workspace.ps1");
const migrateExternalWrapperPath = path.join(repoRoot, "scripts", "apm-workspace-migrate-external.ps1");
const bootstrapTaskPath = path.join(repoRoot, "mise", "tasks", "agents.toml");
const validateWorkflowPath = path.join(repoRoot, ".github", "workflows", "validate.yml");
const isWindows = process.platform === "win32";

const read = (filePath: string) => fs.readFileSync(filePath, "utf8");

describe("scripts/apm-workspace.sh regression checks", () => {
  it("publishes only the bootstrap task from mise", () => {
    expect(read(bootstrapTaskPath)).toContain('run = "bash ./scripts/apm-workspace.sh bootstrap"');
    expect(read(bootstrapTaskPath)).toContain("checkout / apm.yml / mise.toml");
    expect(read(bootstrapTaskPath)).not.toContain("managed mise.toml");
  });

  it("does not depend on workspace maintenance helpers anymore", () => {
    const script = read(scriptPath);
    const powershellScript = read(powershellScriptPath);
    const workflow = read(validateWorkflowPath);

    expect(script).not.toContain("CODEX_OUTPUT=");
    expect(script).not.toContain("EXTERNAL_SOURCES_FILE=");
    expect(powershellScript).not.toContain("$CodexOutput =");
    expect(powershellScript).not.toContain("$ExternalSourcesFile =");
    expect(workflow).not.toContain("maintenance helpers");
  });

  it("does not expose runtime maintenance commands anymore", () => {
    const script = read(scriptPath);
    const powershellScript = read(powershellScriptPath);

    for (const command of [
      "apply",
      "update",
      "list",
      "pin-external",
      "validate",
      "validate-catalog",
      "doctor",
      "bundle-catalog",
      "stage-catalog",
      "register-catalog",
      "release-catalog",
      "smoke-catalog",
      "migrate-external",
    ]) {
      expect(script).not.toContain(`  ${command}`);
      expect(powershellScript).not.toContain(`  ${command}`);
    }
  });

  it("removes the migrate-external wrapper script", () => {
    expect(fs.existsSync(migrateExternalWrapperPath)).toBe(false);
  });

  it("uses a bash shebang", () => {
    expect(read(scriptPath).startsWith("#!/usr/bin/env bash\n")).toBe(true);
  });

  if (!isWindows) {
    it("shows help successfully when run with bash", () => {
      const result = spawnSync("bash", [scriptPath, "help"], {
        encoding: "utf8",
        cwd: repoRoot,
      });

      expect(result.error).toBeUndefined();
      expect(result.status).toBe(0);
      expect(result.stdout).toContain("Usage: scripts/apm-workspace.sh <command> [args...]");
      expect(result.stdout).toContain("bootstrap");
      expect(result.stdout).not.toContain("apply");
      expect(result.stdout).not.toContain("migrate-external");
    });
  }
});
