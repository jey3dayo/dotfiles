#!/usr/bin/env bun

import { describe, expect, it } from "bun:test";
import { spawnSync } from "node:child_process";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, "..");
const scriptPath = path.join(repoRoot, "scripts", "env-detect.sh");
const isWindows = process.platform === "win32";

const runEnvDetect = ({ extraEnv = {} }: { extraEnv?: Record<string, string | undefined> }) => {
  const env: Record<string, string | undefined> = {
    ...process.env,
    ...extraEnv,
  };
  for (const [key, value] of Object.entries(env)) {
    if (value === undefined) {
      delete env[key];
    }
  }
  return spawnSync("sh", [scriptPath], {
    encoding: "utf8",
    env,
  });
};

(isWindows ? describe.skip : describe)("scripts/env-detect.sh", () => {
  it("detects CI environment when CI is set", () => {
    const result = runEnvDetect({
      extraEnv: { CI: "true", GITHUB_ACTIONS: undefined },
    });

    expect(result.status).toBe(0);
    expect(result.stdout).toMatch(/Detected Environment:[\s\S]*\bci\b/);
    expect(result.stdout).toMatch(/1\. CI: ✓ Matched/);
  });

  it("detects CI environment when GITHUB_ACTIONS is set", () => {
    const result = runEnvDetect({
      extraEnv: { GITHUB_ACTIONS: "true", CI: undefined },
    });

    expect(result.status).toBe(0);
    expect(result.stdout).toMatch(/Detected Environment:[\s\S]*\bci\b/);
    expect(result.stdout).toMatch(/1\. CI: ✓ Matched/);
  });

  it("falls back to default when neither CI nor GITHUB_ACTIONS nor Pi is detected", () => {
    const result = runEnvDetect({
      extraEnv: { CI: undefined, GITHUB_ACTIONS: undefined },
    });

    expect(result.status).toBe(0);
    // This assumes the test machine is not itself a Raspberry Pi (true for
    // CI runners and typical macOS/Linux dev machines, including Apple
    // Silicon: the ARCH check requires aarch64/armv7l/armv6l, and arm64
    // does not match, so is_raspberry_pi() returns false regardless).
    expect(result.stdout).toMatch(/Detected Environment:[\s\S]*\bdefault\b/);
    expect(result.stdout).toMatch(/3\. Default: ✓ Fallback/);
  });

  it("keeps the Raspberry Pi match line consistent with the detected ENV_TYPE", () => {
    const result = runEnvDetect({
      extraEnv: { CI: undefined, GITHUB_ACTIONS: undefined },
    });

    expect(result.status).toBe(0);
    const isPi = /Detected Environment:[\s\S]*\bpi\b/.test(result.stdout);
    if (isPi) {
      expect(result.stdout).toMatch(/2\. Raspberry Pi: ✓ Matched/);
    } else {
      expect(result.stdout).toMatch(/2\. Raspberry Pi: ✗ Not matched/);
    }
  });
});
