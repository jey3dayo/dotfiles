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
const bootstrapTaskPath = path.join(repoRoot, "mise", "tasks", "agents.toml");
const validateWorkflowPath = path.join(repoRoot, ".github", "workflows", "validate.yml");
const isWindows = process.platform === "win32";

const read = (filePath: string) => fs.readFileSync(filePath, "utf8");

describe("scripts/apm-workspace.sh regression checks", () => {
  it("is invoked through bash by bootstrap tasks", () => {
    expect(read(bootstrapTaskPath)).toContain('run = "bash ./scripts/apm-workspace.sh bootstrap"');
  });

  it("does not depend on a workspace mise template anymore", () => {
    const script = read(scriptPath);
    const powershellScript = read(powershellScriptPath);
    const workflow = read(validateWorkflowPath);

    expect(script).not.toContain("MISE_TEMPLATE=");
    expect(script).not.toContain("MANAGED_MISE_MARKER=");
    expect(powershellScript).not.toContain("$MiseTemplate =");
    expect(powershellScript).not.toContain("$ManagedMiseMarker =");
    expect(workflow).not.toContain('templates/apm-workspace/mise.toml');
    expect(workflow).not.toContain("# Managed by ~/.config bootstrap");
  });

  it("does not expose inject-mise anymore", () => {
    const script = read(scriptPath);
    const powershellScript = read(powershellScriptPath);

    expect(script).not.toContain("cmd_inject_mise()");
    expect(script).not.toContain("inject-mise)");
    expect(powershellScript).not.toContain('"inject-mise" {');
    expect(powershellScript).not.toContain("inject-mise        ");
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
      expect(result.stdout).not.toContain("inject-mise");
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

  it("cleans up legacy superpowers skill aliases before reinstall", () => {
    const script = read(scriptPath);
    expect(script).toContain("legacy_internal_cleanup_alias()");
    expect(script).toContain(`printf 'superpowers:%s\\n' "$skill_id"`);
    expect(script).toContain('literal_target_path="$target_root/$skill_id"');
    expect(script).toContain('cleanup_skill_ids=$(internal_cleanup_skill_ids "$skill_ids")');
    expect(script).toContain('remove_internal_target_links "$cleanup_skill_ids"');
  });
});
