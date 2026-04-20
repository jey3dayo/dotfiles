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
const bootstrapTaskPath = path.join(repoRoot, "mise", "tasks", "agents.toml");
const workspaceMiseTemplatePath = path.join(repoRoot, "templates", "apm-workspace", "mise.toml");
const isWindows = process.platform === "win32";
const bootstrapRepoRef = `\${APM_BOOTSTRAP_REPO:-$HOME/.config}`;

const read = (filePath: string) => fs.readFileSync(filePath, "utf8");

describe("scripts/apm-workspace.sh regression checks", () => {
  it("is invoked through bash by bootstrap tasks and workspace tasks", () => {
    expect(read(bootstrapTaskPath)).toContain('run = "bash ./scripts/apm-workspace.sh bootstrap"');

    const template = read(workspaceMiseTemplatePath);
    expect(template).toContain(`run = "bash \\"${bootstrapRepoRef}/scripts/apm-workspace.sh\\" apply"`);
    expect(template).toContain(`run = "bash \\"${bootstrapRepoRef}/scripts/apm-workspace.sh\\" migrate-external"`);
    expect(template).toContain(`bash "${bootstrapRepoRef}/scripts/apm-workspace.sh" release-catalog`);
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
    });
  }

  it("uses the defined tracking helper name", () => {
    const script = read(scriptPath);
    expect(script).toContain("workspace_tracking_info()");
    expect(script).not.toContain("get_workspace_tracking_info");
  });

  it("parses tracking info with the control-character delimiter in release-catalog checks", () => {
    const script = read(scriptPath);
    expect(script).toContain(`remote_name=\${tracking_info%%"$(printf '\\036')"*}`);
    expect(script).toContain(`branch_name=\${tracking_info#*"$(printf '\\036')"}`);
  });

  it("defines the error logger used by validate-catalog", () => {
    const script = read(scriptPath);
    expect(script).toContain("error() {");
    expect(script).toContain('    error "Tracked catalog manifest is missing: $tracked_manifest"');
  });
});
