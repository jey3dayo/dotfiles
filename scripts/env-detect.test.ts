#!/usr/bin/env bun

import { describe, expect, it } from "bun:test";
import { spawnSync } from "node:child_process";
import { repoFile } from "./repo-file.ts";

const scriptPath = repoFile("scripts", "env-detect.sh");
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
  it("detects CI from CI or GITHUB_ACTIONS", () => {
    for (const extraEnv of [
      { CI: "true", GITHUB_ACTIONS: undefined },
      { GITHUB_ACTIONS: "true", CI: undefined },
    ]) {
      const result = runEnvDetect({ extraEnv });

      expect(result.status).toBe(0);
      expect(result.stdout).toMatch(/Detected Environment:[\s\S]*\bci\b/);
    }
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
  });
});
